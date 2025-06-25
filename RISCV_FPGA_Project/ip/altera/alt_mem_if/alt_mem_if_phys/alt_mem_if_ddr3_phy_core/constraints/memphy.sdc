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

`ifdef IPTCL_USE_HARD_READ_FIFO
set use_hard_read_fifo 1
`else
set use_hard_read_fifo 0
`endif

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

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
	##################
	#                #
	# QUERIED TIMING #
	#                #
	##################

	set io_standard "DIFFERENTIAL 1.5-V SSTL CLASS I"

	# This is the peak-to-peak jitter on the whole read capture path
`ifdef IPTCL_STRATIXV
	set DQSpathjitter [expr [get_micro_node_delay -micro DQDQS_JITTER -parameters [list IO] -in_fitter]/1000.0]
	set DQSpathjitter_setup_prop [expr [get_micro_node_delay -micro DQDQS_JITTER_DIVISION -parameters [list IO] -in_fitter]/100.0]
	
	set tJITper [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO PHY_SHORT] -in_fitter -period $t(CK)]/2000.0 + $SSN(pullin_o)]
`else
	set DQSpathjitter [expr [get_io_standard_node_delay -dst DQDQS_JITTER -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/1000.0]
	set DQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst DQDQS_JITTER_DIVISION -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/100.0]
	
	set tJITper [expr [get_io_standard_node_delay -dst MEM_CK_PERIOD_JITTER -io_standard $io_standard  -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter -period $t(CK)]/2000.0]
`endif

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

	# Minimum delay on data output pins
	set t(wru_output_min_delay_external) [expr $t(DH) + $board(intra_DQS_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 - $board(DQ_DQS_skew)]
`ifdef IPTCL_STRATIXV
	set t(wru_output_min_delay_internal) [expr $t(WL_DCD) + $t(WL_JITTER)*(1.0-$t(WL_JITTER_DIVISION)) + $SSN(rel_pullin_o)]
`else
	set t(wru_output_min_delay_internal) [expr $t(WL_DCD) + $t(WL_JITTER) + $t(WL_PSE) + $SSN(rel_pullin_o)]
`endif
	set data_output_min_delay [ memphy_round_3dp [ expr - $t(wru_output_min_delay_external) - $t(wru_output_min_delay_internal)]]

	# Maximum delay on data output pins
	set t(wru_output_max_delay_external) [expr $t(DS) + $board(intra_DQS_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 + $board(DQ_DQS_skew)]
`ifdef IPTCL_STRATIXV
	set t(wru_output_max_delay_internal) [expr $t(WL_DCD) + $t(WL_JITTER)*$t(WL_JITTER_DIVISION) + $SSN(rel_pushout_o)]
`else
	set t(wru_output_max_delay_internal) [expr $t(WL_DCD) + $t(WL_JITTER) + $t(WL_PSE) + $SSN(rel_pushout_o)]
`endif
	set data_output_max_delay [ memphy_round_3dp [ expr $t(wru_output_max_delay_external) + $t(wru_output_max_delay_internal)]]

	# Maximum delay on data input pins
	set t(rdu_input_max_delay_external) [expr $t(DQSQ) + $board(intra_DQS_group_skew) + $board(DQ_DQS_skew)]
	set t(rdu_input_max_delay_internal) [expr $DQSpathjitter*$DQSpathjitter_setup_prop + $SSN(rel_pushout_i)]
	set data_input_max_delay [ memphy_round_3dp [ expr $t(rdu_input_max_delay_external) + $t(rdu_input_max_delay_internal) ]]

	# Minimum delay on data input pins
	set t(rdu_input_min_delay_external) [expr $board(intra_DQS_group_skew) - $board(DQ_DQS_skew)]
	set t(rdu_input_min_delay_internal) [expr $t(DCD) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $SSN(rel_pullin_i)]
	set data_input_min_delay [ memphy_round_3dp [ expr - $t(rdu_input_min_delay_external) - $t(rdu_input_min_delay_internal) ]]

	# Minimum delay on address and command paths
	set ac_min_delay [ memphy_round_3dp [ expr - $t(IH) -$fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) - $ISI(addresscmd_hold) ]]

	# Maximum delay on address and command paths
	set ac_max_delay [ memphy_round_3dp [ expr $t(IS) +$fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) + $ISI(addresscmd_setup) ]]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
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

	# Minimum delay on data output pins
	set data_output_min_delay [ memphy_round_3dp [ expr - $t(DH) - $fpga(tPLL_JITTER) -$fpga(tPLL_PSERR) - $board(intra_DQS_group_skew) - $SSN(rel_pullin_o) ]]

	# Maximum delay on data output pins
	set data_output_max_delay [ memphy_round_3dp [ expr $t(DS) + $fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_DQS_group_skew) + $SSN(rel_pushout_o) ]]

	# Maximum delay on data input pins
	set data_input_max_delay [ memphy_round_3dp [ expr $t(DQSQ) + $board(intra_DQS_group_skew) + $SSN(rel_pushout_i) ]]

	# Minimum delay on data input pins
	set data_input_min_delay [ memphy_round_3dp [ expr -$t(DCD) - $board(intra_DQS_group_skew) - $SSN(rel_pullin_i) ]]

	# Minimum delay on address and command paths
	set ac_min_delay [ memphy_round_3dp [ expr - $t(IH) -$fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) ]]

	# Maximum delay on address and command paths
	set ac_max_delay [ memphy_round_3dp [ expr $t(IS) +$fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew)]]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
}
`endif

if { $debug } {
	post_message -type info "SDC: Computed Parameters:"
	post_message -type info "SDC: --------------------"
	post_message -type info "SDC: half_period: $half_period"
	post_message -type info "SDC: data_output_min_delay: $data_output_min_delay"
	post_message -type info "SDC: data_output_max_delay: $data_output_max_delay"
	post_message -type info "SDC: data_input_min_delay: $data_input_min_delay"
	post_message -type info "SDC: data_input_max_delay: $data_input_max_delay"
	post_message -type info "SDC: ac_min_delay: $ac_min_delay"
	post_message -type info "SDC: ac_max_delay: $ac_max_delay"

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		post_message -type info "SDC: Using Timing Models: Micro"
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
		post_message -type info "SDC: Using Timing Models: MACRO"
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	}
`endif
}

