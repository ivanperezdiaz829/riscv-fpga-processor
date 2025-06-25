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


package provide alt_mem_if::util::profiling 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini


if {[::alt_mem_if::util::qini::cfg_is_on "uniphy_generation_profiling"]} {

	rename proc _proc
	
	_proc proc {name arglist body} {
		if {![string match ::* $name]} {
			set name [uplevel 1 namespace current]::[set name]
		}
		set postamble "\nset end_time \[get_ms_time\]\nsend_message info \"::GenerationProfiling Ending from function $name in \[get_module_property NAME\] at \$end_time ($name)\""

		set postamble_return "set end_time \[get_ms_time\];send_message info \"::GenerationProfiling Returning from function $name in \[get_module_property NAME\] at \$end_time ($name)\"; return "

		set postamble_error "set end_time \[get_ms_time\];send_message info \"::GenerationProfiling Erroring from function $name in \[get_module_property NAME\] at \$end_time ($name)\"; _error "
		set body [string map {"\t" " "} $body]
		regsub -all { return } $body $postamble_return body
		regsub -all { _error } $body $postamble_error body
		regsub -all { return$} $body $postamble_return body
		regsub -all { _error$} $body $postamble_error body
		_proc $name $arglist "set start_time \[get_ms_time\]\nsend_message info \"::GenerationProfiling Running $name in \[get_module_property NAME\] at \$start_time\"\n$body\n$postamble"
	}
}
