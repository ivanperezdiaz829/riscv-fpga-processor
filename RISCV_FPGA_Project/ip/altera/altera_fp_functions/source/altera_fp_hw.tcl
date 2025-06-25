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


package require -exact qsys 13.1

# 
# module altera_fp
# 
set_module_property NAME altera_fp_functions
set_module_property VERSION  13.1
set_module_property INTERNAL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Floating Point Functions"
set_module_property DESCRIPTION "A collection of floating point functions"
set_module_property EDITABLE false
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property VALIDATION_CALLBACK validate_input
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property HIDE_FROM_SOPC true
set_module_property HIDE_FROM_QSYS true

#placeholder 
add_documentation_link "User Guide" http://www.altera.com/literature/ug/ug_altfp_mfug.pdf

# 
# file sets
# 
add_fileset ALTFP_FP_QUARTUS_SYNTH QUARTUS_SYNTH quartus_synth_callback
add_fileset ALTFP_FP_SIM_VERILOG SIM_VERILOG sim_verilog_callback
add_fileset ALTFP_FP_SIM_VHDL SIM_VHDL sim_vhdl_callback

#
# functions list
# the format of the list is 
# [list name cmd_proc validate_proc elaborate_proc]
# cmd_proc should contain the function name and other function specific
# parameters such as exponent and mantissa widths.
# validate_proc will be run at the end of the validation.
# elaborate_proc should add appropriate data inputs; clk, reset and if selected
# enable input will have been added before running this proc.
set fp_funcs(Add) [list FPAdd op_exp_man default_validate default_elaborate]
set fp_funcs(Subtract) [list FPSub op_exp_man default_validate default_elaborate]
set fp_funcs(Multiply) [list FPMul op_exp_man default_validate default_elaborate]
set fp_funcs(Min) [list FPMin op_exp_man min_max_validate default_elaborate]
set fp_funcs(Max) [list FPMax op_exp_man min_max_validate default_elaborate]
set {fp_funcs(Square Root)} [list FPSqrt op_exp_man default_validate one_each_same_width_elaborate]
set fp_funcs(Compare) [list "" compare_cmd compare_validate two_in_single_bit_out_elaborate]
set fp_funcs(Convert) [list FPCompare convert_cmd convert_validate convert_elaborate]

# 
# parameters
# 
add_parameter fp_function STRING "Add" 
set_parameter_property fp_function DISPLAY_NAME "Name"
set_parameter_property fp_function UNITS None
set_parameter_property fp_function ALLOWED_RANGES [lsort [array names fp_funcs]] 
set_parameter_property fp_function DESCRIPTION "Choose the floating point function"
set_parameter_property fp_function AFFECTS_GENERATION true

add_parameter fp_format STRING "single" 
#set_parameter_property fp_format DISPLAY_HINT radio
set_parameter_property fp_format DISPLAY_NAME "Format"
set_parameter_property fp_format UNITS None
set_parameter_property fp_format ALLOWED_RANGES {"single" "double" "custom"} 
set_parameter_property fp_format DESCRIPTION "Choose the floating point format"
set_parameter_property fp_format AFFECTS_GENERATION true

add_parameter fp_exp POSITIVE 8 
set_parameter_property fp_exp DISPLAY_NAME "Exponent"
set_parameter_property fp_exp ALLOWED_RANGES 5:11 
set_parameter_property fp_exp UNITS Bits
set_parameter_property fp_exp DESCRIPTION "Choose the width of the exponent in bits"
set_parameter_property fp_exp AFFECTS_GENERATION true

add_parameter fp_exp_derived POSITIVE 8
set_parameter_property fp_exp_derived DERIVED true
set_parameter_property fp_exp_derived VISIBLE false
set_parameter_property fp_exp_derived AFFECTS_GENERATION true

add_parameter fp_man POSITIVE 23 
set_parameter_property fp_man DISPLAY_NAME "Mantissa"
set_parameter_property fp_man ALLOWED_RANGES 10:52 
set_parameter_property fp_man UNITS Bits
set_parameter_property fp_man DESCRIPTION "Choose the width of the mantissa in bits"
set_parameter_property fp_man AFFECTS_GENERATION true

