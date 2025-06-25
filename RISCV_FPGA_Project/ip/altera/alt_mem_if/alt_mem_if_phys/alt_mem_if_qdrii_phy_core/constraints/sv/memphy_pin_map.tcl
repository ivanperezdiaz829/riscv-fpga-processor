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

proc memphy_traverse_atom_path {atom_id atom_oport_id path} {
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

proc memphy_traverse_to_ddio_out_pll_clock {pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set result ""
	if {$pin != ""} {
		set pin_id [get_atom_node_by_name -name $pin]
		set pin_to_pll_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLK -optional} {DDIO_OUT fanin CLKHI -optional} {CLK_PHASE_SELECT fanin CLKIN -optional} {LEVELING_DELAY_CHAIN fanin CLKIN -optional} {CLKBUF fanin INCLK -optional} {PLL_OUTPUT_COUNTER end DIVCLK}]
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

proc memphy_traverse_to_leveling_delay_chain {pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set result ""
	if {$pin != ""} {
		set pin_id [get_atom_node_by_name -name $pin]
		set pin_to_leveling_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLK -optional} {DDIO_OUT fanin CLKHI -optional} {CLK_PHASE_SELECT fanin CLKIN -optional} {LEVELING_DELAY_CHAIN end CLKOUT} ]
		set leveling_id_list [memphy_traverse_atom_path $pin_id -1 $pin_to_leveling_path]
		if {[llength $leveling_id_list] == 1} {
			set atom_oterm_pair [lindex $leveling_id_list 0]
			set result [get_atom_node_info -key name -node [lindex $atom_oterm_pair 0]]
		} else {
			lappend msg_list "Error: Leveling delay chain not found for $pin"
		}
	}

	regsub {^[^\:]+\:} $result "" result
	regsub -all {\|[^\:]+\:} $result "|" result

	return $result
}

