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
proc memphy_perform_flexible_write_launch_timing_analysis {opcs opcname inst family scale_factors_name interface_type max_package_skew dll_length period pin_array_name timing_parameters_array_name summary_name MP_name IP_name board_name} {

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
	upvar 1 $scale_factors_name scale_factors

	set eol_reduction_factor $IP(eol_reduction_factor_write)
	set num_failing_path $IP(num_report_paths)

	set debug 0
	set result 1
	
	#################################
	# Find the clock output of the PLL
	set dk_pll_clock_id [memphy_get_output_clock_id $pins(dk_pins) "DQS output" msg_list]
	if {$dk_pll_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "$msg"
		}
		post_message -type warning "Failed to find PLL clock for pins [join [get_all_dqs_pins $pins(q_groups)]]"
		set result 0
	} else {
		set dkclksource [get_node_info -name $dk_pll_clock_id]
	}

	foreach q_group $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]
	set dm_pins $pins(dm_pins)
	set all_dq_dm_pins [ concat $all_dq_pins $dm_pins ]	
	
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
		set res_0 [report_timing -detail full_path -to [get_ports $all_dq_dm_pins] \
			-npaths $num_failing_path -panel_name $panel_name_setup -setup -disable_panel_color -quiet]
		set res_1 [report_timing -detail full_path -to [get_ports $all_dq_dm_pins] \
			-npaths $num_failing_path -panel_name $panel_name_hold -hold -disable_panel_color -quiet]
	}

	# Perform the default timing analysis to get required and arrival times
	set paths_setup [get_timing_paths -to [get_ports $all_dq_dm_pins] -npaths 400 -setup]
	set paths_hold  [get_timing_paths -to [get_ports $all_dq_dm_pins] -npaths 400 -hold]

	#####################################
	# Find Memory Calibration Improvement 
	#####################################
	
	set mp_setup_slack 0
	set mp_hold_slack  0
	if {($IP(write_deskew_mode) == "dynamic") && ($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		# Reduce the effect of tDS on the setup slack
		set mp_setup_slack [expr $MP(DS)*$t(DS)]
		
		# Reduce the effect of tDH on the hold slack
		set mp_hold_slack  [expr $MP(DH)*$t(DH)]
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

		if {$::GLOBAL_number_of_q_groups == $::GLOBAL_number_of_d_groups} {
			set first_dq_ddio_with_dk 0
			set number_of_dq_ddio_per_dk 1
			set number_of_d_pins_per_dq_ddio $::GLOBAL_d_group_size
		} else {
			set first_dq_ddio_with_dk 1
			set number_of_dq_ddio_per_dk 2
			set number_of_d_pins_per_dq_ddio [ expr $::GLOBAL_d_group_size / 2 ]
		}
		
		if {$::GLOBAL_number_of_q_groups == $::GLOBAL_number_of_dm_pins} {
			set first_dq_ddio_with_dm 0
			set number_of_dq_ddio_per_dm 1
		} else {
			set first_dq_ddio_with_dm 1
			set number_of_dq_ddio_per_dm 2
		}

		# Go over each D pin
		set group_number -1
		foreach dqpins $pins(d_groups) {
		
			set group_number [expr $group_number + 1]
			
			set dkpin [lindex $pins(dk_pins) $group_number]
			set dknpin [lindex $pins(dkn_pins) $group_number]
			set dmpins [lindex $pins(dm_pins) $group_number]
			set dqdmpins $dqpins
			if {[llength $dmpins] > 0} {
				lappend dqdmpins $dmpins
			}
			
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
			set msg_list [list]
			set leveling_delay_chain_name [memphy_traverse_to_leveling_delay_chain $dkpin msg_list]
			
			set dqs_periphery_node ${leveling_delay_chain_name}|clkin
			set dk_pin_dq_ddio_index [ expr $first_dq_ddio_with_dk + $group_number * $number_of_dq_ddio_per_dk ]

			set cps_name [memphy_traverse_to_clock_phase_select $dkpin msg_list]
			set dqs_clk_phase_select_node ${cps_name}|clkout
			set DQSpaths_max [get_path -rise_from $dqs_periphery_node -rise_to $dqs_clk_phase_select_node -nworst 1]
			set DQSpaths_min [get_path -rise_from $dqs_periphery_node -rise_to $dqs_clk_phase_select_node -nworst 1 -min_path]
			set DQSmin_of_max [memphy_min_in_collection $DQSpaths_max "arrival_time"]
			set DQSmax_of_min [memphy_max_in_collection $DQSpaths_min "arrival_time"]
			set DQSmax_of_max [memphy_max_in_collection $DQSpaths_max "arrival_time"]
			set DQSmin_of_min [memphy_min_in_collection $DQSpaths_min "arrival_time"]
`endif			

			#############################################
			# Find extra DK pessimism due to correlation (both spatial correlation and aging correlation)
			#############################################
			
			# Find paths from DK clock periphery node to beginning of output buffer
			set dqs_periphery_node ${inst}|p0|umemphy|uio_pads|dq_ddio[${dk_pin_dq_ddio_index}].ubidir_dq_dqs|altdq_dqs2_inst|phase_align_os|muxsel
			set output_buffer_node ${inst}|p0|umemphy|uio_pads|dq_ddio[${dk_pin_dq_ddio_index}].ubidir_dq_dqs|altdq_dqs2_inst|obuf_os_0|i
			
			set DQSperiphery_min [get_path -fall_from $dqs_periphery_node -rise_to $dkpin -min_path -nworst 1]
			set DQSperiphery_max [get_path -fall_from $dqs_periphery_node -rise_to $dkpin -nworst 1]
			set DQSperiphery_min_delay [memphy_min_in_collection $DQSperiphery_min "arrival_time"]
			set DQSperiphery_max_delay [memphy_max_in_collection $DQSperiphery_max "arrival_time"]
			if {($DQSperiphery_min_delay == 0) || ($DQSperiphery_max_delay == 0)} {
				return
			}
			set aiot_delay [memphy_round_3dp [expr [memphy_get_rise_aiot_delay $dkpin] * 1e9]]
			set DQSperiphery_min_delay [expr $DQSperiphery_min_delay - $aiot_delay]
			set DQSperiphery_max_delay [expr $DQSperiphery_max_delay - $aiot_delay]
			set DQSpath_pessimism  [expr $DQSperiphery_min_delay*($scale_factors(emif) + $scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
			set DQSpath_pessimism_only_eol  [expr $DQSperiphery_min_delay*($scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]

			# Go over each D pin in group
			set dq_index 0
			set dm_index 0
			
			foreach dqpin $dqdmpins {
			
				if {[lsearch -exact $dmpins $dqpin] >= 0} {
					set isdmpin 1
				} else {
					set isdmpin 0
				}
				
				# Calculate the index of the altdq_dqs2 instance exposing the data pin
				if {$isdmpin == 1} {
					set dq_ddio_index [expr $first_dq_ddio_with_dm + $group_number * $number_of_dq_ddio_per_dm]
				} else {
					set dq_ddio_index [ expr $group_number * $number_of_dq_ddio_per_dk + int($dq_index / $number_of_d_pins_per_dq_ddio) ]
					set pad_index [ expr $dq_index % $number_of_d_pins_per_dq_ddio ]
				}				
				
				# Perform the default timing analysis to get required and arrival times
				set pin_setup_slack [memphy_min_in_collection_to_name $paths_setup "slack" $dqpin]
				set pin_hold_slack  [memphy_min_in_collection_to_name $paths_hold "slack" $dqpin]

				set default_setup_slack [min $default_setup_slack $pin_setup_slack]
				set default_hold_slack  [min $default_hold_slack  $pin_hold_slack]		

				if { $debug } {
					puts "$group_number $dkpin $dqpin $pin_setup_slack $pin_hold_slack"
				}

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
				
				set msg_list [list]
				set leveling_delay_chain_name [memphy_traverse_to_leveling_delay_chain $dqpin msg_list]
				
				set dq_periphery_node ${leveling_delay_chain_name}|clkin
							
				set dq_clk_phase_select_node ${inst}|p0|umemphy|uio_pads|dq_ddio[${dq_ddio_index}].ubidir_dq_dqs|altdq_dqs2_inst|dq_select*|clkout

				set DQpaths_max [get_path -rise_from $dq_periphery_node -rise_to $dq_clk_phase_select_node -nworst 1]
				set DQpaths_min [get_path -rise_from $dq_periphery_node -rise_to $dq_clk_phase_select_node -nworst 1 -min_path]
				set DQmin_of_max [memphy_min_in_collection $DQpaths_max "arrival_time"]
				set DQmax_of_min [memphy_max_in_collection $DQpaths_min "arrival_time"]
				set DQmax_of_max [memphy_max_in_collection $DQpaths_max "arrival_time"]
				set DQmin_of_min [memphy_min_in_collection $DQpaths_min "arrival_time"]
				if {[expr abs(($DQSmax_of_min - $DQSmin_of_max) - ($DQmax_of_min - $DQmin_of_max))] < 0.05} {
					set extra_ccpp_DQS [expr $DQSmin_of_max - $DQSmax_of_min]
					set extra_ccpp_DQ  [expr $DQmin_of_max  - $DQmax_of_min]
					set extra_ccpp [expr [min $extra_ccpp_DQS $extra_ccpp_DQ] + $pll_ccpp]
				} else {
					set extra_ccpp $pll_ccpp
				}
`else
				set extra_cppp $pll_cppp
`endif				
				
				set pin_setup_slack [expr $pin_setup_slack + $extra_ccpp]
				set pin_hold_slack [expr $pin_hold_slack + $extra_ccpp]

				########################################
				# Add the memory calibration improvement
				########################################
				
				set pin_setup_slack [expr $pin_setup_slack + $mp_setup_slack]
				set pin_hold_slack [expr $pin_hold_slack + $mp_hold_slack]
		
				############################################
				# Find extra DQ pessimism due to correlation
				# (both spatial correlation and aging correlation)
				############################################
				
				# Find the DQ clock node before the periphery
				if {$isdmpin == 1} {
					set dq_periphery_node ${inst}|p0|umemphy|uio_pads|dq_ddio[$dq_ddio_index].ubidir_dq_dqs|altdq_dqs2_inst|extra_output_pad_gen[$dm_index].ddio_out|muxsel
					set output_buffer_node_dq ${inst}|p0|umemphy|uio_pads|dq_ddio[$dq_ddio_index].ubidir_dq_dqs|altdq_dqs2_inst|extra_output_pad_gen[$dm_index].obuf_1|i
				} else {
					set dq_periphery_node ${inst}|p0|umemphy|uio_pads|dq_ddio[*].ubidir_dq_dqs|altdq_dqs2_inst|output_path_gen[*].ddio_out|muxsel
					set output_buffer_node_dq ${inst}|p0|umemphy|uio_pads|dq_ddio[$dq_ddio_index].ubidir_dq_dqs|altdq_dqs2_inst|pad_gen[$pad_index].data_out|i
				}
				
				set DQperiphery_min [get_path -rise_from $dq_periphery_node -rise_to $dqpin -min_path -nworst 1]
				set DQperiphery_max [get_path -rise_from $dq_periphery_node -rise_to $dqpin -nworst 1]
				set DQperiphery_min_delay [memphy_min_in_collection $DQperiphery_min "arrival_time"]
				set DQperiphery_max_delay [memphy_max_in_collection $DQperiphery_max "arrival_time"]
				if {($DQperiphery_min_delay == 0) || ($DQperiphery_max_delay == 0)} {
					return
				}
				set aiot_delay [memphy_round_3dp [expr [memphy_get_rise_aiot_delay $dqpin] * 1e9]]
				set DQperiphery_min_delay [expr $DQperiphery_min_delay - $aiot_delay]
				set DQperiphery_max_delay [expr $DQperiphery_max_delay - $aiot_delay]
				set DQpath_pessimism  [expr $DQperiphery_min_delay*($scale_factors(emif) + $scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
				set DQpath_pessimism_only_eol  [expr $DQperiphery_min_delay*($scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
				
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
					set dqs_width [llength $dqpins]
					if {$dqs_width <= 9} {
						set pin_setup_slack [expr $pin_setup_slack + 0.35*$total_DQ_DQS_pessimism]
						set pin_hold_slack  [expr $pin_hold_slack  + 0.35*$total_DQ_DQS_pessimism]
					} else {
						set pin_setup_slack [expr $pin_setup_slack + $DQpath_pessimism_only_eol]
						set pin_hold_slack  [expr $pin_hold_slack  + $DQSpath_pessimism_only_eol]
					}
				}
				

				set setup_slack [min $setup_slack $pin_setup_slack]
				set hold_slack  [min $hold_slack $pin_hold_slack]
				
				if { $debug } {
					puts "                                $extra_ccpp $DQSpath_pessimism $DQpath_pessimism ($pin_setup_slack $pin_hold_slack $setup_slack $hold_slack)" 
				}

				if {$isdmpin == 0} {
					set dq_index [expr $dq_index + 1]
				} else {
					set dm_index [expr $dm_index + 1]
				}
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
		set extra_shift [expr $board(intra_DQS_group_skew) + [memphy_round_3dp [expr (1.0-$t9_vt_variation_percent)*$t(WL_PSE)]]]
		
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
		set t9_variation [expr [min [expr $offset_from_90 + (2*$board(intra_DQS_group_skew) + $max_package_skew + $t(WL_PSE))] [max $max_write_deskew_setup $max_write_deskew_hold]]*2*$t9_vt_variation_percent]
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
			set t(wru_fpga_uncertainty_s) [expr $t(CK)/4 - $default_setup_slack - $t(wru_output_max_delay_external) - $extra_ccpp]
			set t(wru_fpga_uncertainty_h) [expr $t(CK)/4 - $default_hold_slack  - $t(wru_output_min_delay_external) - $extra_ccpp]
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
			set t(wru_fpga_uncertainty_s) [expr $t(CK)/4 - $default_setup_slack - $t(wru_output_max_delay_external) - $pessimism_setup]
			set t(wru_fpga_uncertainty_h) [expr $t(CK)/4 - $default_hold_slack  - $t(wru_output_min_delay_external) - $pessimism_hold]
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


#############################################################
# Read Timing Analysis
#############################################################
proc memphy_perform_flexible_read_capture_timing_analysis {opcs opcname inst family scale_factors_name io_std interface_type max_package_skew dqs_phase period all_dq_pins pin_array_name timing_parameters_array_name summary_name MP_name IP_name board_name fpga_name} {

	################################################################################
	# This timing analysis covers the read timing constraints.  It includes support 
	# for uncalibrated and calibrated read paths.  The analysis starts by running a 
	# conventional timing analysis for the read paths and then adds support for 
	# topologies and IP options which are unique to source-synchronous data transfers.  
	# The support for further topologies includes correlation between DQ and QK signals
	# The support for further IP includes support for read-deskew calibration.
	# 
	# During read deskew calibration, the IP will adjust delay chain settings along 
	# each signal path to reduce the skew between DQ pins and to centre align the QK 
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
	upvar 1 $scale_factors_name scale_factors
	
	set eol_reduction_factor $IP(eol_reduction_factor_read)
	set num_failing_path $IP(num_report_paths)

	# Debug switch. Change to 1 to get more run-time debug information
	set debug 0	
	set result 1


	if {$IP(read_deskew_mode) == "dynamic"} {
		set panel_name_setup  "Before Calibration \u0028Negative slacks are OK\u0029||$inst Read Capture \u0028Before Calibration\u0029 (setup)"
		set panel_name_hold   "Before Calibration \u0028Negative slacks are OK\u0029||$inst Read Capture \u0028Before Calibration\u0029 (hold)"
	} else {
		set panel_name_setup  "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Read Capture CQ (setup)"
		set panel_name_hold   "Before Spatial Pessimism Removal \u0028Negative slacks are OK\u0029||$inst Read Capture CQ (hold)"
	}

	#####################################################################
	# Default Read Analysis
	set before_calibration_reporting [get_ini_var -name "qsta_enable_before_calibration_ddr_reporting"]
	if {![string equal -nocase $before_calibration_reporting off]} {
		set res_0 [report_timing -detail full_path -from [get_ports $all_dq_pins] \
			-to_clock [get_clocks $pins(qk_pins)] -npaths $num_failing_path -panel_name $panel_name_setup -setup -disable_panel_color -quiet]
		set res_1 [report_timing -detail full_path -from [get_ports $all_dq_pins] \
			-to_clock [get_clocks $pins(qk_pins)] -npaths $num_failing_path -panel_name $panel_name_hold -hold -disable_panel_color -quiet]
	}	

	set paths_setup [get_timing_paths -from [get_ports $all_dq_pins] -to_clock [get_clocks $pins(qk_pins)] -npaths 400 -setup]
	set paths_hold  [get_timing_paths -from [get_ports $all_dq_pins] -to_clock [get_clocks $pins(qk_pins)] -npaths 400 -hold]

	#####################################
	# Find Memory Calibration Improvement
	#####################################
	
	set mp_setup_slack 0
	set mp_hold_slack  0
	if {($IP(read_deskew_mode) == "dynamic") && ($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		# Reduce the effect of tQKQ_max on the setup slack
		set mp_setup_slack [expr $MP(QKQ_max)*$t(QKQ_max)]

		# Reduce the effect of tQKQ_min on the hold slack
		set mp_hold_slack  [expr -$MP(QKQ_min)*$t(QKQ_min)]
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
			
			set qkpin [lindex $pins(qk_pins) $group_number]
			set qknpin [lindex $pins(qkn_pins) $group_number]
			
			#############################################
			# Find extra QK pessimism due to correlation
			# (both spatial correlation and aging correlation)
			#############################################

			# Find paths from output of the input buffer to the end of the QK periphery
			set input_buffer_node "${inst}|p0|umemphy|uio_pads|dq_ddio[$group_number].ubidir_dq_dqs|altdq_dqs2_inst|strobe_in|o"
			set DQScapture_node [list "${prefix}|*dq_ddio[$group_number].ubidir_dq_dqs|*input_path_gen[*].capture_reg~FF" ]

			set DQSperiphery_min [get_path -rise_from $input_buffer_node -rise_to $DQScapture_node -min_path -nworst 1]
			set DQSperiphery_max [get_path -rise_from $input_buffer_node -rise_to $DQScapture_node -nworst 1]
			set DQSperiphery_min_delay [memphy_min_in_collection $DQSperiphery_min "arrival_time"]
			set DQSperiphery_max_delay [memphy_max_in_collection $DQSperiphery_max "arrival_time"]
			set DQSpath_pessimism  [expr ($DQSperiphery_min_delay - 90.0/360*$t(CK))*($scale_factors(emif) + $scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
			set DQSpath_pessimism_only_eol  [expr ($DQSperiphery_min_delay - 90.0/360*$t(CK))*($scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
			
			# Go over each DQ pin in group
			set q_index 0
			foreach qpin $qpins {
				regexp {\d+} $qpin q_pin_index
			
				# Perform the default timing analysis to get required and arrival times
				set pin_setup_slack [memphy_min_in_collection_from_name $paths_setup "slack" $qpin]
				set pin_hold_slack  [memphy_min_in_collection_from_name $paths_hold "slack" $qpin]

				set default_setup_slack [min $default_setup_slack $pin_setup_slack]
				set default_hold_slack  [min $default_hold_slack  $pin_hold_slack]		

				if { $debug } {
					puts "READ: $group_number $qkpin $qpin $pin_setup_slack $pin_hold_slack (MP: $mp_setup_slack $mp_hold_slack)"
				}
			
				###############################
				# Add the memory calibration improvement
				###############################
				
				set pin_setup_slack [expr $pin_setup_slack + $mp_setup_slack]
				set pin_hold_slack [expr $pin_hold_slack + $mp_hold_slack]
				
				############################################
				# Find extra DQ pessimism due to correlation
				# (both spatial correlation and aging correlation)
				############################################
				
				# Find paths from output of the input buffer to the end of the DQ periphery
				set input_buffer_node_dq ${inst}|p0|umemphy|uio_pads|dq_ddio[$group_number].ubidir_dq_dqs|altdq_dqs2_inst|pad_gen[$q_index].data_in|o
				set DQcapture_node [list "${prefix}|*dq_ddio[$group_number].ubidir_dq_dqs|*input_path_gen[$q_index].capture_reg~FF" ]

				set DQperiphery_min [get_path -rise_from $input_buffer_node_dq -rise_to $DQScapture_node -min_path -nworst 1]
				set DQperiphery_max [get_path -rise_from $input_buffer_node_dq -rise_to $DQScapture_node -nworst 1]
				set DQperiphery_min_delay [memphy_min_in_collection $DQperiphery_min "arrival_time"]
				set DQperiphery_max_delay [memphy_max_in_collection $DQperiphery_max "arrival_time"]
				set DQpath_pessimism  [expr $DQperiphery_min_delay*($scale_factors(emif) + $scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
				set DQpath_pessimism_only_eol  [expr $DQperiphery_min_delay*($scale_factors(eol) - $scale_factors(eol)/$eol_reduction_factor)]
				
				########################################
				# Merge current slacks with other slacks
				########################################

				# If read deskew is available, the setup and hold slacks for this pin will be equal
				#   and can also remove the extra QK pessimism removal
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
					# For uncalibrated calls, there is some spatial correlation between DQ and QK signals, so remove
					# some of the pessimism
					set total_DQ_DQS_pessimism [expr $DQSpath_pessimism + $DQpath_pessimism]
					set dqs_width [llength $qpins]
					if {$dqs_width <= 9} {
						set pin_setup_slack [expr $pin_setup_slack + 0.35*$total_DQ_DQS_pessimism]
						set pin_hold_slack  [expr $pin_hold_slack  + 0.35*$total_DQ_DQS_pessimism]
					} else {
						set pin_setup_slack [expr $pin_setup_slack + $DQpath_pessimism_only_eol]
						set pin_hold_slack  [expr $pin_hold_slack  + $DQSpath_pessimism_only_eol]
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
		set extra_shift [expr $board(intra_DQS_group_skew) + [memphy_round_3dp [expr (1.0-$t1_vt_variation_percent)*$fpga(tDQS_PSERR)]]]
		
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
		set dqs_period [memphy_get_dqs_period $pins(qk_pins) ]
		set offset_from_90 [expr abs(90/360.0*$period - $dqs_phase/360.0*$dqs_period)]
		if {$IP(num_ranks) == 1} {
			set t1_variation [expr [min [expr $offset_from_90 + [max [expr $MP(QKQ_max)*$t(QKQ_max)] [expr -$MP(QKQ_min)*$t(QKQ_min)]] + 2*$board(intra_DQS_group_skew) + $max_package_skew + $fpga(tDQS_PSERR)] [max $max_read_deskew_setup $max_read_deskew_hold]]*2*$t1_vt_variation_percent*0.75]
		} else {
			set t1_variation [expr [min [expr $offset_from_90 + 2*$board(intra_DQS_group_skew) + $max_package_skew + $fpga(tDQS_PSERR)] [max $max_read_deskew_setup $max_read_deskew_hold]]*2*$t1_vt_variation_percent*0.75]
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
			set t(rdu_fpga_uncertainty_s) [expr $t(CK)/4 - $default_setup_slack - $t(rdu_input_max_delay_external)]
			set t(rdu_fpga_uncertainty_h) [expr $t(CK)/4 - $default_hold_slack  - $t(rdu_input_min_delay_external)]
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
			set t(rdu_fpga_uncertainty_s) [expr $t(CK)/4 - $default_setup_slack - $t(rdu_input_max_delay_external) - $pessimism_setup]
			set t(rdu_fpga_uncertainty_h) [expr $t(CK)/4 - $default_hold_slack  - $t(rdu_input_min_delay_external) - $pessimism_hold]
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
		set core_regs [remove_from_collection [get_registers $inst|*] [get_registers $pins(read_capture_ddio)]]
	} else {
		set core_regs [remove_from_collection [get_registers $prefix|*] [get_registers $pins(read_capture_ddio)]]
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
	set ext_regs [remove_from_collection $ext_regs [get_registers $pins(read_capture_ddio)]]
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

proc memphy_perform_ac_analyses {opcs opcname inst scale_factors_name pin_array_name timing_parameters_array_name summary_name IP_name} {

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
	upvar 1 $scale_factors_name scale_factors

	set num_failing_path $IP(num_report_paths)
	set eol_reduction_factor $IP(eol_reduction_factor_addr)

	set add_pins $pins(add_pins)
	set ba_pins $pins(ba_pins)
	set cmd_pins $pins(cmd_pins)
	set ac_pins [ concat $add_pins $ba_pins $cmd_pins ]

	set entity_names_on [ memphy_are_entity_names_on ]

	set prefix [ string map "| |*:" $inst ]
	set prefix "*:$prefix"

	# Address Command
	set res_0 [report_timing -detail full_path -to $ac_pins -npaths $num_failing_path -panel_name "$inst Address Command (setup)" -setup]
	set res_1 [report_timing -detail full_path -to $ac_pins -npaths $num_failing_path -panel_name "$inst Address Command (hold)" -hold]
	lappend summary [list $opcname 0 "Address Command ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]

	# DK vs CK
	if {$IP(write_deskew_mode) == "static" } {
		set res_0 [report_timing -detail full_path -to [get_ports [concat $pins(dk_pins) $pins(dkn_pins)]] -npaths $num_failing_path -panel_name "$inst DK vs CK (setup)" -setup]
		set res_1 [report_timing -detail full_path -to [get_ports [concat $pins(dk_pins) $pins(dkn_pins)]] -npaths $num_failing_path -panel_name "$inst DK vs CK (hold)" -hold]
		lappend summary [list $opcname 0 "DK vs CK ($opcname)" [lindex $res_0 1] [lindex $res_1 1] [lindex $res_0 0] [lindex $res_1 0]]	
	}
}

proc memphy_perform_calibrated_dk_vs_ck_timing_analysis {opcs opcname instname family period dll_length interface_type tJITper tJITdty tDCD pll_steps pin_array_name timing_parameters_array_name summary_name  MP_name IP_name SSN_name board_name ISI_parameters_name} {

	###############################################################################
	# The DK vs CK concerns meeting the RLDRAM requirements between DK 
	# and CK such as tDKCK parameters are met.  The DK vs CK alignment is achieved through 
	# calibration by changing the delay of the DK signal and finding the lowest and
	# and higtest delays that allow writes to complete and then picking a midpoint
	# delay. Because of this, the exact length of the DK and CK traces 
	# don't affect the timing analysis, and the calibration will remove any static 
	# offset from the rest of the path too.  With static offset removed, the 
	# remaining uncertainties with be limited to mostly VT variation, and jitter.
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $IP_name IP
	upvar 1 $pin_array_name pins
	upvar 1 $board_name board	
	upvar 1 $MP_name MP
	upvar 1 $SSN_name SSN
	upvar 1 $ISI_parameters_name ISI		
	
	################################
	# tDKCK specification
	
	# Ideal setup and hold slacks is the tDKCK specification
	set tCKDK_max $t(CKDK_max)
	set tCKDK_min [expr 0 - $t(CKDK_min)]
	if {($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		set tCKDK_max [expr $t(CK)/2 - ($t(CK)/2 - $tCKDK_max)*(1.0-$MP(DKCK))]
		set tCKDK_min [expr $t(CK)/2 - ($t(CK)/2 - $tCKDK_min)*(1.0-$MP(DKCK))]
	} elseif {$IP(mp_calibration) == 1} {
		set tCKDK_max [expr $t(CK)/2 - ($t(CK)/2 - $tCKDK_max)*(1.0-$MP(DKCK)/2)]
		set tCKDK_min [expr $t(CK)/2 - ($t(CK)/2 - $tCKDK_min)*(1.0-$MP(DKCK)/2)]
	}
	set setup_slack $tCKDK_max
	set hold_slack  $tCKDK_min
	
	# Remove Multirank board skew effects - Calibration will calibrate to the average of multiple ranks
	set max_calibration_offset 0
	if {$IP(num_ranks) > 1} {
		set max_calibration_offset [expr abs($board(maxCK_DK_skew) - $board(minCK_DK_skew))]
		set setup_slack [expr $setup_slack - $max_calibration_offset - $ISI(DQS)/2]
		set hold_slack  [expr $hold_slack  - $max_calibration_offset - $ISI(DQS)/2]
	}		
	
	# Remove the uncertainty due to VT variations in T10
	set max_t9_delay 0.350
	set t9_vt_variation_percent [get_float_table_node_delay -src {DELAYCHAIN_T9} -dst {VTVARIATION} -parameters [list IO $interface_type]]
	set t9_vt_variation [expr $max_t9_delay*$t9_vt_variation_percent*2]
	set setup_slack [expr $setup_slack - $t9_vt_variation]
	set hold_slack  [expr $hold_slack  - $t9_vt_variation]
	
	# Remove the jitter on the clock out to the memory (CK and DQS could be in worst-case directions) 
	set setup_slack [expr $setup_slack - $tJITper/2 - $tJITper/2]
	set hold_slack  [expr $hold_slack  - $tJITper/2 - $tJITper/2]
	
	# Remove SSN effects
	set setup_slack [expr $setup_slack - $SSN(pushout_o) - $SSN(pullin_o)]
	set hold_slack  [expr $hold_slack  - $SSN(pushout_o) - $SSN(pullin_o)]	
	
	# Remove the worst-case quantization uncertainty
	set setup_slack [expr $setup_slack - $IP(quantization_T9)/2]
	set hold_slack [expr $hold_slack - $IP(quantization_T9)/2]

	# This section of the analysis tries to make sure that the CK path is longer than the DK path so that we
	# can calibrate

	set first_device_slack [memphy_min_in_collection [get_timing_paths -to [get_ports [concat $pins(dk_pins) $pins(dkn_pins)]] -setup] "slack"] 

	if {$first_device_slack < 0} {
		post_message -type warning "DK to CK calibration may not be able to calibrate due to longer delay to DK pins compared to CK pins"
		set setup_slack $first_device_slack
		set hold_slack 0
	} else {
		set setup_slack [min $setup_slack $first_device_slack]
	}
	
	set last_device_slack  [memphy_min_in_collection [get_timing_paths -to [get_ports [concat $pins(dk_pins) $pins(dkn_pins)]] -hold] "slack"]
	
	if {$last_device_slack < 0} {
		post_message -type warning "DK to CK calibration may not be able to calibrate due to longer delay to CK pins compared to DK pins"
		set hold_slack $last_device_slack
		set setup_slack 0
	} else {
		set hold_slack [min $hold_slack $last_device_slack]
	}		
		
	lappend summary [list $opcname 0 "DK vs CK ($opcname)" $setup_slack $hold_slack]
	
}


#############################################################
# Bus Turnaround Time Analysis
#############################################################

proc memphy_perform_flexible_bus_turnaround_time_analysis {opcs opcname instname family period dll_length interface_type tJITper tJITdty tDCD outputDQSpathjitter outputDQSpathjitter_setup_prop pll_steps pin_array_name timing_parameters_array_name summary_name  MP_name IP_name SSN_name board_name ISI_parameters_name} {

	###############################################################################
	# The bus-turnaround time analysis concerns making sure there is no contention on
	# on the DQ bus when a read command is followed by a write command.  When a read
	# command is issued, some cycles later the memory takes control of the DQS bus and
	# starts sending back data to the controller.  If the controller issues a write 
	# command too early then the read command data may not have fully read and there 
	# may be contention on the bus.  This analysis determines how much margin there 
	# is on the switchover time and if the slack is negative, either the controller's 
	# bus turnaround time must be increased (which reduces effeciency), or the 
	# absolute delays on the board traces must be reduced.
	###############################################################################

	#######################################
	# Need access to global variables
	upvar 1 $summary_name summary
	upvar 1 $timing_parameters_array_name t
	upvar 1 $IP_name IP
	upvar 1 $pin_array_name pins
	upvar 1 $board_name board	
	upvar 1 $MP_name MP
	upvar 1 $SSN_name SSN
	upvar 1 $ISI_parameters_name ISI
	
	# Derived parameters
	set burst_length $t(BL)
	set write_read_latencies_difference 1

	######################################################################
	# Find the maximum delay of the CK issuing a read command followed by 
	# read data coming back
	
	# Maximum clock delay
	set ac_hold [get_timing_paths -to $pins(add_pins) -hold -npaths 100]
	set i 0
	set max_dly 0
	foreach_in_collection path $ac_hold {
		if {$i == 0} {
			set max_dly [expr [get_path_info $path -required_time] - [get_path_info $path -latch_time]]
		} else {
			set temp [expr [get_path_info $path -required_time] - [get_path_info $path -latch_time]]
			if {$temp > $max_dly} {
				set max_dly $temp
			} 
		}
		set i [expr $i + 1]
	}
	
	# SSO and Jitter pushout on clock
	set max_dly [expr $max_dly + $SSN(pushout_o) + $tJITper/2]
	
	# CK Board delay
	set max_dly [expr $max_dly + $board(abs_max_CK_delay)]
	
	# Read Latency and Burst Lenght
	set max_dly [expr $max_dly + ($burst_length/2)*$t(CK)]
	
	# DQS Board delay
	set max_dly [expr $max_dly + $board(abs_max_DK_delay)]
	
	# Time for DQS to go high impedance relative to the CK
	set max_dly [expr $max_dly + $t(CKQK_max)] 
	
	# SSI pushout on DQS
	set max_dly [expr $max_dly + $SSN(pushout_i)]
	
	######################################################################
	# Find the minimum delay of the issuing a write command after read
	# command has been issued and the FPGA taking hold of the DQS trace
	
	# Find all DQ/DM pins
	set q_groups [list]
	foreach q_group $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]
	set dm_pins $pins(dm_pins)
	set all_dq_dm_pins [ concat $all_dq_pins $dm_pins ]		

	# Get the minimum delay to the output write DQ data 	
	set write_hold   [get_timing_paths -to $all_dq_dm_pins -hold -npaths 100]
	set i 0
	set min_dly 0
	foreach_in_collection path $write_hold {
		if {$i == 0} {
			set min_dly [expr [get_path_info $path -arrival_time] - [get_path_info $path -launch_time]]
		} else {
			set temp [expr [get_path_info $path -arrival_time] - [get_path_info $path -launch_time]]
			if {$temp < $min_dly} {
				set min_dly $temp
			} 
		}
		set i [expr $i + 1]
	}

	# SSO pullin on write data
	set min_dly [expr $min_dly - $SSN(pullin_o)]
	
	# Jitter and other effects on write data
	set min_dly [expr $min_dly - $outputDQSpathjitter*(1.0-$outputDQSpathjitter_setup_prop)]
	
	# Quantization error on aligning DK and CK
	set min_dly [expr $min_dly - $IP(quantization_WL)]
	
	# Difference in board delay
	set min_dly [expr $min_dly - $board(minCK_DK_skew)] 
	
	# Delay between the read command and write command 
	set num_clocks_read_to_write [expr $t(rd_to_wr_turnaround) - $write_read_latencies_difference]
`ifdef IPTCL_READ_FIFO_HALF_RATE
	if {[expr $num_clocks_read_to_write % 2] == 1} {
		incr num_clocks_read_to_write
	}
`endif
	set num_clocks_read_to_write [expr $num_clocks_read_to_write + $burst_length/2]
	set min_dly [expr $min_dly + $num_clocks_read_to_write*$t(CK)]
	
	# Delay to account for the difference between write and read latencies
	set min_dly [expr $min_dly + $write_read_latencies_difference*$t(CK)]
	
	# Adjustment for when the DQ is driven compared to CK
	set min_dly [expr $min_dly - 0.25*$t(CK)]
	
	# Adjustment for when the OCT is enabled (one cycle berfore DQ) 
	set min_dly [expr $min_dly - $t(CK)]	

	set setup_slack [expr $min_dly - $max_dly]
	set hold_slack "--"

	lappend summary [list $opcname 0 "Bus Turnaround Time ($opcname)" $setup_slack $hold_slack]
	
}


proc memphy_perform_resync_timing_analysis {opcs opcname inst fbasename family scale_factors_name io_std interface_type period pin_array_name timing_parameters_array_name summary_name MP_name IP_name board_name fpga_name SSN_name} {

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
	upvar 1 $scale_factors_name scale_factors
	
	set num_paths 5000

	set prefix [ string map "| |*:" $inst ]
	set prefix "*:$prefix"

	#######################################
	# Node names
	set dqs_pins $pins(qk_pins)

	set fifo_in ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard*INPUT_DFF*
	set fifo_data_wr_clk_domain ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard*WRITE_LOAD_DFF*
	set fifo_data_rd_clk_domain ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard*READ_LOAD_DFF*
	set fifo_out ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|dataout[*]
	set fifo_wr_address ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|*WRITE_ADDRESS_DFF*
	set fifo_rd_address ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|*READ_ADDRESS_DFF*
	set fifo_rd_address_output ${prefix}*${fbasename}_read_fifo_hard:read_buffering[*].uread_read_fifo_hard|*READ_ADDRESS_OUTPUT_DFF*	
	
	#######################################
	# Paths
	set max_DQS_to_fifo_paths  [get_path -from $dqs_pins -to $fifo_in -npaths $num_paths -nworst 1]
	set min_DQS_to_fifo_paths  [get_path -from $dqs_pins -to $fifo_in -npaths $num_paths -min_path  -nworst 1]
	
	set max_fifo_to_rd_clk_domain_paths [get_path -from $fifo_data_wr_clk_domain -to $fifo_data_rd_clk_domain -npaths $num_paths  -nworst 1]
	set min_fifo_to_rd_clk_domain_paths [get_path -from $fifo_data_wr_clk_domain -to $fifo_data_rd_clk_domain -npaths $num_paths -min_path  -nworst 1]
	
	set max_DQS_to_wr_address_paths [get_path -from $dqs_pins -to $fifo_wr_address -npaths $num_paths -nworst 1]
	set min_DQS_to_wr_address_paths [get_path -from $dqs_pins -to $fifo_wr_address -npaths $num_paths -min_path  -nworst 1]
	
	set max_rd_address_to_rd_data_paths [get_path -from $fifo_rd_address -to $fifo_rd_address_output -npaths $num_paths -nworst 1]
	set min_rd_address_to_rd_data_paths [get_path -from $fifo_rd_address -to $fifo_rd_address_output -npaths $num_paths -min_path -nworst 1]
	
	set max_dqs_common_to_fifo [memphy_max_in_collection [get_path -from $dqs_pins -to $fifo_in -nworst 1] "arrival_time"]
	
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
	foreach_in_collection register [get_keepers $fifo_in] {
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
	foreach_in_collection register [get_keepers $fifo_wr_address] {
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
	set entity_names_on [ memphy_are_entity_names_on ]	
	set fly_by_wire 0
`ifdef IPTCL_FULL_RATE
	set min_latency 2
	set max_latency 3
	set fifo_depth 16
`else
	set min_latency 1
	set max_latency 2.5
	set fifo_depth 8
`endif	
	if {($IP(mp_calibration) == 1) && ($IP(num_ranks) == 1)} {
		set mp_QKQ_max [expr $MP(QKQ_max)*$t(QKQ_max)]

		set mp_QKQ_min [expr -$MP(QKQ_min)*$t(QKQ_min)]
	} else {
		set mp_QKQ_max 0
		set mp_QKQ_min 0
	}
	set hf_DQS_variation [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO PHY_SHORT] -in_fitter -period $period]/1000.0*2/2]
	set hf_DQS_variation [expr $hf_DQS_variation + $SSN(pushout_o) + $SSN(pullin_o) + $t(QKQ_max) - $t(QKQ_min) - $mp_QKQ_max - $mp_QKQ_min + $SSN(pullin_i)]
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
	
	set regs [get_keepers $fifo_rd_address_output]

	foreach_in_collection reg $regs {

		set reg_name [get_register_info -name $reg]

		if {[info exists max_rd_address_to_rd_data_paths_max($reg_name)]==0} {
			# not all registers have arcs for the hard read fifo, depending upon full/half rate
			continue
		}
		
		regsub {READ_ADDRESS_OUTPUT_DFF} $reg_name READ_LOAD_DFF reg_name_fifo_data_rd_clk_domain
		regexp {read_buffering\[(\d+)\]\.uread_read_fifo_hard} $reg_name match dqs_group_number
		set dqs_pin [lindex $pins(qk_pins) $dqs_group_number]
      if {!([info exists max_DQS_to_fifo_paths_max($dqs_pin)] &&
		     [info exists min_DQS_to_fifo_paths_min($dqs_pin)] &&
		     [info exists max_fifo_to_rd_clk_domain_paths_max($reg_name_fifo_data_rd_clk_domain)] &&
		     [info exists min_fifo_to_rd_clk_domain_paths_min($reg_name_fifo_data_rd_clk_domain)] &&
		     [info exists max_rd_address_to_rd_data_paths_max($reg_name)] &&
		     [info exists min_rd_address_to_rd_data_paths_min($reg_name)])} {
         post_message -type error "Paths not found for resync analysis."
         return 1
      }	
		set max_DQS_to_fifo $max_DQS_to_fifo_paths_max($dqs_pin)
		set min_DQS_to_fifo $min_DQS_to_fifo_paths_min($dqs_pin)
		set max_fifo_to_rd_clk_domain $max_fifo_to_rd_clk_domain_paths_max($reg_name_fifo_data_rd_clk_domain)
		set min_fifo_to_rd_clk_domain $min_fifo_to_rd_clk_domain_paths_min($reg_name_fifo_data_rd_clk_domain)
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
