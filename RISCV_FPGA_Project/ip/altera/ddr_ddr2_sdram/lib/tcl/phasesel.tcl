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







package provide ::ddr::phasesel 0.1

package require ::ddr::utils

namespace eval ::ddr::phasesel {
namespace export draw_window
namespace export get_time
namespace export margins
namespace export in_window
namespace export find_phase
namespace export middle_of_win
namespace export max_slack
namespace export adjust_cycle


proc sett { vlist exp } {
if { [llength $vlist] != [llength $exp] } {
error "Length of vlist ([llength $vlist]) != length of exp ([llength $exp])"
} else {
set i 0
foreach v $vlist {
upvar $v x
set x [lindex $exp $i]
incr i
}
}
return
}








#   ""

proc draw_window { window period } {
set dt [expr {$period / 20} ]

set scale " "
set trace " "
sett {l r} $window
for { set i -20 } { $i < 80 } { incr i } {
set t [expr {$dt * $i}]
if { [expr {$i % 20} ] == 0 } {
set scale [string range $scale 0 end-1]
append scale [format %2d [expr {$i / 20}] ]
} elseif { [expr {$i % 10}] == 0 } {
append scale "\\"
} elseif { [expr {$i % 5}] == 0 } {
append scale "."
} else {
append scale " "
}
if { $l <= $t && $t <= $r } {
append trace "_"
} else {
append trace "X"
}
}
puts $scale
puts "$trace"
return 
}











proc get_time { cycle angle period} {
return [expr {$period * $cycle + $angle/360.0*$period } ]
}
















proc margins { t window } {
sett {l r} $window
set setup [expr {$t - $l} ]
set hold [expr {$r - $t} ]
return [list $setup $hold]
}











proc in_window { cycle angle window period } {
set t [get_time $cycle $angle $period]
sett {l r} $window
return [expr {$l <= $t && $t <= $r}]
}






#   * phases - a list of clock phases that are available e.g. {0 90 180 270}






proc find_phase { window phases period } {
set res [list]
foreach cycle {-2 -1 0 1 2 3 4 5 6} {
foreach angle $phases {
if { [in_window $cycle $angle $window $period] }  { 
sett {setup hold} [margins [get_time $cycle $angle $period] $window]
lappend res [list $cycle $angle $setup $hold]
}
}
}
return $res
}












proc middle_of_win { window period } {
sett {l r} $window
set tmid [expr { ($l + $r)/2.0 }]
set cycle [expr {int($tmid / $period) } ]
set angle [expr {360.0 * ($tmid - $cycle * $period) / $period } ]
return [concat [list $cycle $angle] [margins $tmid $window]]
}










proc max_slack { window period } {
sett {l r} $window
set tmid [expr {($l + $r)/2.0} ]

set qcycles [expr { round (4.0 * $tmid / $period) } ]
set cycle [expr { int( floor( $qcycles  / 4.0 )) } ]
set angle [ expr { int(($qcycles - 4*$cycle) * 90 )} ]
set t [expr {$cycle*$period + $angle/360.0*$period} ]
return [concat [list $cycle $angle] [margins $t $window]]
}









proc adjust_cycle { clock window period} {
::ddr::type::check int $clock "::ddr::phasesel::adjust_cycle.clock"
::ddr::type::check int [lindex $window 0] "::ddr::phasesel::adjust_cycle.window0"
::ddr::type::check int [lindex $window 1] "::ddr::phasesel::adjust_cycle.window1"
::ddr::type::check int $period "::ddr::phasesel::adjust_cycle.period"
::ddr::utils::assert {[llength $window] == 2} {$window}





set dvw_mid [expr { ([lindex $window 0] + [lindex $window 1])/2.0 - $clock}]
set cycles [expr {round($dvw_mid/$period) }]
return $cycles
}

proc main {} {
set win [list 160 180]
set period 100

draw_window $win $period

puts "middle of window is: [middle_of_win $win $period]"

set possible [find_phase $win {0 90 180 270} $period]

foreach p $possible { 
sett {cycle angle setup hold} $p
puts "$cycle.$angle is ok $setup-$hold"
}

puts "max slack:[max_slack $win $period]"

puts "sysclk_phase:[find_phase $win {0} $period ]"
puts "not270_phase:[find_phase $win {0 90 180} $period]"
puts "any_phase:[find_phase $win {0 90 180 270} $period]"
}

}
