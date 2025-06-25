##Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
##use of Altera Corporation's design tools, logic functions and other
##software and tools, and its AMPP partner logic functions, and any
##output files any of the foregoing (including device programming or
##simulation files), and any associated documentation or information are
##expressly subject to the terms and conditions of the Altera Program
##License Subscription Agreement or other applicable license agreement,
##including, without limitation, that your use is for the sole purpose
##of programming logic devices manufactured by Altera and sold by Altera
##or its authorized distributors. Please refer to the applicable
##agreement for further details. 




set variation_name      [lindex $quartus(args) 0]

if {[catch {source ddr_lib_path.tcl} err] } { error "Couldn't find ddr_lib_path.tcl in the current directory ([pwd]). Stop. (Err was $err)" }

package require ::ddr::extract
package require ::ddr::flowtools
package require ::ddr::settings
package require ::ddr::dotty
package require ::ddr::legacy
package require ::ddr::paths
package require ::ddr::utils
package require ::ddr::nondqsfbc
package require ::ddr::data
package require ::ddr::messages

namespace import ::ddr::utils::*

proc min { a b } {
if { $a == "" } { 
return $b
} elseif { $a < $b } {
return $a
} else {
return $b
}
}

proc max { a b } {
if { $a == "" } { 
return $b
} elseif { $a > $b } {
return $a
} else {
return $b
}
}

::ddr::settings::read "${variation_name}_ddr_settings.txt" settings_array
::ddr::legacy::unpack_settings_file  setting_array


set abs_path_to_project [file join $settings_array(project_path) $settings_array(quartus_project_name) ]

set quartus_revision [get_current_revision $abs_path_to_project]
project_open $abs_path_to_project  -revision $quartus_revision

::ddr::legacy::set_family_and_speed_grade
::ddr::legacy::set_family_is_star


puts "looking for $settings_array(memory_width) dq pins"

if { [catch {
global log_file
set log_file [open [file join $settings_array(wrapper_path) "${variation_name}_extraction_log.txt"] w]
}] } {
puts "ERROR: Can't open ${variation_name}_extraction_log.txt"
return 1
}

set dotty_nodes [list]

proc extract_debug { name node } {
puts "extract_debug: found $node $name"
global dotty_nodes
lappend dotty_nodes $node
}

set posclockpin $settings_array(clock_pos_pin_name)
set negclockpin $settings_array(clock_neg_pin_name)




set extparam_a  [list  trace_delay_dq $settings_array(tPD_dqs_trace_total_NOM) \
trace_delay_ck $settings_array(tPD_clock_trace_NOM) \
trace_delay_fedback $settings_array(tPD_fedback_clock_NOM) \
trace_skew $settings_array(board_tSKEW_data_group) \
tAC_setup $settings_array(memory_tAC) \
tAC_hold "-$settings_array(memory_tAC)" \
period $settings_array(clock_period_in_ps) \
CAS_L $settings_array(cas_latency) \
tHP 0.45 \
tco_vs_tco_skew 50 ]

array unset extparam
array set extparam $extparam_a
set setup_a [list fedback_capture_phase $settings_array(chosen_capture_phase) \
resync_phase $settings_array(chosen_resynch_phase) \
resync_cycle $settings_array(chosen_resynch_cycle) ]

puts "Analysis will be based in these parameters:"			
puts "------------------------------------------"
foreach {k v} [concat $extparam_a $setup_a] {
puts [format "%-20s %5s" $k $v]
}

set est_paths [list tco_ck tco_fedback dq_capture pin_fedback fedback_capture fedback_resync capture_resync]
foreach p $est_paths {
set est_paths_slow($p) ""
set est_paths_fast($p) ""
}

