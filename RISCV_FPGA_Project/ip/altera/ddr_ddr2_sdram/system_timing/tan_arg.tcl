
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














set variation_name      [lindex $quartus(args) 0]

set setting_of_cut_off_clear_and_preset_paths       "ON"            ;

if {[catch {source ddr_lib_path.tcl} err] } { error "Couldn't find ddr_lib_path.tcl in the current directory ([pwd]). Stop. (Err was $err)" }
package require ::ddr::settings
package require ::ddr::utils
package require ::ddr::extract
package require ::ddr::legacy
package require ::ddr::paths
package require ::ddr::messages
package require ::quartus::advanced_timing

::ddr::settings::read "${variation_name}_ddr_settings.txt" settings_array

::ddr::legacy::set_postcompile_summary_tags

if { ! [info exists release_state] } { set release_state  "release" }


if { $release_state == "debug" } {
set only_dump_pins                      false

set extract_ddr_megacore_paths          true        ;
set run_ddr_system_timing               true

set    die_on_errors                   false        ;
set show_progress                       true

set debug_on                            true        ;
set debug2_on                           false        ;
set debug_ddr_settings                  false        ;
set log_to_file                         true        ;
#set use_different_hdlpaths              false       ;
set force_a_bad_path                    false       ;
#set debug_sig2node_mapping              true        ;
set out_file_path                       $settings_array(wrapper_path)         ;
} else {
set only_dump_pins                      false
set extract_ddr_megacore_paths          true
set run_ddr_system_timing               true
set die_on_errors                       false
set show_progress                       false
set debug_on                            true        ;
set debug2_on                           false
set debug_ddr_settings                  false
set log_to_file                         true

set force_a_bad_path                    false
#set debug_sig2node_mapping              true           ;
set out_file_path                       $settings_array(wrapper_path)
}
#############################################################

set format_estimated_data_file_for_back_annotating      "true"

set max_stack_depth_for_node_src_recursion    30   ;# 8 10 12           ;

set error_in_proc_sig2node               "none"
set error_in_proc_find_hier_using_pin    "none"
set error_in_proc_get_node2node_delay    "none"

set script_can_continue                 "true"
set stop_extractions                    "false"

#set warning_tag             "WARNING:"          ;
#set error_tag               "ERROR:"
#set extrainfo_tag           "EXTRA INFO:"





proc     user_help_info_for_misc_extraction_errors   { file_id } {
global  extrainfo_tag   extrainfo_tag_pretty
foreach line [::ddr::messages::get_tan_failed_message] {
puts $file_id $line
}
return  0
}
################################### procedures ###############################################################

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
#################################################################################################################################

# reports come back as "0.675 ns" - convert to integer ps ie. "675"

proc get_ps { ns } {
return [ expr { round ( 1000 * [lindex $ns 0 ] )  } ]
}





proc    sig2node { sig } {
global      node_ids_of_signals
global      error_in_proc_sig2node
global      die_on_errors
set     result  "no_matching_node"
if { [catch {set  result  $node_ids_of_signals($sig) } error_result ] } {

#set error_in_proc_sig2node  "$error_result"
set error_in_proc_sig2node "The timing node name '$sig' was expected to be found in the timing netlist but could not be found "
if { $die_on_errors } { 
error "error_in_proc_sig2node: $error_in_proc_sig2node"
}
} else {
set result  $error_result
}
return      $result

}

##########################



##########################
proc get_node2node_delay {  src_signal  dest_signal  { type sync } } {

global  error_in_proc_sig2node
global  error_in_proc_get_node2node_delay
global  log_id

global  src_node_error
global  dst_node_error

set src_node_error  "false"
set dst_node_error  "false"


set src_node    [sig2node $src_signal]

if { $error_in_proc_sig2node != "none" } {
set src_node_error  "true"
set this_error      "  Cannot find source node '$src_signal'"
puts $log_id               "ERROR: $this_error"
set error_in_proc_get_node2node_delay   $this_error
return  0
}

if { $src_node == "no_matching_node_for_signal" } {
return "*** BAD src ***"
}
set dest_node   [sig2node $dest_signal]

if { $error_in_proc_sig2node != "none" } {
set dst_node_error  "true"
set this_error      "  Cannot find destination node '$dest_signal'"
puts $log_id               "ERROR: $this_error"
set error_in_proc_get_node2node_delay   $this_error
return  0
}

if { $dest_node == "no_matching_node_for_signal" } {
return "*** BAD dst ***"
}
set fanin_nodes [get_timing_node_fanin -type $type    $dest_node ]
set src_nodes_found     ""
set no_fanins_match_src     "true"
foreach fanin $fanin_nodes {
set found_src_node               [lindex $fanin 0]
append  src_nodes_found  $found_src_node
append  src_nodes_found  ", "
if { $found_src_node == $src_node } {
set no_fanins_match_src     "false"
set total_delay         0
set src_node_delay		[ get_ps [get_timing_node_info -info delay [lindex $fanin 0] ]]
set ic_delay            [ get_ps [lindex $fanin 1]  ]
set cell_delay          [ get_ps [lindex $fanin 2]  ]
set total_delay         [ expr { $src_node_delay + $ic_delay  + $cell_delay } ]
}
}
if { $no_fanins_match_src } {
set this_error  " Path not found from src=$src_node to dst=$dest_node -type $type (the following src nodes are fanin to dest $src_nodes_found)"
puts $log_id               "ERROR: $this_error"
set error_in_proc_get_node2node_delay   $this_error
return 8888
# return  "*** ERROR *** Path not found from src=$src_node to dst=$dest_node -type $type (the following src nodes are fanin to dest $src_nodes_found)"

} else {
return  $total_delay
}
}

##########################

##########################
proc get_recursively_sig2node {  src_signal  dest_node  { type clock } } {
global  max_stack_depth_for_node_src_recursion
global log_id
global post_summary_id
global error_tag
global stop_extractions

set debug_recursion "false"

set stack_level [info level]
if { $stack_level >= $max_stack_depth_for_node_src_recursion} {
set this_error "Proc recursion FATAL ERROR in proc 'get_recursively_sig2node': stack_level is $stack_level (too many delay hops from undelayed_dqs to postamble register)"
puts $post_summary_id "${error_tag} $this_error"
puts $log_id    "$this_error"
set stop_extractions    "true"

}

set current_dest_signal       [ get_timing_node_info -info name    $dest_node ]
if { $current_dest_signal == $src_signal } {
if { $debug_recursion } {
puts $log_id    "Proc recursion: current dest == src signal, $current_dest_signal"
puts $log_id    "                0 delay returned"
}
return 0
}
set fanin_nodes [get_timing_node_fanin -type $type    $dest_node ]

set the_1st_fanin           [lindex $fanin_nodes 0]
set driving_node            [lindex $the_1st_fanin 0]

set next_dest       $driving_node
set total_delay     [ get_recursively_sig2node   $src_signal  $next_dest  ]

set ic_delay            [ get_ps [lindex $the_1st_fanin 1]  ]
set cell_delay          [ get_ps [lindex $the_1st_fanin 2]  ]
set total_delay         [ expr { $total_delay + $ic_delay  + $cell_delay } ]


if { $debug_recursion } {
puts $log_id    "Proc recursion: DEST=  $current_dest_signal"
puts $log_id    "                IC= $ic_delay  CELL= $cell_delay"
puts $log_id    "                TOTAL= $total_delay "
}
return      $total_delay
}






