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
# module altera_fp_acc_custom
# 
set_module_property NAME altera_fp_acc_custom
set_module_property VERSION  13.1
set_module_property INTERNAL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Application-Specific Floating Point Accumulator" 
set_module_property DESCRIPTION "A floating point accumulator that can be customized to the required range of input and output values. The accumulator will be built to operate at the target frequency on the target device family." 
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
add_fileset ALTFP_ACC_QUARTUS_SYNTH QUARTUS_SYNTH quartus_synth_callback
add_fileset ALTFP_ACC_SIM_VERILOG SIM_VERILOG sim_verilog_callback
add_fileset ALTFP_ACC_SIM_VHDL SIM_VHDL sim_vhdl_callback
#add_fileset_property ALTFP_ACC_QUARTUS_SYNTH TOP_LEVEL altera_fp_acc_custom

# 
# parameters
# 
add_parameter fp_format STRING "single" 
set_parameter_property fp_format DEFAULT_VALUE "single"
set_parameter_property fp_format DISPLAY_NAME "Floating point format"
set_parameter_property fp_format TYPE STRING
set_parameter_property fp_format DISPLAY_HINT "radio"
set_parameter_property fp_format UNITS None
set_parameter_property fp_format ALLOWED_RANGES {"single" "double"} 
set_parameter_property fp_format DESCRIPTION "Choose the floating point format of the input data values. The output data values of the accumulator will be in the same format."
set_parameter_property fp_format AFFECTS_GENERATION true

add_parameter frequency POSITIVE 200 
set_parameter_property frequency DEFAULT_VALUE 200
set_parameter_property frequency DISPLAY_NAME "Target frequency"
set_parameter_property frequency TYPE POSITIVE
set_parameter_property frequency UNITS Megahertz
set_parameter_property frequency DESCRIPTION "Choose the frequency in MHz at which this core is expected to run. This together with the target device family will determine the amount of pipelining in the core."
set_parameter_property frequency AFFECTS_GENERATION true


add_parameter gen_enable boolean 0
set_parameter_property gen_enable DEFAULT_VALUE 0
set_parameter_property gen_enable DISPLAY_NAME "Generate an enable port" 
set_parameter_property gen_enable TYPE boolean
set_parameter_property gen_enable UNITS None
set_parameter_property gen_enable DESCRIPTION "Choose if the accumulator should have an enable signal."
set_parameter_property gen_enable AFFECTS_GENERATION true


add_parameter MSBA INTEGER 20 ""
set_parameter_property MSBA DEFAULT_VALUE 20
set_parameter_property MSBA DISPLAY_NAME "MSBA"
set_parameter_property MSBA TYPE INTEGER
set_parameter_property MSBA UNITS None
set_parameter_property MSBA ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MSBA DESCRIPTION "An upper bound on the order of magnitude of the accumulated result."
set_parameter_property MSBA AFFECTS_GENERATION true

add_parameter maxMSBX INTEGER 12 ""
set_parameter_property maxMSBX DEFAULT_VALUE 12
set_parameter_property maxMSBX DISPLAY_NAME "maxMSBX"
set_parameter_property maxMSBX TYPE INTEGER
set_parameter_property maxMSBX UNITS None
set_parameter_property maxMSBX ALLOWED_RANGES -2147483648:2147483647
set_parameter_property maxMSBX DESCRIPTION "An upper bound on the order of magnitude of the terms accumulated."
set_parameter_property maxMSBX AFFECTS_GENERATION true

add_parameter LSBA INTEGER -26 ""
set_parameter_property LSBA DEFAULT_VALUE -26
set_parameter_property LSBA DISPLAY_NAME "LSBA"
set_parameter_property LSBA WIDTH ""
set_parameter_property LSBA TYPE INTEGER
set_parameter_property LSBA UNITS None
set_parameter_property LSBA ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LSBA DESCRIPTION "A paramter which controls the accuracy of the accumulation. Any input X=2^e*1.F with e less than lsbA will be shifted out of the accumulator."
set_parameter_property LSBA AFFECTS_GENERATION true


