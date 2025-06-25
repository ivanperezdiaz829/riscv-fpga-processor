
set  release_state  "release"  
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














package require ::ddr::settings
package require ::ddr::utils
package require ::ddr::legacy
package require ::ddr::messages
package require ::ddr::paths


::ddr::legacy::set_postcompile_summary_tags

set name_of_ddr_megacore    "DDR/DDR2-SDRAM Megacore"
set  verify_file_prefix       "verify_timing_for_"
set length_of_prefix        [expr [string length $verify_file_prefix] - 1  ]


set debug_on                        false
set post_log_messages               false

set default_message_type            "info"
set default_message_type_tan_arg    "info"          ;# "extra_info"

set time_stamp                          [clock format [clock seconds]]

set     something_bad_happened      "false"

if { $debug_on } { post_message -type warning "Debug messages enabled." }




set ver     "13.1"


if { [info exists wrapper_name] } {
if { $wrapper_name != $variation_name} {
post_message -type "warning"   "wrapper_name= '${wrapper_name}', variation_name= '${variation_name}' "
}
}

set    intermediate_file                "${variation_name}_extraction_log.txt"
set    post_compile_summary_file        "${variation_name}_post_summary.txt"


if { $debug_on } { post_message -type $default_message_type "Loading Package (misc).." }
package require ::quartus::misc




puts " $name_of_ddr_megacore $ver  In-System Timing Verification"
puts " Megacore variation is '${variation_name}'"
puts " This may take some time...\n"

#puts ""

flush stdout
flush stderr

after 100

post_message -type $default_message_type       " "
post_message -type $default_message_type       "======================================================="
post_message -type $default_message_type       "==  $name_of_ddr_megacore $ver  In-System Timing Verification    "
post_message -type $default_message_type       "======================================================="
post_message -type $default_message_type       " "
post_message -type $default_message_type       " Verifying in-system timing for $name_of_ddr_megacore variation '${variation_name}'"
post_message -type $default_message_type       " "










## changed to use ::ddr::settings::read by phil
::ddr::settings::read "${variation_name}_ddr_settings.txt" settings_array
set family [get_global_assignment -name FAMILY]
set family [string tolower $family]
set family [regsub -all " " $family ""]

set device_supported        true
switch -glob -- $family  {
"stratix" { }  
"stratixgx" { }   
"cyclone" { }
"cycloneii" { 	}
"stratixii" {
}
"stratixiigx" {   
}                        
"hardcopyii" {
post_message -type warning "Post-compile verification not supported for family HardCopy II."
set device_supported        false
}
default {
set device_supported        false
post_message -type error "Unrecognised family '$family'."
}
}




package require ::quartus::device
package require ::quartus::project
if { [is_project_open] } {
set device [get_global_assignment -name DEVICE]
set device_info [report_part_info $device]

if { [string match *NO_PIN_OUT* $device_info] } {
post_message -type critical_warning "Device $device has no pinout information. Postcompile timing analysis is not supported for devices without pinouts."
set device_supported false
}
} 

