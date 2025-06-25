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


package provide alt_mem_if::util::messaging 0.1

package require alt_mem_if::util::qini

namespace eval ::alt_mem_if::util::messaging:: {
	namespace export _dprint
	namespace export _eprint
	namespace export _wprint
	namespace export _iprint
	namespace export _error
	
	variable debug_level 0
	
	variable debug_fh
	
	variable enable_send_message 0
	
}


proc ::alt_mem_if::util::messaging::create_table {table_name init_num_cols input_col_width table_data_arr} {
	upvar 1 $table_data_arr table_data
	
	set num_rows  [llength [array names table_data]]

	set col_widths [list]
	set table_width 0
	set table_result [list]
	set seperator_line ""
	set temp_line ""

	set init_col_width $input_col_width
	set num_cols $init_num_cols

	if {$num_cols == -1} {
		set data_row $table_data(0)
		
		set num_cols [llength $data_row]
		set width [list]
		for {set i 0} {$i < $num_cols} {incr i} {
			lappend width 20
		}
		set init_col_width $width;
	}
	
	if {[llength $init_col_width] != $num_cols} {
		puts "Fatal Error: initial column widths is not a list of length $num_cols!"
		exit 1
	}

	for {set y 0} {$y < $num_rows} {incr y} {
		set data_row $table_data($y)
		if {[string compare [lindex $data_row 0] "--SEPERATOR--"] == 0} {
			if {[llength $data_row] != $num_cols} {
				puts "Fatal Error: Data row $y does not have $num_cols columns!"
				exit 1
			}
		}
	}

	for {set x 0} {$x < $num_cols} {incr x} {
		set max_length  0
		for {set y 0} {$y < $num_rows} {incr y} {
			set data_row $table_data($y)
			if {[string compare [lindex $data_row 0] "--SEPERATOR--"] != 0} {
				if {[string length [lindex $data_row $x]] > $max_length} {
					set max_length  [string length [lindex $data_row $x]]
				}
			}
		}
		lappend col_widths $max_length
	}

	for {set x 0} {$x < $num_cols} {incr x} {
		if {[lindex $init_col_width $x] > [lindex $col_widths $x]} {
			set col_widths [lreplace $col_widths $x $x [lindex $init_col_width $x]]
		}
	}

	for {set x 0} {$x < $num_cols} {incr x} {
		set table_width [expr {$table_width + [lindex $col_widths $x] +2 +1}]
	}
	incr table_width

	set while_limit [expr {$table_width-4}]
	while {$while_limit < [string length $table_name]} {
		for {set x 0} {$x < $num_cols} {incr x} {
			lreplace $col_widths $x $x [expr {[lindex $col_widths $x] + 1}]
			incr table_width
			set while_limit [expr {$table_width-4}]
			set condition_expr [expr {$table_width-4}]
			if {$condition_expr >= [string length $table_name]} {
				break
			}
		}
	}

	
	set line "+[string repeat - [expr {$table_width-2}]]+"
	lappend table_result $line
	set line [format "| %-*s |" [expr {$table_width-4}] $table_name]
	lappend table_result $line
	set line "+[string repeat - [expr {$table_width-2}]]+"
	lappend table_result $line

	set seperator_line ""
	for {set x 0} {$x < $num_cols} {incr x} {
		set seperator_line "${seperator_line}+[string repeat - [expr {[lindex $col_widths $x]+2}]]"
	}
	set seperator_line "${seperator_line}+"
	lappend table_result $seperator_line

	for {set y 0} {$y < $num_rows} {incr y} {
		set data_row $table_data($y)
		if {[string compare [lindex $data_row 0] "--SEPERATOR--"] == 0} {
			lappend table_result $seperator_line
		} else {
			set temp_line ""
			for {set x 0} {$x < $num_cols} {incr x} {
				set temp_line [format "%s| %-*s " $temp_line [lindex $col_widths $x] [lindex $data_row $x]]
			}
			lappend table_result "${temp_line}|"
		}
	}

	set seperator_line "${seperator_line}"
	lappend table_result $seperator_line

	return $table_result
}


proc ::alt_mem_if::util::messaging::coprint_table {fh table_name init_num_cols input_col_width table_data_arr} {
	upvar 1 $table_data_arr table_data

	set table_result [create_table $table_name $init_num_cols $input_col_width table_data]

	foreach line $table_result {
		puts $fh $line
		puts $line
	}
	puts $fh ""
	puts ""
}