proc  extract_ddr_path  { path  i  } {
global  gLOCAL_DATA_BITS
global  gMEM_DQ_PER_DQS
global  gPOSTAMBLE_REGS

global  pin_prefix
global  signal_hdlpath1  
global  signal_hdlpath2
global  log_id  
global  debug2_on   debug_on

global  error_in_proc_sig2node

global  extracted_clkp_path  
global  clock_pos_pin_name

global  gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS

global  array_of_dq_pins
global family_is_stratix2

if { $debug2_on } { puts $log_id  "i= $i  path= $path" }

set is_the_src_a_pin           [get_ddr_path_info $path  "src_is_pin"]
set is_the_dst_a_pin           [get_ddr_path_info $path  "dst_is_pin"]


set i_rem  [expr { $i % 2 } ]
if { [get_ddr_path_info $path  "src_uneven"]  } {
set src_x     $i_rem
} else {
set src_x     ""
}
if { [get_ddr_path_info $path  "dst_uneven"]  } {
set dst_x     $i_rem
} else {
set dst_x     ""
}

set src_rtl_name    "src_rtl_name${src_x}"       
set src_ext         "src_ext${src_x}"
set dst_rtl_name    "dst_rtl_name${dst_x}"       
set dst_ext         "dst_ext${dst_x}"

if { 0 } {
puts $log_id  "         src_rtl_name= $src_rtl_name" 
puts $log_id  "         src_ext=      $src_ext"
puts $log_id  "         dst_rtl_name= $dst_rtl_name"
puts $log_id  "         dst_ext=      $dst_ext"
}

set path_src                    [get_ddr_path_info $path  $src_rtl_name]
set path_src_ext                [get_ddr_path_info $path  $src_ext]
set path_dst                    [get_ddr_path_info $path  $dst_rtl_name]
set path_dst_ext                [get_ddr_path_info $path  $dst_ext]
set path_type                   [get_ddr_path_info $path  "type"]
set path_recursion_required     [get_ddr_path_info $path  "recursively"]

    #################################################################

#set num_of_data_groups      [expr { ( $gLOCAL_DATA_BITS / 2 ) / $gMEM_DQ_PER_DQS  } ]

set     group_size              [expr { int ( $gMEM_DQ_PER_DQS ) } ]
set     posts_per_group         [expr { int ( $gPOSTAMBLE_REGS ) } ]

set     dq_per_post             [expr { int ( floor ( $group_size / $posts_per_group ) ) } ]
set     dq_pin_n                [expr { int ( floor ( $i / 2 ) ) } ]
set     dq_within_group_n       [expr { round ( $dq_pin_n % $group_size ) } ]

if { $i_rem == 1 } {
set     rdata_n_offset      $group_size
} else {
set     rdata_n_offset      0
}
set     rdata_n                 [expr { round ( $dq_within_group_n + $rdata_n_offset ) } ]
set     post_n                  [expr { floor ( $dq_within_group_n / $dq_per_post )  }  ]
set     data_group_n            [expr { floor ( $dq_pin_n / $gMEM_DQ_PER_DQS  ) } ]
    #################################################################

set src_numbering              [get_ddr_path_info $path  "src_numbering"]
set dst_numbering              [get_ddr_path_info $path  "dst_numbering"]

switch -exact -- $src_numbering {
as_dq               { set src_data_bit_n   $dq_pin_n            }
as_ddio             { set src_data_bit_n   $dq_within_group_n   }
as_dqs              { set src_data_bit_n   $data_group_n        }
as_post             { set src_data_bit_n   $post_n              }
as_rdata            { set src_data_bit_n   $rdata_n             }
fixed_value         { set src_data_bit_n   0                    }
use_num_of_buffers  { set src_data_bit_n   $gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS 
if { $src_data_bit_n == 0 } {
set path_src  "undelayed_dqs"
}
}
default             { set src_data_bit_n   NA                   }
}
switch -exact -- $dst_numbering {
as_dq               { set dst_data_bit_n   $dq_pin_n            }
as_ddio             { set dst_data_bit_n   $dq_within_group_n   }
as_dqs              { set dst_data_bit_n   $data_group_n        }
as_post             { set dst_data_bit_n   $post_n              }
as_rdata            { set dst_data_bit_n   $rdata_n             }
fixed_value         { set dst_data_bit_n   0                    }
use_num_of_buffers  { set dst_data_bit_n   $gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS 
if { $dst_data_bit_n == 0 } {
set path_dst  "undelayed_dqs"
}
}
default             { set dst_data_bit_n   NA                   }
}


set     data_group_hdlpath    ""

append  data_group_hdlpath    $signal_hdlpath1  
append  data_group_hdlpath                        [expr { round ( $data_group_n ) } ] 
append  data_group_hdlpath    $signal_hdlpath2 

set src_hdlpath_type              [get_ddr_path_info $path  "src_hdlpath"]
set dst_hdlpath_type              [get_ddr_path_info $path  "dst_hdlpath"]

if { $src_hdlpath_type  == "none" } {
set      src_data_group_hdlpath      ""
} else {
set     src_data_group_hdlpath      $data_group_hdlpath
}

if { $dst_hdlpath_type  == "none" } {
set     dst_data_group_hdlpath      ""
} else {
set     dst_data_group_hdlpath      $data_group_hdlpath
}

set ignore_pin_prefix              [get_ddr_path_info $path  "ignore_pin_prefix"]




if { $is_the_src_a_pin == "true" } {
if { $ignore_pin_prefix } {
set     src_prefix                 ""
} else {
set     src_prefix                  $pin_prefix
}
set     src_data_group_hdlpath      ""
set     src_io_suffix               "_in"
} else {
set     src_prefix                  ""
set     src_io_suffix               ""
}
if { $is_the_dst_a_pin == "true" } {
if { $ignore_pin_prefix } {
set     dst_prefix                  ""
} else {
set     dst_prefix                  $pin_prefix
}
set     dst_data_group_hdlpath      ""
set     dst_io_suffix               "_out"
} else {
set     dst_prefix                  ""
set     dst_io_suffix               ""
}

if { [get_ddr_path_info $path  "src_sqbrkt_off"] } {
set src_sqbrkt_left      ""
set src_sqbrkt_right     ""
} else {
set src_sqbrkt_left      "\["
set src_sqbrkt_right     "\]"
}


if { ( [get_ddr_path_info $path  "special_case_destination_dq_io_ddio_out_reg_use_colons"] ) && ( $i_rem == 0  ) } {
set dst_sqbrkt_left      ":"
set dst_sqbrkt_right     ":"
} else {
if { [get_ddr_path_info $path  "dst_sqbrkt_off"] } {
set dst_sqbrkt_left       ""
set dst_sqbrkt_right     ""
} else {
set dst_sqbrkt_left      "\["
set dst_sqbrkt_right     "\]"
}
}


set     src_timing_node_name    $src_data_group_hdlpath
append  src_timing_node_name    $src_prefix
append  src_timing_node_name    $path_src 
if { $src_numbering != "none" } {
append  src_timing_node_name                        $src_sqbrkt_left
append  src_timing_node_name                        [expr { round ( $src_data_bit_n  ) } ]                
append  src_timing_node_name                        $src_sqbrkt_right
}
append  src_timing_node_name    $path_src_ext
append  src_timing_node_name    $src_io_suffix



if { [get_ddr_path_info $path  "src_is_dq"] } {
set     src_timing_node_name    $array_of_dq_pins($dq_pin_n)
append  src_timing_node_name        $src_io_suffix
}



set     dst_timing_node_name    $dst_data_group_hdlpath
append  src_timing_node_name    $dst_prefix
append  dst_timing_node_name    $path_dst 
if { $dst_numbering != "none" } {
append  dst_timing_node_name                        $dst_sqbrkt_left
append  dst_timing_node_name                        [expr { round ( $dst_data_bit_n  ) } ]                
append  dst_timing_node_name                        $dst_sqbrkt_right
}
append  dst_timing_node_name    $path_dst_ext
append  dst_timing_node_name    $dst_io_suffix



if {[get_ddr_path_info $path  "part_of_clkout_path"] } {
if { $family_is_stratix2 } {

return "xxx"
}
set src_timing_node_name        "${extracted_clkp_path}$path_src"
set dst_timing_node_name        "${extracted_clkp_path}$path_dst"
if { [get_ddr_path_info $path  "dst_is_clk_pin"] } {
set dst_timing_node_name        "${clock_pos_pin_name}_out"
}
}
    ##############################

if { $debug2_on } {
puts $log_id  "     src=>$src_timing_node_name<"
puts $log_id  "     dst=>$dst_timing_node_name<"
}

if { $path_recursion_required } {
#set path_delay      "*** ERROR ***  recursion switched off"
set src_timing_node_id      [sig2node $dst_timing_node_name]
if { $error_in_proc_sig2node != "none" } {
set path_delay      0
} else {
set path_delay              [get_recursively_sig2node    $src_timing_node_name  $src_timing_node_id     $path_type ]
}
} else {
set path_delay              [get_node2node_delay         $src_timing_node_name  $dst_timing_node_name   $path_type ]
}

if { $debug2_on } {
puts $log_id  "     DELAY= $path_delay ps"
}
return  $path_delay
}





