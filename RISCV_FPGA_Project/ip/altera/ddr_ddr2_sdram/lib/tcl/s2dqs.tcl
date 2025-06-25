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








package provide ::ddr::s2dqs 0.1

package require ::ddr::utils

namespace eval ::ddr::s2dqs {
namespace export analyse_capture
namespace export analyse_postamble_enable
namespace export sentinel	
namespace export externalParam_t
variable delay_capture_t 

if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}







# no comments are allowed in the following {}
set delay_capture_t { struct_partial
dq_capture int
dqs_clkctrl int
clkctrl_capture int
}






# no comments are allowed in the following {}
set setup_capture_t { struct_partial
capture_phase int
}






set externalParam_t { struct 
period int
tDQSCK int
tDQSQ int
tQHS int
CAS_L str
board_ck int
board_dqs int
board_fb_rtd int
board_trace_error int
board_trace_skew int
}







proc get_datasheet_parameters { speed_grade pvt} {
set ds [list]
lappend ds ocv  0.07
lappend ds utco_le [expr {$pvt=="fast" ? 68 : 122}]
lappend ds usu_le [expr {$pvt=="fast" ? 37 : 72}]
lappend ds uhold_le [expr {$pvt=="fast" ? 106 : 179}]
lappend ds utco_ioe [expr {$pvt=="fast" ? 47 : 90}]
lappend ds usu_ioe [expr {$pvt=="fast" ? 75 : 149}]
lappend ds uhold_ioe [expr {$pvt=="fast" ? 62 : 94}]
lappend ds dll_ps_err_total [expr {$pvt=="fast" ? 100 : 100}]
lappend ds pll_ps_err_total [expr {$pvt=="fast" ? 100 : 100}]
return $ds
}












proc analyse_capture {delays_a setup_a extparam_a pvt speed_grade} {
variable delay_capture_t
variable setup_capture_t
variable externalParam_t
assert {[info exists delay_capture_t]}
assert {[info exists setup_capture_t]}
assert {[info exists externalParam_t]}

::ddr::type::check $delay_capture_t $delays_a "::ddr::s2dqs::analyse_capture.delay"
::ddr::type::check $setup_capture_t $setup_a "::ddr::s2dqs::analyse_capure.setup"
::ddr::type::check $externalParam_t $extparam_a "::ddr::s2dqs::analyse_capture.extparam"
::ddr::type::check [list enum fast slow] $pvt

array set delays $delays_a
array set setup $setup_a
array set extparam $extparam_a

array set ds [get_datasheet_parameters $speed_grade $pvt]


set datavalid [expr { $delays(dq_capture) } ]
#set datavalid_ocv [ expr {$ds(ocv)*$delays(dq_capture) }]
set datavalid_ocv 0
set datavalid_err [expr { $extparam(board_trace_skew) + $extparam(tDQSQ) }]
set clock_time [expr {$delays(dqs_clkctrl) + $delays(clkctrl_capture) }]
#set clock_time_ocv [expr {$ds(ocv)*($delays(dqs_clkctrl) + $delays(clkctrl_capture)) - $ds(ocv)* $setup(capture_phase)/360.0*$extparam(period) }]
set clock_time_ocv 0
set clock_time_err 0
set su [expr { round( $clock_time - $datavalid - ($pvt=="fast" ? $datavalid_ocv : $clock_time_ocv) - $clock_time_err - $datavalid_err - $ds(usu_ioe)  )}]

set datainvalid [expr {-$extparam(board_trace_skew) + 0.45 * $extparam(period) -$extparam(tQHS) + $delays(dq_capture)}]
# set datainvalid_ocv [expr {$ds(ocv) * $delays(dq_capture)}]
set datainvalid_ocv 0

set hld [expr {round($datainvalid - $clock_time - ($pvt == "fast" ? $clock_time_ocv : $datainvalid_ocv) - $clock_time_err - $ds(uhold_ioe)  )}]
return [list $su $hld]
}













