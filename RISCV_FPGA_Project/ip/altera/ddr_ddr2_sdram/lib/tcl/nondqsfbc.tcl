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






package provide ::ddr::nondqsfbc 0.1 

package require ::ddr::utils
package require ::ddr::type
package require ::ddr::phasesel
package require ::ddr::paths
package require ::ddr::extract
package require ::ddr::data


namespace eval ::ddr::nondqsfbc {
namespace export extract_s2_paths
namespace export delay_t
namespace export extparam_from_ddr_timing_args
variable foundNodes
variable delay_t
variable delay_partial_t

if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}
if { [package require ::ddr::extract] != "" }   { namespace import ::ddr::extract::*	}

proc helperInit {} {
variable foundNodes ;
if { [array exists foundNodes] } {
array unset foundNodes
}
set foundNodes(LCapture) 0
set foundNodes(HCapture) 0
set foundNodes(LResync) 0
set foundNodes(HResync) 0
}

proc helperReport { } {
variable foundNodes
if { $foundNodes(LCapture) == 0 } {
logmsg warn "Failed to find any lower capture registers"
}
if { $foundNodes(HCapture) == 0 } {
logmsg warn "Failed to find any upper capture registers"
}
if { $foundNodes(LResync) == 0 } {
logmsg warn "Failed to find any lower resync registers"
}
if { $foundNodes(HResync) == 0 } {
logmsg warn "Failed to find any upper resync registers"
}

}



proc log { name {msg "" } } {
variable foundNodes
switch -- $name {
info {
logmsg info $msg
}
FoundLCaptureReg {
incr foundNodes(LCapture)
}
FoundHCaptureReg {
incr foundNodes(HCapture)
}			
FoundLResyncReg {
incr foundNodes(LResync)
}
FoundHResyncReg {
incr foundNodes(HResync)
}
default {
assert { 0 } {$name} "unknown name"
}
}

}	

proc logmsg {level msg } {
if { [string match -* $msg] } { set msg " $msg" } ; # deal with the case msg is "-type"
postmessage $msg
}

















# no comments allowed in the following {} 
set delay_t { struct
tco_ck int
tco_fedback int
utco_le int
usu_le int
uhold_le int
utco_ioe int
usu_ioe int
uhold_ioe int
dq_capture int 
pin_fedback int
fedback_capture int
fedback_resync int
capture_resync int
name str
number int
}





set delay_partial_t { struct 
tco_ck {enum h l}
tco_fedback {enum h l}
dq_capture int 
pin_fedback int
fedback_capture int
fedback_resync int
capture_resync int
name str
number int
}














set externalParam_t {struct
trace_delay_dq int
trace_delay_ck int
trace_delay_fedback int
trace_skew int
period int
tAC_hold int
tAC_setup int
CAS_L str
tHP int
tco_vs_tco_skew int

}











set setup_t { struct
fedback_capture_phase int
resync_phase int
resync_cycle int
}




proc extparam_from_ddr_timing_args {ddr_timing_args_var} {
variable externalParam_t
upvar 1 $ddr_timing_args_var ddr_timing_args
assert {[info exists ddr_timing_args]} {$ddr_timing_args_var}

sett {clock_freq period} [::ddr::utils::normalise_clock_frequency $ddr_timing_args(clock_freq_in_mhz)]

set res [list trace_delay_dq $ddr_timing_args(board_tPD_dqs_trace_total_NOM) \
trace_delay_ck $ddr_timing_args(board_tPD_clock_trace_NOM) \
trace_delay_fedback $ddr_timing_args(tpd_clockfeedback_trace_nom) \
trace_skew $ddr_timing_args(board_tSKEW_data_group) \
period $period \
tAC_setup $ddr_timing_args(memory_tAC) \
tAC_hold [expr {0 - $ddr_timing_args(memory_tAC)}] \
CAS_L $ddr_timing_args(cas_latency) \
tHP 0.45 \
tco_vs_tco_skew 50 ]
::ddr::type::check $externalParam_t $res
return $res
}	



















