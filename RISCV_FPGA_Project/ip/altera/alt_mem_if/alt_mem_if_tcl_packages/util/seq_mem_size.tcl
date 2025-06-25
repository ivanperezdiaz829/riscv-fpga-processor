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


package provide alt_mem_if::util::seq_mem_size 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini


namespace eval ::alt_mem_if::util::seq_mem_size:: {
	
	
	variable COMPONENT_ROOT_FOLDER "Memories and Memory Controllers/External Memory Interfaces"
	variable INTERNAL_COMPONENT_ROOT_FOLDER "$COMPONENT_ROOT_FOLDER/Internal Components"

	namespace import ::alt_mem_if::util::messaging::*

	variable calls
	variable recursive_size
	variable stack
	variable deep
	variable call_stack
}




proc ::alt_mem_if::util::seq_mem_size::_get_max_stack_size {func} {
	variable calls
	variable recursive_size
	variable stack
	variable deep
	variable call_stack

	if {[info exists recursive_size($func)]} {
		return $recursive_size($func)
	} else {
		if {![info exists stack($func)]} { 
			return "ERROR_$func"
		}
		set max $stack($func)
		set deepest "${func};"

		array set subArray [array get calls "${func},*"]

		if { [array exists subArray] } {
			set searchToken [array startsearch subArray]
			while {[array anymore subArray $searchToken]} {
				set call [array nextelement subArray $searchToken]
				set substr ""
				set whole ""

				regexp {.*,(.*)} $call whole call

				if {[lsearch $call_stack $call] != -1} {
					_error "Recursion is not supported"
				}
				lappend call_stack $call

				set recurse [_get_max_stack_size "$call"]

				set call_stack [lreplace $call_stack end end]

				if {[expr {$stack($func) + $recurse}] >= $max} {
					set max [expr {$stack($func) + $recurse}]
					set deepest "$func\($stack($func)\) -> $deep($call)"
				}
			}
		}
		set deep($func) $deepest
		set recursive_size($func) $max
		return $max
	}
}



proc ::alt_mem_if::util::seq_mem_size::get_max_memory_usage {seq_file {debug 0}} {
	variable calls
	variable recursive_size
	variable stack
	variable deep
	variable call_stack

	array set calls {}
	array set recursive_size {}
	array set stack {}
	array set deep {}
	set call_stack [list _start]

	if {[file exists $seq_file] == 0} {
		_error "Cannot find $seq_file"
	}

	set qdir $::env(QUARTUS_ROOTDIR)
	set windows_nios2_cmd_shell "$qdir/../nios2eds/Nios II Command Shell.bat"
	set linux_nios2_cmd_shell "$qdir/../nios2eds/nios2_command_shell.sh"

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_build_software_from_tclsh]} {

		set script_file_name "run_objdump.tcl"
		set fh [open $script_file_name w]
		
		if {[file exists $windows_nios2_cmd_shell]} {
			puts $fh "set cmd \[list exec -- \"$windows_nios2_cmd_shell\" nios2-elf-objdump -p -d \"$seq_file\"\]"
		} elseif {[file exists $linux_nios2_cmd_shell]} {
			puts $fh "set cmd \[list exec -- \"$linux_nios2_cmd_shell\" nios2-elf-objdump -p -d \"$seq_file\"\]"
		} else {
			_error "Cannot locate the Nios II Command Shell.  Nios II SBT must be installed to generate UniPHY IP cores."
		}
		
		puts $fh "catch \{ eval \$cmd \} temp"
		puts $fh "puts \$temp"
		close $fh
		
		set file_data [alt_mem_if::util::iptclgen::run_tclsh_script $script_file_name]

	} else {

		if {[file exists $windows_nios2_cmd_shell]} {
			set cmd [list "${windows_nios2_cmd_shell}" "nios2-elf-objdump" "-p" "-d" "${seq_file}"]
		} elseif {[file exists $linux_nios2_cmd_shell]} {
			set cmd [list "${linux_nios2_cmd_shell}" "nios2-elf-objdump" "-p" "-d" "${seq_file}"]
		} else {
			_error "Cannot locate the Nios II Command Shell.  Nios II SBT must be installed to generate UniPHY IP cores."
		}
		set result [alt_mem_if::util::iptclgen::exec_cmd $cmd]
		set file_data $result
	}
	
	set data [split $file_data "\n"]

	set func  "<<<unknown>>>"
	set stack_size 0

	set mem_start_off ""
	set mem_last_off ""
	set mem_last_size ""

	set whole ""
	set temp ""
	set value ""

	foreach line $data {
		if {$debug > 3} {
			puts "$line"
		}
		if {[regexp {LOAD off .*vaddr[ ]+([a-fA-FxX0-9]+)} $line whole temp]} {

			if {$debug > 2} {
				puts "Found offset $temp = [expr {$temp}]"
			}
			if {[string compare $mem_start_off ""] == 0} {
				set mem_start_off [expr {$temp}]
			} else {
				set mem_last_off [expr {$temp}]
			}
		} elseif {[regexp {memsz[ ]+([a-zA-ZxX0-9]+)} $line whole mem_last_size ]} {

			if {$debug > 2} {
		       	 	puts "Found size $mem_last_size = [expr {$mem_last_size}]"
			}
	       		set mem_last_size [expr {$mem_last_size}]
		} elseif {[regexp {^[0-9a-fA-F]+[ ]+<([a-zA-Z0-9_]+)>} $line whole func]} {

			set stack($func) 0
			if {$debug > 2} {
        			puts "Function $func"
			}
		} elseif {[regexp {addi.*sp,sp,-([0-9]+)} $line whole stack_size]} {

			if {$debug > 1} {
				puts "$stack_size\t$func\t"
			}
			set stack($func) $stack_size
		} elseif {[regexp {<([a-zA-Z0-9_]+)>} $line whole value]} {

			set calls(${func},${value}) 1
			if {$debug > 2} {
				puts "$func calls $value"
			}
		}
	}

	set max_stack [_get_max_stack_size "_start"]
	_dprint 1 "start_off=$mem_start_off last_off=$mem_last_off last_size=$mem_last_size"

	if {[string is integer -strict $mem_start_off] == 0 ||
	    [string is integer -strict $mem_last_off] == 0 ||
	    [string is integer -strict $mem_last_size] == 0} {
		_error	"Failure to extract memory sizes from nios2-elf-objdump"
	}
	set mem_size [expr {$mem_last_off - $mem_start_off + $mem_last_size}]

	set total_size [expr {$max_stack + $mem_size}]

	_dprint 1 "stack=$max_stack mem=$mem_size total=$total_size"
	_dprint 1 "$deep(_start)"
	
	return $total_size
}

proc ::alt_mem_if::util::seq_mem_size::_init {} {

	return 1
}


::alt_mem_if::util::seq_mem_size::_init