# 
# display items
# 
add_display_item "" "Input Data" GROUP
add_display_item "Input Data" fp_format PARAMETER
add_display_item "Input Data" maxMSBX PARAMETER

add_display_item "" "Accumulator Size" GROUP
add_display_item "Accumulator Size" MSBA PARAMETER
add_display_item "Accumulator Size" LSBA PARAMETER

add_display_item "" "Required Peformance" GROUP
add_display_item "Required Performance" frequency PARAMETER

add_display_item "" "Optional" GROUP
add_display_item "Optional" gen_enable PARAMETER

add_display_item "" "Report" GROUP
add_display_item "Report" report_pane TEXT ""

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
# connection point x
# 
add_interface x conduit end
set_interface_property x associatedClock clk
set_interface_property x associatedReset areset
set_interface_property x ENABLED true
add_interface_port x x x Input 32

# 
# connection point n
# 
add_interface n conduit end
set_interface_property n associatedClock clk
set_interface_property n associatedReset areset
set_interface_property n ENABLED true
add_interface_port n n n Input 1

# 
# connection point r
# 
add_interface r conduit start
set_interface_assignment r "ui.blockdiagram.direction" OUTPUT
set_interface_property r associatedClock clk
set_interface_property r associatedReset ""
add_interface_port r r r Output 32
# 
# connection point xo
# 
add_interface xo conduit start
set_interface_assignment xo "ui.blockdiagram.direction" OUTPUT
set_interface_property xo associatedClock clk
set_interface_property xo associatedReset ""
add_interface_port xo xo xo Output 1

# 
# connection point xu
# 
add_interface xu conduit start
set_interface_assignment xu "ui.blockdiagram.direction" OUTPUT
set_interface_property xu associatedClock clk
set_interface_property xu associatedReset ""
add_interface_port xu xu xu Output 1

# 
# connection point ao
# 
add_interface ao conduit start
set_interface_assignment ao "ui.blockdiagram.direction" OUTPUT
set_interface_property ao associatedClock clk
set_interface_property ao associatedReset ""
add_interface_port ao ao ao Output 1

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



proc validate_input {} {
	set lsbA [get_parameter_value LSBA]
	set msbA [get_parameter_value MSBA]
	set maxMSBX [get_parameter_value maxMSBX]

	set_parameter_value validation_failed false

	if { $maxMSBX > $msbA } {
		# we must do this before error reporting because execution does not continue past the error send msg
		set_parameter_value validation_failed true
		send_message ERROR "msbA should be greater than or equal to maxMSBX"
	}


	if { $maxMSBX <= $lsbA } {
		# we must do this before error reporting because execution does not continue past the error send msg
		set_parameter_value validation_failed true
		send_message ERROR "maxMSBX should be greater than lsbA"
	}

	# An accumulator width of more than 508, will cause an assertion in DSPBA. The limit on maxMSBX is more complex.
	# So set this to 400 which should be more than adequate according to Bodgan.
	if { [expr $msbA - $lsbA] > 400 } {
		# we must do this before error reporting because execution does not continue past the error send msg
		set_parameter_value validation_failed true
		send_message ERROR "Accumulator is too large, limit MSBA - LSBA to 400 or less"
	}

	# If the user specifies a range less than 1+wF, the hardware will drop LSBs without any warning to the user.
	# The underflow flag is only activated if the exponent is out of range.
	# So we must stop that.
	set input_range [expr $maxMSBX - $lsbA]
	set wf [expr { [isSingle] ? 23 : 52 }]
	set format_str [expr { [isSingle] ? "single" : "double" }]
	if { $input_range <= $wf } {
		# we must do this before error reporting because execution does not continue past the error send msg
		set_parameter_value validation_failed true
		send_message ERROR "maxMSBX - LSBA must be greater than $wf for $format_str precision input"
	}

}

