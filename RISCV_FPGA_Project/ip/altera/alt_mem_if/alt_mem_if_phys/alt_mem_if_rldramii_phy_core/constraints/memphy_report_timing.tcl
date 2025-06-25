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


####################################################################
#
# THIS IS AN AUTO-GENERATED FILE!
# -------------------------------
# If you modify this files, all your changes will be lost if you
# regenerate the core!
#
# FILE DESCRIPTION
# ----------------
# This file contains the routines to generate the UniPHY memory
# interface timing report at the end of the compile flow.
#
# These routines are only meant to be used in this specific context.
# Trying to using them in a different context can have unexpected
# results.
#############################################################
# This report_timing script performs the timing analysis for
# all memory interfaces in the design.  In particular, this
# script will loop over all memory interface cores and
# instances and will timing analyze a range of paths that
# are applicable for each instance.  These include the
# timing analysis for the read capture, write, PHY
# address/command, and resynchronization paths among others.
#
# In performing the above timing analysis, the script
# calls procedures that are found in a separate file (report_timing_core.tcl)
# that has all the details of the timing analysis, and this
# file only serves as the top-level timing analysis flow.
#
# To reduce data lookups in all the procuedures that perform
# the individual timing analysis, data that is needed for
# multiple procedures is lookup up in this file and passed
# to the various parameters.  These data include both values
# that are applicable over all operating conditions, and those
# that are applicable to only one operating condition.
#
# In addition to the data that is looked up, the script
# and the underlying procedures use various other data
# that are stored in TCL sets and include the following:
#
#   t(.)     : Holds the memory timing parameters
#   board(.) : Holds the board skews and propagation delays
#   SSN(.)   : Holds the SSN pushout and pullin delays
#   IP(.)    : Holds the configuration of the memory interface
#              that was generated
#   ISI(.)   : Holds any intersymbol interference when the
#              memory interface is generated in a multirank
#              topology
#   MP(.)    : Holds some process variation data for the memory
#              See below for more information
#   pins(.)  : Holds the pin names for the memory interface
#
#############################################################

set script_dir [file dirname [info script]]

#############################################################
# Memory Specification Process Variation Information
#############################################################

# The percentage of the JEDEC specification that is due
# to process variation 

set MP(QKQ_max) 0.50
set MP(QKQ_min) 0.65
set MP(AS) 0.60
set MP(AH) 0.50
set MP(DS) 0.70
set MP(DH) 0.60
set MP(DKCK) 0.50

#############################################################
# Initialize the environment
#############################################################

if { ![info exists quartus(nameofexecutable)] || $quartus(nameofexecutable) != "quartus_sta" } {
	post_message -type error "This script must be run from quartus_sta"
	return 1
}

if { ! [ is_project_open ] } {
	if { [ llength $quartus(args) ] > 0 } {
		set project_name [lindex $quartus(args) 0]
		project_open -revision [ get_current_revision $project_name ] $project_name
	} else {
		post_message -type error "Missing project_name argument"
		return 1
	}
}

#############################################################
# Some useful functions
#############################################################
source "$script_dir/memphy_timing.tcl"
source "$script_dir/memphy_pin_map.tcl"
source "$script_dir/memphy_report_timing_core.tcl"

set family [get_family_string]
set family [string tolower $family]
if {$family == "arria ii gx"} {
	set family "arria ii"
}
if {$family == "stratix iv gx"} {
	set family "stratix iv"
}
if {$family == "stratix v gx"} {
	set family "stratix v"
}
if {$family == "stratix v gt"} {
	set family "stratix v"
}
if {$family == "hardcopy iv gx"} {
	set family "hardcopy iv"
}


#############################################################
# Load the timing netlist
#############################################################

if { ! [ timing_netlist_exist ] } {
	create_timing_netlist
}

set opcs [ list "" ]

set signoff_mode $::quartus(ipc_mode)
if { [string match "*Analyzer GUI" [get_current_timequest_report_folder]]} {
	read_sdc
	update_timing_netlist
	set script_dir [file dirname [info script]]
	source "$script_dir/memphy_timing.tcl"
	source "$script_dir/memphy_pin_map.tcl"
	source "$script_dir/memphy_report_timing_core.tcl"
}

load_package atoms
read_atom_netlist

load_package report
load_report
if { ! [timing_netlist_exist] } {
	post_message -type error "Timing Netlist has not been created. Run the 'Update Timing Netlist' task first."
	return
}

package require ::quartus::ioo
package require ::quartus::sin
initialize_ioo

