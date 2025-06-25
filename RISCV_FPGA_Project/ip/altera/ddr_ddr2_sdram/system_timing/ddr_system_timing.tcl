
set  release_state  "release"  
set  mw_to_be_updated        "false"

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














#   source  <filename.tcl>    ;


## !!! Must change equations (2 places) so "max_delay_scaling_under_MIN_conditions" is applied on top of MIN scaling
## !!! set false on the one with the DQS delay




package require ::ddr::utils
package require ::ddr::settings
package require ::ddr::phasesel
package require ::ddr::legacy
package require ::ddr::messages
package require ::ddr::mwinterface
package require ::ddr::s2dqs


if { ! [info exists release_state] } { set release_state  "release" }


if { $release_state == "debug" } {
set show_clock_delays                   false

set debug_equations                     false            ;
set show_progress                       false

set debug_post                          false
set debug_on                            false
set debug2_on                           false
set debug_family_on                     false
set debug_loop_on                       false
set test_outputs_to_gui                 false        ;
set dump_all_margins                    true
} else {
set show_clock_delays                   false
set debug_equations                     false
set show_progress                       false
set debug_post                          false
set debug_on                            false
set debug2_on                           false
set debug_family_on                     false
set debug_loop_on                       false
set test_outputs_to_gui                 false
set dump_all_margins                    false
}

if { $show_progress } { puts    $post_summary_id    " >> Start of auk_system_main.tcl" }

#############################


::ddr::legacy::set_postcompile_summary_tags





## Notes ##
set note_cl_for_custom                  "For a 'Custom' memory device, please ensure that your chosen CL is compatible with your clock speed selection"
set note_clock_has_been_normalised      "Clock period used for timing setup and analysis is"
set note_nondqs_tan_will_do_resync      "Resync margin will be analyzed correctly by Quartus II (PLL 'capture' clock  to PLL 'resync' clock )" 

## Warnings ##
set warn_dll_ref_clock                  "It is not recommended to operate with the Stratix DLL reference clock active during read cycles"
set warn_lower_than_fmin                "The chosen memory device may not operate as low as the chosen frequency."
set warn_excessive_trace_delays         "Board trace delays far exceed recommended limits."
set warn_clk_fb_trace_bad               "Clock fed-back trace delay does not match clock plus DQS path"
set warn_clk_fb_trace_recommended       "Fed-back clock mode is recommended for frequencies greater than 200MHz."

set warn_nondqs_tell_user_to_set_phase  "You must set the PLL capture phase to"

    ## Critical Warnings ##
set warn_default_trace_delays           "Board Timings: You have selected one or more default board trace delays. Please modify 'FPGA Clock  output..' and 'Memory DQ/DQS..' fields to reflect requirements for your specific system so that the correct timing set-up and analysis can be performed."

#### Todd: "Board Timings: You have selected default board trace delays; Please modify FPGA Clock output and Memory DQ/DQS fields to reflect requirements for your specific board".

    ## Errors ##
set error_unrecognised_cl_1             "Unrecognised CAS latency"
set error_unrecognised_cl_2             "(must be 2, 2.5, 3, 4 or 5)"

## messages used during Development only ##
set error_temp_reminder_for_dev_only    "Awaiting 'memory_device' from wizard"




proc get_cycles { degrees  { what "" } } {
if {        $degrees < 360  }  {
set       cycles       0
} elseif {  $degrees < 720  }  {   
set       cycles       1
} elseif {  $degrees < 1080  }  {   
set       cycles       2
} elseif {  $degrees < 1440  }  {
set       cycles       3
} elseif {  $degrees < 1800 } {
set       cycles       4
} elseif {  $degrees < 2160 } {
set       cycles       5
} else {
set       cycles       6
#puts "    WARNING:   RTD Delay may be too large for '$what' \""
}
return $cycles
}

proc get_margin { left right mid } {
set     setup [  expr { $mid - $left } ]
set     hold  [  expr { $right - $mid } ]

if { $setup < $hold } {
return  $setup
} else { 
return  $hold
}
}



proc puts_safe  { id  var_assign  val  } {
set  nullstr    ""
set  val_safe    $val
if { [ string match $nullstr $val ] }  { set  val_safe -999999  }
puts $id    "$var_assign $val_safe"
}

#####################################################

proc get_array_path_data {  path  min_max   i  { do_scaling  true } } {
global  base_array_name
global  scale_min_timing_from_minus_40_to_0degc
global  scale_max_timing
#set base_array_name     "_paths_for_each_half_dq_"
set thename     "${min_max}${base_array_name}$i"

upvar  #0 $thename  thearray
global  $thename
set def     [ array names $thename $path]
if { [llength $def] == 0 } {
set val     "n/a"
#set val     "ERROR-The-type->>${index}<<-does-not-exist"
} else {
if { $do_scaling } {
if { $min_max == "min" } {
set val     [expr { $thearray($path) *  $scale_min_timing_from_minus_40_to_0degc } ]
} else {
set val     [expr { $thearray($path) *  $scale_max_timing   } ]
}
} else {
set val      $thearray($path)
}
if { [catch {expr {$val+1} }] } {
error "get_array_path_data found $val. should have got a number"
}
}
return  $val
}



proc message_out { sever  str } {
global  silent_mode  out_id  verbose
switch -glob -- $sever {
{[Ww]*}     { set severity "WARNING:" }
{[Ee]*}     { set severity "ERROR:  " }
{[Dd]*}     { set severity ">>>DEBUG>>>" }
{[Cc]*}		{ set severity "CRITWARNING:" } 
default     { set severity "NOTE:   " }
}

puts     stdout     "    MESSAGE             \"${severity}  $str\"" 

if { $silent_mode == "false" && [info exists out_id] } {
puts $out_id    "${severity}  $str"
}
}

# eg. [get_path_info $my_path  "src_ext1"]

proc get_ddr_path_info { thename  index } {

upvar  #0 $thename  thearray
global  $thename
set def     [ array names $thename $index]
if { [llength $def] == 0 } {
set val     "false"
#set val     "ERROR-The-type->>${index}<<-does-not-exist"
} else {
set val     $thearray($index)
}
return  $val
}




proc clk_override_to_phase { which_clock  which_edge } {
switch -exact -- $which_clock {
"clk"           {   if { $which_edge == "rising" } {
set     shift       0
} else {
set     shift       180
}
}
"write_clk"     {   if { $which_edge == "rising" } {
set     shift       270
} else {
set     shift       90
}
}
default         {   set     shift       0

}
}
return      $shift 
}





set     array_name_ident                "array_name="
set     base_array_name                 "_paths_for_each_half_dq_"      ;
set     base_margins_array_name         "margins_for_each_half_dq_"
##################################


set     debug_paths_from_file           false
set     n_halfdq_range_debug            0

if {![info exists format_output_for_cmd_line] } { set format_output_for_cmd_line          false }


set temp_fix_for_postamble_low_freq     true
set gui_test_num                        8000





set error_flag                          0
set time_stamp                          [clock format [clock seconds]]

set all_system_timing_met       "true"              ;
set timing_failures             ""

##########################################################################################################################



set system_spec_available           [info exists    ddr_timing_args]
set extracted_data_available        [info exists    ddr_timings_list_of_array_names]

if { $system_spec_available  } {
puts "\n>>> PRE_compile_mode <<<\n"
set pre_compile_mode                "true"
set post_compile_mode               false
set debug_post_compile_mode         false
puts "Input Parameters"
puts "----------------"
foreach { k v} [array get ddr_timing_args ] {
puts [format "%-50s %5s" $k $v]
}
} elseif { $extracted_data_available } {
puts "\n>>> POST_compile_mode <<<\n"
set post_compile_mode               "true"
set pre_compile_mode                false
set debug_post_compile_mode         false
} else {
puts "\n>>> DEBUG_POST_compile_mode <<<\n"
set debug_post_compile_mode         "true"
set pre_compile_mode                false
set post_compile_mode               false
}

if { $show_progress } { puts    $post_summary_id    " >> determined post_compile_mode = $post_compile_mode" }

if { $pre_compile_mode } {
if { $ddr_timing_args(clock_generation) != "ddio" } {
::ddr::mwinterface::report_msg warn [::ddr::messages::dedicated_clkout_mode_warning]
}


set     variation_path                      $ddr_timing_args(variation_path)

set     clock_pos_pin_name                  $ddr_timing_args(clock_pos_pin_name)
set     clock_neg_pin_name                  $ddr_timing_args(clock_neg_pin_name)


set     use_override_resynch                   $ddr_timing_args(override_resynch)
set     override_resynch_cycle                 $ddr_timing_args(resynch_cycle)
set     override_resynch_edge                  $ddr_timing_args(resynch_edge)
set     override_resynch_clock                 $ddr_timing_args(resynch_clock)
set     override_inter_resynch                 $ddr_timing_args(inter_resynch)

set    use_override_postamble               $ddr_timing_args(override_postamble)
set    override_postamble_cycle             $ddr_timing_args(postamble_cycle)
set    override_postamble_edge              $ddr_timing_args(postamble_edge)
set    override_postamble_clock             $ddr_timing_args(postamble_clock)
set    override_inter_postamble             $ddr_timing_args(inter_postamble)
set    override_num_dqs_buffers             $ddr_timing_args(undelayed_dqs_out)

set     silent_mode                         $ddr_timing_args(silent_mode)

set     current_script_working_dir          $ddr_timing_args(current_script_working_dir)
set     current_quartus_project_dir         $ddr_timing_args(project_path)
set     output_dir                          $ddr_timing_args(output_directory)
set     quartus_project_name                $ddr_timing_args(project_name)
set     wrapper_name                        $ddr_timing_args(wrapper_name)
set     pin_prefix                          $ddr_timing_args(pin_prefix)



set     family                              $ddr_timing_args(family)
set     fpga_device                         $ddr_timing_args(fpga_device)
set     fpga_speed_grade                    $ddr_timing_args(fpga_speed_grade)

set     ddr_mode                            $ddr_timing_args(ddr_mode)
set     clock_freq_in_mhz                   $ddr_timing_args(clock_freq_in_mhz)
set     cas_latency                         $ddr_timing_args(cas_latency)
set     fedback_clock_mode                  $ddr_timing_args(fedback_clock_mode)

set     use_dedicated_pll_output_as_clock   $ddr_timing_args(use_dedicated_pll_output_as_clock)         ;
set     dll_ref_clock_switched_off_during_reads    $ddr_timing_args(dll_ref_clock_checked)              ;


set     gLOCAL_DATA_BITS                    $ddr_timing_args(gLOCAL_DATA_BITS)
set     gMEM_DQ_PER_DQS                     $ddr_timing_args(gMEM_DQ_PER_DQS)
set     gPOSTAMBLE_REGS                     $ddr_timing_args(gPOSTAMBLE_REGS)
set     num_output_clocks                   $ddr_timing_args(num_output_clocks)

set     enable_postamble                    $ddr_timing_args(enable_postamble)


set     tPD_clock_trace_NOM                 $ddr_timing_args(board_tPD_clock_trace_NOM)
set     tPD_dqs_trace_total_NOM             $ddr_timing_args(board_tPD_dqs_trace_total_NOM)
set     pcb_delay_var_percent               $ddr_timing_args(board_pcb_delay_var_percent)
set     tSKEW_data_group                    $ddr_timing_args(board_tSKEW_data_group)
set     tPD_clockfeedback_trace_NOM         $ddr_timing_args(tpd_clockfeedback_trace_nom)



set     memory_device                       $ddr_timing_args(memory_device)
set     tDQSQ                               $ddr_timing_args(memory_tDQSQ)
set     tQHS                                $ddr_timing_args(memory_tQHS)
set     tDQSCK                              $ddr_timing_args(memory_tDQSCK)
set     tAC                                 $ddr_timing_args(memory_tAC)
set     fmax_at_cl5                         $ddr_timing_args(memory_fmax_at_cl5)
set     fmax_at_cl4                         $ddr_timing_args(memory_fmax_at_cl4)
set     fmax_at_cl3                         $ddr_timing_args(memory_fmax_at_cl3)
set     fmax_at_cl25                        $ddr_timing_args(memory_fmax_at_cl25)
set     fmax_at_cl2                         $ddr_timing_args(memory_fmax_at_cl2)
set     tCK_MAX                             $ddr_timing_args(memory_tCK_MAX)

set     tDS                                 $ddr_timing_args(memory_tDS)
set     tDH                                 $ddr_timing_args(memory_tDH)                                                            
set     percent_tDQSS                       $ddr_timing_args(memory_percent_tDQSS)




}
if { ! [ info exists  silent_mode                   ] } { set silent_mode               "false"  }
if { ! [ info exists  quartus_version               ] } { set quartus_version           "4.1" }



########################### START NON DQS FBC #########################
if { $fedback_clock_mode &&  $ddr_mode == "non-dqs" } {
package require ::ddr::nondqsfbc
::ddr::nondqsfbc::precompile_top_level ddr_timing_args
return 0
}
########################### END OF NON DQS FBC ########################


########################### START OF DQS FBC ##########################
if { $fedback_clock_mode &&  $ddr_mode == "normal" } {
package require ::ddr::dqsfbc
::ddr::dqsfbc::precompile_top_level ddr_timing_args
return 0
}
########################### END OF DQS FBC ############################


if { $pre_compile_mode } {
set     margins_file                    "${wrapper_name}_pre_compile_margins.txt"
} else {
set     margins_file                    "${variation_name}_post_compile_margins.txt"
}


if { $post_compile_mode && $fedback_clock_mode } {
set     misc_tan_assignments_file           "${variation_name}_misc_tan_assignments.txt"
}

set     equations_file                  "${wrapper_name}_equations.txt"

if { 1 } {

if { ! [ info exists  current_quartus_project_dir   ] } { set current_quartus_project_dir ""  } 

if { ! [ info exists  current_script_working_dir    ] } { set current_script_working_dir  ""  } 

if { ! [ info exists  output_dir                    ] } { set output_dir                  ""  } 
}



if  { ![info exists extracted_data_dir] } {
set     extracted_data_dir  [file join $current_script_working_dir  "timing_data"  "estimated_paths"] 
}

if { $silent_mode == "false" } {

if { $pre_compile_mode  } {
set     summary_file_name               "${wrapper_name}_pre_compile_ddr_timing_summary.txt"
set     summary_file_path            [ file join  $wrapper_path  $summary_file_name  ]

if { [ catch { open $summary_file_path  w }   out_id] } {
puts  " - ERROR: Cant open file '$summary_file_path' for output."
return -code 99
}
}

if { $debug_equations } {
set     equations_file_path            [ file join  $current_quartus_project_dir  $equations_file  ]

if { [ catch { open $equations_file_path  w }   equ_id ] } {
puts  " - ERROR: Cant open file '$equations_file_path' for output."
return -code 99
}

}

if { $dump_all_margins } {
set     margins_file_path            [ file join  $current_quartus_project_dir  $margins_file  ]
if { [ catch { open $margins_file_path  w }   margins_id] } {
puts  " - ERROR: Cant open file '$margins_file_path' for output."
return -code 99
}
}

if { $post_compile_mode && $fedback_clock_mode } {
set     misc_tan_assignments_file_path          [ file join  $current_quartus_project_dir  $misc_tan_assignments_file  ] 
if { [ catch { open $misc_tan_assignments_file_path  w }   misc_tan_id] } {
puts  " - ERROR: Cant open file '$misc_tan_assignments_file_path' for output."
return -code 99
}
}

}


if { $show_progress } { puts    $post_summary_id    " >> handle family and speed grade" }




message_out Note "Speed Grade $fpga_speed_grade used for analysis"



if { $family == "hardcopyii" } {
set family "stratixii"
if { $fpga_speed_grade == "c" } {
set fpga_speed_grade "c4"
} elseif {  $fpga_speed_grade == "i" } {

set fpga_speed_grade "i4"
} else {
::ddr::utils::assert {0} {$fpga_speed_grade} "Unrecognised speed grade for hardcopyii device"
}
}


set industrial_speed_grade 0
if    { [ string match {[Ii]*}   $fpga_speed_grade ] } {
message_out Note "Detected Industrial device. Disabling scaling factors to widen valid temperature range of timing analysis."
set industrial_speed_grade 1
switch -glob -- $fpga_speed_grade  {
[iI]3   { set fpga_speed_grade  c3  }
[iI]4   { set fpga_speed_grade  c4  }
[iI]5   { set fpga_speed_grade  c5  }
[iI]6   { set fpga_speed_grade  c6  }
[iI]7   { set fpga_speed_grade  c7  }
[iI]8   { set fpga_speed_grade  c8  }
}
}

::ddr::legacy::set_family_is_star




if { $post_compile_mode } {
puts "Info: Extracted data should exist as data arrays."
set     n_halfdq_range      [expr { $gLOCAL_DATA_BITS - 1 } ]
if { $show_progress } { puts    $post_summary_id    " >> Dumping extrated data (post-compile only)" }

set     array_name_ident        "array_name="       ;

foreach  array_name  $ddr_timings_list_of_array_names {
puts $data_id       "$array_name_ident    $array_name"
upvar 0 $array_name  next_array
foreach  path  $paths_of_interest {

set def     [ array names $array_name ]
if { [llength $def] == 0 } {
set gotcha      "n/a"
} else {
set gotcha          $next_array($path)
}
puts $data_id       "[format "    %-20s  %5s" $path   $gotcha]"
}
}


} else {
set     family_speed_grade_file     [file join $extracted_data_dir  "${family}-${fpga_speed_grade}_paths.txt"]
if { $pre_compile_mode } {
set     extracted_data_file           $family_speed_grade_file
set     n_halfdq_range      0
} else {
if { $debug_paths_from_file } {
set     extracted_data_file           $family_speed_grade_file
puts    "Info: (debug_paths_from_file)"
set     n_halfdq_range          $n_halfdq_range_debug
} else {
set     extracted_data_file           [file join $extracted_data_dir  "extraction_data.txt" ]
puts    "Info: (debug_post_compile_mode) Extracted data not available in data arrays. Looking for data file instead.."
set     n_halfdq_range          [expr { $gLOCAL_DATA_BITS - 1 } ]
}
}


set  paths_of_interest  [list {I_dont_exist}]      


if { [catch { open $extracted_data_file  r }   extract_id] } {
puts  " - ERROR: Cant read file '$extracted_data_file'"
return -code 99
} else {
puts " "
puts "Info: Using extracted data from file '$extracted_data_file'"
while { [gets $extract_id  in_line] >= 0 }  {
scan  $in_line " %s  %s "   var1   var2
if { $var1 == $array_name_ident } {
set array_name $var2
lappend ddr_timings_list_of_array_names        $array_name
} else  {
set ${array_name}($var1)     $var2

if { [lsearch -exact $paths_of_interest $var1] == -1 } {
lappend paths_of_interest       $var1
}
}
}
}
set num_arrays_found        [llength $ddr_timings_list_of_array_names]









if { $ddr_mode == "non-dqs" && $family_is_stratix2 } {
set min_paths_for_each_half_dq_0(dq_2_ddio) $min_paths_for_each_half_dq_0(dq_2_ddio_nondqs)
set max_paths_for_each_half_dq_0(dq_2_ddio) $max_paths_for_each_half_dq_0(dq_2_ddio_nondqs)
}


if { $ddr_timing_args(use_project_timing_estimates) } {
set back_ann_estdata [file join $ddr_timing_args(wrapper_path) "${wrapper_name}_estimated_data.dat"]
if { [file exists $back_ann_estdata] } {
if { [catch { source $back_ann_estdata } err] } {

message_out warn [::ddr::messages::back_annotation_failed $back_ann_estdata $err]
} else {
message_out info [::ddr::messages::back_annotation_successful $back_ann_estdata]
}
} else {
message_out warn [::ddr::messages::back_annotation_no_file $back_ann_estdata]
}
}
}