add_parameter fp_man_derived POSITIVE 8 
set_parameter_property fp_man_derived DERIVED true
set_parameter_property fp_man_derived VISIBLE false
set_parameter_property fp_man_derived AFFECTS_GENERATION true

add_parameter frequency_target POSITIVE 200 
set_parameter_property frequency_target DISPLAY_NAME "Target"
set_parameter_property frequency_target UNITS Megahertz
set_parameter_property frequency_target DESCRIPTION "Choose the frequency in MHz at which this function is expected to run. This together with the target device family will determine the amount of pipelining."
set_parameter_property frequency_target AFFECTS_GENERATION true

add_parameter latency_target NATURAL 2 
set_parameter_property latency_target DISPLAY_NAME "Target"
set_parameter_property latency_target VISIBLE false
set_parameter_property latency_target UNITS Cycles
set_parameter_property latency_target DESCRIPTION "Choose the required latency"
set_parameter_property latency_target AFFECTS_GENERATION true

add_parameter performance_goal STRING "frequency" 
#set_parameter_property performance_goal DISPLAY_HINT  radio
set_parameter_property performance_goal DISPLAY_NAME "Goal"
set_parameter_property performance_goal UNITS None
set_parameter_property performance_goal ALLOWED_RANGES {"frequency" "latency"} 
set_parameter_property performance_goal DESCRIPTION "Choose the performance target"
set_parameter_property performance_goal AFFECTS_GENERATION true

add_parameter rounding_mode STRING "nearest with tie breaking away from zero" 
set_parameter_property rounding_mode DISPLAY_NAME "Mode"
set_parameter_property rounding_mode VISIBLE false
set_parameter_property rounding_mode UNITS None
set_parameter_property rounding_mode ALLOWED_RANGES {"nearest with tie breaking away from zero" "toward zero"}
set_parameter_property rounding_mode DESCRIPTION "Choose the desired rounding mode"
set_parameter_property rounding_mode AFFECTS_GENERATION true

add_parameter rounding_mode_derived STRING "nearest with tie breaking to even" 
set_parameter_property rounding_mode_derived DISPLAY_NAME "Mode"
set_parameter_property rounding_mode_derived DERIVED true 
set_parameter_property rounding_mode_derived VISIBLE false
set_parameter_property rounding_mode_derived DESCRIPTION "The rounding mode"
set_parameter_property rounding_mode_derived AFFECTS_GENERATION true

add_parameter use_rounding_mode boolean true
set_parameter_property use_rounding_mode DERIVED true
set_parameter_property use_rounding_mode VISIBLE false
set_parameter_property use_rounding_mode AFFECTS_ELABORATION true

add_parameter faithful_rounding boolean false
set_parameter_property faithful_rounding DISPLAY_NAME "Relax rounding to round up or down to reduce resource usage" 
set_parameter_property faithful_rounding UNITS None
set_parameter_property faithful_rounding DESCRIPTION "Choose if the nearest rounding mode should be relaxed to faithful rounding, where the result may be rounded up or down, to reduce resource usage"
set_parameter_property faithful_rounding AFFECTS_GENERATION true

add_parameter gen_enable boolean false
set_parameter_property gen_enable DISPLAY_NAME "Generate an enable port" 
set_parameter_property gen_enable UNITS None
set_parameter_property gen_enable DESCRIPTION "Choose if the function should have an enable signal."
set_parameter_property gen_enable AFFECTS_GENERATION true

add_parameter compare_type STRING "LT" 
set_parameter_property compare_type DISPLAY_NAME "Type"
set_parameter_property compare_type UNITS None
set_parameter_property compare_type VISIBLE false
set_parameter_property compare_type ALLOWED_RANGES {"LT" "LE" "EQ" "GE" "GT" "NEQ" } 
set_parameter_property compare_type DESCRIPTION "Choose the type of the comparator" 
set_parameter_property compare_type AFFECTS_GENERATION true