proc ::alt_mem_if::util::messaging::_dprint {msg_debug_level debug_message} {
	variable debug_level
	variable debug_fh
	
	if {$debug_level >= $msg_debug_level} {
		set caller_level [info level]

		if {$caller_level == 1} {
			set caller "::"
		} else {
			set caller_query_level -1
			if {[
				catch {
					for {set i 1} {$i < $caller_level} {incr i} {
						set caller_name [eval {lindex [info level $i] 0}]
					}
				}
			] != 0} {
				set caller_query_level [expr {$i - 1}]
			}
			if {$caller_query_level == 0} {
				_error "Internal Error: Found caller level as $caller_query_level!"
			}
			
			set caller [lindex [info level $caller_query_level] 0]
			set caller_namespace [uplevel 1 "namespace current"]
			if {[regexp "^\s*${caller_namespace}" $caller match] == 0} {
				set caller "${caller_namespace}::$caller"
			}
		}
		set debug_msg "DEBUG ${caller}(): $debug_message"
		puts $debug_msg
		if {[::alt_mem_if::util::qini::cfg_is_on "enable_debug_log"]} {
			puts $debug_fh $debug_msg
			flush $debug_fh
		}

	}
	return
}

proc ::alt_mem_if::util::messaging::_eprint {error_message {force_msg 0}} {
	variable debug_level
	variable debug_fh
	variable enable_send_message

	set formatted_error_message $error_message
	regsub {^[ ]*} $formatted_error_message "" formatted_error_message
	regsub {[ ]*$} $formatted_error_message "" formatted_error_message
	
	if {$enable_send_message} {
		if {$debug_level == 0 &&
			$force_msg == 0 &&
		    [lsearch [split [get_parameters]] DISABLE_CHILD_MESSAGING] != -1 &&
		    [string compare -nocase [get_parameter_value DISABLE_CHILD_MESSAGING] "true"] == 0} {
		} else {
			send_message error $formatted_error_message
		}
	} else {
		puts "ERROR: $formatted_error_message"
	}
	if {[::alt_mem_if::util::qini::cfg_is_on "enable_debug_log"]} {
		puts $debug_fh "Error: $formatted_error_message"
		flush $debug_fh
	}
	return 1
}

proc ::alt_mem_if::util::messaging::_wprint {error_message} {
	variable debug_level
	variable debug_fh
	variable enable_send_message

	set formatted_error_message $error_message
	regsub {^[ ]*} $formatted_error_message "" formatted_error_message
	regsub {[ ]*$} $formatted_error_message "" formatted_error_message
	
	if {$enable_send_message} {
		if {$debug_level == 0 &&
		    [lsearch [split [get_parameters]] DISABLE_CHILD_MESSAGING] != -1 &&
	    	[string compare -nocase [get_parameter_value DISABLE_CHILD_MESSAGING] "true"] == 0} {
		} else {
			send_message warning $formatted_error_message
		}
	} else {
		puts "WARNING: $formatted_error_message"
	}
	if {[::alt_mem_if::util::qini::cfg_is_on "enable_debug_log"]} {
		puts $debug_fh "Warning: $formatted_error_message"
		flush $debug_fh
	}
	return 1
}

proc ::alt_mem_if::util::messaging::_error {error_message} {
	set formatted_error_message $error_message
	regsub {^[ ]*} $formatted_error_message "" formatted_error_message
	regsub {[ ]*$} $formatted_error_message "" formatted_error_message

	puts "ERROR: $formatted_error_message"
	send_message error $formatted_error_message
	error "An error occurred"
}



proc ::alt_mem_if::util::messaging::_iprint {info_message {force_msg 0}} {
	variable debug_level
	variable debug_fh
	variable enable_send_message

	set formatted_info_message $info_message
	regsub {^[ ]*} $formatted_info_message "" formatted_info_message
	regsub {[ ]*$} $formatted_info_message "" formatted_info_message
	
	if {$enable_send_message} {
		if {$debug_level == 0 && $force_msg == 0 &&
		    [lsearch [split [get_parameters]] DISABLE_CHILD_MESSAGING] != -1 &&
		    [string compare -nocase [get_parameter_value DISABLE_CHILD_MESSAGING] "true"] == 0} {
		} else {
			send_message info $formatted_info_message
		}
	} else {
		puts "INFO: $formatted_info_message"
	}
	if {[::alt_mem_if::util::qini::cfg_is_on "enable_debug_log"]} {
		puts $debug_fh "INFO: $formatted_info_message"
		flush $debug_fh
	}
	return 1
}

proc ::alt_mem_if::util::messaging::_init {} {
	variable debug_level
	variable debug_fh
	variable enable_send_message

	if {[llength [info commands send_message]] == 1} {
		set enable_send_message 1
	} else {
		set enable_send_message 0
	}

	if {[::alt_mem_if::util::qini::cfg_is_on "enable_debug_log"]} {
		set debug_fh [::open "alt_mem_if_debug_log.txt" w+]
	}

	set debug_level [::alt_mem_if::util::qini::qini_value "debug_msg_level" 0]
	
	if {$debug_level == 0} {
		set debug_level [::alt_mem_if::util::qini::cfg_is_on "debug_msg"]
	}
	
	_dprint 1 "Setting debug level to $debug_level"

	return 1


}


::alt_mem_if::util::messaging::_init