# This is the main call to the netlist traversal routines
# that will automatically find all pins and registers required
# to apply timing constraints.
# During the fitter, the routines will be called only once
# and cached data will be used in all subsequent calls.
`ifdef IPTCL_STRATIXV
if { ! [ info exists memphy_sdc_cache ] || $fit_flow} {
`else
if { ! [ info exists memphy_sdc_cache ] } {
`endif
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

	set dqs_pins $pins(dqs_pins)
	set dqsn_pins $pins(dqsn_pins)
	set q_groups [ list ]
	foreach { q_group } $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]

	set ck_pins $pins(ck_pins)
	set ckn_pins $pins(ckn_pins)
	set add_pins $pins(add_pins)
	set ba_pins $pins(ba_pins)
	set cmd_pins $pins(cmd_pins)
	set reset_pins $pins(reset_pins)
	set ac_pins [ concat $add_pins $ba_pins $cmd_pins ]
	set dm_pins $pins(dm_pins)
	set all_dq_dm_pins [ concat $all_dq_pins $dm_pins ]

	set pll_ref_clock $pins(pll_ref_clock)
	set pll_afi_clock $pins(pll_afi_clock)
`ifdef IPTCL_DUAL_WRITE_CLOCK
	set pll_dq_write_clock $pins(pll_dq_write_clock)
`endif
`ifdef IPTCL_USE_LDC_FOR_ADDR_CMD
`else	
	set pll_ac_clock $pins(pll_ac_clock)
	set pll_ck_clock $pins(pll_ck_clock)
`endif
	set pll_write_clock $pins(pll_write_clock)
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock $pins(pll_afi_half_clock)
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock $pins(pll_avl_clock)
	set pll_config_clock $pins(pll_config_clock)
`endif
`ifdef IPTCL_QUARTER_RATE
	set pll_hr_clock $pins(pll_hr_clock)
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pll_p2c_read_clock $pins(pll_p2c_read_clock)
	set pll_c2p_write_clock $pins(pll_c2p_write_clock)
`endif
`ifdef IPTCL_USE_2X_FF
	set pll_2x_clock $pins(pll_2x_clock)
`endif

	set dqs_in_clocks $pins(dqs_in_clocks)
	set dqs_out_clocks $pins(dqs_out_clocks)
	set dqsn_out_clocks $pins(dqsn_out_clocks)
`ifdef IPTCL_MEM_LEVELING
	set leveling_pins $pins(leveling_pins)
 `ifdef IPTCL_STRATIXV
	set dq_xphase_cps_pins $pins(dq_xphase_cps_pins)
	set dqs_xphase_cps_pins $pins(dqs_xphase_cps_pins)
	set phase_transfer_pins $pins(phase_transfer_pins)
 `endif
`endif

	set afi_reset_reg $pins(afi_reset_reg)
	set seq_reset_reg $pins(seq_reset_reg)
	set sync_reg $pins(sync_reg)
	set read_capture_ddio $pins(read_capture_ddio)
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

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		# Correct input min/max delay for queried parameters
		set t(rdu_input_min_delay_external) [expr $t(rdu_input_min_delay_external) + ($t(CK)/2.0 - $t(QH_time))]
		set t(rdu_input_min_delay_internal) [expr $t(rdu_input_min_delay_internal) + $fpga(tDQS_PSERR) + $tJITper]
		set t(rdu_input_max_delay_external) [expr $t(rdu_input_max_delay_external)]
		set t(rdu_input_max_delay_internal) [expr $t(rdu_input_max_delay_internal) + $fpga(tDQS_PSERR)]

		set final_data_input_max_delay [ memphy_round_3dp [ expr $data_input_max_delay + $fpga(tDQS_PSERR) ]]
		set final_data_input_min_delay [ memphy_round_3dp [ expr $data_input_min_delay - $t(CK) / 2.0 + $t(QH_time) - $fpga(tDQS_PSERR) - $tJITper]]

`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	}
`endif

	if { $debug } {
		post_message -type info "SDC: Jitter Parameters"
		post_message -type info "SDC: -----------------"
		post_message -type info "SDC:    DQS Phase: $::GLOBAL_dqs_delay_chain_length"
		post_message -type info "SDC:    fpga(tDQS_PHASE_JITTER): $fpga(tDQS_PHASE_JITTER)"
		post_message -type info "SDC:    fpga(tDQS_PSERR): $fpga(tDQS_PSERR)"
		post_message -type info "SDC:    t(QH_time): $t(QH_time)"
		post_message -type info "SDC:"
		post_message -type info "SDC: Derived Parameters:"
		post_message -type info "SDC: -----------------"
		post_message -type info "SDC:    Corrected data_input_max_delay: $final_data_input_max_delay"
		post_message -type info "SDC:    Corrected data_input_min_delay: $final_data_input_min_delay"
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

	# PLL Clock Names
	set local_pll_afi_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_afi_clock "afi_clk"]
	set local_pll_mem_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_ck_clock "mem_clk"]
	set local_pll_addr_cmd_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_ac_clock "addr_cmd_clk"]
	set local_pll_write_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_write_clock "write_clk"]
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set local_pll_afi_half_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_afi_half_clock "afi_half_clk"]
`endif
	set local_pll_avl_clock [memphy_get_clock_name_from_pin_name_pre_vseries $pll_avl_clock "avl_clk"]
	set local_pll_config_clock [memphy_get_clock_name_from_pin_name_pre_vseries $pll_config_clock "config_clk"]

	if { [get_collection_size [get_clocks -nowarn "$local_pll_afi_clk"]] > 0 } { remove_clock "$local_pll_afi_clk" }
	if { [get_collection_size [get_clocks -nowarn "$local_pll_mem_clk"]] > 0 } { remove_clock "$local_pll_mem_clk" }
	if { [get_collection_size [get_clocks -nowarn "$local_pll_addr_cmd_clk"]] > 0 } { remove_clock "$local_pll_addr_cmd_clk" }
	if { [get_collection_size [get_clocks -nowarn "$local_pll_write_clk"]] > 0 } { remove_clock "$local_pll_write_clk" }
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	if { [get_collection_size [get_clocks -nowarn "$local_pll_afi_half_clk"]] > 0 } { remove_clock "$local_pll_afi_half_clk" }
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	if { [get_collection_size [get_clocks -nowarn "$local_pll_avl_clock"]] > 0 } { remove_clock "$local_pll_avl_clock" }
	if { [get_collection_size [get_clocks -nowarn "$local_pll_config_clock"]] > 0 } { remove_clock "$local_pll_config_clock" }
