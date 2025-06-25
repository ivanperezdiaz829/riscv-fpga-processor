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

global ::GLOBAL_dq_group_size
global ::GLOBAL_corename
global ::GLOBAL_io_standard
global ::GLOBAL_number_of_q_groups

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

set asgn_types [ list IO_STANDARD INPUT_TERMINATION OUTPUT_TERMINATION CURRENT_STRENGTH_NEW DQ_GROUP TERMINATION_CONTROL_BLOCK ]
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

	foreach dq_pin $pins(all_dq_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $dq_pin -tag __$::GLOBAL_corename
`ifdef IPTCL_NO_PARALLEL_TERMINATION
`else
		set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to $dq_pin -tag __$::GLOBAL_corename
`endif
		set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to $dq_pin -tag __$::GLOBAL_corename
	}

	foreach ck_pin [ concat $pins(ck_pins) $pins(ckn_pins) $pins(dk_pins) $pins(dkn_pins) ] {
		set_instance_assignment -name IO_STANDARD "DIFFERENTIAL $::GLOBAL_io_standard CLASS I" -to $ck_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to $ck_pin -tag __$::GLOBAL_corename
	}
	
	set d6_delay -1
	set d5_delay -1

`ifdef IPTCL_NIOS_SEQUENCER	
 `ifdef HCX_COMPAT_MODE
 	set d6_delay 4
 `else
	`ifdef IPTCL_STRATIXV
	set d6_delay 15
	`else
	set d6_delay 2
	`endif
 `endif
`else
 `ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	set d6_delay 0
	set d5_delay 0
 `endif
`endif
	if {$d6_delay != -1} {
		foreach ck_pin [ concat $pins(ck_pins) $pins(ckn_pins) ] {
			set_instance_assignment -name D6_DELAY $d6_delay -to $ck_pin -tag __$::GLOBAL_corename	
		}
	}
	if {$d5_delay != -1} {
		foreach ck_pin [ concat $pins(ck_pins) $pins(ckn_pins) ] {
			set_instance_assignment -name D5_DELAY $d5_delay -to $ck_pin -tag __$::GLOBAL_corename	
		}
	}

	foreach qk_pin [ concat $pins(qk_pins) $pins(qkn_pins) ] {
		set_instance_assignment -name IO_STANDARD "DIFFERENTIAL $::GLOBAL_io_standard CLASS I" -to $qk_pin -tag __$::GLOBAL_corename
`ifdef IPTCL_NO_PARALLEL_TERMINATION
`else
		set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to $qk_pin -tag __$::GLOBAL_corename
`endif
	}

	foreach ac_pin $pins(ac_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $ac_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to $ac_pin -tag __$::GLOBAL_corename
	}

	foreach dm_pin $pins(dm_pins) {
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $dm_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to $dm_pin -tag __$::GLOBAL_corename
	}
`ifdef IPTCL_SKIP_DQ_GROUP_ASSIGNMENTS
`else
	foreach { qk_pin } $pins(qk_pins) { dq_pins } $pins(q_groups) {
		foreach dq_pin $dq_pins {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dq_pin -tag __$::GLOBAL_corename
		}
	}

	`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
	# By using the leveling-delay-chain to drive DK/DK#, we implicitly force the fitter
	# to place these pins in a DQ group. When the read group size is x18 (which has 24 pins	
	# available), we have enough pins in existing DQ groups for the DK/DK#pins, and so we
	# stick them in there as an optimization (not a requirement). When read group size is
	# x9, the fitter will implicitly create new x4 groups for the DK/DK#pins and it is 
	# recommended that you place the DK/DK#pins in the same I/O sub-bank as the DQ groups.
	if { $::GLOBAL_dq_group_size == 18 } {
		foreach {qk_pin} $pins(qk_pins) {dk_pin} $pins(dk_pins) {dkn_pin} $pins(dkn_pins) {
			set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dk_pin -tag __$::GLOBAL_corename
			set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dkn_pin -tag __$::GLOBAL_corename
		}
	}
	`else	
	 `ifdef IPTCL_NIOS_SEQUENCER
	  `ifdef IPTCL_RESERVED_PINS_FOR_DK_GROUP
	foreach {dk_pin} $pins(dk_pins) {reserved_pin} $pins(reserved_pins) {
		set_instance_assignment -name DQ_GROUP 4 -from $dk_pin -to $reserved_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name IO_STANDARD "$::GLOBAL_io_standard CLASS I" -to $reserved_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to $reserved_pin -tag __$::GLOBAL_corename
	}
 	`else
	foreach {qk_pin} $pins(qk_pins) {dk_pin} $pins(dk_pins) {dkn_pin} $pins(dkn_pins) {
		set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dk_pin -tag __$::GLOBAL_corename
		set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dkn_pin -tag __$::GLOBAL_corename
	}
	  `endif
	 `endif
	`endif

	# The DM (datamask) pin needs to be tied to a different DQS group depending on the RLDRAMII configuration
	#    - In x36 mode, there are 2 DQS groups per DM and it will be tied to QK[1] for each device (as per Micron datasheet)
	#    - In x9 and x18 mode, there's one DQS group per DM and it will be tied to QK[0] for each device
	if { $::GLOBAL_number_of_q_groups >= [ expr $::GLOBAL_number_of_dm_pins * 2 ] } {
		set number_of_clocks_per_dm [ expr $::GLOBAL_number_of_q_groups / $::GLOBAL_number_of_dm_pins ]
		for { set i 0 } { $i < [ llength $pins(dm_pins) ] } { incr i } {
			set dm_pin [ lindex $pins(dm_pins) $i ]
			set qk_pin [ lindex $pins(qk_pins) [ expr $number_of_clocks_per_dm * ($i + 1) - 1 ] ]
			set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dm_pin -tag __$::GLOBAL_corename
		}
	} else {
		foreach { qk_pin } $pins(qk_pins) { dm_pin } $pins(dm_pins) {
			if { $dm_pin != "" } {
				set_instance_assignment -name DQ_GROUP $::GLOBAL_dq_group_size -from $qk_pin -to $dm_pin -tag __$::GLOBAL_corename
			}
		}
	}
`endif

`ifdef IPTCL_STRATIXV
`else	
  `ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { [ string match -nocase "HARDCOPY*III*" [ get_global_assignment -name family ] ] } {
  `endif
  `ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		set delay_chain_config FLEXIBLE_TIMING
  `endif
  `ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} elseif { [ string match -nocase "STRATIX*III*" [ get_global_assignment -name family ] ] } {
  `endif
  `ifdef IPTCL_PRINT_MACRO_TIMING
		set delay_chain_config MACRO_TIMING
  `endif
  `ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	}
  `endif

	foreach dq_pin $pins(all_dq_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $dq_pin -tag __$::GLOBAL_corename
	}
	foreach dm_pin $pins(dm_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $dm_pin -tag __$::GLOBAL_corename
	}
	foreach dk_pin $pins(dk_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $dk_pin -tag __$::GLOBAL_corename
	}
	foreach dkn_pin $pins(dkn_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $dkn_pin -tag __$::GLOBAL_corename
	}
	foreach qk_pin $pins(qk_pins) {
		set_instance_assignment -name MEM_INTERFACE_DELAY_CHAIN_CONFIG $delay_chain_config -to $qk_pin -tag __$::GLOBAL_corename
	}
`endif

`ifdef IPTCL_PACKAGE_DESKEW
	# Set the package skew compensation parameter indicating that the design compensates for the package skew on the board
	foreach dq_pin $pins(all_dq_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $dq_pin -tag __$::GLOBAL_corename
	}
	foreach dm_pin $pins(dm_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $dm_pin -tag __$::GLOBAL_corename
	}
	foreach dk_pin $pins(dk_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $dk_pin -tag __$::GLOBAL_corename
	}
	foreach qk_pin $pins(qk_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $qk_pin -tag __$::GLOBAL_corename
	}
`else
	# Disable package skew compensation for data pins in timing analysis
	foreach dq_pin $pins(all_dq_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $dq_pin -tag __$::GLOBAL_corename
	}
	foreach dm_pin $pins(dm_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $dm_pin -tag __$::GLOBAL_corename
	}
	foreach dk_pin $pins(dk_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $dk_pin -tag __$::GLOBAL_corename
	}
	foreach qk_pin $pins(qk_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $qk_pin -tag __$::GLOBAL_corename
	}
`endif

`ifdef IPTCL_AC_PACKAGE_DESKEW
	# Set the package skew compensation parameter indicating that the design compensates for the package skew on the board for address/command pins
	foreach ck_pin [ concat $pins(ck_pins) $pins(ckn_pins) ] {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $ck_pin -tag __$::GLOBAL_corename
	}
	foreach ac_pin $pins(ac_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION ON -to $ac_pin -tag __$::GLOBAL_corename
	}
`else
	# Disable package skew compensation for address/command pins in timing analysis
	foreach ck_pin [ concat $pins(ck_pins) $pins(ckn_pins) ] {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $ck_pin -tag __$::GLOBAL_corename
	}
	foreach ac_pin $pins(ac_pins) {
		set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to $ac_pin -tag __$::GLOBAL_corename
	}
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

`ifdef IPTCL_NO_PARALLEL_TERMINATION
`else
		foreach qk_pin $pins(qk_pins) {
			set_instance_assignment -name TERMINATION_CONTROL_BLOCK $block -to $qk_pin -tag __$::GLOBAL_corename
		}

		foreach qkn_pin $pins(qkn_pins) {
			set_instance_assignment -name TERMINATION_CONTROL_BLOCK $block -to $qkn_pin -tag __$::GLOBAL_corename
		}
`endif
	}
	
`ifdef IPTCL_NIOS_SEQUENCER
	set seq_clks 2
`else
	set seq_clks 0
`endif

`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set c2p_p2c_clks 2
`else	
	set c2p_p2c_clks 0
`endif

`ifdef IPTCL_USE_DR_CLK
	set dr_clk 1
`else
	set dr_clk 0
`endif


	set pll_ck_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_ck_clock) "pll_mem_clk" ] 

	set pll_dk_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_dk_clock) "pll_write_clk" ] 

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else
	set pll_ac_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_ac_clock) "pll_addr_cmd_clk" ] 