proc analyse { delays_a setup_a extparam_a pvt } {
#writeout "d:/temp/temp.tcl" { delays setup extparam pvt }
variable delay_t
variable setup_t 
variable externalParam_t
assert { [info exists delay_t]}
assert { [info exists setup_t]}
assert { [info exists externalParam_t]}
::ddr::type::check $delay_t $delays_a "::ddr::nondqsfbc::analyse"
::ddr::type::check $setup_t $setup_a
::ddr::type::check $externalParam_t $extparam_a
::ddr::type::check [list enum fast slow] $pvt
array set delays $delays_a
array set setup $setup_a
array set extparam $extparam_a

set ocv 0.03

set pll_combined_error 255








if { $delays(dq_capture) > $delays(pin_fedback) + $delays(fedback_capture) } {

set delays(fedback_capture) [expr {$delays(fedback_capture) + $extparam(period)} ]
set delays(fedback_resync) [expr {$delays(fedback_resync) + $extparam(period)} ]
}



set data_cas_adj [expr {fmod ($extparam(CAS_L),1.0) * $extparam(period) } ]

set valid [expr {$delays(tco_ck) + $extparam(trace_delay_ck) + $extparam(tAC_setup) + $extparam(trace_delay_dq) +  $delays(dq_capture) } ]
set valid [expr { $valid + ($pvt=="slow" ? 1 : -1) * $extparam(trace_skew) } ]
set valid_ocv [ expr {2 * $extparam(trace_skew) + 0.5*$extparam(tco_vs_tco_skew) } ]

if { $pvt == "slow" } {
set valid_late [expr  {$valid} ]	
} else {
set valid_late [expr  {$valid + $valid_ocv} ]	
}

set valid_late [expr {$valid_late+$data_cas_adj}] ;



set invalid [expr {$delays(tco_ck) + $extparam(trace_delay_ck) + ($extparam(period) * $extparam(tHP)) +  $extparam(tAC_hold) +  $extparam(trace_delay_dq) +  $delays(dq_capture) } ]
set invalid [expr {$invalid + ($pvt=="slow" ? 1 : -1) * $extparam(trace_skew) } ]
set invalid_ocv [expr {2 * $extparam(trace_skew) + 0.5*$extparam(tco_vs_tco_skew) } ]

if { $pvt == "slow" } {
set invalid_early [expr  {$invalid - $invalid_ocv} ]	
} else {
set invalid_early [expr  {$invalid} ]	
}

set invalid_early [expr {$invalid_early + $data_cas_adj}] ;


set clock_time [expr {$delays(tco_fedback) + $extparam(trace_delay_fedback) + $delays(pin_fedback) + $delays(fedback_capture) }]
set clock_time [expr {$clock_time + ($pvt=="slow" ? 1 : -1) * (0.5*$extparam(trace_skew) + $pll_combined_error )} ]
set clock_time_ocv [expr { $extparam(trace_skew) + 0.5*$extparam(tco_vs_tco_skew) + 2*$pll_combined_error } ]

if { $pvt == "slow" } {
set clock_time_early [expr  {$clock_time - $clock_time_ocv} ]	
set clock_time_late [expr  {$clock_time } ]	
} else {
set clock_time_early [expr  {$clock_time } ]	
set clock_time_late [expr  {$clock_time + $clock_time_ocv} ]	
}
set clock_time_early [expr {  ($clock_time_early) } ]
set clock_time_late [expr {  ($clock_time_late) } ]

#puts stderr "valid: $valid_late"
#puts stderr "invalid: $invalid_early"
#puts stderr "clock: $clock_time_early -- $clock_time_late" 


set capture_setup [expr {round ($clock_time_early - $valid_late - $delays(usu_ioe) )}]
set capture_hold  [expr {round ($invalid_early - $clock_time_late - $delays(uhold_ioe))}]






set resync_valid [expr {$delays(tco_fedback) + $extparam(trace_delay_fedback) + $delays(pin_fedback) + $delays(fedback_resync) + $delays(utco_ioe) + 0.5*$extparam(period) + $delays(capture_resync)}]
set resync_valid [expr {$resync_valid + ($pvt=="slow" ? 1 : -1) * ($extparam(trace_skew) + $pll_combined_error )} ]


set cycles_to_add [expr {int($extparam(CAS_L)) - 2 -1 } ]
set resync_valid [expr {$resync_valid + $cycles_to_add * $extparam(period)} ]


set resync_valid_ocv [expr { 2*$extparam(trace_skew) + 2*$pll_combined_error + $ocv * ( $delays(tco_fedback) + $delays(utco_ioe) + $delays(capture_resync) ) } ]
if { $pvt == "slow" } {
set resync_valid_late [expr { ($resync_valid) }]
} else {
set resync_valid_late [expr {($resync_valid + $resync_valid_ocv) } ] 
}


set resync_invalid [expr {$resync_valid + $extparam(period)}]
set resync_invalid_ocv [ expr { $resync_valid_ocv } ]
if { $pvt == "slow" } {
set resync_invalid_early [expr { ($resync_invalid - $resync_invalid_ocv) }]	
} else {
set resync_invalid_early [expr { ($resync_invalid) }]		
}


set resync_clock_time [expr { ($extparam(period) * ( $setup(resync_cycle) + $setup(resync_phase)/360.0) )} ]

set resync_setup [expr {round ($resync_clock_time - $resync_valid_late - $delays(usu_le)) }]
set resync_hold  [expr {round ($resync_invalid_early - $resync_clock_time - $delays(uhold_le)) }]

#puts stderr "resync setup ($pvt):$resync_clock_time -  $resync_valid_late - $tSU($pvt) => $resync_setup"
#puts stderr "resync hold ($pvt): $resync_invalid_early - $resync_clock_time - $tHOLD($pvt) => $resync_hold"


return [list [list $capture_setup $capture_hold] [list $resync_setup $resync_hold]]
}