proc  extract_ddr_path_alt  { path  i  } {
global  log_id 
global  error_in_proc_get_node2node_delay
global  error_in_proc_sig2node
global  zero_delay_paths

global  dqsclk_2_post
global  post_2_dqsclk
global  reg_2_post

set path_delay      [ extract_ddr_path  $path  $i ]

if { $path_delay == 0 } {
puts $log_id "Zero delay was returned for '$path' i= $i "
incr zero_delay_paths    
set alternative_path           [get_ddr_path_info $path  "alternative_path"]

if { $alternative_path != "false" } {

puts $log_id "Attempting alternaive path '$alternative_path' for '$path' i= $i (ignore previous error)"
set error_in_proc_get_node2node_delay   "none"
set error_in_proc_sig2node              "none"
set path_delay              [ extract_ddr_path  $alternative_path  $i ]
} elseif { [get_ddr_path_info $path  "dont_error_on_absence"] } {


puts $log_id "Ignoring errors on path '$path' i= $i "
set error_in_proc_get_node2node_delay   "none"
set error_in_proc_sig2node              "none"

} else {


set regexp_tildaregout  "~regout"
set got_tildaregout_match  [regexp  $regexp_tildaregout  $error_in_proc_sig2node]

if { $got_tildaregout_match } {
puts $log_id "Changing case of ~regout to ~REGOUT, '$path' i= $i (ignore previous error!)"
set dqsclk_2_post(dst_ext)      "~REGOUT"
set post_2_dqsclk(src_ext)      "~REGOUT"
set reg_2_post(dst_rtl_name)    "dqs_io~REGOUT"

set error_in_proc_get_node2node_delay   "none"
set error_in_proc_sig2node              "none"

set path_delay      [ extract_ddr_path  $path  $i ]
} else {
puts $log_id "Not a regout issue (regexp failed)"
}
}
}
return  $path_delay
}




###########################################################################################################################

###########################################################################################################################

if { $log_to_file } {
set log_file        [ file join $out_file_path "${variation_name}_extraction_log.txt" ]
if { [ catch { open $log_file  w }   log_id  ] } {
puts  " - ERROR: Cant open file '$log_file' for output."
return -code 99
}
} else {
set log_id  "stdout"
}






::ddr::legacy::unpack_settings_file  setting_array   


set abs_path_to_project [file join $settings_array(project_path) $settings_array(quartus_project_name) ]


set quartus_revisions [get_project_revisions $abs_path_to_project]
set current_quartus_revision [get_current_revision $abs_path_to_project]
puts $log_id "$note_tag Found revisions $quartus_revisions. Opening \"$current_quartus_revision\"."

project_open $abs_path_to_project  -revision $current_quartus_revision


::ddr::legacy::set_family_and_speed_grade
::ddr::legacy::set_family_is_star

###################################################################################


if { $wrapper_name != $variation_name } {
puts $log_id  "$line_tag ERROR: wrapper_name(in ddr_settings)= '$wrapper_name', variation_name= '$variation_name' " 
}






if { 0 } {  message_out error "pin prefix is >$pin_prefix<"  }
set null_string_text        "NULL_STRING"
if { $pin_prefix == $null_string_text } {
set pin_prefix      ""
set pin_prefix_for_settings     $null_string_text
} else {
set pin_prefix_for_settings     $pin_prefix
}



set     path_escape_char        "\\"
set     path_generate_char      ":"                 ;# for numbered generates only - non-numbered generates [still] use "_"

set     e   $path_escape_char
set     g   $path_generate_char


set     t    "${variation_name}_"
set     datapath_hdlpath            "${t}auk_ddr_sdram:${t}auk_ddr_sdram_inst|${t}auk_ddr_datapath:ddr_io|${t}auk_ddr_dqs_group:${e}g_datapath${g}"
set     signal_hdlpath2                "${g}g_ddr_io|"

###  | is now included at end of hier path

#  set     datapath_hdlpath     "|auk_ddr_sdram:auk_ddr_sdram_inst|auk_ddr_datapath:ddr_io|auk_ddr_dqs_group_ $family : $e g_datapath $g"



if { $family == "stratix" } {
#set suffix_of_node_name_driving_clk_pins    "|stratix_ddio_out:ddio_out\[0\]|ioatom~DFFDATAOUT"
set suffix_of_node_name_driving_clk_pins    "|ioatom~DFFDATAOUT"
} elseif { $family_is_stratix2 } {

#set suffix_of_node_name_driving_clk_pins      "|ddio_out_69a:auto_generated|ddio_outa\[0\]~data_in_reg"
set suffix_of_node_name_driving_clk_pins      "|ddio_outa\[0\]~data_in_reg"
} elseif { $family == "cyclone" } {
#set suffix_of_node_name_driving_clk_pins    "|mux\[0\]~COMBOUT"
set suffix_of_node_name_driving_clk_pins    "|mux\[0\]~COMBOUT"
} else {
set suffix_of_node_name_driving_clk_pins    "not_defined"
}




if { $family_is_cyclone } {
set  paths_for_all_modes        [list   \
dq_2_wire                       \
wire_2_ddio                     \
ddio_2_reg                      \
clk_2_mux                       \
mux_2_clkpin                    \
]

set  paths_for_dqsmode_only        [list    \
dqsclk_2_ddio_capture               \
dqsclk_2_ddio_resync                \
dqspin_2_dqsclk                     \
] 

set  paths_for_postamble_only        [list  \
reg_2_post                          \
post_2_ddio                         \
dqsclk_2_post                       \
]        

} elseif { $family_is_stratix2 } {



set  paths_for_all_modes        [list   \
dq_2_ddio                       \
ddio_2_core                     \
core_2_reg                      \
clk_2_pin                       \
]      
set  paths_for_dqsmode_only        [list    \
dqsclk_2_ddio_resync                \
dqspin_2_dqsclk                     \
] 
set  paths_for_postamble_only        [list  \
reg_2_post                          \
post_2_dqsclk                       \
dqsclk_2_post                       \
]



} elseif { $family_is_stratix } {



set  paths_for_all_modes        [list   \
dq_2_ddio                       \
ddio_2_reg                      \
clk_2_pin                       \
]      
set  paths_for_dqsmode_only        [list    \
dqsclk_2_ddio                       \
dqspin_2_dqsclk                     \
] 
set  paths_for_postamble_only        [list  \
reg_2_post                          \
post_2_ddio                         \
undelayed_2_post                    \
dqspin_2_undelayed                  \
]


} elseif { $family_is_cyclone2 } {


set paths_for_all_modes		[list dq_capture sysclk_pin]
set paths_for_dqsmode_only		[list dqs_clkctrl clkctrl_capture clkctrl_resync]
set paths_for_postamble_only	[list clkctrl_posten posten_capture postctrl_posten]

} else {
error "auk_path_definitions: Unknown family $family"
}

#############################################################





