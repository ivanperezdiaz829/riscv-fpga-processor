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
# This file contains the timing constraints for the UniPHY memory
# interface.
#    * The timing parameters used by this file are assigned
#      in the memphy_timing.tcl script.
#    * The helper routines are defined in memphy_pin_map.tcl
#
# NOTE
# ----

set script_dir [file dirname [info script]]

source "$script_dir/memphy_parameters.tcl"
source "$script_dir/memphy_timing.tcl"
source "$script_dir/memphy_pin_map.tcl"

load_package ddr_timing_model

set synthesis_flow 0
set sta_flow 0
set fit_flow 0
if { $::TimeQuestInfo(nameofexecutable) == "quartus_map" } {
	set synthesis_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_sta" } {
	set sta_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_fit" } {
	set fit_flow 1
}

####################
#                  #
# GENERAL SETTINGS #
#                  #
####################

# This is a global setting and will apply to the whole design.
# This setting is required for the memory interface to be
# properly constrained.
derive_clock_uncertainty

# Debug switch. Change to 1 to get more run-time debug information
set debug 0

# All timing requirements will be represented in nanoseconds with up to 3 decimal places of precision
set_time_format -unit ns -decimal_places 3

# Determine if entity names are on
set entity_names_on [ memphy_are_entity_names_on ]

##################
#                #
# QUERIED TIMING #
#                #
##################

set io_standard "$::GLOBAL_io_standard CLASS I"

# This is the peak-to-peak jitter on the whole read capture path
set DQSpathjitter [expr [get_micro_node_delay -micro DQDQS_JITTER -parameters [list IO] -in_fitter]/1000.0]

# This is the proportion of the DQ-DQS read capture path jitter that applies to setup
set DQSpathjitter_setup_prop [expr [get_micro_node_delay -micro DQDQS_JITTER_DIVISION -parameters [list IO] -in_fitter]/100.0]

# This is the peak-to-peak jitter on the whole write path
set outputDQSpathjitter [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/1000.0]

# This is the proportion of the DQ-DQS write path jitter that applies to setup
set outputDQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER_DIVISION -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/100.0]

##################
#                #
# DERIVED TIMING #
#                #
##################

# These parameters are used to make constraints more readeable

# Half of memory clock cycle
set half_period [ memphy_round_3dp [ expr $t(CK) / 2.0 ] ]

# Half of reference clock
set ref_half_period [ memphy_round_3dp [ expr $t(refCK) / 2.0 ] ]

# Minimum distance between two consecutive edges of CK (positive to negative or viceversa)
set t(QKHQKnH) [ memphy_round_3dp [ expr $t(QKH) * $t(CK) * $t(CKH)] ]

# Minimum delay on data output pins
set t(wru_output_min_delay_external) [expr $t(DH) + $board(intra_DQS_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 - $board(data_DK_skew)]
set t(wru_output_min_delay_internal) [expr $t(WL_DCD) + $t(WL_PSE) + $t(WL_JITTER)*(1.0-$t(WL_JITTER_DIVISION)) + $SSN(rel_pullin_o)]
set data_output_min_delay [ memphy_round_3dp [ expr - $t(wru_output_min_delay_external) - $t(wru_output_min_delay_internal)]]

# Maximum delay on data output pins
set t(wru_output_max_delay_external) [expr $t(DS) + $board(intra_DQS_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 + $board(data_DK_skew)]
set t(wru_output_max_delay_internal) [expr $t(WL_DCD) + $t(WL_PSE) + $t(WL_JITTER)*$t(WL_JITTER_DIVISION) + $SSN(rel_pushout_o)]
set data_output_max_delay [ memphy_round_3dp [ expr $t(wru_output_max_delay_external) + $t(wru_output_max_delay_internal)]]

# Maximum delay on data input pins
set t(rdu_input_max_delay_external) [expr $t(QKQ_max) + $board(intra_DQS_group_skew) + $board(data_QK_skew)]
set t(rdu_input_max_delay_internal) [expr $DQSpathjitter*$DQSpathjitter_setup_prop + $SSN(rel_pushout_i)]
set data_input_max_delay [ memphy_round_3dp [ expr $t(rdu_input_max_delay_external) + $t(rdu_input_max_delay_internal) ]]

# Minimum delay on data input pins
set t(rdu_input_min_delay_external) [expr -$t(QKQ_min) + $board(intra_DQS_group_skew) - $board(data_QK_skew)]
set t(rdu_input_min_delay_internal) [expr $t(DCD) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $SSN(rel_pullin_i)]
set data_input_min_delay [ memphy_round_3dp [ expr - $t(rdu_input_min_delay_external) - $t(rdu_input_min_delay_internal) ]]

# Minimum delay on address and command paths
set ac_min_delay [ memphy_round_3dp [ expr - $t(AH) -$fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) - $ISI(addresscmd_hold) ]]

# Maximum delay on address and command paths
set ac_max_delay [ memphy_round_3dp [ expr $t(AS) +$fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) + $ISI(addresscmd_setup) ]]