#  or "" otherwise

proc extract_s2_paths { node wrappername debugproc} {
if { [get_timing_node_info -info type $node] != "pin" } { error "node $node ([get_timing_node_info -info name]) is not a pin" }
if { [info commands $debugproc] == "" } { error "debugproc $debugproc doesn't exist" }
if { [llength [info args $debugproc]] != 2 } { error "debugproc $debugproc has wrong args, wanted two got [info args $debugproc]" }


set fanout [get_timing_node_fanout $node]
if { [llength $fanout]  != 2 } { 
return ""
}
set int_node_name [get_timing_node_info -info name [lindex $fanout 0 0 ]]
if { ! [regexp "\\|${wrappername}_auk_ddr_datapath:ddr_io\\|" $int_node_name] } {
#puts "regexp no match \\|${wrappername}_auk_ddr_datapath:ddr_io\\| $int_node_name"
return ""
}
#puts "got pin"

set dq_pin_name [get_timing_node_info -info name $node]
#puts "-------------------------\npin $dq_pin_name is a DQ pin for $wrappername"
$debugproc dqpin $node


array unset lresult
array unset hresult


foreach hl { h l } {
set delays(dq_capture) 0
set regnode $node
set errmsg "" 
#puts "regnode is [dump_node $regnode]"
#follow_edge2 regnode fanout {~COMBOUT$} delays(dq_capture) $debugproc errmsg
#	assert { $delays(dq_capture) > 0 } { $delays(dq_capture) }
set risingfalling [expr { $hl == "l" ? "rising" : "falling" } ]
if { $hl == "h" } {
follow_edge2 regnode fanout "dq_captured_${risingfalling}\\\[\[0-9\]+\\\]\$" delays(dq_capture) $debugproc errmsg
} else {
follow_edge2 regnode fanout "\\\\g_dq_io:\[0-9\]+:dq_io~ddio_out_reg\$"      delays(dq_capture) $debugproc errmsg			
}
if { $errmsg != "" } {
puts "-------failed-----"
puts $errmsg 
puts "------------------"
} else { 
#puts "$hl Register is [dump_node $regnode]"
}

set delays(capture_resync) 0 
set resyncnode $regnode


if { $hl == "l" } {
follow_edge2 resyncnode fanout "dq_captured_${risingfalling}\\\[\[0-9\]+\\\]\$" "" $debugproc errmsg
set latchnode $resyncnode
} 

follow_edge2 resyncnode fanout "resynched_data\\\[\[0-9\]+\\\]\$" delays(capture_resync) $debugproc errmsg
#puts "resync node is [dump_node $resyncnode]"


set delays(fedback_capture) 0
set fbcnode $regnode
follow_edge2 fbcnode clock "altpll_component\\|_clk0\$"  delays(fedback_capture) $debugproc errmsg
follow_edge2 fbcnode clock ""  delays(fedback_capture) $debugproc errmsg ;


set delays(pin_fedback) 0
set pinnode $fbcnode
for { set i 0 } { $i < 4 } { incr i } {
if { [llength [get_timing_node_fanin -type clock $pinnode]] == "1" } {
follow_edge2 pinnode clock ""  delays(pin_fedback) $debugproc errmsg
} else {
break
}
}
if { ! [string match PIN_* [get_timing_node_info -info location $pinnode]] || [get_timing_node_info -info type $pinnode] != "clk" || [llength [get_timing_node_fanin -type clock $pinnode]] != "0" } {

assert {0} {$fbcnode {[dump_node $pinnode]}} "Couldn't find node of type clk when after fbc input. Is the fed-back clock input assigned to a pin?"  
}

#puts "fedback2 pin is [dump_node $pinnode]"


if { $hl == "l" } {
set delays(fedback_resync) 0
set latchfbcnode $latchnode
follow_edge2 latchfbcnode clock "altpll_component\\|_clk0\$"  delays(fedback_resync) $debugproc errmsg
follow_edge2 latchfbcnode clock ""  delays(fedback_resync) $debugproc errmsg 
assert { $latchfbcnode == $fbcnode } {{[dump_node $latchfbcnode]} {[dump_node $fbcnode]}}
} else {

set delays(fedback_resync) $delays(fedback_capture)
}

assert { $errmsg=="" } {$errmsg}



set re $wrappername
append re {_auk_ddr_dqs_group:\\g_datapath:([0-9]+):g_ddr_io\|resynched_data\[([0-9]+)\]$}
set resync_reg_name [get_timing_node_info -info name $resyncnode]
if { [regexp $re $resync_reg_name foobar dqsgroupnumber half_dq_number] } {
set half_dq_number [expr {$dqsgroupnumber *16 + $half_dq_number} ]
} else {
log info "Couldn't extract dq pin number from resync register: $resync_reg_name"
set half_dq_number 0
}
set delays(name) $dq_pin_name
set delays(number) $half_dq_number
set delays(tco_ck) $hl
set delays(tco_fedback) $hl
foreach {k v} [array get delays] {
if { $v == "h" } { 

} elseif {$v == "l" } {

} elseif { $k == "name" } {

} elseif { $k == "number" && [string is integer $v] } {

} elseif {[string is integer $v] && ($v > 0) } { 

} elseif {$k== "fedback_capture" &&  [string is integer $v]  } {

} elseif {$k== "fedback_resync" &&  [string is integer $v]  } {

} else {
assert {false} {$k $v} "Delay unreasonable"
}
}

set diff [expr {$delays(fedback_resync) - $delays(fedback_capture)} ]
if { $diff < 0.0 } { set diff [expr { 0.0 - $diff} ] }
assert { $diff < 300 } { $diff $delays(name) $delays(number) $delays(fedback_resync) $delays(fedback_capture) }
array set ${hl}result [array get delays]
array unset delays
if { $errmsg != "" } {
error "$errmsg"
}

}



set ratio [expr { $lresult(dq_capture) *1.0 / $hresult(dq_capture) } ] 
if { $ratio < 1.0 } { set ratio [expr { 1.0 / $ratio} ] }
assert { $ratio < 1.5 } { $ratio $lresult(name) $lresult(number)  $hresult(number) $lresult(dq_capture) $hresult(dq_capture) } 




set res_l [array get lresult]
set res_h [array get hresult]
variable delay_partial_t
::ddr::type::check $delay_partial_t $res_l
::ddr::type::check $delay_partial_t $res_h
return [list $res_l $res_h]
}


















