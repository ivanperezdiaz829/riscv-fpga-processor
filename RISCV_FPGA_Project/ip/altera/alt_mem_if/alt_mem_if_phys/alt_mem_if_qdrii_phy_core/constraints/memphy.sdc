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

`ifdef IPTCL_REMOVE_WRITE_PESSIMISM
`else
# This is a global setting and will apply to the whole design.
# This setting is required for the memory interface to be
# properly constrained.
derive_clock_uncertainty

`endif
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

	set io_standard "$::GLOBAL_io_standard CLASS I"

	# This is the peak-to-peak jitter on the whole read capture path
`ifdef IPTCL_STRATIXV
	set DQSpathjitter [expr [get_micro_node_delay -micro DQDQS_JITTER -parameters [list IO] -in_fitter]/1000.0]
	set DQSpathjitter_setup_prop [expr [get_micro_node_delay -micro DQDQS_JITTER_DIVISION -parameters [list IO] -in_fitter]/100.0]
`else	
	set DQSpathjitter [expr [get_io_standard_node_delay -dst DQDQS_JITTER -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/1000.0]
	set DQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst DQDQS_JITTER_DIVISION -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/100.0]
`endif

	# This is the peak-to-peak jitter on the whole write path
	set outputDQSpathjitter [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/1000.0]
	set outputDQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER_DIVISION -io_standard $io_standard -parameters [list IO $::GLOBAL_io_interface_type] -in_fitter]/100.0]

	##################
	#                #
	# DERIVED TIMING #
	#                #
	##################

	# These parameters are used to make constraints more readeable

	# Half of memory clock cycle
	set half_period [ memphy_round_3dp [ expr $t(CYC) / 2.0 ] ]

	# Half of reference clock
	set ref_half_period [ memphy_round_3dp [ expr $t(refCK) / 2.0 ] ]

	# Minimum delay on data output pins
	set t(wru_output_min_delay_external) [expr $t(HD) + $board(intra_K_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 - $board(data_K_skew)]
`ifdef IPTCL_STRATIXV
	set t(wru_output_min_delay_internal) [expr $t(WL_DCD) + $t(WL_PSE) + $t(WL_JITTER)*(1.0-$t(WL_JITTER_DIVISION)) + $SSN(rel_pullin_o)]
`else
	set t(wru_output_min_delay_internal) [expr $outputDQSpathjitter*(1.0-$outputDQSpathjitter_setup_prop) + $SSN(rel_pullin_o)]
`endif
	set data_output_min_delay [ memphy_round_3dp [ expr - $t(wru_output_min_delay_external) - $t(wru_output_min_delay_internal)]]

	# Maximum delay on data output pins
	set t(wru_output_max_delay_external) [expr $t(SD) + $board(intra_K_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 + $board(data_K_skew)]
`ifdef IPTCL_STRATIXV
	set t(wru_output_max_delay_internal) [expr $t(WL_DCD) + $t(WL_PSE) + $t(WL_JITTER)*$t(WL_JITTER_DIVISION) + $SSN(rel_pushout_o)]
`else
	set t(wru_output_max_delay_internal) [expr $outputDQSpathjitter*$outputDQSpathjitter_setup_prop + $SSN(rel_pushout_o)]
`endif
	set data_output_max_delay [ memphy_round_3dp [ expr $t(wru_output_max_delay_external) + $t(wru_output_max_delay_internal)]]

	# Maximum delay on data input pins
	set t(rdu_input_max_delay_external) [expr $t(CQD) + $board(intra_CQ_group_skew) + $board(data_CQ_skew)]
	set t(rdu_input_max_delay_internal) [expr $DQSpathjitter*$DQSpathjitter_setup_prop + $SSN(rel_pushout_i)]
	set data_input_max_delay [ memphy_round_3dp [ expr $t(rdu_input_max_delay_external) + $t(rdu_input_max_delay_internal) ]]

	# Minimum delay on data input pins
	set t(rdu_input_min_delay_external) [expr -$t(CQDOH) + $board(intra_CQ_group_skew) - $board(data_CQ_skew)]
	set t(rdu_input_min_delay_internal) [expr $t(DCD) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $SSN(rel_pullin_i)]
	set data_input_min_delay [ memphy_round_3dp [ expr - $t(rdu_input_min_delay_external) - $t(rdu_input_min_delay_internal) ]]

	# Minimum delay on address and command paths
	set ac_min_delay [ memphy_round_3dp [ expr - $t(HA) - $fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) - $ISI(addresscmd_hold)]]

	# Maximum delay on address and command paths
	set ac_max_delay [ memphy_round_3dp [ expr $t(SA) + $fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) + $ISI(addresscmd_setup)]]
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
	set half_period [ memphy_round_3dp [ expr $t(CYC) / 2.0 ] ]

	# Half of reference clock
	set ref_half_period [ memphy_round_3dp [ expr $t(refCK) / 2.0 ] ]

	# Minimum delay on data output pins
	set data_output_min_delay [ memphy_round_3dp [ expr - $t(HD) - $fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_K_group_skew) - $SSN(rel_pullin_o) ]]

	# Maximum delay on data output pins
	set data_output_max_delay [ memphy_round_3dp [ expr $t(SD) + $fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_K_group_skew) + $SSN(rel_pushout_o) ]]

	# Maximum delay on data input pins
	set data_input_max_delay [ memphy_round_3dp [ expr $t(CQD) + $board(intra_CQ_group_skew) + $SSN(rel_pushout_i) ]]

	# Minimum delay on data input pins
	set data_input_min_delay [ memphy_round_3dp [ expr $t(CQDOH) -$t(DCD) - $board(intra_CQ_group_skew) - $SSN(rel_pullin_i) ]]

	# Minimum delay on address and command paths
	set ac_min_delay [ memphy_round_3dp [ expr - $t(HA) - $fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) ]]

	# Maximum delay on address and command paths
	set ac_max_delay [ memphy_round_3dp [ expr $t(SA) + $fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) ]]
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

	set cq_pins $pins(cq_pins)
	set cq_n_pins $pins(cq_n_pins)
	set q_groups [ list ]
	foreach { q_group } $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}

	set k_pins $pins(k_pins)
	set kn_pins $pins(kn_pins)
	set d_groups [ list ]

	foreach { d_group } $pins(d_groups) {
		set d_group $d_group
		lappend d_groups $d_group
	}
	set all_d_pins [ join [ join $d_groups ] ]
	set add_pins $pins(add_pins)
	set cmd_pins $pins(cmd_pins)
	set ac_pins [ concat $add_pins $cmd_pins ]
	set bws_groups $pins(bws_groups)
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set k_leveling_pins $pins(k_leveling_pins)
	set d_leveling_pins $pins(d_leveling_pins)
	set ac_leveling_pins $pins(ac_leveling_pins)