set fx_to_fl "Fixed to Floating"
set fl_to_fx "Floating to Fixed"
add_parameter convert_type STRING $fx_to_fl 
set_parameter_property convert_type DISPLAY_NAME "Type"
#set_parameter_property convert_type DISPLAY_HINT radio
set_parameter_property convert_type UNITS None
set_parameter_property convert_type VISIBLE false
set_parameter_property convert_type ALLOWED_RANGES [list $fx_to_fl $fl_to_fx] 
set_parameter_property convert_type DESCRIPTION "Choose the type of the conversion" 
set_parameter_property convert_type AFFECTS_GENERATION true

add_parameter fxpt_width POSITIVE 32 
set_parameter_property fxpt_width DISPLAY_NAME "Width"
set_parameter_property fxpt_width ALLOWED_RANGES 16:128 
set_parameter_property fxpt_width UNITS Bits
set_parameter_property fxpt_width DESCRIPTION "Choose the width of the fixed point data"
set_parameter_property fxpt_width AFFECTS_GENERATION true

add_parameter fxpt_fraction INTEGER 0 
set_parameter_property fxpt_fraction DISPLAY_NAME "Fraction"
set_parameter_property fxpt_fraction UNITS Bits
set_parameter_property fxpt_fraction DESCRIPTION "Choose the number of fraction bits"
set_parameter_property fxpt_fraction AFFECTS_GENERATION true


add_parameter fxpt_sign STRING "signed" 
set_parameter_property fxpt_sign DISPLAY_NAME "Sign"
#set_parameter_property fxpt_sign DISPLAY_HINT radio 
set_parameter_property fxpt_sign UNITS None
set_parameter_property fxpt_sign ALLOWED_RANGES {"signed" "unsigned" } 
set_parameter_property fxpt_sign DESCRIPTION "Choose the signedness of the fixed point data" 
set_parameter_property fxpt_sign AFFECTS_GENERATION true


add_parameter latency_button_feedback INTEGER 0 
set_parameter_property latency_button_feedback DERIVED true
set_parameter_property latency_button_feedback VISIBLE false
set_parameter_property latency_button_feedback AFFECTS_ELABORATION true

add_parameter force_elaborate INTEGER 0 
set_parameter_property force_elaborate DERIVED true
set_parameter_property force_elaborate VISIBLE false
set_parameter_property force_elaborate AFFECTS_ELABORATION true

set latency_button_pressed false

# 
# display items
# 
add_display_item "" Basic GROUP
set_display_item_property Basic DISPLAY_HINT TAB
add_display_item "" Advanced GROUP
set_display_item_property Advanced DISPLAY_HINT TAB

add_display_item Basic Function GROUP
add_display_item Basic "Floating Point Data" GROUP
add_display_item Basic "Fixed Point Data" GROUP
set_display_item_property "Fixed Point Data" VISIBLE false
add_display_item Basic Performance GROUP
add_display_item Basic Report GROUP

add_display_item Advanced Rounding GROUP
add_display_item Advanced "Data Widths" GROUP
add_display_item Advanced Ports GROUP

add_display_item Function fp_function PARAMETER
add_display_item Function compare_type PARAMETER
add_display_item Function convert_type PARAMETER

add_display_item "Floating Point Data" fp_format PARAMETER
add_display_item "Floating Point Data" fp_exp PARAMETER
add_display_item "Floating Point Data" fp_man PARAMETER

add_display_item "Fixed Point Data" fxpt_width PARAMETER
add_display_item "Fixed Point Data" fxpt_fraction PARAMETER
add_display_item "Fixed Point Data" fxpt_sign PARAMETER

add_display_item Performance performance_goal PARAMETER
add_display_item Performance frequency_target PARAMETER
add_display_item Performance latency_target PARAMETER


add_display_item Report report_pane TEXT ""
add_display_item Report check_performance_button ACTION latency_button_proc
set_display_item_property check_performance_button DISPLAY_NAME "Check Performance"
set_display_item_property check_performance_button DESCRIPTION "Press button to check if the requested latency is achievable and if so at what frequency"

add_display_item Rounding rounding_mode PARAMETER
add_display_item Rounding rounding_mode_derived PARAMETER
add_display_item Rounding faithful_rounding PARAMETER

