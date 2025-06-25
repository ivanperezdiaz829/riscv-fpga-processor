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

set is_es 0
if { [string match -nocase "*es" $::TimeQuestInfo(part)] } {
	set is_es 1
}

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
set half_period [ memphy_round_3dp [ expr $t(CYC) / 2.0 ] ]

# Half of reference clock
set ref_half_period [ memphy_round_3dp [ expr $t(refCK) / 2.0 ] ]

# Minimum delay on data output pins
set t(wru_output_min_delay_external) [expr $t(HD) + $board(intra_K_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 - $board(data_K_skew)]
set t(wru_output_min_delay_internal) [expr $t(WL_DCD) + $t(WL_PSE) + $t(WL_JITTER)*(1.0-$t(WL_JITTER_DIVISION)) + $SSN(rel_pullin_o)]
set data_output_min_delay [ memphy_round_3dp [ expr - $t(wru_output_min_delay_external) - $t(wru_output_min_delay_internal)]]

# Maximum delay on data output pins
set t(wru_output_max_delay_external) [expr $t(SD) + $board(intra_K_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 + $board(data_K_skew)]
set t(wru_output_max_delay_internal) [expr $t(WL_DCD) + $t(WL_PSE) + $t(WL_JITTER)*$t(WL_JITTER_DIVISION) + $SSN(rel_pushout_o)]
set data_output_max_delay [ memphy_round_3dp [ expr $t(wru_output_max_delay_external) + $t(wru_output_max_delay_internal)]]

# Maximum delay on data input pins
set t(rdu_input_max_delay_external) [expr $t(CQD) + $board(intra_CQ_group_skew) + $board(data_CQ_skew) + $ISI(READ_DQ)/2 + $ISI(READ_DQS)/2]
set t(rdu_input_max_delay_internal) [expr $DQSpathjitter*$DQSpathjitter_setup_prop + $SSN(rel_pushout_i)]
set data_input_max_delay [ memphy_round_3dp [ expr $t(rdu_input_max_delay_external) + $t(rdu_input_max_delay_internal) ]]

# Minimum delay on data input pins
set t(rdu_input_min_delay_external) [expr -$t(CQDOH) + $board(intra_CQ_group_skew) - $board(data_CQ_skew) + $ISI(READ_DQ)/2 + $ISI(READ_DQS)/2]
set t(rdu_input_min_delay_internal) [expr $t(DCD) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $SSN(rel_pullin_i)]
set data_input_min_delay [ memphy_round_3dp [ expr - $t(rdu_input_min_delay_external) - $t(rdu_input_min_delay_internal) ]]

# Minimum delay on address and command paths
set ac_min_delay [ memphy_round_3dp [ expr - $t(HA) - $fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) - $ISI(addresscmd_hold)]]

# Maximum delay on address and command paths
set ac_max_delay [ memphy_round_3dp [ expr $t(SA) + $fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) + $ISI(addresscmd_setup)]]

# AFI cycle period
`ifdef IPTCL_FULL_RATE
set tCK_AFI [ expr $t(CYC) * 1.0 ]
`endif
`ifdef IPTCL_HALF_RATE
set tCK_AFI [ expr $t(CYC) * 2.0 ]
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
	set doff_pin $pins(doff_pin)
	set ac_pins [ concat $add_pins $cmd_pins ]
	set bws_groups $pins(bws_groups)
	set k_leveling_pins $pins(k_leveling_pins)
	set d_leveling_pins $pins(d_leveling_pins)
	set ac_leveling_pins $pins(ac_leveling_pins)

	set pll_ref_clock $pins(pll_ref_clock)
	set pll_afi_clock $pins(pll_afi_clock)
	set pll_k_clock $pins(pll_k_clock)
	set pll_d_clock $pins(pll_d_clock)
	set pll_ac_clock $pins(pll_ac_clock)
	set pll_c2p_write_clock $pins(pll_c2p_write_clock)
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock $pins(pll_afi_half_clock)
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock $pins(pll_avl_clock)
	set pll_config_clock $pins(pll_config_clock)
`endif

	set dqs_in_clocks $pins(dqs_in_clocks)
	set read_capture_ddio $pins(read_capture_ddio)
	set read_capture_ddio_capture $pins(read_capture_ddio_capture)
	set reset_reg $pins(reset_reg)
	set sync_reg $pins(sync_reg)
	set fifo_wraddress_reg $pins(fifo_wraddress_reg)
	set fifo_rdaddress_reg $pins(fifo_rdaddress_reg)
	set fifo_wrload_reg $pins(fifo_wrload_reg)
	set fifo_rdload_reg $pins(fifo_rdload_reg)
	set fifo_wrdata_reg $pins(fifo_wrdata_reg)
	set fifo_rddata_reg $pins(fifo_rddata_reg)
	set valid_fifo_wrdata_reg $pins(valid_fifo_wrdata_reg)
	set valid_fifo_rddata_reg $pins(valid_fifo_rddata_reg)
	set valid_fifo_rdaddress_reg $pins(valid_fifo_rdaddress_reg)

	##################
	#                #
	# QUERIED TIMING #
	#                #
	##################

	# Phase Jitter on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PHASE_JITTER) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PHASE_JITTER -in_fitter ] / 1000.0 ]

	# Phase Error on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PSERR) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PSERR -in_fitter ] / 1000.0 ]

	# Mimimum delay requirement for hold constraint on read path
	set data_input_min_constraint [ memphy_round_3dp [ expr - ($t(CYC) * 0.5 - $t(INTERNAL_JITTER) ) + $fpga(tDQS_PSERR) ]]