`endif	

	set pll_ref_clock $pins(pll_ref_clock)
	set pll_afi_clock $pins(pll_afi_clock)
	set pll_k_clock $pins(pll_k_clock)
	set pll_d_clock $pins(pll_d_clock)
	set pll_ac_clock $pins(pll_ac_clock)
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock $pins(pll_afi_half_clock)
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock $pins(pll_avl_clock)
	set pll_config_clock $pins(pll_config_clock)
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pll_p2c_read_clock $pins(pll_p2c_read_clock)
	set pll_c2p_write_clock $pins(pll_c2p_write_clock)
`endif

	set dqs_in_clocks $pins(dqs_in_clocks)
	set read_capture_ddio $pins(read_capture_ddio)
	set read_capture_ddio_capture $pins(read_capture_ddio_capture)
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

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		# Mimimum delay requirement for hold constraint on read path
		set data_input_min_constraint [ memphy_round_3dp [ expr - ($t(CYC) * 0.5 - $t(INTERNAL_JITTER) ) + $fpga(tDQS_PSERR) ]]

		# Maximum delay requirement for setup constraint on read path
		set data_input_max_constraint [ memphy_round_3dp [ expr - $fpga(tDQS_PSERR) ]]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
		# Mimimum delay requirement for hold constraint on read path
		set data_input_min_constraint [ memphy_round_3dp [ expr - ($t(CYC) * 0.5 - $t(INTERNAL_JITTER) ) + $fpga(tDQS_PHASE_JITTER) + $fpga(tDQS_PSERR) ]]

		# Maximum delay requirement for setup constraint on read path
		set data_input_max_constraint [ memphy_round_3dp [ expr - $fpga(tDQS_PHASE_JITTER) - $fpga(tDQS_PSERR) ]]
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

	# PLL Clock Names
	set local_pll_afi_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_afi_clock "afi_clk"]
	set local_pll_mem_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_k_clock "mem_clk"]
	set local_pll_addr_cmd_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_ac_clock "addr_cmd_clk"]
	set local_pll_write_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_d_clock "write_clk"]
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set local_pll_afi_half_clk [memphy_get_clock_name_from_pin_name_pre_vseries $pll_afi_half_clock "afi_half_clk"]
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set local_pll_avl_clock [memphy_get_clock_name_from_pin_name_pre_vseries $pll_avl_clock "avl_clk"]
	set local_pll_config_clock [memphy_get_clock_name_from_pin_name_pre_vseries $pll_config_clock "config_clk"]