add_display_item Ports gen_enable PARAMETER

# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1


# 
# connection point areset
# 
add_interface areset reset end
set_interface_property areset associatedClock clk
set_interface_property areset synchronousEdges DEASSERT
set_interface_property areset ENABLED true
add_interface_port areset areset reset Input 1


# 
# device parameters
# 
add_parameter selected_device_family STRING
set_parameter_property selected_device_family VISIBLE false
set_parameter_property selected_device_family SYSTEM_INFO {DEVICE_FAMILY}

add_parameter selected_device_speedgrade STRING
set_parameter_property selected_device_speedgrade VISIBLE false
set_parameter_property selected_device_speedgrade SYSTEM_INFO {DEVICE_SPEEDGRADE}

#
# status of validation so that cmdPolyEval call can be predicated on this
#
add_parameter validation_failed BOOLEAN false
set_parameter_property validation_failed VISIBLE false
set_parameter_property validation_failed DERIVED true

set rounding_mode_prompt "Select a rounding mode on the Advanced tab"

proc default_validate {} {
	set_parameter_property compare_type VISIBLE false
	set_parameter_property convert_type VISIBLE false
	set_display_item_property "Fixed Point Data" VISIBLE false
	set_parameter_property rounding_mode VISIBLE false 
	set_display_item_property Rounding VISIBLE true
	set_parameter_value use_rounding_mode true
	set_display_item_property faithful_rounding VISIBLE true
	set_parameter_property rounding_mode_derived VISIBLE true 
	set_parameter_value rounding_mode_derived "nearest with tie breaking to even" 
}

proc min_max_validate {} {
	set_parameter_property compare_type VISIBLE false
	set_parameter_property convert_type VISIBLE false
	set_display_item_property "Fixed Point Data" VISIBLE false
	set_display_item_property Rounding VISIBLE false
	set_parameter_value use_rounding_mode false
}

proc compare_validate {} {
	set_parameter_property compare_type VISIBLE true
	set_parameter_property convert_type VISIBLE false
	set_display_item_property "Fixed Point Data" VISIBLE false
	set_display_item_property Rounding VISIBLE false
	set_parameter_value use_rounding_mode false
}

proc convert_validate {} {
	set_parameter_property compare_type VISIBLE false
	set_parameter_property convert_type VISIBLE true
	set_display_item_property "Fixed Point Data" VISIBLE true
	set_parameter_value use_rounding_mode false
	set_display_item_property faithful_rounding VISIBLE false
	set_parameter_property rounding_mode_derived VISIBLE false 
	global fl_to_fx
	global rounding_mode_prompt
	if { [expr {[get_parameter_value convert_type]} eq {$fl_to_fx}] } {
		set_display_item_property Rounding VISIBLE true
		send_message INFO $rounding_mode_prompt
		set_parameter_property rounding_mode VISIBLE true
		set_parameter_value rounding_mode_derived [get_parameter_value rounding_mode]
	} else {
		set_display_item_property Rounding VISIBLE false
	}

	# the fraction bits could be negative and also larger than the fxpt_width	
	# but let's not do it in this release 
	set fx_w [get_parameter_value fxpt_width]
	set_parameter_property fxpt_fraction ALLOWED_RANGES "0:$fx_w"
	set frac [get_parameter_value fxpt_fraction]
	if { $frac > $fx_w || $frac < 0 } {
		set_parameter_value validation_failed true
	}
}

proc add_interface_input { name bit_width } {
	add_interface $name conduit end
	set_interface_property $name associatedClock clk
	set_interface_property $name associatedReset areset
	set_interface_property $name ENABLED true
	add_interface_port $name $name $name Input $bit_width 
}

proc add_interface_output { name bit_width } {
	add_interface $name conduit start
	set_interface_assignment $name "ui.blockdiagram.direction" OUTPUT
	set_interface_property $name associatedClock clk
	set_interface_property $name associatedReset ""
	add_interface_port $name $name $name Output $bit_width
}

