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

##################
#                #
# QUERIED TIMING #
#                #
##################

# Phase Jitter on DQS paths. This parameter is queried at run time
set fpga(tDQS_PHASE_JITTER) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PHASE_JITTER -in_fitter ] / 1000.0 ]

# Phase Error on DQS paths. This parameter is queried at run time
set fpga(tDQS_PSERR) [ expr [ get_integer_node_delay -integer $::GLOBAL_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PSERR -in_fitter ] / 1000.0 ]	

if { $debug } {
	post_message -type info "SDC: Jitter Parameters"
	post_message -type info "SDC: -----------------"
	post_message -type info "SDC:    DQS Phase: $::GLOBAL_dqs_delay_chain_length"
	post_message -type info "SDC:    fpga(tDQS_PHASE_JITTER): $fpga(tDQS_PHASE_JITTER)"
	post_message -type info "SDC:    fpga(tDQS_PSERR): $fpga(tDQS_PSERR)"
	post_message -type info "SDC: -----------------"
}

# Maximum delay on data input pins
set t(rdu_input_max_delay_external) [expr $t(CQD) + $board(intra_CQ_group_skew) + $board(data_CQ_skew) + $t(INTERNAL_JITTER) + $ISI(READ_DQ)/2 + $ISI(READ_DQS)/2]
set t(rdu_input_max_delay_internal) [expr $DQSpathjitter*$DQSpathjitter_setup_prop + $SSN(rel_pushout_i) + $fpga(tDQS_PSERR)]
set data_input_max_delay [ memphy_round_3dp [ expr $t(rdu_input_max_delay_external) + $t(rdu_input_max_delay_internal) ]]

# Minimum delay on data input pins
set t(rdu_input_min_delay_external) [expr -$t(CQDOH) + $board(intra_CQ_group_skew) - $board(data_CQ_skew) + $t(INTERNAL_JITTER) + $ISI(READ_DQ)/2 + $ISI(READ_DQS)/2]
set t(rdu_input_min_delay_internal) [expr $t(DCD) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $SSN(rel_pullin_i) + $fpga(tDQS_PSERR)]
set data_input_min_delay [ memphy_round_3dp [ expr - $t(rdu_input_min_delay_external) - $t(rdu_input_min_delay_internal) ]]

# Minimum delay on address and command paths
set ac_min_delay [ memphy_round_3dp [ expr - $t(HA) - $fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) - $ISI(addresscmd_hold)]]