`ifdef IPTCL_FULL_RATE
`else
`ifdef IPTCL_NIOS_SEQUENCER
`else
	if {$fit_flow} {
		set data_input_min_constraint [ expr $data_input_min_constraint + 0.100 ]
	}
`endif
`endif

	# Maximum delay requirement for setup constraint on read path
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
		
	# Write clock
	set local_pll_write_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_k_clock \
		-suffix "write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_WRITE_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_WRITE_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_WRITE_CLK) ]		
		
 `ifdef IPTCL_FULL_RATE
 `else
 	# Half-rate DDIO clock
	set local_pll_c2p_write_clock [ memphy_get_or_add_clock_vseries \
		-target $pll_c2p_write_clock \
		-suffix "c2p_write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_C2P_WRITE_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_C2P_WRITE_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_C2P_WRITE_CLK) ]	
`endif		
	
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

	# The following clocks are defined at the CPS outputs.
	#Instead of defining one generated clock against a collection of pins,
	set local_leveling_clocks_k [list]
	set local_leveling_clocks_ac [list]
	set local_leveling_clocks_d [list]
		
	for { set i 0 } { $i < [ llength $k_leveling_pins ] } { incr i } {
		set pin_info [get_pins [lindex $k_leveling_pins $i]]
		set pin_name [get_pin_info -name $pin_info]
		
		set local_leveling_clock_k [ memphy_get_or_add_clock_vseries \
			-target $pin_name \
			-suffix "leveling_clock_k_$i" \
			-source $pll_d_clock \
			-multiply_by 1 \
			-divide_by 1 \
			-phase 0 ]		
		
		set local_leveling_clocks_k [concat $local_leveling_clocks_k $local_leveling_clock_k]
	}
		
	for { set i 0 } { $i < [ llength $d_leveling_pins ] } { incr i } {	
		set pin_info [get_pins [lindex $d_leveling_pins $i]]
		set pin_name [get_pin_info -name $pin_info]
		
		set local_leveling_clock_d [ memphy_get_or_add_clock_vseries \
			-target $pin_name \
			-suffix "leveling_clock_d_$i" \
			-source $pll_d_clock \
			-multiply_by 1 \
			-divide_by 1 \
			-phase 0 ]
		
		set local_leveling_clocks_d [concat $local_leveling_clocks_d $local_leveling_clock_d]
	}	

	for { set i 0 } { $i < [ llength $ac_leveling_pins ] } { incr i } {	
		set pin_info [get_pins [lindex $ac_leveling_pins $i]]
		set pin_name [get_pin_info -name $pin_info]
		
		set local_leveling_clock_ac [ memphy_get_or_add_clock_vseries \
			-target $pin_name \
			-suffix "leveling_clock_ac_$i" \
			-source $pll_d_clock \
			-multiply_by 1 \
			-divide_by 1 \
			-phase 0 ]
		
		set local_leveling_clocks_ac [concat $local_leveling_clocks_ac $local_leveling_clock_ac]
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

	foreach { cq_pin } $cq_pins { dqs_in_clock_struct } $dqs_in_clocks {
		# This is the CQ clock for Read Capture analysis (micro model)
		create_clock -period $t(CYC) -waveform [ list 0 $half_period ] $cq_pin -name $cq_pin
		
		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -from [ get_clocks $cq_pin ] 0
		set_clock_uncertainty -to [ get_clocks $cq_pin ] 0

`ifdef IPTCL_FULL_RATE
		if {$fit_flow} {
			set_clock_uncertainty -from [get_clocks $cq_pin] -enable_same_physical_edge -add -hold 0.2
		}
`endif


`ifdef IPTCL_RL2
`else
	`ifdef IPTCL_HALF_RATE
		# DIV clock is generated on the output of the clock divider.
		array set dqs_in_clock $dqs_in_clock_struct
		create_generated_clock -name $dqs_in_clock(div_name) -source $cq_pin -divide_by 2 $dqs_in_clock(div_pin) -master $cq_pin
		
		# Add extra clock uncertainty to locally routed clock derived from input read clock
		set_clock_uncertainty -from $dqs_in_clock(div_name) -enable_same_physical_edge -add 0.1

		if {$fit_flow} {
			set_clock_uncertainty -from $dqs_in_clock(div_name) -enable_same_physical_edge -add -hold 0.2
		}
	`endif
`endif
	}

	# This is the CQn clock for Read Capture analysis (micro model)
	foreach { cq_n_pin } $cq_n_pins { dqs_in_clock_struct } $dqs_in_clocks {
		if {$cq_n_pin == ""} {
			continue
		}
		create_clock -period $t(CYC) -waveform [ list $half_period $t(CYC) ] $cq_n_pin -name $cq_n_pin
		
		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -from [ get_clocks $cq_n_pin ] 0
		set_clock_uncertainty -to [ get_clocks $cq_n_pin ] 0		

`ifdef IPTCL_FULL_RATE
		if {$fit_flow} {
			set_clock_uncertainty -from [get_clocks $cq_n_pin] -enable_same_physical_edge -add -hold 0.2
		}
`endif

`ifdef IPTCL_RL2
	`ifdef IPTCL_HALF_RATE
		# DIV clock is generated on the output of the clock divider.
		array set dqs_in_clock $dqs_in_clock_struct
		create_generated_clock -name $dqs_in_clock(div_name) -source $cq_n_pin -divide_by 2 $dqs_in_clock(div_pin) -master $cq_n_pin
		
		# Add extra clock uncertainty to locally routed clock derived from input read clock
		set_clock_uncertainty -from $dqs_in_clock(div_name) -enable_same_physical_edge -add 0.1

		if {$fit_flow} {
			set_clock_uncertainty -from $dqs_in_clock(div_name) -enable_same_physical_edge -add -hold 0.2
		}
	`endif
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
		set k_leveling_pin [ lindex $k_leveling_pins $i ]
		set local_leveling_clock_k [lindex $local_leveling_clocks_k $i]
		
 `ifdef IPTCL_BURST_2
 		create_generated_clock -add -multiply_by 1 -source $k_leveling_pin -master_clock $local_leveling_clock_k $k_pin -name $k_pin
 `else		
		create_generated_clock -add -multiply_by 1 -invert -source $k_leveling_pin -master_clock $local_leveling_clock_k $k_pin -name $k_pin
 `endif		

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $k_pin ] 0
	}

	# This is the Kn clock for Data Write analysis (micro model) and A/C analysis
	for { set i 0 } { $i < [ llength $kn_pins ] } { incr i } {
		set kn_pin [ lindex $kn_pins $i ]
		set k_leveling_pin [ lindex $k_leveling_pins $i ]
		set local_leveling_clock_k [lindex $local_leveling_clocks_k $i]
		
 `ifdef IPTCL_BURST_2
		create_generated_clock -add -multiply_by 1 -invert -source $k_leveling_pin -master_clock $local_leveling_clock_k $kn_pin -name $kn_pin
 `else		
		create_generated_clock -add -multiply_by 1 -source $k_leveling_pin -master_clock $local_leveling_clock_k $kn_pin -name $kn_pin
 `endif		

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $kn_pin ] 0
	}

	##################
	#                #
	# READ DATA PATH #
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

	###################
	#                 #
	# WRITE DATA PATH #
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

	foreach { local_leveling_clock_ac } $local_leveling_clocks_ac {
		set_multicycle_path -setup 0 -fall_from [ get_clocks $local_leveling_clock_ac ] -rise_to [ get_clocks $kn_pins ]
		set_multicycle_path -setup 0 -rise_from [ get_clocks $local_leveling_clock_ac ] -rise_to [ get_clocks $k_pins ]

		set_false_path -setup -fall_from [ get_clocks $local_leveling_clock_ac ] -to [ get_clocks $k_pins ]
		set_false_path -setup -rise_from [ get_clocks $local_leveling_clock_ac ] -fall_to [ get_clocks $k_pins ]
		set_false_path -setup -rise_from [ get_clocks $local_leveling_clock_ac ] -to [ get_clocks $kn_pins ]
		set_false_path -setup -fall_from [ get_clocks $local_leveling_clock_ac ] -fall_to [ get_clocks $kn_pins ]
	}
	
	foreach { local_leveling_clock_d } $local_leveling_clocks_d {
		set_multicycle_path -setup 0 -fall_from [ get_clocks $local_leveling_clock_d ] -rise_to [ get_clocks $kn_pins ]
		set_multicycle_path -setup 0 -rise_from [ get_clocks $local_leveling_clock_d ] -rise_to [ get_clocks $k_pins ]
 
		set_false_path -setup -fall_from [ get_clocks $local_leveling_clock_d ] -to [ get_clocks $k_pins ]
		set_false_path -setup -rise_from [ get_clocks $local_leveling_clock_d ] -fall_to [ get_clocks $k_pins ]
		set_false_path -setup -rise_from [ get_clocks $local_leveling_clock_d ] -to [ get_clocks $kn_pins ]
		set_false_path -setup -fall_from [ get_clocks $local_leveling_clock_d ] -fall_to [ get_clocks $kn_pins ]
	}
`else
	`ifdef IPTCL_FULL_RATE
 	# The address and command bus is toggling at Single Data Rate, and is only captured by
	# the rising edge of K. We need to cut the path from the falling edge of the addr_cmd_clk
	# and K and any path from the addr_cmd_clk and Kn
	foreach { local_leveling_clock_ac } $local_leveling_clocks_ac {
		set_false_path -fall_from [ get_clocks $local_leveling_clock_ac ] -to [ get_clocks $k_pins ]
	}
	
	foreach { local_leveling_clock_k } $local_leveling_clocks_k {
		set_false_path -fall_from [ get_clocks $local_leveling_clock_k ] -to [ get_clocks $k_pins ]
	}
	`endif
`endif

	##########################
	#                        #
	# MULTICYCLE CONSTRAINTS #
	#                        #
	##########################

	# If the C2P clock is phase-delayed to help setup for
	# the C2P transfer, we must tell STA to analyze setup
	# using one clock edge later than the default latch edge,
	# via a multicycle value of 2. 
	# For hold, STA automatically picks the right edge in this
	# case, which is one clock edge before the one used for setup.
 `ifdef IPTCL_FULL_RATE
	if {$::GLOBAL_pll_phase(PLL_WRITE_CLK) > 0} {
		foreach { local_leveling_clock_ac } $local_leveling_clocks_ac {
			set_multicycle_path -to [get_clocks $local_leveling_clock_ac] -setup 2
		}
		foreach { local_leveling_clock_d } $local_leveling_clocks_d {
			set_multicycle_path -to [get_clocks $local_leveling_clock_d] -setup 2
		}
		foreach { local_leveling_clock_k } $local_leveling_clocks_k {
			set_multicycle_path -to [get_clocks $local_leveling_clock_k] -setup 2
		}
	}
 `else
	if {$::GLOBAL_pll_phase(PLL_C2P_WRITE_CLK) > 0} {
		set_multicycle_path -to [get_clocks $local_pll_c2p_write_clock] -setup 2
	}
 `endif

	# Relax timing for the reset signal going into the hard read fifo
	set_multicycle_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|*read_buffering[*].uread_read_fifo_hard|*] -setup 2
	set_multicycle_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|*read_buffering[*].uread_read_fifo_hard|*] -hold 2
 
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

	set_multicycle_path -from [get_registers ${prefix}|*p0|*umemphy|*uio_pads|*dq_ddio[*].uwrite|*altdq_dqs2_inst|clk_h] -setup 3
	set_multicycle_path -from [get_registers ${prefix}|*p0|*umemphy|*uio_pads|*dq_ddio[*].uwrite|*altdq_dqs2_inst|clk_h] -hold 3

	##########################
	#                        #
	# FALSE PATH CONSTRAINTS #
	#                        #
	##########################

	# Cut paths for memory clocks to avoid unconstrained warnings
	# Also cut doff_n pin because it is asynchronous.
	foreach { pin } [concat $k_pins $kn_pins $doff_pin] {
		set_false_path -to [get_ports $pin]
	}
	
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
	
	# Cut paths between AFI Clock and Div Clock
	foreach dqs_in_clock_struct $dqs_in_clocks {
		array set dqs_in_clock $dqs_in_clock_struct
		set_false_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_write_side*] -to [ get_clocks $dqs_in_clock(div_name) ]
		set_false_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress*] -to [ get_clocks $dqs_in_clock(div_name) ]
	}
