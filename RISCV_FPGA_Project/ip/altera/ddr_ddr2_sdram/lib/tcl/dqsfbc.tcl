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






package provide ::ddr::dqsfbc 0.1 

package require ::ddr::utils
package require ::ddr::type
package require ::ddr::phasesel
package require ::ddr::paths
package require ::ddr::extract
package require ::ddr::data
package require ::ddr::s2dqs


namespace eval ::ddr::dqsfbc {
namespace export sentinel
namespace export extract_s2_paths
namespace export precompile_top_level
namespace export phase_from_inter_postamble
variable delay_t

if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}









set delay_t { struct_partial
sysclk_pin_min str
sysclk_pin_max str
dq_capture int
capture_resync1 int
resync1_resync2 int
clkctrl_capture int
clkctrl_resync int
dqs_clkctrl int
pin_fedback int
fedback_resync int
}








set delay_postamble_t { struct_partial
posten_clkctrl int
clkctrl_posten int
postctrl_posten int
pin_fedback int
fedback_postamble int
sysclk_postctrl int
}










set setup_t { struct_partial
capture_phase int
resync_cycle int
resync_phase int
fedback_resync_phase int
}







set setup_postamble_t { struct_partial
fedback_postamble_phase int
postamble_phase {enum 0 180}
postamble_cycle int
}




#  or "" otherwise