`endif

	# W A R N I N G !
	# The PLL parameters are statically defined in the memphy_parameters.tcl
	# file at generation time!
	# To ensure timing constraints and timing reports are correct, when you make
	# any changes to the PLL component using the MegaWizard Plug-In,
	# apply those changes to the PLL parameters in the memphy_parameters.tcl

	set pll_i 5
`ifdef IPTCL_AFI_CLK_1GHZ
	create_clock -period 1 -name "$local_pll_afi_clk" $inst|$::GLOBAL_pll_0_pin
`else
	create_generated_clock -add -name "$local_pll_afi_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(0) -divide_by $::GLOBAL_pll_div(0) -phase $::GLOBAL_pll_phase(0) $pll_afi_clock
`endif
	create_generated_clock -add -name "$local_pll_mem_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(1) -divide_by $::GLOBAL_pll_div(1) -phase $::GLOBAL_pll_phase(1) $pll_ck_clock
	create_generated_clock -add -name "$local_pll_addr_cmd_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(3) -divide_by $::GLOBAL_pll_div(3) -phase $::GLOBAL_pll_phase(3) $pll_ac_clock
	set write_clk_phase $::GLOBAL_pll_phase(2)
	create_generated_clock -add -name "$local_pll_write_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(2) -divide_by $::GLOBAL_pll_div(2) -phase $write_clk_phase $pll_write_clock
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	create_generated_clock -add -name "$local_pll_afi_half_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(4) -divide_by $::GLOBAL_pll_div(4) -phase $::GLOBAL_pll_phase(4) $pll_afi_half_clock
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set avl_pll_clk_i $pll_i
	if {[string compare -nocase $pll_afi_clock $pll_avl_clock]==0} {
		set local_pll_avl_clock $local_pll_afi_clk
	} else {
		create_generated_clock -add -name "$local_pll_avl_clock" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult($pll_i) -divide_by $::GLOBAL_pll_div($pll_i) -phase $::GLOBAL_pll_phase($pll_i) $pll_avl_clock
	}
	incr pll_i
	create_generated_clock -add -name "$local_pll_config_clock" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult($pll_i) -divide_by $::GLOBAL_pll_div($pll_i) -phase $::GLOBAL_pll_phase($pll_i) $pll_config_clock
	incr pll_i