#
# Two input one output, same bit width 
# 
proc default_elaborate {} {
	set bit_width [expr {[get_parameter_value fp_exp_derived] + [get_parameter_value fp_man_derived] + 1}]  
	
	add_interface_input a $bit_width
	add_interface_input b $bit_width
	add_interface_output q $bit_width
}

#
# One input one output, same bit width
#
proc one_each_same_width_elaborate {} {
	set bit_width [expr {[get_parameter_value fp_exp_derived] + [get_parameter_value fp_man_derived] + 1}]  
	
	add_interface_input a $bit_width
	add_interface_output q $bit_width
}

#
# Two inputs of bit width, one single bit output
#
proc two_in_single_bit_out_elaborate {} {
	set bit_width [expr {[get_parameter_value fp_exp_derived] + [get_parameter_value fp_man_derived] + 1}]  
	
	add_interface_input a $bit_width
	add_interface_output q 1 
	set_port_property q VHDL_TYPE STD_LOGIC_VECTOR
}

proc convert_elaborate {} {
	set type [get_parameter_value convert_type]
	set fl_bit_width [expr {[get_parameter_value fp_exp_derived] + [get_parameter_value fp_man_derived] + 1}]  
	set fx_bit_width [get_parameter_value fxpt_width]
	global fx_to_fl 
	global fl_to_fx 
	if { [expr {$type eq $fx_to_fl}] } {
		add_interface_input a $fx_bit_width
		add_interface_output q $fl_bit_width
	} elseif { [expr {$type eq $fl_to_fx}] } {
		add_interface_input a $fl_bit_width
		add_interface_output q $fx_bit_width
	}
}

proc latency_button_proc {} {
	#we need to force elaborate because if the frequency is the same the elaborate callback will
	#not be called, and no information message will be printed.
	set_parameter_value force_elaborate [expr [get_parameter_value force_elaborate] ^ 1]
	set_parameter_value latency_button_feedback [find_frequency [get_parameter_value latency_target]] 
	set_latency_button_pressed true
}

proc validate_input {} {
	set_parameter_value validation_failed false

	set man [get_parameter_value fp_man]
	set exp [get_parameter_value fp_exp]
	set width [get_parameter_value fxpt_width]
	if { $man < 1 || $exp < 1 || $width < 1 } {
		set_parameter_value validation_failed true
	}
	
	set fp_fmt [get_parameter_value fp_format]
	switch -exact $fp_fmt {
		single {
			set_parameter_value fp_man_derived 23
			set_parameter_value fp_exp_derived 8
			set_parameter_property fp_man VISIBLE false
			set_parameter_property fp_exp VISIBLE false
		}

		double {
			set_parameter_value fp_man_derived 52
			set_parameter_value fp_exp_derived 11
			set_parameter_property fp_man VISIBLE false
			set_parameter_property fp_exp VISIBLE false
		}

		custom {
			set_parameter_value fp_man_derived [get_parameter_value fp_man]
			set_parameter_value fp_exp_derived [get_parameter_value fp_exp] 
			set_parameter_property fp_man VISIBLE true
			set_parameter_property fp_exp VISIBLE true
		}
	}

	if { [is_goal_frequency] } {
		set_parameter_property frequency_target VISIBLE true
		set_parameter_property latency_target VISIBLE false
	} else {
		set_parameter_property frequency_target VISIBLE false
		set_parameter_property latency_target VISIBLE true
	}

	[get_function_option validate]
}