proc elaboration_callback {} {
	if { [isSingle] } {
		set bit_width 32
	} else { 
		set bit_width 64
	}
	set_port_property x WIDTH_EXPR $bit_width
	set_port_property r WIDTH_EXPR $bit_width

	if { [get_parameter_value gen_enable] } {
		add_interface en conduit end
		set_interface_property en associatedClock clk
		set_interface_property en associatedReset ""
		set_interface_property en ENABLED true
		add_interface_port en en en Input 1
		set_port_property en VHDL_TYPE STD_LOGIC_VECTOR
	}
	
	if { bool([get_parameter_value validation_failed]) == bool(false) } {
		global env 
		set quartus_dir ${env(QUARTUS_ROOTDIR)}
		set output [call_cmdPolyEval "" $quartus_dir "." "report"]
		array set report [extract_report $output]
		report_latency [array get report] false	
	} else {
		set_display_item_property report_pane TEXT "Latency unknown because parameters are invalid"
	}
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
	global env 
	set quartus_dir ${env(QUARTUS_ROOTDIR)}
	
	set output [call_cmdPolyEval $entity_name $quartus_dir $tmp_dir "$lang"]
	array set report [extract_report $output]
	report_latency [array get report] true	

    if { $lang == "vhdl" } {
        add_fileset_file dspba_library_package.vhd VHDL PATH  "$quartus_dir/dspba/backend/Libraries/vhdl/base/dspba_library_package.vhd"
        add_fileset_file dspba_library.vhd VHDL PATH  "$quartus_dir/dspba/backend/Libraries/vhdl/base/dspba_library.vhd"
        add_fileset_file $entity_name.vhd VHDL PATH  $tmp_dir/$entity_name.vhd
    } else {
        add_fileset_file dspba_library_ver.sv SYSTEM_VERILOG PATH  "$quartus_dir/dspba/backend/Libraries/sv/base/dspba_library_ver.sv"
        add_fileset_file $entity_name.sv SYSTEM_VERILOG PATH  $tmp_dir/$entity_name.sv
    }
}

# Returns true or talse
proc isSingle {} {
	if { [get_parameter_value fp_format] == "single" } {
		return true
	} else {
		return false
	}
}

#
# Before calling cmdPolyEval the directory will be changed to tmp_dir, so 
# if you don't want a directory change specify . for tmp_dir
#
# Returns stdout or stderr of cmdPolyEval
#
proc call_cmdPolyEval { entity_name quartus_dir tmp_dir call_type } {
	# call cmdPolyEval here
	# All the dash parameters must come before others
	# target is preferred before frequency
	set module_dir [get_module_property MODULE_DIRECTORY]
	set args ""
	append args " -target "
	set device_family [get_parameter_value selected_device_family]
	append args [string map {{ } {}} $device_family]
	append args " -frequency "
	append args [get_parameter_value frequency]
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

	append args " FPAcc"
	if { [isSingle] } {
		append args " 8 23"
	} else { 
		append args " 11 52"
	}
	append args " "
	append args [get_parameter_value LSBA]
	append args " "
	append args [get_parameter_value MSBA]
	append args " "
	append args [get_parameter_value maxMSBX]

	set path_to_exe "$quartus_dir/dspba/backend"

    # Only the native tcl interpreter has 'tcl_platform(wordSize)'
    # In Jacl however 'tcl_platform(machine)' is set to the JVM bitness, not the OS bitness
    if { [catch {set WORDSIZE $::tcl_platform(wordSize)} errmsg] } {
        if {[string match "*64" $::tcl_platform(machine)]} {
            set WORDSIZE 8
        } else {
            set WORDSIZE 4
        }
    }
    if { $WORDSIZE == 8 } {
        set bitness "64"
    } else {
        set bitness "32"
    }        

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
		set msg "Latency is unknown"
	}

	if { $send_msg } {
		send_message $level $msg 
	} else {
		set_display_item_property report_pane TEXT $msg
	}
}