`endif

	if {$fit_flow} {
		if {[string compare -nocase $pll_avl_clock $pll_afi_clock] != 0} {
			set_clock_uncertainty -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_afi_clk] -add -hold 0.100
			set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_avl_clock] -add -hold 0.050
		}
	}

`ifdef IPTCL_BREAK_EXPORTED_AFI_CLK_DOMAIN

	if { [ memphy_are_entity_names_on ] } {
		create_clock -period 1 -name "${inst}|afi_clk_export" [get_registers "*:${inst}|*:pll0|afi_clk_export"]
		create_clock -period 1 -name "${inst}|ctl_afi_clk" [get_registers "*:${inst}|*:pll0|ctl_afi_clk"]
	} else {
		create_clock -period 1 -name "${inst}|afi_clk_export" [get_registers "${inst}|pll0|afi_clk_export"]
		create_clock -period 1 -name "${inst}|ctl_afi_clk" [get_registers "${inst}|pll0|ctl_afi_clk"]
	}
	set drv_num 0
	foreach_in_collection drv_clk [get_registers "*|driver_afi_clk"] {
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

	# This is the CK clock
`ifdef IPTCL_USE_2X_FF
	set ck_2x_i 0
`endif
	foreach { ck_pin } $ck_pins {
`ifdef IPTCL_USE_2X_FF
		set ck_2x_reg [string map "* $ck_2x_i" $pins(ck_2x_reg)]
		incr ck_2x_i
		create_generated_clock -divide_by 2    -source $pll_2x_clock -master_clock "$local_pll_2x_clk" $ck_2x_reg -name $ck_2x_reg
		create_generated_clock -multiply_by 1  -source $ck_2x_reg -master_clock $ck_2x_reg $ck_pin -name $ck_pin
`else
`ifdef IPTCL_USE_LDC_FOR_ADDR_CMD
		create_generated_clock -multiply_by 1 -invert -source $pll_write_clock -master_clock "$local_pll_write_clk" $ck_pin -name $ck_pin
`else
		create_generated_clock -multiply_by 1 -source $pll_ck_clock -master_clock "$local_pll_mem_clk" $ck_pin -name $ck_pin
`endif
`endif
	}

	# This is the CK#clock
`ifdef IPTCL_USE_2X_FF
	set ck_2x_i 0
`endif
	foreach { ckn_pin } $ckn_pins {
`ifdef IPTCL_USE_2X_FF
		set ck_2x_reg [string map "* $ck_2x_i" $pins(ck_2x_reg)]
		incr ck_2x_i
		create_generated_clock -multiply_by 1 -invert -source $ck_2x_reg -master_clock $ck_2x_reg $ckn_pin -name $ckn_pin
`else
`ifdef IPTCL_USE_LDC_FOR_ADDR_CMD
		create_generated_clock -multiply_by 1 -source $pll_write_clock -master_clock "$local_pll_write_clk" $ckn_pin -name $ckn_pin
`else
		create_generated_clock -multiply_by 1 -invert -source $pll_ck_clock -master_clock "$local_pll_mem_clk" $ckn_pin -name $ckn_pin
`endif
`endif
	}
	
	# ------------------- #
	# -                 - #
	# --- READ CLOCKS --- #
	# -                 - #
	# ------------------- #


	foreach dqs_in_clock_struct $dqs_in_clocks {
		array set dqs_in_clock $dqs_in_clock_struct
		# This is the DQS clock for Read Capture analysis (micro model)
		create_clock -period $t(CK) -waveform [ list 0 $half_period ] $dqs_in_clock(dqs_pin) -name $dqs_in_clock(dqs_pin)_IN -add

`ifdef IPTCL_READ_FIFO_HALF_RATE
		# DIV clock is generated on the output of the clock divider.
		# This clock is created using DQS as the source. However, in the netlist there's an inverter
		# between the two clocks. In order to create the right waveform, the clock is divided and shifted by 90
		# degrees.
`ifdef IPTCL_ACV_FAMILY
`else
		create_generated_clock -name $dqs_in_clock(div_name) -source $dqs_in_clock(dqs_pin) -divide_by 2 -phase 90 -offset 0.001 $dqs_in_clock(div_pin) -master $dqs_in_clock(dqs_pin)_IN
`endif
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
			set_clock_uncertainty -from [ get_clocks $dqs_in_clock(dqs_pin)_IN ] 0
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
	}

`ifdef IPTCL_STRATIXV
`else
`ifdef IPTCL_MEM_LEVELING
	# ----------------------- #
	# -                     - #
	# --- LEVELING CLOCKS --- #
	# -                     - #
	# ----------------------- #

	create_generated_clock -add -name "${inst}|memphy_leveling_clk" -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock -phase $::GLOBAL_leveling_capture_phase [ get_pins $leveling_pins ]
`endif
`endif

	# -------------------- #
	# -                  - #
	# --- WRITE CLOCKS --- #
	# -                  - #
	# -------------------- #

	# This is the DQS clock for Data Write analysis (micro model)
	foreach dqs_out_clock_struct $dqs_out_clocks {
		array set dqs_out_clock $dqs_out_clock_struct
`ifdef IPTCL_STRATIXV
`ifdef IPTCL_DUAL_WRITE_CLOCK
`else
		# Set DQS phase to the ideal 90 degrees and let the calibration scripts take care of
		# properly adjust the margins
`endif
`ifdef IPTCL_USE_2X_FF
		create_generated_clock -divide_by 2 -master_clock [get_clocks $local_pll_2x_clk] -source $pll_2x_clock -phase 0 $dqs_out_clock(2X)  -name $dqs_out_clock(dst)_2X -add
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $dqs_out_clock(dst)_2X] -source $dqs_out_clock(2X) -phase 90 $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add
`else
`ifdef IPTCL_DUAL_WRITE_CLOCK
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add
`else
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock -phase 90 $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add
`endif
`endif
`else
`ifdef IPTCL_MEM_LEVELING
		# Set DQS phase to the ideal 90 degrees and let the calibration scripts take care of
		# properly adjust the margins
		create_generated_clock -multiply_by 1 -master_clock "${inst}|memphy_leveling_clk" -source $dqs_out_clock(src) -phase 90 $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add
`else
`ifdef IPTCL_ACV_FAMILY
		create_generated_clock -name $dqs_out_clock(dst)_OUT_tmp -source $pll_ck_clock -divide_by 1 -multiply_by 1  $dqs_out_clock(src)
		create_generated_clock -multiply_by 1 -source $dqs_out_clock(src) $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add
`else
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $dqs_out_clock(src) $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add
`endif
`endif
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
`ifdef IPTCL_MEM_LEVELING
`ifdef IPTCL_STRATIXV
			set_clock_uncertainty -to [ get_clocks $dqs_out_clock(dst)_OUT ] 0