# Maximum delay on address and command paths
set ac_max_delay [ memphy_round_3dp [ expr $t(SA) + $fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) + $ISI(addresscmd_setup)]]

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
	set ac_pins [ concat $add_pins $cmd_pins ]
	set bws_groups $pins(bws_groups)

	set pll_ref_clock $pins(pll_ref_clock)
	set pll_afi_clock $pins(pll_afi_clock)
	set pll_afi_phy_clock $pins(pll_afi_phy_clock)
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
		-target $pll_d_clock \
		-suffix "write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_pll_mult(PLL_WRITE_CLK) \
		-divide_by $::GLOBAL_pll_div(PLL_WRITE_CLK) \
		-phase $::GLOBAL_pll_phase(PLL_WRITE_CLK) ]
		
	# Common clock between CK/DK at the PHY clock tree output
	set local_pll_mem_clk [ memphy_get_or_add_clock_vseries \
		-target $pll_k_clock \
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

	# ------------------- #
	# -                 - #
	# --- READ CLOCKS --- #
	# -                 - #
	# ------------------- #

	set cq_cqn_pins [ concat $cq_pins $cq_n_pins ]
	foreach { cq_pin } $cq_cqn_pins { dqs_in_clock_struct } $dqs_in_clocks {
		# This is the CQ clock for Read Capture analysis (micro model)
		create_clock -period $t(CYC) -waveform [ list 0 $half_period ] $cq_pin -name $cq_pin

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -from [ get_clocks $cq_pin ] 0
		set_clock_uncertainty -to [ get_clocks $cq_pin ] 0
	}


	# -------------------- #
	# -                  - #
	# --- WRITE CLOCKS --- #
	# -                  - #
	# -------------------- #

	# This is the K clock for Data Write analysis (micro model) and A/C analysis
	for { set i 0 } { $i < [ llength $k_pins ] } { incr i } {
		set k_pin [ lindex $k_pins $i ]

		create_generated_clock -add -multiply_by 1 -source $pll_k_clock -master_clock "$local_pll_mem_clk" $k_pin -name $k_pin

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $k_pin ] 0
	}

	# This is the Kn clock for Data Write analysis (micro model) and A/C analysis
	for { set i 0 } { $i < [ llength $kn_pins ] } { incr i } {
		set kn_pin [ lindex $kn_pins $i ]

		create_generated_clock -add -multiply_by 1 -invert -source $pll_k_clock -master_clock "$local_pll_mem_clk" $kn_pin -name $kn_pin

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $kn_pin ] 0
	}

	##################
	#                #
	# READ DATA PATH #
	#                #
	##################


	foreach { cq_pin } $cq_cqn_pins { q_pins } $q_groups {
		foreach { q_pin } $q_pins {
			set_max_delay -from [get_ports $q_pin] -to $read_capture_ddio 0
			set_min_delay -from [get_ports $q_pin] -to $read_capture_ddio [expr 0-$half_period]
			# Specifies the maximum delay difference between the Q pin and the CQ pin:
			set_input_delay -max $data_input_max_delay -clock [get_clocks $cq_pin] [get_ports $q_pin] -add_delay

			# Specifies the minimum delay difference between the Q pin and the CQ pin:
			set_input_delay -min $data_input_min_delay -clock [get_clocks $cq_pin] [get_ports $q_pin] -add_delay
		}
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
	set_false_path -setup -fall_from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "$local_pll_addr_cmd_clk" ] -fall_to [ get_clocks $k_pins ]
	set_false_path -setup -rise_from [ get_clocks "$local_pll_addr_cmd_clk" ] -to [ get_clocks $kn_pins ]
	set_false_path -setup -fall_from [ get_clocks "$local_pll_addr_cmd_clk" ] -fall_to [ get_clocks $kn_pins ]
`endif

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


	set lfifo_in_read_en_dff ${prefix}|*p0|*lfifo~*LFIFO_IN_READ_EN_DFF
	set lfifo_out_rden_dff ${prefix}|*p0|*lfifo~*LFIFO_OUT_RDEN_DFF
	set lfifo_rd_latency_dff ${prefix}|*p0|*lfifo~*RD_LATENCY_DFF*
	set phase_align_os_dff ${prefix}|*p0|*altdq_dqs2_inst|phase_align_os~DFF*
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

		set_multicycle_path -from ${prefix}|*p0|*umemphy|*ureset|*ureset_afi_clk|reset_reg[*] -to ${prefix}|*p0|*altdq_dqs2_inst|clk_h -end -setup 2
		set_multicycle_path -from ${prefix}|*p0|*umemphy|*ureset|*ureset_afi_clk|reset_reg[*] -to ${prefix}|*p0|*altdq_dqs2_inst|clk_h -end -hold 1
		set_multicycle_path -from ${prefix}|*p0|*altdq_dqs2_inst|clk_h -to $phase_align_os_dff -end -setup 2
		set_multicycle_path -from ${prefix}|*p0|*altdq_dqs2_inst|clk_h -to $phase_align_os_dff -end -hold 1

		set_false_path -from $pll_afi_phy_clock -to $lfifo_in_read_en_dff
	}



	##########################
	#                        #
	# FALSE PATH CONSTRAINTS #
	#                        #
	##########################

	# Cut paths for memory clocks to avoid unconstrained warnings
	foreach { pin } [concat $k_pins $kn_pins] {
		set_false_path -to [get_ports $pin]
	}

`ifdef IPTCL_NIOS_SEQUENCER
`else
	set_false_path -through *oe_reg -to $all_d_pins
`endif

	# Cut paths between AFI Clock and Read Capture Registers
	set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $cq_cqn_pins]
	if {[get_collection_size [get_clocks $pll_afi_clock -nowarn]] > 0} {
		set_false_path -from [get_clocks $pll_afi_clock] -to [get_clocks $cq_cqn_pins]
	}

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
		set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_addr_cmd_clk] -add -setup 0.500

        set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_addr_cmd_clk] -add -hold 0.000

		if {$after_u2b} {
			set_min_delay -from ${prefix}|*p0|*altdq_dqs2_inst|clk_h -to $phase_align_os_dff 0.300
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