`endif

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

	set write_clk_phase $::GLOBAL_pll_phase(2)
	if {[string compare -nocase $pll_d_clock $pll_afi_clock]==0} {
		set local_pll_write_clk $local_pll_afi_clk
	} else {
		create_generated_clock -add -name "$local_pll_write_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(2) -divide_by $::GLOBAL_pll_div(2) -phase $write_clk_phase $pll_d_clock
	}
	
	set mem_clk_phase $::GLOBAL_pll_phase(1)
	create_generated_clock -add -name "$local_pll_mem_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(1) -divide_by $::GLOBAL_pll_div(1) -phase $mem_clk_phase $pll_k_clock
	
`ifdef IPTCL_FULL_RATE
	if {$mem_clk_phase > 0 && $mem_clk_phase < 270} {	
		set_multicycle_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_mem_clk] -setup 2
	}
`endif		
	create_generated_clock -add -name "$local_pll_addr_cmd_clk" -source $pll_ref_clock -multiply_by $::GLOBAL_pll_mult(3) -divide_by $::GLOBAL_pll_div(3) -phase $::GLOBAL_pll_phase(3) $pll_ac_clock

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
`ifdef IPTCL_NIOS_SEQUENCER
		if {[string compare -nocase $pll_avl_clock $pll_afi_clock] != 0} {
			set_clock_uncertainty -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_afi_clk] -add -hold 0.100
			set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_avl_clock] -add -hold 0.050
		}
`endif
`ifdef HCX_COMPAT_MODE
	set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_addr_cmd_clk] -add -setup 0.200
`endif
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


	# ------------------- #
	# -                 - #
	# --- READ CLOCKS --- #
	# -                 - #
	# ------------------- #
	set use_div_clock 0
`ifdef IPTCL_READ_FIFO_HALF_RATE
	set use_div_clock 1
`endif
`ifdef IPTCL_USE_IO_CLOCK_DIVIDER
	set use_div_clock 1
`endif
`ifdef IPTCL_ACV_FAMILY
	set use_div_clock 0