#############################################################
# This is the main timing analysis function
#   It performs the timing analysis over all of the
#   various Memory Interface instances and timing corners
#############################################################

set mem_if_memtype "rldram2"

if [ info exists ddr_db ] {
	unset ddr_db
}

###############################################
# This is the main call to the netlist traversal routines
# that will automatically find all pins and registers required
# to timing analyze the Core.
memphy_initialize_ddr_db ddr_db

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
	set old_active_clocks [get_active_clocks]
	set_active_clocks [all_clocks]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
} 
`endif

# If multiple instances of this core are present in the
# design they will all be analyzed through the
# following loop
set instances [ array names ddr_db ]
set inst_id 0
foreach inst $instances {
	if { [ info exists pins ] } {
		# Clean-up stale content
		unset pins
	}
	array set pins $ddr_db($inst)

`ifdef IPTCL_PHY_ONLY
	set inst_controller [regsub {if0$} $inst "c0"]
`else
	set inst_controller [regsub {p0$} $inst "c0"]
`endif

	####################################################
	#                                                  #
	# Transfer the pin names to a more readable scheme #
	#                                                  #
	####################################################
	set qk_pins $pins(qk_pins)
	set qkn_pins $pins(qkn_pins)
	set q_groups [ list ]
	foreach q_group $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]

	set dk_pins $pins(dk_pins)
	set dkn_pins $pins(dkn_pins)
	set d_groups [ list ]

	foreach d_group $pins(d_groups) {
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


	#################################################################################
	# Find some design values and parameters that will used during the timing analysis
	# that do not change accross the operating conditions
	set period $t(CK)
	
	# Get the number of PLL steps
`ifdef IPTCL_STRATIXV
	set pll_steps "UNDEFINED"
`else
	set clk_to_write_d [memphy_traverse_to_ddio_out_pll_clock [lindex $all_dq_pins 0] msg_list]
	`ifdef IPTCL_ACV_FAMILY
	set pll_steps 0
	`else
	set pll_steps [expr {int([get_vco_freq -clk $clk_to_write_d ]*8.0*$period/1000.0)}]
	`endif
`endif
	
`ifdef IPTCL_PACKAGE_DESKEW
	set max_package_skew 0.040
`else
	# Package skew
	[catch {get_max_package_skew} max_package_skew]
	if { ($max_package_skew == "") } {
		set max_package_skew 0
	} else {
		set max_package_skew [expr $max_package_skew / 1000.0]
	}
`endif
	
	# DLL length
`ifdef IPTCL_STRATIXV
	# STRATIX V DLL Length is always 8
	set dll_length 8
`else	
	set dll_length 0
	set dqs0 [lindex $qk_pins 0]
	if {$dqs0 != ""} {
		set dll_id [memphy_traverse_to_dll_id $dqs0 msg_list]
		if {$dll_id != -1} {
	`ifdef IPTCL_ACV_FAMILY
			set dll_length 8
	`else
			set dll_length [get_atom_node_info -key UINT_DELAY_CHAIN_LENGTH -node $dll_id]
	`endif
		}
	}
	if {$dll_length == 0} {
		set dll_length 8
		post_message -type critical_warning "Unable to determine DLL delay chain length.  Assuming default setting of $dll_length"
	}