if { $debug } {
	post_message -type info "SDC: Computed Parameters:"
	post_message -type info "SDC: --------------------"
	post_message -type info "SDC: half_period: $half_period"
	post_message -type info "SDC: t(QKHQKnH): $t(QKHQKnH)"
	post_message -type info "SDC: data_output_min_delay: $data_output_min_delay"
	post_message -type info "SDC: data_output_max_delay: $data_output_max_delay"
	post_message -type info "SDC: data_input_min_delay: $data_input_min_delay"
	post_message -type info "SDC: data_input_max_delay: $data_input_max_delay"
	post_message -type info "SDC: ac_min_delay: $ac_min_delay"
	post_message -type info "SDC: ac_max_delay: $ac_max_delay"
	post_message -type info "SDC: Using Timing Models: Micro"
}

# This is the main call to the netlist traversal routines
# that will automatically find all pins and registers required
# to apply timing constraints.
# During the fitter, the routines will be called only once
# and cached data will be used in all subsequent calls.
if { ! [ info exists memphy_sdc_cache ] } {
	set memphy_sdc_cache 1
	memphy_initialize_ddr_db memphy_ddr_db
} else {
	if { $debug } {
		post_message -type info "SDC: reusing cached DDR DB"
	}
}

# If multiple instances of this core are present in the
# design they will all be constrained through the
# following loop
set instances [ array names memphy_ddr_db ]
foreach { inst } $instances {
	if { [ info exists pins ] } {
		# Clean-up stale content
		unset pins
	}
	array set pins $memphy_ddr_db($inst)

	set prefix $inst
	if { $entity_names_on } {
		set prefix [ string map "| |*:" $inst ]
		set prefix "*:$prefix"
	}

	#####################################################
	#                                                   #
	# Transfer the pin names to more readable variables #
	#                                                   #
	#####################################################

	set qk_pins $pins(qk_pins)
	set qkn_pins $pins(qkn_pins)
	set q_groups [ list ]
	foreach { q_group } $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]

	set dk_pins $pins(dk_pins)
	set dkn_pins $pins(dkn_pins)
	set d_groups [ list ]

	foreach { d_group } $pins(d_groups) {
		set d_group $d_group
		lappend d_groups $d_group
	}
	set all_d_pins [ join [ join $d_groups ] ]
	set ck_pins $pins(ck_pins)
	set ckn_pins $pins(ckn_pins)
	set add_pins $pins(add_pins)
	set ba_pins $pins(ba_pins)
	set cmd_pins $pins(cmd_pins)
	set ac_pins [ concat $add_pins $ba_pins $cmd_pins ]
	set dm_pins $pins(dm_pins)
	set all_dq_dm_pins [ concat $all_dq_pins $dm_pins ]

	set pll_ref_clock $pins(pll_ref_clock)
	set pll_afi_clock $pins(pll_afi_clock)
	set pll_afi_phy_clock $pins(pll_afi_phy_clock)
	set pll_ck_clock $pins(pll_ck_clock)
	set pll_dk_clock $pins(pll_dk_clock)
	set pll_ac_clock $pins(pll_ac_clock)
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock $pins(pll_afi_half_clock)
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock $pins(pll_avl_clock)
	set pll_config_clock $pins(pll_config_clock)
