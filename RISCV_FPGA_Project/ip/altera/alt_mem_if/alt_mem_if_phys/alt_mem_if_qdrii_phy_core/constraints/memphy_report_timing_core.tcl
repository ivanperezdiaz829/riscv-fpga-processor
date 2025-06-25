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


#############################################################
# Write Timing Analysis
#############################################################
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
proc memphy_perform_flexible_write_launch_timing_analysis {opcs opcname inst family DQS_min_max interface_type max_package_skew dll_length period pin_array_name timing_parameters_array_name summary_name MP_name IP_name board_name} {

	###############################################################################
	# This timing analysis covers the write timing constraints.  It includes support 
	# for uncalibrated and calibrated write paths.  The analysis starts by running a 
	# conventional timing analysis for the write paths and then adds support for 
	# topologies and IP options which are unique to source-synchronous data transfers.  
	# The support for further topologies includes common clock paths in DDR3 as well as 
	# correlation between D and K.  The support for further IP includes support for 
	# write-deskew calibration.
	# 
	# During write deskew calibration, the IP will adjust delay chain settings along 
	# each signal path to reduce the skew between D pins and to centre align the K 
	# clock within the DVW.  This operation has the benefit of increasing margin on the 
	# setup and hold, as well as removing some of the unknown process variation on each 
	# signal path.  This timing analysis emulates the IP process by deskewing each pin as 
	# well as accounting for the elimination of the unknown process variation.  Once the 
	# deskew emulation is complete, the analysis further considers the effect of changing 
	# the delay chain settings to the operation of the device after calibration: these 
	# effects include changes in voltage and temperature which may affect the optimality 
	# of the deskew process.
	# 
	# The timing analysis creates a write summary report indicating how the timing analysis 
	# was performed starting with a typical timing analysis before calibration.
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $pin_array_name pins
	upvar 1 $MP_name MP
	upvar 1 $IP_name IP
	upvar 1 $board_name board

	set num_failing_path $IP(num_report_paths)

	set debug 0
	set result 1
	
	#################################
	# Find the clock output of the PLL
	set k_pll_clock_id [memphy_get_output_clock_id $pins(k_pins) "DQS output" msg_list]
	if {$k_pll_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "$msg"
		}
		post_message -type warning "Failed to find PLL clock for pins [join [get_all_dqs_pins $pins(q_groups)]]"
		set result 0
	} else {
		set kclksource [get_node_info -name $k_pll_clock_id]
	}


	
	if {$IP(write_deskew_mode) == "dynamic"} {
		set panel_name_setup  "Before Calibration \u0028Negative slacks are OK\u0029||$inst Write \u0028Before Calibration\u0029 (setup)"
		set panel_name_hold   "Before Calibration \u0028Negative slacks are OK\u0029||$inst Write \u0028Before Calibration\u0029 (hold)"
	} else {
		set panel_name_setup  "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Write (setup)"
		set panel_name_hold   "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Write (hold)"
	}	
	
	#####################################################################
	# Default Write Analysis
	set before_calibration_reporting [get_ini_var -name "qsta_enable_before_calibration_ddr_reporting"]
	if {![string equal -nocase $before_calibration_reporting off]}  {
		set res_0 [report_timing -detail full_path -to [get_ports $pins(all_d_bws_pins)] \
			-npaths $num_failing_path -panel_name $panel_name_setup -setup -disable_panel_color -quiet]
		set res_1 [report_timing -detail full_path -to [get_ports $pins(all_d_bws_pins)] \
			-npaths $num_failing_path -panel_name $panel_name_hold -hold -disable_panel_color -quiet]
	}

	# Perform the default timing analysis to get required and arrival times
	set paths_setup [get_timing_paths -to [get_ports $pins(all_d_bws_pins)] -npaths 400 -setup]
	set paths_hold  [get_timing_paths -to [get_ports $pins(all_d_bws_pins)] -npaths 400 -hold]

	#####################################
	# Find Memory Calibration Improvement 
	#####################################
	
	set mp_setup_slack 0
	set mp_hold_slack  0
	if {($IP(write_deskew_mode) == "dynamic") && ($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		# Reduce the effect of tDS on the setup slack
		set mp_setup_slack [expr $MP(SD)*$t(SD)]
		
		# Reduce the effect of tDH on the hold slack
		set mp_hold_slack  [expr $MP(HD)*$t(HD)]
	}

	set pll_ccpp 0

	########################################
	# Go over each pin and compute its slack
	# Then include any effects that are unique
	# to source synchronous designs including
	# common clocks, signal correlation, and
	# IP calibration options to compute the
	# total slack of the instance
	
	set setup_slack 1000000000
	set hold_slack  1000000000
	set default_setup_slack 1000000000
	set default_hold_slack  1000000000	

	set max_write_deskew_setup [expr $IP(write_deskew_range_setup)*$IP(quantization_T9)]
	set max_write_deskew_hold  [expr $IP(write_deskew_range_hold)*$IP(quantization_T9)]
		
	if {($result == 1)} {

		set group_number_base -1
		#Go over each D pin
		foreach dpins $pins(d_groups) {
			
			set group_number_base [expr $group_number_base + 1]		
`ifdef IPTCL_EMULATED_MODE
			if {[llength [lindex $pins(d_groups) 0]] == 9} {
				set group_number [expr $group_number_base/4]
			} else {
				set group_number [expr $group_number_base/2]
			}
`else
			set group_number $group_number_base
`endif
			
			set kpin [lindex $pins(k_pins) $group_number]
			set knpin [lindex $pins(kn_pins) $group_number]
			
			#############################################
			# Find extra K pessimism due to correlation
			#############################################
			
			# Find paths from K clock periphery node to beginning of output buffer
			set dqs_periphery_node ${inst}|p0|umemphy|uio_pads|dq_ddio[${group_number}].uwrite|altdq_dqs2_inst|phase_align_os|muxsel
			set output_buffer_node ${inst}|p0|umemphy|uio_pads|dq_ddio[${group_number}].uwrite|altdq_dqs2_inst|obuf_os_0|i
			
			set DQSperiphery_min [get_path -from $dqs_periphery_node -to $kpin -min_path -nworst 100]
			set DQSperiphery_delay [memphy_min_in_collection $DQSperiphery_min "arrival_time"]
			set aiot_delay [memphy_round_3dp [expr [memphy_get_min_aiot_delay $kpin] * 1e9]]
			set DQSperiphery_delay [expr $DQSperiphery_delay - $aiot_delay]
			set DQSpath_pessimism [expr $DQSperiphery_delay*$DQS_min_max]
			
			# Go over each D pin in group
			set d_index 0
			
			foreach dpin $dpins {
				regexp {\d+} $dpin d_pin_index
			
				# Perform the default timing analysis to get required and arrival times
				set pin_setup_slack [memphy_min_in_collection_to_name $paths_setup "slack" $dpin]
				set pin_hold_slack  [memphy_min_in_collection_to_name $paths_hold "slack" $dpin]

				set default_setup_slack [min $default_setup_slack $pin_setup_slack]
				set default_hold_slack  [min $default_hold_slack  $pin_hold_slack]		

				if { $debug } {
					puts "$group_number $kpin $dpin $pin_setup_slack $pin_hold_slack"
				}

				set extra_ccpp 0

				########################################
				# Add the memory calibration improvement
				########################################
				
				set pin_setup_slack [expr $pin_setup_slack + $mp_setup_slack]
				set pin_hold_slack [expr $pin_hold_slack + $mp_hold_slack]
		
				############################################
				# Find extra D pessimism due to correlation
				############################################
				
				# Find the DQ clock node before the periphery
				set dq_periphery_node ${inst}|p0|umemphy|uio_pads|dq_ddio[${group_number}].uwrite|altdq_dqs2_inst|output_path_gen[${d_index}].ddio_out|muxsel
				set output_buffer_node_dq ${inst}|p0|umemphy|uio_pads|dq_ddio[${group_number}].uwrite|altdq_dqs2_inst|pad_gen[${d_index}].data_out|i
				
				set DQperiphery_min [get_path -from $dq_periphery_node -to $dpin -min_path -nworst 100]
				set DQperiphery_delay [memphy_min_in_collection $DQperiphery_min "arrival_time"]
				set aiot_delay [memphy_round_3dp [expr [memphy_get_min_aiot_delay $dpin] * 1e9]]
				set DQperiphery_delay [expr $DQperiphery_delay - $aiot_delay]
				set DQpath_pessimism [expr $DQperiphery_delay*$DQS_min_max]
				
				########################################
				# Merge current slacks with other slacks
				########################################

				# If write deskew is available, the setup and hold slacks for this pin will be equal
				#   and can also remove the extra DQS and DQ pessimism removal
				if {$IP(write_deskew_mode) == "dynamic"} {
				
					# Consider the maximum range of the deskew when deskewing
					set shift_setup_slack [expr ($pin_setup_slack + $pin_hold_slack)/2 - $pin_setup_slack]
					if {$shift_setup_slack >= $max_write_deskew_setup} {
						if { $debug } {
							puts "limited setup"
						}
						set pin_setup_slack [expr $pin_setup_slack + $max_write_deskew_setup]
						set pin_hold_slack [expr $pin_hold_slack - $max_write_deskew_setup]

						# Remember the largest shifts in either direction
						if {[info exist max_shift]} {
							if {$max_write_deskew_setup > $max_shift} {
								set max_shift $max_write_deskew_setup
							}
							if {$max_write_deskew_setup < $min_shift} {
								set min_shift $max_write_deskew_setup
							}
						} else {
							set max_shift $max_write_deskew_setup
							set min_shift $max_shift
						}

					} elseif {$shift_setup_slack <= -$max_write_deskew_hold} {
						if { $debug } {
							puts "limited hold"
						}
						set pin_setup_slack [expr $pin_setup_slack - $max_write_deskew_hold]
						set pin_hold_slack [expr $pin_hold_slack + $max_write_deskew_hold]

						# Remember the largest shifts in either direction
						if {[info exist max_shift]} {
							if {[expr 0 -$max_write_deskew_hold] > $max_shift} {
								set max_shift [expr 0 - $max_write_deskew_hold]
							}
							if {[expr 0 -$max_write_deskew_hold] < $min_shift} {
								set min_shift [expr 0 - $max_write_deskew_hold]
							}
						} else {
							set max_shift [expr 0 - $max_write_deskew_hold]
							set min_shift $max_shift
						}
					} else {
						# In this case we can also consider the DQS/DQpath pessimism since we can guarantee we have enough delay chain settings to align it
						set pin_setup_slack [expr $pin_setup_slack + $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
						set pin_hold_slack [expr $pin_hold_slack - $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]

						# Remember the largest shifts in either direction
						if {[info exist max_shift]} {
							if {[expr $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2] > $max_shift} {
								set max_shift [expr $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
							}
							if {[expr $shift_setup_slack - $DQSpath_pessimism/2 - $DQpath_pessimism/2] < $min_shift} {
								set min_shift [expr $shift_setup_slack - $DQSpath_pessimism/2 - $DQpath_pessimism/2]
							}
						} else {
							set max_shift [expr $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
							set min_shift [expr $shift_setup_slack - $DQSpath_pessimism/2 - $DQpath_pessimism/2]
						}
					}
				} else {
					# For uncalibrated calls, there is some spatial correlation between DQ and DQS signals, so remove
					# some of the pessimism
					set total_DQ_DQS_pessimism [expr $DQSpath_pessimism + $DQpath_pessimism]
					set dqs_width [llength $dpins]
					if {$dqs_width <= 9} {
						set pin_setup_slack [expr $pin_setup_slack + 0.35*$total_DQ_DQS_pessimism]
						set pin_hold_slack  [expr $pin_hold_slack  + 0.35*$total_DQ_DQS_pessimism]
					} else {
						set pin_setup_slack [expr $pin_setup_slack + 0.12*$total_DQ_DQS_pessimism]
						set pin_hold_slack  [expr $pin_hold_slack  + 0.12*$total_DQ_DQS_pessimism]
					}
				} 
				

				set setup_slack [min $setup_slack $pin_setup_slack]
				set hold_slack  [min $hold_slack $pin_hold_slack]
				
				if { $debug } {
					puts "                                $extra_ccpp $DQSpath_pessimism $DQpath_pessimism ($pin_setup_slack $pin_hold_slack $setup_slack $hold_slack)" 
				}

				set d_index [expr $d_index + 1]

			}
		}
	}

	###############################
	# Consider some post calibration effects on calibration
	#  and output the write summary report
	###############################
	set positive_fcolour [list "black" "blue" "blue"]
	set negative_fcolour [list "black" "red"  "red"]	
	
	set wr_summary [list]
	
	if {$IP(write_deskew_mode) == "dynamic"} {
		lappend wr_summary [list "  Before Calibration Write" [memphy_format_3dp $default_setup_slack] [memphy_format_3dp $default_hold_slack]]
	} else {
		lappend wr_summary [list "  Standard Write" [memphy_format_3dp $default_setup_slack] [memphy_format_3dp $default_hold_slack]]
	}
	
	if {($IP(write_deskew_mode) == "dynamic") && ($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		lappend wr_summary [list "  Memory Calibration" [memphy_format_3dp $mp_setup_slack] [memphy_format_3dp $mp_hold_slack]]
	}		
	
	if {$IP(write_deskew_mode) == "dynamic"} {
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		
		#######################################
		# Find values for uncertainty table
		set t(wru_fpga_deskew_s) [expr $setup_slack - $default_setup_slack - $extra_ccpp - $mp_setup_slack]
		set t(wru_fpga_deskew_h) [expr $hold_slack  - $default_hold_slack  - $extra_ccpp - $mp_setup_slack]
		#######################################

		# Remove external delays (add slack) that are fixed by the dynamic deskew
		if { $IP(discrete_device) == 1 } {
			set t(WL_PSE) 0
		}
		[catch {get_float_table_node_delay -src {DELAYCHAIN_T9} -dst {VTVARIATION} -parameters [list IO $interface_type]} t9_vt_variation_percent]
		set extra_shift [expr $board(intra_K_group_skew) + [memphy_round_3dp [expr (1.0-$t9_vt_variation_percent)*$t(WL_PSE)]]]
		
		if {$extra_shift > [expr $max_write_deskew_setup - $max_shift]} {
			set setup_slack [expr $setup_slack + $max_write_deskew_setup - $max_shift]
		} else {
			set setup_slack [expr $setup_slack + $extra_shift]
		}
		if {$extra_shift > [expr $max_write_deskew_hold + $min_shift]} {
			set hold_slack [expr $hold_slack + $max_write_deskew_hold + $min_shift]
		} else {
			set hold_slack [expr $hold_slack + $extra_shift]
		}	

		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		set deskew_setup [expr $setup_slack - $default_setup_slack -$mp_setup_slack]
		set deskew_hold  [expr $hold_slack - $default_hold_slack - $mp_hold_slack]
		lappend wr_summary [list "  Deskew Write and/or more clock pessimism removal" [memphy_format_3dp $deskew_setup] [memphy_format_3dp $deskew_hold]]
		
		#######################################
		# Find values for uncertainty table
		set t(wru_external_deskew_s) [expr $deskew_setup - $t(wru_fpga_deskew_s) + $mp_setup_slack - $extra_ccpp]
		set t(wru_external_deskew_h) [expr $deskew_hold  - $t(wru_fpga_deskew_h) + $mp_hold_slack  - $extra_ccpp]
		#######################################

		# Consider errors in the dynamic deskew
		set t9_quantization $IP(quantization_T9)
		set setup_slack [expr $setup_slack - $t9_quantization]
		set hold_slack  [expr $hold_slack - $t9_quantization]
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend wr_summary [list "  Quantization error" [memphy_format_3dp [expr 0-$t9_quantization]] [memphy_format_3dp [expr 0-$t9_quantization]]]
		
		# Consider variation in the delay chains used during dynamic deksew
		set offset_from_90 0
`ifdef IPTCL_STRATIXIV
		set t9_variation [expr [min [expr $offset_from_90 + (2*$board(intra_K_group_skew) + $max_package_skew + $t(WL_PSE))] [max $max_write_deskew_setup $max_write_deskew_hold]]*2*$t9_vt_variation_percent]
`else
`ifdef IPTCL_ARRIAIIGX
		set t9_variation [expr [min [expr $offset_from_90 + (2*$board(intra_K_group_skew) + $max_package_skew + $t(WL_PSE))] [max $max_write_deskew_setup $max_write_deskew_hold]]*2*$t9_vt_variation_percent]
`else
`ifdef IPTCL_ARRIAIIGZ
		set t9_variation [expr [min [expr $offset_from_90 + (2*$board(intra_K_group_skew) + $max_package_skew + $t(WL_PSE))] [max $max_write_deskew_setup $max_write_deskew_hold]]*2*$t9_vt_variation_percent]
`else
		if {$IP(num_ranks) == 1} {
			set t9_variation [expr [min [expr $offset_from_90 + [max [expr $MP(SD)*$t(SD)] [expr $MP(HD)*$t(HD)]] + (2*$board(intra_K_group_skew) + $max_package_skew + $t(WL_PSE))] [max $max_write_deskew_setup $max_write_deskew_hold]]*2*$t9_vt_variation_percent]
		} else {
			set t9_variation [expr [min [expr $offset_from_90 + (2*$board(intra_K_group_skew) + $max_package_skew + $t(WL_PSE))] [max $max_write_deskew_setup $max_write_deskew_hold]]*2*$t9_vt_variation_percent]
		}
`endif
`endif
`endif
		set setup_slack [expr $setup_slack - $t9_variation]
		set hold_slack  [expr $hold_slack - $t9_variation]	
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend wr_summary [list "  Calibration uncertainty" [memphy_format_3dp [expr 0-$t9_variation]] [memphy_format_3dp [expr 0-$t9_variation]]] 
		
		#######################################
		# Find values for uncertainty table
		set uncertainty_reporting [get_ini_var -name "qsta_enable_uncertainty_ddr_reporting"]
		if {[string equal -nocase $uncertainty_reporting on]} {
			set t(wru_calibration_uncertaintyerror_s) [expr 0 - $t9_variation - $t9_quantization]
			set t(wru_calibration_uncertaintyerror_h) [expr 0 - $t9_variation - $t9_quantization]
			set t(wru_fpga_uncertainty_s) [expr $t(CYC)/4 - $default_setup_slack - $t(wru_output_max_delay_external) - $extra_ccpp]
			set t(wru_fpga_uncertainty_h) [expr $t(CYC)/4 - $default_hold_slack  - $t(wru_output_min_delay_external) - $extra_ccpp]
			set t(wru_extl_uncertainty_s) [expr $t(wru_output_max_delay_external)]
			set t(wru_extl_uncertainty_h) [expr $t(wru_output_min_delay_external)]		
		}
		#######################################
		
	} else {
		set pessimism_setup [expr $setup_slack - $default_setup_slack - $mp_setup_slack]
		set pessimism_hold  [expr $hold_slack - $default_hold_slack - $mp_hold_slack]
		lappend wr_summary [list "  Spatial correlation pessimism removal" [memphy_format_3dp $pessimism_setup] [memphy_format_3dp $pessimism_hold]]

		#######################################
		# Find values for uncertainty table
		set uncertainty_reporting [get_ini_var -name "qsta_enable_uncertainty_ddr_reporting"]
		if {[string equal -nocase $uncertainty_reporting on]} {		
			set t(wru_fpga_deskew_s) 0
			set t(wru_fpga_deskew_h) 0
			set t(wru_external_deskew_s) 0
			set t(wru_external_deskew_h) 0
			set t(wru_calibration_uncertaintyerror_s) 0
			set t(wru_calibration_uncertaintyerror_h) 0
			set t(wru_fpga_uncertainty_s) [expr $t(CYC)/4 - $default_setup_slack - $t(wru_output_max_delay_external) - $pessimism_setup]
			set t(wru_fpga_uncertainty_h) [expr $t(CYC)/4 - $default_hold_slack  - $t(wru_output_min_delay_external) - $pessimism_hold]
			set t(wru_extl_uncertainty_s) [expr $t(wru_output_max_delay_external)]
			set t(wru_extl_uncertainty_h) [expr $t(wru_output_min_delay_external)]				
		}
		#######################################
	}	
	
	###############################
	# Consider Duty Cycle Calibration if enabled
	###############################

	if {($IP(write_dcc) == "dynamic")} {
		#First remove the Systematic DCD
		set setup_slack [expr $setup_slack + $t(WL_DCD)]
		set hold_slack  [expr $hold_slack + $t(WL_DCD)]
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend wr_summary [list "  Duty cycle correction" $t(WL_DCD) $t(WL_DCD)]
		
		#Add errors in the DCC
		set DCC_quantization $IP(quantization_DCC)
		set setup_slack [expr $setup_slack - $DCC_quantization]
		set hold_slack  [expr $hold_slack - $DCC_quantization]
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend wr_summary [list "  Duty cycle correction quantization error" [memphy_format_3dp [expr 0-$DCC_quantization]] [memphy_format_3dp [expr 0-$DCC_quantization]]]
		
		# Consider variation in the DCC 
		[catch {get_float_table_node_delay -src {DELAYCHAIN_DUTY_CYCLE} -dst {VTVARIATION} -parameters [list IO $interface_type]} dcc_vt_variation_percent]
		set dcc_variation [expr $t(WL_DCD)*2*$dcc_vt_variation_percent]
		set setup_slack [expr $setup_slack - $dcc_variation]
		set hold_slack  [expr $hold_slack - $dcc_variation]		
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend wr_summary [list "  Duty cycle correction calibration uncertainity" [memphy_format_3dp [expr 0-$dcc_variation]] [memphy_format_3dp [expr 0-$dcc_variation]]]
	}
	
	#######################################
	#######################################
	# Create the write analysis panel	
	set panel_name "$inst Write"
	set root_folder_name [get_current_timequest_report_folder]

	if { ! [string match "${root_folder_name}*" $panel_name] } {
		set panel_name "${root_folder_name}||$panel_name"
	}
	# Create the root if it doesn't yet exist
	if {[get_report_panel_id $root_folder_name] == -1} {
		set panel_id [create_report_panel -folder $root_folder_name]
	}

	# Delete any pre-existing summary panel
	set panel_id [get_report_panel_id $panel_name]
	if {$panel_id != -1} {
		delete_report_panel -id $panel_id
	}
	
	if {($setup_slack < 0) || ($hold_slack <0)} {
		set panel_id [create_report_panel -table $panel_name -color red]
	} else {
		set panel_id [create_report_panel -table $panel_name]
	}
	add_row_to_table -id $panel_id [list "Operation" "Setup Slack" "Hold Slack"] 		
	
	if {($IP(write_deskew_mode) == "dynamic")} {
		set fcolour [memphy_get_colours $setup_slack $hold_slack]
		add_row_to_table -id $panel_id [list "After Calibration Write" [memphy_format_3dp $setup_slack] [memphy_format_3dp $hold_slack]] -fcolor $fcolour
		lappend summary [list $opcname 0 "Write ($opcname)" $setup_slack $hold_slack]
	} else {
		set fcolour [memphy_get_colours $setup_slack $hold_slack] 
		add_row_to_table -id $panel_id [list "Write" [memphy_format_3dp $setup_slack] [memphy_format_3dp $hold_slack]] -fcolor $fcolour
		lappend summary [list $opcname 0 "Write ($opcname)" [memphy_format_3dp $setup_slack] [memphy_format_3dp $hold_slack]]
	}

	foreach summary_line $wr_summary {
		add_row_to_table -id $panel_id $summary_line -fcolors $positive_fcolour
	}
	
	#######################################
	# Create the Write uncertainty panel
	set uncertainty_reporting [get_ini_var -name "qsta_enable_uncertainty_ddr_reporting"]
	if {[string equal -nocase $uncertainty_reporting on]} {
		set panel_name "$inst Write Uncertainty"
		set root_folder_name [get_current_timequest_report_folder]

		if { ! [string match "${root_folder_name}*" $panel_name] } {
			set panel_name "${root_folder_name}||$panel_name"
		}

		# Delete any pre-existing summary panel
		set panel_id [get_report_panel_id $panel_name]
		if {$panel_id != -1} {
			delete_report_panel -id $panel_id
		}
		
		set panel_id [create_report_panel -table $panel_name]
		add_row_to_table -id $panel_id [list "Value" "Setup Side" "Hold Side"]
		add_row_to_table -id $panel_id [list "Uncertainty" "" ""]
		add_row_to_table -id $panel_id [list "  FPGA uncertainty" [memphy_format_3dp $t(wru_fpga_uncertainty_s)] [memphy_format_3dp $t(wru_fpga_uncertainty_h)]] 
		add_row_to_table -id $panel_id [list "  External uncertainty" [memphy_format_3dp $t(wru_extl_uncertainty_s)] [memphy_format_3dp $t(wru_extl_uncertainty_h)]] 
		add_row_to_table -id $panel_id [list "Deskew" "" ""]
		add_row_to_table -id $panel_id [list "  FPGA deskew" [memphy_format_3dp $t(wru_fpga_deskew_s)] [memphy_format_3dp $t(wru_fpga_deskew_h)]] 
		add_row_to_table -id $panel_id [list "  External deskew" [memphy_format_3dp $t(wru_external_deskew_s)] [memphy_format_3dp $t(wru_external_deskew_h)]] 
		add_row_to_table -id $panel_id [list "  Calibration uncertainty/error" [memphy_format_3dp $t(wru_calibration_uncertaintyerror_s)] [memphy_format_3dp $t(wru_calibration_uncertaintyerror_h)]] 
	}		
}
`endif

`ifdef IPTCL_PRINT_MACRO_TIMING
proc memphy_perform_macro_write_launch_timing_analysis {opcs opcname inst pin_array_name timing_parameters_array_name summary_name IP_name ISI_name board_name} {

	###############################################################################
	# This timing analysis covers the write timing constraints using the Altera 
	# characterized values.  Altera performs characterization on its devices and IP 
	# to determine all the FPGA uncertainties, and uses these values to provide accurate 
	# timing analysis.  
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $IP_name IP
	upvar 1 $pin_array_name pins
	upvar 1 $ISI_name ISI
	upvar 1 $board_name board

	set local_pll_afi_clk [memphy_get_clock_name_from_pin_name $pins(pll_afi_clock)]
	set local_pll_write_clk [memphy_get_clock_name_from_pin_name $pins(pll_d_clock)]
	set local_pll_mem_clk [memphy_get_clock_name_from_pin_name $pins(pll_k_clock)]

	# First find the phase offset between DQ and DQS
	set dqs_output_phase [get_clock_info -phase $local_pll_mem_clk]
	set dq_output_phase [get_clock_info -phase $local_pll_write_clk]
	set dq2dqs_output_phase_offset [expr $dqs_output_phase - $dq_output_phase]
	if {$dq2dqs_output_phase_offset < 0} {
		set dq2dqs_output_phase_offset [expr $dq2dqs_output_phase_offset + 360.0]
	}

	set tccs [memphy_get_tccs $IP(mem_if_memtype) $pins(k_pins) $t(CYC)]

	set board_skew $board(intra_K_group_skew)	
	set write_board_skew $board_skew
	if {$IP(write_deskew_mode) == "dynamic"} {
		if {[catch {get_micro_node_delay -micro EXTERNAL_SKEW_THRESHOLD -parameters [list IO]} compensated_skew] != 0 || $compensated_skew == ""} {
		  # No skew compensation
		} else {
		  set compensated_skew [expr $compensated_skew / 1000.0]
		  if {$board_skew > $compensated_skew} {
			set write_board_skew [expr $board_skew - $compensated_skew]
		  } else {
			set write_board_skew 0
		  }
		}
	}

`ifdef IPTCL_EMULATED_MODE
	# Additional TCCS derating due to pseudo x36 mode
	set tccs_x36 [memphy_get_qdr_tccs_derating $pins(k_pins)]
	set su   [memphy_round_3dp [expr {$t(CYC)*$dq2dqs_output_phase_offset/360.0 - $write_board_skew - [lindex $tccs 0]/1000.0 - [lindex $tccs_x36 0]/1000.0- $t(SD)}]]
	set hold [memphy_round_3dp [expr {$t(CYC)*(0.5 - $dq2dqs_output_phase_offset/360.0) - $write_board_skew - [lindex $tccs 1]/1000.0 - [lindex $tccs_x36 1]/1000.0 - $t(HD)}]]
`else
	set su   [memphy_round_3dp [expr {$t(CYC)*$dq2dqs_output_phase_offset/360.0 - $write_board_skew - [lindex $tccs 0]/1000.0 - $t(SD)}]]
	set hold [memphy_round_3dp [expr {$t(CYC)*(0.5 - $dq2dqs_output_phase_offset/360.0) - $write_board_skew - [lindex $tccs 1]/1000.0 - $t(HD)}]]
`endif
	lappend summary [list "All Conditions" 0 "Write (All Conditions)" $su $hold 1 1]

}
`endif

#############################################################
# Read Timing Analysis
#############################################################
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
proc memphy_perform_flexible_read_capture_timing_analysis {opcs opcname inst family DQS_min_max io_std interface_type max_package_skew dqs_phase period all_q_pins pin_array_name timing_parameters_array_name summary_name MP_name IP_name board_name fpga_name} {

	################################################################################
	# This timing analysis covers the read timing constraints.  It includes support 
	# for uncalibrated and calibrated read paths.  The analysis starts by running a 
	# conventional timing analysis for the read paths and then adds support for 
	# topologies and IP options which are unique to source-synchronous data transfers.  
	# The support for further topologies includes correlation between Q and CQ signals
	# The support for further IP includes support for read-deskew calibration.
	# 
	# During read deskew calibration, the IP will adjust delay chain settings along 
	# each signal path to reduce the skew between Q pins and to centre align the CQ 
	# strobe within the DVW.  This operation has the benefit of increasing margin on the 
	# setup and hold, as well as removing some of the unknown process variation on each 
	# signal path.  This timing analysis emulates the IP process by deskewing each pin as 
	# well as accounting for the elimination of the unknown process variation.  Once the 
	# deskew emulation is complete, the analysis further considers the effect of changing 
	# the delay chain settings to the operation of the device after calibration: these 
	# effects include changes in voltage and temperature which may affect the optimality 
	# of the deskew process.
	# 
	# The timing analysis creates a read summary report indicating how the timing analysis 
	# was performed starting with a typical timing analysis before calibration.
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $pin_array_name pins
	upvar 1 $MP_name MP
	upvar 1 $IP_name IP
	upvar 1 $board_name board
	upvar 1 $fpga_name fpga

	set num_failing_path $IP(num_report_paths)

	# Debug switch. Change to 1 to get more run-time debug information
	set debug 0	
	set result 1


	if {$IP(read_deskew_mode) == "dynamic"} {
		set panel_name_setup  "Before Calibration \u0028Negative slacks are OK\u0029||$inst Read Capture CQ \u0028Before Calibration\u0029 (setup)"
		set panel_name_hold   "Before Calibration \u0028Negative slacks are OK\u0029||$inst Read Capture CQ \u0028Before Calibration\u0029 (hold)"
		set panel_name_setup2 "Before Calibration \u0028Negative slacks are OK\u0029||$inst Read Capture CQn \u0028Before Calibration\u0029 (setup)"
		set panel_name_hold2  "Before Calibration \u0028Negative slacks are OK\u0029||$inst Read Capture CQn \u0028Before Calibration\u0029 (hold)"
	} else {
		set panel_name_setup  "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Read Capture CQ (setup)"
		set panel_name_hold   "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Read Capture CQ (hold)"
		set panel_name_setup2 "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Read Capture CQn (setup)"
		set panel_name_hold2  "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Read Capture CQn (hold)"
	}

	#####################################################################
	# Default Read Analysis
	set before_calibration_reporting [get_ini_var -name "qsta_enable_before_calibration_ddr_reporting"]
	if {![string equal -nocase $before_calibration_reporting off]} {
		set res_0 [report_timing -detail full_path -from [get_ports $all_q_pins] \
			-to_clock [get_clocks $pins(cq_pins)] -npaths $num_failing_path -panel_name $panel_name_setup -setup -disable_panel_color -quiet]
		set res_1 [report_timing -detail full_path -from [get_ports $all_q_pins] \
			-to_clock [get_clocks $pins(cq_pins)] -npaths $num_failing_path -panel_name $panel_name_hold -hold -disable_panel_color -quiet]
		
		set res_0 [report_timing -detail full_path -from [get_ports $all_q_pins] \
			-to_clock [get_clocks $pins(cq_n_pins)] -npaths $num_failing_path -panel_name $panel_name_setup2 -setup -disable_panel_color -quiet]
		set res_1 [report_timing -detail full_path -from [get_ports $all_q_pins] \
			-to_clock [get_clocks $pins(cq_n_pins)] -npaths $num_failing_path -panel_name $panel_name_hold2 -hold -disable_panel_color -quiet]

	}	

	set paths_setup [get_timing_paths -from [get_ports $all_q_pins] -to_clock [get_clocks $pins(cq_pins)] -npaths 400 -setup]
	set paths_hold  [get_timing_paths -from [get_ports $all_q_pins] -to_clock [get_clocks $pins(cq_pins)] -npaths 400 -hold]			
	set paths_setup2 [get_timing_paths -from [get_ports $all_q_pins] -to_clock [get_clocks $pins(cq_n_pins)] -npaths 400 -setup]
	set paths_hold2  [get_timing_paths -from [get_ports $all_q_pins] -to_clock [get_clocks $pins(cq_n_pins)] -npaths 400 -hold]	

	#####################################
	# Find Memory Calibration Improvement
	#####################################
	
	set mp_setup_slack 0
	set mp_hold_slack  0
	if {($IP(read_deskew_mode) == "dynamic") && ($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		# Reduce the effect of tCQD on the setup slack
		set mp_setup_slack [expr $MP(CQD)*$t(CQD)]

		# Reduce the effect of tCQDOH on the hold slack
		set mp_hold_slack  [expr -$MP(CQDOH)*$t(CQDOH)]
	}

	########################################
	# Go over each pin and compute its slack
	# Then include any effects that are unique
	# to source synchronous designs including
	# common clocks, signal correlation, and
	# IP calibration options to compute the
	# total slack of the instance	

	set prefix [ string map "| |*:" $inst ]
	set prefix "*:$prefix"	
`ifdef IPTCL_STRATIXV
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set tJITper [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO PHY_SHORT] -period $period]/1000.0]
	set tJITdty [expr [get_micro_node_delay -micro MEM_CK_DC_JITTER -parameters [list IO PHY_SHORT]]/1000.0]
	# DCD value that is looked up is in %, and thus needs to be divided by 100
	set tDCD [expr [get_micro_node_delay -micro MEM_CK_DCD -parameters [list IO PHY_SHORT]]/100.0]
`else
	set tJITper [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO QCLK] -period $period]/1000.0]
	set tJITdty [expr [get_micro_node_delay -micro MEM_CK_DC_JITTER -parameters [list IO QCLK]]/1000.0]
	# DCD value that is looked up is in %, and thus needs to be divided by 100
	set tDCD [expr [get_micro_node_delay -micro MEM_CK_DCD -parameters [list IO QCLK]]/100.0]
`endif
	
	# This is the peak-to-peak jitter on the whole DQ-DQS read capture path
	set DQSpathjitter [expr [get_micro_node_delay -micro DQDQS_JITTER -parameters [list IO] -in_fitter]/1000.0]
	# This is the proportion of the DQ-DQS read capture path jitter that applies to setup (looed up value is in %, and thus needs to be divided by 100)
	set DQSpathjitter_setup_prop [expr [get_micro_node_delay -micro DQDQS_JITTER_DIVISION -parameters [list IO] -in_fitter]/100.0]
`else
	set tJITper [expr [get_io_standard_node_delay -dst MEM_CK_PERIOD_JITTER -io_standard $io_std -parameters [list IO $interface_type] -period $period]/1000.0]
	set tJITdty [expr [get_io_standard_node_delay -dst MEM_CK_DC_JITTER -io_standard $io_std -parameters [list IO $interface_type]]/1000.0]
	# DCD value that is looked up is in %, and thus needs to be divided by 100
	set tDCD [expr [get_io_standard_node_delay -dst MEM_CK_DCD -io_standard $io_std -parameters [list IO $interface_type]]/100.0]
	
	# This is the peak-to-peak jitter on the whole DQ-DQS read capture path
	set DQSpathjitter [expr [get_io_standard_node_delay -dst DQDQS_JITTER -io_standard $io_std -parameters [list IO $interface_type]]/1000.0]
	# This is the proportion of the DQ-DQS read capture path jitter that applies to setup (looed up value is in %, and thus needs to be divided by 100)
	set DQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst DQDQS_JITTER_DIVISION -io_standard $io_std -parameters [list IO $interface_type]]/100.0]
