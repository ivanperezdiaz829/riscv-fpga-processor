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






package provide ::ddr::legacy 0.1

namespace eval ::ddr::legacy { 
namespace export read_settings_file
namespace export set_family_is_star
namespace export gen_precompile
namespace export tan_arg_script_name
namespace export set_postcompile_summary_tags
namespace export sentinel

if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}





proc unpack_settings_file { arrayname } {
uplevel {

if { $settings_array(family) == "stratixgx" } {
set settings_array(family) stratix
}

if { $settings_array(family) == "stratixiigx" } {
set settings_array(family) stratixii
}	
::ddr::utils::unpack_array settings_array {
memory_device
cas_latency
{ chosen_resynch_clk chosen_resynch_clock }
chosen_resynch_cycle
chosen_resynch_edge

chosen_resynch_phase
clock_freq_in_mhz
clock_neg_pin_name
{clock_period_in_ps clock_period} 
clock_pos_pin_name
current_quartus_project_dir
current_script_working_dir
ddr_mode
{ dll_ref_clock__switched_off_during_reads dll_ref_clock_switched_off_during_reads }
enable_postamble

fedback_clock_mode
{memory_fmax_at_cl2 fmax_at_cl2}
{memory_fmax_at_cl25 fmax_at_cl25}
{memory_fmax_at_cl3 fmax_at_cl3}
{memory_fmax_at_cl4 fmax_at_cl4}
{memory_fmax_at_cl5 fmax_at_cl5}
{device fpga_device}
# {speed_grade fpga_speed_grade tolower}: extracted separately
{local_data_bits gLOCAL_DATA_BITS}
{mem_dq_per_dqs gMEM_DQ_PER_DQS}
{postamble_regs gPOSTAMBLE_REGS}
{stratix_undelayeddqsout_insert_buffers gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS}
num_output_clocks
pcb_delay_var_percent
{memory_percent_tDQSS percent_tDQSS}
{ddr_pin_prefix pin_prefix}
quartus_project_name

quartus_version
{memory_tAC tAC}
{memory_tCK_MAX tCK_MAX}
{memory_tDH tDH}
{memory_tDQSCK tDQSCK}
{memory_tDQSQ tDQSQ}
{memory_tDS tDS}
{tPD_clock_trace_NOM tPD_clock_trace_NOM}
{tPD_dqs_trace_total_NOM tPD_dqs_trace_total_NOM}
{memory_tQHS tQHS}
{board_tSKEW_data_group tSKEW_data_group}
use_dedicated_pll_output_as_clock
wrapper_name
} 0 

if { $fedback_clock_mode } {   
::ddr::utils::unpack_array settings_array {
chosen_fb_resynch_cycle  
chosen_fb_resynch_phase  
chosen_fb_postamble_cycle  
chosen_fb_postamble_phase  
{tPD_fedback_clock_NOM tPD_clockfeedback_trace_NOM}
} 0
} else {
::ddr::utils::unpack_array settings_array {
chosen_resynch_cycle  
chosen_resynch_phase  
chosen_postamble_cycle  

chosen_postamble_phase  
} 0
}

if { $ddr_mode == "normal" } {
::ddr::utils::unpack_array settings_array {
best_dqs_shift_setting
dqs_cram_cyclone
dqs_delay_cyclone          
{ dqs_phase dqs_phase_stratix }
override_resynch_was_used
} 0
if { $enable_postamble  } {
::ddr::utils::unpack_array settings_array {
override_postamble_was_used
{ chosen_postamble_clk chosen_postamble_clock }
chosen_postamble_edge
} 0
}
} else {

::ddr::utils::unpack_array settings_array {

chosen_capture_phase
} 0
}


}
}	




#  family_is_{cyclone,cyclone2,stratix,stratix2}.








#  Will update family, if it contains either "stratixgx", "stratixiigx" or "hardcopyii"



proc set_family_is_star { } {
uplevel {

set family_is_cyclone false
set family_is_cyclone2 false
set family_is_stratix false
set family_is_stratix2 false

if { $family == "stratixgx" } {
set family "stratix"
}

if { $family == "stratixiigx" } {
set family "stratixii"
}			
if { $family == "hardcopyii" } {
set family "stratixii"
}

if { $family == "cyclone" } { 	set family_is_cyclone true 
} elseif { $family == "cycloneii" } { set family_is_cyclone2 true 
} elseif { $family == "stratix" } { set family_is_stratix true 
} elseif { $family == "stratixgx" } { set family_is_stratix true 
} elseif { $family == "stratixii" } { set family_is_stratix2 true 
} elseif { $family == "stratixiigx" } { set family_is_stratix2 true 
} elseif { $family == "hardcopyii" } { set family_is_stratix2 true ;
} else {
message_out Error "Unrecognised device family >$family<."
error "Unrecognised device family >$family<."
}
}

}