`endif

	# DQS_phase offset
	set dqs_phase [ memphy_get_dqs_phase $qk_pins ]

	# Get the interface type (HPAD or VPAD)
	set interface_type [memphy_get_io_interface_type $all_dq_pins]

	# Treat the VHPAD interface as the same as a HPAD interface
	if {($interface_type == "VHPAD") || ($interface_type == "HYBRID")} {
		set interface_type "HPAD"
	}
	
	# Get the IO standard which helps us determine the Memory type
	set io_std [memphy_get_io_standard [lindex $all_dq_pins 0]]

	if {$interface_type == "" || $interface_type == "UNKNOWN" || $io_std == "" || $io_std == "UNKNOWN"} {
		set result 0
	}

	# Get some of the FPGA jitter and DCD specs
	# When not specified all jitter values are peak-to-peak jitters in ns
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
	set outputDQSpathjitter $t(WL_JITTER)
	set outputDQSpathjitter_setup_prop $t(WL_JITTER_DIVISION)
`else
	set tJITper [expr [get_io_standard_node_delay -dst MEM_CK_PERIOD_JITTER -io_standard $io_std -parameters [list IO $interface_type] -period $period]/1000.0]
	set tJITdty [expr [get_io_standard_node_delay -dst MEM_CK_DC_JITTER -io_standard $io_std -parameters [list IO $interface_type]]/1000.0]
	# DCD value that is looked up is in %, and thus needs to be divided by 100
	set tDCD [expr [get_io_standard_node_delay -dst MEM_CK_DCD -io_standard $io_std -parameters [list IO $interface_type]]/100.0]
	# This is the peak-to-peak jitter on the whole DQ-DQS read capture path
	set DQSpathjitter [expr [get_io_standard_node_delay -dst DQDQS_JITTER -io_standard $io_std -parameters [list IO $interface_type]]/1000.0]
	# This is the proportion of the DQ-DQS read capture path jitter that applies to setup (looed up value is in %, and thus needs to be divided by 100)
	set DQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst DQDQS_JITTER_DIVISION -io_standard $io_std -parameters [list IO $interface_type]]/100.0]
	# This is the peak-to-peak jitter on the whole DQ-DQS write path
	set outputDQSpathjitter [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER -io_standard $io_std -parameters [list IO $interface_type] -in_fitter]/1000.0]
	# This is the proportion of the DQ-DQS write path jitter that applies to setup (looed up value is in %, and thus needs to be divided by 100)
	set outputDQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER_DIVISION -io_standard $io_std -parameters [list IO $interface_type] -in_fitter]/100.0]