proc elaboration_callback {} {
	if { [get_parameter_value gen_enable] } {
		add_interface en conduit end
		set_interface_property en associatedClock clk
		set_interface_property en associatedReset ""
		set_interface_property en ENABLED true
		add_interface_port en en en Input 1
		set_port_property en VHDL_TYPE STD_LOGIC_VECTOR
	}

	[get_function_option elaborate]

	if { [is_goal_frequency] } {
		set_display_item_property check_performance_button VISIBLE false
		set_display_item_property report_pane VISIBLE true
		if { bool([get_parameter_value validation_failed]) == bool(false) } {
			set quartus_dir [get_quartus_rootdir] 
			set freq [get_parameter_value frequency_target]
			set output [call_cmdPolyEval "" $quartus_dir "." "report" $freq]
			array set report [extract_report $output]
			report_latency [array get report] false	
		} else {
			set_display_item_property report_pane TEXT "Latency unknown because parameters are invalid"
		}
	} else {
		if { [get_latency_button_pressed] } {
			set_display_item_property report_pane VISIBLE true
			set_display_item_property check_performance_button VISIBLE false
			set latency_button_feedback [get_parameter_value latency_button_feedback]
			if { [expr $latency_button_feedback > 0] } {
				set_display_item_property report_pane TEXT "Estimated frequency on [get_parameter_value selected_device_family] is $latency_button_feedback MHz"
			} elseif { [expr $latency_button_feedback < 0] } {
				set actual_latency [expr 0 - [get_parameter_value latency_button_feedback]]
				set_display_item_property report_pane TEXT "Could not achieve the requested latency. Nearest achievable latency is $actual_latency cycles"
			} else {
				send_message ERROR "There was a problem when checking performance, please tell Altera"
				set_display_item_property check_performance_button VISIBLE true
				set_display_item_property report_pane VISIBLE false
			}
		   set_latency_button_pressed false	
		} else {
			set_display_item_property check_performance_button VISIBLE true
			set_display_item_property report_pane VISIBLE false
		}
	}
}

proc set_latency_button_pressed { val } {
	global latency_button_pressed
	set latency_button_pressed $val
}

proc get_latency_button_pressed {} {
	global latency_button_pressed
	return $latency_button_pressed
}

proc sim_verilog_callback {entity_name} {
    generate $entity_name verilog
}

proc sim_vhdl_callback {entity_name} {
    generate $entity_name vhdl
}

proc quartus_synth_callback {entity_name} {
    generate $entity_name vhdl
}

proc generate {entity_name lang} {
	set tmp_dir [create_temp_file ""]
	file mkdir $tmp_dir
	set quartus_dir [get_quartus_rootdir] 

	if { [is_goal_frequency] } {
		set freq [get_parameter_value frequency_target]
	} else {
		set freq [find_frequency [get_parameter_value latency_target]]
	}

	if { [expr $freq > 0] } {
		set output [call_cmdPolyEval $entity_name $quartus_dir $tmp_dir "$lang" $freq]
		array set report [extract_report $output]
		report_latency [array get report] true	

		set hex_files [glob -nocomplain -tails -directory $tmp_dir *.hex]
		foreach a_file $hex_files {
		    add_fileset_file $a_file HEX PATH  $tmp_dir/$a_file
		}
		if { $lang == "vhdl" } {
		    add_fileset_file dspba_library_package.vhd VHDL PATH  "$quartus_dir/dspba/backend/Libraries/vhdl/base/dspba_library_package.vhd"
		    add_fileset_file dspba_library.vhd VHDL PATH  "$quartus_dir/dspba/backend/Libraries/vhdl/base/dspba_library.vhd"
		    add_fileset_file $entity_name.vhd VHDL PATH  $tmp_dir/$entity_name.vhd
		} else {
		    add_fileset_file dspba_library_ver.sv SYSTEM_VERILOG PATH  "$quartus_dir/dspba/backend/Libraries/sv/base/dspba_library_ver.sv"
		    add_fileset_file $entity_name.sv SYSTEM_VERILOG PATH  $tmp_dir/$entity_name.sv
		}
	}
}


