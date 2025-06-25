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
package require ::ddr::dqsfbc
package require ::ddr::s2dqs
package require ::ddr::data
package require ::ddr::messages
package require ::ddr::pcinterface

namespace import ::ddr::utils::*


::ddr::settings::read "${variation_name}_ddr_settings.txt" settings_array




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
#puts "extract_debug: found $node $name"
global dotty_nodes
lappend dotty_nodes $node
}

set posclockpin $settings_array(clock_pos_pin_name)
set negclockpin $settings_array(clock_neg_pin_name)



set extparam_a  [list                                               \
period $settings_array(clock_period_in_ps)          \
tDQSCK $settings_array(memory_tDQSCK)               \
tDQSQ $settings_array(memory_tDQSQ)                 \
tQHS $settings_array(memory_tQHS)                   \
board_ck $settings_array(tPD_clock_trace_NOM)       \
board_dqs $settings_array(tPD_dqs_trace_total_NOM)  \
board_fb_rtd $settings_array(tPD_fedback_clock_NOM) \
board_trace_skew $settings_array(board_tSKEW_data_group) \
board_trace_error [expr {$settings_array(pcb_delay_var_percent)*0.01}] \
CAS_L $settings_array(cas_latency)]

array unset extparam
array set extparam $extparam_a


set postamble_phase [::ddr::dqsfbc::phase_from_inter_postamble $settings_array(inter_postamble)]

set setup_a [list capture_phase $settings_array(dqs_phase) \
fedback_resync_phase $settings_array(chosen_fb_resynch_phase)\
resync_cycle $settings_array(chosen_resynch_cycle)\
resync_phase $settings_array(chosen_resynch_phase)\
postamble_cycle $settings_array(chosen_postamble_cycle)\
postamble_phase $postamble_phase]

proc write_margin {post_summary name margins } {
global post_summary_id
assert {$post_summary == $post_summary_id} {$post_summary $post_summary_id}
sett {setup hold } $margins
::ddr::pcinterface::report_msg note "DDR $name"
set sutag  [expr {$setup >0 ? "              " : ""  }]
set sutype  [expr {$setup >0 ? "note" : "cwarning"  }]
::ddr::pcinterface::report_msg $sutype  "$sutag    Setup slack is  $setup ps"
if { $hold != "--" } {
set holdtag [expr {$hold >0 ? "              " : ""  }]
set holdtype [expr {$hold >0 ? "note" : "cwarning"  }]
::ddr::pcinterface::report_msg $holdtype  "$holdtag    Hold slack is  $hold ps"
} else {
::ddr::pcinterface::report_msg note  "                  Hold time is right by design"
}
}

global post_summary_id
set    post_compile_summary_file        "${variation_name}_post_summary.txt"
set post_summary_id [open [file join $settings_array(wrapper_path) $post_compile_summary_file] w]

puts "Analysis will be based in these parameters:"			
puts "------------------------------------------"
foreach {k v} [concat $extparam_a $setup_a] {
puts [format "%-20s %5s" $k $v]
}

set setup_ok 1	



if { $settings_array(chosen_postamble_clk) != "dedicated" } {
::ddr::pcinterface::report_msg error [::ddr::messages::dqsfbc_postamble_not_dedicated]
set setup_ok 0
}
if { ! $settings_array(override_resynch_was_used) || ! $settings_array(override_postamble_was_used) } {
::ddr::pcinterface::report_msg error [::ddr::messages::dqsfbc_not_setup_manually]
set setup_ok 0
}
if { ! $setup_ok } {
exit 0
}

set est_paths [list sysclk_pin_min sysclk_pin_max dq_capture capture_resync1 \
resync1_resync2 clkctrl_capture clkctrl_resync \
dqs_clkctrl clkctrl_posten posten_clkctrl      \
postctrl_posten pin_fedback fedback_resync     \
fedback_postamble sysclk_postctrl]

foreach p $est_paths {
set est_paths_slow($p) ""
set est_paths_fast($p) ""
}


set rs_interface_info ""
set pa_interface_info ""