`endif
	
	set fname ""
	set fbasename ""
	if {[llength $instances] <= 1} {
		set fbasename "${::GLOBAL_corename}"
	} else {
		set fbasename "${::GLOBAL_corename}_${inst_id}"
	}
	
	set fname "${fbasename}_summary.csv"
	
	#################################################################################
	# Now loop the timing analysis over the various operating conditions
	set summary [list]
	foreach opc $opcs {
		if {$opc != "" } {
			set_operating_conditions $opc
			update_timing_netlist
		}
		set opcname [get_operating_conditions_info [get_operating_conditions] -display_name]
		set opcname [string trim $opcname]
		
		set model_corner [memphy_get_model_corner]
		initialize_sin -model [lindex $model_corner 0] -corner [lindex $model_corner 1]
		
		global assumptions_cache
		set in_gui [regexp "TimeQuest Timing Analyzer GUI" [get_current_timequest_report_folder]]
		if {!$in_gui && [array exists assumptions_cache] &&  [info exists assumptions_cache(${::GLOBAL_corename}-$inst)] } {
			set assumptions_valid $assumptions_cache(${::GLOBAL_corename}-$inst)
			if {!$assumptions_valid} {
				post_message -type critical_warning "Read Capture and Write timing analyses may not be valid due to violated timing model assumptions"
				post_message -type critical_warning "See violated timing model assumptions in previous timing analysis above"
			}
		} else {
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
			if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
				set assumptions_valid [memphy_verify_flexible_timing_assumptions $inst pins $mem_if_memtype]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
			} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
				set assumptions_valid [memphy_verify_high_performance_timing_assumptions $inst pins $mem_if_memtype]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
			}
`endif	
			set assumptions_cache(${::GLOBAL_corename}-$inst) $assumptions_valid
		}	

		#######################################
		# Determine parameters and values that are valid only for this operating condition

		# Min/Max scaling factor
		[catch {get_float_table_node_delay -src {SCALE_FACTOR} -dst {MEM_INTERFACE_SCALE_FACTOR} -parameters {IO}} DQS_max_scale_factor]
		[catch {get_float_table_node_delay -src {SCALE_FACTOR} -dst {MEM_INTERFACE_SCALE_FACTOR} -parameters {IO MIN}} DQS_min_scale_factor]
		if {  (($DQS_max_scale_factor != 0) || ($DQS_max_scale_factor == "")) && (($DQS_min_scale_factor != 0) || ($DQS_min_scale_factor == "")) } {
			set DQS_min_max [expr $DQS_max_scale_factor - $DQS_min_scale_factor]
		} else {
			set DQS_min_max 0
		}
		
		#######################################
		# Write Analysis

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			memphy_perform_flexible_write_launch_timing_analysis $opcs $opcname $inst $family $DQS_min_max $interface_type $max_package_skew $dll_length $period pins t summary MP IP board
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
			memphy_perform_macro_write_launch_timing_analysis $opcs $opcname $inst pins t summary IP ISI board
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif

		#######################################
		# Read Analysis

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			memphy_perform_flexible_read_capture_timing_analysis $opcs $opcname $inst $family $DQS_min_max $io_std $interface_type $max_package_skew $dqs_phase $period $all_dq_pins pins t summary MP IP board fpga
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		} else {
`endif
`ifdef IPTCL_PRINT_MACRO_TIMING
			memphy_perform_macro_read_capture_timing_analysis $opcs $opcname $inst $dqs_phase $all_dq_pins pins t summary IP board
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		}
`endif
		memphy_perform_resync_timing_analysis $opcs $opcname $inst ${::GLOBAL_corename} $family $DQS_min_max $io_std $interface_type $period pins t summary MP IP board fpga SSN

		#######################################
		# PHY and Address/command Analyses

		memphy_perform_ac_analyses  $opcs $opcname $inst pins t summary IP		
		memphy_perform_phy_analyses $opcs $opcname $inst $inst_controller pins t summary IP
		if {$IP(write_deskew_mode) == "dynamic"} {
			memphy_perform_calibrated_dk_vs_ck_timing_analysis $opcs $opcname $inst $family $period $dll_length $interface_type $tJITper $tJITdty $tDCD $pll_steps pins t summary MP IP SSN board ISI
		}

		#######################################
		# Bus Turnaround Time Analysis
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			memphy_perform_flexible_bus_turnaround_time_analysis $opcs $opcname $inst $family $period $dll_length $interface_type $tJITper $tJITdty $tDCD $outputDQSpathjitter $outputDQSpathjitter_setup_prop $pll_steps pins t summary MP IP SSN board ISI
`endif			
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		} 
`endif

	}

	#################################################
	# Now perform analysis of some of the calibrated paths that consider
	# Worst-case conditions	

	set opcname "All Conditions"

	#######################################
	# Print out the Summary Panel for this instance	

	set summary [lsort -command memphy_sort_proc $summary]

	set f -1
	if { [memphy_get_operating_conditions_number] == 0 } {
		set f [open $fname w]
`ifdef IPTCL_ENABLE_EXTRA_REPORTING

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			set_active_clocks $old_active_clocks
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		} 
`endif

		set setup_fname "${fbasename}_wc_setup_paths.txt"
		set hold_fname "${fbasename}_wc_hold_paths.txt"
		set recovery_fname "${fbasename}_wc_recovery_paths.txt"
		set removal_fname "${fbasename}_wc_removal_paths.txt"

		set f_setup [open $setup_fname w]
		set f_hold [open $hold_fname w]
		set f_recovery [open $recovery_fname w]
		set f_removal [open $removal_fname w]
		
		set path_headers "FROM\tTO\tSLACK\tFROM_LOC\tTO_LOC\tCLK_SKEW"
		puts $f_setup $path_headers
		puts $f_hold $path_headers
		puts $f_recovery $path_headers
		puts $f_removal $path_headers
		set num_failing_path $IP(num_report_paths)

		load_package ::quartus::device
		set device_name [get_report_panel_data -name {Fitter||Fitter Summary} -row_name {Device} -col 1]
		set family_member [get_part_info -device $device_name]
		set opcname [get_operating_conditions_info [get_operating_conditions] -display_name]
		set opcname [string trim $opcname]
		set entity_names_on [ memphy_are_entity_names_on ]
		set prefix [ string map "| |*:" $inst ]
		set prefix "*:$prefix"
		set prefix_controller [ string map "| |*:" $inst_controller ]
		set prefix_controller "*:$prefix_controller"

		set afi_clk_node [get_clocks [memphy_get_clock_name_from_pin_name $pins(pll_afi_clock)]]
		set addr_cmd_clk_node [get_clocks [memphy_get_clock_name_from_pin_name $pins(pll_ac_clock)]]

		set speedgrade [get_part_info -speed_grade $device_name]
		set tempgrade [get_part_info -temperature_grade $device_name]
		set speed_temp_grade [string toupper "[string trim [string range $tempgrade 0 0 ]]${speedgrade}"]

		puts $f "Extra Reporting:"
		puts $f "=============================================="
		puts $f "DEVICE : $device_name"
		puts $f "SPEEDGRADE : $speedgrade"
		puts $f "TEMPGRADE : $tempgrade"
		puts $f "SPEED_TEMP_GRADE : $speed_temp_grade"
		set family_name [lindex [get_part_info -family $device_name] 0]
		regsub -all " " $family_name "" family_name
		puts $f "FAMILY : $family_name"
		puts $f "FAMILY_VARIANT : [get_part_info -family_variant $device_name]"
		puts $f "FAMILY_MEMBER : $family_member"
		set clock_fmax [get_clock_fmax_info]
		foreach clock_fmax_line $clock_fmax {
			set clock_name [lindex $clock_fmax_line 0]
			set clock_fmax [lindex $clock_fmax_line 1]
			if {[string compare -nocase $clock_name "${inst}|memphy_pll_afi_clk"] == 0} {
				puts $f "AFI_CLK_FMAX : $clock_fmax"
			}
			if {[string compare -nocase $clock_name "${inst}|afi_clk_export"] == 0} {
				puts $f "AFI_EXPORT_CLK_FMAX : $clock_fmax"
			}
			if {[string compare -nocase $clock_name "${inst}|ctl_afi_clk"] == 0} {
				puts $f "CTL_AFI_CLK_FMAX : $clock_fmax"
			}
			if {[regexp -nocase {\|driver_afi_clk_\d+\s*$} $clock_name] == 1} {
				puts $f "DRV_AFI_CLK_FMAX : $clock_fmax : $clock_name"
			}
		}
		puts $f "=============================================="
		puts $f  "Critical Path Summary"
		puts $f "REPORTING_CORNER : $opcname"
		foreach_in_collection path [get_timing_paths -setup -npaths 1] {
			puts $f "WC_SETUP SLACK : [get_path_info $path -slack]"
			puts $f "WC_SETUP REQUIRED TIME : [get_path_info $path -required_time]"
			puts $f "WC_SETUP CLK SKEW : [get_path_info $path -clock_skew]"
			puts $f "WC_SETUP FROM : [get_node_info [get_path_info $path -from] -name]"
			puts $f "WC_SETUP TO : [get_node_info [get_path_info $path -to] -name]"
			puts $f "WC_SETUP FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
			
			set to_clk [get_path_info $path -to_clock]
			if {[string compare $to_clk ""] == 0} {
				puts $f "WC_SETUP TO CLK : n/a"
			} else {			
				puts $f "WC_SETUP TO CLK : [get_clock_info $to_clk -name]"
			}
			
			puts $f "WC_SETUP FROM LOC : [get_node_info [get_path_info $path -from] -location]"
			puts $f "WC_SETUP TO LOC : [get_node_info [get_path_info $path -to] -location]"
		}

		foreach_in_collection path [get_timing_paths -setup -npaths $num_failing_path] {
			set path_from [get_node_info [get_path_info $path -from] -name]
			set path_to [get_node_info [get_path_info $path -to] -name]
			set path_slack [get_path_info $path -slack]
			set path_from_loc [get_node_info [get_path_info $path -from] -location]
			set path_to_loc [get_node_info [get_path_info $path -to] -location]
			set path_clk_skew [get_path_info $path -clock_skew]
			puts $f_setup "$path_from\t$path_to\t$path_slack\t$path_from_loc\t$path_to_loc\t$path_clk_skew"
		}

		foreach_in_collection path [get_timing_paths -hold -npaths 1] {
			puts $f "WC_HOLD SLACK : [get_path_info $path -slack]"
			puts $f "WC_HOLD REQUIRED TIME : [get_path_info $path -required_time]"
			puts $f "WC_HOLD CLK SKEW : [get_path_info $path -clock_skew]"
			puts $f "WC_HOLD FROM : [get_node_info [get_path_info $path -from] -name]"
			puts $f "WC_HOLD TO : [get_node_info [get_path_info $path -to] -name]"
			puts $f "WC_HOLD FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
			puts $f "WC_HOLD TO CLK : [get_clock_info [get_path_info $path -to_clock] -name]"
			puts $f "WC_HOLD FROM LOC : [get_node_info [get_path_info $path -from] -location]"
			puts $f "WC_HOLD TO LOC : [get_node_info [get_path_info $path -to] -location]"
		}

		foreach_in_collection path [get_timing_paths -hold -npaths $num_failing_path] {
			set path_from [get_node_info [get_path_info $path -from] -name]
			set path_to [get_node_info [get_path_info $path -to] -name]
			set path_slack [get_path_info $path -slack]
			set path_from_loc [get_node_info [get_path_info $path -from] -location]
			set path_to_loc [get_node_info [get_path_info $path -to] -location]
			set path_clk_skew [get_path_info $path -clock_skew]
			puts $f_hold "$path_from\t$path_to\t$path_slack\t$path_from_loc\t$path_to_loc\t$path_clk_skew"
		}

		foreach_in_collection path [get_timing_paths -recovery -npaths $num_failing_path] {
			set path_from [get_node_info [get_path_info $path -from] -name]
			set path_to [get_node_info [get_path_info $path -to] -name]
			set path_slack [get_path_info $path -slack]
			set path_from_loc [get_node_info [get_path_info $path -from] -location]
			set path_to_loc [get_node_info [get_path_info $path -to] -location]
			set path_clk_skew [get_path_info $path -clock_skew]
			puts $f_recovery "$path_from\t$path_to\t$path_slack\t$path_from_loc\t$path_to_loc\t$path_clk_skew"
		}

		foreach_in_collection path [get_timing_paths -removal -npaths $num_failing_path] {
			set path_from [get_node_info [get_path_info $path -from] -name]
			set path_to [get_node_info [get_path_info $path -to] -name]
			set path_slack [get_path_info $path -slack]
			set path_from_loc [get_node_info [get_path_info $path -from] -location]
			set path_to_loc [get_node_info [get_path_info $path -to] -location]
			set path_clk_skew [get_path_info $path -clock_skew]
			puts $f_removal "$path_from\t$path_to\t$path_slack\t$path_from_loc\t$path_to_loc\t$path_clk_skew"
		}

		if { ! $entity_names_on } {
			set tpaths [get_timing_paths -from [get_registers $inst_controller|*controller_*inst|* ] -to [get_registers $inst_controller|*controller_*inst|* ] -npaths 1 -setup]
		} else {
			set tpaths [get_timing_paths -from [get_registers $prefix_controller|*:*controller_*inst|* ] -to [get_registers $prefix_controller|*:*controller_*inst|* ] -npaths 1 -setup]
		}
		foreach_in_collection path $tpaths {
			puts $f "WC_SETUP_CONTROLLER SLACK : [get_path_info $path -slack]"
			puts $f "WC_SETUP_CONTROLLER FROM : [get_node_info [get_path_info $path -from] -name]"
			puts $f "WC_SETUP_CONTROLLER TO : [get_node_info [get_path_info $path -to] -name]"
			puts $f "WC_SETUP_CONTROLLER FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
			puts $f "WC_SETUP_CONTROLLER TO CLK : [get_clock_info [get_path_info $path -to_clock] -name]"
		}

`ifdef IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK
`else
		if { ! $entity_names_on } {
			set tpaths [get_timing_paths -from [get_registers $inst|* ] -to [get_registers $inst|* ] -npaths 1 -setup -from_clock $afi_clk_node -to_clock $addr_cmd_clk_node ]
		} else {
			set tpaths [get_timing_paths -from [get_registers $prefix|* ] -to [get_registers $prefix|* ] -npaths 1 -setup -from_clock $afi_clk_node -to_clock $addr_cmd_clk_node]
		}
		foreach_in_collection path $tpaths {
			puts $f "WC_SETUP_PHY_CORE_AC SLACK : [get_path_info $path -slack]"
			puts $f "WC_SETUP_PHY_CORE_AC REQUIRED TIME : [get_path_info $path -required_time]"
			puts $f "WC_SETUP_PHY_CORE_AC CLK SKEW : [get_path_info $path -clock_skew]"
			puts $f "WC_SETUP_PHY_CORE_AC FROM : [get_node_info [get_path_info $path -from] -name]"
			puts $f "WC_SETUP_PHY_CORE_AC TO : [get_node_info [get_path_info $path -to] -name]"
			puts $f "WC_SETUP_PHY_CORE_AC FROM LOC : [get_node_info [get_path_info $path -from] -location]"
			puts $f "WC_SETUP_PHY_CORE_AC TO LOC : [get_node_info [get_path_info $path -to] -location]"
			puts $f "WC_SETUP_PHY_CORE_AC FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
			puts $f "WC_SETUP_PHY_CORE_AC TO CLK : [get_clock_info [get_path_info $path -to_clock] -name]"
			puts $f "WC_SETUP_PHY_CORE_AC TO CLK PHASE : [get_clock_info [get_path_info $path -to_clock] -phase]"
		}

		set tpaths [get_timing_paths -to_clock $addr_cmd_clk_node -npaths 1 -setup ]
		foreach_in_collection path $tpaths {
				puts $f "WC_AC_CLOCK_SETUP SLACK : [get_path_info $path -slack]"
				puts $f "WC_AC_CLOCK_SETUP REQUIRED TIME : [get_path_info $path -required_time]"
				puts $f "WC_AC_CLOCK_SETUP CLK SKEW : [get_path_info $path -clock_skew]"
				puts $f "WC_AC_CLOCK_SETUP FROM : [get_node_info [get_path_info $path -from] -name]"
				puts $f "WC_AC_CLOCK_SETUP TO : [get_node_info [get_path_info $path -to] -name]"
				puts $f "WC_AC_CLOCK_SETUP FROM LOC : [get_node_info [get_path_info $path -from] -location]"
				puts $f "WC_AC_CLOCK_SETUP TO LOC : [get_node_info [get_path_info $path -to] -location]"
				puts $f "WC_AC_CLOCK_SETUP FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
				puts $f "WC_AC_CLOCK_SETUP TO CLK : [get_clock_info [get_path_info $path -to_clock] -name]"
				puts $f "WC_AC_CLOCK_SETUP TO CLK PHASE : [get_clock_info [get_path_info $path -to_clock] -phase]"
		}
		set tpaths [get_timing_paths -to_clock $addr_cmd_clk_node -npaths 1 -hold ]
		foreach_in_collection path $tpaths {
			puts $f "WC_AC_CLOCK HOLD SLACK : [get_path_info $path -slack]"
		}
`endif

		if { ! $entity_names_on } {
			set tpaths [get_timing_paths -from [get_registers $inst|* ] -to [get_registers $inst|* ] -npaths 1 -setup]
		} else {
			set tpaths [get_timing_paths -from [get_registers $prefix|* ] -to [get_registers $prefix|* ] -npaths 1 -setup]
		}
		foreach_in_collection path $tpaths {
			puts $f "WC_SETUP_PHY SLACK : [get_path_info $path -slack]"
			puts $f "WC_SETUP_PHY FROM : [get_node_info [get_path_info $path -from] -name]"
			puts $f "WC_SETUP_PHY TO : [get_node_info [get_path_info $path -to] -name]"
			puts $f "WC_SETUP_PHY FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
			puts $f "WC_SETUP_PHY TO CLK : [get_clock_info [get_path_info $path -to_clock] -name]"
		}

		if { ! $entity_names_on } {
			set tpaths [get_timing_paths -from [get_registers *traffic_generator_0|* ] -to [get_registers *traffic_generator_0|* ] -npaths 1 -setup]
		} else {
			set tpaths [get_timing_paths -from [get_registers *:traffic_generator_0|* ] -to [get_registers *:traffic_generator_0|* ] -npaths 1 -setup]
		}
		foreach_in_collection path $tpaths {
			puts $f "WC_SETUP_DRIVER SLACK : [get_path_info $path -slack]"
			puts $f "WC_SETUP_DRIVER FROM : [get_node_info [get_path_info $path -from] -name]"
			puts $f "WC_SETUP_DRIVER TO : [get_node_info [get_path_info $path -to] -name]"
			puts $f "WC_SETUP_DRIVER FROM CLK : [get_clock_info [get_path_info $path -from_clock] -name]"
			puts $f "WC_SETUP_DRIVER TO CLK : [get_clock_info [get_path_info $path -to_clock] -name]"
			puts $f "NOTE: WC DRIVER paths are for all drivers in the design"
		}

		puts $f "==============================================\n"
		
		close $f_setup
		close $f_hold
		close $f_recovery
		close $f_removal
		
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
			set_active_clocks [all_clocks]
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
		} 