set t [time {
set margins(capture) ""
set margins(resync) ""
foreach pvt {fast slow} {
array unset estimated_paths
array set estimated_paths [::ddr::nondqsfbc::estimatedData $pvt [string tolower $settings_array(speed_grade)] $settings_array(clock_period_in_ps) $settings_array(chosen_capture_phase) ]
set dq_pin_list [list]
set tco_min ""
set tco_max ""
set pincount 0
catch { delete_timing_netlist }
if { $pvt == "fast" } { 
create_timing_netlist -fast_model
} else { 
create_timing_netlist 
}

foreach_in_collection node [get_timing_nodes -type pin] {
set node_name [get_timing_node_info -info name $node]
set res [::ddr::nondqsfbc::extract_s2_paths $node $variation_name extract_debug]
if { $res != "" } {
incr pincount
puts "found pin $pincount: $res"
sett {ldelay hdelay} $res
lappend dq_pin_list $ldelay
lappend dq_pin_list $hdelay
global dotty_nodes
if { [file isdirectory ddr-dotty] } {
::ddr::dotty::draw "ddr-dotty/ddr-$node_name-$pvt.dot" $dotty_nodes 
}
set dotty_nodes [list]

}
::ddr::paths::extract_clk_tco stratixii $settings_array(clock_generation) $settings_array(wrapper_name) [list $settings_array(clock_pos_pin_name) $settings_array(clock_neg_pin_name)] $node tco_min tco_max


}
# end foreach_in_collection { pins }

if { $tco_min == "" || $tco_max == "" } { 

error "No clock out pins found: $tco_min $tco_max"
}

if { $pvt == "fast" } {
set tco $tco_min
} elseif { $pvt == "slow" } {
set tco $tco_min
} else {
assert 0 {$pvt} "Unrecognised pvt"	
}

puts "found $pincount pins"
::ddr::utils::assert {2*$pincount == [llength $dq_pin_list]} {{$pincount} {[llength $dq_pin_list]} }
if { [llength $dq_pin_list] != 2 * $settings_array(memory_width) } {

post_message -type critical_warning "Post compile timing analysis failed to find [expr {2*$settings_array(memory_width) - [llength $dq_pin_list]}] half-DQ pins."
foreach line [::ddr::messages::get_tan_failed_message] {
post_message -type info $line
}
}
foreach dq_pin $dq_pin_list {
set dq_pin [concat $dq_pin [::ddr::data::get_micro_params [string tolower $settings_array(speed_grade)] $pvt]]
set delay [::ddr::nondqsfbc::fixuptco $dq_pin $tco $tco $tco $tco]
sett {capture resync} [::ddr::nondqsfbc::analyse $delay $setup_a $extparam_a $pvt]
puts "Capture/Resync Margins: $capture   $resync"
foreach {k v} $delay {

if { $k == "name" || $k == "number" } { continue } 
set diff [expr {$v - $estimated_paths($k)} ]
if { $diff < - $extparam(period) * 0.75 } {
set diff [expr { $diff + $extparam(period) } ]
}
if { $diff > 500  || $diff < -500 } { 
puts "WARNING: Actual delay on path $k is $diff ps away from estimated data. est:$estimated_paths($k) got:$v. Likely causes are a change in the PLL setting from $settings_array(chosen_capture_phase) or incorrect constraints."
set warn_actual_ne_est_delay 1
}


if { [lsearch -exact $est_paths $k] != -1  } {
if { $pvt == "slow" } {
set est_paths_slow($k) [max $est_paths_slow($k) $v]
} elseif { $pvt == "fast" } {
set est_paths_fast($k) [min $est_paths_fast($k) $v]
} else { assert {0} {$pvt} }
}
}
fold_margins margins(capture) $capture
fold_margins margins(resync) $resync
}
}
}]

puts "Extraction took $t"


set post_compile_summary_file [file join $settings_array(wrapper_path) "${variation_name}_post_summary.txt"]

proc write_margin { name margins } {
global post_summary
sett {setup hold } $margins
puts $post_summary "DDR $name"
set sutag  [expr {$setup >0 ? "              " : "CRITWARNING:"  }]
set holdtag [expr {$hold >0 ? "              " : "CRITWARNING:"  }]
puts $post_summary   "$sutag    Setup slack is  $setup ps"
puts $post_summary "$holdtag    Hold slack is  $hold ps"
}

set post_summary [open $post_compile_summary_file w]

puts $post_summary "Post Compile Analysis Finished."
puts $post_summary " "
write_margin "DDR Read Data Capture: Phase shifted fed-back clock to DQ Registers" $margins(capture)
puts $post_summary " "
write_margin "DDR Read Data Resync: Capture clock to Resync clock" $margins(resync)
puts $post_summary " "
if { [info exists warn_actual_ne_est_delay ] } {
puts $post_summary "WARNING: One or more delays on a path differ substantially from estimated data. Likely causes are a change in the PLL setting or incorrect constraints."
puts $post_summary "WARNING: This may cause the above margins to be less than predicted. See the <variation name>_extraction_log2.txt for more details."
}

puts $post_summary "--"

set est_data_file [file join $settings_array(wrapper_path) "$settings_array(wrapper_name)_estimated_data_nondqs_fbc.dat"]
set est_data [open $est_data_file w] 

set est_paths_fast(fedback_resync) [expr {round($est_paths_fast(fedback_resync) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]
set est_paths_fast(fedback_capture) [expr {round($est_paths_fast(fedback_capture) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]
set est_paths_slow(fedback_resync) [expr {round($est_paths_slow(fedback_resync) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]
set est_paths_slow(fedback_capture) [expr {round($est_paths_slow(fedback_capture) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]


puts $est_data "# Estimated data [get_global_assignment -name FAMILY]  [get_global_assignment -name DEVICE]"
puts $est_data "# fast corner:"
puts $est_data "# array set delays [list [array get est_paths_fast]]"
puts $est_data "# slow corner: "
puts $est_data "# array set delays [list [array get est_paths_slow]]"
puts $est_data "# Note that a phase shift of $settings_array(chosen_capture_phase) may have been used in this project"

puts $est_data "proc ::ddr::nondqsfbc::back_ann_est_data { pvt } {"
puts $est_data "	if { \$pvt == \"fast\" } {"
puts $est_data "		return [list [array get est_paths_fast]]"
puts $est_data "	} else {"
puts $est_data "		return [list [array get est_paths_slow]]"
puts $est_data "	}"
puts $est_data "}"

close $est_data
# puts "profiler:[::profiler::sortFunctions totalRuntime ]"

close $post_summary


foreach f [file channels file*] {
close $f
}

return 0