if { $pre_compile_mode } { 

##### default outputs  ####


set     gRESYNCH_EDGE                   ""
set     gRESYNCH_CYCLE                  ""
set     gINTER_RESYNCH                  ""
set     gPOSTAMBLE_EDGE                 ""
set     gPOSTAMBLE_CYCLE                ""
set     gINTER_POSTAMBLE                ""
set     dqs_phase_stratix               ""
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS      ""

set     gSTRATIXII_DQS_PHASE                "9999"
set     gSTRATIXII_DLL_DELAY_BUFFER_MODE    "undefined"               ;# "0"
set     gSTRATIXII_DQS_OUT_MODE             "undefined"      ;#  "3"
set     gSTRATIXII_DLL_DELAY_CHAIN_LENGTH   "99"



set     gCONNECT_RESYNCH_CLK_TO         ""
set     gCONNECT_POSTAMBLE_CLK_TO       ""
set     gCONNECT_CAPTURE_CLK_TO         ""

set     dqs_delay_cyclone               ""

####### Reporting #######
## FYI
set     dqs_cram_cyclone                ""
## Tell user to setup the PLL with these
set     resynch_phase                   "9999"
set     postamble_phase                 "9999"
set     chosen_capture_phase                   "9999"
## General timing reports
set     memory_fmin                     "9999"


}

if { $mw_to_be_updated } {     
message_out error   $error_temp_reminder_for_dev_only
}

##### DQS delay user options ####

set     cram_first                  0  
set     cram_last                   63

set     quartus_dqs_phase_      [ list  "72"  "90"  ] 




######################################################



######################################################
::ddr::settings::read_temp [ file join  $current_script_working_dir "timing_data"  "common.txt" ]
::ddr::settings::read_temp [ file join  $current_script_working_dir "timing_data" "${family}_common.txt" ]
::ddr::settings::read_temp [ file join  $current_script_working_dir "timing_data" "${family}-${fpga_speed_grade}.txt" ]


######################################################