`endif

	set dqs_in_clocks $pins(dqs_in_clocks)
	set read_capture_ddio $pins(read_capture_ddio)
	set reset_reg $pins(reset_reg)
	set sync_reg $pins(sync_reg)
	set fifo_wraddress_reg $pins(fifo_wraddress_reg)
	set fifo_rdaddress_reg $pins(fifo_rdaddress_reg)
	set fifo_wrdata_reg $pins(fifo_wrdata_reg)
	set fifo_rddata_reg $pins(fifo_rddata_reg)
	set valid_fifo_wrdata_reg $pins(valid_fifo_wrdata_reg)
	set valid_fifo_rddata_reg $pins(valid_fifo_rddata_reg)

	##################
	#                #
	# QUERIED TIMING #
	#                #
	##################

	# Phase Jitter on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PHASE_JITTER) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PHASE_JITTER -in_fitter ] / 1000.0 ]

	# Phase Error on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PSERR) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PSERR -in_fitter ] / 1000.0 ]

	# Maximum delay requirement for setup constraint on read path
	set data_input_min_constraint [ memphy_round_3dp [ expr -$t(QKHQKnH) + $fpga(tDQS_PSERR) ]]

	# Mimimum delay requirement for hold constraint on read path
	set data_input_max_constraint [ memphy_round_3dp [ expr - $fpga(tDQS_PSERR) ]]

	if { $debug } {
		post_message -type info "SDC: Jitter Parameters"
		post_message -type info "SDC: -----------------"
		post_message -type info "SDC:    DQS Phase: $::GLOBAL_dqs_delay_chain_length"
		post_message -type info "SDC:    fpga(tDQS_PHASE_JITTER): $fpga(tDQS_PHASE_JITTER)"
		post_message -type info "SDC:    fpga(tDQS_PSERR): $fpga(tDQS_PSERR)"
		post_message -type info "SDC:"
		post_message -type info "SDC: Derived Parameters:"
		post_message -type info "SDC: -----------------"
		post_message -type info "SDC:    data_input_min_constraint: $data_input_min_constraint"
		post_message -type info "SDC:    data_input_max_constraint: $data_input_max_constraint"
		post_message -type info "SDC: -----------------"
	}

	# ----------------------- #
	# -                     - #
	# --- REFERENCE CLOCK --- #
	# -                     - #
	# ----------------------- #

	# This is the reference clock used by the PLL to derive any other clock in the core
	if { [get_collection_size [get_clocks -nowarn $pll_ref_clock]] > 0 } { remove_clock $pll_ref_clock }
	create_clock -period $t(refCK) -waveform [ list 0 $ref_half_period ] $pll_ref_clock

	# ------------------ #
	# -                - #
	# --- PLL CLOCKS --- #
	# -                - #
	# ------------------ #
	
	# AFI clock
	set local_pll_afi_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_afi_clock \
		-suffix "afi_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_AFI_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_AFI_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_AFI_CLK) ]

	# HR PHY clock
	set local_pll_afi_phy_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_afi_phy_clock \
		-suffix "afi_phy_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_AFI_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_AFI_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_AFI_CLK) ]
		
	# Write clock
	set local_pll_write_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_dk_clock \
		-suffix "write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_WRITE_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_WRITE_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_WRITE_CLK) ]
		
	# Common clock between CK/DK at the PHY clock tree output
	set local_pll_mem_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_ck_clock \
		-suffix "mem_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_MEM_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_MEM_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_MEM_CLK) ]		

	# A/C clock
	set local_pll_addr_cmd_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_ac_clock \
		-suffix "addr_cmd_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_ADDR_CMD_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_ADDR_CMD_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_ADDR_CMD_CLK) ]

`ifdef IPTCL_NIOS_SEQUENCER
	# NIOS clock
	set local_pll_avl_clock [ memphy_get_or_add_clock_vseries \
		-target $pll_avl_clock \
		-suffix "avl_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_NIOS_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_NIOS_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_NIOS_CLK) ]
	
	# I/O scan chain clock
	set local_pll_config_clock [ memphy_get_or_add_clock_vseries \
		-target $pll_config_clock \
		-suffix "config_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_CONFIG_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_CONFIG_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_CONFIG_CLK) ]	
`endif

`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	# AFI-divided-by-2 clock
	set local_pll_afi_half_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_afi_half_clock \
		-suffix "afi_half_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_AFI_HALF_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_AFI_HALF_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_AFI_HALF_CLK) ]
`endif


	
	set ckdk_common_clock $pll_ck_clock
	set ckdk_common_master_clock $local_pll_mem_clk

`ifdef IPTCL_BREAK_EXPORTED_AFI_CLK_DOMAIN
	if { [get_collection_size [get_clocks -nowarn "${inst}|afi_clk_export"]] > 0 } { remove_clock "${inst}|afi_clk_export" }
	if { [get_collection_size [get_clocks -nowarn "${inst}|ctl_afi_clk"]] > 0 } { remove_clock "${inst}|ctl_afi_clk" }
	if { [ memphy_are_entity_names_on ] } {
		create_clock -period 1 -name "${inst}|afi_clk_export" [get_registers "*:${inst}|*:pll0|afi_clk_export"]
		create_clock -period 1 -name "${inst}|ctl_afi_clk" [get_registers "*:${inst}|*:pll0|ctl_afi_clk"]
	} else {
		create_clock -period 1 -name "${inst}|afi_clk_export" [get_registers "${inst}|pll0|afi_clk_export"]
		create_clock -period 1 -name "${inst}|ctl_afi_clk" [get_registers "${inst}|pll0|ctl_afi_clk"]
	}
	set drv_num 0
	foreach_in_collection drv_clk [get_registers "*|driver_afi_clk"] {
		if { [get_collection_size [get_clocks -nowarn "${inst}|driver_afi_clk_${drv_num}"]] > 0 } { remove_clock "${inst}|driver_afi_clk_${drv_num}" }
		create_clock -period 1 -name "${inst}|driver_afi_clk_${drv_num}" [get_node_info -name $drv_clk]
		set_clock_groups -exclusive -group [get_clocks "$local_pll_afi_clk"] -group [get_clocks "${inst}|driver_afi_clk_${drv_num}"]
		set_clock_groups -exclusive -group [get_clocks "${inst}|afi_clk_export"] -group [get_clocks "${inst}|driver_afi_clk_${drv_num}"]
		set_clock_groups -exclusive -group [get_clocks "${inst}|ctl_afi_clk"] -group [get_clocks "${inst}|driver_afi_clk_${drv_num}"]
		incr drv_num
	}

	set_clock_groups -exclusive -group [get_clocks "$local_pll_afi_clk"] -group [get_clocks "${inst}|afi_clk_export"]
	set_clock_groups -exclusive -group [get_clocks "$local_pll_afi_clk"] -group [get_clocks "${inst}|ctl_afi_clk"]
`endif

	# -------------------- #
	# -                  - #
	# --- SYSTEM CLOCK --- #
	# -                  - #
	# -------------------- #
	
	# This is the CK/CKn clock pair
	for { set i 0 } { $i < [ llength $ck_pins ] } { incr i } {
		set ck_pin [ lindex $ck_pins $i ]
		set ckn_pin [ lindex $ckn_pins $i ]
		
		create_generated_clock -add -multiply_by 1 -source $ckdk_common_clock -master_clock $ckdk_common_master_clock $ck_pin -name $ck_pin
		create_generated_clock -add -multiply_by 1 -invert -source $ckdk_common_clock -master_clock $ckdk_common_master_clock $ckn_pin -name $ckn_pin
	}
	
	# ------------------- #
	# -                 - #
	# --- READ CLOCKS --- #
	# -                 - #
	# ------------------- #

	foreach { qk_pin } $qk_pins { dqs_in_clock_struct } $dqs_in_clocks {
		# This is the QK clock for Read Capture analysis (micro model)
		create_clock -period $t(CK) -waveform [ list 0 $half_period ] $qk_pin -name $qk_pin

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -from [ get_clocks $qk_pin ] 0
	}

	# This is the QKn clock for Read Capture analysis (micro model)
	if { ! $synthesis_flow } {
		# This assignment cannot be performed during Synthesis as the QKn
		# pins cannot be detected at this stage. Skipping this assignment
		# DOES NOT impact Timing-Driven synthesis
		foreach { qkn_pin } $qkn_pins {
			create_clock -period $t(CK) -waveform [ list $half_period $t(CK) ] $qkn_pin -name $qkn_pin

			# Clock Uncertainty is accounted for by the ...pathjitter parameters
			set_clock_uncertainty -from [ get_clocks $qkn_pin ] 0
		}
	}

	# -------------------- #
	# -                  - #
	# --- WRITE CLOCKS --- #
	# -                  - #
	# -------------------- #

	# This is the DK clock for Data Write analysis (micro model)
	for { set i 0 } { $i < [ llength $dk_pins ] } { incr i } {
		set dk_pin [lindex $dk_pins $i]
		
		create_generated_clock -add -multiply_by 1 -source $ckdk_common_clock -master_clock $ckdk_common_master_clock $dk_pin -name $dk_pin

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $dk_pin ] 0
	}

	# This is the DKn clock for Data Write analysis (micro model)
	for { set i 0 } { $i < [ llength $dkn_pins ] } { incr i } {
		set dkn_pin [lindex $dkn_pins $i]
		
		create_generated_clock -add -multiply_by 1 -invert -source $ckdk_common_clock -master_clock $ckdk_common_master_clock $dkn_pin -name $dkn_pin

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $dkn_pin ] 0
	}

	##################
	#                #
	# READ DATA PATH #
	#                #
	##################

	if { ! $synthesis_flow } {
		# The read capture DDIO registers don't yet exist in the timing netlist during synthesis
		foreach { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				# Specifies the setup relationship of the read input data at the DQ pin
				set_max_delay $data_input_max_constraint -from $dq_pin -to $read_capture_ddio

				# Specifies the hold relationship of the read input data at the DQ pin
				set_min_delay $data_input_min_constraint -from $dq_pin -to $read_capture_ddio
			}
		}
	}

	foreach { qk_pin } $qk_pins { dq_pins } $q_groups {
		foreach { dq_pin } $dq_pins {
			# Specifies the maximum delay difference between the DQ pin and the QK pin:
			set_input_delay -max $data_input_max_delay -clock [get_clocks $qk_pin] [get_ports $dq_pin] -add_delay

			# Specifies the minimum delay difference between the DQ pin and the QK pin:
			set_input_delay -min $data_input_min_delay -clock [get_clocks $qk_pin] [get_ports $dq_pin] -add_delay
		}
	}

	if { ! $synthesis_flow } {
		# This assignment cannot be performed during Synthesis as the QKn
		# pins cannot be detected at this stage. Skipping this assignment
		# DOES NOT impact Timing-Driven synthesis

		foreach { qkn_pin } $qkn_pins { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				# Specifies the maximum delay difference between the DQ pin and the QKn pin:
				set_input_delay -max $data_input_max_delay -clock [get_clocks $qkn_pin] [get_ports $dq_pin] -add_delay

				# Specifies the minimum delay difference between the DQ pin and the QKn pin:
				set_input_delay -min $data_input_min_delay -clock [get_clocks $qkn_pin] [get_ports $dq_pin] -add_delay
			}
		}
	}

	###################
	#                 #
	# WRITE DATA PATH #
	#                 #
	###################

	set number_of_clocks_per_dm [ expr $::GLOBAL_number_of_d_groups / $::GLOBAL_number_of_dm_pins ]
	
	for { set i 0 } { $i < [ llength $d_groups ] } { incr i } {
		set dk_pin [ lindex $dk_pins $i ]
		set dkn_pin [ lindex $dkn_pins $i ]
		
		foreach { dq_pin } [ lindex $d_groups $i ] {
			# Specifies the minimum delay difference between the K pin and the DQ pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks $dk_pin] [get_ports $dq_pin] -add_delay

			# Specifies the maximum delay difference between the K pin and the DQ pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks $dk_pin] [get_ports $dq_pin] -add_delay
			
			# Specifies the minimum delay difference between the Kn pin and the DQ pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks $dkn_pin] [get_ports $dq_pin] -add_delay

			# Specifies the maximum delay difference between the Kn pin and the DQ pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks $dkn_pin] [get_ports $dq_pin] -add_delay
		}

		if {[expr ($i + 1) % $number_of_clocks_per_dm] == 0} {
			set dm_index [expr ($i + 1) / $number_of_clocks_per_dm - 1]
			set dm_pin [lindex $dm_pins $dm_index]

			# Specifies the minimum delay difference between the K pin and the DQ pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks $dk_pin] [get_ports $dm_pin] -add_delay

			# Specifies the maximum delay difference between the K pin and the DQ pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks $dk_pin] [get_ports $dm_pin] -add_delay
			
			# Specifies the minimum delay difference between the K pin and the DQ pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks $dkn_pin] [get_ports $dm_pin] -add_delay

			# Specifies the maximum delay difference between the K pin and the DQ pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks $dkn_pin] [get_ports $dm_pin] -add_delay
		}
	}

	#################
	#               #
	# DK vs CK PATH #
	#               #
	#################
	
	foreach { ck_pin } $ck_pins {
		set_output_delay -add_delay -clock [get_clocks $ck_pin] -max [memphy_round_3dp [expr $t(CK) - $t(CKDK_max)]] $dk_pins
		set_output_delay -add_delay -clock [get_clocks $ck_pin] -min [memphy_round_3dp [expr -$t(CKDK_min)]] $dk_pins		

		set_false_path -to [get_clocks $ck_pin]  -fall_from [get_clocks $ckdk_common_master_clock]
	}
	
	############
	#          #
	# A/C PATH #
	#          #
	############

	foreach { ck_pin } $ck_pins {
		# Specifies the minimum delay difference between the K pin and the address/control pins:
		set_output_delay -min $ac_min_delay -clock [get_clocks $ck_pin] [ get_ports $ac_pins ] -add_delay

		# Specifies the maximum delay difference between the K pin and the address/control pins:
		set_output_delay -max $ac_max_delay -clock [get_clocks $ck_pin] [ get_ports $ac_pins ] -add_delay
	}


	##########################
	#                        #
	# MULTICYCLE CONSTRAINTS #
	#                        #
	##########################

`ifdef IPTCL_NIOS_SEQUENCER
	# Relax timing for the AFI mux select signal. 
	# We don't assert the cal_done signal many cycles after we switch the AFI mux.
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -setup 3
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -hold 2
`else
	# Set multicycle constraint based on VCALIB_COUNT_WIDTH in the sequencer
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|vcalib_rddata_burst\[*\]"] -setup -end [expr $vcalib_count_width+1]
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|vcalib_rddata_burst\[*\]"] -hold -end $vcalib_count_width
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|mux_seq_rdata_burst\[*\]"] -setup -end [expr $vcalib_count_width+1]
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|mux_seq_rdata_burst\[*\]"] -hold -end $vcalib_count_width
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|vcalib_count\[*\]"] -to [get_registers "${prefix}|*s0|*sequencer_inst|state.STATE_V_CHECK_READ_FAIL"] -setup -end [expr $vcalib_count_width+1]
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|vcalib_count\[*\]"] -to [get_registers "${prefix}|*s0|*sequencer_inst|state.STATE_V_CHECK_READ_FAIL"] -hold $vcalib_count_width
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|vcalib_count\[*\]"] -to [get_registers "${prefix}|*s0|*sequencer_inst|state.STATE_V_CALIB_DONE"] -setup -end [expr $vcalib_count_width+1]
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|vcalib_count\[*\]"] -to [get_registers "${prefix}|*s0|*sequencer_inst|state.STATE_V_CALIB_DONE"] -hold $vcalib_count_width

	# Relax timing for the AFI mux select signal. 
	# We don't assert the cal_done signal many cycles after we switch the AFI mux.
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|mux_sel"] -to [remove_from_collection [get_keepers *] [get_registers [list "${prefix}|*s0|*sequencer_inst|mux_sel"]]] -setup 3
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|mux_sel"] -to [remove_from_collection [get_keepers *] [get_registers [list "${prefix}|*s0|*sequencer_inst|mux_sel"]]] -hold 2
`endif


`ifdef IPTCL_FULL_RATE
`else
	set ac_fr_phase_mod_360 [expr round(2*$::GLOBAL_pll_phase(3)) % 360]
	set ck_fr_phase_mod_360 [expr round($::GLOBAL_pll_phase(1)) % 360]
	set ac_to_ck_setup_window_fr_degrees [expr {($ck_fr_phase_mod_360 + 360) - $ac_fr_phase_mod_360}]
	if {$ac_to_ck_setup_window_fr_degrees < 90} {
		foreach { ck_pin } $ck_pins {
			set_multicycle_path -from [get_clocks $local_pll_addr_cmd_clk] -to [get_clocks $ck_pin] -end -setup 2
			set_multicycle_path -from [get_clocks $local_pll_addr_cmd_clk] -to [get_clocks $ck_pin] -end -hold 0
		}
	}
`endif

	set lfifo_in_read_en_dff ${prefix}|*p0|*lfifo~*LFIFO_IN_READ_EN_DFF
	set lfifo_dff_reg ${prefix}|*p0|*lfifo~LFIFO_OUT_OCT_LFIFO_DFF
	set lfifo_out_rden_dff ${prefix}|*p0|*lfifo~*LFIFO_OUT_RDEN_DFF
	set os_oct_ddio_oe_reg ${prefix}|*p0|*os_oct_ddio_oe~DFF
	set lfifo_rd_latency_dff ${prefix}|*p0|*lfifo~*RD_LATENCY_DFF*
`ifdef IPTCL_NIOS_SEQUENCER
	set phy_read_latency_counter ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_read_latency_counter\[*\]
	set phy_reset_mem_stable ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_reset_mem_stable
	set read_fifo_reset ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_read_fifo_reset\[*\]
`else
	set phy_read_latency_counter ${prefix}|*s0|*sequencer_inst|seq_read_latency_counter\[*\]
	set phy_reset_mem_stable ${prefix}|*s0|*sequencer_inst|seq_reset_mem_stable
	set read_fifo_reset ${prefix}|*s0|*sequencer_inst|seq_read_fifo_reset\[*\]
`endif

	set core_to_fr_multicycle_setup 2
	set core_to_fr_multicycle_hold [expr {$core_to_fr_multicycle_setup - 1}]

	set after_u2b 0
	if {[get_collection_size [get_registers -nowarn $fifo_wraddress_reg]] > 0} {
		set after_u2b 1
	}

	if {$after_u2b} {

		set_multicycle_path -from $lfifo_dff_reg -to $os_oct_ddio_oe_reg -hold -end 1

		set_multicycle_path -from $phy_read_latency_counter -to $lfifo_rd_latency_dff -end -setup $core_to_fr_multicycle_setup
		set_multicycle_path -from $phy_read_latency_counter -to $lfifo_rd_latency_dff -end -hold $core_to_fr_multicycle_hold

		set_multicycle_path -from ${prefix}|*p0|*umemphy|*ureset|*ureset_afi_clk|reset_reg[*] -to $lfifo_in_read_en_dff -end -setup $core_to_fr_multicycle_setup
		set_multicycle_path -from ${prefix}|*p0|*umemphy|*ureset|*ureset_afi_clk|reset_reg[*] -to $lfifo_in_read_en_dff -end -hold $core_to_fr_multicycle_hold

		set_multicycle_path -from $phy_reset_mem_stable -to $valid_fifo_wrdata_reg -end -setup $core_to_fr_multicycle_setup
		set_multicycle_path -from $phy_reset_mem_stable -to $valid_fifo_wrdata_reg -end -hold $core_to_fr_multicycle_hold

		set_multicycle_path -from $read_fifo_reset -to $fifo_wraddress_reg -end -setup 2
		set_multicycle_path -from $read_fifo_reset -to $fifo_wraddress_reg -end -hold 1

		set_multicycle_path -from $read_fifo_reset -to $fifo_rdaddress_reg -end -setup 2
		set_multicycle_path -from $read_fifo_reset -to $fifo_rdaddress_reg -end -hold 1

		set_false_path -from $lfifo_out_rden_dff -to $fifo_rdaddress_reg

		set_false_path -from $pll_afi_phy_clock -to $lfifo_in_read_en_dff
		set_false_path -from $pll_afi_phy_clock -to $valid_fifo_wrdata_reg
	}



	##########################
	#                        #
	# FALSE PATH CONSTRAINTS #
	#                        #
	##########################

	# Cut paths for memory clocks to avoid unconstrained warnings
	foreach { pin } [concat $dkn_pins $ck_pins $ckn_pins] {
		set_false_path -to [get_ports $pin]
	}

	# Cut paths between AFI Clock and Read Capture Registers
	set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $qk_pins]

	if {$after_u2b} {

		# Cut calibrated path from the VFIFO to the read FIFO
		set_false_path -from $valid_fifo_rddata_reg -to $fifo_wraddress_reg

	}

`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	# The following registers serve as anchors for the pin_map.tcl
	# script and are not used by the IP during memory operation
	set_false_path -from $pins(afi_half_ck_pins) -to $pins(afi_half_ck_pins)
`endif

	# ------------------------------ #
	# -                            - #
	# --- FITTER OVERCONSTRAINTS --- #
	# -                            - #
	# ------------------------------ #
	if {$fit_flow} {
		
		

                set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_mem_clk] -add -hold 0.300

		if {[string compare -nocase $pll_afi_clock $pll_afi_phy_clock]==0} {
			set hr_to_fr_dff ${prefix}|*p0|*altdq_dqs2_inst|*hr_to_fr*
			if {[get_collection_size [get_registers -nowarn $hr_to_fr_dff]] > 0} {
				set_min_delay -to $hr_to_fr_dff 0.500
			}
		} else {
			set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_afi_phy_clk] -add -hold 0.500
		}
	}
	
	# -------------------------------- #
	# -                              - #
	# --- TIMING MODEL ADJUSTMENTS --- #
	# -                              - #
	# -------------------------------- #

}

if {(($::quartus(nameofexecutable) ne "quartus_fit") && ($::quartus(nameofexecutable) ne "quartus_map"))} {
	set dqs_clocks [memphy_get_all_instances_dqs_pins memphy_ddr_db]
	# Leave clocks active when in debug mode
	if {[llength $dqs_clocks] > 0 && !$debug} {
		post_sdc_message info "Setting DQS clocks as inactive; use Report DDR to timing analyze DQS clocks"
		set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $dqs_clocks]]
	}
}

######################
#                    #
# REPORT DDR COMMAND #
#                    #
######################

add_ddr_report_command "source [list [file join [file dirname [info script]] ${::GLOBAL_corename}_report_timing.tcl]]"