# array set delays {dq_capture 619 tco_fedback 1053 pin_fedback 473 capture_resync 382 fedback_resync 1517 fedback_capture 1517 tco_ck 1053}

# array set delays {dq_capture 988 tco_fedback 1920 pin_fedback 844 capture_resync 820 fedback_resync 1500 fedback_capture 1528 tco_ck 1920}

# array set delays {dq_capture 1119 tco_fedback 2180 pin_fedback 964 capture_resync 943 fedback_resync 1444 fedback_capture 1477 tco_ck 2180}

# array set delays {dq_capture 1288 tco_fedback 2277 pin_fedback 1117 capture_resync 1099 fedback_resync 1373 fedback_capture 1411 tco_ck 2277}

proc estimatedData { pvt speed_grade clock_period fedback_pll } {
::ddr::type::check [list enum fast slow] $pvt
::ddr::type::check [list enum c3 c4 c5 i4 i5] $speed_grade
::ddr::type::check int $clock_period "estimatedData.clock_period"
::ddr::type::check int $fedback_pll "estimatedData.fedback_pll"
array set delays {}

set delays_l [list]
if { [info procs back_ann_est_data] != ""} {
catch {
set delays_l [::ddr::nondqsfbc::back_ann_est_data $pvt]
}
}
if { $delays_l == "" } {
if { $pvt == "slow" } {
if { $speed_grade == "c3" } {
set delays_l {dq_capture 1024 tco_fedback 2028 pin_fedback 556 capture_resync 784 fedback_resync 477 fedback_capture 521 tco_ck 2028}
} elseif { $speed_grade == "c4" || $speed_grade == "i4" } {
set delays_l {dq_capture 1163 tco_fedback 2304 pin_fedback 630 capture_resync 909 fedback_resync 548 fedback_capture 599 tco_ck 2304}
} elseif { $speed_grade == "c5" || $speed_grade == "i5" } {
set delays_l {dq_capture 1343 tco_fedback 2412 pin_fedback 724 capture_resync 1062 fedback_resync 666 fedback_capture 725 tco_ck 2412}
} else {
assert {0} {$speed_grade} "Unsupported speed grade"
}
} elseif {$pvt == "fast" } {
set delays_l {dq_capture 621 tco_fedback 1101 pin_fedback 396 capture_resync 263 fedback_resync 241 fedback_capture 241 tco_ck 1101}
} else { assert {0} {$pvt} "Unreachable state" }
}
array set delays $delays_l

set pll_delay [expr {round( $fedback_pll /360.0 * $clock_period) } ]
		##nagelfar variable delays(fedback_capture)
		##nagelfar variable delays(fedback_resync)
incr delays(fedback_capture) $pll_delay
incr delays(fedback_resync) $pll_delay

set delays(name) "dq_estimated"
set delays(number) 0
set res [array get delays]
set res [concat $res [::ddr::data::get_micro_params $speed_grade $pvt]]

array unset delays
variable delay_t
::ddr::type::check $delay_t $res "::ddr:nondqsfbc::estimatedData"
return $res
}