`endif

`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_avl_clock) "pll_avl_clk" ]

	set pll_config_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_config_clock) "pll_config_clk" ]
`endif

`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pll_p2c_read_clock [ memphy_get_pll_clock_name_for_acf $pins(pll_p2c_read_clock) "pll_p2c_read_clk" ]
`endif

	set dr_clks 0
	set g_clks 0
	if { $::GLOBAL_num_pll_clock == [ expr 5 + $seq_clks + $c2p_p2c_clks + $dr_clk] } {
		if { [string compare -nocase $family_name "arriaiigx"] ==0 } {

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else				
			set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_ck_clock -tag __$::GLOBAL_corename
			incr g_clks
`endif			

`ifdef IPTCL_PHY_CLKBUF
`else
			set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_dk_clock -tag __$::GLOBAL_corename
			incr g_clks
`endif

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else
			set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_ac_clock -tag __$::GLOBAL_corename
			incr g_clks
`endif			

`ifdef IPTCL_NIOS_SEQUENCER
			set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_avl_clock -tag __$::GLOBAL_corename

			set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_config_clock -tag __$::GLOBAL_corename
`endif
		} else {
			if { [llength $pins(all_dq_pins)] <= 36 } {
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else				
				set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_ck_clock -tag __$::GLOBAL_corename
				incr dr_clks
`endif				
`ifdef IPTCL_PHY_CLKBUF
`else
				set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_dk_clock -tag __$::GLOBAL_corename
				incr dr_clks
`endif				
			} else {
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else				
				set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_ck_clock -tag __$::GLOBAL_corename
				incr g_clks
`endif				
`ifdef IPTCL_PHY_CLKBUF
`else
				set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to $pll_dk_clock -tag __$::GLOBAL_corename
				incr g_clks
`endif				
			}
`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else
			set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_ac_clock -tag __$::GLOBAL_corename
			incr dr_clks
`endif			
`ifdef IPTCL_NIOS_SEQUENCER
			set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_avl_clock -tag __$::GLOBAL_corename

			set_instance_assignment -name GLOBAL_SIGNAL "DUAL-REGIONAL CLOCK" -to $pll_config_clock -tag __$::GLOBAL_corename
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
`endif
		}
	} else {
		post_message -type critical_warning "Expected [ expr 5 + $seq_clks + $c2p_p2c_clks + $dr_clk] PLL clocks but found $::GLOBAL_num_pll_clock!"
	}