`endif
	# Phase Error on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PSERR) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PSERR -in_fitter ] / 1000.0 ]

	set setup_slack 1000000000
	set hold_slack  1000000000
	set default_setup_slack 1000000000
	set default_hold_slack  1000000000	
		
	# Find quiet jitter values during calibration
	set quiet_setup_jitter [expr 0.8*$DQSpathjitter*$DQSpathjitter_setup_prop]
	set quiet_hold_jitter  [expr 0.8*$DQSpathjitter*(1-$DQSpathjitter_setup_prop)]
	set max_read_deskew_setup [expr $IP(read_deskew_range_setup)*$IP(quantization_T1)]
	set max_read_deskew_hold  [expr $IP(read_deskew_range_hold)*$IP(quantization_T1)]
		
	if {($result == 1)} {

		#Go over each CQ pin
		set group_number -1
		foreach qpins $pins(q_groups) {
			
			set group_number [expr $group_number + 1]
			
			set cqpin [lindex $pins(cq_pins) $group_number]
			set cqnpin [lindex $pins(cq_n_pins) $group_number]
			
			#############################################
			# Find extra CQ pessimism due to correlation
			#############################################

			# Find paths from output of the input buffer to the end of the CQ periphery
`ifdef IPTCL_ACV_FAMILY
			set input_buffer_node [list "${inst}|p0|umemphy|uio_pads|read_capture[$group_number].uread|altdq_dqs2_inst|strobe_in|o" ]