`endif

	foreach { cq_pin } $cq_pins { dqs_in_clock_struct } $dqs_in_clocks {
		# This is the CQ clock for Read Capture analysis (micro model)
		create_clock -period $t(CYC) -waveform [ list 0 $half_period ] $cq_pin -name $cq_pin

`ifdef IPTCL_RL2
`else
		if { $use_div_clock } {
			# DIV clock is generated on the output of the clock divider.
			array set dqs_in_clock $dqs_in_clock_struct
			create_generated_clock -name $dqs_in_clock(div_name) -source $cq_pin -divide_by 2 $dqs_in_clock(div_pin) -master $cq_pin
		}
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
			set_clock_uncertainty -from [ get_clocks $cq_pin ] 0
			set_clock_uncertainty -to [ get_clocks $cq_pin ] 0
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
	}

	# This is the CQn clock for Read Capture analysis (micro model)
	foreach { cq_n_pin } $cq_n_pins { dqs_in_clock_struct } $dqs_in_clocks {
		if {$cq_n_pin == ""} {
			continue
		}
		create_clock -period $t(CYC) -waveform [ list $half_period $t(CYC) ] $cq_n_pin -name $cq_n_pin

`ifdef IPTCL_RL2
		if { $use_div_clock } {
			# DIV clock is generated on the output of the clock divider.
			array set dqs_in_clock $dqs_in_clock_struct
			create_generated_clock -name $dqs_in_clock(div_name) -source $cq_n_pin -divide_by 2 $dqs_in_clock(div_pin) -master $cq_n_pin
		}
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
			set_clock_uncertainty -from [ get_clocks $cq_n_pin ] 0
			set_clock_uncertainty -to [ get_clocks $cq_n_pin ] 0
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
	}

	# -------------------- #
	# -                  - #
	# --- WRITE CLOCKS --- #
	# -                  - #
	# -------------------- #

	# This is the K clock for Data Write analysis (micro model) and A/C analysis
	for { set i 0 } { $i < [ llength $k_pins ] } { incr i } {
		set k_pin [ lindex $k_pins $i ]
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
		set k_leveling_pin [ lindex $k_leveling_pins $i ]
 `ifdef IPTCL_BURST_2
 		create_generated_clock -add -multiply_by 1 -source $k_leveling_pin -master_clock "${local_leveling_clock_k}_${i}" $k_pin -name $k_pin
 `else		
		create_generated_clock -add -multiply_by 1 -invert -source $k_leveling_pin -master_clock "${local_leveling_clock_k}_${i}" $k_pin -name $k_pin
 `endif		
`else	
		create_generated_clock -add -multiply_by 1 -source $pll_k_clock -master_clock "$local_pll_mem_clk" $k_pin -name $k_pin
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
			set_clock_uncertainty -to [ get_clocks $k_pin ] 0
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
	}

	# This is the Kn clock for Data Write analysis (micro model) and A/C analysis
	for { set i 0 } { $i < [ llength $kn_pins ] } { incr i } {
		set kn_pin [ lindex $kn_pins $i ]
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
		set k_leveling_pin [ lindex $k_leveling_pins $i ]
 `ifdef IPTCL_BURST_2
		create_generated_clock -add -multiply_by 1 -invert -source $k_leveling_pin -master_clock "${local_leveling_clock_k}_${i}" $kn_pin -name $kn_pin
 `else		
		create_generated_clock -add -multiply_by 1 -source $k_leveling_pin -master_clock "${local_leveling_clock_k}_${i}" $kn_pin -name $kn_pin
 `endif		
`else
		create_generated_clock -add -multiply_by 1 -invert -source $pll_k_clock -master_clock "$local_pll_mem_clk" $kn_pin -name $kn_pin
`endif

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			# Clock Uncertainty is accounted for by the ...pathjitter parameters
			set_clock_uncertainty -to [ get_clocks $kn_pin ] 0
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
`ifdef IPTCL_ACV_FAMILY
`else
		##################
		#                #
		# (Micro Model)  #
		#                #
		##################
		if { ! $synthesis_flow } {
			# The read capture DDIO registers don't yet exist in the timing netlist during synthesis
			foreach { q_pins } $q_groups {
				foreach { q_pin } $q_pins {
					# Specifies the setup relationship of the read input data at the Q pin
					set_max_delay $data_input_max_constraint -from $q_pin -to $read_capture_ddio_capture

					# Specifies the hold relationship of the read input data at the Q pin
					set_min_delay $data_input_min_constraint -from $q_pin -to $read_capture_ddio_capture
				}
			}
		}
`endif

		foreach { cq_pin } $cq_pins { q_pins } $q_groups {
			foreach { q_pin } $q_pins {
				# Specifies the maximum delay difference between the Q pin and the CQ pin:
				set_input_delay -max $data_input_max_delay -clock [get_clocks $cq_pin] [get_ports $q_pin] -add_delay

				# Specifies the minimum delay difference between the Q pin and the CQ pin:
				set_input_delay -min $data_input_min_delay -clock [get_clocks $cq_pin] [get_ports $q_pin] -add_delay
			}
		}

		foreach { cq_n_pin } $cq_n_pins { q_pins } $q_groups {
			if {$cq_n_pin == ""} {
				continue
			}
			foreach { q_pin } $q_pins {
				# Specifies the maximum delay difference between the Q pin and the CQ pin:
				set_input_delay -max $data_input_max_delay -clock [get_clocks $cq_n_pin] [get_ports $q_pin] -add_delay

				# Specifies the minimum delay difference between the Q pin and the CQ pin:
				set_input_delay -min $data_input_min_delay -clock [get_clocks $cq_n_pin] [get_ports $q_pin] -add_delay
			}
		}

		# This constrains the path between registers in the DDIO
		# The default constraint applied by STA is half a clock cycle
		# but due to the memory device jitter, the rising edges of CQ and CQ#
		# can be less than half a clock cycle apart
		set half_clock_constraint [ memphy_round_3dp [ expr ($t(CYC) * 0.5 - $t(INTERNAL_JITTER) ) ]]
		foreach { cq_n_pin } $cq_n_pins { cq_pin } $cq_pins {
			if {$cq_n_pin == ""} {
				continue
			}
			set_max_delay $half_clock_constraint -from $cq_n_pin -to $cq_pin
			set_min_delay -$half_clock_constraint -from $cq_n_pin -to $cq_pin
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
		foreach { q_pins } $q_groups {
			foreach { q_pin } $q_pins {
				set_false_path -from $q_pin
			}
		}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
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

		set d_groups_per_k_pin [ expr [ llength $d_groups ] / [ llength $k_pins ] ]

		for { set i 0 } { $i < [ llength $d_groups ] } { incr i } {
			set k_pin [ lindex $k_pins [ expr $i / $d_groups_per_k_pin ] ]
			set kn_pin [ lindex $kn_pins [ expr $i / $d_groups_per_k_pin ] ]

			foreach { d_pin } [ lindex $d_groups $i ] {
				# Specifies the minimum delay difference between the K pin and the D pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks $k_pin] [get_ports $d_pin] -add_delay

				# Specifies the maximum delay difference between the K pin and the D pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks $k_pin] [get_ports $d_pin] -add_delay

				# Specifies the minimum delay difference between the Kn pin and the D pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks $kn_pin] [get_ports $d_pin] -add_delay

				# Specifies the maximum delay difference between the Kn pin and the D pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks $kn_pin] [get_ports $d_pin] -add_delay
			}

			foreach { bws_pin } [ lindex $bws_groups $i ] {
				# Specifies the minimum delay difference between the K pin and the D pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks $k_pin] [get_ports $bws_pin] -add_delay

				# Specifies the maximum delay difference between the K pin and the D pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks $k_pin] [get_ports $bws_pin] -add_delay

				# Specifies the minimum delay difference between the Kn pin and the D pins:
				set_output_delay -min $data_output_min_delay -clock [get_clocks $kn_pin] [get_ports $bws_pin] -add_delay

				# Specifies the maximum delay difference between the Kn pin and the D pins:
				set_output_delay -max $data_output_max_delay -clock [get_clocks $kn_pin] [get_ports $bws_pin] -add_delay
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
		foreach { d_pins } $d_groups {
			foreach { d_pin } $d_pins {
				set_false_path -from * -to $d_pin
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

	foreach { k_pin } $k_pins {
		# Specifies the minimum delay difference between the K pin and the address/control pins:
		set_output_delay -min $ac_min_delay -clock [get_clocks $k_pin] [ get_ports $ac_pins ] -add_delay

		# Specifies the maximum delay difference between the K pin and the address/control pins:
		set_output_delay -max $ac_max_delay -clock [get_clocks $k_pin] [ get_ports $ac_pins ] -add_delay
	}

`ifdef IPTCL_BURST_2
	foreach { kn_pin } $kn_pins {
		# Specifies the minimum delay difference between the Kn pin and the address/control pins:
		set_output_delay -min $ac_min_delay -clock [get_clocks $kn_pin] [ get_ports $ac_pins ] -add_delay

		# Specifies the maximum delay difference between the Kn pin and the address/control pins:
		set_output_delay -max $ac_max_delay -clock [get_clocks $kn_pin] [ get_ports $ac_pins ] -add_delay
	}
`endif

`ifdef IPTCL_BURST_2
	
	# The address and command bus is toggling at Double Data Rate. More specifically, data sent on the
	# rising edge of the addr_cmd_clk is captured by the rising edge of K and data sent on the falling
	# edge of addr_cmd_clk is captured by the rising edge of Kn. All other combinations of addr_cmd_clk
	# rise/fall and K/Kn rise/fall must be cut.
 `ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set_multicycle_path -setup 0 -fall_from [ get_clocks "${local_leveling_clock_ac}_*" ] -rise_to [ get_clocks $kn_pins ]
	set_multicycle_path -setup 0 -rise_from [ get_clocks "${local_leveling_clock_ac}_*" ] -rise_to [ get_clocks $k_pins ]
	set_multicycle_path -setup 0 -fall_from [ get_clocks "${local_leveling_clock_d}_*" ] -rise_to [ get_clocks $kn_pins ]
	set_multicycle_path -setup 0 -rise_from [ get_clocks "${local_leveling_clock_d}_*" ] -rise_to [ get_clocks $k_pins ]
 
	set_false_path -setup -fall_from [ get_clocks "${local_leveling_clock_ac}_*" ] -to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "${local_leveling_clock_ac}_*" ] -fall_to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "${local_leveling_clock_ac}_*" ] -to [ get_clocks $kn_pins ]
	set_false_path -setup -fall_from [ get_clocks "${local_leveling_clock_ac}_*" ] -fall_to [ get_clocks $kn_pins ]
	set_false_path -setup -fall_from [ get_clocks "${local_leveling_clock_d}_*" ] -to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "${local_leveling_clock_d}_*" ] -fall_to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "${local_leveling_clock_d}_*" ] -to [ get_clocks $kn_pins ]
	set_false_path -setup -fall_from [ get_clocks "${local_leveling_clock_d}_*" ] -fall_to [ get_clocks $kn_pins ]
 `else
	set_false_path -setup -fall_from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "$local_pll_addr_cmd_clk" ] -fall_to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_clocks $kn_pins ]
	set_false_path -setup -fall_from [ get_clocks "$local_pll_addr_cmd_clk" ] -fall_to [ get_clocks $kn_pins ]
 `endif
`else
 `ifdef IPTCL_FULL_RATE
 	# The address and command bus is toggling at Single Data Rate, and is only captured by
	# the rising edge of K. We need to cut the path from the falling edge of the addr_cmd_clk
	# and K and any path from the addr_cmd_clk and Kn
  `ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set_false_path -fall_from [ get_clocks "${local_leveling_clock_ac}_*" ] -to [ get_clocks $k_pins ]
  `else
	set_false_path -fall_from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_clocks $k_pins ]
	set_false_path -from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_clocks $kn_pins ]
  `endif	
 `endif