`else
			set_clock_uncertainty -from [get_clocks ${inst}|memphy_leveling_clk] -to [ get_clocks $dqs_out_clock(dst)_OUT ] 0
`endif
`else
			set_clock_uncertainty -to [ get_clocks $dqs_out_clock(dst)_OUT ] 0
`endif
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
	}

	# This is the DQS#clock for Data Write analysis (micro model)
	foreach dqsn_out_clock_struct $dqsn_out_clocks {
		array set dqsn_out_clock $dqsn_out_clock_struct
`ifdef IPTCL_STRATIXV
`ifdef IPTCL_DUAL_WRITE_CLOCK
`else
		# Set DQS#phase to the ideal 90 degrees and let the calibration scripts take care of
		# properly adjust the margins
`endif
`ifdef IPTCL_USE_2X_FF
		create_generated_clock -divide_by 2 -master_clock [get_clocks $local_pll_2x_clk]    -source $pll_2x_clock -phase 0  $dqsn_out_clock(2X)  -name $dqsn_out_clock(dst)_2X -add
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $dqsn_out_clock(dst)_2X] -source $dqsn_out_clock(2X) -phase 90 $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add		
`else
`ifdef IPTCL_DUAL_WRITE_CLOCK
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add
`else
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock -phase 90 $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add
`endif
`endif
`else
`ifdef IPTCL_MEM_LEVELING
		# Set DQS#phase to the ideal 90 degrees and let the calibration scripts take care of
		# properly adjust the margins
		create_generated_clock -multiply_by 1 -master_clock "${inst}|memphy_leveling_clk" -source $dqsn_out_clock(src) -phase 90 $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add
`else
`ifdef IPTCL_ACV_FAMILY
		create_generated_clock -name $dqsn_out_clock(dst)_OUT_tmp -source $pll_ck_clock -divide_by 1 -multiply_by 1  $dqsn_out_clock(src)
		create_generated_clock -multiply_by 1 -source $dqsn_out_clock(src) $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add
`else
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $dqsn_out_clock(src) $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add
`endif
`endif
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
`ifdef IPTCL_MEM_LEVELING
`ifdef IPTCL_STRATIXV
			set_clock_uncertainty -to [ get_clocks $dqsn_out_clock(dst)_OUT ] 0
`else
			set_clock_uncertainty -from [get_clocks ${inst}|memphy_leveling_clk] -to [ get_clocks $dqsn_out_clock(dst)_OUT ] 0
`endif
`else
			set_clock_uncertainty -to [ get_clocks $dqsn_out_clock(dst)_OUT ] 0
`endif
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
	}


	##################
	#                #
	# READ DATA PATH #
	#                #
	##################

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		##################
		#                #
		# (Micro Model)  #
		#                #
		##################

		foreach { dqs_pin } $dqs_pins { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				set_max_delay -from [get_ports $dq_pin] -to $read_capture_ddio 0
				set_min_delay -from [get_ports $dq_pin] -to $read_capture_ddio [expr 0-$half_period]

				# Specifies the maximum delay difference between the DQ pin and the DQS pin:
				set_input_delay -max $final_data_input_max_delay -clock [get_clocks ${dqs_pin}_IN ] [get_ports $dq_pin] -add_delay

				# Specifies the minimum delay difference between the DQ pin and the DQS pin:
				set_input_delay -min $final_data_input_min_delay -clock [get_clocks ${dqs_pin}_IN ] [get_ports $dq_pin] -add_delay
			}
		}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
		##################
		#                #
		# (MACRO Model)  #
		#                #
		##################

		# Cut paths to read capture registers
		foreach { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				set_false_path -from $dq_pin
			}
		}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	}
`endif

`ifdef IPTCL_STRATIXV
`else
	# Constraint to increase resynchronization timing margin
	if {(($::quartus(nameofexecutable) eq "quartus_fit"))} {
		set_max_delay -from $pins(fifo_rdaddress_reg) -to $pins(fifo_rddata_reg) [memphy_round_3dp [expr $t(CK)/2.0]]
		set_min_delay -from $pins(fifo_rdaddress_reg) -to $pins(fifo_rddata_reg) 0
	}
`endif

	###################
	#                 #
	# WRITE DATA PATH #
	#                 #
	###################

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		###################
		#                 #
		# (Micro Model)   #
		#                 #
		###################

		foreach { dqs_pin } $dqs_pins { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				# Specifies the minimum delay difference between the DQS pin and the DQ pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks ${dqs_pin}_OUT ] [get_ports $dq_pin] -add_delay

				# Specifies the maximum delay difference between the DQS pin and the DQ pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks ${dqs_pin}_OUT ] [get_ports $dq_pin] -add_delay
			}
		}

		foreach { dqsn_pin } $dqsn_pins { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				# Specifies the minimum delay difference between the DQS#pin and the DQ pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks ${dqsn_pin}_OUT ] [get_ports $dq_pin] -add_delay

				# Specifies the maximum delay difference between the DQS#pin and the DQ pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks ${dqsn_pin}_OUT ] [get_ports $dq_pin] -add_delay
			}
		}

		foreach dqs_out_clock_struct $dqs_out_clocks {
			array set dqs_out_clock $dqs_out_clock_struct

			if { [string length $dqs_out_clock(dm_pin)] > 0 } {
				# Specifies the minimum delay difference between the DQS and the DM pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks $dqs_out_clock(dst)_OUT ] [get_ports $dqs_out_clock(dm_pin)] -add_delay

				# Specifies the maximum delay difference between the DQS and the DM pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks $dqs_out_clock(dst)_OUT ] [get_ports $dqs_out_clock(dm_pin)] -add_delay
			}
		}

		foreach dqsn_out_clock_struct $dqsn_out_clocks {
			array set dqsn_out_clock $dqsn_out_clock_struct

			if { [string length $dqsn_out_clock(dm_pin)] > 0 } {
				# Specifies the minimum delay difference between the DQS and the DM pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks $dqsn_out_clock(dst)_OUT ] [get_ports $dqsn_out_clock(dm_pin)] -add_delay

				# Specifies the maximum delay difference between the DQS and the DM pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks $dqsn_out_clock(dst)_OUT ] [get_ports $dqsn_out_clock(dm_pin)] -add_delay
			}
		}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
		###################
		#                 #
		# (MACRO Model)   #
		#                 #
		###################

		# Cut paths to write pads
		foreach { dq_pins } $q_groups {
			foreach { dq_pin } $dq_pins {
				set_false_path -from * -to $dq_pin
			}
		}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	}
`endif

	############
	#          #
	# A/C PATH #
	#          #
	############

	foreach { ck_pin } $ck_pins {
		# ac_pins can contain input ports such as mem_err_out_n
		# Loop through each ac pin to make sure we only apply set_output_delay to output ports
		foreach { ac_pin } $ac_pins {
			set ac_port [ get_ports $ac_pin ]
			if {[get_collection_size $ac_port] > 0} {
				if [ get_port_info -is_output_port $ac_port ] {
					# Specifies the minimum delay difference between the DQS pin and the address/control pins:
					set_output_delay -min $ac_min_delay -clock [get_clocks $ck_pin] $ac_port -add_delay

					# Specifies the maximum delay difference between the DQS pin and the address/control pins:
					set_output_delay -max $ac_max_delay -clock [get_clocks $ck_pin] $ac_port -add_delay
				}
			}
		}
	}

`ifdef IPTCL_FULL_RATE
`ifdef IPTCL_USE_LDC_FOR_ADDR_CMD
	# Only the rising edge-launched control data needs to be timing analyzed in full rate
	set_false_path -fall_from [ get_clocks ${local_pll_write_clk} ] -to [ get_ports $ac_pins ]
`else
	# Only the rising edge-launched control data needs to be timing analyzed in full rate
	set_false_path -fall_from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_ports $ac_pins ]
`endif	
`endif

	##########################
	#                        #
	# MULTICYCLE CONSTRAINTS #
	#                        #
	##########################


`ifdef IPTCL_NIOS_SEQUENCER
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers -nowarn [list ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel ${prefix}|*p0|*altdq_dqs2_inst|oct_*reg*]]] -setup 3
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers -nowarn [list ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel ${prefix}|*p0|*altdq_dqs2_inst|oct_*reg*]]] -hold 2
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
`endif

	if { [get_collection_size [get_registers -nowarn ${prefix}|*p0|*umemphy|*uio_pads|*uaddr_cmd_pads|*clock_gen[*].umem_ck_pad|*]] > 0 } {
		set_multicycle_path -to [get_registers ${prefix}|*p0|*umemphy|*uio_pads|*uaddr_cmd_pads|*clock_gen[*].umem_ck_pad|*] -end -setup 4
		set_multicycle_path -to [get_registers ${prefix}|*p0|*umemphy|*uio_pads|*uaddr_cmd_pads|*clock_gen[*].umem_ck_pad|*] -end -hold 4
	}
	
`ifdef IPTCL_USE_LDC_FOR_ADDR_CMD
`else
	`ifdef IPTCL_FULL_RATE
	`else
	# Set multicycle path between address command clock and mem clock when COMMAND_PHASE is > 90 degrees or < -90 degrees
	if {(270 - $::GLOBAL_pll_phase(3)) > 90 || ($::GLOBAL_pll_phase(3) - 270) > 90} {
		foreach { ck_pin } $ck_pins {
			set_multicycle_path -from [get_clocks $local_pll_addr_cmd_clk] -to [get_clocks $ck_pin] -setup -end 2
			set_multicycle_path -from [get_clocks $local_pll_addr_cmd_clk] -to [get_clocks $ck_pin] -hold -start 1
		}
	}
	`endif