#
# Before calling cmdPolyEval the directory will be changed to tmp_dir, so 
# if you don't want a directory change specify . for tmp_dir
#
# Returns stdout or stderr of cmdPolyEval
#
proc call_cmdPolyEval { entity_name quartus_dir tmp_dir call_type freq } {
	# call cmdPolyEval here
	# All the dash parameters must come before others
	# target is preferred before frequency
	set module_dir [get_module_property MODULE_DIRECTORY]
	set args ""
	append args " -target "
	set device_family [get_parameter_value selected_device_family]
	append args [string map {{ } {}} $device_family]
	append args " -frequency "
	append args $freq
	append args " -name "
	append args $entity_name
	append args " -noChanValid"
	if { [get_parameter_value gen_enable] } {
		append args " -enable"
	}
	append args " -printMachineReadable"

	switch -exact $call_type {
		report {
			append args " -noFileGenerate"
		}
		
		vhdl {
			append args " -lang VHDL"
		}
		
		verilog {
			append args " -lang SYSTEMVERILOG"
		}
	}

	if { [get_parameter_value use_rounding_mode] } {
		if { [is_rounding_to_nearest] } {
			if { [get_parameter_value faithful_rounding] } {
				append args " -faithfulRounding"
			} else {
				append args " -correctRounding"
			}
		}
	}

	append args " "
	append args [[get_function_option cmd]]

	set path_to_exe "$quartus_dir/dspba/backend"
	set bitness [expr {[is_64bit] ? "64" : "32"}]
	set prev_dir [pwd]
	cd $tmp_dir
	if { [regexp -nocase win $::tcl_platform(os) match] } {
		append path_to_exe "/windows"
		append path_to_exe $bitness
		set command_line "$path_to_exe/cmdPolyEval $args" 
	} else {
		append path_to_exe "/linux"
		append path_to_exe $bitness
		set command_line "$module_dir/cmdPolyEval.sh $path_to_exe $args" 
	}
	send_message DEBUG $command_line
	if { [ catch { exec $command_line } output ] } {
		# if there is an error change directory back before erroring as execution stops at error message
		cd $prev_dir
		send_message ERROR $output
	} else {
		cd $prev_dir
	}
	return $output
}

#
# Returns the frequency (in MHz) at which the specified latency is achievable.
# If the latency is not achievable, returns zero or a negative number whose 
# absolute value is the nearest achievable latency.
# The function will give up after a certain number of attempts.
# The function binary searches the 1 to 800 MHz range.
#
proc find_frequency { latency } {
	set quartus_dir [get_quartus_rootdir] 
	set freq 400
	set step [expr $freq/2]
	set output [call_cmdPolyEval "" $quartus_dir "." "report" $freq]
	array set report [extract_report $output]
	set attempts 0

	while { [info exists report(latency)] && [expr $report(latency) ne $latency] } {
		if { [expr $attempts > 10] } {
			break
		}

		if { [expr $report(latency) > $latency] } {
			set freq [expr int($freq - $step)]
		} elseif { [expr $report(latency) < $latency] } {
			set freq [expr int($freq + $step)]
		} else {
			break
		}

		if { [expr $freq < 1] } {
			break
		}
		
		set last_latency $report(latency)
		set output [call_cmdPolyEval "" $quartus_dir "." "report" $freq]
		array set report [extract_report $output]
		set step [expr ceil($step/2)]
		incr attempts
	}
	if { ![info exists report(latency)] } {
		set freq 0
	} elseif { [expr $report(latency) ne $latency] } {
		set curr_diff [expr $report(latency) - $latency]
		set last_diff [expr $last_latency - $latency]
		set curr_diff [expr abs($curr_diff)]
		set last_diff [expr abs($last_diff)]
		set achieved_latency [expr $curr_diff > $last_diff ? $last_latency : $report(latency)] 
		send_message ERROR "Could not achieve the requested latency. Nearest achievable latency is $achieved_latency cycles"
		set freq [expr 0 - $achieved_latency] 
	}
	return $freq
}

proc op_exp_man {} {
	set args ""
	append args [get_function_option name]
	append args " "
	append args [get_parameter_value fp_exp_derived]
	append args " "
	append args [get_parameter_value fp_man_derived]
	return $args
}

proc compare_cmd {} {
	set args ""
	append args FPCompare
	append args " "
	append args [get_parameter_value fp_exp_derived]
	append args " "
	append args [get_parameter_value fp_man_derived]
	append args " "
	switch -exact [get_parameter_value compare_type] {
		LT {
			append args -2 
		}

		LE {
			append args -1
		}

		EQ {
			append args 0 
		}

		GE {
			append args 1
		}

		GT {
			append args 2 
		}

		NEQ {
			append args 3 
		}
	}
	return $args
}