`endif

	##########################
	#                        #
	# MULTICYCLE CONSTRAINTS #
	#                        #
	##########################

`ifdef IPTCL_NIOS_SEQUENCER
`ifdef IPTCL_MEM_LEVELING
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -setup 3
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -hold 2
`else
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -setup 3
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -hold 2
`endif
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

	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|mux_sel"] -to [remove_from_collection [get_keepers *] [get_registers [list "${prefix}|*s0|*sequencer_inst|mux_sel"]]] -setup 3
	set_multicycle_path -from [get_registers "${prefix}|*s0|*sequencer_inst|mux_sel"] -to [remove_from_collection [get_keepers *] [get_registers [list "${prefix}|*s0|*sequencer_inst|mux_sel"]]] -hold 2
`endif

	##########################
	#                        #
	# FALSE PATH CONSTRAINTS #
	#                        #
	##########################

	# Cut paths for memory clocks to avoid unconstrained warnings
	foreach { pin } [concat $k_pins $kn_pins] {
		set_false_path -to [get_ports $pin]
	}

	set cut_oe_path 0
`ifdef HCX_COMPAT_MODE
	set cut_oe_path 1
`endif
`ifdef IPTCL_NIOS_SEQUENCER
`else
	set cut_oe_path 1
`endif
	if {$cut_oe_path} {
		set_false_path -through *oe_reg -to $all_d_pins
	}

	set use_div_clock 0
`ifdef IPTCL_READ_FIFO_HALF_RATE
	set use_div_clock 1