#  * int fedback_pll - The chosen angle of the fedback capture pll if it is overidden, or "" for 'script gets to choose' 
#  * (int * int) resync_settings - A tuple of cycle, phase of the resync settings to force, or "" if the script should choose.





proc precompileSetup { extparam_a fedback_pll resync_settings speed_grade} {
variable externalParam_t
::ddr::type::check $externalParam_t $extparam_a
array set extparam $extparam_a
if { $fedback_pll == "" } {
set pll_guess 90  ;
set estMargin "" 
foreach pvt {fast slow} {
set est_delays_f [::ddr::nondqsfbc::estimatedData $pvt $speed_grade $extparam(period) $pll_guess ]
#puts "delays in precompile are $est_delays_f"
set setup [list fedback_capture_phase $pll_guess resync_phase 0 resync_cycle 0]
sett {capture resync}  [::ddr::nondqsfbc::analyse $est_delays_f $setup $extparam_a $pvt]
#puts "got $pvt margins $capture"
fold_margins estMargin $capture
}
sett {setup hold} $estMargin
#puts "$pll_guess degree margins are $estMargin"
set pll_shift [expr { 0.5 * ($hold - $setup)} ]
set fedback_pll [expr {round($pll_guess + 360.0  * $pll_shift / $extparam(period) )} ]
#puts "margins are currently $setup -- $hold. Moving by $pll_shift with $fedback_pll of pll (period $extparam(period))"
} else {

}

if { $resync_settings == "" } {

set res [list fedback_capture_phase $fedback_pll resync_phase 0 resync_cycle 0]
set resync_margins ""
foreach pvt {fast slow} {
set delays [::ddr::nondqsfbc::estimatedData $pvt $speed_grade $extparam(period) $fedback_pll ]
::ddr::utils::sett {capture resync} [::ddr::nondqsfbc::analyse $delays $res $extparam_a $pvt]
::ddr::utils::fold_margins resync_margins $resync
}
::ddr::utils::sett {r_su r_hold} $resync_margins


set window [list [expr { 0 - $r_su}] $r_hold]

set resync_settings [::ddr::phasesel::max_slack  $window $extparam(period)]
::ddr::utils::sett {r_cycle r_phase r_su r_hold} $resync_settings
} else {
::ddr::utils::sett { r_cycle r_phase } $resync_settings
::ddr::type::check int $r_cycle "precompileSetup.resync_settings.cycle"
::ddr::type::check int $r_phase "precompileSetup.resync_settings.phase"
}

set res [list fedback_capture_phase $fedback_pll resync_phase $r_phase resync_cycle $r_cycle]

array unset extparam
variable setup_t
::ddr::type::check $setup_t $res
return $res
}