`endif	

`ifdef IPTCL_NIOS_SEQUENCER
`else
	set_false_path -through *oe_reg -to $all_d_pins
`endif

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

	# The following registers serve as anchors for the pin_map.tcl
	# script and are not used by the IP during memory operation
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set_false_path -from $pins(afi_half_ck_pins) -to $pins(afi_half_ck_pins)
`endif

	# VFIFO is soft. Although it is an async FIFO we still want the FFs
	# to be placed close to each other to guarantee support of minimum read latency.
	set_max_delay -from [get_registers $valid_fifo_wrdata_reg] -to [get_registers $valid_fifo_rddata_reg] $tCK_AFI
	set_false_path -hold -from [get_registers $valid_fifo_wrdata_reg] -to [get_registers $valid_fifo_rddata_reg]
	
`ifdef IPTCL_NIOS_SEQUENCER	
	# Add extra timing guardband to the VFIFO read address counter to account
	# for the change in input clock delay during read deskew calibration.
	# This is to avoid the VFIFO getting out of sync as a result of timing
	# failure caused by a moving clock. The guardband permits a delay change of
	# up to 50ps/200ps.
	set_max_delay -from [get_registers $valid_fifo_rdaddress_reg] -to [get_registers $valid_fifo_rdaddress_reg] [expr $tCK_AFI - 0.2]
	set_min_delay -from [get_registers $valid_fifo_rdaddress_reg] -to [get_registers $valid_fifo_rdaddress_reg] 0.05