`endif
`ifdef IPTCL_USE_IO_CLOCK_DIVIDER
	set use_div_clock 1
`endif
`ifdef IPTCL_ACV_FAMILY
	set use_div_clock 0
`endif
	if {$use_div_clock} {
		foreach dqs_in_clock_struct $dqs_in_clocks {
			array set dqs_in_clock $dqs_in_clock_struct

			# Cut paths between AFI Clock and Div Clock
			set_false_path -from [ get_clocks $local_pll_afi_clk ] -to [ get_clocks $dqs_in_clock(div_name) ]
			if { [get_collection_size [get_clocks -nowarn  $pll_afi_clock]] > 0 } {
				set_false_path -from [ get_clocks $pll_afi_clock ] -to [ get_clocks $dqs_in_clock(div_name) ]
			}

`ifdef IPTCL_USE_IO_CLOCK_DIVIDER
`else
			# Cut reset path to clock divider (reset signal controlled by the sequencer)
			set_false_path -from [ get_clocks $local_pll_afi_clk ] -to $dqs_in_clock(div_pin)
			if { [get_collection_size [get_clocks -nowarn  $pll_afi_clock]] > 0 } {
				set_false_path -from [ get_clocks $pll_afi_clock ] -to $dqs_in_clock(div_pin)
			}
`endif			
		}
	}
	