if { $family_is_cyclone } {


array set   dq_2_wire    {      type                sync 

src_rtl_name        "dqzzzzzzzzzzz"                  
src_ext             ""                            
src_numbering       as_dq
src_is_pin          true

src_is_dq           true

dst_rtl_name        "altddio_bidir:\\g_dq_io:"          
dst_ext             ":dq_io|cyclone_ddio_bidir:ddio_bidir\[0\]|dataout_wire"
dst_numbering       as_ddio
dst_sqbrkt_off      true

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


array set   wire_2_ddio   {     type                sync

src_rtl_name        "altddio_bidir:\\g_dq_io:"          
src_ext             ":dq_io|cyclone_ddio_bidir:ddio_bidir\[0\]|dataout_wire"
src_numbering       as_ddio
src_sqbrkt_off      true

dst_uneven          true
dst_rtl_name0       "altddio_bidir:\\g_dq_io:"          
dst_ext0            ":dq_io|input_cell_L\[0\]"
dst_rtl_name1       "altddio_bidir:\\g_dq_io:"
dst_ext1            ":dq_io|input_cell_H\[0\]"
dst_numbering       as_ddio
dst_sqbrkt_off      true

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   ddio_2_reg      {   type                sync
src_uneven          true
src_rtl_name0       "altddio_bidir:\\g_dq_io:"          
src_ext0            ":dq_io|input_latch_L\[0\]"
src_rtl_name1       "altddio_bidir:\\g_dq_io:"
src_ext1            ":dq_io|input_cell_H\[0\]"
src_numbering       as_ddio
src_sqbrkt_off      true

dst_uneven          true
dst_rtl_name0       resynched_data          
dst_ext0            ""
dst_rtl_name1       resynched_data
dst_ext1            ""
dst_numbering       as_rdata

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


array set   clk_2_mux       {   src_rtl_name        "|mux\[0\]"
part_of_clkout_path "true"

src_ext             ""                          
src_numbering       none
dst_rtl_name        ""             
dst_ext             ""
dst_numbering       none
dst_is_pin          false
ignore_pin_prefix   true
type                clock
recursively         false
src_hdlpath         none
dst_hdlpath         none
}
set     clk_2_mux(dst_rtl_name)     ${suffix_of_node_name_driving_clk_pins}


array set   mux_2_clkpin     {  src_rtl_name        ""
src_ext             ""                          
src_numbering       none

part_of_clkout_path "true"
dst_is_clk_pin      "true"

dst_rtl_name        ""             
dst_ext             ""
dst_numbering       none
dst_is_pin          true
ignore_pin_prefix   true
type                clock 
recursively         false
src_hdlpath         none
dst_hdlpath         none
}
set     mux_2_clkpin(src_rtl_name)     ${suffix_of_node_name_driving_clk_pins}


array set   dqspin_2_dqsclk   { src_rtl_name        dqs                         type            clock   
src_ext             ""                          recursively     false
src_numbering       "as_dqs"
src_is_pin          true

dst_rtl_name        "altddio_bidir:dqs_io|cyclone_ddio_bidir:ddio_bidir\[0\]"               
dst_ext             "|dataout_wire"
dst_numbering       none

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   dqsclk_2_post     { src_rtl_name        "altddio_bidir:dqs_io|cyclone_ddio_bidir:ddio_bidir\[0\]"      type            clock   
src_ext             "|dataout_wire"                                                 recursively     false
src_numbering       "none"

dst_rtl_name        dq_enable               
dst_ext             ""
dst_numbering       as_post       

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}




array set  dqsclk_2_ddio_capture { type             clock
src_rtl_name        "altddio_bidir:dqs_io|cyclone_ddio_bidir:ddio_bidir\[0\]"         
src_ext             "|dataout_wire"       
src_numbering       "none"

dst_uneven          true

dst_rtl_name0       "altddio_bidir:\\g_dq_io:"          
dst_ext0            ":dq_io|input_cell_L\[0\]"

dst_rtl_name1       "altddio_bidir:\\g_dq_io:"
dst_ext1            ":dq_io|input_cell_H\[0\]"

dst_numbering       as_ddio
dst_sqbrkt_off      true

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}




array set dqsclk_2_ddio_resync { type               clock
src_rtl_name        "altddio_bidir:dqs_io|cyclone_ddio_bidir:ddio_bidir\[0\]"         
src_ext             "|dataout_wire"   
src_numbering       "none"

dst_uneven          true

dst_rtl_name0       "altddio_bidir:\\g_dq_io:"          
dst_ext0            ":dq_io|input_latch_L\[0\]"

dst_rtl_name1       "altddio_bidir:\\g_dq_io:"
dst_ext1            ":dq_io|input_cell_H\[0\]"

dst_numbering       as_ddio
dst_sqbrkt_off      true

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   post_2_ddio     {   type            sync
src_rtl_name        "dq_enable"         
src_ext             ""           
src_numbering       "as_post"

dst_uneven          true
dst_rtl_name0       "altddio_bidir:\\g_dq_io:"          
dst_ext0            ":dq_io|input_latch_L\[0\]"
dst_rtl_name1       "altddio_bidir:\\g_dq_io:"
dst_ext1            ":dq_io|input_cell_H\[0\]"
dst_numbering       as_ddio
dst_sqbrkt_off      true

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

if { 0 } {
array set   reg_2_post      {   src_rtl_name        dq_enable_reset             type            sync    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_rtl_name        dq_enable              
dst_ext             "~clr_pre"
dst_numbering       as_post

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}
} else {
array set   reg_2_post      {   src_rtl_name        dq_enable_reset             type            async    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_rtl_name        dq_enable              
dst_ext             ""
dst_numbering       as_post

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}
}

} elseif { $family_is_stratix2 } {



array set   dq_2_ddio       {   src_uneven          true
src_rtl_name0       "dont_care"                 type            sync         
src_ext0            "dont_care"                 recursively     false
src_rtl_name1       "dont_care"                          
src_ext1            "dont_care"
src_is_pin          true
src_numbering       as_dq

src_is_dq           true

dst_uneven          true

special_case_destination_dq_io_ddio_out_reg_use_colons      "true"
dst_rtl_name0       "\\g_dq_io"      
dst_ext0            "dq_io~ddio_out_reg"

dst_rtl_name1       dq_captured_falling
dst_ext1            ""

dst_is_pin          false
dst_numbering       as_ddio

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


array set   ddio_2_core     {   src_uneven          true
src_rtl_name0       dq_captured_rising          type            sync         
src_ext0            ""                          recursively     false
src_rtl_name1       dq_captured_falling         
src_ext1            ""
src_numbering       as_ddio

dst_uneven          true
dst_rtl_name0       resynched_data          
dst_ext0            "~feeder"
dst_rtl_name1       resynched_data
dst_ext1            "~feeder"
dst_numbering       as_rdata

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath

dont_error_on_absence   "true"
}

array set   core_2_reg      {   src_uneven          true
src_rtl_name0       resynched_data          type            sync         
src_ext0            "~feeder"                          recursively     false
src_rtl_name1       resynched_data         
src_ext1            "~feeder"
src_numbering       as_rdata

dst_uneven          true
dst_rtl_name0       resynched_data          
dst_ext0            ""
dst_rtl_name1       resynched_data
dst_ext1            ""
dst_numbering       as_rdata

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath

alternative_path    "ddio_2_reg_no_feeder"
}


array set   ddio_2_reg_no_feeder  { src_uneven          true
src_rtl_name0       dq_captured_rising          type            sync         
src_ext0            ""                          recursively     false
src_rtl_name1       dq_captured_falling         
src_ext1            ""
src_numbering       as_ddio

dst_uneven          true
dst_rtl_name0       resynched_data          
dst_ext0            ""
dst_rtl_name1       resynched_data
dst_ext1            ""
dst_numbering       as_rdata

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath

}

array set   clk_2_pin       {   src_rtl_name        ""                            
dst_is_clk_pin      true

part_of_clkout_path "true"

src_ext             ""                          
src_numbering       none

dst_rtl_name        ""             
dst_ext             ""
dst_numbering       none
dst_is_pin          true

ignore_pin_prefix   true

type                clock 
recursively         false

src_hdlpath         none
dst_hdlpath         none
}
set     clk_2_pin(src_rtl_name)     ${suffix_of_node_name_driving_clk_pins}


array set   dqsclk_2_ddio_resync   {   src_rtl_name        "dqs_clk"            type            clock    
src_ext             ""                          recursively     false
src_numbering       "fixed_value"

dst_uneven          true
dst_rtl_name0       dq_captured_rising      
dst_ext0            ""
dst_rtl_name1       dq_captured_falling
dst_ext1            ""
dst_is_pin          false
dst_numbering       as_ddio

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   dqspin_2_dqsclk {   src_rtl_name        dqs                         type            sync    
src_ext             ""                          recursively     false
src_numbering       as_dqs
src_is_pin          true

dst_rtl_name        dqs_clk              
dst_ext             ""
dst_numbering       "fixed_value"

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


if { 0 } {
array set   reg_2_post      {   src_rtl_name        dq_enable_reset             type            sync    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_rtl_name        dqs_io~regout              
dst_ext             "clr_pre"
dst_numbering       none

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}
} else {
array set   reg_2_post      {   src_rtl_name        dq_enable_reset             type            async    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_rtl_name        dqs_io~regout              
dst_ext             ""
dst_numbering       none

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}
}
array set   post_2_dqsclk   {   src_rtl_name        "dqs_io"                    type            sync    
src_ext             "~regout"                   recursively     false
src_numbering       none

dst_rtl_name        dqs_clk              
dst_ext             ""
dst_numbering       "fixed_value"

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


array set   dqsclk_2_post   {   src_rtl_name        "dqs_clk"                   type            clock    
src_ext             ""                          recursively     false
src_numbering       "fixed_value"

dst_rtl_name        "dqs_io"              
dst_ext             "~regout"
dst_numbering       "none"

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


} elseif { $family_is_stratix }  {



array set   dq_2_ddio       {   src_uneven          true
src_rtl_name0       dq                          type            sync         
src_ext0            ""                          recursively     false
src_rtl_name1       dq                          
src_ext1            ""
src_is_pin          true
src_numbering       as_dq

src_is_dq           true

dst_uneven          true
dst_rtl_name0       dq_captured_rising      
dst_ext0            "~ddio1_"
dst_rtl_name1       dq_captured_falling
dst_ext1            ""
dst_is_pin          false
dst_numbering       as_ddio

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   ddio_2_reg      {   src_uneven          true
src_rtl_name0       dq_captured_rising          type            sync         
src_ext0            ""                          recursively     false
src_rtl_name1       dq_captured_falling         
src_ext1            "~out1"
src_numbering       as_ddio

dst_uneven          true
dst_rtl_name0       resynched_data          
dst_ext0            ""
dst_rtl_name1       resynched_data
dst_ext1            ""
dst_numbering       as_rdata

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


###############






array set   undelayed_2_post  { src_rtl_name        stratix_dqs_delay_buffers               type            clock   
src_ext             ""                                      recursively     true
src_numbering       "use_num_of_buffers"

dst_rtl_name        dq_enable               
dst_ext             ""
dst_numbering       as_post

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   dqsclk_2_ddio   {   src_rtl_name        "dqs_clk"                   type            clock    
src_ext             ""                          recursively     false
src_numbering       "fixed_value"

dst_uneven          true
dst_rtl_name0       dq_captured_rising      
dst_ext0            "~ddio1_"
dst_rtl_name1       dq_captured_falling
dst_ext1            ""
dst_is_pin          false
dst_numbering       as_ddio

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

array set   post_2_ddio     {   src_rtl_name        dq_enable                   type            sync    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_uneven          true
dst_rtl_name0       dq_captured_rising      
dst_ext0            "~ddio1_"
dst_rtl_name1       dq_captured_falling
dst_ext1            ""
dst_is_pin          false
dst_numbering       as_ddio

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}




array set  dqspin_2_undelayed { src_rtl_name        dqs                         type            sync    
src_ext             ""                          recursively     false
src_numbering       as_dqs
src_is_pin          true

dst_rtl_name        stratix_dqs_delay_buffers              
dst_ext             ""
dst_numbering       "use_num_of_buffers"

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}


array set   dqspin_2_dqsclk {   src_rtl_name        dqs                         type            sync    
src_ext             ""                          recursively     false
src_numbering       as_dqs
src_is_pin          true

dst_rtl_name        dqs_clk              
dst_ext             ""
dst_numbering       "fixed_value"

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

# !!! Q&D   dst_rtl_name        "clk_to_sdram\[0\]" 




#######                         src_rtl_name        "|stratix_ddio_out_no_areset:ddio_out\[0\]|ioatom~DFFDATAOUT"

array set   clk_2_pin       {   src_rtl_name        ""                            
dst_is_clk_pin      true

part_of_clkout_path "true"

src_ext             ""                          
src_numbering       none

dst_rtl_name        ""             
dst_ext             ""
dst_numbering       none
dst_is_pin          true

ignore_pin_prefix   true

type                clock 
recursively         false

src_hdlpath         none
dst_hdlpath         none
}
set     clk_2_pin(src_rtl_name)     ${suffix_of_node_name_driving_clk_pins}




array set   pll_2_resynclk {    src_hdlpath         is_in_datapath
src_uneven          true
src_rtl_name0       dq_captured_rising          type            sync         
src_ext0            ""                          recursively     false
src_rtl_name1       dq_captured_falling         
src_ext1            "~out1"
src_numbering       as_ddio

dst_hdlpath         is_clkoutlogic
dst_uneven          true
dst_rtl_name0       resynched_data          
dst_ext0            ""
dst_rtl_name1       resynched_data
dst_ext1            ""
dst_numbering       as_rdata

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

if { 0 } {
array set   reg_2_post      {   src_rtl_name        dq_enable_reset             type            sync    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_rtl_name        dq_enable              
dst_ext             "~clr_pre"
dst_numbering       as_post

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

} else {                                 
array set   reg_2_post      {   src_rtl_name        dq_enable_reset             type            async    
src_ext             ""                          recursively     false
src_numbering       as_post

dst_rtl_name        dq_enable              
dst_ext             ""
dst_numbering       as_post

src_hdlpath         is_in_datapath
dst_hdlpath         is_in_datapath
}

}

} elseif { $family_is_cyclone2 } {
puts "path definitions not needed for cyclone2"

} else {
error "auk_path_definitions: family $family unknown"
}








######################################################################################

set extraction_failures_file        [ file join $out_file_path "${variation_name}_extraction_failures.txt" ]
if { [ catch { open $extraction_failures_file  w }   extraction_failures_id  ] } {
puts  " - ERROR: Cant open file '$extraction_failures_file' for output."
return -code 99
}

set allnodes_min_file        [ file join $out_file_path "extraction_min_allnodes.txt" ]
if { [ catch { open $allnodes_min_file  w }   min_allnodes_id  ] } {
puts  " - ERROR: Cant open file '$allnodes_min_file' for output."
return -code 99
}
set allnodes_max_file        [ file join $out_file_path "extraction_max_allnodes.txt" ]
if { [ catch { open $allnodes_max_file  w }   max_allnodes_id  ] } {
puts  " - ERROR: Cant open file '$allnodes_max_file' for output."
return -code 99
}

if { 1 } {
set data_file        [ file join $out_file_path "${variation_name}_extraction_data.txt" ]
if { [ catch { open $data_file  w }   data_id  ] } {
puts  " - ERROR: Cant open file '$data_file' for output."
return -code 99
}
# to back annotate drop the "${variation_name}_${fpga_device}_" part from the file name
set estimated_data_file        [ file join $out_file_path "${variation_name}_${fpga_device}_${family}-${fpga_speed_grade}_paths.txt" ]
if { [ catch { open $estimated_data_file  w }   estimated_id  ] } {
puts  " - ERROR: Cant open file '$estimated_data_file' for output."
return -code 99
}

}



set line_tag    "tan_arg:   "

puts $log_id  "Running   quartus_tan -t tan_arg_tcl.txt (log messages are from tcl script 'tan_arg_tcl.txt'. messages from 'quartus_tan.exe' are not logged here)" 
puts $log_id  ""
puts $log_id  "$line_tag release_state= $release_state"


########################################################################################
set     post_compile_summary_file       "${variation_name}_post_summary.txt"

set     post_compile_summary_file_path            [ file join  $out_file_path  $post_compile_summary_file  ]
if { [ catch { open $post_compile_summary_file_path  w }   post_summary_id] } {
error "Cant open file '$post_compile_summary_file_path' for output."
}

set out_id      $post_summary_id
########################################################################################



set dq_path_array_length    $gLOCAL_DATA_BITS       ;
###########################################




set  paths_of_interest  [concat $paths_for_all_modes  ]
if { $ddr_mode == "normal" } {
set  paths_of_interest  [concat $paths_of_interest  $paths_for_dqsmode_only ]
if { $enable_postamble } {
set  paths_of_interest  [concat $paths_of_interest  $paths_for_postamble_only]
}
}



########################################################################################
if { $debug_on } { puts $log_id  "$line_tag Load Packages.."  }







if { $enable_postamble } {
puts $log_id  "$line_tag Making timing assignments (when postamble enabled).."
puts $log_id  "$line_tag        set_global_assignment -name \"CUT_OFF_CLEAR_AND_PRESET_PATHS\"        \"${setting_of_cut_off_clear_and_preset_paths}\"  "
set_global_assignment -name "CUT_OFF_CLEAR_AND_PRESET_PATHS"        "${setting_of_cut_off_clear_and_preset_paths}";
}



##########################################################################
set     num_good_extractions                0
set     extraction_errors_encountered       false
set     num_extraction_errors               0


######### Stratix

#  "zz:xcd|myddr1:hier_path|














######## Cyclone











set     esc     "\\"        ;# ie  $esc is literally "\"
set rexp_legal_instance_name      {[a-zA-Z][-_a-zA-Z0-9]*}
set rexp_int                      {[0-9]+}

set known_wrapper                   $variation_name
set w                               $known_wrapper

##--------------  "  | <w>_auk_ddr_sdram: <w>_auk_ddr_sdram_inst  | <w>_auk_ddr_datapath:ddr_io  | <w>_auk_ddr_dqs_group: \g_datapath:"
set rexp_const1      "${w}_auk_ddr_sdram:${w}_auk_ddr_sdram_inst${esc}|${w}_auk_ddr_datapath:ddr_io${esc}|${w}_auk_ddr_dqs_group:${esc}${esc}g_datapath:"


set const1      "${w}_auk_ddr_sdram:${w}_auk_ddr_sdram_inst|${w}_auk_ddr_datapath:ddr_io|${w}_auk_ddr_dqs_group:${esc}g_datapath:"

##---------------------  ":g_ddr_io      |           \g_dq_io:"       --> Spaces in this quoted string are only added so the \ substitution is clear

#######################################################################





#########################################################################

if { ( $family == "stratix" || $family_is_stratix2 ) } {


set  const2             ":g_ddr_io|${esc}g_dq_io:"
set  rexp_const2        ":g_ddr_io${esc}|${esc}${esc}g_dq_io:"     


set  const3             ":dq_io~DFFDATAOUT"
set  rexp_const3        ":dq_io~DFFDATAOUT"


if { $family_is_stratix2 } {

set  const3             ":dq_io~oe_reg"
set  rexp_const3        ":dq_io~oe_reg"

}

} elseif { $family == "cyclone" } {


set  const2             ":g_ddr_io|altddio_bidir:${esc}g_dq_io:"
set  rexp_const2        ":g_ddr_io${esc}|altddio_bidir:${esc}${esc}g_dq_io:"    


set  const3             ":dq_io|mux\[0\]~COMBOUT"
set  rexp_const3        ":dq_io${esc}|mux${esc}\[0${esc}\]~COMBOUT"

} else {

set  rexp_const2        "not_yet_defined"     
set  const2             "not_yet_defined"

set  rexp_const3        "not_yet_defined"
set  const3             "not_yet_defined"
}

set rexp_suffix_for_dq_pin   "${rexp_const1}${rexp_int}${rexp_const2}${rexp_int}${rexp_const3}\$"

set pattern_for_dq_pin_matching             ".*${known_wrapper}:${rexp_legal_instance_name}${esc}|${rexp_suffix_for_dq_pin}"





set     not_found_hier             "true"           ;

set     extracted_variation_path     "path_not_found"

## init longest max and shortest min arrays
foreach  path  $paths_of_interest {
set  longest_max_paths($path)      0
set  shortest_min_paths($path)      999999
}



set zero_delay_paths    0

set src_node_error  "false"
set dst_node_error  "false"

set clkout_tco_min ""
set clkout_tco_max ""



for { set model_speed 0 } { $model_speed <= 1 } { incr model_speed } {
if { $model_speed == 0 } {
set     min_or_max      "min"
} else {
set     min_or_max      "max"
}

    ##########################################################################

if { $debug_on } { puts $log_id  "$line_tag Creating timing netlist ($min_or_max delay).." }


if { $min_or_max == "min"} {
puts $log_id "Creating min netlist"
#catch { delete_timing_netlist }
create_timing_netlist   -min
set  allnodes_id     $min_allnodes_id
} else {
puts $log_id "Creating max netlist"
#catch { delete_timing_netlist }
create_timing_netlist
set  allnodes_id     $max_allnodes_id
}




set node_count  0


array set node_ids_of_signals  { }
foreach_in_collection  node_id  [ get_timing_nodes -type all ] {
set node_name       [ get_timing_node_info -info name        $node_id ]



set node_type       [ get_timing_node_info -info type        $node_id ]
set node_location   [ get_timing_node_info -info location    $node_id ]
set location_is_a_pin       [string match {[pP][iI][nN]_*} $node_location]
if { ( $location_is_a_pin == 1 ) || ( $node_type == "pin" ) } {
set     the_node_is_a_pin       true
} else {
set     the_node_is_a_pin       false
}

if { $the_node_is_a_pin } {
set pin_name    $node_name
set sync_fanin_nodes  [get_timing_node_fanin -type sync     $node_id]
set async_fanin_nodes [get_timing_node_fanin -type async    $node_id]
set clock_fanin_nodes [get_timing_node_fanin -type clock    $node_id]
set all_fanin   [concat $sync_fanin_nodes $async_fanin_nodes $clock_fanin_nodes]

if { [llength $all_fanin] == 0 } {
set node_name_x   [append node_name "_in"]
} else {
set node_name_x   [append node_name "_out"]

if { 1 } {
                    ###### Find 'dq' pins for this variation ####


if { $min_or_max == "min"} {




foreach fanin_driving_output   $all_fanin  {
set nodeid_driving_output               [lindex $fanin_driving_output 0]
set the_string       [ get_timing_node_info -info name        $nodeid_driving_output ]

#puts $log_id  ">>>>> Node= $node_driving_output  Name= $the_string "

set got_dq_match  [regexp  $pattern_for_dq_pin_matching  $the_string]


if { $got_dq_match } {

if { $not_found_hier } {

regsub  $rexp_suffix_for_dq_pin  $the_string  ""  extracted_variation_path
if { $debug_on } { puts $log_id  " Found_hier_path=   '${extracted_variation_path}'" }   
set not_found_hier      "false"
}

regexp  $rexp_suffix_for_dq_pin    $the_string    dq_pin_suffix

set     scan_format  "${const1}%d${const2}%d${const3}"
scan    $dq_pin_suffix    $scan_format      extracted_group      extracted_index_in_group

set    extracted_dq_pin_number [expr int( ( $gMEM_DQ_PER_DQS * $extracted_group ) + $extracted_index_in_group ) ]

        ##set   pin_name      $node_name
set array_of_dq_pins($extracted_dq_pin_number)      $pin_name

if { $debug2_on } { puts $log_id  " DQ pin number is  $extracted_dq_pin_number, Pin is called  '$array_of_dq_pins($extracted_dq_pin_number)'" }  


break
}

}







}
}
}

##if { $debug_on } { puts $log_id  "$line_tag Finding hierarchy paths for clocks.." }

} else {
set node_name_x     $node_name
}
set node_ids_of_signals($node_name_x)   $node_id


incr node_count
}

if { $debug_on } { puts $log_id  "$line_tag $node_count nodes found." }


if { $family_is_stratix2 } {
foreach_in_collection node [get_timing_nodes -type pin] {
set res [::ddr::paths::extract_clk_tco $family  $settings_array(clock_generation) $settings_array(wrapper_name) [list $settings_array(clock_pos_pin_name) $settings_array(clock_neg_pin_name)]  $node clkout_tco_min clkout_tco_max]
if { $min_or_max == "min" && $res } {
puts $post_summary_id "${note_tag} Found a clock output pin: [get_timing_node_info -info name $node]"
}
}
if { $clkout_tco_min == "" || $clkout_tco_max == "" } {
puts $post_summary_id "${error_tag} Couldn't find the clock output pins. Stop."
set script_can_continue false
}
if { $script_can_continue && $min_or_max == "min" && $clkout_tco_max - $clkout_tco_min >= 100 } {


puts $post_summary_id "${cwarning_tag} [::ddr::messages::clkout_skew_too_big [expr $clkout_tco_max - $clkout_tco_min]]"
}
}





if { $model_speed == 0 } {

set num_dq_pins_found   [array  size  array_of_dq_pins]
if { $debug_on } { puts $log_id  "$line_tag $num_dq_pins_found DQ pins found for variation ${variation_name}" }

set mem_width   [expr { round ( $gLOCAL_DATA_BITS / 2.0 ) }]
if { $num_dq_pins_found != $mem_width } { 
puts $post_summary_id "${error_tag} $num_dq_pins_found DQ pins found for variation '${variation_name}' but it was configured to be $mem_width bits wide."
}

if { $debug_on } { puts $log_id  "$line_tag Finding hierarchy paths for clocks.." }
set break_out       "false"



proc find_hier_using_pin { pin_name  name_suffix } {


#global      user_clocklogic_instance_name           ;

# Stratix ---->   "|stratix_ddio_out:ddio_out[0]"
# StratixII -->   "|ddio_out_69a:auto_generated"
# Cyclone ---->   ""

global      error_in_proc_find_hier_using_pin
global      error_in_proc_sig2node
global      log_id  line_tag

set     no_matches     "true"
set     found_path     "path_not_found"


set pin_timing_node_name        "${pin_name}_out"

set     pin_timing_node   [sig2node $pin_timing_node_name]

if { $error_in_proc_sig2node != "none" } {
set this_error      " Timing node '$pin_timing_node_name' (pin name = '$pin_name') cannot be found"
puts $log_id               "ERROR: $this_error"
set error_in_proc_find_hier_using_pin   $this_error
return  $found_path
} else {


set pin_fanin_nodes [get_timing_node_fanin -type sync    $pin_timing_node ]

foreach fanin $pin_fanin_nodes {
set src_node               [lindex $fanin 0]
set src_node_name       [ get_timing_node_info -info name        $src_node ]

if { $no_matches } {
if { [string first $name_suffix  $src_node_name ] != -1 } {
set no_matches     "false"
puts $log_id       " Found timing node '$src_node_name' feeding node '$pin_timing_node_name' (pin name = '$pin_name')"
set  found_path     [::ddr::utils::string_chop_right $src_node_name  $name_suffix]
puts $log_id       " Hierarchy path to this node is '$found_path'."
}
}
}

if { $no_matches } {
set this_error     " Cant find path to pin '$pin_name' (timing node = '${pin_timing_node_name}') "
puts $log_id  "$line_tag ERROR: $this_error"
set error_in_proc_find_hier_using_pin    $this_error
} 

return  $found_path
}
}









#                                                                                     ${e}         ${g} ${g}       ${g}     ${e}   ${g} ${g}






if { $not_found_hier } {
set     script_can_continue                 "false"
set     $extraction_errors_encountered      "true"
set     break_out                           "true"

puts    $post_summary_id  "${error_tag}  Can't find hierarchy path."
}

if { $extracted_variation_path == "path_not_found" } {
puts  $post_summary_id  "${error_tag}  The hierarchy path could not be found, possibly due to previous errors"
} elseif { $settings_array(manual_hierarchy_control) == "true" && $extracted_variation_path != $settings_array(variation_path) } {

puts  $post_summary_id  "${warning_tag}  User entered path does not match path extrated from timing netlist; User specified path is  '$settings_array(variation_path)'  but extracted path is  '$extracted_variation_path'"
puts  $post_summary_id  "${extrainfo_tag_pretty} The above warning means that you may have incorrectly entered the hierarchy path for your instance in the DDR Megawizard (for variation '${variation_name}')."
puts  $post_summary_id  "${extrainfo_tag_pretty} This means that the constraints may have not been correctly applied to your design before you compiled in Quartus II and the design may not meet timing or the verify-timing script may not run."
puts  $post_summary_id  "${extrainfo_tag_pretty} Timing analysis will attempt to continue using the extracted path, but it is recommended that you re-run the design flow from the megawizard and enter the correct hierarchy path."
}



if {! $family_is_stratix2 } {
set     extracted_clkp_path             [find_hier_using_pin  "${clock_pos_pin_name}"   $suffix_of_node_name_driving_clk_pins]

if { $error_in_proc_find_hier_using_pin != "none" } {
set     script_can_continue                 "false"
set     $extraction_errors_encountered      "true"
set     break_out                           "true"

puts  $post_summary_id  "${error_tag}  $error_in_proc_find_hier_using_pin"
puts  $post_summary_id  "${extrainfo_tag_pretty}  The possible cause of the above error is that you have not entered the correct positive clock pin name for variation '${variation_name}'."
set   error_in_proc_find_hier_using_pin       "none"
}


set     extracted_clkn_path             [find_hier_using_pin  "${clock_neg_pin_name}"   $suffix_of_node_name_driving_clk_pins]

if { $error_in_proc_find_hier_using_pin != "none" } {
set     script_can_continue                 "false"
set     $extraction_errors_encountered      "true"
set     break_out                           "true"

puts  $post_summary_id  "${error_tag}  $error_in_proc_find_hier_using_pin"
puts  $post_summary_id  "${extrainfo_tag_pretty}  The possible cause of the above error is that you have not entered the correct negative clock pin name for variation '${variation_name}'."
set   error_in_proc_find_hier_using_pin       "none"
}
}


#set suffix_of_node_name_driving_clk_pins  "$user_clocklogic_instance_name$end_suffix_of_node_name_driving_clk_pins"


if { $break_out } {
break
}     
set     signal_hdlpath1                "${extracted_variation_path}${datapath_hdlpath}"







set rootpath "${extracted_variation_path}${datapath_hdlpath}0${signal_hdlpath2}"
# rootpath will be something like "fred:fred_ddr_sdram|fred_auk_ddr_sdram:fred_auk_ddr_sdram_inst|fred_auk_ddr_datapath:ddr_io|fred_auk_ddr_dqs_group:\g_datapath:0:g_ddr_io|"

puts $log_id "ddr_mode is $ddr_mode"
if { $settings_array(fedback_clock_mode) != "true" } {
if {$ddr_mode == "normal" }  {

if { $chosen_resynch_clock == "dedicated" } {
set resync_failed [catch {
set pllres [lindex [::ddr::extract::pll_phase  "${rootpath}wdata_r\[0\]"  "${rootpath}resynched_data\[0\]"  $clock_period] 1]
puts $log_id "Detected pll phase for resync of [format %.2f $pllres]"
puts $log_id "Changing chosen_resynch_phase from $chosen_resynch_phase to [format %.2f $pllres] degrees to match reality"
if { $chosen_resynch_phase - 10 > $pllres ||  $chosen_resynch_phase + 10 < $pllres } {
puts $post_summary_id "${cwarning_tag} The dedicated resynchronization clock should have a $chosen_resynch_phase degree phase shift but has a [format %.0f $pllres] degree phase shift."
puts $post_summary_id "${cwarning_tag} Check that the phase shift applied to the relevant PLL output clock matches that recommended by the MegaWizard."
}			
set chosen_resynch_phase $pllres
}]
if { $resync_failed } {
puts $post_summary_id "${cwarning_tag} Could not find 'wdata_r' or 'resynched_data' registers needed to check PLL offsets. Will continue assuming resynch PLL is set to $chosen_resynch_phase"
}
}

if { $enable_postamble && $chosen_postamble_clock == "dedicated" } {
set failed [catch {
set pllres [lindex [::ddr::extract::pll_phase  "${rootpath}wdata_r\[0\]"  "${rootpath}dq_enable_reset\[0\]"  $clock_period] 1]
puts $log_id "Detected pll phase for postamble of [format %.2f $pllres]"
puts $log_id "Changing chosen_postamble_phase from $chosen_postamble_phase to [format %.2f $pllres] degrees to match reality"
if { $chosen_postamble_phase - 10 > $pllres ||  $chosen_postamble_phase + 10 < $pllres } {
puts $post_summary_id "${cwarning_tag} The dedicated postamble clock should have a $chosen_postamble_phase degree phase shift but has a [format %.0f $pllres] degree phase shift."
puts $post_summary_id "${cwarning_tag} Check that the phase shift applied to the relevant PLL output clock matches that recommended by the MegaWizard."
}			
set chosen_postamble_phase $pllres
}]
if { $failed } {
puts $post_summary_id "${cwarning_tag} Could not find 'wdata_r' or 'dq_enable_reset' registers needed to check PLL offsets. Will continue assuming Postamble PLL is set to $chosen_postamble_phase"
}
}

} elseif { $ddr_mode == "non-dqs" }  {

set failed [catch {
set pllres [lindex [::ddr::extract::pll_phase  "${rootpath}wdata_r\[0\]"  "${rootpath}dq_captured_rising\[0\]"  $clock_period] 1]
puts $log_id "Detected pll phase for capture of [format %.2f $pllres] should have been $chosen_capture_phase"
puts $log_id "Changing chosen_capture_phase from $chosen_capture_phase to [format %.2f $pllres] degrees to match reality"
if { $chosen_capture_phase - 10 > $pllres ||  $chosen_capture_phase + 10 < $pllres } {
puts $post_summary_id "${cwarning_tag} The dedicated capture clock should have a $chosen_capture_phase degree phase shift but has a [format %.0f $pllres] degree phase shift."
puts $post_summary_id "${cwarning_tag} Check that the phase shift applied to the relevant PLL output clock matches that recommended by the MegaWizard."
}			
set chosen_capture_phase $pllres
}]
if { $failed } {
puts $post_summary_id "${cwarning_tag} Could not find 'wdata_r' or 'dq_captured_rising' registers needed to check capture PLL offset. Will continue assuming Capture PLL is set to $chosen_capture_phase"
}
} else {
puts $post_summary_id "${error_tag} Unknown ddr_mode:$ddr_mode. Stop."
return 
}
} else {

if { $chosen_resynch_clock == "dedicated" || ($enable_postamble && $chosen_postamble_clock == "dedicated") } {
puts $post_summary_id "${note_tag} PLL Phase extraction not performed for fed-back clock mode. Assuming the PLL is set up as recommended by the DDR MegaCore."
}
}
}


if { $script_can_continue } {

        #########################################################################

        #########################################################################
if { $extract_ddr_megacore_paths  } {

if { $debug_on } { puts $log_id  "$line_tag Getting DDR-SDRAM Megacore specific delay paths.." }



if { 0 } {
set dq_path_array_length    2
puts $post_summary_id "${error_tag} Array length limited to 2 for test"
}

for { set i 0 } { $i <  $dq_path_array_length } { incr i } {

set array_name      "${min_or_max}_paths_for_each_half_dq_$i" 


lappend  ddr_timings_list_of_array_names     $array_name
foreach  path  $paths_of_interest {

if { $family_is_stratix2 && $path == "clk_2_pin" } {
if { $min_or_max == "max" } {
set ${array_name}($path) $clkout_tco_max
} elseif { $min_or_max == "min" } {
set ${array_name}($path) $clkout_tco_min
} else { ::ddr::utils::assert {0} {$min_or_max} }
continue
}

set path_delay      [ extract_ddr_path_alt  $path  $i ]



if {  $error_in_proc_get_node2node_delay != "none"  } {
set     stop_extractions    "true"
puts $post_summary_id   "${error_tag} $error_in_proc_get_node2node_delay"
user_help_info_for_misc_extraction_errors    $post_summary_id
break
}
if {  $error_in_proc_sig2node != "none"  } {
set     stop_extractions    "true"
puts $post_summary_id   "${error_tag} $error_in_proc_sig2node"
user_help_info_for_misc_extraction_errors    $post_summary_id
break
}

set ${array_name}($path)      $path_delay

if { [string is integer $path_delay] != 1 } {
set     extraction_errors_encountered       true
incr    num_extraction_errors
puts    $extraction_failures_id "$path_delay"
} else {
incr    num_good_extractions
}


if { $model_speed == 0 } {
if { $path_delay < $shortest_min_paths($path) } {
set  shortest_min_paths($path)  $path_delay
}
} else {
if { $path_delay > $longest_max_paths($path) } {
set  longest_max_paths($path)  $path_delay
}
}
}



if { $stop_extractions } {
break
}
}

}

if { $debug_on } { puts $log_id  "$line_tag Deleting $min_or_max timing netlist.." }
delete_timing_netlist
}
if { $stop_extractions } {
break
}
}



####################################################################################

if { $stop_extractions } {
set this_error  "Extractions stopped due to error"
puts $log_id              "${error_tag} $this_error"
puts $post_summary_id     "${error_tag} $this_error"
set   extraction_errors_encountered       "true"
set   script_can_continue                 "false"
}

puts $log_id  "$line_tag $num_good_extractions paths successfully extracted."
puts $log_id  "$line_tag There were $zero_delay_paths zero delay paths"

if { $extraction_errors_encountered } {
puts $log_id  "$line_tag ERROR: Unable to extract all required DDR-SDRAM signal path delays ($num_extraction_errors errors)"
} else {
if { $debug_on } {
if { $extract_ddr_megacore_paths } {
puts $log_id                    "$line_tag All paths extracted successfully."
puts $extraction_failures_id    "There were no extraction failures."
} else {
puts $log_id                    "$line_tag *** WARNING *** No paths were extracted."
puts $extraction_failures_id    "Extraction was disabled."
}
}
}

#######################################


##  $stratixii_dqs_phase in settings file



set shortest_min_paths(clk_2_pin) $clkout_tco_min
set longest_max_paths(clk_2_pin) $clkout_tco_max



if { $family_is_stratix && ( $ddr_mode == "normal" ) } {

if { $dqs_phase_stratix == "72" } {
set     phase_div   5.0
} else {
set     phase_div   4.0
}
set     phase_shift_ps      [expr { round ( $clock_period / $phase_div ) } ]
set     do_subtract_shift_for_stratix       "true"
} elseif { $family_is_stratix2 && ( $ddr_mode == "normal" ) } {
set     phase_shift_ps      [expr { round ( $clock_period * $settings_array(stratixii_dqs_phase)  / 36000.0 ) } ]
set     do_subtract_shift_for_stratix       "true"
} else { 
set     do_subtract_shift_for_stratix       "false"
}

if { $format_estimated_data_file_for_back_annotating } {
set estimated_data_min_heading  "array_name=    min_paths_for_each_half_dq_0"
set estimated_data_max_heading  "array_name=    max_paths_for_each_half_dq_0"
} else {
set estimated_data_min_heading "Shortest MIN:"
set estimated_data_max_heading "Longest MAX:"
}

puts $log_id                    "$line_tag Dumping estimated paths.."

puts $estimated_id  $estimated_data_min_heading

foreach path $paths_of_interest {
puts $estimated_id "[format "    %-20s  %5s" $path   $shortest_min_paths($path)]"
}
if { $do_subtract_shift_for_stratix } {
set val_min_dqspin_2_dqsclk_minus_tshift        [expr { round ( $shortest_min_paths(dqspin_2_dqsclk) - $phase_shift_ps ) } ]  
puts $estimated_id "[format "    %-20s  %5s"  "dqspin_2_dqsclk_minus_tshift" $val_min_dqspin_2_dqsclk_minus_tshift  ]"
}
puts $estimated_id $estimated_data_max_heading

foreach path $paths_of_interest {
puts $estimated_id "[format "    %-20s  %5s" $path   $longest_max_paths($path)]"
}
if { $do_subtract_shift_for_stratix } {
set val_max_dqspin_2_dqsclk_minus_tshift        [expr { round ( $longest_max_paths(dqspin_2_dqsclk) - $phase_shift_ps ) } ]
puts $estimated_id "[format "    %-20s  %5s"  "dqspin_2_dqsclk_minus_tshift"   $val_max_dqspin_2_dqsclk_minus_tshift  ]"
}


#####################################

if { $script_can_continue } {
if { ( $extract_ddr_megacore_paths ) && ( $run_ddr_system_timing ) } {
if { $debug_on } {
puts $log_id  "$line_tag Running DDR system timing analysis equations.."
}

puts $post_summary_id "Running DDR system timing analysis equations.. pwd:[pwd]"
if { [file exists store_vars.tcl] } {
source store_vars.tcl
}

        ##########################
cd $settings_array(wrapper_path)
source  [file join $settings_array(current_script_working_dir) ddr_system_timing.tcl]
        ##########################
}
if { $debug_on } { puts $log_id  "$line_tag DDR System Timing analysis complete." }
} else {
puts $log_id        "$line_tag Skipping DDR system timing analysis equations. (script_can_continue = false)"
puts $post_summary_id         "Skipping DDR system timing analysis equations."
}
####################################################################################

project_close  -dont_export_assignments


if { $log_to_file != "true" } {
puts $doesnt_exist
}



foreach f [file channels file*] {
close $f
}