`endif	

	if { ! $synthesis_flow } {
		# Cut paths within hard async FIFO
		set_false_path -from [get_registers $fifo_wrload_reg] -to [get_registers $fifo_rdload_reg]
		
		# Constrain for the zero-cycle transfer between DDIO_IN and read FIFO.
		# This cannot be set during timing-driven synthesis because the DDIO
		# registers don't exist in the timing netlist at that stage. This does not
		# affect timing-driven synthesis.
		set_max_delay -from [get_registers $read_capture_ddio] -to $fifo_wrdata_reg -0.05
		set_min_delay -from [get_registers $read_capture_ddio] -to $fifo_wrdata_reg [ memphy_round_3dp [expr -$t(CYC) + 0.15]]
	}

	# ------------------------------ #
	# -                            - #
	# --- FITTER OVERCONSTRAINTS --- #
	# -                            - #
	# ------------------------------ #
	if {$fit_flow} {
		
		

`ifdef IPTCL_FULL_RATE
	foreach { local_leveling_clock_ac } $local_leveling_clocks_ac {
		set_clock_uncertainty -to [get_clocks $local_leveling_clock_ac] -add -hold 0.150
	}
	foreach { local_leveling_clock_d } $local_leveling_clocks_d {
		set_clock_uncertainty -to [get_clocks $local_leveling_clock_d] -add -hold 0.150
	}
	foreach { local_leveling_clock_k } $local_leveling_clocks_k {
		set_clock_uncertainty -to [get_clocks $local_leveling_clock_k] -add -hold 0.150
	}