`ifdef IPTCL_USE_HARD_READ_FIFO
 `ifdef IPTCL_FULL_RATE
	# We use a ddio_out as an FF for the transfer from the read fifo
	# write enable signal going from the DQS logic block to the hard 
	# read fifo. The second phase output of the ddio_out is always 
	# the same as the first phase. Cut the second phase transfer.
	# Note that the rise-from transfer is the real one, because
	# read fifo is synchronized with cq/cq_n (hence cutting fall-from).
	set_false_path -fall_from [get_clocks [concat $cq_pins $cq_n_pins]] -to [get_registers $fifo_wraddress_reg]
 `endif
 
	# The transfer from the write-enable ddio_out to the read fifo's write address FF
	# isn't timing analyzed properly due to unateness and delay modeling issues. This
	# is a hard path and so place-and-route isn't affected. This will be fixed in a
	# future release.
`ifdef IPTCL_FULL_RATE	
	set_false_path -from [get_clocks [concat $cq_pins $cq_n_pins]] -to [get_registers $fifo_wraddress_reg]
`else
	foreach dqs_in_clock_struct $dqs_in_clocks {
		array set dqs_in_clock $dqs_in_clock_struct
		set_false_path -from [get_clocks $dqs_in_clock(div_name)] -to [get_registers $fifo_wraddress_reg]
	}
`endif	
`endif	

`ifdef IPTCL_READ_FIFO_HALF_RATE
`else
	# Cut paths between AFI Clock and Read Capture Registers
	set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $cq_pins]
	if {[llength $cq_n_pins] > 0} {
		set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $cq_n_pins]
	}
	if {[get_collection_size [get_clocks $pll_afi_clock -nowarn]] > 0} {
		set_false_path -from [get_clocks $pll_afi_clock] -to [get_clocks $cq_pins]
		if {[llength $cq_n_pins] > 0} {
			set_false_path -from [get_clocks $pll_afi_clock] -to [get_clocks $cq_n_pins]
		}
	}
`endif

	# The following registers serve as anchors for the pin_map.tcl
	# script and are not used by the IP during memory operation
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set_false_path -from $pins(afi_half_ck_pins) -to $pins(afi_half_ck_pins)
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK	
	set_false_path -from $pins(p2c_read_ck_pins) -to $pins(p2c_read_ck_pins)
`endif	

`ifdef IPTCL_ACV_FAMILY
`else
	if { ! $use_hard_read_fifo || ! $synthesis_flow } {
		# This is a register based memory operating as an asynchronous FIFO
		# therefore there is no timing path between the write and read side
		if {$::quartus(nameofexecutable) eq "quartus_fit" && !$use_hard_read_fifo} {
			set_max_delay -from $pins(fifo_wrdata_reg) -to $pins(fifo_rddata_reg) [expr 3*$t(CYC)]
			set_min_delay -from $pins(fifo_wrdata_reg) -to $pins(fifo_rddata_reg) 0
		} else {
			set_false_path -from [get_registers $fifo_wrdata_reg] -to [get_registers $fifo_rddata_reg]
		}              
		set_false_path -from [get_registers $valid_fifo_wrdata_reg] -to [get_registers $valid_fifo_rddata_reg]
		
		# Constrain for the zero-cycle transfer between DDIO_IN and read FIFO.
		# This cannot be set during timing-driven synthesis because the DDIO
		# registers don't exist in the timing netlist at that stage. This does not
		# affect timing-driven synthesis.
		set_max_delay -from [get_registers $read_capture_ddio] -to $fifo_wrdata_reg -0.05
`ifdef HCX_COMPAT_MODE
		set_min_delay -from [get_registers $read_capture_ddio] -to $fifo_wrdata_reg [ memphy_round_3dp [expr -$t(CYC) + 0.15]]
`else   
`ifdef IPTCL_FULL_RATE
		set_min_delay -from [get_registers $read_capture_ddio] -to $fifo_wrdata_reg [ memphy_round_3dp [expr -$t(CYC) + 0.15]]
`else
		set_min_delay -from [get_registers $read_capture_ddio] -to $fifo_wrdata_reg [ memphy_round_3dp [expr -$t(CYC) + 0.20]]
`endif
`endif	

`ifdef IPTCL_FULL_RATE
		set tCYC_AFI $t(CYC)