proc set_family_and_speed_grade {} {
uplevel {
set family [get_global_assignment -name FAMILY]
set family [string tolower $family]
set family [regsub -all " " $family ""]
set fpga_speed_grade [get_global_assignment -name DEVICE]
set fpga_speed_grade [lindex [regexp -inline {([iac][0-9]?)(es)?$} [string tolower $fpga_speed_grade]] 1]
}
}

proc min { a b} {
if { $a > $b } { return $b
} else { return $a }
}
proc max { a b} {
if { $b > $a } { return $b
} else { return $a }
}

proc gen_precompile { list_of_array_names dqs_shift} {
array set min_paths {}
array set max_paths {}

foreach array_name $list_of_array_names {
upvar $array_name arr
foreach {k v} [array get arr] {
if { [string match min* $array_name] } {
if { [info exists min_paths($k)] }  { set min_paths($k) [min $min_paths($k) $v] 
} else {set min_paths($k) $v }
} else {
if { [info exists max_paths($k)] }  { set max_paths($k) [max $max_paths($k) $v] 
} else {set max_paths($k) $v } 
}
}
}

set f [open "estimated_data.txt" w]

puts $f "array_name=    min_paths_for_each_half_dq_0"
foreach {k v} [array get min_paths] {
puts $f "    $k        $v"
}
puts $f "array_name=    max_paths_for_each_half_dq_0"
foreach {k v} [array get max_paths] {
puts $f "    $k        $v"
}
close $f

puts "min_paths : [array get min_paths]"
puts "max_paths : [array get max_paths]"
}






set generate_t [list struct \
family str \
local_data_bits int \
mem_dq_per_dqs int \
mem_chip_bits int \
local_avalon_if str \
mem_chipsels int \
mem_bank_bits int \
mem_row_bits int \
mem_col_bits int \
local_burst_len int \
local_burst_len_bits int \
user_refresh str \
enable_capture_clk str \
enable_resynch_clk str \
chosen_resynch_edge str \
chosen_postamble_edge str \
chosen_postamble_cycle int \
inter_resynch str \
inter_postamble str \
pipeline_readdata str \
stratix_undelayeddqsout_insert_buffers int \
clock_period_in_ps str \
mem_type str \
enable_postamble str \
reg_dimm str \
postamble_regs str \
buffer_dll_delay_output str \
fedback_clock_mode str \
chosen_resynch_clk str \
chosen_resynch_cycle str \
chosen_postamble_clk str \
dqs_phase str \
stratixii_dqs_phase str \
stratixii_dll_delay_buffer_mode str \
stratixii_dqs_out_mode str \
stratixii_dll_delay_chain_length str \
dll_ref_clock__switched_off_during_reads str \
tinit_clocks str \
num_output_clocks str \
rtl_roundtrip_clocks str \
tpd_clock_trace_nom str \
tpd_clockfeedback_trace_nom str \
tpd_dqs_trace_total_nom str \
toplevel_name str \
wrapper_name str \
ddr_pin_prefix str \
parse_example_design str \
testbench_use_vector str \
language str \
quartus_version str \
megawizard_version str \
regtest_add_dll_ports str \
]








#  The name of the script to call, for example "tan_arg2.tcl", or "" if the combination is handled by the legacy infrastructure.

proc tan_arg_script_name { family ddr_mode fedback_clock_mode } {
#post_message "$family $ddr_mode $fedback_clock_mode"
if { $family == "cycloneii" } {
assert { $ddr_mode == "normal" && !$fedback_clock_mode } {} "Only DQS capture, normal resync mode is supported for Cyclone2"
return "tan_arg2.tcl"
} elseif { $family == "stratixii" || $family == "stratixiigx" } {
if { $ddr_mode == "non-dqs" && $fedback_clock_mode } {
return "tan_arg_nondqsfbc.tcl"
} elseif { $ddr_mode == "non-dqs" &&  ! $fedback_clock_mode } {
return ""
} elseif { $ddr_mode == "normal" && $fedback_clock_mode } {
return "tan_arg_dqsfbc.tcl"
} elseif { $ddr_mode == "normal" && ! $fedback_clock_mode } {
return "" 
} else {
assert {0} {$ddr_mode} "Unknown ddr mode"
return ""
}
} else {

return ""
}
}

proc set_postcompile_summary_tags { } {
uplevel {
set note_tag                "NOTE:"
set cwarning_tag             "CRITWARNING:"        
set warning_tag             "WARNING:"          ;
set error_tag               "ERROR:"
set extrainfo_tag           "EXTRA INFO:"

set extrainfo_tag_pretty    "${extrainfo_tag}      |__"
}
}

proc sentinel  {x} {
return "sentinel$x" 
}
}