# Replace tco = "h" with a number, once it is known

proc fixuptco {delays tco_ck_l tco_ck_h tco_fedback_l tco_fedback_h} {
array set res $delays

if { $res(tco_ck) == "h" } {
set res(tco_ck) $tco_ck_h
} elseif {$res(tco_ck) == "l" } {
set res(tco_ck) $tco_ck_l
} else { assert {0} {$res(tco_ck)} }

if { $res(tco_fedback) == "h" } {
set res(tco_fedback) $tco_fedback_h
} elseif { $res(tco_fedback) == "l" } {
set res(tco_fedback) $tco_fedback_l
} else { assert {0} {$res(tco_fedback)} }	

set res_a [array get res]
variable delay_t
::ddr::type::check  $delay_t $res_a
return $res_a
}










proc precompile_top_level {ddr_timing_args_var} {
package require ::ddr::mwinterface
upvar 1 $ddr_timing_args_var ddr_timing_args
global current_quartus_project_dir
global wrapper_name


if { $ddr_timing_args(use_project_timing_estimates) } {
set back_ann_estdata [file join $ddr_timing_args(wrapper_path) "${wrapper_name}_estimated_data_nondqs_fbc.dat"]
if { [file exists $back_ann_estdata] } {
if { [catch { source $back_ann_estdata } err] } {

::ddr::mwinterface::report_msg warn [::ddr::messages::back_annotation_failed $back_ann_estdata $err]
} else {
::ddr::mwinterface::report_msg info [::ddr::messages::back_annotation_successful $back_ann_estdata]
}
} else {
::ddr::mwinterface::report_msg warn [::ddr::messages::back_annotation_no_file $back_ann_estdata]
}
} 


if { $ddr_timing_args(family) == "hardcopyii" } {
set $ddr_timing_args(family) "stratixii"
if { $ddr_timing_args(fpga_speed_grade) == "c" } {
set ddr_timing_args(fpga_speed_grade) "c4"
} elseif { $ddr_timing_args(fpga_speed_grade) == "i" } {
set ddr_timing_args(fpga_speed_grade) "i4"
} else {
::ddr::utils::assert {0} $ddr_timing_args(fpga_speed_grade) "Unrecognised speed grade"
}
}

set extparam_a [::ddr::nondqsfbc::extparam_from_ddr_timing_args ddr_timing_args]
array set extparam $extparam_a

#foreach {k v} $extparam_a {
#	::ddr::mwinterface::report_msg Note "extparam $k --> $v"
#}

if { $ddr_timing_args(override_capture) } {
set fedback_pll $ddr_timing_args(capture_clock_phase)
} else {
set fedback_pll "" ;
}

if { $ddr_timing_args(override_resynch) } {

if { $ddr_timing_args(resynch_clock) == "dedicated" } {

set resync_phase $ddr_timing_args(resynch_clock_phase)
} else {
switch -- "$ddr_timing_args(resynch_clock)/$ddr_timing_args(resynch_edge)" {
"clk/rising" { set resync_phase 0 }
"write_clk/falling" { set resync_phase 90 }
"clk/falling" { set resync_phase 180 }
"write_clk/rising" { set resync_phase 270 } 
default { 
::ddr::mwinterface::report_msg Error "Unknown resync clock $ddr_timing_args(resynch_clock)/$ddr_timing_args(resynch_edge)"
set resync_phase 0
}
}
}


set resync_settings [list $ddr_timing_args(resynch_cycle) $resync_phase]
} else {
set resync_settings "" 
}
set setup_a [::ddr::nondqsfbc::precompileSetup  $extparam_a  $fedback_pll  $resync_settings  $ddr_timing_args(fpga_speed_grade)]

array set setup $setup_a

::ddr::mwinterface::report_value capture_phase "Capture Phase" $setup(fedback_capture_phase) "deg"
::ddr::mwinterface::report_msg Info "Fed-back capture PLL phase shift should be $setup(fedback_capture_phase) degrees"
::ddr::mwinterface::report_value resync_phase "Resynchronisation Phase" $setup(resync_phase) "deg"


::ddr::mwinterface::report_value resync_cycle "Resynchronisation Cycle" $setup(resync_cycle) "cycles"
::ddr::mwinterface::write_private gRESYNCH_CYCLE $setup(resync_cycle)

set clock_and_edge [::ddr::utils::degrees_to_clock_and_edge $setup(resync_phase)]
::ddr::mwinterface::write_private gCONNECT_RESYNCH_CLK_TO [lindex $clock_and_edge 0]
::ddr::mwinterface::write_private gRESYNCH_EDGE           [lindex $clock_and_edge 1]



::ddr::mwinterface::store_setting chosen_capture_phase $setup(fedback_capture_phase)
::ddr::mwinterface::store_setting chosen_resynch_phase $setup(resync_phase)


set estMargins(capture) "" 
set estMargins(resync) ""
foreach pvt {fast slow} {
set est_delays_f [::ddr::nondqsfbc::estimatedData $pvt $ddr_timing_args(fpga_speed_grade) $extparam(period) $setup(fedback_capture_phase) ]
::ddr::utils::sett {capture resync} [::ddr::nondqsfbc::analyse $est_delays_f $setup_a $extparam_a $pvt]
::ddr::utils::fold_margins estMargins(capture) $capture
::ddr::utils::fold_margins estMargins(resync) $resync
}
::ddr::mwinterface::report_margin "Capture" $estMargins(capture)
::ddr::mwinterface::report_margin "Resync" $estMargins(resync)

if { [lindex $estMargins(capture) 0] < 0 || [lindex $estMargins(capture) 1] < 0 || [lindex $estMargins(resync) 0] < 0 || [lindex $estMargins(resync) 1] < 0 } {
::ddr::mwinterface::report_msg Crit "Warning: One or more timing requirements not met. Click 'Show Timing Estimates' for more details"
}








}

}