`else
		set tCYC_AFI [ expr $t(CYC) * 2.0 ]
`endif
		# constraint the read latency of the data resynchronization FIFO to be within 1 cycle
		# the read clock of the data fifo is the AFI clock
		set_max_delay $tCYC_AFI -from [get_registers $fifo_rddata_reg]
		set_min_delay 0         -from [get_registers $fifo_rddata_reg]
	}
`endif
	
`ifdef HCX_COMPAT_MODE
`ifdef IPTCL_NIOS_SEQUENCER
	if {(($::quartus(nameofexecutable) eq "quartus_fit") || ($::quartus(nameofexecutable) eq "quartus_map"))} {
		set_max_delay -from ${prefix}*|MonDReg[*] -to *datain_reg0 [expr $t(refCK)/$::GLOBAL_pll_mult($avl_pll_clk_i)*$::GLOBAL_pll_div($avl_pll_clk_i)]
		set_min_delay -from ${prefix}*|MonDReg[*] -to *datain_reg0 [expr 0 + 0.170]

		set_max_delay -from ${prefix}*|W_alu_result[*]* -to *${prefix}*|wraddr_reg[*] [expr $t(refCK)/$::GLOBAL_pll_mult($avl_pll_clk_i)*$::GLOBAL_pll_div($avl_pll_clk_i)]
		set_min_delay -from ${prefix}*|W_alu_result[*]* -to *${prefix}*|wraddr_reg[*] [expr 0 + 0.300]
	}
`endif
	if {(($::quartus(nameofexecutable) eq "quartus_fit") || ($::quartus(nameofexecutable) eq "quartus_map"))} {
		if { $t(CYC) < 3 } {
			set dividers [get_keepers *${prefix}*read_capture_clk_div2*]
			set_max_delay -from $dividers -to $dividers 1.2
		}		
	}
`endif
}

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
	if {(($::quartus(nameofexecutable) ne "quartus_fit") && ($::quartus(nameofexecutable) ne "quartus_map"))} {
		set dqs_clocks [memphy_get_all_instances_dqs_pins memphy_ddr_db]
		if {[llength $dqs_clocks] > 0} {
			post_sdc_message info "Setting DQS clocks as inactive; use Report DDR to timing analyze DQS clocks"
			set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $dqs_clocks]]
		}
	}
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
}
`endif

`ifdef IPTCL_ACV_FAMILY
set_false_path -from [get_clocks {altera_reserved_tck}]
set_false_path -to [get_clocks {altera_reserved_tck}]
set_false_path -to *afi_rdata_valid
set_false_path -to *aligned_input[*] 
set_false_path -to *oe_reg
set_false_path -to *DFFLO
set_false_path -to *DFFHI0
set_false_path -from *afi_rdata_valid
set_multicycle_path -to $local_pll_addr_cmd_clk -setup -end 2
set_multicycle_path -from $local_pll_addr_cmd_clk -hold -end 1
set_multicycle_path -from $local_pll_write_clk -hold 2
set_false_path -from *d0*traffic_generator*
set_false_path -to *d0*traffic_generator*
set_false_path -to *c0*cmd1_valid
set_false_path -to *p0*vfifo*
set_false_path -to *p0*lfifo*
set_false_path -from *rw_manager_core*
set_false_path -from *if0_c0_memctl_data_if*
set_false_path -to *if0_c0_memctl_data_if*
set_false_path -from *altera_mem_if_sequencer_cpu*cpu_inst*E_shift_rot_cnt[*]
set_false_path -from *altera_avalon_packets_to_master*packets_to_master*counter[*]
set_false_path -to *if0_c0_reset_sync*
set_false_path -to *rw_mgr_core*
`endif


######################
#                    #
# REPORT DDR COMMAND #
#                    #
######################

add_ddr_report_command "source [list [file join [file dirname [info script]] ${::GLOBAL_corename}_report_timing.tcl]]"



`ifdef IPTCL_ADD_OPENCORES_LOGIC
if { $::TimeQuestInfo(nameofexecutable) == "quartus_fit" } {
	post_message -type info "OpenCores: Creating 1ns clock period for oc_logic_clock and oc_wrapper_clock"
	create_clock -name oc_logic_clk -period 1 [get_ports {oc_logic_clk}]
	create_clock -name oc_wrapper_clk -period 1 [get_ports {oc_wrapper_clk}]
}
`endif