`endif

`ifdef IPTCL_PHY_ONLY
`else
`ifdef IPTCL_NEXTGEN
`ifdef IPTCL_PHY_CSR_ENABLED
	set_multicycle_path -from [get_registers ${prefix}|*c0|*ng0|*alt_mem_ddrx_controller_top_inst|*register_control_inst|csr_*] -to [get_registers *] -end -setup 2
	set_multicycle_path -from [get_registers ${prefix}|*c0|*ng0|*alt_mem_ddrx_controller_top_inst|*register_control_inst|csr_*] -to [get_registers *] -end -hold 1
`endif
`endif
`endif

	##########################
	#                        #
	# FALSE PATH CONSTRAINTS #
	#                        #
	##########################

`ifdef IPTCL_STRATIXV
`else
`ifdef IPTCL_ACV_FAMILY
`else
	# Cut calibrated paths from DQS enable clock to DQS
	set_false_path -from $pins(dqs_enable_ctrl_reg) -to $pins(dqs_enable_reg)
	set_false_path -from $pins(dqs_enable_ctrl_extend_reg) -to $pins(dqs_enable_reg)
`endif
`endif

`ifdef IPTCL_STRATIXV
	# Cut calibrated paths between HR reg domain and everything clocked by the x-phase CPS
 `ifdef IPTCL_FULL_RATE
	set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_fanouts $dq_xphase_cps_pins]
	set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_fanouts $dqs_xphase_cps_pins]
 `else
	set_false_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_fanouts $dq_xphase_cps_pins]
	set_false_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_fanouts $dqs_xphase_cps_pins]
 `endif
  if { [get_collection_size [get_clocks -nowarn "$local_pll_c2p_write_clock"]] > 0 } {
	set_false_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_keepers $phase_transfer_pins]
  }
`else
`endif

	# Cut paths for memory clocks to avoid unconstrained warnings
	foreach { pin } [concat $dqs_pins $dqsn_pins $ck_pins $ckn_pins] {
		set_false_path -to [get_ports $pin]
	}

`ifdef IPTCL_READ_FIFO_HALF_RATE
`ifdef IPTCL_ACV_FAMILY
`else
	foreach dqs_in_clock_struct $dqs_in_clocks dqsn_out_clock_struct $dqsn_out_clocks {
		array set dqs_in_clock $dqs_in_clock_struct
		array set dqsn_out_clock $dqsn_out_clock_struct

		set_clock_groups -physically_exclusive	-group "$dqs_in_clock(dqs_pin)_IN $dqs_in_clock(div_name)" -group "$dqs_in_clock(dqs_pin)_OUT $dqsn_out_clock(dst)_OUT"

		# Cut paths between AFI Clock and Div Clock
		set_false_path -from [ get_clocks $local_pll_afi_clk ] -to [ get_clocks $dqs_in_clock(div_name) ]
		if { [get_collection_size [get_clocks -nowarn  $pll_afi_clock]] > 0 } {
			set_false_path -from [ get_clocks $pll_afi_clock ] -to [ get_clocks $dqs_in_clock(div_name) ]
		}
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
		set_false_path -from [ get_clocks $local_pll_afi_half_clk ] -to [ get_clocks $dqs_in_clock(div_name) ]
		if { [get_collection_size [get_clocks -nowarn  $pll_afi_half_clock]] > 0 } {
			set_false_path -from [ get_clocks $pll_afi_half_clock ] -to [ get_clocks $dqs_in_clock(div_name) ]
		}
`endif

		# Cut reset path to clock divider (reset signal controlled by the sequencer)
		set_false_path -from [ get_clocks $local_pll_afi_clk ] -to $dqs_in_clock(div_pin)
		if { [get_collection_size [get_clocks -nowarn  $pll_afi_clock]] > 0 } {
			set_false_path -from [ get_clocks $pll_afi_clock ] -to $dqs_in_clock(div_pin)
		}
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
		set_false_path -from [ get_clocks $local_pll_afi_half_clk ] -to $dqs_in_clock(div_pin)
		if { [get_collection_size [get_clocks -nowarn  $pll_afi_half_clock]] > 0 } {
			set_false_path -from [ get_clocks $pll_afi_half_clock ] -to $dqs_in_clock(div_pin)
		}