######################################################
if { $family_is_cyclone } {
set     user_input_file_name            [ file join $current_script_working_dir  "timing_data"  "dqs_table_cyclone1.txt" ]
if { [ catch { open $user_input_file_name  r }   user_id  ] } {
puts  " - ERROR: Cant read file '$user_input_file_name'"

} else {
for { set  i  $cram_first } { $i  <= $cram_last } { incr i 1 } {
gets $user_id  in_line
scan  $in_line " %d %d %d %d %d"   c7_max  c6_max  all_min  c7_nom  c6_nom

if { [ string match c6 $fpga_speed_grade ]  } {

lappend     tSHIFT90_                       $c6_max
lappend     tSHIFT90_NOM_                   $c6_nom
} else {

lappend     tSHIFT90_                       $c7_max
lappend     tSHIFT90_NOM_                   $c7_nom
}
lappend         tSHIFT90_MIN_                   $all_min
}
}
} elseif { $family_is_cyclone2 } {
set     user_input_file_name            [ file join $current_script_working_dir  "timing_data"  "dqs_table_cyclone2.txt" ]
if { [ catch { open $user_input_file_name  r }   user_id  ] } {
puts  " - ERROR: Cant read file '$user_input_file_name'"

} else {
for { set  i  $cram_first } { $i  <= $cram_last } { incr i 1 } {
gets $user_id  in_line
set match [regexp {^\W*(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W*$} $in_line   min_rise min_fall min_typ  c6_rise c6_fall c6_typ  c7_rise c7_fall c7_typ  c8_rise c8_fall c8_typ]
if { ! $match } { error "Couldn't parse dqs_table_cyclone2.txt line $i:  $in_line" } 
switch -- $fpga_speed_grade {
c6 {
lappend     tSHIFT90_                       $c6_typ
}
c7 {
lappend     tSHIFT90_                       $c7_typ
}
c8 {
lappend     tSHIFT90_                       $c7_typ
} 
a7 {
lappend     tSHIFT90_                       $c7_typ
}                 
default {
error "Fpga speed grade $fpga_speed_grade not recognised"
}
}
lappend         tSHIFT90_MIN_                   $min_typ


}
}
}







set global_min_acceptable_margin                $pes_global_min_acceptable_margin 
set t_rise_to_vref                              $pes_t_rise_to_vref
set scale_min_timing_from_minus_40_to_0degc     $pes_scale_min_timing_from_minus_40_to_0degc
set scale_max_timing                            $pes_scale_max_timing               
set min_delay_scaling_under_MAX_conditions      $pes_min_delay_scaling_under_MAX_conditions
set max_delay_scaling_under_MIN_conditions      $pes_max_delay_scaling_under_MIN_conditions

if { $industrial_speed_grade } { 
set scale_min_timing_from_minus_40_to_0degc 1.000
}

if { $debug_equations && ( ! $silent_mode ) } {
puts $equ_id    " "
puts $equ_id    " scale_min_timing_from_minus_40_to_0degc       $scale_min_timing_from_minus_40_to_0degc "
puts $equ_id    " scale_max_timing                              $scale_max_timing "
puts $equ_id    " min_delay_scaling_under_MAX_conditions        $min_delay_scaling_under_MAX_conditions "
puts $equ_id    " max_delay_scaling_under_MIN_conditions        $max_delay_scaling_under_MIN_conditions "
puts $equ_id    "-------------------------------------------------------------------------------"
}

::ddr::utils::assert {[string is double $cas_latency]} {$cas_latency}
set formatted_cas_latency      [ format "%1.1f" $cas_latency ]


if { $pre_compile_mode } {
set     best_dqs_shift_setting      -99999
}
set     dqs_cram_cyclone            -99999

if { $show_progress } { puts    $post_summary_id    " >> Sanity check user input" }

if { ( $tPD_clock_trace_NOM == $mw_default_trace_NOM ) ||  ( $tPD_dqs_trace_total_NOM == $mw_default_trace_NOM ) } {
message_out c $warn_default_trace_delays
}
::ddr::utils::sett {clock_freq_actually_used clock_period} [::ddr::utils::normalise_clock_frequency $clock_freq_in_mhz]

###############################################################

###############################################################

set     tSKEW                       [expr      { $tSKEW_data_group  + $tSKEW_other  }         ]


if { 0 } {

set     tHP                         [expr     {  ( 0.5 - ( $clock_duty_cycle_at_fpga_output_pin_percent_error / 100.0 ) ) * $clock_period  }    ]
} else {
set tHP [expr { (0.5 - $dcd_on_clk_to_sdram_tck)*$clock_period  - $dcd_on_clk_to_sdram_ps } ]
}
set     tQH                         [expr     {  $tHP         - $tQHS   }          ]


#set     DVW_memory_rel_dqs          [expr     {  $tQH        - $tDQSQ   }          ]




set     min_dqs_period_at_end_of_burst_under_MAX_conditions     [ expr { $clock_period * $smallest_dqs_period_scaling }     ]


###################################

###################################


set     rtd_trace_delay_total_NOM           [ expr     { $tPD_clock_trace_NOM  + $tPD_dqs_trace_total_NOM }  ]

set     rtd_trace_delay_total               [ expr     { $rtd_trace_delay_total_NOM * ( 1 +  ( $pcb_delay_var_percent / 100.0 ) ) }  ]
set     rtd_trace_delay_total_MIN           [ expr     { $rtd_trace_delay_total_NOM * ( 1 -  ( $pcb_delay_var_percent / 100.0 ) ) }  ]

set     t_dc_distortion_at_fpga_output_pin  [ expr     { ( $clock_duty_cycle_at_fpga_output_pin_percent_error / 100.0 ) * $clock_period } ]

if { $fedback_clock_mode } {
set     fb_trace_delay_total_MAX        [ expr   { $tPD_clockfeedback_trace_NOM * ( 1 +  ( $pcb_delay_var_percent / 100.0 ) ) }  ]
set     fb_trace_delay_total_MIN        [ expr   { $tPD_clockfeedback_trace_NOM * ( 1 -  ( $pcb_delay_var_percent / 100.0 ) ) }  ]

}


###############################################################

###############################################################



if { $memory_device == "Custom" } {
set     memory_fmin     $custom_memory_fmin_default
} else {
set     memory_fmin     [ expr { round ( 1000000 / ( 0.0 + ${tCK_MAX} ) ) } ] 
}

if { $clock_freq_actually_used < $memory_fmin } {

message_out w "$warn_lower_than_fmin"
set all_system_timing_met       false
append  timing_failures "Freq too low, "
}


set cl_too_low      0
set cl_too_high     0


set fmax_at_cl2_plus        [ expr { $fmax_at_cl2  + 1.0 } ]
set fmax_at_cl25_plus       [ expr { $fmax_at_cl25 + 1.0 } ]
set fmax_at_cl3_plus        [ expr { $fmax_at_cl3  + 1.0 } ]
set fmax_at_cl4_plus        [ expr { $fmax_at_cl4  + 1.0 } ]
set fmax_at_cl5_plus        [ expr { $fmax_at_cl5  + 1.0 } ]

if {        $cas_latency == 2   }  {
if { $fmax_at_cl2_plus  < $clock_freq_actually_used }  { set cl_too_low  1 }
} elseif {  $cas_latency == 2.5 }  {
if { $fmax_at_cl25_plus  < $clock_freq_actually_used }  { set cl_too_low      1  }
if { $fmax_at_cl2 >= $clock_freq_actually_used  }  { set cl_too_high     1  }
} elseif {  $cas_latency == 3   }  {
if { $fmax_at_cl3_plus  < $clock_freq_actually_used  }  { set cl_too_low      1  }
if { $fmax_at_cl25 >= $clock_freq_actually_used }  { set cl_too_high     1  }
} elseif {  $cas_latency == 4   }  {
if { $fmax_at_cl4_plus  < $clock_freq_actually_used  }  { set cl_too_low      1  }
if { $fmax_at_cl3  >= $clock_freq_actually_used }  { set cl_too_high     1  }
} elseif {  $cas_latency == 5   }  {
if { $fmax_at_cl5_plus  < $clock_freq_actually_used  }  { set cl_too_low      1  }
if { $fmax_at_cl4  >= $clock_freq_actually_used }  { set cl_too_high     1  }
} else {
message_out  error  "$error_unrecognised_cl_1 '$cas_latency' $error_unrecognised_cl_2"
return
}





if { $memory_device == "Custom" } {
message_out NOTE $note_cl_for_custom
} else {
if {       $cl_too_low == 1 } {
message_out WARN [format "Memory device is not specified to run at %.2f MHz with CL= $formatted_cas_latency" $clock_freq_actually_used]
set  all_system_timing_met   false
append  timing_failures "CL too low, "
} elseif { $cl_too_high == 1 } {
message_out NOTE [format "Memory device can operate at %.2f MHz with a lower CL than $formatted_cas_latency" $clock_freq_actually_used]
}
}

if { $ddr_mode == "normal" } {
if { ( ( $family == "stratix" ) || ( $family == "stratixgx" ) ) } {
if  { $dll_ref_clock_switched_off_during_reads == "false" } {
message_out WARN $warn_dll_ref_clock 
}
}
}


if { ( $tPD_clock_trace_NOM > $largest_allowed_clock_trace_NOM) ||  ( $tPD_dqs_trace_total_NOM > $largest_allowed_dqs_trace_total_NOM ) } {
message_out w $warn_excessive_trace_delays
set all_system_timing_met       false
append  timing_failures "Traces too long, "
}



if { $fedback_clock_mode } {
if { $rtd_trace_delay_total_NOM != $tPD_clockfeedback_trace_NOM } {
message_out w $warn_clk_fb_trace_bad
}
}

if { $family == "stratixii" } {
if { ( $clock_period < 5000 ) && ( ! $fedback_clock_mode ) } {
message_out w $warn_clk_fb_trace_recommended
}
}







if { 0 } {  message_out error "pin prefix is >$pin_prefix<"  }
set null_string_text        "NULL_STRING"
if { $pin_prefix == $null_string_text } {
set pin_prefix      ""
set pin_prefix_for_settings     $null_string_text
} else {
set pin_prefix_for_settings     $pin_prefix
}





if { ! [ info exists    tJITTER_pll  ] } {
if { $cyclone_pll_g_count_odd == 0 } {
set     tJITTER_pll     $tJITTER_pll_low
} else {
set     tJITTER_pll     $tJITTER_pll_high
}
}
##################################################################################################################################################
##################################################################################################################################################
##################################################################################################################################################

set     lists_need_to_be_cleared        false

#puts ">>>>> n_halfdq_range= $n_halfdq_range"

if { $show_progress } { puts    $post_summary_id    " >> n_halfdq loop" } 

for { set n_halfdq  0 } { ${n_halfdq} <= ${n_halfdq_range} } { incr n_halfdq } {

set margins_array_name                      "${base_margins_array_name}${n_halfdq}"
lappend ddr_timings_list_of_margins         $margins_array_name














set min_max_list  [list   min  max ]

foreach   min_max  $min_max_list {


if { $family == "cyclone" } {

set tpd_clk_2_mux($min_max)                 [ get_array_path_data    "clk_2_mux"               $min_max  ${n_halfdq} ] ;
set tpd_mux_2_clkpin($min_max)              [ get_array_path_data    "mux_2_clkpin"            $min_max  ${n_halfdq} ] ;
set tpd_sysclk_to_pin($min_max)                 [expr { $tpd_clk_2_mux($min_max)  + $tpd_mux_2_clkpin($min_max) } ]

set tpd_dq_2_wire($min_max)                 [get_array_path_data    "dq_2_wire"              $min_max  ${n_halfdq} ] ;
set tpd_wire_2_ddio($min_max)               [get_array_path_data    "wire_2_ddio"            $min_max  ${n_halfdq} ] ;
set tpd_dq($min_max)                            [expr { $tpd_dq_2_wire($min_max) +  $tpd_wire_2_ddio($min_max) } ]        



set tpd_routing_rega_to_regb_resynch($min_max)      [get_array_path_data    "ddio_2_reg"             $min_max  ${n_halfdq} ]


if { $ddr_mode == "normal" } {


set tpd_dqsclk_2_ddio_capture($min_max)         [get_array_path_data    "dqsclk_2_ddio_capture"     $min_max  ${n_halfdq} ] ;
set tpd_dqsclk_2_ddio_resync($min_max)          [get_array_path_data    "dqsclk_2_ddio_resync"      $min_max  ${n_halfdq} ] ;

if { $enable_postamble } {
set tpd_reset_control($min_max)                     [get_array_path_data    "reg_2_post"     $min_max  ${n_halfdq} ]
set tpd_reset_reg_to_enable($min_max)               [get_array_path_data    "post_2_ddio"      $min_max  ${n_halfdq} ]

}

if { $pre_compile_mode } {
set path_with_dqs_delay     "dqspin_2_dqsclk_minus_tshift" ;
} else {
set path_with_dqs_delay     "dqspin_2_dqsclk" ;
}

set tpd_dqspin_2_dqsclk_minus_tshift($min_max)        [get_array_path_data    $path_with_dqs_delay    $min_max  ${n_halfdq} false ]

set     tpd_dqs_capture($min_max)                     [ expr {     $tpd_dqspin_2_dqsclk_minus_tshift($min_max) +  $tpd_dqsclk_2_ddio_capture($min_max)  } ]
set     tpd_dqs_resync($min_max)                      [ expr {     $tpd_dqspin_2_dqsclk_minus_tshift($min_max) +  $tpd_dqsclk_2_ddio_resync($min_max)  } ]


}        


} elseif { $family == "stratix" || $family == "stratixii" } {



set tpd_dq($min_max)                                    [ get_array_path_data    dq_2_ddio              $min_max  ${n_halfdq} ]
set tpd_sysclk_to_pin($min_max)                         [ get_array_path_data    clk_2_pin              $min_max  ${n_halfdq} ]

if { $family == "stratix" } {
set tpd_routing_rega_to_regb_resynch($min_max)      [ get_array_path_data    ddio_2_reg             $min_max  ${n_halfdq} ]
} else {

set     tpd_ddio_2_core                             [ get_array_path_data    "ddio_2_core"          $min_max  ${n_halfdq} ] ;
set     tpd_core_2_reg                              [ get_array_path_data    "core_2_reg"           $min_max  ${n_halfdq} ] ;
set tpd_routing_rega_to_regb_resynch($min_max)      [ expr { $tpd_ddio_2_core +  $tpd_core_2_reg }  ]
}


if { $ddr_mode == "normal" } {
if { $family == "stratix" } {
set tpd_dqsclk_2_ddio($min_max)                 [ get_array_path_data    dqsclk_2_ddio          $min_max  ${n_halfdq} ]
} else {
set tpd_dqsclk_2_ddio_resync($min_max)          [ get_array_path_data    dqsclk_2_ddio_resync   $min_max  ${n_halfdq} ] ;
}


if { $pre_compile_mode } {
set path_with_dqs_delay     "dqspin_2_dqsclk_minus_tshift"
} else {
set path_with_dqs_delay     "dqspin_2_dqsclk"
}

set tpd_dqspin_2_dqsclk_minus_tshift($min_max)        [get_array_path_data    $path_with_dqs_delay    $min_max  ${n_halfdq} false ]

if { $family == "stratix" } {




set     tpd_dqs_capture($min_max)                     [ expr {     $tpd_dqspin_2_dqsclk_minus_tshift($min_max) +  $tpd_dqsclk_2_ddio($min_max)  } ]
set     tpd_dqs_resync($min_max)                   $tpd_dqs_capture($min_max)


if { $enable_postamble } {
set tpd_reset_control($min_max)                     [ get_array_path_data    reg_2_post             $min_max  ${n_halfdq} ]
set tpd_reset_reg_to_enable($min_max)               [ get_array_path_data    post_2_ddio            $min_max  ${n_halfdq} ]
set tpd_dqspin_2_undelayed($min_max)                [ get_array_path_data    dqspin_2_undelayed     $min_max  ${n_halfdq} ]
set tpd_undelayed_out_to_resetreg_clk($min_max)     [ get_array_path_data    undelayed_2_post       $min_max  ${n_halfdq} ]


set tpd_pseudo_dqs_pin_to_int($min_max)         [expr { $tpd_dqspin_2_undelayed($min_max) * $scaling_to_estimate_dqs_int  }]

set tpd_dqs_int_to_undelayed_out($min_max)    [expr { $tpd_dqspin_2_undelayed($min_max) - $tpd_pseudo_dqs_pin_to_int($min_max) } ]

set     tpd_dqs_int_to_ncapture_reg_clk_minus_tshift($min_max)      [expr { $tpd_dqs_capture($min_max) - $tpd_pseudo_dqs_pin_to_int($min_max) } ]
}

} else {


puts "tpd_dqspin_2_dqsclk_minus_tshift( $min_max )  = $tpd_dqspin_2_dqsclk_minus_tshift($min_max)"
puts "tpd_dqsclk_2_ddio_resync( $min_max )  = $tpd_dqsclk_2_ddio_resync($min_max)"


set     tpd_dqs_resync($min_max)                [ expr {     $tpd_dqspin_2_dqsclk_minus_tshift($min_max) +  $tpd_dqsclk_2_ddio_resync($min_max)  } ]

set     tpd_dqs_capture($min_max)                     $tpd_dqs_resync($min_max)


##set     tpd_dqs_int_to_ncapture_reg_clk_minus_tshift($min_max)      [expr { $tpd_dqs_capture($min_max) - $tpd_pseudo_dqs_pin_to_int($min_max) } ]


if { $enable_postamble } {

set tpd_reset_control($min_max)                     [ get_array_path_data    reg_2_post             $min_max  ${n_halfdq} ]

set tpd_resetreg_to_andgate($min_max)               [ get_array_path_data    post_2_dqsclk            $min_max  ${n_halfdq} ]
set tpd_andgate_to_resetreg_clk($min_max)           [ get_array_path_data    dqsclk_2_post       $min_max  ${n_halfdq} ]

}
}


}
# END ddr_mode == "normal"
} elseif { $family == "cycloneii" } {

set tpd_sysclk_to_pin($min_max) [get_array_path_data "sysclk_pin" $min_max ${n_halfdq} ]


set tpd_dq($min_max) [get_array_path_data "dq_capture" $min_max ${n_halfdq} ]


set tpd_routing_rega_to_regb_resynch($min_max) [get_array_path_data "capture_resync" $min_max ${n_halfdq} ]

if { $ddr_mode == "normal" } {

set tpd_dqspin_2_dqsclk_minus_tshift($min_max) [get_array_path_data "dqs_clkctrl" $min_max ${n_halfdq} ]


set tpd_dqs_capture($min_max) [expr [get_array_path_data "dqs_clkctrl" $min_max ${n_halfdq} ] +	[get_array_path_data "clkctrl_capture" $min_max ${n_halfdq} ] ]


set tpd_dqs_resync($min_max) [ expr [get_array_path_data "dqs_clkctrl" $min_max ${n_halfdq} ] + [get_array_path_data "clkctrl_resync" $min_max ${n_halfdq} ] ]

if { $enable_postamble } {

set tpd_reset_control($min_max) [get_array_path_data  "postctrl_posten" $min_max ${n_halfdq} ]


set tpd_resetreg_to_capture($min_max) [get_array_path_data "posten_capture" $min_max ${n_halfdq} ]



set tpd_andgate_to_resetreg_clk($min_max) [get_array_path_data "clkctrl_posten" $min_max ${n_halfdq} ]


set tpd_andgate_to_capturereg_clk($min_max) [get_array_path_data "clkctrl_capture" $min_max ${n_halfdq} ]
}
}
} else {
error "auk_read_node2node_paths: family $family is not recognised"
}

}



if { $show_progress } { puts    $post_summary_id    " >> Finished auk_read_node2node_paths" }
    ##################################################################################################################################################
    ##################################################################################################################################################


if { $post_compile_mode } {
lappend     list_of_max_clk_to_pin_delays   $tpd_sysclk_to_pin(max)
}

if { ( $ddr_mode == "normal" ) && $pre_compile_mode } {












#set     MIN_scaling         0.6     ;

if { $family_is_stratix } {
set may_insert_stratix_buffers      true
} else {
set may_insert_stratix_buffers      false
}

if { $may_insert_stratix_buffers } {
if { $use_override_postamble } {
switch -exact -- $override_num_dqs_buffers {
0           { set   tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_no_buffers
set   tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_no_buffers_MIN  }

1           { set   tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_one_buffer  
set   tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_one_buffer_MIN  }

2           { set   tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_two_buffers 
set   tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_two_buffers_MIN }

3           { set   tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_three_buffers 
set   tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_three_buffers_MIN }

4           { set   tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_four_buffers 
set   tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_four_buffers_MIN }

default     { set   tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_no_buffers  
set   tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_no_buffers_MIN  }

}
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS         $override_num_dqs_buffers      
} else {
if {       $clock_period <= $t_clock_period_postamble_hold_limit_for_inserting_zero_buffers } { 
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS      0
set     tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_no_buffers
set     tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_no_buffers_MIN

} elseif { $clock_period <= $t_clock_period_postamble_hold_limit_for_inserting_one_buffer } {
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS      1
set     tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_one_buffer
set     tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_one_buffer_MIN

} elseif {  $clock_period <= $t_clock_period_postamble_hold_limit_for_inserting_two_buffers } {
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS      2
set     tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_two_buffers
set     tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_two_buffers_MIN

} elseif {  $clock_period <= $t_clock_period_postamble_hold_limit_for_inserting_three_buffers } {
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS      3
set     tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_three_buffers
set     tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_three_buffers_MIN
}  else {
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS      4
set     tpd_undelayed_out_to_resetreg_clk(max)        $tPD_undelayed_out_to_resetreg_clk_four_buffers
set     tpd_undelayed_out_to_resetreg_clk(min)        $tPD_undelayed_out_to_resetreg_clk_four_buffers_MIN
}
#set     tpd_undelayed_out_to_resetreg_clk(min)       [ expr { $tpd_undelayed_out_to_resetreg_clk(max) * $MIN_scaling } ]
}
} else {
set     gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS         ""
}


}




if { $fedback_clock_mode } {

set tpd_clockout_and_trace(min)             [ expr  {   $tpd_sysclk_to_pin(min) +  $rtd_trace_delay_total_MIN   }   ] 
set tpd_clockout_and_trace(max)             [ expr  {   $tpd_sysclk_to_pin(max) +  $rtd_trace_delay_total       }   ] 


set tpd_clockout_and_fedback_trace(min)     [ expr  {   $tpd_sysclk_to_pin(min) +  $fb_trace_delay_total_MIN  }   ] 
set tpd_clockout_and_fedback_trace(max)     [ expr  {   $tpd_sysclk_to_pin(max) +  $fb_trace_delay_total_MAX  }   ] 



set tpd_clockout_and_trace(nom)     [ expr  { ( $tpd_clockout_and_trace(min) + $tpd_clockout_and_trace(max) ) / 2.0   } ]



if { $post_compile_mode && ( $n_halfdq == 0 ) } {
puts    $misc_tan_id    "EARLY_at_MIN_cond_arrival_time_at_fedback_PLL_input_pin_relative_to_system_clock_in_ps = $tpd_clockout_and_fedback_trace(min) "  
puts    $misc_tan_id    "LATE_at_MAX_cond_arrival_time_at_fedback_PLL_input_pin_relative_to_system_clock_in_ps  = $tpd_clockout_and_fedback_trace(max) "
}



set tpd_clk_arrival_at_le_fedback_pll_at_zero(nom) [ expr  { $tpd_clockout_and_trace(nom) +  $pll_normal_mode_phase_offset  } ]
}

    ######################################################################################

    ######################################################################################

if   { $ddr_mode == "non-dqs"  } {








set tSCW_left      [ expr { round (   - $clock_period*0.5           \
+ $tpd_sysclk_to_pin(max)     \
+ $rtd_trace_delay_total      \
+ $tAC                        \
+ $tpd_dq(max)                     \
+ $tSU                        \
) } ]

set tSCW_right     [ expr { round (   - $clock_period*0.5           \
+ $tHP                        \
+ $tpd_sysclk_to_pin(min)      \
+ $rtd_trace_delay_total_MIN  \
- $tAC                      \
+ $tpd_dq(min)                 \
- $tHOLD                    \
) } ]



set  tSCW_left  [::ddr::utils::adjust_for_cas_latency $cas_latency $tSCW_left 2.5 $clock_period]
set  tSCW_right [::ddr::utils::adjust_for_cas_latency $cas_latency $tSCW_right 2.5 $clock_period]

set tSCW_mid [expr {round( ($tSCW_left + $tSCW_right)/2.0)}]
if { $pre_compile_mode && $ddr_timing_args(override_capture)==0 } {

set chosen_capture_cycle [expr {floor( 1.0*$tSCW_mid/$clock_period )} ]
set chosen_capture_phase [expr {round(360.0*(1.0*$tSCW_mid/$clock_period-$chosen_capture_cycle)	)} ]
::ddr::utils::assert { 0<= $chosen_capture_phase && $chosen_capture_phase < 360 } {$chosen_capture_phase}
} else {

if { $pre_compile_mode } {
set chosen_capture_phase $ddr_timing_args(capture_clock_phase)
} else {
set chosen_capture_phase $settings_array(chosen_capture_phase)
}

set chosen_capture_cycle [expr {round( 1.0*$tSCW_mid/$clock_period - $chosen_capture_phase/360.0 )} ]
#puts "chosen_capture_cycle:$chosen_capture_cycle chosen_capture_phase:$chosen_capture_phase tSCW_left:$tSCW_left tSCW:$tSCW_right"
}
::ddr::utils::assert {abs($chosen_capture_cycle + $chosen_capture_phase/360.0 - 1.0*$tSCW_mid/$clock_period) <= 0.5} {$chosen_capture_cycle $tSCW_mid $chosen_capture_phase {$chosen_capture_cycle + $chosen_capture_phase/360.0 - 1.0*$tSCW_mid/$clock_period}} 




if { $pre_compile_mode && $ddr_timing_args(override_resynch) ==0 } {






set chosen_resynch_cycle [expr {round($chosen_capture_cycle +1) }]
if {  0 <= $chosen_capture_phase && $chosen_capture_phase < 90 } {

set chosen_resynch_phase 0
} elseif { 90 <= $chosen_capture_phase && $chosen_capture_phase < 180 } {

set chosen_resynch_phase 180
} elseif { 180<= $chosen_capture_phase && $chosen_capture_phase < 270 } {

set chosen_resynch_phase 180
} elseif { 270<= $chosen_capture_phase && $chosen_capture_phase < 360 } {

set chosen_resynch_cycle [expr {round($chosen_resynch_cycle +1) }]
set chosen_resynch_phase 0
} else {
::ddr::utils::assert {0} {$chosen_capture_phase} "out of range"
}

} else {


if { $pre_compile_mode } {	
message_out Warn "The read data resynchronisation settings used were selected by the user (Manual Timing tab). Resynchronisation Cycle parameter is not checked."

set  chosen_resynch_clock           $override_resynch_clock
set  chosen_resynch_edge            $override_resynch_edge
set  chosen_resynch_cycle           $override_resynch_cycle
if { $ddr_timing_args(resynch_clock) == "dedicated" } {
set  chosen_resynch_phase $ddr_timing_args(resynch_clock_phase)
} else {
set  chosen_resynch_phase [clk_override_to_phase  $chosen_resynch_clock  $chosen_resynch_edge]
}		
} else {

}
}


set chosen_capture_clock_time [expr {round( $clock_period*($chosen_capture_phase/360.0 + $chosen_capture_cycle) )} ]
puts "DDDDDDD chosen_capture_cycle:$chosen_capture_cycle chosen_capture_phase:$chosen_capture_phase"
puts "DDDDDDDD chosen_capture_clock_time:chosen_capture_clock_time"
set ${margins_array_name}(read_capture_su)     [expr {$chosen_capture_clock_time - $tSCW_left}]
set ${margins_array_name}(read_capture_hold)   [expr {$tSCW_right - $chosen_capture_clock_time}]

if { $pre_compile_mode } {
set chosen_resynch_clock "clk"
if { $chosen_resynch_phase!=0 && $chosen_resynch_phase != 180 } {
message_out Crit "DDR MegaCore Function only supports a resynchronisation clock with a phase of 0 or 180 degrees in Non-DQS mode. Found a setting of $chosen_resynch_phase overiding to 0 degrees."
set chosen_resynch_phase 0			
}
if { $chosen_resynch_phase == 0 } {
set chosen_resynch_edge "rising"
} elseif { $chosen_resynch_phase == 180 } {
set chosen_resynch_edge "falling"
} else {
::ddr::utils::assert {0} {$chosen_resynch_phase} "Unreachable"
}

set gCONNECT_CAPTURE_CLK_TO 		"dedicated"
set capture_phase 					$chosen_capture_phase
set gRESYNCH_CYCLE					$chosen_resynch_cycle
set gRESYNCH_EDGE 					$chosen_resynch_edge
set resynch_phase 					$chosen_resynch_phase
set gINTER_RESYNCH 					false;
set gCONNECT_RESYNCH_CLK_TO 		$chosen_resynch_clock



set dqs_cram_cyclone                ""
set dqs_delay_cyclone               ""
set dqs_phase_stratix               ""

set postamble_phase                 ""
set gCONNECT_POSTAMBLE_CLK_TO       ""
set gPOSTAMBLE_EDGE                 ""
set gPOSTAMBLE_CYCLE                ""
set gINTER_POSTAMBLE                ""
set gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS     ""
}

} else {
        ######################################################################################

        ######################################################################################
if { $show_progress } { puts    $post_summary_id    " >> Start of DQS-mode code" }

if { $post_compile_mode } {

set     i_first     $best_dqs_shift_setting
set     i_last      $i_first



if { $family_is_stratix2 } {
set     t_shift_ideal       0
}

} else {

if { $family_is_stratix } {
# Stratix   0= "72 deg" 1= "90 deg"     "0deg" TBD !!!
set     i_first     0
set     i_last      1

} elseif { $family_is_stratix2 } {
set     i_first     0
set     i_last      0









foreach {varname value} [::ddr::s2dqs::choose_dqs_settings $clock_period] {
set $varname $value
}

set     t_shift_ideal              [ expr { $clock_period * ( $gSTRATIXII_DQS_PHASE / 36000.0 ) } ]







} elseif { $family_is_cyclone || $family_is_cyclone2 }  {

set     i_first     $cram_first
set     i_last      $cram_last
}

}

if { $lists_need_to_be_cleared } {


unset     quartus_dqs_delay_  
unset     Delta_MAX_                                         
unset     Delta_MIN_                                          
unset     Slack_SU_                                            
unset     Slack_HOLD_                                        
unset     RTD_resynch_                                
unset     RTD_resynch_MIN_                         
unset     tSRW_left_                      
unset     tSRW_right_                     
unset     degrees_SRW_left_                      
unset      cycles_SRW_left_                              
unset     degrees_SRW_left_offset_        
unset     display_SRW_left_              
unset     degrees_SRW_right_                     
unset      cycles_SRW_right_               
unset     degrees_SRW_right_offset_       
unset     display_SRW_right_               
unset     degrees_SRW_centre_                           
unset      cycles_SRW_centre_                         
unset     degrees_SRW_centre_offset_         
unset     display_SRW_centre_                            
unset     display_degrees_SRW_half_width_ 

if { $enable_postamble } {         
unset     tSPAW_left_                      
unset     tSPAW_right_                     
unset     degrees_SPAW_left_                      
unset      cycles_SPAW_left_                            
unset     degrees_SPAW_left_offset_        
unset     display_SPAW_left_               
unset     degrees_SPAW_right_                      
unset      cycles_SPAW_right_              
unset     degrees_SPAW_right_offset_       
unset     display_SPAW_right_               
unset     degrees_SPAW_centre_                            
unset      cycles_SPAW_centre_                           
unset     degrees_SPAW_centre_offset_            
unset     display_SPAW_centre_                            
unset     display_degrees_SPAW_half_width_ 
unset     postamble_enable_hold_to_postamble_slack_  
unset     postamble_enable_setup_to_noise_slack_     

}

}
for { set  i  $i_first } { $i  <= $i_last } { incr i 1 } {

if { $show_progress } { puts    $post_summary_id    " >> i-first/last loop" }




if { $family_is_stratix } {

if { $pre_compile_mode } {
if { $i == 0 } { 
# i=0: "72 degrees"
set     t_shift_ideal              [ expr { $clock_period / 5.0 } ]
} else {
# i=1:  "90 degrees"
set     t_shift_ideal              [ expr { $clock_period / 4.0 } ]
}
} else {
set     t_shift_ideal       0
}



if  { $dll_ref_clock_switched_off_during_reads } {
set t_dll_dynamic_phase_jitter  0
} else {
if        { $clock_period <= $tCK_limit_dll_jitter_low } {
set t_dll_dynamic_phase_jitter     $t_dll_dynamic_phase_jitter_small 
} elseif { $clock_period <= $tCK_limit_dll_jitter_high  } {
set t_dll_dynamic_phase_jitter     $t_dll_dynamic_phase_jitter_medium
} else {
set t_dll_dynamic_phase_jitter     $t_dll_dynamic_phase_jitter_large
}
}
set     t_dll_offset                [ expr { $t_dll_phase_error + $t_dll_dynamic_phase_jitter } ]
set     tSHIFT90                    [ expr { $t_shift_ideal  +  $t_dll_offset } ]
set     tSHIFT90_MIN                [ expr { $t_shift_ideal  -  $t_dll_offset } ]


if { $tSHIFT90 > $dll_shift_limit } {
set     tSHIFT90    $dll_shift_limit

# message_out NOTE "Stratix DLL upper shift limit reached"
}
if { $tSHIFT90_MIN > $dll_shift_limit } {
set     tSHIFT90_MIN    $dll_shift_limit
}
} elseif { $family_is_stratix2  } {





set     t_dll_offset                $t_dll_phase_error 
set     tSHIFT90                    [ expr { $t_shift_ideal  +  $t_dll_offset } ]
set     tSHIFT90_MIN                [ expr { $t_shift_ideal  -  $t_dll_offset } ]

} elseif { $family_is_cyclone }  {

if { $pre_compile_mode } {

set     tSHIFT90                    [ lindex $tSHIFT90_         $i    ]    
set     tSHIFT90_MIN                [ lindex $tSHIFT90_MIN_     $i    ] 
} else {

set     tSHIFT90                    0    
set     tSHIFT90_MIN                0
}      
} elseif { $family_is_cyclone2 } { 
if { $pre_compile_mode } {

set     tSHIFT90                    [ lindex $tSHIFT90_         $i    ]    
set     tSHIFT90_MIN                [ lindex $tSHIFT90_MIN_     $i    ] 
} else {

set     tSHIFT90                    0    
set     tSHIFT90_MIN                0
}      
} else {
error "Unknown family"
}



set     Delta_MAX                   [ expr      { $tpd_dqs_capture(max)     + $tSHIFT90      - $tpd_dq(max)  }      ]
set     Delta_MIN                   [ expr      { $tpd_dqs_capture(min) + $tSHIFT90_MIN  - $tpd_dq(min)  }  ]
set     Slack_SU                    [ expr     {  round ( $Delta_MIN   - $tDQSQ   - $tSKEW    - $tSU       ) }      ]
set     Slack_HOLD                  [ expr     {  round ( $tQH         - $tHOLD   - $tSKEW    - $Delta_MAX ) }      ]




    ##############################

    ##############################


set RTD_to_dqs_pin(max) [expr {				\
$tpd_sysclk_to_pin(max)				\
+ $rtd_trace_delay_total				\
+ $tDQSCK								}]

set RTD_to_dqs_pin(min) [expr {				\
$tpd_sysclk_to_pin(min)				\
+ $rtd_trace_delay_total_MIN			\
- $tDQSCK								}]

if { 1 } {

set RTD_to_ncapture_reg_clk(max) [expr {	\
$RTD_to_dqs_pin(max)					\
+ $tpd_dqs_capture(max)					\
+ $tSHIFT90								}]

set RTD_to_ncapture_reg_clk(min) [expr {	\
$RTD_to_dqs_pin(min)					\
+ $tpd_dqs_capture(min)					\
+ $tSHIFT90_MIN							}]



set RTD_resynch(max) [expr {				\
$RTD_to_ncapture_reg_clk(max)			\
+ $micro_tCO							\
+ $tpd_routing_rega_to_regb_resynch(max)\
+ $tJITTER_pll							\
+ $tSU									}]

set RTD_resynch(min) [expr {				\
$RTD_to_ncapture_reg_clk(min)			\
+ $micro_tCO_MIN						\
+ $tpd_routing_rega_to_regb_resynch(min)\
- $tJITTER_pll							\
- $tHOLD								}]
} else {

set    RTD_to_ncapture_reg_clk(max)      [ expr {    $RTD_to_dqs_pin(max)   \
+ $tpd_dqs_capture(max)          \
+ $tSHIFT90        } ]

set    RTD_to_ncapture_reg_clk(min)  [ expr {    $RTD_to_dqs_pin(min)   \
+ $tpd_dqs_capture(min)          \
+ $tSHIFT90_MIN        } ]



set   RTD_to_resynch_reg(max)            [ expr {    $RTD_to_ncapture_reg_clk(max)        \
+ $micro_tCO        \
+ $tpd_routing_rega_to_regb_resynch(max)    } ]

set   RTD_to_resynch_reg(min)        [ expr {    $RTD_to_ncapture_reg_clk(min)        \
+ $micro_tCO_MIN        \
+ $tpd_routing_rega_to_regb_resynch(min)      } ]



set     RTD_resynch(max)                 [ expr  {   $RTD_to_resynch_reg(max)     \
+ $t_dc_distortion_at_fpga_output_pin \
+ $tJITTER_pll        \
+ $tSU      } ]

set     RTD_resynch(min)             [ expr  {   $RTD_to_resynch_reg(min)     \
- $t_dc_distortion_at_fpga_output_pin \
- $tJITTER_pll        \
- $tHOLD      } ]

}    


set     tSRW_left               [expr     {  $RTD_resynch(max)      } ]
set     tSRW_right              [expr     {  $RTD_resynch(min)  + $clock_period     }  ]


if { $enable_postamble } {


if { [ string match cyclone $family ] } {

foreach minmax {min max} {
set RTD_to_reset_reg_clk($minmax)         $RTD_to_ncapture_reg_clk($minmax)
set dqspin_to_pa_reg($minmax) [expr {$tpd_dqs_capture($minmax) + $tSHIFT90 } ]
}
} elseif { $family == "stratix"  } {
foreach minmax {min max} {
set RTD_to_reset_reg_clk($minmax) [expr {$RTD_to_dqs_pin($minmax) + $tpd_dqspin_2_undelayed($minmax) + $tpd_undelayed_out_to_resetreg_clk($minmax) }]
set dqspin_to_pa_reg($minmax) [expr {$tpd_dqspin_2_undelayed($minmax) + $tpd_undelayed_out_to_resetreg_clk($minmax) }]
}
} else {

foreach minmax {min max} {
set RTD_to_reset_reg_clk($minmax) [expr {$RTD_to_dqs_pin($minmax) + $tpd_dqspin_2_dqsclk_minus_tshift($minmax) + $tSHIFT90 + $tpd_andgate_to_resetreg_clk($minmax) }]
set exp {$tpd_dqspin_2_dqsclk_minus_tshift($minmax) + $tSHIFT90 + $tpd_andgate_to_resetreg_clk($minmax) }
#puts "dqspin_to_pa_reg($minmax): $exp" 
#puts "dqspin_to_pa_reg($minmax): [subst $exp]" 
set dqspin_to_pa_reg($minmax) [expr $exp]
}
}




	############ Postamble Control ###############


if { 1 } {



set tSPAW_right_expr { \
$tpd_sysclk_to_pin(min) * $max_delay_scaling_under_MIN_conditions + \
$rtd_trace_delay_total_MIN + \
$dqspin_to_pa_reg(min) * $max_delay_scaling_under_MIN_conditions + \
-1 * $tDQSCK + \
-1 * $tpd_reset_control(min) + \
-1 * $micro_tCO + \
0.95 * $clock_period }
set tSPAW_right [expr $tSPAW_right_expr]

set tSPAW_left_expr { \
$tpd_sysclk_to_pin(max) + \
$rtd_trace_delay_total  + \
$dqspin_to_pa_reg(max) +\
$tDQSCK + \
-1 * $tpd_reset_control(max) * $min_delay_scaling_under_MAX_conditions + \
-1 * $micro_tCO * $min_delay_scaling_under_MAX_conditions + \
0.05 * $clock_period }
set tSPAW_left [expr $tSPAW_left_expr]

} else { 


set     t_lastbutone_dqs_neg_edge_under_MAX_conditions      $RTD_to_reset_reg_clk(max)


set     t_last_dqs_neg_edge_under_MIN_conditions  [ expr {                                          \
$RTD_to_reset_reg_clk(min)      +  $min_dqs_period_at_end_of_burst_under_MAX_conditions     \
} ]

		################################

		################################



set tSPAW_left  [ expr  {                                                                                                   \
$t_lastbutone_dqs_neg_edge_under_MAX_conditions - (                                                                     \
$min_delay_scaling_under_MAX_conditions * (                         \
$micro_tCO              \
+ $tpd_reset_control(max) \
- $t_reset_release_hold ) ) } ] 



set tSPAW_right  [ expr  {                                                                                                  \
$t_last_dqs_neg_edge_under_MIN_conditions  - (                                                                          \
$max_delay_scaling_under_MIN_conditions * (                             \
$micro_tCO              \
+ $tpd_reset_control(min) \
+ $t_reset_release_setup  ))} ] 
}

}


        ######################################################################

# 'zero' (ie "cycle 0 + 0 degrees") is defined as the neg edge of DQS at CL 2.5 with RTD at zero (with dqs shift at zero as well)





        ######################################################################

set tSRW_left  [::ddr::utils::adjust_for_cas_latency $cas_latency $tSRW_left 2.5 $clock_period]
set tSRW_right [::ddr::utils::adjust_for_cas_latency $cas_latency $tSRW_right 2.5 $clock_period]

if { $enable_postamble } {
set tSPAW_left [::ddr::utils::adjust_for_cas_latency $cas_latency $tSPAW_left 2.5 $clock_period]
set tSPAW_right [::ddr::utils::adjust_for_cas_latency $cas_latency $tSPAW_right 2.5 $clock_period]
}

if { $fedback_clock_mode } {

set     tSRW_left        [ expr  { round (   $tSRW_left   + $clock_period )  } ]
set     tSRW_right       [ expr  { round (   $tSRW_right  + $clock_period )  } ]
if { $enable_postamble } {
set     tSPAW_left       [ expr  { round (   $tSPAW_left  + $clock_period )  } ]
set     tSPAW_right      [ expr  { round (   $tSPAW_right + $clock_period )  } ]
}
}


        ######################################################################

        ######################################################################
        #### LHS / RHS
set     degrees_SRW_left        [ expr  { round ( ( $tSRW_left  / ($clock_period + 0.0 ) ) * 360 )  } ]
set     degrees_SRW_right       [ expr  { round ( ( $tSRW_right / ($clock_period + 0.0 ) ) * 360 )  } ]

                #### LHS / RHS
if { $enable_postamble } {
set     degrees_SPAW_left        [ expr  { round (  ( $tSPAW_left  / ($clock_period + 0.0 ) ) * 360 )  } ]
set     degrees_SPAW_right       [ expr  { round (  ( $tSPAW_right / ($clock_period + 0.0 ) ) * 360 )  } ]
}


if { $temp_fix_for_postamble_low_freq } {
if { $degrees_SRW_left  < 0 } { 
set  degrees_SRW_left   -1 
if { $debug_loop_on } { message_out d "SRW left negative at setting $i " }
}
if { $degrees_SRW_right < 0 } { 
set  degrees_SRW_right  1
if { $debug_loop_on } { message_out d "SRW right negative at setting $i " }
}

if { $enable_postamble } {
if { $degrees_SPAW_left  < 0 } { 
set  degrees_SPAW_left   -1 
if { $debug_loop_on } { message_out d "SPAW left negative at setting $i " }
}
if { $degrees_SPAW_right  < 0 } { 
set  degrees_SPAW_right   1 
if { $debug_loop_on } { message_out d "SPAW right negative at setting $i " }
}
}
}

        #####################################################################################################

        #### Centre / half-width
set     degrees_SRW_centre      [ expr  { round (  ( $degrees_SRW_right + $degrees_SRW_left  ) / 2.0    ) } ]
set     degrees_SRW_half_width  [ expr  { round (  ( $degrees_SRW_right - $degrees_SRW_left  ) / 2.0    ) } ]

if { $degrees_SRW_half_width > 0 } {
set display_degrees_SRW_half_width     $degrees_SRW_half_width
} else {
#message_out error "No SRW"
set display_degrees_SRW_half_width      -9
}



#set     tSRW_half_width         [ expr  { round (  ( $degrees_SRW_half_width * $clock_period ) / 360.0  )  } ]



#   .. and Format the postion as "cycles + degrees" EG.  1+120   meaning 1-cycle and 120 degrees
set      cycles_SRW_left            [ get_cycles  $degrees_SRW_left    Resynch_left]
set     degrees_SRW_left_offset     [ expr { $degrees_SRW_left    -    ( $cycles_SRW_left   * 360 ) } ]
set     display_SRW_left            "$cycles_SRW_left+$degrees_SRW_left_offset" 

set      cycles_SRW_right           [ get_cycles  $degrees_SRW_right   Resynch_right]
set     degrees_SRW_right_offset    [ expr { $degrees_SRW_right   -    ( $cycles_SRW_right  * 360 ) } ]
set     display_SRW_right           "$cycles_SRW_right+$degrees_SRW_right_offset" 

set      cycles_SRW_centre          [ get_cycles  $degrees_SRW_centre  Resynch_centre]
set     degrees_SRW_centre_offset   [ expr { $degrees_SRW_centre  -    ( $cycles_SRW_centre * 360 ) } ]
set     display_SRW_centre          "$cycles_SRW_centre+$degrees_SRW_centre_offset"


if { $enable_postamble } {   
        ######################################################################

        ######################################################################

        #### Centre / half-width
set     degrees_SPAW_centre      [ expr  { round (  ( $degrees_SPAW_right + $degrees_SPAW_left  ) / 2.0    ) } ]
set     degrees_SPAW_half_width  [ expr  { round (  ( $degrees_SPAW_right - $degrees_SPAW_left  ) / 2.0    ) } ]

if { $degrees_SPAW_half_width > 0 } {
set display_degrees_SPAW_half_width     $degrees_SPAW_half_width
} else {
#message_out error "No SPAW"
set display_degrees_SPAW_half_width      -9
}



#   .. and Format the postion as "cycles + degrees" EG.  1+120   meaning 1-cycle and 120 degrees
set      cycles_SPAW_left            [ get_cycles  $degrees_SPAW_left    Postamble_left]
set     degrees_SPAW_left_offset     [ expr { $degrees_SPAW_left    -    ( $cycles_SPAW_left   * 360 ) } ]
set     display_SPAW_left            "$cycles_SPAW_left+$degrees_SPAW_left_offset" 

set      cycles_SPAW_right           [ get_cycles  $degrees_SPAW_right   Postamble_right]
set     degrees_SPAW_right_offset    [ expr { $degrees_SPAW_right   -    ( $cycles_SPAW_right  * 360 ) } ]
set     display_SPAW_right           "$cycles_SPAW_right+$degrees_SPAW_right_offset" 

set      cycles_SPAW_centre          [ get_cycles  $degrees_SPAW_centre  Postamble-centre]
set     degrees_SPAW_centre_offset   [ expr { $degrees_SPAW_centre  -    ( $cycles_SPAW_centre * 360 ) } ]
set     display_SPAW_centre          "$cycles_SPAW_centre+$degrees_SPAW_centre_offset"
}




if { $family_is_cyclone } {
set     quartus_dqs_delay [lindex $tSHIFT90_NOM_  $i]
} elseif { $family_is_cyclone2 } { 
set     quartus_dqs_delay   "$i"
} else {      
set     quartus_dqs_delay   ""
}

if { $enable_postamble } {

        #############################################################

        #############################################################


        ##################################################################

        ##################################################################













if { $family_is_cyclone } {


set postamble_enable_hold_to_postamble_slack    [ expr {  round   (         \
$micro_tCO                   \
+  $tpd_reset_reg_to_enable(min)     \
- $tHOLD                                          \
- $t_skew_global_small                            \
) } ] 
} elseif { $family_is_stratix } {

set     t_total_reset_register_path(max)      [ expr {                       \
$tpd_dqs_int_to_undelayed_out(max)       \
+  $tpd_undelayed_out_to_resetreg_clk(max)  \
+  $micro_tCO                          \
+  $tpd_reset_reg_to_enable(max)            \
} ]

set     t_total_reset_register_path(min)      [ expr {                       \
$tpd_dqs_int_to_undelayed_out(min)       \
+  $tpd_undelayed_out_to_resetreg_clk(min)  \
+  $micro_tCO_MIN                          \
+  $tpd_reset_reg_to_enable(min)            \
} ]           




set postamble_enable_hold_to_postamble_slack    [ expr {  round (                           \
$t_total_reset_register_path(min) - (                                                 \
( $max_delay_scaling_under_MIN_conditions *  $tpd_dqs_int_to_ncapture_reg_clk_minus_tshift(min) )  \
+ $tHOLD                                    \
+ $tSHIFT90                                 \
)                                                 \
) } ]


            ####################################################################

if { $debug_equations && ( ! $silent_mode ) } {
puts $equ_id    "\n n_halfdq= $n_halfdq:  Stratix Postamble Enable Path \n"

puts $equ_id    " tpd_dqspin_2_dqsclk_minus_tshift(min)     $tpd_dqspin_2_dqsclk_minus_tshift(min)"
puts $equ_id    " tpd_dqspin_2_undelayed(min)               $tpd_dqspin_2_undelayed(min) "     
puts $equ_id    " scaling_to_estimate_dqs_int               $scaling_to_estimate_dqs_int "
puts $equ_id    " tpd_pseudo_dqs_pin_to_int(min)            $tpd_pseudo_dqs_pin_to_int(min) "
puts $equ_id    " tpd_dqs_int_to_undelayed_out(min)         $tpd_dqs_int_to_undelayed_out(min) "
puts $equ_id    " tpd_dqsclk_2_ddio(min)                    $tpd_dqsclk_2_ddio(min) "
puts $equ_id    " tpd_dqs_capture(min)                      $tpd_dqs_capture(min) "

puts $equ_id    " === HOLD Slack ==="
puts $equ_id    " postamble_enable_hold_to_postamble_slack                  $postamble_enable_hold_to_postamble_slack "
puts $equ_id    "        t_total_reset_register_path(min)                       $t_total_reset_register_path(min) "
puts $equ_id    "                tpd_dqs_int_to_undelayed_out(min)                      $tpd_dqs_int_to_undelayed_out(min) "
puts $equ_id    "                tpd_undelayed_out_to_resetreg_clk(min)                 $tpd_undelayed_out_to_resetreg_clk(min) "
puts $equ_id    "                micro_tCO_MIN                                          $micro_tCO_MIN "
puts $equ_id    "                tpd_reset_reg_to_enable(min)                           $tpd_reset_reg_to_enable(min) "
puts $equ_id    "        tpd_dqs_int_to_ncapture_reg_clk_minus_tshift(min)      $tpd_dqs_int_to_ncapture_reg_clk_minus_tshift(min) "
puts $equ_id    "        max_delay_scaling_under_MIN_conditions                 $max_delay_scaling_under_MIN_conditions "
puts $equ_id    "        tSHIFT90                                               $tSHIFT90 "
puts $equ_id    "        tHOLD                                                  $tHOLD "


}

} elseif {$family_is_stratix2} {



set postamble_enable_hold_to_postamble_slack    0

} elseif { $family_is_cyclone2 } {
set postamble_enable_hold_to_postamble_slack    [expr { round (
$tpd_andgate_to_resetreg_clk(min)
+ $tpd_resetreg_to_capture(min)
- $tpd_andgate_to_capturereg_clk(min)
) } ]
} else {
::ddr::utils::assert {0} {$family} "Unknown family"
}

        ##################################################################


        ##################################################################









set    t_must_disable_by    [ expr { ( $tRPST_MIN * $clock_period ) + $t_rise_to_vref } ] 

if { $family_is_cyclone } {
set postamble_enable_setup_to_noise_slack      [ expr { round (         \
$t_must_disable_by                          \
- ( $micro_tCO  + $tpd_reset_reg_to_enable(max) )   \
- $t_skew_global_small                        \
) } ]

} elseif { $family_is_cyclone2 } {
set postamble_enable_setup_to_noise_slack [expr { round (
$t_must_disable_by
+ $tpd_andgate_to_capturereg_clk(max)
- $tpd_andgate_to_resetreg_clk(max)
- $tpd_resetreg_to_capture(max)
- $micro_tCO
) } ]
} elseif { $family_is_stratix }  {

set postamble_enable_setup_to_noise_slack      [ expr { round (                 \
( $tpd_dqs_int_to_ncapture_reg_clk_minus_tshift(max) * $min_delay_scaling_under_MAX_conditions )  \
+ $tSHIFT90_MIN                                      \
+ $t_must_disable_by                                \
- $t_total_reset_register_path(max)                      \
) } ]

} elseif { $family_is_stratix2} {

set postamble_enable_setup_to_noise_slack      [ expr { round (        \
+ $t_must_disable_by                        \
- $tpd_andgate_to_resetreg_clk(max)         \
- $tpd_resetreg_to_andgate(max)             \
) } ]
} else {
error "auk_postamble_enable_su_hold_equations: unknown family"
}


}


        ###############################
        ##  Add to table
        ###############################





lappend     quartus_dqs_delay_              $quartus_dqs_delay 
lappend     Delta_MAX_                      $Delta_MAX                    
lappend     Delta_MIN_                      $Delta_MIN                    
lappend     Slack_SU_                       $Slack_SU                     
lappend     Slack_HOLD_                     $Slack_HOLD                   


            ###### Resynch #######################################
lappend     RTD_resynch_                    $RTD_resynch(max)             
lappend     RTD_resynch_MIN_                $RTD_resynch(min)         

lappend     tSRW_left_                      $tSRW_left
lappend     tSRW_right_                     $tSRW_right

lappend     degrees_SRW_left_               $degrees_SRW_left        
lappend      cycles_SRW_left_                $cycles_SRW_left              
lappend     degrees_SRW_left_offset_        $degrees_SRW_left_offset
lappend     display_SRW_left_               $display_SRW_left

lappend     degrees_SRW_right_              $degrees_SRW_right        
lappend      cycles_SRW_right_               $cycles_SRW_right 
lappend     degrees_SRW_right_offset_       $degrees_SRW_right_offset
lappend     display_SRW_right_              $display_SRW_right 

lappend     degrees_SRW_centre_             $degrees_SRW_centre                
lappend      cycles_SRW_centre_              $cycles_SRW_centre                
lappend     degrees_SRW_centre_offset_      $degrees_SRW_centre_offset       
lappend     display_SRW_centre_             $display_SRW_centre               
lappend     display_degrees_SRW_half_width_ $display_degrees_SRW_half_width

            ###### Postamble Control #######################################



if { $enable_postamble } {
lappend     tSPAW_left_                      $tSPAW_left
lappend     tSPAW_right_                     $tSPAW_right

lappend     degrees_SPAW_left_               $degrees_SPAW_left        
lappend      cycles_SPAW_left_                $cycles_SPAW_left              
lappend     degrees_SPAW_left_offset_        $degrees_SPAW_left_offset
lappend     display_SPAW_left_               $display_SPAW_left

lappend     degrees_SPAW_right_              $degrees_SPAW_right        
lappend      cycles_SPAW_right_               $cycles_SPAW_right 
lappend     degrees_SPAW_right_offset_       $degrees_SPAW_right_offset
lappend     display_SPAW_right_              $display_SPAW_right 

lappend     degrees_SPAW_centre_             $degrees_SPAW_centre                
lappend      cycles_SPAW_centre_              $cycles_SPAW_centre                
lappend     degrees_SPAW_centre_offset_      $degrees_SPAW_centre_offset       
lappend     display_SPAW_centre_             $display_SPAW_centre               
lappend     display_degrees_SPAW_half_width_ $display_degrees_SPAW_half_width

            #### Postamble enable
lappend     postamble_enable_hold_to_postamble_slack_  $postamble_enable_hold_to_postamble_slack
lappend     postamble_enable_setup_to_noise_slack_     $postamble_enable_setup_to_noise_slack
}


} 



if { $pre_compile_mode } {

if { ! $fedback_clock_mode } {

for { set  i  $i_first } { $i  <= $i_last } { incr i 1 } {


set     resynch_can_use_0_deg           -9
set     resynch_can_use_90_deg          -9
set     resynch_can_use_180_deg         -9
set     resynch_can_use_270_deg         -9

set     postamble_can_use_0_deg         -9
set     postamble_can_use_90_deg        -9
set     postamble_can_use_180_deg       -9
set     postamble_can_use_270_deg       -9





        ##############################

        ##############################

if { ( [lindex $degrees_SRW_right_offset_ $i] > [lindex $degrees_SRW_left_offset_ $i] ) } {

if { ( [lindex $degrees_SRW_left_offset_ $i] < 90 ) && ( 90 < [lindex $degrees_SRW_right_offset_ $i] )  } {
set     resynch_can_use_90_deg      [ lindex $cycles_SRW_left_ $i ]
} 
if { ( [lindex $degrees_SRW_left_offset_ $i] < 180 ) && ( 180 < [lindex $degrees_SRW_right_offset_ $i] )  } {
set     resynch_can_use_180_deg      [ lindex $cycles_SRW_left_ $i ]
} 
if { ( [lindex $degrees_SRW_left_offset_ $i] < 270 ) && ( 270 < [lindex $degrees_SRW_right_offset_ $i] )  } {
set     resynch_can_use_270_deg      [ lindex $cycles_SRW_left_ $i ]
} 

} else {

set     resynch_can_use_0_deg           [ lindex $cycles_SRW_right_ $i ]

if { ( [lindex $degrees_SRW_left_offset_ $i] < 90  )  } {
set     resynch_can_use_90_deg      [ lindex $cycles_SRW_left_ $i ]
} 
if { ( [lindex $degrees_SRW_left_offset_ $i] < 180  )  } {
set     resynch_can_use_180_deg      [ lindex $cycles_SRW_left_ $i ]
} 
if { ( [lindex $degrees_SRW_left_offset_ $i] < 270  )  } {
set     resynch_can_use_270_deg      [ lindex $cycles_SRW_left_ $i ]
} 

if { ( 90 < [lindex $degrees_SRW_right_offset_ $i]  )  } {
set     resynch_can_use_90_deg      [ lindex $cycles_SRW_right_ $i ]
} 
if { ( 180 < [lindex $degrees_SRW_right_offset_ $i]  )  } {
set     resynch_can_use_180_deg      [ lindex $cycles_SRW_right_ $i ]
} 
if { ( 270 < [lindex $degrees_SRW_right_offset_ $i]  )  } {
set     resynch_can_use_270_deg      [ lindex $cycles_SRW_right_ $i ]
} 
}


if { $enable_postamble } {     

        ##############################

        ##############################
if { ( [lindex $degrees_SPAW_right_offset_ $i] > [lindex $degrees_SPAW_left_offset_ $i] ) } {

if { ( [lindex $degrees_SPAW_left_offset_ $i] < 90 ) && ( 90 < [lindex $degrees_SPAW_right_offset_ $i] )  } {
set     postamble_can_use_90_deg      [ lindex $cycles_SPAW_left_ $i ]
} 
if { ( [lindex $degrees_SPAW_left_offset_ $i] < 180 ) && ( 180 < [lindex $degrees_SPAW_right_offset_ $i] )  } {
set     postamble_can_use_180_deg      [ lindex $cycles_SPAW_left_ $i ]
} 
if { ( [lindex $degrees_SPAW_left_offset_ $i] < 270 ) && ( 270 < [lindex $degrees_SPAW_right_offset_ $i] )  } {
set     postamble_can_use_270_deg      [ lindex $cycles_SPAW_left_ $i ]
} 

} else {

set     postamble_can_use_0_deg           [ lindex $cycles_SPAW_right_ $i ]

if { ( [lindex $degrees_SPAW_left_offset_ $i] < 90  )  } {
set     postamble_can_use_90_deg      [ lindex $cycles_SPAW_left_ $i ]
} 
if { ( [lindex $degrees_SPAW_left_offset_ $i] < 180  )  } {
set     postamble_can_use_180_deg      [ lindex $cycles_SPAW_left_ $i ]
} 
if { ( [lindex $degrees_SPAW_left_offset_ $i] < 270  )  } {
set     postamble_can_use_270_deg      [ lindex $cycles_SPAW_left_ $i ]
} 

if { ( 90 < [lindex $degrees_SPAW_right_offset_ $i]  )  } {
set     postamble_can_use_90_deg      [ lindex $cycles_SPAW_right_ $i ]
} 
if { ( 180 < [lindex $degrees_SPAW_right_offset_ $i]  )  } {
set     postamble_can_use_180_deg      [ lindex $cycles_SPAW_right_ $i ]
} 
if { ( 270 < [lindex $degrees_SPAW_right_offset_ $i]  )  } {
set     postamble_can_use_270_deg      [ lindex $cycles_SPAW_right_ $i ]
} 
}


lappend     postamble_can_use_0_deg_        $postamble_can_use_0_deg
lappend     postamble_can_use_90_deg_       $postamble_can_use_90_deg
lappend     postamble_can_use_180_deg_      $postamble_can_use_180_deg
lappend     postamble_can_use_270_deg_      $postamble_can_use_270_deg

}    





lappend     resynch_can_use_0_deg_          $resynch_can_use_0_deg
lappend     resynch_can_use_90_deg_         $resynch_can_use_90_deg
lappend     resynch_can_use_180_deg_        $resynch_can_use_180_deg
lappend     resynch_can_use_270_deg_        $resynch_can_use_270_deg


}


}

##############################

##############################

set best_so_far ""
set best_index ""

for { set  i  $i_first } { $i  <= $i_last } { incr i 1 } {
set badness 0
set penalty ""


set     Slack_SU        [ lindex $Slack_SU_    $i ]
set     Slack_HOLD      [ lindex $Slack_HOLD_  $i ]

if { $Slack_SU < 200 } { 
set p [expr {200-$Slack_SU}] 
incr badness $p
append penalty "capture-su $p "
}
if { $Slack_HOLD < 200 } {
set p  [expr {200-$Slack_HOLD}] 
incr badness $p
append penalty "capture-hold $p "
}

if { $Slack_SU < 0 || $Slack_HOLD < 0 } {
incr badness 100
append penalty "capture -ve 100 "
}


set p    [expr {int( abs($Slack_SU - $Slack_HOLD)/10)}]
incr badness $p
append penalty "capture-balance $p "


if { $family_is_cyclone2 } {
set rwindow [expr {[lindex $tSRW_right_ $i] - [lindex $tSRW_left_ $i]}]




if { $rwindow < 500 } {
set p [expr {int ((500 - $rwindow)/2) } ]
incr badness $p
append penalty "resync-window $p"
} 
if { $rwindow < 1000 } {
set p [expr {int ((1000 - $rwindow)/2) } ]
incr badness $p
append penalty "resync-window-half $p"
}


if { $rwindow < 50 } {
incr badness 100 
append penalty "resync -ve 100"
}
}



if { $enable_postamble } {
set paen_hold   [ lindex $postamble_enable_hold_to_postamble_slack_   $i ]
set paen_setup  [ lindex $postamble_enable_setup_to_noise_slack_      $i ]

if { $paen_setup < 200 } { 
set p [expr {200-$paen_setup}] 
incr badness $p
append penalty "PA-su $p "
}
if { $family_is_stratix || $family_is_cyclone } {

if { $paen_hold < 200 } {
set p [expr {200-$paen_hold}]
incr badness $p
append penalty "pa-hold $p "
}
}
if { $paen_setup < 0 || $paen_hold < 0} {
incr badness 50
append penalty "pa -ve 50 "
}
}

#puts "dqsopt:$i badness $badness $penalty"


if {$best_so_far=="" || $badness < $best_so_far } {
#puts "dqsopt:$i >>> new badness $badness"
set best_so_far $badness
set best_index $i
}
}

set best_dqs_shift_setting $best_index

if {  $silent_mode == "false" } {
if { $family_is_stratix || ( $family == "cyclone" ) } { 

set col_hdr1_    "                      Safe Resynch Window (SRW)          Safe Postamble control Window(SPAW)    ( 0,1,2 = 'cycle'   -9 = cant use)          Postamble"
set col_hdr2_    "   Read Slack (ps)    _____SRW (cycles+degrees)_____     _____SPAW (cycles+degrees)_____       ____Resynch_____    ___Postamble____        Enable slack (ps)"
set col_hdr3_    "   Setup   Hold       LHS     RHS      Centre(Offset)    LHS       RHS       Centre(Offset)    0   90  180  270    0   90  180  270         SU     HOLD"
set col_hdr4_    "   -----   ----       ---     ---      -------------     ---       ---       -------------     ----------------    ----------------        ----    ----     "

if { [ string match cyclone $family ] } {
set quaver    [ format "%6s" $quartus_version ]
set col_hdr1    " Delay     QuartusII"
set col_hdr2    " chain     $quaver  "  
set col_hdr3    " control   DQS delay" 
set col_hdr4    " -------   ---------"  
} else {
set col_hdr1    "        QuartusII"
set col_hdr2    "        DQS phase"
set col_hdr3    "        setting  "
set col_hdr4    "        ---------"  
}
puts $out_id    ""
puts $out_id    "$col_hdr1 $col_hdr1_"
puts $out_id    "$col_hdr2 $col_hdr2_"
puts $out_id    "$col_hdr3 $col_hdr3_"
puts $out_id    "$col_hdr4 $col_hdr4_"
puts $out_id    ""

for { set  i  $i_first } { $i  <= $i_last } { incr i 1 } {

if { $i == $best_dqs_shift_setting } {
set point   " >>"
} else {
set point   "   "
}

if {  (( [ string match cyclone $family ] ) && ( [lindex $Slack_SU_ $i] >= $min_acceptable_read_margin ) &&  ( [lindex $Slack_HOLD_ $i]>= $min_acceptable_read_margin ) ) || ( [ string match stratix $family ] ) } {
if { [ string match cyclone $family ] } { 
set cram_summary_line_a   [ format " $point  %2d   \"%4dps\" " $i [lindex $quartus_dqs_delay_   $i ] ]
} else {
set cram_summary_line_a   [ format " $point   \"%10s\" "  [lindex $quartus_dqs_phase_   $i ] ]
}

if { $enable_postamble } { 
set cram_summary_line_b   [ format "\
%4d    %4d    %6s -> %-6s    %-6s (%3d)    %6s -> %-6s    %-6s (%3d)      \
%2d  %2d  %2d  %2d      %2d  %2d  %2d  %2d        \
%5d    %5d" \
[lindex $Slack_SU_                          $i]   \
[lindex $Slack_HOLD_                        $i]   \
[lindex $display_SRW_left_                  $i]   \
[lindex $display_SRW_right_                 $i]   \
[lindex $display_SRW_centre_                $i]   \
[lindex $display_degrees_SRW_half_width_    $i]   \
[lindex $display_SPAW_left_                 $i]   \
[lindex $display_SPAW_right_                $i]   \
[lindex $display_SPAW_centre_               $i]   \
[lindex $display_degrees_SPAW_half_width_   $i]   \
[lindex $resynch_can_use_0_deg_             $i]   \
[lindex $resynch_can_use_90_deg_            $i]   \
[lindex $resynch_can_use_180_deg_           $i]   \
[lindex $resynch_can_use_270_deg_           $i]   \
[lindex $postamble_can_use_0_deg_           $i]   \
[lindex $postamble_can_use_90_deg_          $i]   \
[lindex $postamble_can_use_180_deg_         $i]   \
[lindex $postamble_can_use_270_deg_         $i]   \
[lindex $postamble_enable_setup_to_noise_slack_     $i]   \
[lindex $postamble_enable_hold_to_postamble_slack_  $i]   \
]

} else {

set cram_summary_line_b   [ format "\
%4d    %4d    %6s -> %-6s    %-6s (%3d)    --   --   ---N/A---  --  --  ---      \
%2d  %2d  %2d  %2d      --  N/A --       \
n/a      n/a  " \
[lindex $Slack_SU_                          $i]   \
[lindex $Slack_HOLD_                        $i]   \
[lindex $display_SRW_left_                  $i]   \
[lindex $display_SRW_right_                 $i]   \
[lindex $display_SRW_centre_                $i]   \
[lindex $display_degrees_SRW_half_width_    $i]   \
\
[lindex $resynch_can_use_0_deg_             $i]   \
[lindex $resynch_can_use_90_deg_            $i]   \
[lindex $resynch_can_use_180_deg_           $i]   \
[lindex $resynch_can_use_270_deg_           $i]   \
]

}
## debug only
set cram_summary_line_c   [ format " \
%5.0f   %5.0f  %5.0f   %5.0f " \
[lindex $RTD_resynch_MIN_               $i]   \
[lindex $RTD_resynch_                   $i]   \
[lindex $tSRW_left_                     $i]   \
[lindex $tSRW_right_                    $i]   \
]






set cram_summary_line_c  ""

puts $out_id    "$cram_summary_line_a $cram_summary_line_b $cram_summary_line_c"
}

}
puts $out_id        "  "



}
}


if { $family_is_cyclone } {
set     dqs_cram_cyclone                $best_dqs_shift_setting
set     dqs_delay_cyclone          "[ lindex $quartus_dqs_delay_  $best_dqs_shift_setting ]"

set     dqs_phase_stratix   ""
} elseif { $family_is_cyclone2 } {
set     dqs_cram_cyclone                $best_dqs_shift_setting
set     dqs_delay_cyclone          $best_dqs_shift_setting

set     dqs_phase_stratix   ""
} else {
# Stratix (ie. "72 degrees" or "90 degrees"  etc..
set     dqs_phase_stratix           [ lindex $quartus_dqs_phase_  $best_dqs_shift_setting ]

set     dqs_cram_cyclone    ""
set     dqs_delay_cyclone   ""
}






    ##################
    ### calc outputs        - this algorithm just crudely picks the phases at the opt read point
    ###################










set     tSRW_left                       [ lindex $tSRW_left_   $best_dqs_shift_setting ]
set     tSRW_right                      [ lindex $tSRW_right_  $best_dqs_shift_setting ]








if { $fedback_clock_mode } {

    ######################## Fedback RESYNC ################################


set     gCONNECT_RESYNCH_CLK_TO     "dedicated"

set     gRESYNCH_EDGE               "rising"



set     gINTER_RESYNCH            "true"        ;

if { 0 } {
if { $resynch_phase > 180.0 } {
set     gINTER_RESYNCH            "true"
} else {
set     gINTER_RESYNCH            "false"
}
}


set     mid_resync                 [expr  {  ( $tSRW_left + $tSRW_right ) / 2.0 } ]
set     tpd_absolute_required_setting_of_fedback_clock_pll_resync       [expr  {  $mid_resync  - $tpd_clk_arrival_at_le_fedback_pll_at_zero(nom) } ]

set     tpd_required_setting_of_fedback_clock_pll_resync           [ ::ddr::utils::wrap_to_clock_period  $tpd_absolute_required_setting_of_fedback_clock_pll_resync $clock_period ]
set     cycles_of_fedback_clock_pll_resync                         [ ::ddr::utils::get_cycles_from_ps     $tpd_absolute_required_setting_of_fedback_clock_pll_resync $clock_period ]

set     fedback_resynch_phase_at_pll        [expr { int ( 360.0 * $tpd_required_setting_of_fedback_clock_pll_resync / $clock_period ) } ]

message_out Warn "You must set the fed-back clock PLL phase for the resynch clock to ${fedback_resynch_phase_at_pll} degrees relative to the zero-compensated clock."


set     resynch_phase           ${fedback_resynch_phase_at_pll}

        ######################## Fedback POSTamble ################################
if { $enable_postamble } {

set     gCONNECT_POSTAMBLE_CLK_TO     "dedicated"
set     gPOSTAMBLE_EDGE               "rising"
set     gPOSTAMBLE_CYCLE              [ lindex  $cycles_SPAW_centre_        $best_dqs_shift_setting ]
set     gINTER_POSTAMBLE            "false"

set     mid_postamble                 [expr  {  ( $tSPAW_left + $tSPAW_right ) / 2.0 } ]
set     tpd_absolute_required_setting_of_fedback_clock_pll_postamble       [expr  {  $mid_postamble  - $tpd_clk_arrival_at_le_fedback_pll_at_zero(nom) } ]

set     tpd_required_setting_of_fedback_clock_pll_postamble           [ ::ddr::utils::wrap_to_clock_period  $tpd_absolute_required_setting_of_fedback_clock_pll_postamble $clock_period ]
set     cycles_of_fedback_clock_pll_postamble                         [ ::ddr::utils::get_cycles_from_ps    $tpd_absolute_required_setting_of_fedback_clock_pll_postamble $clock_period ]


set     fedback_postamble_phase_at_pll        [expr { int ( 360.0 * $tpd_required_setting_of_fedback_clock_pll_postamble / $clock_period ) } ]

message_out Warn "You must set the fedback-clock PLL phase for the postamble clock to ${fedback_postamble_phase_at_pll} degrees relative to the zero-compensated clock."


set     postamble_phase           ${fedback_postamble_phase_at_pll}

}


} else {

















puts "Resync Window: $tSRW_left $tSRW_right"
::ddr::phasesel::draw_window [list $tSRW_left $tSRW_right] $clock_period
set tSRW_win [list $tSRW_left $tSRW_right]

set existing_phases [::ddr::phasesel::find_phase $tSRW_win {0 90 180 270} $clock_period]


set x [list]
foreach phase $existing_phases {
set su [lindex $phase 2]
set hold [lindex $phase 3]
::ddr::utils::assert {$su >= 0} {$su}
::ddr::utils::assert {$hold >= 0} {$su}
set ratio [expr { ($su+1.0)/($hold +1.0) }]
if { $ratio < 1.0 } {set ratio [expr {1.0/$ratio}] }
if { $ratio < 5.0 } {
lappend x $phase
} else {
}
}
set existing_phases $x
if { [llength $existing_phases] > 0 } {

set resync_choice [lindex $existing_phases 0] ;
set clk_and_edge [::ddr::utils::degrees_to_clock_and_edge [lindex $resync_choice 1]]
set gCONNECT_RESYNCH_CLK_TO [lindex $clk_and_edge 0]
set gRESYNCH_EDGE           [lindex $clk_and_edge 1]
} else {

set resync_choice [::ddr::phasesel::middle_of_win $tSRW_win $clock_period] ;
set gCONNECT_RESYNCH_CLK_TO "dedicated"
set gRESYNCH_EDGE           "rising"
}

set gRESYNCH_CYCLE [lindex $resync_choice 0]
set resynch_phase [expr {round([lindex $resync_choice 1])}]
if { $resynch_phase < 180 } {
set gINTER_RESYNCH "false"
} else {
set gINTER_RESYNCH "true"
}

if { $family_is_cyclone && $gCONNECT_RESYNCH_CLK_TO == "dedicated" } {

message_out Warn "Dedicated resynch phase required (${resynch_phase}deg): example instance does not support this for Cyclone (second PLL required)."
}

if { $enable_postamble } { 











set     tSPAW_left                       [ lindex $tSPAW_left_   $best_dqs_shift_setting ]
set     tSPAW_right                      [ lindex $tSPAW_right_  $best_dqs_shift_setting ]

puts "tSPAW_left  is $tSPAW_left"
puts "tSPAW_right is $tSPAW_right"

set tSPAW_win [list $tSPAW_left $tSPAW_right]


#puts "Possible edges:[::ddr::phasesel::find_phase $tSPAW_win {0 90 180 270} $clock_period]"
#puts "Max slack: [::ddr::phasesel::max_slack $tSPAW_win $clock_period]"
set postamble_choice [::ddr::phasesel::max_slack $tSPAW_win $clock_period]

if { $tSPAW_left >= $tSPAW_right} {
message_out warn "Unable to meet postamble timing. See Timing Estimates window for more information."
}

if { [lindex $postamble_choice 2] < 0 || [lindex $postamble_choice 3] < 0 } {



set postamble_choice [::ddr::phasesel::middle_of_win $tSPAW_win $clock_period]

puts "Need to use pll: no clock edge in window"
if { [ string match cyclone $family ] && ! ${family_is_cyclone2} } {
message_out warn "Dedicated postamble phase required ([lindex $postamble_choice 1]deg): example instance does not support this for Cyclone (second PLL required)."
set     all_system_timing_met  "false"
append  timing_failures "Limited PLL resources (postamble), "
} else {
message_out warn "You must set the PLL phase for the postamble clock to [lindex $postamble_choice 1]degrees relative to the system clock."
}

}

set postamble_phase [lindex $postamble_choice 1]
set gPOSTAMBLE_CYCLE [lindex $postamble_choice 0]

switch -- $postamble_phase {
0 {
set     gCONNECT_POSTAMBLE_CLK_TO       "clk"
set     gPOSTAMBLE_EDGE                 "rising"
}
90 {
set     gCONNECT_POSTAMBLE_CLK_TO       "write_clk"
set     gPOSTAMBLE_EDGE                 "falling"
}
180 {
set     gCONNECT_POSTAMBLE_CLK_TO       "clk"
set     gPOSTAMBLE_EDGE                 "falling"
}
270 {
set     gCONNECT_POSTAMBLE_CLK_TO       "write_clk"
set     gPOSTAMBLE_EDGE                 "rising"
}
default {
set     gCONNECT_POSTAMBLE_CLK_TO       "dedicated"
set     gPOSTAMBLE_EDGE                 "rising"
}
}


if { $postamble_phase > 180.0 } {
set     gINTER_POSTAMBLE            "true"
} else {
set     gINTER_POSTAMBLE            "false"
}
} ;

} ;

}


if { ! [info exists handle_override_values ] } {
set handle_override_values      true






if { ! [info exists use_override_resynch]           }  { set  use_override_resynch          "false" }
if { ! [info exists use_override_postamble]         }  { set  use_override_postamble        "false" }

if { ! [info exists override_resynch_was_used]      }  { set  override_resynch_was_used     "false" }
if { ! [info exists override_postamble_was_used]    }  { set  override_postamble_was_used   "false" }


if { ( $use_override_resynch ) || ( $override_resynch_was_used ) } {
message_out Warn "The read data resynchronisation settings used were selected by the user (Manual Timing tab)."
}
if { ( $use_override_postamble ) || ( $override_postamble_was_used ) } {
message_out Warn "The postamble control settings used were selected by the user (Manual Timing tab)."
}

if { $pre_compile_mode } { 
if { $use_override_resynch } {
set  value_of_override_resynch_was_used      "true"

if { $fedback_clock_mode } {

set  chosen_resynch_clock           "dont_care"
set  chosen_resynch_edge            "dont_care"
set  chosen_resynch_cycle           9999
set  chosen_resynch_phase           9999

set  chosen_fb_resynch_cycle        $override_resynch_cycle
set  chosen_fb_resynch_phase        $ddr_timing_args(fedback_resync_clock_phase)
} else {
set  chosen_resynch_clock           $override_resynch_clock
set  chosen_resynch_edge            $override_resynch_edge
set  chosen_resynch_cycle           $override_resynch_cycle
if { $ddr_timing_args(resynch_clock) == "dedicated" } {
set  chosen_resynch_phase $ddr_timing_args(resynch_clock_phase)
} else {
set  chosen_resynch_phase           [clk_override_to_phase  $chosen_resynch_clock  $chosen_resynch_edge]
}

set  chosen_fb_resynch_cycle        9999
set  chosen_fb_resynch_phase        9999
}
} else {
set  value_of_override_resynch_was_used      "false"
if { $fedback_clock_mode } {

set  chosen_resynch_clock           "dont_care"
set  chosen_resynch_edge            "dont_care"
set  chosen_resynch_cycle           9999
set  chosen_resynch_phase           9999

set  chosen_fb_resynch_cycle        $cycles_of_fedback_clock_pll_resync 
set  chosen_fb_resynch_phase        $fedback_resynch_phase_at_pll
} else {

set  chosen_resynch_clock           $gCONNECT_RESYNCH_CLK_TO
set  chosen_resynch_edge            $gRESYNCH_EDGE
set  chosen_resynch_cycle           $gRESYNCH_CYCLE
set  chosen_resynch_phase           $resynch_phase

set  chosen_fb_resynch_cycle        9999
set  chosen_fb_resynch_phase        9999
}
}

if { $ddr_mode == "normal" } {
if { $enable_postamble  } {
if { $use_override_postamble } {
set  value_of_override_postamble_was_used      "true"

if { $fedback_clock_mode } {

set  chosen_postamble_clock           "dont_care"
set  chosen_postamble_edge            "dont_care"
set  chosen_postamble_cycle           9999
set  chosen_postamble_phase           9999

set  chosen_fb_postamble_cycle        $override_postamble_cycle 
set  chosen_fb_postamble_phase        $ddr_timing_args(postamble_clock_phase)
} else {
set  chosen_postamble_clock     $override_postamble_clock
set  chosen_postamble_edge      $override_postamble_edge
set  chosen_postamble_cycle     $override_postamble_cycle
if { $chosen_postamble_clock == "dedicated" } {
set  chosen_postamble_phase $ddr_timing_args(postamble_clock_phase)
} else {
set  chosen_postamble_phase     [clk_override_to_phase  $chosen_postamble_clock  $chosen_postamble_edge]
}

set  chosen_fb_postamble_cycle        9999 
set  chosen_fb_postamble_phase        9999
}
} else {
set  value_of_override_postamble_was_used      "false"

if { $fedback_clock_mode } {
set  chosen_postamble_clock           "dont_care"
set  chosen_postamble_edge            "dont_care"
set  chosen_postamble_cycle           9999
set  chosen_postamble_phase           9999

set  chosen_fb_postamble_cycle         $cycles_of_fedback_clock_pll_postamble
set  chosen_fb_postamble_phase         $fedback_postamble_phase_at_pll
} else {
set  chosen_postamble_clock     $gCONNECT_POSTAMBLE_CLK_TO
set  chosen_postamble_edge      $gPOSTAMBLE_EDGE
set  chosen_postamble_cycle     $gPOSTAMBLE_CYCLE

set  chosen_postamble_phase     [clk_override_to_phase  $chosen_postamble_clock  $chosen_postamble_edge]

set  chosen_fb_postamble_cycle        9999 
set  chosen_fb_postamble_phase        9999
}
}
}
} else {
}


}



}





if { $pre_compile_mode } {
set     index_of_best_dqs_shift_setting     $best_dqs_shift_setting
} else {
set     index_of_best_dqs_shift_setting     0
}


set     tSRW_left                       [ lindex $tSRW_left_    $index_of_best_dqs_shift_setting ]
set     tSRW_right                      [ lindex $tSRW_right_   $index_of_best_dqs_shift_setting ]

if { $fedback_clock_mode } {
#puts "t_absolute_actual_setting_of_fedback_clock_pll_resync:"
set     t_absolute_actual_setting_of_fedback_clock_pll_resync      [expr {  ( $chosen_fb_resynch_cycle   +   ( $chosen_fb_resynch_phase / 360.0 ) ) * $clock_period } ]

#puts "t_resynch_fb_at_MIN:"
set     t_resynch_fb_at_MIN             [ expr {  $tpd_clockout_and_trace(min) + $pll_normal_mode_phase_offset + $t_absolute_actual_setting_of_fedback_clock_pll_resync } ]
#puts "t_resynch_fb_at_MAX:"
set     t_resynch_fb_at_MAX             [ expr {  $tpd_clockout_and_trace(max) + $pll_normal_mode_phase_offset + $t_absolute_actual_setting_of_fedback_clock_pll_resync } ]

#puts "t_resynch_setup_slack:"
set     t_resynch_setup_slack           [ expr { round ( $t_resynch_fb_at_MAX  -  $tSRW_left - $pll_normal_mode_phase_error ) } ]
#puts "t_resynch_hold_slack:"
set     t_resynch_hold_slack            [ expr { round ( $tSRW_right -  $t_resynch_fb_at_MIN - $pll_normal_mode_phase_error ) } ]

} else {



set     total_resynch_phase             [ expr {  ( $chosen_resynch_cycle * 360 ) + $chosen_resynch_phase } ]
set     t_resynch                       [ expr { ( $total_resynch_phase * $clock_period ) / 360.0 } ]

set     t_resynch_setup_slack           [ expr { round ( $t_resynch  -  $tSRW_left ) } ]
set     t_resynch_hold_slack            [ expr { round ( $tSRW_right -  $t_resynch ) } ]
}
##!!! puts ">>>>>>  t_resynch_setup_slack= $t_resynch_setup_slack"
set   ${margins_array_name}(read_resync_hold)     $t_resynch_hold_slack
set   ${margins_array_name}(read_resync_su)       $t_resynch_setup_slack


if { $enable_postamble } {

set     tSPAW_left                      [ lindex $tSPAW_left_   $index_of_best_dqs_shift_setting ]
set     tSPAW_right                     [ lindex $tSPAW_right_  $index_of_best_dqs_shift_setting ]

if { $fedback_clock_mode } {

set     t_absolute_actual_setting_of_fedback_clock_pll_postamble      [expr {  ( $chosen_fb_postamble_cycle   +   ( $chosen_fb_postamble_phase / 360.0 ) ) * $clock_period } ]

set     t_postamble_fb_at_MIN             [ expr {  $tpd_clockout_and_fedback_trace(min) + $pll_normal_mode_phase_offset + $t_absolute_actual_setting_of_fedback_clock_pll_postamble } ]
set     t_postamble_fb_at_MAX             [ expr {  $tpd_clockout_and_fedback_trace(max) + $pll_normal_mode_phase_offset + $t_absolute_actual_setting_of_fedback_clock_pll_postamble } ]

set     t_postamble_setup_slack           [ expr { round ( $t_postamble_fb_at_MAX  -  $tSPAW_left - $pll_normal_mode_phase_error ) } ]
set     t_postamble_hold_slack            [ expr { round ( $tSPAW_right -  $t_postamble_fb_at_MIN - $pll_normal_mode_phase_error ) } ]

set   ${margins_array_name}(read_postamble_control_hold)        $t_postamble_hold_slack
set   ${margins_array_name}(read_postamble_control_su)          $t_postamble_setup_slack

} else {

        ##################


set     total_postamble_phase           [ expr {  ( $chosen_postamble_cycle * 360 ) + $chosen_postamble_phase } ]
set     t_postamble                     [ expr { ( $total_postamble_phase * $clock_period ) / 360.0 } ]

set   ${margins_array_name}(read_postamble_control_hold)        [ expr { round ( $tSPAW_right -  $t_postamble ) } ]
set   ${margins_array_name}(read_postamble_control_su)          [ expr { round ( $t_postamble  -  $tSPAW_left ) } ]

} 


set   ${margins_array_name}(read_postamble_enable_hold)        [ lindex $postamble_enable_hold_to_postamble_slack_     $index_of_best_dqs_shift_setting ]
set   ${margins_array_name}(read_postamble_enable_su)          [ lindex $postamble_enable_setup_to_noise_slack_        $index_of_best_dqs_shift_setting ]



}


set ${margins_array_name}(read_capture_su)     [ lindex $Slack_SU_      $index_of_best_dqs_shift_setting ]
set ${margins_array_name}(read_capture_hold)   [ lindex $Slack_HOLD_    $index_of_best_dqs_shift_setting ]


}
    #################### END 'normal' mode ##############


set     lists_need_to_be_cleared        true
}



######################################################################################################

######################################################################################################


set     big_num             999999
set     default_bad_pin     999             ;#"na"

set     worst_read_capture_su_SLACK             $big_num
set     worst_read_capture_hold_SLACK           $big_num
set     worst_read_capture_su_PIN               $default_bad_pin
set     worst_read_capture_hold_PIN             $default_bad_pin

set     worst_read_resync_su_SLACK              $big_num
set     worst_read_resync_hold_SLACK            $big_num
set     worst_read_resync_su_PIN                $default_bad_pin
set     worst_read_resync_hold_PIN              $default_bad_pin

set     worst_read_postamble_enable_su_SLACK        $big_num
set     worst_read_postamble_enable_hold_SLACK      $big_num
set     worst_read_postamble_enable_su_PIN          $default_bad_pin
set     worst_read_postamble_enable_hold_PIN        $default_bad_pin

set     worst_read_postamble_control_su_SLACK        $big_num
set     worst_read_postamble_control_hold_SLACK      $big_num
set     worst_read_postamble_control_su_PIN          $default_bad_pin
set     worst_read_postamble_control_hold_PIN        $default_bad_pin


set     read_capture_su_failed                  false
set     read_capture_hold_failed                false

set     read_resync_su_failed                   false
set     read_resync_hold_failed                 false

set     read_postamble_enable_su_failed         false
set     read_postamble_enable_hold_failed       false

set     read_postamble_control_su_failed        false
set     read_postamble_control_hold_failed      false


foreach margin_array_name  $ddr_timings_list_of_margins {





set     halfdq_pin_number   [::ddr::utils::string_chop_left $margin_array_name  ${base_margins_array_name}]


if { $debug_post } { puts "     >>> extract margins (array= ${margin_array_name} , pin= ${halfdq_pin_number} )" }



set     read_capture_su     [ get_ddr_path_info  $margin_array_name "read_capture_su"   ]
set     read_capture_hold   [ get_ddr_path_info  $margin_array_name "read_capture_hold" ]

if { $debug_post } { puts "     >>>          read_capture_su=    $read_capture_su"   } 
if { $debug_post } { puts "     >>>          read_capture_hold=  $read_capture_hold" }


if { $read_capture_su < $global_min_acceptable_margin } {

if { $read_capture_su_failed == false } {
set     read_capture_su_failed     true
set     all_system_timing_met      false
lappend timing_failures     "Capture-SU, "
}
if { $debug_post } { puts "+++++ add to list '..read_capture_su_failures' (su= $read_capture_su) pin= $halfdq_pin_number" }
lappend     list_of_halfdq_pin_read_capture_su_failures     $halfdq_pin_number
}
if { $read_capture_su < $worst_read_capture_su_SLACK } {
set worst_read_capture_su_SLACK     $read_capture_su
set worst_read_capture_su_PIN       $halfdq_pin_number
}

if { $read_capture_hold < $global_min_acceptable_margin } {

if { $read_capture_hold_failed == false } {
set     read_capture_hold_failed     true
set     all_system_timing_met       false
lappend timing_failures     "Capture-HOLD, "
}
lappend     list_of_halfdq_pin_read_capture_hold_failures     $halfdq_pin_number
}
if { $read_capture_hold < $worst_read_capture_hold_SLACK } {
set worst_read_capture_hold_SLACK     $read_capture_hold
set worst_read_capture_hold_PIN       $halfdq_pin_number
}



if { $ddr_mode == "normal" } {


set     read_resync_su      [get_ddr_path_info  $margin_array_name "read_resync_su"   ]
set     read_resync_hold    [get_ddr_path_info  $margin_array_name "read_resync_hold" ]

if { $read_resync_su < $global_min_acceptable_margin } {

if { $read_resync_su_failed == false } {
set     read_resync_su_failed       true
set     all_system_timing_met       false
lappend timing_failures             "Resync-SU, "
}
lappend     list_of_halfdq_pin_read_resync_su_failures     $halfdq_pin_number
}
if { $read_resync_su < $worst_read_resync_su_SLACK } {
set worst_read_resync_su_SLACK     $read_resync_su
set worst_read_resync_su_PIN       $halfdq_pin_number
}

if { $read_resync_hold < $global_min_acceptable_margin } {

if { $read_resync_hold_failed == false } {
set     read_resync_hold_failed       true
set     all_system_timing_met       false
lappend timing_failures             "Resync-HOLD, "
}
lappend     list_of_halfdq_pin_read_resync_hold_failures     $halfdq_pin_number
}
if { $read_resync_hold < $worst_read_resync_hold_SLACK } {
set worst_read_resync_hold_SLACK     $read_resync_hold
set worst_read_resync_hold_PIN       $halfdq_pin_number
}


if { $enable_postamble } {


set     read_postamble_enable_su      [get_ddr_path_info  $margin_array_name "read_postamble_enable_su"   ]
set     read_postamble_enable_hold    [get_ddr_path_info  $margin_array_name "read_postamble_enable_hold" ]

if { $read_postamble_enable_su < $global_min_acceptable_margin } {

if { $read_postamble_enable_su_failed == false } {
set     read_postamble_enable_su_failed       true
set     all_system_timing_met       false
lappend timing_failures             "Posamble-Enable-SU, "
}
lappend     list_of_halfdq_pin_read_postamble_enable_su_failures     $halfdq_pin_number
}
if { $read_postamble_enable_su < $worst_read_postamble_enable_su_SLACK } {
set worst_read_postamble_enable_su_SLACK     $read_postamble_enable_su
set worst_read_postamble_enable_su_PIN       $halfdq_pin_number
}

if { $read_postamble_enable_hold < $global_min_acceptable_margin } {

if { $read_postamble_enable_hold_failed == false } {
set     read_postamble_enable_hold_failed       true
set     all_system_timing_met       false
lappend timing_failures             "Posamble-Enable-HOLD, "
}
lappend     list_of_halfdq_pin_read_postamble_enable_hold_failures     $halfdq_pin_number
}
if { $read_postamble_enable_hold < $worst_read_postamble_enable_hold_SLACK } {
set worst_read_postamble_enable_hold_SLACK     $read_postamble_enable_hold
set worst_read_postamble_enable_hold_PIN       $halfdq_pin_number
}




set     read_postamble_control_su      [get_ddr_path_info  $margin_array_name "read_postamble_control_su"   ]
set     read_postamble_control_hold    [get_ddr_path_info  $margin_array_name "read_postamble_control_hold" ]

if { $read_postamble_control_su < $global_min_acceptable_margin } {

if { $read_postamble_control_su_failed == false } {
set     read_postamble_control_su_failed       true
set     all_system_timing_met       false
lappend timing_failures             "Posamble-Control-SU, "
}
lappend     list_of_halfdq_pin_read_postamble_control_su_failures     $halfdq_pin_number
}
if { $read_postamble_control_su < $worst_read_postamble_control_su_SLACK } {
set worst_read_postamble_control_su_SLACK     $read_postamble_control_su
set worst_read_postamble_control_su_PIN       $halfdq_pin_number
}

if { $read_postamble_control_hold < $global_min_acceptable_margin } {

if { $read_postamble_control_hold_failed == false } {
set     read_postamble_control_hold_failed       true
set     all_system_timing_met       false
lappend timing_failures             "Posamble-Control-HOLD, "
}
lappend     list_of_halfdq_pin_read_postamble_control_hold_failures     $halfdq_pin_number
}
if { $read_postamble_control_hold < $worst_read_postamble_control_hold_SLACK } {
set worst_read_postamble_control_hold_SLACK     $read_postamble_control_hold
set worst_read_postamble_control_hold_PIN       $halfdq_pin_number
}



}

}

if { $dump_all_margins && ( ! $silent_mode ) } {
puts  $margins_id   "$margin_array_name"
puts  $margins_id   "   read_capture_su                 $read_capture_su"
puts  $margins_id   "   read_capture_hold               $read_capture_hold"
if { $ddr_mode == "normal" } {
puts  $margins_id   "   read_resync_su                  $read_resync_su"
puts  $margins_id   "   read_resync_hold                $read_resync_hold"
if { $enable_postamble } {
puts  $margins_id   "   read_postamble_enable_su        $read_postamble_enable_su"
puts  $margins_id   "   read_postamble_enable_hold      $read_postamble_enable_hold"

puts  $margins_id   "   read_postamble_control_su       $read_postamble_control_su"
puts  $margins_id   "   read_postamble_control_hold     $read_postamble_control_hold"
}
}
}

}
if { [info exists list_of_halfdq_pin_read_capture_su_failures ] } {
set     num_failures_read_capture_su        [llength  $list_of_halfdq_pin_read_capture_su_failures ]
} else {
set     num_failures_read_capture_su        0
}
if { [info exists list_of_halfdq_pin_read_capture_hold_failures] } {
set     num_failures_read_capture_hold      [llength  $list_of_halfdq_pin_read_capture_hold_failures ]
} else {
set     num_failures_read_capture_hold      0
}



if { [info exists list_of_halfdq_pin_read_resync_su_failures] } {
set     num_failures_read_resync_su         [llength  $list_of_halfdq_pin_read_resync_su_failures ]
} else {
set     num_failures_read_resync_su         0
}
if { [info exists list_of_halfdq_pin_read_resync_hold_failures] } {
set     num_failures_read_resync_hold       [llength  $list_of_halfdq_pin_read_resync_hold_failures ]
} else {
set     num_failures_read_resync_hold       0
}



if { $enable_postamble } {

if { [info exists list_of_halfdq_pin_read_postamble_enable_su_failures] } {
set     num_failures_read_postamble_enable_su       [llength  $list_of_halfdq_pin_read_postamble_enable_su_failures ]
} else {
set     num_failures_read_postamble_enable_su       0
}
if { [info exists list_of_halfdq_pin_read_postamble_enable_hold_failures] } {
set     num_failures_read_postamble_enable_hold       [llength  $list_of_halfdq_pin_read_postamble_enable_hold_failures ]
} else {
set     num_failures_read_postamble_enable_hold       0
}



if { [info exists list_of_halfdq_pin_read_postamble_control_su_failures] } {
set     num_failures_read_postamble_control_su       [llength  $list_of_halfdq_pin_read_postamble_control_su_failures ]
} else {
set     num_failures_read_postamble_control_su       0
}
if { [info exists list_of_halfdq_pin_read_postamble_control_hold_failures] } {
set     num_failures_read_postamble_control_hold       [llength  $list_of_halfdq_pin_read_postamble_control_hold_failures ]
} else {
set     num_failures_read_postamble_control_hold       0
}
}


if {  $pre_compile_mode  } {

##########################

##########################

set resync_postamble_info       "false"     ;

set resynch_desc    "Datapath Config (resynch_clk): Captured read data will be resynchronised with the"
set postamble_desc  "Datapath Config (postamble_clk): Postamble register preset will be released on the"

set fb_desc1    "output of a PLL in 'Normal' mode (set to"
set fb_desc2                                               "degrees) in cycle"

if { $fedback_clock_mode } {
if { $resync_postamble_info } {
message_out note     "$resynch_desc $fb_desc1 $fedback_resynch_phase_at_pll $fb_desc2 $chosen_resynch_cycle"
if   { ( $ddr_mode == "normal" ) && ( $enable_postamble ) } {
message_out note   "$postamble_desc $fb_desc1 $fedback_postamble_phase_at_pll $fb_desc2 $chosen_postamble_cycle"
}
}
} else {
if { $resync_postamble_info } {
if {  $family == "cyclone"  } {

if { $chosen_resynch_clock != "dedicated" } {
message_out note   "$resynch_desc $chosen_resynch_edge edge of $chosen_resynch_clock, in cycle $chosen_resynch_cycle"
}
if   { ( $ddr_mode == "normal" ) && ( $enable_postamble ) } {
if { $chosen_postamble_clock != "dedicated" } {
message_out note   "$postamble_desc $chosen_postamble_edge edge of $chosen_postamble_clock, in cycle $chosen_postamble_cycle"
}
}
} else {

if { $chosen_resynch_clock == "dedicated" } {
set resynch_clock_description "a dedicated PLL phase of $resynch_phase degrees"
} else {
set resynch_clock_description   $chosen_resynch_clock
}
message_out note   "$resynch_desc $chosen_resynch_edge edge of $resynch_clock_description, in cycle $chosen_resynch_cycle"

if   { ( $ddr_mode == "normal" ) && ( $enable_postamble ) } {
if { $chosen_postamble_clock == "dedicated" } {
set postamble_clock_description "a dedicated PLL phase of $postamble_phase degrees"
} else {
set postamble_clock_description   $chosen_postamble_clock
}
message_out note    "$postamble_desc $chosen_postamble_edge edge of $postamble_clock_description, in cycle $chosen_postamble_cycle"
}

}
}


if { $ddr_mode == "non-dqs" } {
message_out N   $note_nondqs_tan_will_do_resync 
}
}

}




if { $show_progress } { puts    $post_summary_id    " >> Start of auk_output_results.tcl" } 



proc real_pin { i }  {
global  pin_prefix
global  family_is_stratix
global  family_is_stratix2
global  array_of_dq_pins

set name_of_dqhalfpin_side(stratix0)    "dq_captured_rising"
set name_of_dqhalfpin_side(stratix1)    "dq_captured_falling"
set name_of_dqhalfpin_side(cyclone0)    "input_cell_L\[0\]"
set name_of_dqhalfpin_side(cyclone1)    "input_cell_H\[0\]"

set pin_num         [expr { int ( floor ( $i / 2 ) ) } ]
set which_side      [expr { int ( $i % 2 ) }  ]

if { $family_is_stratix || $family_is_stratix2 } {
set family_type "stratix"
} else {
set family_type "cyclone"
}
set name_index      "${family_type}${which_side}"
set side_name       $name_of_dqhalfpin_side($name_index)

return     " associated with pin '$array_of_dq_pins($pin_num)'  ( variation port 'dq([format "%d" ${pin_num} ])', '${side_name}')"

}

if { $pre_compile_mode } {
if { $ddr_mode=="normal" && $fedback_clock_mode } {
set chosen_fb_resync1_cycle $chosen_fb_resynch_cycle
set chosen_fb_resync2_cycle $chosen_fb_resynch_cycle







set clock_source_to_sysclk(min) -380
set clock_source_to_sysclk(max) 100

set clock_source_to_pin(min) [expr {$clock_source_to_sysclk(min) + $tpd_sysclk_to_pin(min)}]
set clock_source_to_pin(max) [expr {$clock_source_to_sysclk(max) + $tpd_sysclk_to_pin(max)}]

set fbc_cl_late  [expr {$clock_source_to_pin(max) + $ddr_timing_args(tpd_clockfeedback_trace_nom) * (1 + 0.01 * $ddr_timing_args(board_pcb_delay_var_percent)) }]
set fbc_cl_early [expr {$clock_source_to_pin(min) + $ddr_timing_args(tpd_clockfeedback_trace_nom) * (1 - 0.01* $ddr_timing_args(board_pcb_delay_var_percent)) }]
set dqs_cl_late  [expr {$clock_source_to_pin(max) + ($ddr_timing_args(board_tPD_clock_trace_NOM) + $ddr_timing_args(board_tPD_dqs_trace_total_NOM)) * (1 + 0.01*$ddr_timing_args(board_pcb_delay_var_percent)) + $ddr_timing_args(memory_tDQSCK)}]
set dqs_cl_early [expr {$clock_source_to_pin(min) + ($ddr_timing_args(board_tPD_clock_trace_NOM) + $ddr_timing_args(board_tPD_dqs_trace_total_NOM)) * (1 - 0.01*$ddr_timing_args(board_pcb_delay_var_percent)) - $ddr_timing_args(memory_tDQSCK)}]

while { $fbc_cl_late > 0.50 * $clock_period } {

set fbc_cl_late  [expr {$fbc_cl_late  - $clock_period}]
set fbc_cl_early [expr {$fbc_cl_early - $clock_period}]
set dqs_cl_late  [expr {$dqs_cl_late  - $clock_period}]
set dqs_cl_early [expr {$dqs_cl_early - $clock_period}]
}
}



set outab   "    "

#puts    "${outab}REPORT_clock_period_for_tan        \"$clock_period\" "                 ;
set outab   "    "

puts    "${outab}REPORT_capture_phase               \"$chosen_capture_phase\" "                ;
::ddr::mwinterface::write_private capture_phase $chosen_capture_phase

puts    "${outab}gCONNECT_CAPTURE_CLK_TO            \"$gCONNECT_CAPTURE_CLK_TO\" "      ;
puts    "${outab}gSTRATIX_DQS_PHASE                 \"$dqs_phase_stratix\" "            ;
if { $family_is_cyclone } { 
puts    "${outab}CONSTRAINT_dqs_delay_cyclone       \"$dqs_delay_cyclone\" "            ;# To constraints script - user-spec file.txt eg "dqs_delay_cyclone = 1234"
} elseif { $family_is_cyclone2 } {
puts    "${outab}CONSTRAINT_dqs_delay_cyclone       \"$dqs_cram_cyclone\" "            ;# To constraints script - user-spec file.txt eg "dqs_delay_cyclone = 1234"
} else {

}

puts    ""

puts    "${outab}gSTRATIXII_DQS_PHASE               \"$gSTRATIXII_DQS_PHASE\" "                 ;#  : natural := 7200;       --  9000/100 "90 degrees",  7200/100 "72 degrees"
puts    "${outab}gSTRATIXII_DLL_DELAY_BUFFER_MODE   \"$gSTRATIXII_DLL_DELAY_BUFFER_MODE\" "     ;#  : string  := "low";
puts    "${outab}gSTRATIXII_DQS_OUT_MODE            \"$gSTRATIXII_DQS_OUT_MODE\" "              ;#  : string  := "delay_chain3"
puts    "${outab}gSTRATIXII_DLL_DELAY_CHAIN_LENGTH  \"$gSTRATIXII_DLL_DELAY_CHAIN_LENGTH\" "    ;
puts    ""

    ## RESYNCH

puts    "${outab}REPORT_resynch_phase               \"$resynch_phase\" "                ;

puts    "${outab}gCONNECT_RESYNCH_CLK_TO            \"$gCONNECT_RESYNCH_CLK_TO\" "      ;
puts    "${outab}gRESYNCH_EDGE                      \"$gRESYNCH_EDGE\" "                ;
if { $fedback_clock_mode } {
puts    "${outab}gRESYNCH_CYCLE                     \"$chosen_fb_resync2_cycle\" "	
#puts "chosen_fb_resynch_cycle:$chosen_fb_resynch_cycle "
puts "gRESYNCH_CYCLE:$gRESYNCH_CYCLE"
} else {
puts    "${outab}gRESYNCH_CYCLE                     \"$gRESYNCH_CYCLE\" "               ;
}
puts    "${outab}gINTER_RESYNCH                     \"$gINTER_RESYNCH\" "               ;


if { $fedback_clock_mode } {
::ddr::mwinterface::write_private fedback_resync_phase $chosen_fb_resynch_phase	;
::ddr::mwinterface::write_private resync_phase 0								;
} else {
::ddr::mwinterface::write_private resync_phase $chosen_resynch_phase			;
}
puts    ""
    ## Postamble (control path)
if { $enable_postamble }  {
puts    "${outab}REPORT_postamble_phase             \"$postamble_phase\" "              ;

puts    "${outab}gCONNECT_POSTAMBLE_CLK_TO          \"$gCONNECT_POSTAMBLE_CLK_TO\" "    ;
puts    "${outab}gPOSTAMBLE_EDGE                    \"$gPOSTAMBLE_EDGE\" "              ;
if { $fedback_clock_mode } {
puts    "${outab}gPOSTAMBLE_CYCLE                   \"$chosen_fb_postamble_cycle\" "             ;
} else {
puts    "${outab}gPOSTAMBLE_CYCLE                   \"$gPOSTAMBLE_CYCLE\" "             ;
}
puts    "${outab}gINTER_POSTAMBLE                   \"$gINTER_POSTAMBLE\" "             ;
puts    ""
		## Postamble (Enable Path)
puts    ""
puts    "${outab}gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS \"$gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS\" "       ;
}



::ddr::mwinterface::store_setting family_is_stratix  $family_is_stratix
::ddr::mwinterface::store_setting family_is_stratix2 $family_is_stratix2
::ddr::mwinterface::store_setting family_is_cyclone2 $family_is_cyclone2

::ddr::mwinterface::store_setting dqs_cram_cyclone $dqs_cram_cyclone
::ddr::mwinterface::store_setting chosen_resynch_phase $chosen_resynch_phase


if { $ddr_mode=="normal" } {
::ddr::mwinterface::store_setting best_dqs_shift_setting $best_dqs_shift_setting
::ddr::mwinterface::store_setting dqs_cram_cyclone $dqs_cram_cyclone

if { $family_is_cyclone2 || $family_is_cyclone } {
::ddr::mwinterface::store_setting tshift90 [lindex $tSHIFT90_ $index_of_best_dqs_shift_setting]
::ddr::mwinterface::store_setting tshift90_min [lindex $tSHIFT90_MIN_ $index_of_best_dqs_shift_setting]
}

if { $fedback_clock_mode } {    

::ddr::mwinterface::store_setting fbc_cl_late  [expr {round($fbc_cl_late)}]
::ddr::mwinterface::store_setting fbc_cl_early [expr {round($fbc_cl_early)}]
::ddr::mwinterface::store_setting dqs_cl_late  [expr {round($dqs_cl_late)}]
::ddr::mwinterface::store_setting dqs_cl_early [expr {round($dqs_cl_early)}]


::ddr::mwinterface::store_setting   chosen_fb_resynch_cycle  $chosen_fb_resync1_cycle
::ddr::mwinterface::store_setting   chosen_fb_resync1_cycle  $chosen_fb_resync1_cycle
::ddr::mwinterface::store_setting   chosen_fb_resync2_cycle  $chosen_fb_resync2_cycle


::ddr::mwinterface::store_setting   chosen_fb_resynch_phase  $chosen_fb_resynch_phase

if { $enable_postamble } {
::ddr::mwinterface::store_setting   chosen_fb_postamble_cycle  $chosen_fb_postamble_cycle
::ddr::mwinterface::store_setting   chosen_fb_postamble_phase  $chosen_fb_postamble_phase
}
} else {
::ddr::mwinterface::store_setting   chosen_resynch_cycle  $chosen_resynch_cycle
::ddr::mwinterface::store_setting   chosen_resynch_phase  $chosen_resynch_phase
if { $enable_postamble } {
::ddr::mwinterface::store_setting   chosen_postamble_cycle  $chosen_postamble_cycle
::ddr::mwinterface::store_setting   chosen_postamble_phase  $chosen_postamble_phase
}
}

} else {

::ddr::mwinterface::store_setting chosen_capture_phase $chosen_capture_phase    
}

if { 0 } {
if { $fedback_clock_mode } {
::ddr::mwinterface::store_setting tpd_required_setting_of_fedback_clock_pll_resync $tpd_required_setting_of_fedback_clock_pll_resync
::ddr::mwinterface::store_setting cycles_of_fedback_clock_pll_resync $cycles_of_fedback_clock_pll_resync



if { $enable_postamble } {
::ddr::mwinterface::store_setting tpd_required_setting_of_fedback_clock_pll_postamble $tpd_required_setting_of_fedback_clock_pll_postamble
::ddr::mwinterface::store_setting cycles_of_fedback_clock_pll_postamble $cycles_of_fedback_clock_pll_postamble
}
}
}




}



set     text_capture            " DDR read data capture: DDR Data to DQS strobe edges at capture registers. "
set     text_resync             " Read data resynchronisation: Captured data to resync clock at resync registers ('resynched_data')."
set     text_post_enable        " Read Postamble Enable: Enable-release to DQS strobe postamble period at negative-edge capture registers."
set     text_post_control       " Read Postamble Control: Preset-release ('dq_enable_reset') to DQS strobe negative edges at postamble register ('dq_enable').     "



set     report_capture_su       [format "%5d" $worst_read_capture_su_SLACK]
set     report_capture_hold     [format "%5d" $worst_read_capture_hold_SLACK]
set     report_resync_su        [format "%5d" $worst_read_resync_su_SLACK]
set     report_resync_hold      [format "%5d" $worst_read_resync_hold_SLACK]
set     report_posen_su         [format "%5d" $worst_read_postamble_enable_su_SLACK]
set     report_posen_hold       [format "%5d" $worst_read_postamble_enable_hold_SLACK]
set     report_poscon_su        [format "%5d" $worst_read_postamble_control_su_SLACK]
set     report_poscon_hold      [format "%5d" $worst_read_postamble_control_hold_SLACK]

set space1  "\t"
set str_blank_failure   "             "

#set warning_tag             "WARNING:"          ;
#set error_tag               "ERROR:"
#set extrainfo_tag           "EXTRA INFO:"

set info_tag                "    "



set tag_cap_su      $info_tag
set tag_cap_hold    $info_tag
set tag_resync_su      $info_tag
set tag_resync_hold    $info_tag
set tag_posen_su      $info_tag
set tag_posen_hold    $info_tag
set tag_poscon_su      $info_tag
set tag_poscon_hold    $info_tag


if { $post_compile_mode } { 

if { ${num_failures_read_capture_su} == 0 } {
set     failure_info_capture_su          $str_blank_failure
} else {
set     failure_info_capture_su     [format "( Total of %3d paths with negative slack)" ${num_failures_read_capture_su}  ]
set     tag_cap_su      $warning_tag
}
if { ${num_failures_read_capture_hold} == 0 } {
set     failure_info_capture_hold          $str_blank_failure
} else {
set     failure_info_capture_hold   [format "( Total of %3d paths with negative slack)" ${num_failures_read_capture_hold} ]
set     tag_cap_hold      $warning_tag
}

set post_compile_info_capture_su        "[real_pin ${worst_read_capture_su_PIN}             ] ${failure_info_capture_su}"
set post_compile_info_capture_hold      "[real_pin ${worst_read_capture_hold_PIN}           ] ${failure_info_capture_hold}"


if { $ddr_mode == "normal" } {
if { ${num_failures_read_resync_su} == 0 } {
set     failure_info_resync_su          $str_blank_failure
} else {
set     failure_info_resync_su      [format "( Total of %3d paths with negative slack)" ${num_failures_read_resync_su} ]
set     tag_resync_su       $warning_tag
}
if { ${num_failures_read_resync_hold} == 0 } {
set     failure_info_resync_hold          $str_blank_failure
} else {
set     failure_info_resync_hold    [format "( Total of %3d paths with negative slack)" ${num_failures_read_resync_hold} ]
set     tag_resync_hold       $warning_tag
}

set post_compile_info_resync_su         "[real_pin ${worst_read_resync_su_PIN}              ] ${failure_info_resync_su}"
set post_compile_info_resync_hold       "[real_pin ${worst_read_resync_hold_PIN}            ] ${failure_info_resync_hold}"


if { $enable_postamble } {
if { ${num_failures_read_postamble_enable_su} == 0 } {
set     failure_info_posen_su          $str_blank_failure
} else {
set     failure_info_posen_su     [format "( Total of %3d paths with negative slack)" ${num_failures_read_postamble_enable_su}  ]
set     tag_posen_su        $warning_tag
}
if { ${num_failures_read_postamble_enable_hold} == 0 } {
set     failure_info_posen_hold          $str_blank_failure
} else {
set     failure_info_posen_hold     [format "( Total of %3d paths with negative slack)" ${num_failures_read_postamble_enable_hold}  ]
set     tag_posen_hold        $warning_tag
}


if { ${num_failures_read_postamble_control_su} == 0 } {
set     failure_info_poscon_su          $str_blank_failure
} else {
set     failure_info_poscon_su     [format "( Total of %3d paths with negative slack)" ${num_failures_read_postamble_control_su}  ]
set     tag_poscon_su       $warning_tag
}
if { ${num_failures_read_postamble_control_hold} == 0 } {
set     failure_info_poscon_hold          $str_blank_failure
} else {
set     failure_info_poscon_hold     [format "( Total of %3d paths with negative slack)" ${num_failures_read_postamble_control_hold}  ]
set     tag_poscon_hold       $warning_tag
}

set post_compile_info_posen_su          "[real_pin ${worst_read_postamble_enable_su_PIN}    ] ${failure_info_posen_su}"
set post_compile_info_posen_hold        "[real_pin ${worst_read_postamble_enable_hold_PIN}  ] ${failure_info_posen_hold}"

set post_compile_info_poscon_su         "[real_pin ${worst_read_postamble_control_su_PIN}   ] ${failure_info_poscon_su}"
set post_compile_info_poscon_hold       "[real_pin ${worst_read_postamble_control_hold_PIN} ] ${failure_info_poscon_hold}"
}
}
}



# Note: post_message cmd requires a string, so "" is not a valid argument - put a white space in at least!


if { $pre_compile_mode } {

if { $format_output_for_cmd_line } {
puts        " "
puts        "           Path                  Setup       Hold "
puts        "           ----------------      -----       ----"
puts        "           Capture             ${report_capture_su} ps    ${report_capture_hold} ps"
if { $ddr_mode == "normal" } {
puts        "           Resync              ${report_resync_su} ps    ${report_resync_hold} ps"
if { $enable_postamble } {
puts        "           Postamble-Enable    ${report_posen_su} ps    ${report_posen_hold} ps"
puts        "           Postamble-Control   ${report_poscon_su} ps    ${report_poscon_hold} ps"
}
}
puts        " "
puts        " "
puts        " "
} else {

		## Table 1.
set all_paths_ok true
puts        "REPORT\tDDR Read Data Capture\t${worst_read_capture_su_SLACK}\t${worst_read_capture_hold_SLACK}\tps"
if { $worst_read_capture_su_SLACK < 0 || $worst_read_capture_hold_SLACK < 0 } { set all_paths_ok false }

if { $ddr_mode == "normal" } {
puts        "REPORT\tRead Data Resync\t${worst_read_resync_su_SLACK}\t${worst_read_resync_hold_SLACK}\tps"
if { $worst_read_resync_su_SLACK < 0 || $worst_read_resync_hold_SLACK < 0 } { set all_paths_ok false }
if { $enable_postamble } {
if { ! $family_is_stratix2 } {
puts        "REPORT\tRead Postamble Enable\t${worst_read_postamble_enable_su_SLACK}\t${worst_read_postamble_enable_hold_SLACK}\tps"
if { $worst_read_postamble_enable_su_SLACK < 0 || $worst_read_postamble_enable_hold_SLACK < 0 } { set all_paths_ok false }

} else {
					## TODO <bla> is right by design..
}
puts        "REPORT\tRead Postamble Control\t${worst_read_postamble_control_su_SLACK}\t${worst_read_postamble_control_hold_SLACK}\tps"
if { $worst_read_postamble_control_su_SLACK < 0 || $worst_read_postamble_control_hold_SLACK < 0 } { set all_paths_ok false }
}
}
if { ! $all_paths_ok } {
message_out Crit "Warning: One or more timing requirements not met. Click 'Show Timing Estimates' for more details"
}
}   
        ## Table 2.



        ## $fedback_clock_mode
if { $fedback_clock_mode } {
puts        "REPORT\t Resync Clock\t  dedicated \t   <fixed> "
puts        "REPORT\t Resync Clock Edge\t  rising \t   <fixed> "
puts        "REPORT\t Resync Cycle\t  ${chosen_fb_resync2_cycle}\t  integer ( 0 to 3 )"
puts        "REPORT\t Resync Phase\t  ${chosen_fb_resynch_phase}\t  degrees ( 0 to 359 ) "
} else {
puts        "REPORT\t Resync Clock\t  ${chosen_resynch_clock}\t   clk  |  write_clk  |  dedicated "
puts        "REPORT\t Resync Clock Edge\t  ${chosen_resynch_edge}\t   rising | falling"
puts        "REPORT\t Resync Cycle\t  ${chosen_resynch_cycle}\t  integer ( 0 to 3 )"
puts        "REPORT\t Resync Phase\t  ${resynch_phase}\t  degrees ( 0 to 359 ) "
}

if { $ddr_mode == "normal" } {
if {  $family_is_stratix } {
puts        "REPORT\t Stratix DQS Phase Setting\t  ${dqs_phase_stratix}\t degrees ( 72 | 90 )"

} elseif { $family_is_stratix2 } {

puts        "REPORT\t Stratix II DQS Phase Setting\t  ${gSTRATIXII_DQS_PHASE}\t  1/100ths of a degree"
puts        "REPORT\t Stratix II DLL Delay Buffer Mode\t  ${gSTRATIXII_DLL_DELAY_BUFFER_MODE}\t  low  |  high"
puts        "REPORT\t Stratix II DQS Out Mode\t  ${gSTRATIXII_DQS_OUT_MODE}\t  1  |  2  |  3  |  4"
puts        "REPORT\t Stratix II DLL Delay Chain Length\t  ${gSTRATIXII_DLL_DELAY_CHAIN_LENGTH}\t  10  |  12  |  16"

} elseif { $family == "cyclone" } {
puts        "REPORT\tQuartus II assignment       DQS Delay\t$dqs_delay_cyclone\t ps"
puts        "REPORT\tCyclone DQS delay chain control setting\t${dqs_cram_cyclone}\t integer ( 0 to 63 )"
} elseif { $family == "cycloneii" } {
puts        "REPORT\tCyclone DQS delay chain control setting\t${dqs_cram_cyclone}\t integer ( 0 to 63 )"
} else {
error "auk_output_results: family $family unknown"
}

if {  $enable_postamble } {

if { $fedback_clock_mode } {
puts        "REPORT\t Postamble-Control Clock\t  dedicated\t   <fixed> "
puts        "REPORT\t Postamble-Control Clock Edge\t  rising \t   <fixed> "
puts        "REPORT\t Postamble-Control Cycle\t  ${chosen_fb_postamble_cycle}\t  integer ( 0 to 3 )"
puts        "REPORT\t Postamble-Control Phase\t  ${chosen_fb_postamble_phase}\t  degrees ( 0 to 359 )"
} else {
puts        "REPORT\t Postamble-Control Clock\t  ${chosen_postamble_clock}\t   clk  |  write_clk  |  dedicated "
puts        "REPORT\t Postamble-Control Clock Edge\t  ${chosen_postamble_edge}\t   rising  |  falling "
puts        "REPORT\t Postamble-Control Cycle\t  ${chosen_postamble_cycle}\t  integer ( 0 to 3 )"
puts        "REPORT\t Postamble-Control Phase\t  ${postamble_phase}\t  degrees ( 0 to 359 )"
}
if {  $family_is_stratix } {
puts        "REPORT\t Number of delay buffers inserted into postamble register clock path\t  ${gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS}\t  integer ( 0 to 8 )" 
}
}
} else {

puts "REPORT\t Capture Phase\t  ${chosen_capture_phase}\t  degrees ( 0 to 359 )"
}

} else {


puts  $post_summary_id  "  "        ;#---------------------------------------------------------------------------------------"
puts  $post_summary_id  "${text_capture}"
puts  $post_summary_id  "$tag_cap_su         Setup slack is ${report_capture_su} ps   ${post_compile_info_capture_su}"
puts  $post_summary_id  "$tag_cap_hold         Hold slack is  ${report_capture_hold} ps   ${post_compile_info_capture_hold}"
puts  $post_summary_id  "  "        ;#---------------------------------------------------------------------------------------"
if { $ddr_mode == "normal" } {
puts  $post_summary_id  "${text_resync}  "       
puts  $post_summary_id  "$tag_resync_su         Setup slack is ${report_resync_su} ps   ${post_compile_info_resync_su}    "
puts  $post_summary_id  "$tag_resync_hold         Hold slack is  ${report_resync_hold} ps   ${post_compile_info_resync_hold}"
puts  $post_summary_id  "  "        ;#---------------------------------------------------------------------------------------"
if { $enable_postamble } {
puts  $post_summary_id  "${text_post_enable}  "       
puts  $post_summary_id  "$tag_posen_su         Setup slack is ${report_posen_su} ps   ${post_compile_info_posen_su}    "

if { $family_is_stratix2 } {
puts  $post_summary_id  "$tag_posen_hold         Hold slack is guaranteed by design to always be positive for Stratix II"
} else {
puts  $post_summary_id  "$tag_posen_hold         Hold slack is  ${report_posen_hold} ps   ${post_compile_info_posen_hold}"
}

puts  $post_summary_id  "  "        ;#---------------------------------------------------------------------------------------"
puts  $post_summary_id  "${text_post_control}  "       
puts  $post_summary_id  "$tag_poscon_su         Setup slack is ${report_poscon_su} ps   ${post_compile_info_poscon_su}    "
puts  $post_summary_id  "$tag_poscon_hold         Hold slack is  ${report_poscon_hold} ps   ${post_compile_info_poscon_hold}"
puts  $post_summary_id  "  "        ;#---------------------------------------------------------------------------------------"
}
}

set    clock_delays_string          [join   $list_of_max_clk_to_pin_delays ", " ] 
if { $show_clock_delays } {
puts  $post_summary_id  " Clock output delays are:  $clock_delays_string "
}
}







set create_ba_file false
if { $pre_compile_mode } {

} elseif { $family_is_cyclone  } {

} elseif { $family_is_stratix2 && $fedback_clock_mode } {

} else {
set create_ba_file true
}


if {$create_ba_file} {
array set est_paths_min {}
array set est_paths_max {}
set back_ann_ignore [list dqspin_2_dqsclk_minus_tshift dqs_clkctrl name number ]

if { $family_is_cyclone } {
set back_ann_c1_paths [list dqsclk_2_ddio_capture dqsclk_2_ddio_resync dqsclk_2_post]
set back_ann_ignore [concat $back_ann_ignore $back_ann_c1_paths]
} else {
lappend back_ann_ignore dqspin_2_dqsclk
}


for { set n_halfdq  0 } { ${n_halfdq} <= ${n_halfdq_range} } { incr n_halfdq } {
foreach minmax {min max} {
foreach {k v} [array get "${minmax}${base_array_name}${n_halfdq}"] {
if { ! [info exists est_paths_${minmax}($k)] } {
set est_paths_${minmax}($k) [list]
}
lappend est_paths_${minmax}($k) $v
}
}
}

foreach minmax {min max} {
foreach {k v} [array get est_paths_${minmax}] {

catch {	set est_paths_${minmax}($k) [lsort -unique -integer $v] }
puts "$minmax $k [set est_paths_${minmax}($k)]"
}
}

set back_ann_estdata [open "${variation_name}_estimated_data.dat" w]

puts $back_ann_estdata "# Estimated data for Pre-Compile"
foreach {k v} [array get est_paths_min]  {
set l "set min_paths_for_each_half_dq_0($k) [list [lindex $v 0]]"
if { [lsearch -exact $back_ann_ignore $k] == -1 } {
puts $back_ann_estdata $l
} else {
puts $back_ann_estdata "# $l"
}

}
puts  $back_ann_estdata ""
foreach {k v} [array get est_paths_max]  {
set l "set max_paths_for_each_half_dq_0($k) [list [lindex $v end]]"
if { [lsearch -exact $back_ann_ignore $k] == -1 } {
puts $back_ann_estdata $l
} else {
puts $back_ann_estdata "# $l"
}

}


if { $family_is_stratix &&  $ddr_mode == "normal" } {
set sh [expr {$settings_array(dqs_phase)/360.0 * $clock_period}]
puts $back_ann_estdata ""
puts $back_ann_estdata "set min_paths_for_each_half_dq_0(dqspin_2_dqsclk_minus_tshift)  [expr {round([lindex $est_paths_min(dqspin_2_dqsclk) 0] - $sh)}]"
puts $back_ann_estdata "set max_paths_for_each_half_dq_0(dqspin_2_dqsclk_minus_tshift)  [expr {round([lindex $est_paths_max(dqspin_2_dqsclk) end] - $sh)}]"
}

if {$family_is_cyclone2 } {
puts $back_ann_estdata ""
puts $back_ann_estdata "set min_paths_for_each_half_dq_0(dqs_clkctrl) [expr {round([lindex $est_paths_min(dqs_clkctrl) 0] - $settings_array(tshift90_min))}]"
puts $back_ann_estdata "set max_paths_for_each_half_dq_0(dqs_clkctrl) [expr {round([lindex $est_paths_max(dqs_clkctrl) end] - $settings_array(tshift90))}]"

}

if {$family_is_cyclone } {
puts $back_ann_estdata ""
foreach p $back_ann_c1_paths  {
puts $back_ann_estdata "set min_paths_for_each_half_dq_0($p) [expr {round([lindex $est_paths_min($p) 0] - $settings_array(tshift90_min))}]"
puts $back_ann_estdata "set max_paths_for_each_half_dq_0($p) [expr {round([lindex $est_paths_max($p) end] - $settings_array(tshift90))}]"
}
}

close $back_ann_estdata
}