`ifdef IPTCL_NIOS_SEQUENCER
	set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|s0|sequencer_rw_mgr_inst|rw_mgr_inst|rw_mgr_core_inst|rw_soft_reset_n" -tag __$::GLOBAL_corename
`endif
	
	for {set i 0} {$i < $::GLOBAL_number_of_q_groups} {incr i 1} {
`ifdef IPTCL_READ_FIFO_HALF_RATE
`else
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uio_pads|dq_ddio[$i].read_capture_clk_buffer" -tag __$::GLOBAL_corename
`endif		
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uread_datapath|reset_n_valid_predict_clk[$i]" -tag __$::GLOBAL_corename
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uread_datapath|reset_n_fifo_write_side[$i]" -tag __$::GLOBAL_corename
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to "${inst}|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[$i]" -tag __$::GLOBAL_corename
	}

`ifdef IPTCL_READ_FIFO_HALF_RATE
	# Leave clock divider signals on local routing
	foreach dqs_in_clock_struct $pins(dqs_in_clocks) {
		array set dqs_in_clock $dqs_in_clock_struct
		set_instance_assignment -name GLOBAL_SIGNAL OFF -to $dqs_in_clock(div_pin) -tag __$::GLOBAL_corename
	}
`endif

	set_instance_assignment -name GLOBAL_SIGNAL OFF -from $pll_dk_clock -to "${inst}|dll0|dll_wys_m" -tag __$::GLOBAL_corename

	set_instance_assignment -name ENABLE_BENEFICIAL_SKEW_OPTIMIZATION_FOR_NON_GLOBAL_CLOCKS ON -to $inst -tag __$::GLOBAL_corename
`ifdef HCX_COMPAT_MODE	
	set_instance_assignment -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 200 -to $inst -tag __$::GLOBAL_corename
`endif	
	
`ifdef IPTCL_STRATIXV
`else	
	set_instance_assignment -name PLL_ENFORCE_USER_PHASE_SHIFT ON -to "${inst}|pll0|upll_memphy|auto_generated|pll1" -tag __$::GLOBAL_corename
`endif	
}

set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON

memphy_dump_all_pins ddr_db

if { [ llength $quartus(args) ] > 1 } {
	set param [lindex $quartus(args) 1]

	if { [ string match -dump_static_pin_map $param ] } {
		set filename "${::GLOBAL_corename}_static_pin_map.tcl"

		memphy_dump_static_pin_map ddr_db $filename
	}
}

set_global_assignment -name ECO_REGENERATE_REPORT ON
