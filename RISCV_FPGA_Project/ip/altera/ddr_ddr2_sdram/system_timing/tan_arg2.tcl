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
package require ::ddr::messages
package require ::ddr::utils

namespace import ::ddr::utils::*

::ddr::settings::read "${variation_name}_ddr_settings.txt" settings_array
::ddr::legacy::unpack_settings_file  setting_array

set abs_path_to_project [file join $settings_array(project_path) $settings_array(quartus_project_name) ]
set quartus_revision [get_current_revision $abs_path_to_project]
project_open $abs_path_to_project  -revision $quartus_revision

::ddr::legacy::set_family_and_speed_grade
::ddr::legacy::set_family_is_star
::ddr::legacy::set_postcompile_summary_tags


puts "looking for $settings_array(memory_width) dq pins"

if { [catch {
global log_file
set log_file [open [file join $settings_array(wrapper_path) "${variation_name}_extraction_log.txt"] w]
}] } {
puts "ERROR: Can't open ${variation_name}_extraction_log.txt"
return 1
}

set     post_compile_summary_file_path            [ file join  $settings_array(wrapper_path)  "${variation_name}_post_summary.txt"  ]
if { [ catch { open $post_compile_summary_file_path  w }   post_summary_id] } {
error "Cant open file '$post_compile_summary_file_path' for output."
}



array set array_of_dq_pins {} 
set ddr_timings_list_of_array_names [list]

set ddr_dqs_t {struct
dq_capture int
cature_resync int
clkctrl_capture int
dqs_clkctrl int 
clkctrl_posten int
posten_capture int 
postctrl_posten int
sysclk_pin int
name string
number int
}

set dotty_nodes [list]

proc extract_debug { name node } {
global dotty_nodes
lappend dotty_nodes $node
}

proc create_delay_arrays {delays minmax hl} {
global ddr_dqs_t
global log_file
puts $log_file "delays are $delays"
catch {
::ddr::type::check $ddr_dqs_t $delays
} err

foreach {k v} $delays {
if { $k == "number" } { 
set dq_pin_number $v
} elseif { $k == "name" }  {
set dq_pin_name $v
}
}


set arrayvar "${minmax}_paths_for_each_half_dq_$dq_pin_number"
global $arrayvar
array set $arrayvar $delays
set ${arrayvar}(sysclk_pin) $hl ;


global ddr_timings_list_of_array_names
lappend ddr_timings_list_of_array_names $arrayvar 


global array_of_dq_pins
set array_of_dq_pins($dq_pin_number) $dq_pin_name


}




set t [time {
global minmax 
foreach minmax {min max} {
set tco_min ""
set tco_max ""

set pincount 0
catch { delete_timing_netlist }
if { $minmax == "min" } { 
create_timing_netlist -fast_model
} else { 
create_timing_netlist 
}


foreach_in_collection node [get_timing_nodes -type pin] {
set node_name [get_timing_node_info -info name $node]
set res [::ddr::paths::extract_c2_ddr $node $variation_name $settings_array(enable_postamble) extract_debug]
if { $res != "" } {
# puts "Found a DQ pin: [get_timing_node_info -info name $node]"
incr pincount
#puts "found pin $pincount"
sett {ldelay hdelay} $res
create_delay_arrays $ldelay $minmax l
create_delay_arrays $hdelay $minmax h
global dotty_nodes
if { [file isdirectory ddr-dotty] } {
::ddr::dotty::draw "ddr-dotty/ddr-$node_name.dot" $dotty_nodes 
}
set dotty_nodes [list]
}

set res [::ddr::paths::extract_clk_tco cycloneii ddio $settings_array(wrapper_name) "" $node tco_min tco_max]
if { $res } {
# puts "Found a clock output pin: [get_timing_node_info -info name $node] (new tcos are $tco_min/$tco_max)"
}
}
# end foreach_in_collection { pins }


if { $tco_max == "" && $tco_min == "" } { 
puts $post_summary_id "${error_tag} Output clocks to SDRAM Not Found" 
} elseif { $tco_max == "" || $tco_min == "" } {
error "INTERNAL ERROR: One, but not both tco's found"
}

if {$minmax=="max" && $tco_max - $tco_min >=100 } {
puts $post_summary_id "${cwarning_tag} [::ddr::messages::clkout_skew_too_big [expr $tco_max - $tco_min]]"
}


foreach arrayvar $ddr_timings_list_of_array_names {
if {[string match "${minmax}*" $arrayvar]} {
if { $minmax == "min" } {
set ${arrayvar}(sysclk_pin) $tco_min
} elseif { $minmax == "max" }  {
set ${arrayvar}(sysclk_pin) $tco_max
} else { error "minmax!= { max | min } (was $minmax)" }
}
}
puts "found $pincount/[llength $ddr_timings_list_of_array_names] pins"
}
}]

puts "Extraction took $t"

puts "Generating precompile numbers"
::ddr::legacy::gen_precompile $ddr_timings_list_of_array_names 0





set paths_for_all_modes		[list dq_capture sysclk_pin]
set paths_for_dqsmode_only	[list dqs_clkctrl clkctrl_capture clkctrl_resync capture_resync]
set paths_for_postamble_only	[list clkctrl_posten posten_capture postctrl_posten]

set paths_of_interest  $paths_for_all_modes

if { $settings_array(ddr_mode) == "normal" } {
set paths_of_interest [concat $paths_of_interest $paths_for_dqsmode_only]
if { $settings_array(enable_postamble) } {
set paths_of_interest [concat $paths_of_interest $paths_for_postamble_only]
}
} else {

}





set out_id $post_summary_id

set data_file        [ file join file join  $settings_array(wrapper_path) "${variation_name}_extraction_data.txt" ]
if { [ catch { open $data_file  w }   data_id  ] } {
puts  " - ERROR: Cant open file '$data_file' for output."
return -code 99
}


set post_compile_mode 1

cd $settings_array(wrapper_path)
source  [file join $settings_array(current_script_working_dir) ddr_system_timing.tcl]


foreach f [file channels file*] {
close $f
}
return 0