proc memphy_traverse_to_clock_phase_select {pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set result ""
	if {$pin != ""} {
		set pin_id [get_atom_node_by_name -name $pin]
		set pin_to_cps_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLK -optional} {DDIO_OUT fanin CLKHI -optional} {CLK_PHASE_SELECT end CLKOUT} ]
		set cps_id_list [memphy_traverse_atom_path $pin_id -1 $pin_to_cps_path]
		if {[llength $cps_id_list] == 1} {
			set atom_oterm_pair [lindex $cps_id_list 0]
			set result [get_atom_node_info -key name -node [lindex $atom_oterm_pair 0]]
		} else {
			lappend msg_list "Error: Clock phase select not found for $pin"
		}
	}

	regsub {^[^\:]+\:} $result "" result
	regsub -all {\|[^\:]+\:} $result "|" result

	return $result
}

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

	set d_groups [ list ]

	foreach d_group $pins(d_groups) {
		set d_group $d_group
		lappend d_groups $d_group
	}
	set all_d_pins [ join [ join $d_groups ] ]
	set all_bws_pins $pins(all_bws_pins)

	set all_d_bws_pins [ concat $all_d_pins $all_bws_pins ]
	foreach d_bws_pin $all_d_bws_pins {
		set io_type [memphy_get_fitter_report_pin_io_type_info $d_bws_pin]
		if {[string compare -nocase "Column I/O" $io_type] == 0} {
			set io_types("column") 1
		} elseif {[string compare -nocase "Row I/O" $io_type] == 0} {
			set io_types("row") 1
		} else {
			post_message -type warning "Could not determine IO type for pin $d_bws_pin"
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

proc memphy_verify_high_performance_timing_assumptions { inst pins_array_name IP_name mem_if_memtype } {
	upvar $pins_array_name pins
	upvar $IP_name IP

	set num_errors 0
	load_package verify_ddr
	set k_kn_pairs [list]
	set failed_assumptions [list]
	if {[llength $pins(k_pins)] > 0 && [llength $pins(k_pins)] == [llength $pins(kn_pins)]} {
		for {set k_index 0} {$k_index != [llength $pins(k_pins)]} {incr k_index} {
			lappend k_kn_pairs [list [lindex $pins(k_pins) $k_index] [lindex $pins(kn_pins) $k_index]]
		}
	} else {
		incr num_errors
		lappend failed_assumptions "Error: Could not locate same number of CK pins as CK# pins"
	}

	set read_pins_list [list]
	set write_pins_list [list]
	set read_clock_pairs [list]
	set write_clock_pairs [list]
`ifdef IPTCL_RL2
	foreach { cq_n } $pins(cq_n_pins) { dq_list } $pins(q_groups) {
		lappend read_pins_list [list $cq_n $dq_list]
	}
`else
	foreach { cq } $pins(cq_pins) { dq_list } $pins(q_groups) {
		lappend read_pins_list [list $cq $dq_list]
	}
`endif

	# QDRII only supports one group on the write side
	if { [ llength $pins(k_pins) ] != $IP(device_width) } {
		incr num_errors
		lappend failed_assumptions "Error: The number of K pins is not equal to $IP(device_width)"
	}
	if { [ llength $pins(kn_pins) ] != $IP(device_width) } {
		incr num_errors
		lappend failed_assumptions "Error: The number of Kn pins is not equal to $IP(device_width)"
	}
	if {$num_errors == 0} {
		set group_index 0
		set number_of_d_groups_per_device [ expr [llength $pins(d_groups)] / $IP(device_width) ]
		
		foreach { k } $pins(k_pins) {kn} $pins(kn_pins) {
			lappend write_clock_pairs [list $k $kn]
			
			set end_group_index [ expr $group_index + $number_of_d_groups_per_device ]
			for { } {$group_index < $end_group_index} {incr group_index} {
				set dq_list [ lindex $pins(d_groups) $group_index ]
				set bws_list [ lindex $pins(bws_groups) $group_index ]
				lappend write_pins_list [list $k $dq_list]
			}
		}	
	}

	set all_write_dqs_list $pins(k_pins)
	set all_d_list $pins(all_d_pins)
	if {[llength $pins(q_groups)] == 0} {
		incr num_errors
		lappend failed_assumptions "Error: Could not locate DQS pins"
	}

	if {$num_errors == 0} {
		set msg_list [list]
		set cq [ lindex $pins(cq_pins) 0 ]
		set dll_name [memphy_traverse_to_dll $cq msg_list]
		set clk_to_write_d [memphy_traverse_to_ddio_out_pll_clock [lindex $all_d_list 0] msg_list]
		set clk_to_write_clock [memphy_traverse_to_ddio_out_pll_clock [lindex $all_write_dqs_list 0] msg_list]
		set clk_to_k_kn [memphy_traverse_to_ddio_out_pll_clock [lindex $pins(k_pins) 0] msg_list]
		foreach msg $msg_list {
			set verify_assumptions_exception 1
			incr num_errors
			lappend failed_assumptions $msg
		}
		if {$num_errors == 0} {
			set verify_assumptions_exception 0
			set verify_assumptions_result {0}
`ifdef IPTCL_EMULATED_MODE
`ifdef IPTCL_NIOS_SEQUENCER
			set verify_assumptions_exception [catch {verify_assumptions -uniphy_deskew -memory_type $mem_if_memtype \
				-read_pins_list $read_pins_list -write_pins_list $write_pins_list -ck_ckn_pairs $k_kn_pairs \
				-clk_to_write_d $clk_to_write_d -clk_to_write_clock $clk_to_write_clock -clk_to_ck_ckn $clk_to_k_kn \
				-dll $dll_name -write_clock_pairs $write_clock_pairs -mem_var {pseudo_x36 1} } verify_assumptions_result]
`else
			set verify_assumptions_exception [catch {verify_assumptions -uniphy -memory_type $mem_if_memtype \
				-read_pins_list $read_pins_list -write_pins_list $write_pins_list -ck_ckn_pairs $k_kn_pairs \
				-clk_to_write_d $clk_to_write_d -clk_to_write_clock $clk_to_write_clock -clk_to_ck_ckn $clk_to_k_kn \
				-dll $dll_name -write_clock_pairs $write_clock_pairs -mem_var {pseudo_x36 1} } verify_assumptions_result]
`endif				
`else
`ifdef IPTCL_NIOS_SEQUENCER
			set verify_assumptions_exception [catch {verify_assumptions -uniphy_deskew -memory_type $mem_if_memtype \
				-read_pins_list $read_pins_list -write_pins_list $write_pins_list -ck_ckn_pairs $k_kn_pairs \
				-clk_to_write_d $clk_to_write_d -clk_to_write_clock $clk_to_write_clock -clk_to_ck_ckn $clk_to_k_kn \
				-dll $dll_name -write_clock_pairs $write_clock_pairs } verify_assumptions_result]
`else
			set verify_assumptions_exception [catch {verify_assumptions -uniphy -memory_type $mem_if_memtype \
				-read_pins_list $read_pins_list -write_pins_list $write_pins_list -ck_ckn_pairs $k_kn_pairs \
				-clk_to_write_d $clk_to_write_d -clk_to_write_clock $clk_to_write_clock -clk_to_ck_ckn $clk_to_k_kn \
				-dll $dll_name -write_clock_pairs $write_clock_pairs } verify_assumptions_result]
`endif				
`endif
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

proc memphy_get_tsw { mem_if_memtype dqs_list period} {
	global TimeQuestInfo
	set interface_type [memphy_get_io_interface_type $dqs_list]
	set io_std [memphy_get_io_standard [lindex $dqs_list 0]]
	if {$interface_type != "" && $interface_type != "UNKNOWN" && $io_std != "" && $io_std != "UNKNOWN"} {
		package require ::quartus::ddr_timing_model
		set family $TimeQuestInfo(family)

		set parameters_list [ list IO $interface_type ]
		if { [ string match -nocase $family "STRATIX III" ] } {
			lappend parameters_list "UNIPHY"
		}

		if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters $parameters_list } tsw_setup] != 0 \
			|| $tsw_setup == "" || $tsw_setup == 0 \
			|| [catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters $parameters_list } tsw_hold] != 0 \
			|| $tsw_hold == "" || $tsw_hold == 0 } {
			error "Missing $family timing model for tSW of $io_std $interface_type"
		} else {
			if {[get_part_info -package -pin_count $TimeQuestInfo(part)] == "PQFP 240"} {
				if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std \
					-parameters [list IO $interface_type Q240_DERATING]} tsw_setup_derating] != 0 \
					|| $tsw_setup_derating == 0 \
					|| [catch {get_io_standard_node_delay -dst TH -io_standard $io_std \
					-parameters [list IO $interface_type Q240_DERATING]} tsw_hold_derating] != 0 || $tsw_hold_derating == 0} {
					set f "$io_std/$interface_type/$family"
					switch -glob $f {
						"SSTL_18*/VPAD/Cyclone III" {
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

proc memphy_get_tccs { mem_if_memtype dqs_list period } {
	global TimeQuestInfo
	set interface_type [memphy_get_io_interface_type $dqs_list]
	if {$interface_type == "HYBRID"} {
		set interface_type "HPAD"
	}
	set io_std [memphy_get_io_standard [lindex $dqs_list 0]]
	set result [list 0 0]
	if {$interface_type != "" && $interface_type != "UNKNOWN" && $io_std != "" && $io_std != "UNKNOWN"} {
		package require ::quartus::ddr_timing_model
		set family $TimeQuestInfo(family)

		set parameters_list [ list IO $interface_type ]
		if { [ string match -nocase $family "STRATIX III" ] } {
			lappend parameters_list "UNIPHY"
		}

		if {[catch {get_io_standard_node_delay -dst TCCS_LEAD -io_standard $io_std -parameters $parameters_list } tccs_lead] != 0 \
			|| $tccs_lead == "" || $tccs_lead == 0 \
			|| [catch {get_io_standard_node_delay -dst TCCS_LAG -io_standard $io_std -parameters $parameters_list } tccs_lag] != 0 \
			|| $tccs_lag == "" || $tccs_lag == 0 } {
			error "Missing $family timing model for tCCS of $io_std $interface_type"
		} else {
			return [list $tccs_lead $tccs_lag]
		}
	}
}

proc memphy_get_fitter_report_pin_info_from_report {target_pin info_type pin_report_id} {
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

proc memphy_get_fitter_report_pin_info {target_pin info_type preferred_report_id {found_report_id_name ""}} {
	if {$found_report_id_name != ""} {
		upvar 1 $found_report_id_name found_report_id
	}
	set found_report_id -1
	set result ""
	if {$preferred_report_id == -1} {
		set pin_report_list [list "Fitter||Resource Section||Input Pins" "Fitter||Resource Section||Output Pins"]
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
proc memphy_get_fitter_report_pin_io_type_info {target_pin} {
	return "Column I/O"
}
proc memphy_get_io_interface_type {pin_list} {
	set preferred_report_id -1
	set interface_type ""
	foreach target_pin $pin_list {
		set io_bank [memphy_get_fitter_report_pin_info $target_pin "I/O Bank" $preferred_report_id preferred_report_id]
		if {[regexp -- {^([0-9]+)[A-Z]*} $io_bank -> io_bank_number]} {
			if {$io_bank_number == 1 || $io_bank_number == 2 || $io_bank_number == 5 || $io_bank_number == 6} {
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
				set interface_type "HYBRID"
			}
		}
	}
	return $interface_type
}


proc memphy_get_report_column { report_id str} {
	set target_col [get_report_panel_column_index -id $report_id $str]
	if {$target_col == -1} {
		error "Cannot find $str column"
	}
	return $target_col
}

proc memphy_get_qdr_tsw_derating { dqs_list } {
	global TimeQuestInfo
	set io_std [memphy_get_io_standard [lindex $dqs_list 0]]
	set interface_type [memphy_get_io_interface_type [lindex $dqs_list 0]]

	if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tsw_setup] != 0 \
		|| $tsw_setup == "" \
		|| [catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tsw_hold] != 0 \
		|| $tsw_hold == "" || $tsw_hold == 0 } {
		set family $TimeQuestInfo(family)
		error "Missing $family timing model for derated tSW of $io_std $interface_type"
	} else {
		set result [list $tsw_setup $tsw_hold]
	}
	return $result
}

proc memphy_get_qdr_tccs_derating { dqs_list } {
	set io_std [memphy_get_io_standard [lindex $dqs_list 0]]
	set interface_type [memphy_get_io_interface_type [lindex $dqs_list 0]]

	if {[catch {get_io_standard_node_delay -dst TCCS_LEAD -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tccs_lead] != 0 \
		|| $tccs_lead == "" || $tccs_lead == 0 \
		|| [catch {get_io_standard_node_delay -dst TCCS_LAG -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tccs_lag] != 0 \
		|| $tccs_lag == "" || $tccs_lag == 0 } {
		set family $TimeQuestInfo(family)
		error "Missing $family timing model for derated tCCS of $io_std $interface_type"
	} else {
		set result [list $tccs_lead $tccs_lag]
	}

	return $result
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
			set dqs_phase_setting [get_atom_node_info -key INT_PHASE_SETTING -node $dqs_delay_chain_id]
		}
	}

	if {$dqs_phase_setting == 0} {
		set dqs_phase_setting 2
		post_message -type critical_warning "Unable to determine DQS delay chain phase setting.  Assuming default setting of $dqs_phase_setting"
	}

	return $dqs_phase_setting
}

proc memphy_get_dqs_phase { dqs_pins } {
	set dll_length 8
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

proc memphy_find_oct_blocks { instname } {
	set blocks [ list ]
	set sd2a_0_atom ""
	set sd1a_0_atom ""
	set match_data_out ${instname}|p0|umemphy|uio_pads|dq_ddio[0].uwrite|altdq_dqs2_inst|pad_gen[0].data_out
	load_package atoms
	read_atom_netlist
	set_project_mode -always_show_entity_name off
	set dataout_atoms [get_atom_nodes -matching [escape_brackets $match_data_out] ]
	if { [get_collection_size $dataout_atoms] == 1 } {
		foreach_in_collection dataout_atom $dataout_atoms { 
			set dataout_atom_name [get_atom_node_info -key name -node $dataout_atom] 
			set iterms [get_atom_iports -node $dataout_atom]
			foreach iterm $iterms { 
				set fanin	[get_atom_port_info -node $dataout_atom -type iport -port_id $iterm -key fanin]
				set sd2a_0_atom [lindex $fanin 0]
				set sd2a_0_atom_name [get_atom_node_info -key name -node $sd2a_0_atom]
				if { [regexp "oct0|sd2a_0" $sd2a_0_atom_name] } {
					break
				}
			}
		}	
		
		set sda_2_0_iterms [get_atom_iports -node $sd2a_0_atom]
		foreach sda_2_0_iterm $sda_2_0_iterms {
			set fanin	[get_atom_port_info -node $sd2a_0_atom -type iport -port_id $sda_2_0_iterm -key fanin]
			set sd1a_0_atom [lindex $fanin 0]
			set sd1a_0_atom_name [get_atom_node_info -key name -node $sd1a_0_atom]
			if { [regexp "oct0|sd1a_0" $sd1a_0_atom_name] } {
				set_project_mode -always_show_entity_name on
				set sd1a_0_atom_proper_name [get_atom_node_info -key name -node $sd1a_0_atom]
				lappend blocks $sd1a_0_atom_proper_name
				break
			}
		}
	} else {
		if { [get_collection_size $dataout_atoms] == 0 } {
			post_message -type warning " Correct OCT Block cannot be find as no dataout atom found for the $instname instance ";
		}
		if { [get_collection_size $dataout_atoms] > 1 } {
			post_message -type warning " Correct OCT Block cannot be find as multiple dataout atoms found for the $instname instance ";
		}
	}
	
	set_project_mode -always_show_entity_name qsf
	return $blocks
}

proc memphy_get_ddr_pins { instname allpins } {
	upvar allpins pins

	global ::GLOBAL_q_group_size
	global ::GLOBAL_d_group_size
	global ::GLOBAL_number_of_d_groups
	global ::GLOBAL_number_of_q_groups
	global ::GLOBAL_device_width
	
	set synthesis_flow 0
	set sta_flow 0
	if { $::TimeQuestInfo(nameofexecutable) == "quartus_map" } {
		set synthesis_flow 1
	} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_sta" } {
		set sta_flow 1
	}
	
	set number_of_d_pins [ expr $::GLOBAL_number_of_d_groups * $::GLOBAL_q_group_size ]
	set number_of_d_groups_per_device [ expr $::GLOBAL_number_of_d_groups /  $::GLOBAL_device_width ]

	set cq_pins [ list ]
	set cq_n_pins [ list ]
	set q_groups [ list ]
	set dqs_in_clocks [ list ]
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set d_leveling_pins [ list ]
	set k_leveling_pins [ list ]
	set ac_leveling_pins [ list ]
`endif
		
	for { set i 0 } { $i < $::GLOBAL_number_of_q_groups } { incr i } {
`ifdef IPTCL_RL2
		set cq_string ${instname}|p0|umemphy|uio_pads|read_capture[$i].uread|altdq_dqs2_inst|strobe_n_in|i
		set cq_n_string ${instname}|p0|umemphy|uio_pads|read_capture[$i].uread|altdq_dqs2_inst|strobe_in|i
`else
		set cq_string ${instname}|p0|umemphy|uio_pads|read_capture[$i].uread|altdq_dqs2_inst|strobe_in|i
		set cq_n_string ${instname}|p0|umemphy|uio_pads|read_capture[$i].uread|altdq_dqs2_inst|strobe_n_in|i
`endif
`ifdef IPTCL_SINGLE_CAPTURE_STROBE
	`ifdef IPTCL_RL2
		set cq_local_pins [ memphy_get_names_in_collection [ get_fanins $cq_n_string ] ]
	`else
		set cq_local_pins [ memphy_get_names_in_collection [ get_fanins $cq_string ] ]
	`endif
`else
		set cq_local_pins [ memphy_get_names_in_collection [ get_fanins $cq_string ] ]
		set cq_n_local_pins [ memphy_get_names_in_collection [ get_fanins $cq_n_string ] ]
`endif

		set q_group [ list ]
		for { set j 0 } { $j < $::GLOBAL_q_group_size } { incr j } {
			set q_string ${instname}|p0|umemphy|uio_pads|read_capture[$i].uread|altdq_dqs2_inst|pad_gen[$j].data_in|i
			set tmp_q_pins [ memphy_get_names_in_collection [ get_fanins $q_string ] ]

			lappend q_group $tmp_q_pins
		}

		if { [llength $cq_local_pins] != 1 } {
			post_sdc_message critical_warning "Could not find CQ pin number $i"
		} else {
			lappend cq_pins [ lindex $cq_local_pins 0 ]

			set dqs_in_clock(dqs_pin) [ lindex $cq_local_pins 0 ]
			set dqs_in_clock(div_name) "${instname}|div_clock_$i"
`ifdef IPTCL_USE_IO_CLOCK_DIVIDER
			set dqs_in_clock(div_pin) "${instname}|p0|umemphy|uread_datapath|clock_div2[$i].uread_clock_divider*|clkout"
`else			
			set dqs_in_clock(div_pin) "${instname}|p0|umemphy|uread_datapath|read_capture_clk_div2[$i]"
`endif			
			lappend dqs_in_clocks [ array get dqs_in_clock ]
		}

`ifdef IPTCL_SINGLE_CAPTURE_STROBE
`else
		if { [llength $cq_n_local_pins] != 1 } {
			post_sdc_message critical_warning "Could not find QKn pin number $i"
		} else {
			lappend cq_n_pins [ lindex $cq_n_local_pins 0 ]
		}
`endif
		
		if { [llength $q_group] != $::GLOBAL_q_group_size } {
			post_sdc_message critical_warning "Could not find correct number of Q pins for CQ pin $i. \
				Found [llength $q_pins] pins. Expecting ${::GLOBAL_q_group_size}."
		} else {
			lappend q_groups [ join $q_group ]
		}
	}

	set pins(cq_pins) $cq_pins
	set pins(cq_n_pins) $cq_n_pins
	set pins(q_groups) $q_groups
	set pins(all_q_pins) [ join [ join $q_groups ] ]


	set k_pins [ list ]
	set kn_pins [ list ]
	for { set i 0 } { $i < $::GLOBAL_number_of_k_pins } { incr i } {
		set k_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].uwrite|altdq_dqs2_inst|obuf_os_0|o
		set kn_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].uwrite|altdq_dqs2_inst|obuf_os_bar_0|o

		set k_local_pins [ memphy_get_names_in_collection [ get_fanouts $k_string ] ]
		set kn_local_pins [ memphy_get_names_in_collection [ get_fanouts $kn_string ] ]

		if { [llength $k_local_pins] != 1 } {
			post_sdc_message critical_warning "Could not find K pin number $i"
		} else {
			lappend k_pins [ join $k_local_pins ]
		}
		
		if { [llength $kn_local_pins] != 1 } {
			post_sdc_message critical_warning "Could not find Kn pin number $i"
		} else {
			lappend kn_pins [ join $kn_local_pins ]
		}
	}

	set pins(k_pins) $k_pins
	set pins(kn_pins) $kn_pins


	set d_groups [ list ]

	set d_group_heads [list]
	set d_group_types [list]
 
	set msg_list [ list ]

	for { set i 0 } { $i < $::GLOBAL_number_of_d_groups } { incr i } {

		set d_group [ list ]
		for { set j 0 } { $j < $::GLOBAL_d_group_size } { incr j } {
			set dqdqs_index [ expr int($i / $number_of_d_groups_per_device) ]
			set pad_index [ expr ($i % $number_of_d_groups_per_device) * $::GLOBAL_d_group_size + $j ]
			set d_string ${instname}|p0|umemphy|uio_pads|dq_ddio[$dqdqs_index].uwrite|altdq_dqs2_inst|pad_gen[$pad_index].data_out|i
			
			set tmp_d_pins [ memphy_get_names_in_collection [ get_fanouts $d_string ] ]
			lappend d_group $tmp_d_pins
		}

		if { [llength $d_group] != $::GLOBAL_d_group_size } {
			post_sdc_message critical_warning "Could not find correct number of D pins for K pin $i. \
				Found [llength $d_p] pins. Expecting ${::GLOBAL_d_group_size}."
		}

`ifdef IPTCL_NIOS_SEQUENCER
		set number_of_d_groups_per_k_pin [expr $::GLOBAL_number_of_d_groups / $::GLOBAL_number_of_k_pins]
		if { [expr $i % $number_of_d_groups_per_k_pin] == 0 } {
			set d_head_pin [ lindex $pins(k_pins) [expr $i / $number_of_d_groups_per_k_pin] ]
			lappend d_group_types DQ_GROUP
		} else {
`endif
			set d_head_pin [ lindex $d_group 0 ]
			lappend d_group_types MEMORY_INTERFACE_DATA_PIN_GROUP
`ifdef IPTCL_NIOS_SEQUENCER
		}
`endif

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
		set patterns "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].uwrite|altdq_dqs2_inst|dq_select*|clkout"
		lappend d_leveling_pins [ memphy_get_names_in_collection [ get_pins $patterns ] ]
		
		set k_cps_id [memphy_get_output_clock_clk_phase_select_id [lindex $pins(k_pins) $i] "K CLK CPS" msg_list]
		if {$k_cps_id == -1} {
			foreach {msg_type msg} $msg_list {
				post_message -type $msg_type "memphy.sdc: $msg"
			}
			post_message -type critical_warning "memphy.sdc: Failed to find CPS output for pin [lindex $pins(k_pins) $i]"
			lappend k_leveling_pins "CPS_NOT_FOUND"
		} else {
			set k_cps [get_node_info -name $k_cps_id]
			lappend k_leveling_pins [ memphy_get_names_in_collection [ get_pins $k_cps ] ]
		}
`endif

		lappend d_groups [ join $d_group ]
		lappend d_group_heads [ join $d_head_pin ]
	}
	
	set pins(d_groups) $d_groups
	set pins(all_d_pins) [ join [ join $d_groups ] ]
	set pins(d_group_heads) $d_group_heads
	set pins(d_group_types) $d_group_types

	set number_of_bws_pins [ expr $::GLOBAL_number_of_d_groups * $::GLOBAL_d_group_size / 9 ]
	set number_of_bws_per_d_group [ expr $number_of_bws_pins / $::GLOBAL_number_of_d_groups ]

	set index 0
	set bws_groups [ list ]
	for { set i 0 } { $i < $::GLOBAL_number_of_d_groups } { incr i } {
		set bws_group [ list ]
		for { set j 0 } { $j < $number_of_bws_per_d_group} { incr j } {
			set dqdqs_index [ expr int($i / $number_of_d_groups_per_device) ]
			set pad_index [expr ($i % $number_of_d_groups_per_device) * $number_of_bws_per_d_group + $j]
			set bws_string ${instname}|p0|umemphy|uio_pads|dq_ddio[$dqdqs_index].uwrite|altdq_dqs2_inst|extra_output_pad_gen[$pad_index].obuf_1|o

			set tmp_bws_pins [ memphy_get_names_in_collection [ get_fanouts $bws_string ] ]
			lappend bws_group [ join $tmp_bws_pins ]

			incr index
		}

		lappend bws_groups [ join $bws_group ]
	} 

	set pins(bws_groups) $bws_groups
	set pins(all_bws_pins) [ join [ join $bws_groups ] ]

	set pins(all_d_bws_pins) [ concat $pins(all_d_pins) [ join $pins(bws_groups) ] ]

	set pins(dqs_in_clocks) $dqs_in_clocks
	

	set pins(add_pins) [ list ]
	set pins(cmd_pins) [ list ]
	set pins(doff_pin) [ list ]

	set patterns [ list ]
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	`ifdef IPTCL_FULL_RATE
	set addr_cmd_postfix "*fr_ddio_out|*ddio_o|dataout"
	`else
	set addr_cmd_postfix "fr_data_reg*"
	`endif
`else
	set addr_cmd_postfix "auto_generated|ddio_outa[*]|dataout"
`endif
	lappend patterns add_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|uaddress_pad|${addr_cmd_postfix}
	lappend patterns cmd_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|uwps_n_pad|${addr_cmd_postfix}
	lappend patterns cmd_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|urps_n_pad|${addr_cmd_postfix}
	
	lappend patterns doff_pin ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|udoff_n_pad|*fr_ddio_out|*ddio_o|dataout
	
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
	
	set pins(ac_pins) [ concat $pins(add_pins) $pins(cmd_pins) $pins(doff_pin)]
	set pins(ac_pins_wo_doff) [ concat $pins(add_pins) $pins(cmd_pins)]

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	for { set i 0 } { $i < [ llength $pins(ac_pins_wo_doff) ] } { incr i } {
		set ac_pin [ lindex $pins(ac_pins_wo_doff) $i ]		
		
		set tmp_msg_list [ list ]
		set ac_cps_id [memphy_get_output_clock_clk_phase_select_id $ac_pin "AC CPS Output" tmp_msg_list]
		if {$ac_cps_id == -1} {
			foreach {msg_type msg} $tmp_msg_list {
				post_message -type $msg_type "memphy.sdc: $msg"
			}
			post_message -type critical_warning "memphy.sdc: Failed to find CPS output for pin $ac_pin"
			lappend ac_leveling_pins "CPS_NOT_FOUND"
		} else {
			set ac_cps "{[get_node_info -name $ac_cps_id]}"
			lappend ac_leveling_pins ${ac_cps}
		}
	}
	set pins(k_leveling_pins) [ join $k_leveling_pins ]
	set pins(d_leveling_pins) [ join $d_leveling_pins ]
	set pins(ac_leveling_pins) [ join ${ac_leveling_pins} ]
`endif	

`ifdef IPTCL_NIOS_SEQUENCER
	set pins(afi_ck_pins) ${instname}|s0|*sequencer_rw_mgr_inst|rw_mgr_inst|rw_mgr_core_inst|afi_rdata_valid_r
`else
	set pins(afi_ck_pins) ${instname}|p0|umemphy|uread_datapath|afi_rdata_valid[0]
`endif
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pins(afi_half_ck_pins) ${instname}|p0|umemphy|afi_half_clk_reg
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set prefix [string map "| |*:" $instname]
	set pins(avl_ck_pins) *:${prefix}|*:s0|*:sequencer_rw_mgr_inst|*:rw_mgr_inst|cmd_done_avl
	set pins(config_ck_pins) ${instname}|s0|sequencer_scc_mgr_inst|scc_upd[0]
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pins(p2c_read_ck_pins) ${instname}|p0|umemphy|uread_datapath|read_buffering[0].uread_read_fifo_hard|dataout[0]
	`ifdef IPTCL_FULL_RATE
	set pins(c2p_write_ck_pins) UNDEFINED_NODE_FOR_FR
	`else
	set pins(c2p_write_ck_pins) ${instname}|p0|umemphy|uio_pads|dq_ddio[0].uwrite|altdq_dqs2_inst|output_path_gen[0].hr_to_fr_hi~DFFHI0
	`endif
`endif


	set pll_afi_clock "_UNDEFINED_PIN_"
	set pll_k_clock "_UNDEFINED_PIN_"
	set pll_d_clock "_UNDEFINED_PIN_"
	set pll_ac_clock "_UNDEFINED_PIN_"
	set pll_ref_clock "_UNDEFINED_PIN_"
	set pll_ref_clock_input_buffer "_UNDEFINED_PIN_"
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock "_UNDEFINED_PIN_"
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock "_UNDEFINED_PIN_"
	set pll_config_clock "_UNDEFINED_PIN_"
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pll_p2c_read_clock "_UNDEFINED_PIN_"
	set pll_c2p_write_clock "_UNDEFINED_PIN_"	
`endif

	set pll_afi_clock_id [memphy_get_output_clock_id $pins(afi_ck_pins) "AFI CK" msg_list]
	if {$pll_afi_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "rldram.sdc: $msg"
		}
		post_message -type critical_warning "rldram.sdc: Failed to find PLL clock for pins [join $pins(afi_ck_pins)]"
	} else {
		set pll_afi_clock [memphy_get_pll_clock_name $pll_afi_clock_id]
	}
	set pins(pll_afi_clock) $pll_afi_clock

	set pll_k_clock_id [memphy_get_output_clock_id $pins(k_pins) "K Output" msg_list 20]
	if {$pll_k_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy.sdc: $msg"
		}
		post_message -type critical_warning "memphy.sdc: Failed to find PLL clock for pins [join $pins(k_pins)]"
	} else {
		set pll_k_clock [memphy_get_pll_clock_name $pll_k_clock_id]
	}
	set pins(pll_k_clock) $pll_k_clock

	set pll_d_clock_id [memphy_get_output_clock_id [ join [ join $pins(d_groups) ]] "Data output clock" msg_list]
	if {$pll_d_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy.sdc: $msg"
		}
		post_message -type critical_warning "memphy.sdc: Failed to find PLL clock for pins [ join [ join $pins(d_groups) ]]"
	} else {
		set pll_d_clock [memphy_get_pll_clock_name $pll_d_clock_id]
	}
	set pins(pll_d_clock) $pll_d_clock

	set pll_ac_clock_id [memphy_get_output_clock_id $pins(add_pins) "Address/Command Output" msg_list]
	if {$pll_ac_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy.sdc: $msg"
		}
		post_message -type critical_warning "memphy.sdc: Failed to find PLL clock for pins [join $pins(add_pins)]"
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

	set pll_ref_clock_id [memphy_get_input_clk_id $pll_ac_clock_id]
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

	set entity_names_on [ memphy_are_entity_names_on ]

	set prefix [ string map "| |*:" $instname ]
	set prefix "*:$prefix"

	#####################
	# READ CAPTURE DDIO #
	#####################
	set read_capture_ddio_prefix [expr { $entity_names_on ? \
		"$prefix|*:p0|*:umemphy|*:uio_pads|*:read_capture[*].uread|*:altdq_dqs2_inst|" : \
		"$instname|p0|umemphy|uio_pads|read_capture[*].uread|altdq_dqs2_inst|" }]

	set read_capture_ddio "${read_capture_ddio_prefix}input_path_gen[*].capture_reg*"
		set read_capture_ddio_capture [list	"${read_capture_ddio_prefix}input_path_gen[*].capture_reg~HIGH_DFF" \
										"${read_capture_ddio_prefix}input_path_gen[*].capture_reg~FF" ]
	set pins(read_capture_ddio) $read_capture_ddio
	set pins(read_capture_ddio_capture) $read_capture_ddio_capture	

	###################
	# RESET REGISTERS #
	###################

	# the output of this flop feeds the asynchronous clear pin of the reset registers and should be false pathed
	# since the deassertion of the reset is synchronous with the use of a reset pipeline
	# normal timing analysis will take care that 
	#MarkW: does this work for both sequencers?
	set reset_reg ${prefix}|*:s0|*:sequencer_inst|seq_reset_mem_stable
	if { ! $entity_names_on } {
		set reset_reg ${instname}|s0|sequencer_inst|seq_reset_mem_stable
	}
	set pins(reset_reg) $reset_reg

	# first flop of a synchronzier
	# sequencer issues multiple resets during calibration, reset is synced over from AFI to read capture clock domain
	set sync_reg $prefix|*:p0|*:umemphy|*:uread_datapath|read_buffering[*].seq_read_fifo_reset_sync[*]
	if { ! $entity_names_on } {
		set sync_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].seq_read_fifo_reset_sync[*]
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
	
    set valid_fifo_rdaddress_reg $prefix|*:p0|*:umemphy|*:uread_datapath|read_valid_predict[*].qvld_rd_address[*]
    if { ! $entity_names_on } {
        set valid_fifo_rdaddress_reg $instname|p0|umemphy|uread_datapath|read_valid_predict[*].qvld_rd_address[*]
    }
    set pins(valid_fifo_rdaddress_reg) $valid_fifo_rdaddress_reg	
}

proc memphy_verify_pins { allpins } {
	set pins [ array get allpins ]
}

proc memphy_initialize_ddr_db { ddr_db_par } {
	upvar $ddr_db_par local_ddr_db

	global ::GLOBAL_corename

	post_sdc_message info "Initializing DDR database for CORE $::GLOBAL_corename"
	set instance_list [memphy_get_core_instance_list $::GLOBAL_corename]

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

	# Verify D groups
	set current_d_group_size -1
	foreach d_group $pins(d_groups) {
		set group_size [ llength $d_group ]
		if { $group_size == 0 } {
			post_message -type critical_warning "D group of size 0"
		}
		if { $current_d_group_size == -1 } {
			set current_d_group_size $group_size
		} else {
			if { $current_d_group_size != $group_size } {
				post_message -type critical_warning "Inconsistent Q group size across groups"
			}
		}
	}

	# Verify BWS groups
	set current_bws_group_size -1
	foreach bws_group $pins(bws_groups) {
		set group_size [ llength $bws_group ]
		if { $group_size == 0 } {
			post_message -type critical_warning "BWS group of size 0"
		}
		if { $current_bws_group_size == -1 } {
			set current_bws_group_size $group_size
		} else {
			if { $current_bws_group_size != $group_size } {
				post_message -type critical_warning "Inconsistent Q group size across groups"
			}
		}
	}

	# Verify Address/Command pins
	if { [ llength $pins(add_pins) ] == 0 } {
		post_message -type critical_warning "Add pins of size 0"
	}
	if { [ llength $pins(cmd_pins) ] == 0 } {
		post_message -type critical_warning "Cmd pins of size 0"
	}
	if { [ llength $pins(doff_pin) ] == 0 } {
		post_message -type critical_warning "Doff pin of size 0"
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

		foreach { cq_pin } $pins(cq_pins) {
			lappend dqs_pins $cq_pin
		}
		foreach { cq_n_pin } $pins(cq_n_pins) {
			lappend dqs_pins $cq_n_pin
		}
		foreach { k_pin } $pins(k_pins) {
			lappend dqs_pins $k_pin
		}
		foreach { kn_pin } $pins(kn_pins) {
			lappend dqs_pins $kn_pin
		}
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

		puts $FH "# INSTANCE: $instance"
		puts $FH "#"
		puts $FH ""

		puts $FH "CQ: $pins(cq_pins)"
		puts $FH "CQn: $pins(cq_n_pins)"
		puts $FH "Q: $pins(q_groups)"

		puts $FH "K: $pins(k_pins)"
		puts $FH "Kn: $pins(kn_pins)"
		puts $FH "D: $pins(d_groups)"
		puts $FH "BWS: $pins(bws_groups)"

		puts $FH "ADD: $pins(add_pins)"
		puts $FH "CMD: $pins(cmd_pins)"
		puts $FH "DOFF: $pins(doff_pin)"

		puts $FH "REF CLK: $pins(pll_ref_clock)"
		puts $FH "PLL AFI: $pins(pll_afi_clock)"
		puts $FH "PLL K: $pins(pll_k_clock)"
		puts $FH "PLL D: $pins(pll_d_clock)"
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
			puts $FH "DQS_IN_CLOCK DIV_NAME ($i): $dqs_in_clock(div_name)"
			puts $FH "DQS_IN_CLOCK DIV_PIN ($i): $dqs_in_clock(div_pin)"
			incr i
		}
		
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
		puts $FH "D LEVELING PINS: $pins(d_leveling_pins)"
		puts $FH "K LEVELING PINS: $pins(k_leveling_pins)"
		puts $FH "AC LEVELING PINS: $pins(ac_leveling_pins)"
`endif
		puts $FH "READ CAPTURE DDIO: $pins(read_capture_ddio)"
		puts $FH "RESET REGISTERS: $pins(reset_reg)"
		puts $FH "SYNCHRONIZERS: $pins(sync_reg)"
		puts $FH "SYNCHRONIZATION FIFO WRITE REGISTERS: $pins(fifo_wrdata_reg)"
		puts $FH "SYNCHRONIZATION FIFO READ REGISTERS: $pins(fifo_rddata_reg)"
		puts $FH "VALID PREDICTION FIFO WRITE REGISTERS: $pins(valid_fifo_wrdata_reg)"
		puts $FH "VALID PREDICTION FIFO READ REGISTERS: $pins(valid_fifo_rddata_reg)"
		puts $FH "VALID PREDICTION FIFO READ ADDRESS REGISTERS: $pins(valid_fifo_rdaddress_reg)"

		puts $FH "HEADS: $pins(d_group_heads)"
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

		memphy_static_map_expand_list $FH pins cq_pins
		memphy_static_map_expand_list $FH pins cq_n_pins

		memphy_static_map_expand_list_of_list $FH pins q_groups

		puts $FH ""
		puts $FH "set pins(all_q_pins) \[ join \[ join \$pins(q_groups) \] \]"

		memphy_static_map_expand_list $FH pins k_pins
		memphy_static_map_expand_list $FH pins kn_pins

		memphy_static_map_expand_list_of_list $FH pins d_groups

		puts $FH ""
		puts $FH "set pins(all_d_pins) \[ join \[ join \$pins(d_groups) \] \]"

		memphy_static_map_expand_list_of_list $FH pins bws_groups

		puts $FH ""
		puts $FH "set pins(all_bws_pins) \[ join \[ join \$pins(bws_groups) \] \]"
		puts $FH "set pins(all_q_bws_pins) \[ concat \$pins(all_q_pins) \$pins(all_bws_pins) \]"


		memphy_static_map_expand_list $FH pins add_pins
		memphy_static_map_expand_list $FH pins cmd_pins
		memphy_static_map_expand_list $FH pins doff_pin

		puts $FH ""
		puts $FH "set pins(ac_pins) \[ concat \$pins(add_pins) \$pins(cmd_pins) \$pins(doff_pin) \]"

		memphy_static_map_expand_string $FH pins pll_ref_clock
		memphy_static_map_expand_string $FH pins pll_afi_clock
		memphy_static_map_expand_string $FH pins pll_k_clock
		memphy_static_map_expand_string $FH pins pll_d_clock
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
			puts $FH "   set dqs_in_clock(div_name) $dqs_in_clock(div_name)"
			puts $FH "   set dqs_in_clock(div_pin) $dqs_in_clock(div_pin)"
			puts $FH "   lappend dqs_in_clocks \[ array get dqs_in_clock \]"
			incr i
		}
		puts $FH "   set pins(dqs_in_clocks) \$dqs_in_clocks"

		memphy_static_map_expand_string $FH pins read_capture_ddio
		memphy_static_map_expand_string $FH pins reset_reg
		memphy_static_map_expand_string $FH pins sync_reg
		memphy_static_map_expand_string $FH pins fifo_wrdata_reg
		memphy_static_map_expand_string $FH pins fifo_rddata_reg
		memphy_static_map_expand_string $FH pins valid_fifo_wrdata_reg
		memphy_static_map_expand_string $FH pins valid_fifo_rddata_reg
		memphy_static_map_expand_string $FH pins valid_fifo_rdaddress_reg

		memphy_static_map_expand_list $FH pins d_group_heads

		puts $FH ""
		puts $FH "   set local_ddr_db($instname) \[ array get pins \]"
	}

	puts $FH "}"

	close $FH
}