set t [time {
set margins(capture) ""
set margins(resync1) ""
set margins(resync2) ""
set margins(postambleen) ""
set margins(postamble1) ""
set margins(postamble2) ""

foreach pvt {fast slow} {
set dq_pin_list [list]
set tco_min ""
set tco_max ""
set pincount 0
set clock_pins_found 0
catch { delete_timing_netlist }
if { $pvt == "fast" } { 
create_timing_netlist -fast_model
} else { 
create_timing_netlist 
}

foreach_in_collection node [get_timing_nodes -type pin] {
set node_name [get_timing_node_info -info name $node]
set res [::ddr::dqsfbc::extract_s2_paths $node $variation_name extract_debug $settings_array(enable_postamble) ]
if { $res != "" } {
incr pincount
#puts "found pin $pincount: $res"
sett {ldelay hdelay} $res
lappend dq_pin_list $ldelay
lappend dq_pin_list $hdelay
global dotty_nodes
if { [file isdirectory ddr-dotty] } {
::ddr::dotty::draw "ddr-dotty/ddr-$node_name-$pvt.dot" $dotty_nodes 
}
set dotty_nodes [list]

}

if {[::ddr::paths::extract_clk_tco stratixii $settings_array(clock_generation) $settings_array(wrapper_name)  [list $settings_array(clock_pos_pin_name) $settings_array(clock_neg_pin_name)] $node tco_min tco_max]} {
incr clock_pins_found
}

}
# end foreach_in_collection { pins }

if { $tco_min == "" || $tco_max == "" } { 

error "No clock out pins found: $tco_min $tco_max"
}

puts "found $pincount pins"
puts "found $clock_pins_found clock pins"
::ddr::utils::assert {2*$pincount == [llength $dq_pin_list]} {{$pincount} {[llength $dq_pin_list]} }

if { $settings_array(num_output_clocks) + 1 != $clock_pins_found } {

}
if { [llength $dq_pin_list] != 2 * $settings_array(memory_width) } {


set cwarn_didnt_find_all_dq_pins [list [expr {2*$settings_array(memory_width)}] [llength $dq_pin_list]]
}

foreach dq_pin $dq_pin_list {
set dq_pin [concat $dq_pin [::ddr::data::get_micro_params $fpga_speed_grade $pvt]]
set delay [::ddr::utils::fix_up_tco $dq_pin $tco_min $tco_max]

#puts "\n--------------"
foreach {k v} [concat $delay $setup_a $extparam_a] {
#	puts [format "%-20s %5s" $k $v]
}
#puts "---------------"


set capture [::ddr::s2dqs::analyse_capture $delay $setup_a $extparam_a $pvt $fpga_speed_grade]
fold_margins margins(capture) $capture
#puts "capture: $capture"


sett {resync1 resync2} [::ddr::dqsfbc::analyse_resync $delay $setup_a $extparam_a $pvt $fpga_speed_grade rs_interface_info]
#puts "resync1: $resync1"
#puts "resync2: $resync2"
fold_margins margins(resync1) $resync1
fold_margins margins(resync2) $resync2


if { $settings_array(enable_postamble) } {
set postamble_slack [::ddr::s2dqs::analyse_postamble_enable $delay $setup_a $extparam_a $pvt $fpga_speed_grade]
sett {postamble1 postamble2} [::ddr::dqsfbc::analyse_postamble $delay $setup_a $extparam_a $pvt $fpga_speed_grade pa_interface_info]
#puts "postamble enable:$postamble_slack"
#puts "postamble1 $postamble1"
#puts "postamble2 $postamble2"
fold_margins margins(postambleen) [list $postamble_slack 0]
fold_margins margins(postamble1) $postamble1
fold_margins margins(postamble2) $postamble2
}

foreach {k v} $delay {

#if { $k == "name" || $k == "number" } { continue } 
#set diff [expr {$v - $estimated_paths($k)} ]
#if { $diff < - $extparam(period) * 0.75 } {
#	set diff [expr { $diff + $extparam(period) } ]
#}
#if { $diff > 500  || $diff < -500 } { 
#	puts "WARNING: Actual delay on path $k is $diff ps away from estimated data. est:$estimated_paths($k) got:$v. Likely causes are a change in the PLL setting from $settings_array(chosen_capture_phase) or incorrect constraints."

#}


if { [lsearch -exact $est_paths $k] != -1  } {
if { $pvt == "slow" } {
set est_paths_slow($k) [max $est_paths_slow($k) $v]
} elseif { $pvt == "fast" } {
set est_paths_fast($k) [min $est_paths_fast($k) $v]
} else { assert {0} {$pvt} }
}
}

}
}
}]

puts "Extraction took $t"









::ddr::pcinterface::report_msg note "Post Compile Analysis Finished."
::ddr::pcinterface::report_msg note  " "