`endif

`endif

		puts $f "Core: ${::GLOBAL_corename} - Instance: $inst"
		puts $f "Path, Setup Margin, Hold Margin"
	} else {
		set f [open $fname a]
	}

	
`ifdef IPTCL_ENABLE_EXTRA_REPORTING
	`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
	`endif
	`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		set_active_clocks $old_active_clocks
	`endif
	`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} 
	`endif

	set panel_name "$inst Cross-Clock Transfer Minimum Slacks"
	set root_folder_name [get_current_timequest_report_folder]
	if { ! [string match "${root_folder_name}*" $panel_name] } {
		set panel_name "${root_folder_name}||$panel_name"
	}
	if {[get_report_panel_id $root_folder_name] == -1} {
		set panel_id [create_report_panel -folder $root_folder_name]
	}
	set panel_id [get_report_panel_id $panel_name]
	if {$panel_id != -1} {
		delete_report_panel -id $panel_id
	}

	set panel_id [create_report_panel -table $panel_name]

	add_row_to_table -id $panel_id [list "From" "To" "Min. Setup Slack" "Min. Hold Slack" "Min. Recovery Slack" "Min. Removal Slack"]

	set cross_clock_transfer_table [list]
	set all_clks [list]
	foreach_in_collection clk [get_clocks] {
		set clk_name [get_clock_info -name $clk]
		lappend all_clks $clk_name
	}
	set npaths 1
	foreach {from_clock} $all_clks {
		foreach {to_clock} $all_clks {
			set val_setup [report_timing -from [get_clocks $from_clock] -to [get_clocks $to_clock] -npaths $npaths -setup -quiet]
			set val_hold [report_timing -from [get_clocks $from_clock] -to [get_clocks $to_clock] -npaths $npaths -hold -quiet]
			set val_recovery [report_timing -from [get_clocks $from_clock] -to [get_clocks $to_clock] -npaths $npaths -recovery -quiet]
			set val_removal [report_timing -from [get_clocks $from_clock] -to [get_clocks $to_clock] -npaths $npaths -removal -quiet]
			if {[lindex $val_recovery 0] == 0} {
				set val_recovery {0 "--"}
			}
			if {[lindex $val_removal 0] == 0} {
				set val_removal {0 "--"}
			}
			if {[lindex $val_setup 0] > 0 && [lindex $val_hold 0] > 0} {
				lappend cross_clock_transfer_table [list $from_clock $to_clock [lindex $val_setup 1] [lindex $val_hold 1] [lindex $val_recovery 1] [lindex $val_removal 1]]
			}
		}
	}

	foreach summary_line $cross_clock_transfer_table {
		add_row_to_table -id $panel_id $summary_line
	}

	`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	if { $::GLOBAL_phy_use_micro_timing } {
	`endif
	`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
		set_active_clocks [all_clocks]
	`endif
	`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
	} 
	`endif
`endif


	post_message -type info "Core: ${::GLOBAL_corename} - Instance: $inst"
	post_message -type info "                                                         setup  hold"
	set panel_name "$inst"
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

	# Create summary panel
	set total_failures 0
	set rows [list]
	lappend rows "add_row_to_table -id \$panel_id \[list \"Path\" \"Operating Condition\" \"Setup Slack\" \"Hold Slack\"\]"
	foreach summary_line $summary {
		foreach {corner order path su hold num_su num_hold} $summary_line { }
		if {($num_su == 0) || ([string trim $su] == "")} {
			set su "--"
		}
		if {($num_hold == 0) || ([string trim $hold] == "")} {
			set hold "--"
		}


		if { ($su != "--" && $su < 0) || ($hold != "--" && $hold < 0) } {
			incr total_failures
			set type warning
			set offset 50
		} else {
			set type info
			set offset 53
		}
		if {$su != "--"} {
			set su [ memphy_round_3dp $su]
		}
		if {$hold != "--"} {
			set hold [ memphy_round_3dp $hold]
		}
		post_message -type $type [format "%-${offset}s | %6s %6s" $path $su $hold]
		puts $f [format "\"%s\",%s,%s" $path $su $hold]
		set fg_colours [list black black]
		if { $su != "--" && $su < 0 } {
			lappend fg_colours red
		} else {
			lappend fg_colours black
		}

		if { $hold != "" && $hold < 0 } {
			lappend fg_colours red
		} else {
			lappend fg_colours black
		}
		lappend rows "add_row_to_table -id \$panel_id -fcolors \"$fg_colours\" \[list \"$path\" \"$corner\" \"$su\" \"$hold\"\]"
	}
	close $f
	if {$total_failures > 0} {
		post_message -type critical_warning "DDR Timing requirements not met"
		set panel_id [create_report_panel -table $panel_name -color red]
	} else {
		set panel_id [create_report_panel -table $panel_name]
	}
	foreach row $rows {
		eval $row
	}
	
	write_timing_report

	if { ( [ string compare -nocase $family "stratix iv" ] == 0 ) || ( [ string compare -nocase $family "stratix iii" ] == 0 ) } {
		set clr_bfr_tri [ get_global_assignment -name RELEASE_CLEARS_BEFORE_TRI_STATES ] 
		if { [ string compare -nocase $clr_bfr_tri "on" ] == 0 } {
			post_message -type critical_warning "This design has the QSF assignment RELEASE_CLEARS_BEFORE_TRI_STATES set to ON. UniPHY IP in Stratix III and Stratix IV is not compatible with this setting. Set the RELEASE_CLEARS_BEFORE_TRI_STATES assignment to OFF to resolve the issue."
		}
	}

	incr inst_id
}

`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
if { $::GLOBAL_phy_use_micro_timing } {
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_TIMING
	set_active_clocks $old_active_clocks
`endif
`ifdef IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH
} 
`endif
uninitialize_sin
uninitialize_ioo