`else
			set input_buffer_node [list "${inst}|p0|umemphy|uio_pads|read_capture[$group_number].uread|altdq_dqs2_inst|strobe_in|o" \
										"${inst}|p0|umemphy|uio_pads|read_capture[$group_number].uread|altdq_dqs2_inst|strobe_n_in|o" ]
`endif
`ifdef IPTCL_STRATIXV
			set DQScapture_node [list "${prefix}|*read_capture[$group_number].uread|*input_path_gen[*].capture_reg~HIGH_DFF" \
									  "${prefix}|*read_capture[$group_number].uread|*input_path_gen[*].capture_reg~FF" ]
`else
`ifdef IPTCL_ACV_FAMILY
			set DQScapture_node [list "${prefix}|*read_capture[$group_number].uread|*input_path_gen[*].capture_reg~DFFLO" ]
`else
			set DQScapture_node [list "${prefix}|*read_capture[$group_number].uread|*input_path_gen[*].capture_reg~DFFLO" \
									  "${prefix}|*read_capture[$group_number].uread|*read_data_out[*]" ]
`endif
`endif

			set DQSperiphery_min [get_path -from $input_buffer_node -to $DQScapture_node]
			set DQSperiphery_delay [memphy_max_in_collection $DQSperiphery_min "arrival_time"]
			set DQSpath_pessimism [expr ($DQSperiphery_delay-$dqs_phase/360.0*$period)*$DQS_min_max]
			
			# Go over each Q pin in group
			set q_index 0
			foreach qpin $qpins {
				regexp {\d+} $qpin q_pin_index
			
				# Perform the default timing analysis to get required and arrival times
				set pin_setup_slack [min [memphy_min_in_collection_from_name $paths_setup "slack" $qpin] [memphy_min_in_collection_from_name $paths_setup2 "slack" $qpin]]
				set pin_hold_slack  [min [memphy_min_in_collection_from_name $paths_hold "slack" $qpin]  [memphy_min_in_collection_from_name $paths_hold2 "slack" $qpin]]

				set default_setup_slack [min $default_setup_slack $pin_setup_slack]
				set default_hold_slack  [min $default_hold_slack  $pin_hold_slack]		

				if { $debug } {
					puts "READ: $group_number $cqpin $qpin $pin_setup_slack $pin_hold_slack (MP: $mp_setup_slack $mp_hold_slack)"
				}
			
				###############################
				# Add the memory calibration improvement
				###############################
				
				set pin_setup_slack [expr $pin_setup_slack + $mp_setup_slack]
				set pin_hold_slack [expr $pin_hold_slack + $mp_hold_slack]
				
				############################################
				# Find extra Q pessimism due to correlation
				############################################
				
				# Find paths from output of the input buffer to the end of the DQ periphery
				set input_buffer_node_dq ${inst}|p0|umemphy|uio_pads|read_capture[$group_number].uread|altdq_dqs2_inst|pad_gen[$q_index].data_in|o
`ifdef IPTCL_STRATIXV
				set DQcapture_node [list "${prefix}|*read_capture[$group_number].uread|*input_path_gen[$q_index].capture_reg~HIGH_DFF" \
										 "${prefix}|*read_capture[$group_number].uread|*input_path_gen[$q_index].capture_reg~FF" ]
`else
`ifdef IPTCL_ACV_FAMILY
				set DQcapture_node [list "${prefix}|*read_capture[$group_number].uread|*input_path_gen[$q_index].capture_reg~DFFLO" ]
`else
				set DQcapture_node [list "${prefix}|*read_capture[$group_number].uread|*input_path_gen[$q_index].capture_reg~DFFLO" \
										 "${prefix}|*read_capture[$group_number].uread|*read_data_out[$q_index]" ]
`endif
`endif

				set DQperiphery_min [get_path -from $input_buffer_node_dq -to $DQcapture_node -min_path -nworst 10]
				set DQperiphery_delay [memphy_min_in_collection $DQperiphery_min "arrival_time"]
				set DQpath_pessimism [expr $DQperiphery_delay*$DQS_min_max]
				
				########################################
				# Merge current slacks with other slacks
				########################################

				# If read deskew is available, the setup and hold slacks for this pin will be equal
				#   and can also remove the extra CQ pessimism removal
				if {$IP(read_deskew_mode) == "dynamic"} {
				
					# Consider the maximum range of the deskew when deskewing
					set shift_setup_slack [expr (($pin_setup_slack + $quiet_setup_jitter) + ($pin_hold_slack + $quiet_hold_jitter))/2 - $pin_setup_slack - $quiet_setup_jitter]
					if {$shift_setup_slack >= $max_read_deskew_setup} {
						if { $debug } {
							puts "limited setup"
						}
						set pin_setup_slack [expr $pin_setup_slack + $max_read_deskew_setup]
						set pin_hold_slack [expr $pin_hold_slack - $max_read_deskew_setup]
						
						# Remember the largest shifts in either direction
						if {[info exist max_shift]} {
							if {$max_read_deskew_setup > $max_shift} {
								set max_shift $max_read_deskew_setup
							}
							if {$max_read_deskew_setup < $min_shift} {
								set min_shift $max_read_deskew_setup
							}
						} else {
							set max_shift $max_read_deskew_setup
							set min_shift $max_shift
						}
						
					} elseif {$shift_setup_slack <= -$max_read_deskew_hold} {
						if { $debug } {
							puts "limited hold"
						}
						set pin_setup_slack [expr $pin_setup_slack - $max_read_deskew_hold]
						set pin_hold_slack [expr $pin_hold_slack + $max_read_deskew_hold]
						
						# Remember the largest shifts in either direction
						if {[info exist max_shift]} {
							if {[expr 0 -$max_read_deskew_hold] > $max_shift} {
								set max_shift [expr 0 - $max_read_deskew_hold]
							}
							if {[expr 0 -$max_read_deskew_hold] < $min_shift} {
								set min_shift [expr 0 - $max_read_deskew_hold]
							}
						} else {
							set max_shift [expr 0 - $max_read_deskew_hold]
							set min_shift $max_shift
						}
					} else {
						# In this case we can also consider the QK path pessimism since we can guarantee we have enough delay chain settings to align it
						set pin_setup_slack [expr $pin_setup_slack + $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
						set pin_hold_slack [expr $pin_hold_slack - $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
						
						# Remember the largest shifts in either direction
						if {[info exist max_shift]} {
							if {[expr $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2] > $max_shift} {
								set max_shift [expr $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
							}
							if {[expr $shift_setup_slack - $DQSpath_pessimism/2 - $DQpath_pessimism/2] < $min_shift} {
								set min_shift [expr $shift_setup_slack - $DQSpath_pessimism/2 - $DQpath_pessimism/2]
							}
						} else {
							set max_shift [expr $shift_setup_slack + $DQSpath_pessimism/2 + $DQpath_pessimism/2]
							set min_shift [expr $shift_setup_slack - $DQSpath_pessimism/2 - $DQpath_pessimism/2]
						}
					}
				} else {
					# For uncalibrated calls, there is some spatial correlation between Q and CQ signals, so remove
					# some of the pessimism
					set total_DQ_DQS_pessimism [expr $DQSpath_pessimism + $DQpath_pessimism]
					set dqs_width [llength $qpins]
					if {$dqs_width <= 9} {
						set pin_setup_slack [expr $pin_setup_slack + 0.35*$total_DQ_DQS_pessimism]
						set pin_hold_slack  [expr $pin_hold_slack  + 0.35*$total_DQ_DQS_pessimism]
					} else {
						set pin_setup_slack [expr $pin_setup_slack + 0.12*$total_DQ_DQS_pessimism]
						set pin_hold_slack  [expr $pin_hold_slack  + 0.12*$total_DQ_DQS_pessimism]
					}
				}

				set setup_slack [min $setup_slack $pin_setup_slack]
				set hold_slack  [min $hold_slack $pin_hold_slack]
				
				if { $debug } {
					puts "READ:               $DQSpath_pessimism $DQpath_pessimism ($pin_setup_slack $pin_hold_slack $setup_slack $hold_slack)" 
				}
				set q_index [expr $q_index + 1]
			}
		}
	}
	
	########################################################
	# Consider some post calibration effects on calibration
	#  and output the read summary report
	########################################################
	
	set positive_fcolour [list "black" "blue" "blue"]
	set negative_fcolour [list "black" "red"  "red"]	

	set rc_summary [list]	
	
	set fcolour [memphy_get_colours $default_setup_slack $default_hold_slack]
	if {$IP(read_deskew_mode) == "dynamic"} {
		lappend rc_summary [list "  Before Calibration Read Capture" [memphy_format_3dp $default_setup_slack] [memphy_format_3dp $default_hold_slack]]
	} else {
		lappend rc_summary [list "  Standard Read Capture" [memphy_format_3dp $default_setup_slack] [memphy_format_3dp $default_hold_slack]] 
	}
	
	if {($IP(read_deskew_mode) == "dynamic") && ($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		lappend rc_summary [list "  Memory Calibration" [memphy_format_3dp $mp_setup_slack] [memphy_format_3dp $mp_hold_slack]] 
	}
	
	if {$IP(read_deskew_mode) == "dynamic"} {
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		
		#######################################
		# Find values for uncertainty table
		set t(rdu_fpga_deskew_s) [expr $setup_slack - $default_setup_slack - $mp_setup_slack]
		set t(rdu_fpga_deskew_h) [expr $hold_slack  - $default_hold_slack  - $mp_hold_slack]
		#######################################
		
		# Remove external delays (add slack) that are fixed by the dynamic deskew
		[catch {get_float_table_node_delay -src {DELAYCHAIN_T1} -dst {VTVARIATION} -parameters [list IO $interface_type]} t1_vt_variation_percent]
		set extra_shift [expr $board(intra_CQ_group_skew) + [memphy_round_3dp [expr (1.0-$t1_vt_variation_percent)*$fpga(tDQS_PSERR)]]]
		
		if {$extra_shift > [expr $max_read_deskew_setup - $max_shift]} {
			set setup_slack [expr $setup_slack + $max_read_deskew_setup - $max_shift]
		} else {
			set setup_slack [expr $setup_slack + $extra_shift]
		}
		if {$extra_shift > [expr $max_read_deskew_hold + $min_shift]} {
			set hold_slack [expr $hold_slack + $max_read_deskew_hold + $min_shift]
		} else {
			set hold_slack [expr $hold_slack + $extra_shift]
		}	
		
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		set deskew_setup [expr $setup_slack - $default_setup_slack - $mp_setup_slack]
		set deskew_hold  [expr $hold_slack - $default_hold_slack - $mp_hold_slack]
		lappend rc_summary [list "  Deskew Read" [memphy_format_3dp $deskew_setup] [memphy_format_3dp $deskew_hold]]
		
		#######################################
		# Find values for uncertainty table
		set t(rdu_external_deskew_s) [expr $deskew_setup - $t(rdu_fpga_deskew_s) + $mp_setup_slack]
		set t(rdu_external_deskew_h) [expr $deskew_hold  - $t(rdu_fpga_deskew_h) + $mp_hold_slack]
		#######################################

		# Consider errors in the dynamic deskew
		set t1_quantization $IP(quantization_T1)
		set setup_slack [expr $setup_slack - $t1_quantization]
		set hold_slack  [expr $hold_slack - $t1_quantization]
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend rc_summary [list "  Quantization error" [memphy_format_3dp [expr 0-$t1_quantization]] [memphy_format_3dp [expr 0-$t1_quantization]]]
		
		# Consider variation in the delay chains used during dynamic deksew
		set offset_from_90 [expr abs(90-$dqs_phase)/360.0*$period]
		if {$IP(num_ranks) == 1} {
			set t1_variation [expr [min [expr $offset_from_90 + [max [expr $MP(CQD)*$t(CQD)] [expr - $MP(CQDOH)*$t(CQDOH)]] + 2*$board(intra_CQ_group_skew) + $max_package_skew + $fpga(tDQS_PSERR)] [max $max_read_deskew_setup $max_read_deskew_hold]]*2*$t1_vt_variation_percent]
		} else {
			set t1_variation [expr [min [expr $offset_from_90 + 2*$board(intra_CQ_group_skew) + $max_package_skew + $fpga(tDQS_PSERR)] [max $max_read_deskew_setup $max_read_deskew_hold]]*2*$t1_vt_variation_percent]
		}
		set setup_slack [expr $setup_slack - $t1_variation]
		set hold_slack  [expr $hold_slack - $t1_variation]	
		if { $debug } {
			puts "	$setup_slack $hold_slack"
		}
		lappend rc_summary [list "  Calibration uncertainty" [memphy_format_3dp [expr 0-$t1_variation]] [memphy_format_3dp [expr 0-$t1_variation]]]
		
		#######################################
		# Find values for uncertainty table
		set uncertainty_reporting [get_ini_var -name "qsta_enable_uncertainty_ddr_reporting"]
		if {[string equal -nocase $uncertainty_reporting on]} {
			set t(rdu_calibration_uncertaintyerror_s) [expr 0 - $t1_variation - $t1_quantization]
			set t(rdu_calibration_uncertaintyerror_h) [expr 0 - $t1_variation - $t1_quantization]
			set t(rdu_fpga_uncertainty_s) [expr $t(CYC)/4 - $default_setup_slack - $t(rdu_input_max_delay_external)]
			set t(rdu_fpga_uncertainty_h) [expr $t(CYC)/4 - $default_hold_slack  - $t(rdu_input_min_delay_external)]
			set t(rdu_extl_uncertainty_s) [expr $t(rdu_input_max_delay_external)]
			set t(rdu_extl_uncertainty_h) [expr $t(rdu_input_min_delay_external)]		
		}
		#######################################
		
	} else {
		set pessimism_setup [expr $setup_slack - $default_setup_slack - $mp_setup_slack]
		set pessimism_hold  [expr $hold_slack - $default_hold_slack - $mp_hold_slack]
		lappend rc_summary [list "  Spatial correlation pessimism removal" [memphy_format_3dp $pessimism_setup] [memphy_format_3dp $pessimism_hold]] 
		
		#######################################
		# Find values for uncertainty table
		set uncertainty_reporting [get_ini_var -name "qsta_enable_uncertainty_ddr_reporting"]
		if {[string equal -nocase $uncertainty_reporting on]} {
			set t(rdu_fpga_deskew_s) 0
			set t(rdu_fpga_deskew_h) 0
			set t(rdu_external_deskew_s) 0
			set t(rdu_external_deskew_h) 0
			set t(rdu_calibration_uncertaintyerror_s) 0
			set t(rdu_calibration_uncertaintyerror_h) 0
			set t(rdu_fpga_uncertainty_s) [expr $t(CYC)/4 - $default_setup_slack - $t(rdu_input_max_delay_external) - $pessimism_setup]
			set t(rdu_fpga_uncertainty_h) [expr $t(CYC)/4 - $default_hold_slack  - $t(rdu_input_min_delay_external) - $pessimism_hold]
			set t(rdu_extl_uncertainty_s) [expr $t(rdu_input_max_delay_external)]
			set t(rdu_extl_uncertainty_h) [expr $t(rdu_input_min_delay_external)]				
		}
		#######################################
	}
	
	#######################################
	# Create the read analysis panel	
	set panel_name "$inst Read Capture"
	set root_folder_name [get_current_timequest_report_folder]

	if { ! [string match "${root_folder_name}*" $panel_name] } {
		set panel_name "${root_folder_name}||$panel_name"
	}
	# Create the root if it doesn't yet exist
	if {[get_report_panel_id $root_folder_name] == -1} {
		set panel_id [create_report_panel -folder $root_folder_name]
	}

	# Delete any pre-existing summary panel
	set panel_id [get_report_panel_id $panel_name]
	if {$panel_id != -1} {
		delete_report_panel -id $panel_id
	}
	
	if {($setup_slack < 0) || ($hold_slack <0)} {
		set panel_id [create_report_panel -table $panel_name -color red]
	} else {
		set panel_id [create_report_panel -table $panel_name]
	}	
	add_row_to_table -id $panel_id [list "Operation" "Setup Slack" "Hold Slack"]	
	
	if {$IP(read_deskew_mode) == "dynamic"} {
		set fcolour [memphy_get_colours $setup_slack $hold_slack] 
		add_row_to_table -id $panel_id [list "After Calibration Read Capture" [memphy_format_3dp $setup_slack] [memphy_format_3dp $hold_slack]] -fcolor $fcolour
		lappend summary [list $opcname 0 "Read Capture ($opcname)" $setup_slack $hold_slack]
	} else {
		set fcolour [memphy_get_colours $setup_slack $hold_slack] 
		add_row_to_table -id $panel_id [list "Read Capture" [memphy_format_3dp $setup_slack] [memphy_format_3dp $hold_slack]] -fcolor $fcolour
		lappend summary [list $opcname 0 "Read Capture CQ ($opcname)" $setup_slack $hold_slack]  
	}	
	
	foreach summary_line $rc_summary {
		add_row_to_table -id $panel_id $summary_line -fcolors $positive_fcolour
	}	
	
	#######################################
	# Create the Read uncertainty panel
	set uncertainty_reporting [get_ini_var -name "qsta_enable_uncertainty_ddr_reporting"]
	if {[string equal -nocase $uncertainty_reporting on]} {
		set panel_name "$inst Read Capture Uncertainty"
		set root_folder_name [get_current_timequest_report_folder]

		if { ! [string match "${root_folder_name}*" $panel_name] } {
			set panel_name "${root_folder_name}||$panel_name"
		}

		# Delete any pre-existing summary panel
		set panel_id [get_report_panel_id $panel_name]
		if {$panel_id != -1} {
			delete_report_panel -id $panel_id
		}
		
		set panel_id [create_report_panel -table $panel_name]
		add_row_to_table -id $panel_id [list "Value" "Setup Side" "Hold Side"]
		add_row_to_table -id $panel_id [list "Uncertainty" "" ""]
		add_row_to_table -id $panel_id [list "  FPGA uncertainty" [memphy_format_3dp $t(rdu_fpga_uncertainty_s)] [memphy_format_3dp $t(rdu_fpga_uncertainty_h)]] 
		add_row_to_table -id $panel_id [list "  External uncertainty" [memphy_format_3dp $t(rdu_extl_uncertainty_s)] [memphy_format_3dp $t(rdu_extl_uncertainty_h)]] 
		add_row_to_table -id $panel_id [list "Deskew" "" ""]
		add_row_to_table -id $panel_id [list "  FPGA deskew" [memphy_format_3dp $t(rdu_fpga_deskew_s)] [memphy_format_3dp $t(rdu_fpga_deskew_h)]] 
		add_row_to_table -id $panel_id [list "  External deskew" [memphy_format_3dp $t(rdu_external_deskew_s)] [memphy_format_3dp $t(rdu_external_deskew_h)]] 
		add_row_to_table -id $panel_id [list "  Calibration uncertainty/error" [memphy_format_3dp $t(rdu_calibration_uncertaintyerror_s)] [memphy_format_3dp $t(rdu_calibration_uncertaintyerror_h)]] 
	}
		
}
`endif

`ifdef IPTCL_PRINT_MACRO_TIMING
proc memphy_perform_macro_read_capture_timing_analysis {opcs opcname inst dqs_phase all_q_pins pin_array_name timing_parameters_array_name summary_name IP_name board_name} {

	###############################################################################
	# This timing analysis covers the read timing constraints using the Altera 
	# characterized values.  Altera performs characterization on its devices and IP 
	# to determine all the FPGA uncertainties, and uses these values to provide accurate 
	# timing analysis.  
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $IP_name IP
	upvar 1 $pin_array_name pins
	upvar 1 $board_name board
	
	set board_skew $board(intra_CQ_group_skew)
	set read_board_skew board_skew
	if {$IP(read_deskew_mode) == "dynamic"} {
		if {[catch {get_micro_node_delay -micro EXTERNAL_SKEW_THRESHOLD -parameters [list IO]} compensated_skew] != 0 || $compensated_skew == ""} {
			# No skew compensation
		} else {
			set compensated_skew [expr $compensated_skew / 1000.0]
			if {$board_skew > $compensated_skew} {
				set read_board_skew [expr $board_skew - $compensated_skew]
			} else {
				set read_board_skew 0
			}
		}
	}
	
	# Read capture CQ
	set tsw  [memphy_get_tsw $IP(mem_if_memtype) $pins(cq_pins) $t(CYC)]
`ifdef IPTCL_EMULATED_MODE	
	# Additional TCCS derating due to pseudo x36 mode
	set tsw_x36 [memphy_get_qdr_tsw_derating $pins(cq_pins)]
	set su   [memphy_round_3dp [expr {$t(CYC)*$dqs_phase/360.0 - [lindex $tsw 0]/1000.0 - [lindex $tsw_x36 0]/1000.0 - $t(CQD) - $board_skew}]]
	set hold [memphy_round_3dp [expr {$t(CYC)*(0.5 - $t(DCD)) - $t(INTERNAL_JITTER) + $t(CQDOH) - $t(CYC)*$dqs_phase/360.0 - [lindex $tsw 1]/1000.0 - [lindex $tsw_x36 1]/1000.0 - $board_skew}]]
`else
	set su   [memphy_round_3dp [expr {$t(CYC)*$dqs_phase/360.0 - [lindex $tsw 0]/1000.0 - $t(CQD) - $board_skew}]]
	set hold [memphy_round_3dp [expr {$t(CYC)*(0.5 - $t(DCD)) - $t(INTERNAL_JITTER) + $t(CQDOH) - $t(CYC)*$dqs_phase/360.0 - [lindex $tsw 1]/1000.0 - $board_skew}]]
`endif
	lappend summary [list "All Conditions" 0 "Read Capture CQ (All Conditions)" $su $hold 1 1]

	# Read capture CQn
	set tsw  [memphy_get_tsw $IP(mem_if_memtype) $pins(cq_n_pins) $t(CYC)]
`ifdef IPTCL_EMULATED_MODE	
	# Additional TCCS derating due to pseudo x36 mode
	set tsw_x36 [memphy_get_qdr_tsw_derating $pins(cq_n_pins)]
	set su   [memphy_round_3dp [expr {$t(CYC)*$dqs_phase/360.0 - [lindex $tsw 0]/1000.0 - [lindex $tsw_x36 0]/1000.0 - $t(CQD) - $board_skew}]]
	set hold [memphy_round_3dp [expr {$t(CYC)*(0.5 - $t(DCD)) - $t(INTERNAL_JITTER) + $t(CQDOH) - $t(CYC)*$dqs_phase/360.0 - [lindex $tsw 1]/1000.0 - [lindex $tsw_x36 1]/1000.0 - $board_skew}]]
`else
	set su   [memphy_round_3dp [expr {$t(CYC)*$dqs_phase/360.0 - [lindex $tsw 0]/1000.0 - $t(CQD) - $board_skew}]]
	set hold [memphy_round_3dp [expr {$t(CYC)*(0.5 - $t(DCD)) - $t(INTERNAL_JITTER) + $t(CQDOH) - $t(CYC)*$dqs_phase/360.0 - [lindex $tsw 1]/1000.0 - $board_skew}]]
`endif	
	lappend summary [list "All Conditions" 0 "Read Capture CQn (All Conditions)" $su $hold 1 1]	
}
`endif

#############################################################
# Other Timing Analysis
#############################################################

proc memphy_perform_phy_analyses {opcs opcname inst inst_controller pin_array_name timing_parameters_array_name summary_name IP_name} {

	###############################################################################
	# The PHY analysis concerns the timing requirements of the PHY which includes
	# soft registers in the FPGA core as well as some registers in the hard periphery
	# The read capture and write registers are not analyzed here, even though they 
	# are part of the PHY since they are timing analyzed separately. 
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $pin_array_name pins
	upvar 1 $IP_name IP
	
	set num_failing_path $IP(num_report_paths)

	set entity_names_on [ memphy_are_entity_names_on ]

	set prefix [ string map "| |*:" $inst ]
	set prefix "*:$prefix"
	set prefix_controller [ string map "| |*:" $inst_controller ]
	set prefix_controller "*:$prefix_controller"

	if { ! $entity_names_on } {
		set core_regs [remove_from_collection [get_registers $inst|*] [get_registers $pins(read_capture_ddio_capture)]]
	} else {
		set core_regs [remove_from_collection [get_registers $prefix|*] [get_registers $pins(read_capture_ddio_capture)]]
	}

	# Core
	set res_0 [report_timing -detail full_path -to $core_regs -npaths $num_failing_path -panel_name "$inst Core (setup)" -setup]
	set res_1 [report_timing -detail full_path -to $core_regs -npaths $num_failing_path -panel_name "$inst Core (hold)" -hold]
	lappend summary [list $opcname 0 "Core ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	# Core Recovery/Removal
	set res_0 [report_timing -detail full_path -to $core_regs -npaths $num_failing_path -panel_name "$inst Core Recovery/Removal (recovery)" -recovery]
	set res_1 [report_timing -detail full_path -to $core_regs -npaths $num_failing_path -panel_name "$inst Core Recovery/Removal (removal)" -removal]
	lappend summary [list $opcname 0 "Core Recovery/Removal ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]
	
`ifdef IPTCL_ENABLE_EXTRA_REPORTING
	################################################################################
	# BEGIN EXTRA REPORTING SECTION

	if { ! $entity_names_on } {
		set controller_regs [get_registers $inst_controller|*alt_*controller_*inst|*]
		set inst_other_if $inst
	} else {
		set controller_regs [get_registers $prefix_controller|*:*alt_*controller_*inst|*]
		set inst_other_if $prefix
	}
	set phy_regs [remove_from_collection $core_regs $controller_regs]
	set ext_regs [remove_from_collection [get_registers *] $phy_regs]
	set ext_regs [remove_from_collection $ext_regs [get_registers $pins(read_capture_ddio_capture)]]
	`ifdef IPTCL_PLL_SHARING
	set ext_regs_sub [regsub {if0$} $inst_other_if {if1} inst_other_if]
	if {!$ext_regs_sub} {
		set ext_regs_sub [regsub {if1$} $inst_other_if {if0} inst_other_if]
	}
	if {$ext_regs_sub && [get_collection_size [get_registers -nowarn $inst_other_if|*]] > 0} {
		set ext_regs [remove_from_collection $ext_regs [get_registers $inst_other_if|*]]
	}
	`endif

	set res_0 [report_timing -detail full_path -to $controller_regs -npaths $num_failing_path -panel_name "$inst_controller Controller (setup)" -setup]
	set res_1 [report_timing -detail full_path -to $controller_regs -npaths $num_failing_path -panel_name "$inst_controller Controller (hold)" -hold]
	lappend summary [list $opcname 0 "Controller ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	set res_0 [report_timing -detail full_path -to $controller_regs -npaths $num_failing_path -panel_name "$inst_controller Controller (recovery)" -recovery]
	set res_1 [report_timing -detail full_path -to $controller_regs -npaths $num_failing_path -panel_name "$inst_controller Controller (removal)" -removal]
	lappend summary [list $opcname 0 "Controller Recovery/Removal ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	set res_0 [report_timing -detail full_path -to $phy_regs -npaths $num_failing_path -panel_name "$inst PHY (setup)" -setup]
	set res_1 [report_timing -detail full_path -to $phy_regs -npaths $num_failing_path -panel_name "$inst PHY (hold)" -hold]
	lappend summary [list $opcname 0 "PHY ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	set res_0 [report_timing -detail full_path -to $phy_regs -npaths $num_failing_path -panel_name "$inst PHY (recovery)" -recovery]
	set res_1 [report_timing -detail full_path -to $phy_regs -npaths $num_failing_path -panel_name "$inst PHY (removal)" -removal]
	lappend summary [list $opcname 0 "PHY Recovery/Removal ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	set res_0 [report_timing -detail full_path -to $ext_regs -npaths $num_failing_path -panel_name "$inst User Logic (setup)" -setup]
	set res_1 [report_timing -detail full_path -to $ext_regs -npaths $num_failing_path -panel_name "$inst User Logic (hold)" -hold]
	lappend summary [list $opcname 0 "User Logic ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	set res_0 [report_timing -detail full_path -to $ext_regs -npaths $num_failing_path -panel_name "$inst User Logic (recovery)" -recovery]
	set res_1 [report_timing -detail full_path -to $ext_regs -npaths $num_failing_path -panel_name "$inst User Logic (removal)" -removal]
	lappend summary [list $opcname 0 "User Logic Recovery/Removal ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	# END EXTRA REPORTING SECTION
	# ################################################################################
`endif

}

proc memphy_perform_ac_analyses {opcs opcname inst pin_array_name timing_parameters_array_name summary_name IP_name} {

	###############################################################################
	# The adress/command analysis concerns the timing requirements of the pins (other
	# than the D/Q pins) which go to the memory device/DIMM.  These include address/command
	# pins, some of which are runing at Single-Data-Rate (SDR) and some which are 
	# running at Half-Data-Rate (HDR).  
	###############################################################################
	
	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $pin_array_name pins
	upvar 1 $IP_name IP

	set num_failing_path $IP(num_report_paths)

	set add_pins $pins(add_pins)
	set cmd_pins $pins(cmd_pins)
	set ac_pins [ concat $add_pins $cmd_pins ]	

	set entity_names_on [ memphy_are_entity_names_on ]

	set prefix [ string map "| |*:" $inst ]
	set prefix "*:$prefix"

	# Address Command
	set res_0 [report_timing -detail full_path -to $ac_pins -npaths $num_failing_path -panel_name "$inst Address Command (setup)" -setup]
	set res_1 [report_timing -detail full_path -to $ac_pins -npaths $num_failing_path -panel_name "$inst Address Command (hold)" -hold]
	lappend summary [list $opcname 0 "Address Command ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]
}

proc memphy_perform_resync_timing_analysis {opcs opcname inst fbasename family DQS_min_max io_std interface_type period pin_array_name timing_parameters_array_name summary_name MP_name IP_name board_name fpga_name SSN_name} {

	###############################################################################
	# The resynchronization timing analysis concerns transferring read data that
	# has been captured with a DQS strobe to a clock domain under the control of
	# the UniPHY. A special FIFO is used to resynchronize the data which has a wide
	# tolerance to any changes in the arrival time of data from DQS groups
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $pin_array_name pins
	upvar 1 $MP_name MP
	upvar 1 $IP_name IP
	upvar 1 $board_name board
	upvar 1 $fpga_name fpga
	upvar 1 $SSN_name SSN
	
	set num_paths 5000
	
`ifdef IPTCL_ACV_FAMILY
	lappend summary [list $opcname 0 "Read Resync ($opcname)" 1.000 1.000]

	return
`endif
	#######################################
	# Node names
`ifdef IPTCL_READ_FIFO_HALF_RATE
	set dqs_pins *${fbasename}_read_datapath:uread_datapath|read_capture_clk_div2[*]
`else
	set dqs_pins $pins(cq_pins)
	set dqsn_pins $pins(cq_n_pins)
`endif
`ifdef IPTCL_USE_HARD_READ_FIFO
	set fifo *${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard*INPUT_DFF*
	set reg_in_rd_clk_domain *${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|dataout[*]
	set reg_wr_address *${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|*WRITE_ADDRESS_DFF*
	set reg_rd_address *${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|*READ_ADDRESS_DFF*
`else
	set fifo *${fbasename}_flop_mem:read_buffering[*].read_subgroup[*].uread_fifo|data_stored[*][*]
	set reg_in_rd_clk_domain *${fbasename}_flop_mem:read_buffering[*].read_subgroup[*].uread_fifo|rd_data[*]
	set reg_wr_address *${fbasename}_read_datapath:uread_datapath|read_buffering[*].read_subgroup[*].wraddress[*]
	set reg_rd_address *${fbasename}_read_datapath:uread_datapath|read_buffering[*].read_subgroup[*].rdaddress[*]
`endif
	
	#######################################
	# Paths
`ifdef IPTCL_READ_FIFO_HALF_RATE
	set max_DQS_to_fifo_paths  [get_path -from $dqs_pins -to $fifo -npaths $num_paths -nworst 1]
	set min_DQS_to_fifo_paths  [get_path -from $dqs_pins -to $fifo -npaths $num_paths -min_path  -nworst 1]
`else
	set max_DQS_to_fifo_paths  [get_path -from [concat $dqs_pins $dqsn_pins] -to $fifo -npaths $num_paths -nworst 1]
	set min_DQS_to_fifo_paths  [get_path -from [concat $dqs_pins $dqsn_pins] -to $fifo -npaths $num_paths -min_path  -nworst 1]
`endif

	set max_fifo_to_rd_clk_domain_paths [get_path -from $fifo -to $reg_in_rd_clk_domain -npaths $num_paths  -nworst 1]
	set min_fifo_to_rd_clk_domain_paths [get_path -from $fifo -to $reg_in_rd_clk_domain -npaths $num_paths -min_path  -nworst 1]
	
	set max_DQS_to_wr_address_paths [get_path -from $dqs_pins -to $reg_wr_address -npaths $num_paths -nworst 1]
	set min_DQS_to_wr_address_paths [get_path -from $dqs_pins -to $reg_wr_address -npaths $num_paths -min_path  -nworst 1]
	
	set max_rd_address_to_rd_data_paths [get_path -from $reg_rd_address -to $reg_in_rd_clk_domain -npaths $num_paths -nworst 1]
	set min_rd_address_to_rd_data_paths [get_path -from $reg_rd_address -to $reg_in_rd_clk_domain -npaths $num_paths -min_path -nworst 1]
	
	set max_dqs_common_to_fifo [memphy_max_in_collection [get_path -from $dqs_pins -to $fifo -nworst 1] "arrival_time"]
	
	#########################################
	# Limit to one endpoint/startpoint
	
	foreach_in_collection path $max_DQS_to_fifo_paths {
		set arrival_time [get_path_info $path -arrival_time]
		set startpoint [get_node_info -name [get_path_info $path -from]]
		if {[info exist max_DQS_to_fifo_paths_max($startpoint)]} {
			if {$arrival_time > $max_DQS_to_fifo_paths_max($startpoint)} {
				set max_DQS_to_fifo_paths_max($startpoint) $arrival_time
			}
		} else {
			set max_DQS_to_fifo_paths_max($startpoint) $arrival_time
		}
	}
	
	foreach_in_collection path $min_DQS_to_fifo_paths {
		set arrival_time [get_path_info $path -arrival_time]
		set startpoint [get_node_info -name [get_path_info $path -from]]
		if {[info exist min_DQS_to_fifo_paths_min($startpoint)]} {
			if {$arrival_time < $min_DQS_to_fifo_paths_min($startpoint)} {
				set min_DQS_to_fifo_paths_min($startpoint) $arrival_time
			}
		} else {
			set min_DQS_to_fifo_paths_min($startpoint) $arrival_time
		}
	}	

	
	foreach_in_collection path $max_fifo_to_rd_clk_domain_paths {
		set arrival_time [get_path_info $path -arrival_time]
		set endpoint [get_node_info -name [get_path_info $path -to]]
		if {[info exist max_fifo_to_rd_clk_domain_paths_max($endpoint)]} {
			if {$arrival_time > $max_fifo_to_rd_clk_domain_paths_max($endpoint)} {
				set max_fifo_to_rd_clk_domain_paths_max($endpoint) $arrival_time
			}
		} else {
			set max_fifo_to_rd_clk_domain_paths_max($endpoint) $arrival_time
		}
	}
	
	foreach_in_collection path $min_fifo_to_rd_clk_domain_paths {
		set arrival_time [get_path_info $path -arrival_time]
		set endpoint [get_node_info -name [get_path_info $path -to]]
		if {[info exist min_fifo_to_rd_clk_domain_paths_min($endpoint)]} {
			if {$arrival_time < $min_fifo_to_rd_clk_domain_paths_min($endpoint)} {
				set min_fifo_to_rd_clk_domain_paths_min($endpoint) $arrival_time
			}
		} else {
			set min_fifo_to_rd_clk_domain_paths_min($endpoint) $arrival_time
		}
	}
	
	foreach_in_collection path $max_rd_address_to_rd_data_paths {
		set arrival_time [get_path_info $path -arrival_time]
		set endpoint [get_node_info -name [get_path_info $path -to]]
		if {[info exist max_rd_address_to_rd_data_paths_max($endpoint)]} {
			if {$arrival_time > $max_rd_address_to_rd_data_paths_max($endpoint)} {
				set max_rd_address_to_rd_data_paths_max($endpoint) $arrival_time
			}
		} else {
			set max_rd_address_to_rd_data_paths_max($endpoint) $arrival_time
		}
	}
	
	foreach_in_collection path $min_rd_address_to_rd_data_paths {
		set arrival_time [get_path_info $path -arrival_time]
		set endpoint [get_node_info -name [get_path_info $path -to]]
		if {[info exist min_rd_address_to_rd_data_paths_min($endpoint)]} {
			if {$arrival_time < $min_rd_address_to_rd_data_paths_min($endpoint)} {
				set min_rd_address_to_rd_data_paths_min($endpoint) $arrival_time
			}
		} else {
			set min_rd_address_to_rd_data_paths_min($endpoint) $arrival_time
		}
	}		
	
	#######################################
	# TCO times
	set i 0
	set tco_fifo_min 0
	set tco_fifo_max 0
	foreach_in_collection register [get_keepers $fifo] {
		set tcotemp [get_register_info $register -tco]
		if {$i == 0} {
			set tco_fifo_min $tcotemp
			set tco_fifo_max $tcotemp
		} else {
			if {$tcotemp < $tco_fifo_min} {
				set tco_fifo_min $tcotemp
			} elseif {$tcotemp > $tco_fifo_max} {
				set tco_fifo_max $tcotemp
			}
		}
		incr i
	}
	set i 0
	set tco_wr_address_min 0
	set tco_wr_address_max 0
	foreach_in_collection register [get_keepers $reg_wr_address] {
		set tcotemp [get_register_info $register -tco]
		if {$i == 0} {
			set tco_wr_address_min $tcotemp
			set tco_wr_address_max $tcotemp
		} else {
			if {$tcotemp < $tco_wr_address_min} {
				set tco_wr_address_min $tcotemp
			} elseif {$tcotemp > $tco_wr_address_max} {
				set tco_wr_addressmax $tcotemp
			}
		}
		incr i
	}
	
	#######################################
	# Other parameters
	set prefix [ string map "| |*:" $inst ]
	set prefix "*:$prefix"
	set entity_names_on [ memphy_are_entity_names_on ]	
	set fly_by_wire 0
`ifdef IPTCL_FULL_RATE
	set min_latency 2
	set max_latency 3
`ifdef IPTCL_USE_HARD_READ_FIFO
	set fifo_depth 16
`else
	if { ! $entity_names_on } {
		set fifo_depth [get_collection_size [get_keepers $inst*read_buffering[0].read_subgroup[0].uread_fifo|data_stored[*][0]]]	
	} else {
		set fifo_depth [get_collection_size [get_keepers $prefix*read_buffering[0].read_subgroup[0].uread_fifo|data_stored[*][0]]]	
	}	
`endif
`else
	set min_latency 1
	set max_latency 2.5
`ifdef IPTCL_USE_HARD_READ_FIFO
	set fifo_depth 8
`else
	if { ! $entity_names_on } {
		set fifo_depth [get_collection_size [get_keepers $inst*read_buffering[0].read_subgroup[0].uread_fifo|data_stored[*][0]]]	
	} else {
		set fifo_depth [get_collection_size [get_keepers $prefix*read_buffering[0].read_subgroup[0].uread_fifo|data_stored[*][0]]]	
	}	
`endif
`ifdef IPTCL_READ_FIFO_HALF_RATE
`else
	set fifo_depth [expr $fifo_depth/2.0]
`endif
`endif	
	if {($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		set mp_CQD [expr $MP(CQD)*$t(CQD)]

		set mp_CQDOH  [expr -$MP(CQDOH)*$t(CQDOH)]
	} else {
		set mp_CQD 0
		set mp_CQDOH 0
	}
`ifdef IPTCL_STRATIXV
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set hf_DQS_variation [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO PHY_SHORT] -in_fitter -period $period]/1000.0*2/2]	
`else
	set hf_DQS_variation [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO QCLK] -in_fitter -period $period]/1000.0*2/2]
`endif
`else
	set hf_DQS_variation [expr [get_io_standard_node_delay -dst MEM_CK_PERIOD_JITTER -io_standard $io_std -parameters [list IO $interface_type] -period $period]/1000.0*2/2]
`endif
	set hf_DQS_variation [expr $hf_DQS_variation + $SSN(pushout_o) + $SSN(pullin_o) + $t(CQD) - $t(CQDOH) - $mp_CQD - $mp_CQDOH + $SSN(pullin_i)]
	set hf_DQS_variation [expr $hf_DQS_variation + [get_float_table_node_delay -src {DELAYCHAIN_T9} -dst {VTVARIATION} -parameters [list IO $interface_type]]*$max_dqs_common_to_fifo/2]
	
	#######################################
	# Board parameters
	set board_skew [expr $board(inter_DQS_group_skew)/2.0]
	if {$IP(num_ranks) > 1} {
		set board_skew [expr $board_skew + $board(tpd_inter_DIMM)]
	}	

	#######################################
	# Body of Resync analysis
	# Go over each DQ pin

	set total_setup_slack 10000000
	set total_hold_slack  10000000
	
	set regs [get_keepers $reg_in_rd_clk_domain]
`ifdef IPTCL_READ_FIFO_HALF_RATE
	set dqs_regs [get_keepers $dqs_pins]
	set dqs_regs_list [list]
	foreach_in_collection reg $dqs_regs {
		lappend dqs_regs_list [get_register_info -name $reg]
	}
	lsort $dqs_regs_list
`endif

	foreach_in_collection reg $regs {

		set reg_name [get_register_info -name $reg]

		if {[info exists max_rd_address_to_rd_data_paths_max($reg_name)]==0} {
			# not all registers have arcs for the hard read fifo, depending upon full/half rate
			continue
		}
		
`ifdef IPTCL_USE_HARD_READ_FIFO
		regexp {read_buffering\[(\d+)\]\.uread_read_fifo_hard} $reg_name match dqs_group_number
`else
		regexp {read_buffering\[(\d+)\]\.read_subgroup} $reg_name match dqs_group_number
`endif

`ifdef IPTCL_READ_FIFO_HALF_RATE
		set dqs_pin [lindex $dqs_regs_list $dqs_group_number]

		set max_DQS_to_fifo $max_DQS_to_fifo_paths_max($dqs_pin)
		set min_DQS_to_fifo $min_DQS_to_fifo_paths_min($dqs_pin)		
`else
		set dqs_pin [lindex $pins(cq_pins) $dqs_group_number]
		set dqsn_pin  [lindex $pins(cq_n_pins) $dqs_group_number]

		if {[info exist max_DQS_to_fifo_paths_max($dqs_pin)]} {
			set max_DQS_to_fifo $max_DQS_to_fifo_paths_max($dqs_pin)
			set min_DQS_to_fifo $min_DQS_to_fifo_paths_min($dqs_pin)		
		} else {
			set max_DQS_to_fifo $max_DQS_to_fifo_paths_max($dqsn_pin)
			set min_DQS_to_fifo $min_DQS_to_fifo_paths_min($dqsn_pin)		
		}
`endif
		set max_fifo_to_rd_clk_domain $max_fifo_to_rd_clk_domain_paths_max($reg_name)
		set min_fifo_to_rd_clk_domain $min_fifo_to_rd_clk_domain_paths_min($reg_name)
		set max_rd_address_to_rd_data $max_rd_address_to_rd_data_paths_max($reg_name)
		set min_rd_address_to_rd_data $min_rd_address_to_rd_data_paths_min($reg_name)

`ifdef IPTCL_ENABLE_EXTRA_REPORTING				
		if {($max_DQS_to_fifo == 0) || ($min_DQS_to_fifo == 0) || ($max_fifo_to_rd_clk_domain == 0) || ($min_fifo_to_rd_clk_domain == 0) || ($max_rd_address_to_rd_data == 0) || ($min_rd_address_to_rd_data == 0)} {
			return
		}
`endif

		###############
		# Setup analysis	
`ifdef IPTCL_FULL_RATE
		set setup_arrival_time  [expr ($max_DQS_to_fifo - $min_DQS_to_fifo) + $tco_fifo_max + $max_fifo_to_rd_clk_domain]
		set setup_required_time [expr $min_latency*$period + $tco_wr_address_min + $min_rd_address_to_rd_data]
`else
		set setup_arrival_time  [expr ($max_DQS_to_fifo - $min_DQS_to_fifo) + $tco_fifo_max + $max_fifo_to_rd_clk_domain + $hf_DQS_variation]
		set setup_required_time [expr $min_latency*$period*2 + $tco_wr_address_min + $min_rd_address_to_rd_data]
`endif
		set setup_slack [expr $setup_required_time - $setup_arrival_time - $board_skew]

		###############
		# Hold analysis
`ifdef IPTCL_FULL_RATE
		set hold_arrival_time  [expr ($min_DQS_to_fifo - $max_DQS_to_fifo) + $tco_fifo_min + $min_fifo_to_rd_clk_domain + $fifo_depth*$period]
		set hold_required_time [expr $hf_DQS_variation + $max_rd_address_to_rd_data + $tco_wr_address_max + $max_latency*$period  + $fly_by_wire]	
`else
		set hold_arrival_time  [expr ($min_DQS_to_fifo - $max_DQS_to_fifo) + $tco_fifo_min + $min_fifo_to_rd_clk_domain + $fifo_depth*$period*2]
		set hold_required_time [expr $hf_DQS_variation + $max_rd_address_to_rd_data + $tco_wr_address_max + $max_latency*$period*2  + $fly_by_wire]	
`endif
		set hold_slack [expr -$hold_required_time + $hold_arrival_time - $board_skew]

		if {$setup_slack < $total_setup_slack} {
			set total_setup_slack $setup_slack
		}
		
		if {$hold_slack < $total_hold_slack} {
			set total_hold_slack $hold_slack
		}				
	}
	lappend summary [list $opcname 0 "Read Resync ($opcname)" $total_setup_slack $total_hold_slack]

}