proc convert_cmd {} {
	set type [get_parameter_value convert_type]
	set args ""
	global fx_to_fl 
	global fl_to_fx 
	if { [expr {$type eq $fx_to_fl}] } {
		append args "FXPToFP" 
		append args " "
		append args [get_parameter_value fxpt_width]
		append args " "
		append args [get_parameter_value fxpt_fraction]
		append args " "
		append args [ fxpt_signed_to_int ]
		append args " "
		append args [get_parameter_value fp_exp_derived]
		append args " "
		append args [get_parameter_value fp_man_derived]
	} elseif { [expr {$type eq $fl_to_fx}] } {
		append args "FPToFXPExpert"
		append args " "
		append args [get_parameter_value fp_exp_derived]
		append args " "
		append args [get_parameter_value fp_man_derived]
		append args " "
		append args [get_parameter_value fxpt_width]
		append args " "
		append args [get_parameter_value fxpt_fraction]
		append args " "
		append args [ fxpt_signed_to_int ]
		append args " "
		append args [expr {[is_rounding_to_nearest] ? 1 : 0}]
	}
	append args " "
}

proc fxpt_signed_to_int {} {
	if { [expr {[get_parameter_value fxpt_sign] eq "signed"}] } {
		return 1
	} else {
		return 0
	}
}

proc get_function_option { option } {
	global fp_funcs
	set function_options $fp_funcs([get_parameter_value fp_function])
	switch -exact $option {
		name {
			return [lindex $function_options 0]
		}

		cmd {
			return [lindex $function_options 1]
		}

		validate {
			return [lindex $function_options 2]
		}

		elaborate {
			return [lindex $function_options 3]
		}
	}
	return -1
}

#
# Returns an associative array of field values pairs serialised by array get
#
proc extract_report { output } {
	set startToken @@start
	set endToken @@end
	set s [string first $startToken $output] 
	set e [string first $endToken $output]
	set reportBlock [string range $output [expr $s + [string length $startToken]]  [expr $e -1]]
	set reportBlock [string trim $reportBlock]

	#TODO We should error if there is another @@start or @@end

	set kv_list [split $reportBlock "\n"]
	foreach item $kv_list {
		set item [string trim $item]
		if { [string index $item 0] != "@" || [string index $item end] != "@" } {
			send_message WARNING "Internal Warning: Malformed report from cmdPolyEval, missing @ on line $item"
		}
		
		set kv [split [string map {@ {}} $item]]
		if { [info exists report([lindex $kv 0])] == 1 } {
			send_message WARNING "Internal Warning: Multiple entries for [lindex $kv 0]"
		}
		set report([lindex $kv 0]) [lindex $kv 1]

	}
	return [array get report]
}

#
# This procedure will report latency if you pass to it the return value of extract_report
#
proc report_latency { r send_msg } {
	array set report $r
	if { [info exists report(latency)] } {
		set msg "Latency on [get_parameter_value selected_device_family] is $report(latency) cycle"
		if { $report(latency) > 1 } {
			append msg "s"
		}
		set level INFO
	} else {
		set level WARNING
		set msg "Latency is unknown, please tell Altera"
	}

	if { $send_msg } {
		send_message $level $msg 
	} else {
		set_display_item_property report_pane TEXT $msg
	}
}


# Return 1 if 64 bit, or 0 otherwise
proc is_64bit {} {
	global env
	set is_64bit 0
	if { [info exists env(QUARTUS_BINDIR)] } {
		if { [regexp -nocase bin64 ${env(QUARTUS_BINDIR)} match] 
		  || [regexp -nocase linux64 ${env(QUARTUS_BINDIR)} match]
		} then {
			set is_64bit 1
		} 
		
	}
	return $is_64bit
}

# Return 1 if performance goal is frequency
proc is_goal_frequency {} {
 return [expr {[get_parameter_value performance_goal] eq "frequency"}]
}

proc is_rounding_to_nearest {} {
	return [regexp nearest [get_parameter_value rounding_mode_derived] match]
}

proc get_quartus_rootdir {} {
	global env 
	set quartus_dir ${env(QUARTUS_ROOTDIR)}
	return $quartus_dir
}