proc extract_s2_paths { node wrappername debugproc enable_postamble} {
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

set dq_pin_name [get_timing_node_info -info name $node]
#puts "-------------------------\npin $dq_pin_name is a DQ pin for $wrappername"
$debugproc dqpin $node
puts "got pin $dq_pin_name"  


array unset lresult
array unset hresult


foreach hl { h l } {


set delays(dq_capture) 0
set capturenode $node
set errmsg "" 
#puts "regnode is [dump_node $regnode]"
#follow_edge2 regnode fanout {~COMBOUT$} delays(dq_capture) $debugproc errmsg
#	assert { $delays(dq_capture) > 0 } { $delays(dq_capture) }
set risingfalling [expr { $hl == "l" ? "rising" : "falling" } ]
if { $hl == "h" } {
::ddr::extract::follow_edge2 capturenode fanout "dq_captured_${risingfalling}\\\[\[0-9\]+\\\]\$" delays(dq_capture) $debugproc errmsg
} else {
::ddr::extract::follow_edge2 capturenode fanout "\\\\g_dq_io:\[0-9\]+:dq_io~ddio_out_reg\$"      delays(dq_capture) $debugproc errmsg			
}
if { $errmsg != "" } {
puts "-------failed-----"
puts $errmsg 
puts "------------------"
} else { 
#puts "$hl Register is [dump_node $capturenode]"
}

set delays(capture_resync1) 0 
set resyncnode $capturenode


if { $hl == "l" } {
::ddr::extract::follow_edge2 resyncnode fanout "dq_captured_${risingfalling}\\\[\[0-9\]+\\\]\$" "" $debugproc errmsg
set latchnode $resyncnode
} 

::ddr::extract::follow_edge2 resyncnode fanout "resynched_data\\\[\[0-9\]+\\\]\$" delays(capture_resync1) $debugproc errmsg

set delays(resync1_resync2) 0
set resync2node $resyncnode
::ddr::extract::follow_edge2 resync2node fanout  "fedback_resynched_data\\\[\[0-9\]+\\\]\$" delays(resync1_resync2) $debugproc errmsg


set delays(clkctrl_capture) 0
set delays(dqs_clkctrl) 0
set dqspinnode $capturenode
::ddr::extract::follow_edge2 dqspinnode clock "dqs_clk\\\[\[0-9\]+\\\]\$" delays(clkctrl_capture) $debugproc errmsg
set clkctrlnode $dqspinnode ;
::ddr::extract::follow_edge2 dqspinnode pin_clock "" delays(dqs_clkctrl) $debugproc errmsg
if { ! [::ddr::extract::is_pin $dqspinnode] || [get_timing_node_info -info type $dqspinnode] != "clk" || [llength [get_timing_node_fanin -type clock $dqspinnode]] != "0" } {

assert {0} {$dqspinnode {[dump_node $dqspinnode]}} "Couldn't find node of type clk when after dqs input. Is the DQS clock assigned to a pin?"  
}
set delays(clkctrl_resync) $delays(clkctrl_capture)


set delays(fedback_resync) 0 
set delays(pin_fedback) 0 
set fbcpinnode $resyncnode
::ddr::extract::follow_edge2 fbcpinnode clock "altpll_component\\|_clk0\$" delays(fedback_resync) $debugproc errmsg

::ddr::extract::follow_edge2 fbcpinnode clock "" delays(fedback_resync) $debugproc errmsg
set fedbackpllnode $fbcpinnode
for { set i 0 } { $i < 4 } { incr i } {
if { [llength [get_timing_node_fanin -type clock $fbcpinnode]] == "1" } {
::ddr::extract::follow_edge2 fbcpinnode clock ""  delays(pin_fedback) $debugproc errmsg
} else {
break
}
}
if { ! [::ddr::extract::is_pin $fbcpinnode] || [get_timing_node_info -info type $fbcpinnode] != "clk" || [llength [get_timing_node_fanin -type clock $fbcpinnode]] != "0" } {

assert {0} {$fbcpinnode {[dump_node $fbcpinnode]}} "Couldn't find node of type clk when after fbc input. Is the fed-back clock input assigned to a pin?"  
}
#puts "FBC pin is [dump_node $fbcpinnode]"

if { $enable_postamble } {
set paennode $clkctrlnode
set delays(posten_clkctrl) 0
set delays(clkctrl_posten) 0

::ddr::extract::follow_edge2 paennode clock "dqs_io~(regout|REGOUT)\$" delays(posten_clkctrl) $debugproc errmsg
set tempnode $paennode
::ddr::extract::follow_edge2 tempnode clock "dqs_clk\\\[\[0-9\]+\\\]\$" delays(clkctrl_posten) $debugproc errmsg
assert { $tempnode == $clkctrlnode }
set delays(postctrl_posten) 0
::ddr::extract::follow_edge2 paennode async "dq_enable_reset\\\[\[0-9\]+\\\]\$" delays(postctrl_posten) $debugproc errmsg
set pactrlnode $paennode
set delays(sysclk_postctrl) 0
::ddr::extract::follow_edge2 paennode synch "doing_rd_delayed\$" delays(sysclk_postctrl) $debugproc errmsg

set delays(fedback_postamble) 0
::ddr::extract::follow_edge2  pactrlnode clock "altpll_component\\|_clk1\$" delays(fedback_postamble) $debugproc errmsg

::ddr::extract::follow_edge2  pactrlnode clock "" delays(fedback_postamble) $debugproc errmsg
assert { $fedbackpllnode == $pactrlnode } {{[::ddr::extract::dump_node $fedbackpllnode]} {[::ddr::extract::dump_node $pactrlnode]} }
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
set delays(sysclk_pin_min) $hl
set delays(sysclk_pin_max) $hl
foreach {k v} [array get delays] {
if { $v == "h" } { 

} elseif {$v == "l" } {

} elseif { $k == "name" } {

} elseif { $k == "number" && [string is integer $v] } {

} elseif {[string is integer $v] && ($v > 0) } { 

} elseif {$k== "fedback_resync" &&  [string is integer $v]  } {

} elseif {$k== "fedback_postamble" &&  [string is integer $v]  } {

} else {
assert {false} {$k $v} "Delay unreasonable"
}
}

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
variable delay_t
::ddr::type::check $delay_t $res_l
::ddr::type::check $delay_t $res_h
if { $enable_postamble } {
variable delay_postamble_t
::ddr::type::check $delay_postamble_t $res_l
::ddr::type::check $delay_postamble_t $res_h
}
return [list $res_l $res_h]

}










#  * interface_info - This is a pointer to an opaque variable, which should be initialised to "". 




proc analyse_resync {delays_a setup_a extparam_a pvt speed_grade interface_info_var} {
variable delay_t
variable setup_t
assert {[info exists delay_t]}
assert {[info exists setup_t]}
assert {[info exists ::ddr::s2dqs::externalParam_t]}
upvar 1 $interface_info_var interface_info
assert {[info exists interface_info]}

::ddr::type::check $delay_t $delays_a "::ddr::dqsfbc::analyse_resync.delays"
::ddr::type::check $setup_t $setup_a "::ddr::dqsfbc::analyse_resync.setup"
::ddr::type::check $::ddr::s2dqs::externalParam_t $extparam_a "::ddr::dqsfbc::analyse_resync"
::ddr::type::check [list enum fast slow] $pvt

array set delays $delays_a
array set setup $setup_a
array set extparam $extparam_a

array set ds [::ddr::s2dqs::get_datasheet_parameters $speed_grade $pvt]


set trip_to_resync_reg [expr {$extparam(board_ck) + $extparam(board_dqs) + $delays(dqs_clkctrl) + $delays(clkctrl_capture) + $ds(utco_ioe) + $delays(capture_resync1) }]
set trip_to_resync_reg_ocv [expr {$ds(ocv) * ($delays(dqs_clkctrl) + $delays(clkctrl_capture) + $delays(capture_resync1) - $setup(capture_phase)/360.0*$extparam(period) )}]
set trip_to_resync_reg_err [expr {$extparam(board_trace_error) *($extparam(board_ck) + $extparam(board_dqs)) + $extparam(tDQSCK) + $ds(dll_ps_err_total)}]

set data_valid_time [expr {$delays(sysclk_pin_max) + $trip_to_resync_reg + (0.5+$extparam(CAS_L))*$extparam(period) }]
set data_valid_time_ocv [expr { $delays(sysclk_pin_max)*$ds(ocv) + $trip_to_resync_reg_ocv  }]
set data_valid_time_err [expr {$trip_to_resync_reg_err}]

set data_invalid_time [expr {$delays(sysclk_pin_min) + $trip_to_resync_reg + (0.5+$extparam(CAS_L))*$extparam(period) + $extparam(period) }]
set data_invalid_time_ocv [expr {$ds(ocv) * $delays(sysclk_pin_min) + $trip_to_resync_reg_ocv  }]
set data_invalid_time_err [expr {  $trip_to_resync_reg_err }]

set fbc_to_resync_reg [expr {$extparam(board_fb_rtd) + $delays(pin_fedback) + $delays(fedback_resync) }]
set fbc_to_resync_reg_ocv [expr {0}]
set fbc_to_resync_reg_err [expr {$extparam(board_fb_rtd) * $extparam(board_trace_error) + $ds(pll_ps_err_total)}]

set early_clock_time [expr { $delays(sysclk_pin_min) + $fbc_to_resync_reg }]
set early_clock_time_ocv [expr { $delays(sysclk_pin_min) * $ds(ocv) + $fbc_to_resync_reg_ocv }]
set early_clock_time_err [expr { $fbc_to_resync_reg_err }]

set late_clock_time [expr { $delays(sysclk_pin_max) + $fbc_to_resync_reg }]
set late_clock_time_ocv [expr { $delays(sysclk_pin_max) * $ds(ocv) + $fbc_to_resync_reg_ocv }]
set late_clock_time_err [expr { $fbc_to_resync_reg_err }]






# store this in the variable "interface_info" that the caller must pass a pointer to in 

if { $interface_info == "" } {
set clock_time_mid [expr {($late_clock_time + $early_clock_time)/2.0}]
set cycles [::ddr::phasesel::adjust_cycle $clock_time_mid [list $data_valid_time $data_invalid_time] $extparam(period)]
puts "Choosing FBC resync cycle of $cycles, and storing in var"
set interface_info $cycles
} else {
::ddr::type::check int $interface_info "::ddr::dqsfbc::analyse_resync.interface_info-cycles"
set cycles $interface_info
}

set late_clock_time [expr {$late_clock_time + $extparam(period) * $cycles}]
set early_clock_time [expr {$early_clock_time + $extparam(period) * $cycles}]

set su1 [expr { round($early_clock_time - $data_valid_time - ($pvt=="fast" ? $data_valid_time_ocv : $early_clock_time_ocv) - $early_clock_time_err - $data_valid_time_err - $ds(usu_le)  )}] 
set hld1 [expr {round($data_invalid_time - $late_clock_time - ($pvt == "fast" ? $late_clock_time_ocv : $data_invalid_time_ocv) - $late_clock_time_err - $data_invalid_time_err - $ds(uhold_le)  )}]



set data_valid_time [expr {$late_clock_time + $ds(utco_le) + $delays(resync1_resync2)}]
set data_valid_time_ocv [expr {$late_clock_time_ocv + $ds(ocv) * $delays(resync1_resync2) }]
set data_valid_time_err [expr {$late_clock_time_err}]

set data_invalid_time [expr {$early_clock_time + $ds(utco_le) + $delays(resync1_resync2) + $extparam(period)}]
set data_invalid_time_ocv [expr {$early_clock_time_ocv + $ds(ocv) * $delays(resync1_resync2) }]
set data_invalid_time_err [expr {$early_clock_time_err}]

set clock_time [expr {($setup(resync_phase)/360.0 + $setup(resync_cycle)+3)*$extparam(period)}]
set clock_time_ocv 0
set clock_time_err [expr {$ds(pll_ps_err_total)/2.0}]

set su2 [expr {round($clock_time - $data_valid_time - ($pvt=="fast" ? $data_valid_time_ocv : $clock_time_ocv) - $clock_time_err - $data_valid_time_err - $ds(usu_le))}]
set hld2 [expr {round($data_invalid_time - $clock_time - ($pvt == "fast" ? $clock_time_ocv : $data_invalid_time_ocv) - $clock_time_err - $data_invalid_time_err - $ds(uhold_le)  )}]
		########
return [list [list $su1 $hld1] [list $su2 $hld2 ]]
}










#  * interface_info - This is a pointer to an opaque variable, which should be initialised to "". 




proc analyse_postamble {delays_a setup_a extparam_a pvt speed_grade interface_info_var} {
variable delay_t
variable setup_t
assert {[info exists delay_t]}
assert {[info exists setup_t]}
assert {[info exists ::ddr::s2dqs::externalParam_t]}
upvar 1 $interface_info_var interface_info
assert {[info exists interface_info]}

::ddr::type::check $delay_t $delays_a "::ddr::dqsfbc::analyse_postamble.delays"
::ddr::type::check $setup_t $setup_a "::ddr::dqsfbc::analyse_postamble.setup"
::ddr::type::check $::ddr::s2dqs::externalParam_t $extparam_a "::ddr::dqsfbc::analyse_postamble.extparam"
::ddr::type::check [list enum fast slow] $pvt

array set delays $delays_a
array set setup $setup_a
array set extparam $extparam_a

array set ds [::ddr::s2dqs::get_datasheet_parameters $speed_grade $pvt]		

set late_dqs_edge [expr {$extparam(period)*($extparam(CAS_L)+0.55) + $delays(sysclk_pin_max) + $extparam(board_ck) + $extparam(board_dqs) + $delays(dqs_clkctrl) + $delays(clkctrl_posten)}]
set late_dqs_edge_ocv [expr {$ds(ocv) * ($delays(sysclk_pin_max) + $delays(dqs_clkctrl) + $delays(clkctrl_posten))}]
set late_dqs_edge_err [expr {($extparam(board_ck) + $extparam(board_dqs))*$extparam(board_trace_error) + $extparam(tDQSCK)}]

set early_dqs_edge [expr {$extparam(period)*($extparam(CAS_L)+1.45) + $delays(sysclk_pin_min) + $extparam(board_ck) + $extparam(board_dqs) + $delays(dqs_clkctrl) + $delays(clkctrl_posten)}]
set early_dqs_edge_ocv [expr {$ds(ocv) * ($delays(sysclk_pin_min) + $delays(dqs_clkctrl) + $delays(clkctrl_posten))}]
set early_dqs_edge_err [expr {($extparam(board_ck) + $extparam(board_dqs))*$extparam(board_trace_error) + $extparam(tDQSCK)}]

set fb_postamble_trip [expr {$extparam(board_fb_rtd) + $delays(pin_fedback) + $delays(fedback_postamble) }]
set fb_postamble_trip_ocv 0
set fb_postamble_trip_err [expr { $extparam(board_trace_error) * $extparam(board_fb_rtd) + $ds(pll_ps_err_total) }]

set early_pa_clock [expr {$delays(sysclk_pin_min) + $fb_postamble_trip } ]
set early_pa_clock_ocv [expr { $ds(ocv)*$delays(sysclk_pin_min) + $fb_postamble_trip_ocv }]
set early_pa_clock_err $fb_postamble_trip_err

set late_pa_clock [expr {$delays(sysclk_pin_max) + $fb_postamble_trip } ]
set late_pa_clock_ocv [expr { $ds(ocv)*$delays(sysclk_pin_max) + $fb_postamble_trip_ocv }]
set late_pa_clock_err $fb_postamble_trip_err

set early_reset [expr {$early_pa_clock + $delays(postctrl_posten)}]
set early_reset_ocv [expr {$early_pa_clock_ocv + $ds(ocv)*$delays(postctrl_posten) }]
set early_reset_err $early_pa_clock_err

set late_reset [expr {$late_pa_clock + $delays(postctrl_posten)}]
set late_reset_ocv [expr {$late_pa_clock_ocv + $ds(ocv)*$delays(postctrl_posten) }]
set late_reset_err $late_pa_clock_err


if { $interface_info == "" } {
set clock_time_mid [expr {($early_reset + $late_reset)/2.0}]
set cycles [::ddr::phasesel::adjust_cycle $clock_time_mid [list $late_dqs_edge $early_dqs_edge] $extparam(period)]
puts "Choosing FBC postamble cycle of $cycles, and storing in var"
set interface_info $cycles
} else {
::ddr::type::check int $interface_info "::ddr::dqsfbc::analyse_postamble.interface_info-cycles"
set cycles $interface_info
}
foreach v {early_pa_clock late_pa_clock early_reset late_reset } {
set $v [expr {[set $v] + $extparam(period) * $cycles}]
}	

set setup1 [expr {round($early_dqs_edge - $early_dqs_edge_err - $late_reset - $late_reset_err - ($pvt=="fast" ? $late_reset_ocv : $early_dqs_edge_ocv ))}]
set hold1 [expr {($early_reset - $early_reset_err - $late_dqs_edge - $late_dqs_edge_err - ($pvt=="fast" ? $late_dqs_edge_ocv : $early_reset_ocv) )}]
set hold1 [expr {round($hold1+0.000000000001)}]  ;



set late_data_valid [expr { $extparam(period) * (3+$setup(postamble_cycle) + $setup(postamble_phase)/360.0) + $delays(sysclk_postctrl)}]
set late_data_valid_ocv [expr {$delays(sysclk_postctrl)*$ds(ocv)}]

set early_data_invalid [expr {$late_data_valid + $extparam(period)}]
set early_data_invalid_ocv $late_data_valid_ocv

set setup2 [expr {round($early_pa_clock - $late_data_valid - $early_pa_clock_err - ($pvt=="fast" ? $late_data_valid_ocv : $early_pa_clock_ocv) - $ds(usu_le))}]
set hold2 [expr  {round($early_data_invalid - $late_pa_clock - $late_pa_clock_err - ($pvt=="fast" ?$late_pa_clock_ocv:$early_data_invalid_ocv)- $ds(uhold_le))}]
return [list [list $setup1 $hold1] [list $setup2 $hold2]]
}




proc extparam_from_ddr_timing_args {ddr_timing_args_var} {
upvar 1 $ddr_timing_args_var ddr_timing_args
assert {[info exists ddr_timing_args]} {$ddr_timing_args_var}

sett {clock_freq period} [::ddr::utils::normalise_clock_frequency $ddr_timing_args(clock_freq_in_mhz)]

set res [list period $period \
tDQSCK $ddr_timing_args(memory_tDQSCK) \
tDQSQ  $ddr_timing_args(memory_tDQSQ)  \
tQHS   $ddr_timing_args(memory_tQHS)   \
CAS_L  $ddr_timing_args(cas_latency)   \
board_ck   $ddr_timing_args(board_tPD_clock_trace_NOM) \
board_dqs  $ddr_timing_args(board_tPD_dqs_trace_total_NOM) \
board_fb_rtd $ddr_timing_args(tpd_clockfeedback_trace_nom) \
board_trace_error [expr {$ddr_timing_args(board_pcb_delay_var_percent)*0.01}] \
board_trace_skew $ddr_timing_args(board_tSKEW_data_group)]

::ddr::type::check $::ddr::s2dqs::externalParam_t $res
return $res
}	


















proc estimatedData { pvt speed_grade clock_period fedback_resync_phase fedback_postamble_phase } {
::ddr::type::check [list enum fast slow] $pvt
::ddr::type::check [list enum c3 c4 c5 i4 i5] $speed_grade
::ddr::type::check int $clock_period "estimatedData.clock_period"
::ddr::type::check int $fedback_resync_phase "estimatedData.fedback_resync_phase"
::ddr::type::check int $fedback_postamble_phase "estimatedData.fedback_postamble_phase"
array set delays {}

set delays_l [list]
if { [info procs ::ddr::dqsfbc::back_ann_est_data] != ""} {
catch {
set delays_l [::ddr::dqsfbc::back_ann_est_data $pvt]
}
}
if { $delays_l == "" } {
if { $pvt == "slow" } {
if { $speed_grade == "c3" } {

set delays_l {capture_resync1 979 sysclk_pin_min 1300 resync1_resync2 865 sysclk_pin_max 1342 pin_fedback 489 clkctrl_posten 666 posten_clkctrl 164 dq_capture 1785 clkctrl_capture 689 clkctrl_resync 689 sysclk_postctrl 411 fedback_resync -5288 postctrl_posten 1055 fedback_postamble -289 dqs_clkctrl 1975}
} elseif { $speed_grade == "c4" || $speed_grade == "i4" } {
set delays_l {capture_resync1 979 sysclk_pin_min 1300 resync1_resync2 865 sysclk_pin_max 1342 pin_fedback 489 clkctrl_posten 666 posten_clkctrl 164 dq_capture 1785 clkctrl_capture 689 clkctrl_resync 689 sysclk_postctrl 411 fedback_resync -5288 postctrl_posten 1055 fedback_postamble -289 dqs_clkctrl 1975}
} elseif { $speed_grade == "c5" || $speed_grade == "i5" } {
set delays_l {capture_resync1 1317 sysclk_pin_min 1665 resync1_resync2 2897 sysclk_pin_max 1737 pin_fedback 1183 clkctrl_posten 866 posten_clkctrl 219 dq_capture 2339 clkctrl_capture 897 clkctrl_resync 897 sysclk_postctrl 572 fedback_resync -3790 postctrl_posten 1428 fedback_postamble 1812 dqs_clkctrl 2312}
} else {
assert {0} {$speed_grade} "Unsupported speed grade"
}
} elseif {$pvt  == "fast" } {
set delays_l {capture_resync1 467 sysclk_pin_min 836 resync1_resync2 227 sysclk_pin_max 906 pin_fedback 623 clkctrl_posten 412 posten_clkctrl 112 dq_capture 1113 clkctrl_capture 412 clkctrl_resync 412 sysclk_postctrl 231 fedback_resync -4590 postctrl_posten 599 fedback_postamble 839 dqs_clkctrl 1619}
} else { assert {0} {$pvt} "Unreachable state" }
}
array set delays $delays_l

		##nagelfar variable delays(fedback_capture)
		##nagelfar variable delays(fedback_resync)
set delays(fedback_resync) [expr {round($delays(fedback_resync)+ $fedback_resync_phase /360.0 * $clock_period) } ]
set delays(fedback_postamble) [expr {round($delays(fedback_postamble)+ $fedback_postamble_phase /360.0 * $clock_period) } ]
set delays(name) "dq_estimated"
set delays(number) 0
set res [array get delays]
array unset delays

variable delay_t
::ddr::type::check $delay_t $res "::ddr:dqsfbc::estimatedData"
return $res
}










proc precompile_top_level { ddr_timing_args_var } {
package require ::ddr::mwinterface
upvar 1 $ddr_timing_args_var ddr_timing_args
global current_quartus_project_dir
global wrapper_name


if { $ddr_timing_args(use_project_timing_estimates) } {
set back_ann_estdata [file join $ddr_timing_args(wrapper_path) "${wrapper_name}_estimated_data_dqs_fbc.dat"]
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

set extparam_a [extparam_from_ddr_timing_args ddr_timing_args]
array set extparam $extparam_a





set setup(capture_phase) 90 ;


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

set setup(resync_cycle) $ddr_timing_args(resynch_cycle)
set setup(resync_phase) $resync_phase
set setup(fedback_resync_phase) $ddr_timing_args(fedback_resync_clock_phase)
if { $ddr_timing_args(enable_postamble) } {
set setup(fedback_postamble_phase) $ddr_timing_args(postamble_clock_phase)

set setup(postamble_phase) [phase_from_inter_postamble $ddr_timing_args(inter_postamble)]
set setup(postamble_cycle) $ddr_timing_args(postamble_cycle)
}

if { $ddr_timing_args(postamble_clock) != "dedicated" } {
::ddr::mwinterface::report_msg Crit "Postamble clock must be set to 'dedicated clock' in DQS Fedback Clock mode"
}

if { ! $ddr_timing_args(override_resynch) || ! $ddr_timing_args(override_postamble) } {
::ddr::mwinterface::report_msg Crit "Resynchronisation and Postamble settings must be chosen manually in the 'Manual Timings' pane when using DQS Fedback Clock mode"
}

#foreach {k v} [array get setup] {
#	::ddr::mwinterface::report_msg Note "setup $k --> $v"
#}
set margins(capture) ""
set margins(resync1) ""
set margins(resync2) ""
set margins(postamble1) ""
set margins(postamble2) ""
set margins(postambleen) ""
set resync_interface_info_var ""
set postamble_interface_info_var ""
foreach pvt {fast slow} {
set delays_a [estimatedData $pvt $ddr_timing_args(fpga_speed_grade) $extparam(period) $setup(fedback_resync_phase) [expr {$ddr_timing_args(enable_postamble) ? $setup(fedback_postamble_phase) : 0 }]]
foreach {k v} [concat {--- delays} $delays_a {--- setup} [array get setup] {--- extparam} [array get extparam]] {
#puts "$k\t\t$v"
}
set capture [::ddr::s2dqs::analyse_capture $delays_a [array get setup] [array get extparam] $pvt $ddr_timing_args(fpga_speed_grade)]
fold_margins margins(capture) $capture
set postambleen [::ddr::s2dqs::analyse_postamble_enable $delays_a [array get setup] [array get extparam] $pvt $ddr_timing_args(fpga_speed_grade)]
fold_margins margins(postambleen) [list $postambleen 0]
sett {resync1 resync2} [analyse_resync $delays_a [array get setup] [array get extparam] $pvt $ddr_timing_args(fpga_speed_grade) resync_interface_info_var ]
fold_margins margins(resync1) $resync1
fold_margins margins(resync2) $resync2
if { $ddr_timing_args(enable_postamble) } {
sett {postamble1 postamble2} [analyse_postamble $delays_a [array get setup] [array get extparam] $pvt $ddr_timing_args(fpga_speed_grade) postamble_interface_info_var ]
fold_margins margins(postamble1) $postamble1
fold_margins margins(postamble2) $postamble2
}
}
::ddr::mwinterface::report_margin "Capture" $margins(capture)
::ddr::mwinterface::report_margin "Stage 1 Resynchronisation" $margins(resync1)
::ddr::mwinterface::report_margin "Stage 2 Resynchronisation" $margins(resync2)
if { $ddr_timing_args(enable_postamble) } {
::ddr::mwinterface::report_margin "Postamble Enable" [list [lindex $margins(postambleen) 0] "0"]
::ddr::mwinterface::report_margin "Stage 1 Postamble Control" $margins(postamble1)
::ddr::mwinterface::report_margin "Stage 2 Postamble Control" $margins(postamble2)		
}


# "Names for Parameters.doc" documents what these names mean




foreach {k v} [::ddr::s2dqs::choose_dqs_settings $extparam(period)] {
::ddr::mwinterface::report_value $k $k $v
}


::ddr::mwinterface::report_value fedback_resync_phase "Fedback Resynchronisation Clock Phase" $setup(fedback_resync_phase) "degrees"
::ddr::mwinterface::store_setting chosen_fb_resynch_phase $setup(fedback_resync_phase)

sett {resync_clock resync_edge} [::ddr::utils::degrees_to_clock_and_edge $setup(resync_phase)]
::ddr::mwinterface::report_value gCONNECT_RESYNCH_CLK_TO "Resynchronisation Clock" $resync_clock
::ddr::mwinterface::report_value gRESYNCH_EDGE "Edge of Resynchronisation Clock" $resync_edge
::ddr::mwinterface::store_setting chosen_resynch_phase $setup(resync_phase)

::ddr::mwinterface::report_value chosen_resynch_cycle "Resynchronisation Cycle" $setup(resync_cycle) "cycles"


if { $ddr_timing_args(enable_postamble) } {
::ddr::mwinterface::report_value REPORT_postamble_phase "Fedback Postamble Phase" $setup(fedback_postamble_phase) ;
::ddr::mwinterface::write_private postamble_phase $setup(fedback_postamble_phase)                                 ;
::ddr::mwinterface::store_setting chosen_fb_postamble_phase $setup(fedback_postamble_phase)                       ;

::ddr::mwinterface::report_value gPOSTAMBLE_CYCLE "Postamble Cycle" $setup(postamble_cycle) "cycles"
::ddr::mwinterface::store_setting chosen_postamble_cycle $setup(postamble_cycle)

::ddr::mwinterface::report_value inter_postamble "Intermediate Inverted Postamble Control Clock" [expr {$setup(postamble_phase) == 0 ? false: true}]
}

}


proc phase_from_inter_postamble { inter_postamble } {


if { $inter_postamble } {
set postamble_phase 0
} else  {

set postamble_phase -180
}
return $postamble_phase
}

proc sentinel { d } {
return "dqsfbcssentinel$d"
}
}