`endif

`ifdef IPTCL_NIOS_SEQUENCER
		set_clock_uncertainty -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_config_clock] -add -hold 0.100
`endif
	}	

	# -------------------------------- #
	# -                              - #
	# --- TIMING MODEL ADJUSTMENTS --- #
	# -                              - #
	# -------------------------------- #
`ifdef IPTCL_FULL_RATE
`else		
	# These negative over-constraints recover excess min/max scaling on the articifically lengthend clock delays
	foreach { local_leveling_clock_ac } $local_leveling_clocks_ac {
		set_clock_uncertainty -add -hold -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_leveling_clock_ac] -0.080
		set_clock_uncertainty -add -setup -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_leveling_clock_ac] -0.075
	}
	foreach { local_leveling_clock_k } $local_leveling_clocks_k {
		set_clock_uncertainty -add -hold -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_leveling_clock_k] -0.080
		set_clock_uncertainty -add -setup -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_leveling_clock_k] -0.075
	}
`endif
}

if {(($::quartus(nameofexecutable) ne "quartus_fit") && ($::quartus(nameofexecutable) ne "quartus_map"))} {
	set dqs_clocks [memphy_get_all_instances_dqs_pins memphy_ddr_db]
	if {[llength $dqs_clocks] > 0} {
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

`ifdef IPTCL_ADD_OPENCORES_LOGIC
if { $::TimeQuestInfo(nameofexecutable) == "quartus_fit" } {
	post_message -type info "OpenCores: Creating 1ns clock period for oc_logic_clock and oc_wrapper_clock"
	create_clock -name oc_logic_clk -period 1 [get_ports {oc_logic_clk}]
	create_clock -name oc_wrapper_clk -period 1 [get_ports {oc_wrapper_clk}]
}
`endif
