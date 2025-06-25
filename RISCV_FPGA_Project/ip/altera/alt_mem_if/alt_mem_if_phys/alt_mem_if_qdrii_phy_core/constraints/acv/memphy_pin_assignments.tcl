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
# This file contains a simple script to automatically apply
# IO standards and other IO assignments for the UniPHY memory
# interface pins that connect to the memory device. The pins
# are automatically detected using the routines defined in
# the memphy_pin_map.tcl script.
# All the memory interface parameters are defined in the
# memphy_parameters.tcl script


set available_options {
	{ c.arg "#_ignore_#" "Option to specify the revision name" }
}
package require cmdline
set script_dir [file dirname [info script]]

global ::GLOBAL_q_group_size
global ::GLOBAL_d_group_size
global ::GLOBAL_io_standard

proc memphy_find_oct_blocks { instname } {
	set blocks [ list ]

`ifdef IPTCL_OCT_MASTER
	set matchthis "$instname|oct0|sd1a_0"
	set allnames [ get_names -filter *sd1a_0* ]
	foreach_in_collection node $allnames {
		set_project_mode -always_show_entity_name off
		set name [ get_name_info -info full_path $node ]

		if [ string match $matchthis $name ] {

			set_project_mode -always_show_entity_name qsf
			set proper_name [ get_name_info -info full_path $node ]
			lappend blocks $proper_name
		}
	}
`else
	set ::master_corename "_MASTER_CORE_"
	set allnames [ get_names -filter *$::master_corename*sd1a_0* ]
	foreach_in_collection node $allnames {
		set_project_mode -always_show_entity_name off
		set name [ get_name_info -info full_path $node ]
		set_project_mode -always_show_entity_name qsf
		set proper_name [ get_name_info -info full_path $node ]
		lappend blocks $proper_name
	}
`endif
	return $blocks
}

#################
#               #
# SETUP SECTION #
#               #
#################

global options
set argument_list $quartus(args)
set argv0 "quartus_sta -t [info script]"
set usage "\[<options>\] <project_name>:"
	
if [catch {array set options [cmdline::getoptions argument_list $::available_options]} result] {
	if {[llength $argument_list] > 0 } {
		post_message -type error "Illegal Options"
		post_message -type error  [::cmdline::usage $::available_options $usage]
		qexit -error
	} else {
		post_message -type info  "Usage:"
		post_message -type info  [::cmdline::usage $::available_options $usage]
		qexit -success
	}
}
if {$options(c) != "#_ignore_#"} {
	if [string compare [file extension $options(c)] ""] {
		set options(c) [file rootname $options(c)]
	}
}

if {[llength $argument_list] == 1 } {
	set options(project_name) [lindex $argument_list 0]

	if [string compare [file extension $options(project_name)] ""] {
		set project_name [file rootname $options(project_name)]
	}

	set project_name [file normalize $options(project_name)]

} elseif { [llength $argument_list] == 2 } {
	set options(project_name) [lindex $argument_list 0]
	set options(rev)          [lindex $argument_list 1]

	if [string compare [file extension $options(project_name)] ""] {
		set project_name [file rootname $options(project_name)]
	}
	if [string compare [file extension $options(c)] ""] {
		set revision_name [file rootname $options(c)]
	}

	set project_name [file normalize $options(project_name)]
	set revision_name [file normalize $options(rev)]

} elseif { [ is_project_open ] } {
	set project_name $::quartus(project)
	set options(rev) $::quartus(settings)

} else {
	post_message -type error "Project name is missing"
	post_message -type info [::cmdline::usage $::available_options $usage]
	post_message -type info "For more details, use \"quartus_sta --help\""
	qexit -error
}


# If this script is called from outside quartus_sta, it will re-launch itself in quartus_sta
if { ![info exists quartus(nameofexecutable)] || $quartus(nameofexecutable) != "quartus_sta" } {
	post_message -type info "Restarting in quartus_sta..."

	set cmd quartus_sta
	if { [info exists quartus(binpath)] } {
		set cmd [file join $quartus(binpath) $cmd]
	}

	if { [ is_project_open ] } {
		set project_name [ get_current_revision ]
	} elseif { ! [ string compare $project_name "" ] } {
		post_message -type error "Missing project_name argument"

		return 1
	}

	set output [ exec $cmd -t [ info script ] $project_name ]

	foreach line [split $output \n] {
		set type info
		set matched_line [ regexp {^\W*(Info|Extra Info|Warning|Critical Warning|Error): (.*)$} $line x type msg ]
		regsub " " $type _ type

		if { $matched_line } {
			post_message -type $type $msg
		} else {
			puts "$line"
		}
	}

	return 0
}

source "$script_dir/memphy_parameters.tcl"
source "$script_dir/memphy_pin_map.tcl"

if { ! [ is_project_open ] } {
	if { ! [ string compare $project_name "" ] } {
		post_message -type error "Missing project_name argument"

		return 1
	}

	if {$options(c) == "#_ignore_#"} {
		project_open $project_name
	} else {
		project_open $project_name -revision $options(c)
	}

}

set family_name [string tolower [regsub -all " +" [get_global_assignment -name FAMILY] ""]]

##############################
# Clean up stale assignments #
##############################
post_message -type info "Cleaning up stale assignments..."

set asgn_types [ list IO_STANDARD INPUT_TERMINATION OUTPUT_TERMINATION CURRENT_STRENGTH_NEW DQ_GROUP ]
foreach asgn_type $asgn_types {
	remove_all_instance_assignments -tag __$::GLOBAL_corename -name $asgn_type
}

if { ! [ timing_netlist_exist ] } {
	create_timing_netlist -post_map
}

#######################
#                     #
# ASSIGNMENTS SECTION #
#                     #
#######################

# This is the main call to the netlist traversal routines
# that will automatically find all pins and registers required
# to apply pin settings.
memphy_initialize_ddr_db ddr_db

# If multiple instances of this core are present in the
# design they will all be constrained through the
# following loop

set instances [ array names ddr_db ]
foreach inst $instances {
	if { [ info exists pins ] } {
		# Clean-up stale content
		unset pins
	}
	array set pins $ddr_db($inst)

	foreach cq_pin [ concat $pins(cq_pins) ] {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $cq_pin -tag __$::GLOBAL_corename
	`ifdef IPTCL_EMULATED_MODE 
    `else 
		set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to $cq_pin -tag __$::GLOBAL_corename
	`endif
	}

	foreach cq_n_pin [ concat $pins(cq_n_pins) ] {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $cq_n_pin -tag __$::GLOBAL_corename
	`ifdef IPTCL_EMULATED_MODE 
    `else 
		set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to $cq_n_pin -tag __$::GLOBAL_corename
	`endif
	}

	foreach q_pin $pins(all_q_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $q_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to $q_pin -tag __$::GLOBAL_corename
	}

	foreach k_pin [ concat $pins(k_pins) $pins(kn_pins) ] {
		set_instance_assignment -name IO_STANDARD "DIFFERENTIAL $::GLOBAL_io_standard CLASS I" -to $k_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to $k_pin -tag __$::GLOBAL_corename
	}

	foreach d_pin $pins(all_d_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $d_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to $d_pin -tag __$::GLOBAL_corename
	}

	foreach ac_pin $pins(ac_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $ac_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to $ac_pin -tag __$::GLOBAL_corename
	}

	foreach bws_pin $pins(all_bws_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $bws_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to $bws_pin -tag __$::GLOBAL_corename
	}

	foreach refclk_pin $pins(pll_ref_clock) {
		if {![string compare [get_instance_assignment -to $refclk_pin -name IO_STANDARD] ""]} {
			set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $refclk_pin -tag __$::GLOBAL_corename
    		}
	}

`ifdef IPTCL_SINGLE_CAPTURE_STROBE
	foreach { cq_pin } $pins(cq_pins) { q_pins } $pins(q_groups) {
		foreach q_pin $q_pins {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_q_group_size -from $cq_pin -to $q_pin -tag __$::GLOBAL_corename
		}
	}
`else
	`ifdef IPTCL_RL2
	foreach { cq_n_pin } $pins(cq_n_pins) { q_pins } $pins(q_groups) {
		foreach q_pin $q_pins {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_q_group_size -from $cq_n_pin -to $q_pin -tag __$::GLOBAL_corename
		}
	}
	`else
	foreach { cq_pin } $pins(cq_pins) { q_pins } $pins(q_groups) {
		foreach q_pin $q_pins {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_q_group_size -from $cq_pin -to $q_pin -tag __$::GLOBAL_corename
		}
	}
	`endif
`endif

`ifdef IPTCL_EMULATED_MODE
	foreach { group_type } $pins(d_group_types) { d_head } $pins(d_group_heads) { d_pins } $pins(d_groups) {
		foreach d_pin $d_pins {
			set_instance_assignment -name $group_type $::GLOBAL_d_group_size -from $d_head -to $d_pin -tag __$::GLOBAL_corename
		}
	}
`else
	foreach { k_pin } $pins(k_pins) { d_pins } $pins(d_groups) {
		foreach d_pin $d_pins {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_d_group_size -from $k_pin -to $d_pin -tag __$::GLOBAL_corename
		}
	}
`endif

	set delay_chain_config FLEXIBLE_TIMING

	foreach d_pin $pins(all_d_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $d_pin -tag __$::GLOBAL_corename
	}
	foreach q_pin $pins(all_q_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $q_pin -tag __$::GLOBAL_corename
	}

	foreach bws_pin $pins(all_bws_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $bws_pin -tag __$::GLOBAL_corename
	}
	foreach k_pin $pins(k_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $k_pin -tag __$::GLOBAL_corename
`ifdef IPTCL_NIOS_SEQUENCER
		set_instance_assignment -name D5_DELAY IPTCL_IO_DQS_OUT_RESERVE -to $k_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name D6_DELAY 0 -to $k_pin -tag __$::GLOBAL_corename
`endif
	}
	foreach kn_pin $pins(kn_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $kn_pin -tag __$::GLOBAL_corename
`ifdef IPTCL_NIOS_SEQUENCER
		set_instance_assignment -name D5_DELAY IPTCL_IO_DQS_OUT_RESERVE -to $kn_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name D6_DELAY 0 -to $kn_pin -tag __$::GLOBAL_corename
`endif
	}

	foreach cq_pin $pins(cq_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $cq_pin -tag __$::GLOBAL_corename
	}
	foreach cqn_pin $pins(cq_n_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $cqn_pin -tag __$::GLOBAL_corename
	}

`ifdef IPTCL_PACKAGE_DESKEW
	# Set the package skew compensation parameter indicating that the design compensates for the package skew on the board
	foreach d_pin $pins(all_d_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $d_pin -tag __$::GLOBAL_corename
	}
	foreach q_pin $pins(all_q_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $q_pin -tag __$::GLOBAL_corename
	}
	foreach bws_pin $pins(all_bws_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $bws_pin -tag __$::GLOBAL_corename
	}
	foreach k_pin $pins(k_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $k_pin -tag __$::GLOBAL_corename
	}
	foreach kn_pin $pins(kn_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $kn_pin -tag __$::GLOBAL_corename
	}
	foreach cq_pin $pins(cq_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $cq_pin -tag __$::GLOBAL_corename
	}
	foreach cqn_pin $pins(cq_n_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $cqn_pin -tag __$::GLOBAL_corename
	}
`else
	# Disable package skew compensation for data and clock pins in timing analysis
	foreach d_pin $pins(all_d_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $d_pin -tag __$::GLOBAL_corename
	}
	foreach q_pin $pins(all_q_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $q_pin -tag __$::GLOBAL_corename
	}
	foreach bws_pin $pins(all_bws_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $bws_pin -tag __$::GLOBAL_corename
	}
	foreach k_pin $pins(k_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $k_pin -tag __$::GLOBAL_corename
	}
	foreach kn_pin $pins(kn_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $kn_pin -tag __$::GLOBAL_corename
	}
	foreach cq_pin $pins(cq_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $cq_pin -tag __$::GLOBAL_corename
	}
	foreach cqn_pin $pins(cq_n_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $cqn_pin -tag __$::GLOBAL_corename
	}
`endif

`ifdef IPTCL_AC_PACKAGE_DESKEW
	# Set the package skew compensation parameter indicating that the design compensates for the package skew on the board for Address/Command
	foreach ac_pin $pins(ac_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $ac_pin -tag __$::GLOBAL_corename
	}
`else
	# Disable package skew compensation for address/command pins in timing analysis
	foreach ac_pin $pins(ac_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $ac_pin -tag __$::GLOBAL_corename
	}
`endif


`ifdef IPTCL_EMULATED_MODE
	foreach { group_type } $pins(d_group_types) { d_head } $pins(d_group_heads) { bws_pins } $pins(bws_groups) {
		foreach bws_pin $bws_pins {
			set_instance_assignment -name $group_type $::GLOBAL_d_group_size -from $d_head -to $bws_pin -tag __$::GLOBAL_corename
		}
	}
`else
	`ifdef IPTCL_AIIGZ_QDRII_x36
	foreach { bws_pins } $pins(bws_groups) {
		for {set bws_width 1} {$bws_width<[llength $bws_pins]} {incr bws_width 1} {
			set_instance_assignment -name DQ_GROUP 4 -from [ lindex $bws_pins 0 ] -to [ lindex $bws_pins $bws_width ] -tag __$::GLOBAL_corename
		}
	}
	`else
	foreach { k_pin } $pins(k_pins) { bws_pins } $pins(bws_groups) {
		foreach bws_pin $bws_pins {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_d_group_size -from $k_pin -to $bws_pin -tag __$::GLOBAL_corename
		}
	}
	`endif
`endif

	set blocks [ memphy_find_oct_blocks $inst ]
	if { [ llength $blocks ] == 0 } {
		post_message -type info "No OCT found"
	} elseif { [ llength $blocks ] > 1 } {
		post_message -type critical_warning "Multiple OCT blocks found!"

		foreach block $blocks {
			post_message -type info "$block"
		}
	} else {
		set block [ lindex $blocks 0 ]
		post_message -type info "Found OCT block: $block"


		foreach q_pin $pins(all_q_pins) {
			set_instance_assignment -name TERMINATION_CONTROL_BLOCK $block -to $q_pin -tag __$::GLOBAL_corename
		}

		foreach cq_pin $pins(cq_pins) {
			`ifdef IPTCL_EMULATED_MODE
			`else 
				set_instance_assignment -name TERMINATION_CONTROL_BLOCK $block -to $cq_pin -tag __$::GLOBAL_corename
			`endif
		}

		foreach cq_n_pin $pins(cq_n_pins) {
			`ifdef IPTCL_EMULATED_MODE 
            `else  
				set_instance_assignment -name TERMINATION_CONTROL_BLOCK $block -to $cq_n_pin -tag __$::GLOBAL_corename
			`endif
		}
	}

`ifdef IPTCL_NIOS_SEQUENCER
	set seq_clks 2
`else
	set seq_clks 0
`endif

`ifdef IPTCL_USE_DR_CLK
	set dr_clk 1
`else
	set dr_clk 0
`endif

	# Create the global and regional clocks

	# PLL clocks

	# Address/Command Clock
	set pll_ac_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_ac_clock) "pll_addr_cmd_clk" ]