`endif
		# Cut reset path from sequencer to the clock divider
		set_false_path -from $seq_reset_reg -to $dqs_in_clock(div_pin)
	}
`endif
`else
	if { ! $use_hard_read_fifo || ! $synthesis_flow } {
		foreach dqs_in_clock_struct $dqs_in_clocks dqsn_out_clock_struct $dqsn_out_clocks {
			array set dqs_in_clock $dqs_in_clock_struct
			array set dqsn_out_clock $dqsn_out_clock_struct

			set_clock_groups -physically_exclusive	-group "$dqs_in_clock(dqs_pin)_IN $dqs_in_clock(div_name)" -group "$dqs_in_clock(dqs_pin)_OUT $dqsn_out_clock(dst)_OUT"
			
			# Cut paths between DQS_OUT and Read Capture Registers
			set_false_path -from [get_clocks $dqs_in_clock(dqs_pin)_OUT] -to [get_registers $fifo_wrdata_reg]
			set_false_path -from [get_clocks $dqs_in_clock(dqs_pin)_OUT] -to [get_registers $fifo_wraddress_reg]

			# Cut paths between DQS_OUT and Read Capture Registers
			set_false_path -from [get_clocks $dqsn_out_clock(dst)_OUT] -to [get_registers $fifo_wrdata_reg]
			set_false_path -from [get_clocks $dqsn_out_clock(dst)_OUT] -to [get_registers $fifo_wraddress_reg]
		}

		# Cut paths between AFI Clock and Read Capture Registers
		set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_registers $fifo_wrdata_reg]
		set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_registers $fifo_wraddress_reg]
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
		set_false_path -from [get_clocks $local_pll_afi_half_clk] -to [get_registers $fifo_wrdata_reg]
		set_false_path -from [get_clocks $local_pll_afi_half_clk] -to [get_registers $fifo_wraddress_reg]
`endif
		if {[get_collection_size [get_clocks $pll_afi_clock -nowarn]] > 0} {
			set_false_path -from [get_clocks $pll_afi_clock] -to [get_registers $fifo_wrdata_reg]
			set_false_path -from [get_clocks $pll_afi_clock] -to [get_registers $fifo_wraddress_reg]
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
			set_false_path -from [get_clocks $pll_afi_half_clock] -to [get_registers $fifo_wrdata_reg]
			set_false_path -from [get_clocks $pll_afi_half_clock] -to [get_registers $fifo_wraddress_reg]
`endif
		}
	}
`endif

`ifdef IPTCL_ACV_FAMILY
`else
	# This is a register based memory operating as an asynchronous FIFO
	# therefore there is no timing path between the write and read side
	if { ! $use_hard_read_fifo || ! $synthesis_flow } {
		set_false_path -from [get_registers $fifo_wrdata_reg] -to [get_registers $fifo_rddata_reg]
		
`ifdef IPTCL_USE_HARD_READ_FIFO
`ifdef IPTCL_FULL_RATE
		if {$sta_flow} {
			set_false_path -to [get_registers "${prefix}|*read_fifos[*].*dataout2_dont_care"]
			set_false_path -to [get_registers "${prefix}|*read_fifos[*].*dataout3_dont_care"]
		}
`endif
`endif
	}


	# The paths between DQS_ENA_CLK and DQS_IN are calibrated, so they must not be analyzed
	set_false_path -from [get_clocks $local_pll_write_clk] -to [get_clocks {*_IN}]

`ifdef HCX_COMPAT_MODE
	set_false_path -through *predelayed_oe* -to $all_dq_pins
`endif
`endif

	# Cut paths between the afi_half and avl clocks
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set_false_path -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_afi_half_clk]
	set_false_path -from [get_clocks $local_pll_afi_half_clk] -to [get_clocks $local_pll_avl_clock]
`endif

`ifdef IPTCL_AC_PARITY
	# AC parity false paths
	set_false_path -from [get_ports *mem_err_out_n*]
	set_false_path -to [get_ports *parity_error_n*]
`endif

	# The following registers serve as anchors for the pin_map.tcl
	# script and are not used by the IP during memory operation
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set_false_path -from $pins(afi_half_ck_pins) -to $pins(afi_half_ck_pins)
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK	
	set_false_path -from $pins(p2c_read_ck_pins) -to $pins(p2c_read_ck_pins)
`endif	
`ifdef IPTCL_QUARTER_RATE
	set_false_path -from $pins(hr_ck_pins) -to $pins(hr_ck_pins)
`endif

`ifdef IPTCL_FULL_RATE
	set tCK_AFI $t(CK)
`endif
`ifdef IPTCL_HALF_RATE
	set tCK_AFI [ expr $t(CK) * 2.0 ]
`endif
`ifdef IPTCL_QUARTER_RATE
	set tCK_AFI [ expr $t(CK) * 4.0 ]
`endif
	
	`ifdef IPTCL_USE_HARD_READ_FIFO
	set capture_reg ${prefix}*capture_reg*
	`else
	set capture_reg ${prefix}*read_data_out*
	`endif

`ifdef IPTCL_ACV_FAMILY
`else
	# Add clock (DQS) uncertainty applied from the DDIO registers to registers in the core
`ifdef HCX_COMPAT_MODE
	if {(($::quartus(nameofexecutable) eq "quartus_fit") || ($::quartus(nameofexecutable) eq "quartus_map"))} {
		set value -0.05
		if { $t(CK) < 2.0 } {
			set value -0.3
		}
		set_max_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg $value
	} else {
		set_max_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg -0.05
	}
	set_min_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg [ memphy_round_3dp [expr -$t(CK) + 0.15 ]]
`else
	set_max_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg -0.05
	set_min_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg [ memphy_round_3dp [expr -$t(CK) + 0.2 ]]
`endif
`endif

`ifdef HCX_COMPAT_MODE
	if {(($::quartus(nameofexecutable) eq "quartus_fit") || ($::quartus(nameofexecutable) eq "quartus_map"))} {
`ifdef IPTCL_READ_FIFO_HALF_RATE	
		foreach dqs_in_clock_struct $dqs_in_clocks {
			array set dqs_in_clock $dqs_in_clock_struct
			set value [expr $t(CK) - 0.25]
			if { $t(CK) > 3.3 && $t(CK) < 3.4 || $t(CK) < 2 } {
				set value 0.7
			}
			set_max_delay -from $dqs_in_clock(div_pin) -to $dqs_in_clock(div_pin) $value
			set_min_delay -from $dqs_in_clock(div_pin) -to $dqs_in_clock(div_pin) 0
		}
`endif		
`ifdef IPTCL_NIOS_SEQUENCER
		set_max_delay -from ${prefix}*|W_alu_result[*] -to *${prefix}*|wraddr_reg[*]* [memphy_round_3dp [expr $t(refCK)/$::GLOBAL_pll_mult($avl_pll_clk_i)*$::GLOBAL_pll_div($avl_pll_clk_i)]]
		set_min_delay -from ${prefix}*|W_alu_result[*] -to *${prefix}*|wraddr_reg[*]* [expr 0 + 0.300]
		
		set_max_delay -from *|avl_wdata[*] -to *datain_reg0 [memphy_round_3dp [expr $t(refCK)/$::GLOBAL_pll_mult(0)*$::GLOBAL_pll_div(0)]]
		set_min_delay -from *|avl_wdata[*] -to *datain_reg0 [expr 0 + 0.300]

		set_max_delay -from *|avl_be[*] -to *datain_reg0 [memphy_round_3dp [expr $t(refCK)/$::GLOBAL_pll_mult(0)*$::GLOBAL_pll_div(0)]]
		set_min_delay -from *|avl_be[*] -to *datain_reg0 [expr 0 + 0.200]
`endif

		set_max_delay -from ${prefix}*counter_reg_bit[*] -to *ram_block*reg0 [memphy_round_3dp [expr $t(refCK)/$::GLOBAL_pll_mult(0)*$::GLOBAL_pll_div(0)]]
		set_min_delay -from ${prefix}*counter_reg_bit[*] -to *ram_block*reg0 [expr 0 + 0.2]

	}
	set_multicycle_path -from ${prefix}*ureset_addr_cmd_clk|reset_reg[3] -setup 2
	set_multicycle_path -from ${prefix}*ureset_addr_cmd_clk|reset_reg[3] -hold 1
`endif
}

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
	if {(($::quartus(nameofexecutable) ne "quartus_fit") && ($::quartus(nameofexecutable) ne "quartus_map"))} {
		set dqs_clocks [memphy_get_all_instances_dqs_pins memphy_ddr_db]
		# Leave clocks active when in debug mode
		if {[llength $dqs_clocks] > 0 && !$debug} {
			post_sdc_message info "Setting DQS clocks as inactive; use Report DDR to timing analyze DQS clocks"
			set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $dqs_clocks]]
		}
	}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
}
`endif

`ifdef IPTCL_ACV_FAMILY
	set_false_path -from $pll_ref_clock
	set_false_path -to $pll_ref_clock
	set_false_path -from [get_clocks {altera_reserved_tck}]
	set_false_path -to [get_clocks {altera_reserved_tck}]
	set_false_path -hold -to *d0*
	set_false_path -hold -to *if0_c0*reg0
	set_false_path -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_afi_clk]
	set_false_path -from *afi_rdata_valid
	set_false_path -to *afi_rdata_valid
	set_false_path -to *d0*reg0
	set_false_path -from *if0_c0*cmd_if_ready
	set_false_path -from *if0_c0*cmd_gen_read
	set_false_path -from *if0_c0*list_v[*]
	set_false_path -from *d0*
	set_false_path -to *d0*
	set_false_path -from *col_grant*
	set_false_path -to *alt_ddrx_cmd_queue*
	set_false_path -from *alt_ddrx_state_machine*
	set_false_path -from *alt_ddrx_input_if*
	set_false_path -from *alt_ddrx_rank_monitor*
	set_false_path -from *alt_ddrx_bank_timer_wrapper*
	set_false_path -from *rw_manager_ddr3*
	set_false_path -from *sequencer_phy_mgr*
	set_false_path -to *alt_mem_ddrx_tbp*
	set_false_path -from *alt_mem_ddrx_tbp*
	set_false_path -from *alt_mem_ddrx_fifo*
	set_false_path -to *alt_mem_ddrx_sideband*
	set_false_path -from *alt_mem_ddrx_rdata_path*
	set_false_path -to *afi_mux_ddr3*
	set_false_path -from *alt_mem_ddrx_arbiter*
	set_false_path -from *wdatap_dataid_manager*
	set_false_path -from *alt_mem_ddrx_sideband*
	set_false_path -from *alt_mem_ddrx_timing_param*
	set_false_path -from *alt_mem_ddrx_burst_tracking*
	set_false_path -to *alt_mem_ddrx_wdata_path*
	set_false_path -to *alt_mem_ddrx_arbiter*
	set_false_path -from *alt_mem_ddrx_cmd_gen*
	set_false_path -to *alt_mem_ddrx_cmd_gen*
	set_false_path -from *alt_mem_ddrx_rank_timer*
	set_false_path -from altera_merlin_master_translator*
	set_false_path -from altera_merlin_slave_translator*
	set_false_path -from altera_reset_controller*
	set_multicycle_path -from *if0_p0_reset_sync*reset_reg[*] -setup -end 2
	set_multicycle_path -from *if0_p0_reset_sync*reset_reg[*] -hold -end 1
	