proc analyse_resync {delays_a setup_a extparam_a pvt speed_grade} {
variable delay_t
variable setup_t
variable externalParam_t
assert {[info exists delay_t]}
assert {[info exists setup_t]}
assert {[info exists externalParam_t]}

::ddr::type::check $delay_t $delays_a "::ddr::s2dqs::analyse_capure"
::ddr::type::check $setup_t $setup_a "::ddr::s2dqs::analyse_capure"
::ddr::type::check $externalParam_t $extparam_a "::ddr::s2dqs::analyse_resync.extparam_a"
::ddr::type::check [list enum fast slow] $pvt

array set delays $delays_a
array set setup $setup_a
array set extparam $extparam_a

array set ds [get_datasheet_parameters $speed_grade $pvt]

set roundtrip [expr {$extparam(board_ck) + $extparam(board_dqs) + $delays(dqspin_2_dqsclk) + $delays(dqsclk_2_ddio_resync) + $delays(ddio_reg)}]
set roundtrip_ocv [expr {$ds(ocv) * ($delays(dqspin_2_dqsclk) + $delays(dqsclk_2_ddio_resync) + $delays(ddio_reg) - $setup(capture_phase)/360.0*$extparam(period) )}]
set roundtrip_un [expr {$extparam(board_trace_error) * ($extparam(board_dqs) + $extparam(board_ck)) + $ds(dll_ps_err_total) + $extparam(tDQSCK) }] 

set latedata [expr   {$delays(clk_2_pin_max)*($pvt=="fast"?1+$ds(ocv):1)  + $roundtrip + $roundtrip_un + ($pvt=="fast"? $roundtrip_ocv : 0) }]
set earlydatax [expr {$delays(clk_2_pin_min)*($pvt=="fast"?1:1-$ds(ocv)) + $roundtrip - $roundtrip_un - ($pvt=="fast"? 0 : $roundtrip_ocv) + $extparam(period) }]

set clock_time [expr { $extparam(period)*($setup(resync_cycle) + $setup(resync_phase)/360.0) }]
set clock_time_un $ds(pll_ps_err_total)
set su [expr {round($clock_time - $clock_time_un - $latedata - $ds(usu_le) )}]
set hold [expr {round($earlydatax - $clock_time - $clock_time_un - $ds(uhold_le) )}]

return [list $su $hold]
}













proc analyse_postamble_enable {delays_a setup_a extparam_a pvt speed_grade} {


#assert {[info exists delay_t]}
#assert {[info exists setup_t]}
#assert {[info exists externalParam_t]}

#::ddr::type::check $delay_t $delays_a "::ddr::s2dqs::analyse_postamble_enable.delay"
#::ddr::type::check $setup_t $setup_a "::ddr::s2dqs::analyse_postamble_enable.setup"
#::ddr::type::check $::ddr::s2dqs::externalParam_t $extparam_a "::ddr::s2dqs::analyse_postamble_enable.extparam"
::ddr::type::check [list enum fast slow] $pvt

array set delays $delays_a
array set setup $setup_a
array set extparam $extparam_a

array set ds [::ddr::s2dqs::get_datasheet_parameters $speed_grade $pvt]

set window [expr {$extparam(period) * 0.4 } ]
set round_trip [expr { $delays(clkctrl_posten) + $ds(utco_ioe) + $delays(posten_clkctrl) }]
set slack [expr {round($window - $round_trip)}] 
return $slack
}









proc choose_dqs_settings { clock_period } {
if { $clock_period >= 6001  } {

set res(gSTRATIXII_DLL_DELAY_BUFFER_MODE)    "low"
set res(gSTRATIXII_DQS_PHASE)                "6000"
set res(gSTRATIXII_DQS_OUT_MODE)             "delay_chain2" 
set res(gSTRATIXII_DLL_DELAY_CHAIN_LENGTH)   "12"
} elseif {$clock_period >= 4651 }  {

set res(gSTRATIXII_DLL_DELAY_BUFFER_MODE)    "high"
set res(gSTRATIXII_DQS_PHASE)                "6750"
set res(gSTRATIXII_DQS_OUT_MODE)             "delay_chain3" 
set res(gSTRATIXII_DLL_DELAY_CHAIN_LENGTH)   "16"
} else {

set res(gSTRATIXII_DLL_DELAY_BUFFER_MODE)        "high"
set res(gSTRATIXII_DQS_PHASE)                    "9000"
set res(gSTRATIXII_DQS_OUT_MODE)                 "delay_chain3"
set res(gSTRATIXII_DLL_DELAY_CHAIN_LENGTH)       "12"
}

set res(gSTRATIX_DQS_PHASE) [expr {round( $res(gSTRATIXII_DQS_PHASE) / 100)}]

set r [array get res]
array unset res
return $r
}


proc sentinel { d } {
return "s2dqssentinel$d"
}

}