`ifdef IPTCL_NIOS_SEQUENCER
	# Avalon Clock
	set pll_avl_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_avl_clock) "pll_avl_clk" ]

	# Scan Chain Configuration CLock
	set pll_config_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_config_clock) "pll_config_clk" ]
`endif

	set dr_clks 0
	set g_clks 0
	if { $::GLOBAL_num_pll_clock == [ expr 5 + $seq_clks + $dr_clk] } {
		
		set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_ac_clock -tag __$::GLOBAL_corename
		incr dr_clks

`ifdef IPTCL_NIOS_SEQUENCER
		set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_avl_clock -tag __$::GLOBAL_corename

`endif
	} else {
		post_message -type critical_warning "Expected [ expr 5 + $seq_clks + $dr_clk] PLL clocks but found $::GLOBAL_num_pll_clock!"
	}

`ifdef IPTCL_NIOS_SEQUENCER
	set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|s0|sequencer_rw_mgr_inst|rw_mgr_inst|rw_mgr_core_inst|rw_soft_reset_n" -tag __$::GLOBAL_corename
`endif

	for {set i 0} {$i < $::GLOBAL_number_of_q_groups} {incr i 1} {
`ifdef IPTCL_READ_FIFO_HALF_RATE
`else
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uio_pads|read_capture[$i].read_capture_clk_buffer" -tag __$::GLOBAL_corename				
`endif		
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uread_datapath|reset_n_valid_predict_clk[$i]" -tag __$::GLOBAL_corename
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uread_datapath|reset_n_fifo_write_side[$i]" -tag __$::GLOBAL_corename
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[$i]" -tag __$::GLOBAL_corename
	}

	set_instance_assignment -name ENABLE_BENEFICIAL_SKEW_OPTIMIZATION_FOR_NON_GLOBAL_CLOCKS ON -to $inst -tag __$::GLOBAL_corename
}

set_global_assignment -name ENABLE_ADVANCED_IO_DELAY_CHAIN_OPTIMIZATION ON

memphy_dump_all_pins ddr_db

if { [ llength $quartus(args) ] > 1 } {
	set param [lindex $quartus(args) 1]

	if { [ string match -dump_static_pin_map $param ] } {
		set filename "${::GLOBAL_corename}_static_pin_map.tcl"

		memphy_dump_static_pin_map ddr_db $filename
	}
}

set_global_assignment -name USE_DLL_FREQUENCY_FOR_DQS_DELAY_CHAIN ON
set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON

set_global_assignment -name ECO_REGENERATE_REPORT ON