`ifdef IPTCL_HARD_PHY
	set_false_path -from *if0_p0_acv_hard_memphy*afi_clk_reg
	set_false_path -from *if0_p0_acv_hard_memphy*dut_if0_p0_reset_sync*reset_reg[*]
	set_false_path -to *altdq_dqs2_acv_arriav_connect_to_hard_phy*output_*_gen[*]*
	set_false_path -to *altdq_dqs2_acv_arriav_connect_to_hard_phy*oct_oe_reg
	set_false_path -to *altdq_dqs2_acv_arriav_connect_to_hard_phy*os_oe_reg
	set_false_path -to *altdq_dqs2_acv_arriav_connect_to_hard_phy*phase_align_os*
	set_false_path -to *if0_p0_acv_hard_addr_cmd_pads*acblock[*].ddio_out*
	
	set ac_pins [ concat $pins(add_pins) $pins(ba_pins) $pins(cmd_pins) $pins(reset_pins) ]
	foreach pin $ac_pins {
		set_multicycle_path -from $pll_afi_clock -to $pin -setup -end 2
		set_multicycle_path -from $pll_afi_clock -to $pin -hold -end 2
		set_multicycle_path -from $pll_ck_clock -to $pin -setup -end 2
		set_multicycle_path -from $pll_ck_clock -to $pin -hold -end 2
	}
`endif
`endif


######################
#                    #
# REPORT DDR COMMAND #
#                    #
######################

add_ddr_report_command "source [list [file join [file dirname [info script]] ${::GLOBAL_corename}_report_timing.tcl]]"