if { [llength $dq_pin_list] == 0 } {
::ddr::pcinterface::report_msg error [::ddr::messages::found_no_datapath_pins]

} else {

write_margin $post_summary_id "DDR Read Data Capture: Phase shifted DQS Strobe to DQ Registers" $margins(capture)
write_margin $post_summary_id "DDR Read Data Resynchronisation: Fedback Clock to Phase shifted DQS Strobe" $margins(resync1)
write_margin $post_summary_id "DDR Read Data Resynchronisation: System PLL-derived clock to Fedback Clock" $margins(resync2)

if { $settings_array(enable_postamble) } {
set margins(postambleen) [list [lindex $margins(postambleen) 0] "--"]
write_margin $post_summary_id "DDR Postamble Enable" $margins(postambleen)
write_margin $post_summary_id "DDR Read Data Postamble: Fedback Clock to Postamble Enable Register" $margins(postamble1)
write_margin $post_summary_id "DDR Read Data Postamble: System PLL-derived clock to Fedback Clock" $margins(postamble2)
}
::ddr::pcinterface::report_msg note " "

::ddr::pcinterface::report_msg note " "

#if { [info exists warn_actual_ne_est_delay ] } {
#	::ddr::pcinterface::report_msg warning "One or more delays on a path differ substantially from estimated data. Likely causes are a change in the PLL setting or incorrect constraints."
#	::ddr::pcinterface::report_msg warning "This may cause the above margins to be less than predicted. See the <variation name>_extraction_log2.txt for more details."
#}

if { [info exists cwarn_didnt_find_all_dq_pins] } {
::ddr::pcinterface::report_msg cwarning [::ddr::messages::found_wrong_number_of_pins "Half-DQ" [lindex $cwarn_didnt_find_all_dq_pins 0] [lindex $cwarn_didnt_find_all_dq_pins 1]]
}

if { [info exists cwarn_didnt_find_all_clock_pins] } {
::ddr::pcinterface::report_msg cwarning [::ddr::messages::found_wrong_number_of_pins "Clock Output"  [lindex $cwarn_didnt_find_all_clock_pins 0] [lindex $cwarn_didnt_find_all_clock_pins 1]]
}

::ddr::pcinterface::report_msg note "--"

set est_data [open [file join $settings_array(wrapper_path) "$settings_array(wrapper_name)_estimated_data_dqs_fbc.dat"] w] 

set est_paths_fast(fedback_resync) [expr {round($est_paths_fast(fedback_resync) - $settings_array(chosen_fb_resynch_phase)/360.0*$settings_array(clock_period_in_ps))}]
set est_paths_slow(fedback_resync) [expr {round($est_paths_slow(fedback_resync) - $settings_array(chosen_fb_resynch_phase)/360.0*$settings_array(clock_period_in_ps))}]
set est_paths_fast(fedback_postamble) [expr {round($est_paths_fast(fedback_postamble) - $settings_array(chosen_fb_postamble_phase)/360.0*$settings_array(clock_period_in_ps))}]
set est_paths_slow(fedback_postamble) [expr {round($est_paths_slow(fedback_postamble) - $settings_array(chosen_fb_postamble_phase)/360.0*$settings_array(clock_period_in_ps))}]

#set est_paths_fast(fedback_capture) [expr {round($est_paths_fast(fedback_capture) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]
#set est_paths_slow(fedback_resync) [expr {round($est_paths_slow(fedback_resync) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]
#set est_paths_slow(fedback_capture) [expr {round($est_paths_slow(fedback_capture) - $settings_array(chosen_capture_phase)/360.0*$settings_array(clock_period_in_ps))}]


puts $est_data "# Estimated data [get_global_assignment -name FAMILY]  [get_global_assignment -name DEVICE]"
puts $est_data "# fast corner:"
puts $est_data "# array set delays [list [array get est_paths_fast]]"
puts $est_data "# slow corner: "
puts $est_data "# array set delays [list [array get est_paths_slow]]"
#puts $est_data "# Note that a phase shift of $settings_array(chosen_capture_phase) may have been used in this project"

puts $est_data "proc ::ddr::dqsfbc::back_ann_est_data { pvt } {"
puts $est_data "	if { \$pvt == \"fast\" } {"
puts $est_data "		return [list [array get est_paths_fast]]"
puts $est_data "	} else {"
puts $est_data "		return [list [array get est_paths_slow]]"
puts $est_data "	}"
puts $est_data "}"

close $est_data
}
# puts "profiler:[::profiler::sortFunctions totalRuntime ]"



foreach f [file channels file*] {
close $f
}

puts "RETURNING ZERO"

return 0