if { $device_supported } {



set revision_name [get_current_revision]
if { $debug_on } { post_message -type $default_message_type "current revision_name=  $revision_name" }
set flow_report_file    [file join $settings_array(project_path) "${revision_name}.flow.rpt"]


set status_line_string      "Flow Status"
set bad_status_string       "Failed"

set successful_compile      "false"
    ###########################
if { $debug_on } { post_message -type $default_message_type "Looking for file '$flow_report_file'.." }
if  [ catch { open $flow_report_file  r }   flow_id  ] {
if { $debug_on } { post_message -type warning "Cant find flow report file '$flow_report_file'" }
set found_flow_file  "false"
} else {
if { $debug_on } { post_message -type $default_message_type "Found file '$flow_report_file'." }
set found_flow_file  "true"
while { [gets $flow_id  in_line   ] >= 0 }  {

if { [string first $status_line_string  $in_line] != -1 } {
if { [string first $bad_status_string  $in_line] != -1 } {
if { $debug_on } { post_message -type warning "File indicates that flow failed." }
set successful_compile  "false"
} else {
set successful_compile  "true"
}
break
}
}
}
    ###############################

if { $successful_compile } {

if { [catch {
set f [open $post_compile_summary_file w]
puts $f "Postcompile not run"
close $f
}]} {
post_message -type error "Couldn't open $post_compile_summary_file for writing"
post_message -type error "Fatal Error. Stop."
return
}


#puts " This may take some time.."

set datapath_present [::ddr::paths::check_datapath_present $settings_array(wrapper_name)]

if { $datapath_present } {


post_message -type $default_message_type       " Running Quartus II Timing Analyzer (delay extraction only)"
post_message -type $default_message_type       " See file '${variation_name}_extraction_log.txt' for detailed log messages"



set tan_arg_name [::ddr::legacy::tan_arg_script_name $family $settings_array(ddr_mode) $settings_array(fedback_clock_mode)]
if { $tan_arg_name != "" } {
post_message -type info "Running Timing Analysis using $tan_arg_name"
set tanretcode [catch {
exec [file join $quartus(binpath) quartus_tan] -t [file join $settings_array(mw_path) $tan_arg_name] ${variation_name}
} tanresults]
set f [open "${variation_name}_extraction_log2.txt" w]
puts $f $tanresults
close $f

set skipping true
if { $tanretcode != 0 } {
foreach line [split $tanresults \n] {

if { [string trim $line] == "Delay annotation completed successfully" } {
set skipping false
continue 
}
#if { $skipping } { continue }


if { $line != "" } { 
post_message -type info $line
}
}
}
if { $tanretcode != 0 } {
post_message -type error "Post compile timing analysis failed (retcode=$tanretcode)"
foreach line [::ddr::messages::get_tan_failed_message] {
post_message -type info $line
}
} 

} else {
set tanretcode [catch {
exec [file join $quartus(binpath) quartus_tan] -t [file join $settings_array(mw_path) tan_arg.tcl] ${variation_name}
} tanresults]
set f [open "${variation_name}_extraction_log2.txt" w]
puts $f $tanresults
close $f
if { $tanretcode != 0 } {
post_message -type error "DDR Post compile timing analysis failed"
}
}

if { $debug_on } { post_message -type $default_message_type "tan_arg done. Getting results.." }


if { $post_log_messages } {
if  [ catch { open $intermediate_file  r }   inter_id  ] {
post_message -type error "Cant read results file '$intermediate_file'"
return -code 99
} else {
while { [gets $inter_id  in_line   ] >= 0 }  {
post_message -type $default_message_type_tan_arg "$in_line"
}
}
}

if  [ catch { open $post_compile_summary_file  r }   postsum_id  ] {
post_message -type error "Cant read summary table file '$post_compile_summary_file'"
return -code 99
} else {

while { [gets $postsum_id  in_line   ] >= 0 }  {
set message_type    $default_message_type_tan_arg
if { [string match "${warning_tag}*" $in_line ]  } { 
set message_type "warning"  
set post_line       [::ddr::utils::string_chop_left $in_line ${warning_tag}]
} elseif { [string match "${cwarning_tag}*" $in_line ]  } { 
set message_type "critical_warning"  
set post_line       [::ddr::utils::string_chop_left $in_line ${cwarning_tag}]
} elseif { [string match "${note_tag}*" $in_line ]  } { 
set message_type "extra_info"  
set post_line       [::ddr::utils::string_chop_left $in_line ${note_tag}]
} elseif { [string match "${extrainfo_tag}*" $in_line ]  } { 
set message_type "extra_info"  
set post_line       [::ddr::utils::string_chop_left $in_line ${extrainfo_tag}]
} elseif { [string match "${error_tag}*" $in_line ]  } { 
set something_bad_happened      "true"
set message_type "error"  
set post_line       [::ddr::utils::string_chop_left $in_line ${error_tag}]
} else { 
set post_line   $in_line
}
if { $post_line != "" } {
post_message -type $message_type  "$post_line"
}
}
}

if { $something_bad_happened } {
post_message -type error       " In-System timing verification of $name_of_ddr_megacore variation '${variation_name}' could not be completed due to the above errors."
puts " Errors encountered (variation= '${variation_name}').  See 'System' Tab for all messages."
} else {
post_message -type $default_message_type       " In-System timing verification of $name_of_ddr_megacore variation '${variation_name}' complete."
post_message -type $default_message_type       " Please run the appropriate script for In-System verification of other $name_of_ddr_megacore variations you may have in your project, and check system Fmax."
} 
} else {
post_message -type critical_warning "Cannot find data path $settings_array(wrapper_name). Skipping DDR Post-compile analysis for DDR MegaCore instance $settings_array(wrapper_name)."
}       
} else {

post_message -type error "DDR timing cannot be verified until project has been successfully compiled."
}
if { $debug_on } { post_message -type $default_message_type "End of script." }









}
puts " All Done.  See 'System' Tab for all messages.\n\n"

