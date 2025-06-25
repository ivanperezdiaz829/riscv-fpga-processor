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








#  if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}




package provide ::ddr::utils 0.1
package require Itcl 


namespace eval ::ddr::utils { 
namespace export sett 
namespace export string_chop_left
namespace export string_chop_right
namespace export wrap_to_clock_period
namespace export get_cycles_from_ps
namespace export unpack_array
namespace export assert
namespace export fold_margins
namespace export writeout
namespace export normalise_clock_frequency
namespace export min
namespace export max
namespace export expr_debug
namespace export degrees_to_clock_and_edge
namespace export adjust_for_cas_latency
namespace export fix_up_tco




#  Sett {var1 var2 ...} [list a b ...] - set tuple. Unpack a list (tuple) into variables









#   proc foo { bar } {


#   }
#   sett {xpos ypos} [foo $bbb]

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







proc string_chop_left { str  str_prefix } {
set length_of_prefix        [expr [string length $str_prefix] - 1  ]
set chopped     [ string replace   $str    0  ${length_of_prefix}  ]
return $chopped
}







proc string_chop_right { str  str_postfix } {
set length_of_postfix       [expr [string length $str_postfix] - 1  ]
set length_of_str           [expr [string length $str] - 1  ]
set length_of_chopped       [expr  $length_of_str -  $length_of_postfix]
set chopped                 [ string replace   $str    ${length_of_chopped}  ${length_of_str}  ]
return $chopped
}





















proc wrap_to_clock_period  { delay_in_ps clock_period } {
if { [expr {$clock_period <= 0 } ] } { error "clock_period must be positive (was $clock_period)" }
if { [expr {fmod($delay_in_ps, 1.0) != 0.0} ] } { 
# puts stderr  "delay_in_ps is not integer (was $delay_in_ps). Have you specified it in ns rather than ps?"
}
if { [expr {fmod($clock_period, 1.0) != 0.0} ] } { 
# puts stderr "clock_period is not integer (was $clock_period). Have you specified it in ns rather than ps?"
}
return       [ expr { int ( $delay_in_ps ) % int ( $clock_period )  } ]
}























proc get_cycles_from_ps  { delay_in_ps clock_period} {
if { [expr {$clock_period <= 0 } ] } { error "clock_period must be positive (was $clock_period)" }
if { [expr {fmod($clock_period, 1.0) != 0.0} ] } { error "clock_period is not integer (was $clock_period). Have you specified it in ns rather than ps?"}

return       [ expr { int ( $delay_in_ps  / $clock_period )  } ]
}	



proc write_to_error_log { logfile wn key msg } {


set f [open $logfile a]
set revision {$Revision: #1 $}
puts $f "[clock format [clock seconds]] $revision $wn key:$key $msg"
close $f
}








#              or a pair of elements {key varname} in which case varname will be set to $arrayname($key)








#   unpack_array myarray {

#     {bar bar_temp}
#     {baz boink tolower}
#   }
#   puts "$foo $bar_temp"



proc unpack_array { arrayname mapping {testmode 0} {testerrorfile "errlog"} } {
if { ! [uplevel 1 [list info exists $arrayname]] } {
error "::ddr::utils::unpack_array:$arrayname doesn't exist"
}
if { $testmode != 0 && $testmode != 1 && $testmode!=2 } {
error "Invalid testmode:$testmode. Must be 0,1 or 2"
}
upvar $arrayname local_array
foreach map [split $mapping \n] {
set map [string trim $map]
if { [string match "#*" $map ] } { continue }
if { $map == "" } { continue }
if { [llength $map] != 1 } {error "bad line: $map" }
set map [lindex $map 0]
#puts "map is $map"
set length [llength $map]
set conv ""
if { $length == 1 } {
set key [lindex $map 0]
set upvarname [lindex $map 0]
} elseif { $length == 2 } {
set key [lindex $map 0]
set upvarname [lindex $map 1]
} elseif { $length == 3 } {
set key [lindex $map 0]
set upvarname [lindex $map 1]
set conv [lindex $map 2]
} else {
error "::ddr::utils::unpack_array:mapping $map had $length elements. Should be 1-3."
}
if { [info exists local_array($key)] } {
set array_value $local_array($key)
switch -- $conv {
"" { } 
tolower {
set array_value [string tolower $array_value]
}
toupper {
set array_value [string toupper $array_value]					
}
default {
error "Unknown conversion type $conv. Must be either 'tolower' or 'toupper'."
}
}
upvar $upvarname lname



if {$testmode== 1 || $testmode==2 } {
if { [info exists lname] } {
if { $lname != $array_value } {
set wn $local_array(wrapper_name)
if { ! ( $lname == "-999999" && ($array_value=="\"\"" || $array_value=="0" ) ) } {
write_to_error_log $testerrorfile $wn $key "right:$lname res:$array_value"
}
}
} else {
set wn $local_array(wrapper_name)
write_to_error_log $testerrorfile $wn $key "$upvarname is not present"
}
}
if { $testmode == 0 || $testmode==2} {
set  lname $array_value
} 
} 
            ## else 
			  ##	# ie ! [ info exists local_array($key)]
##	error "::ddr::utils::unpack_array:key $key not found in array $arrayname"
			##
}
}








#  ""






#   % assert { $x == 1 }
#   ASSERTION FAILED:  $x == 1  threw an error: can't read "x": no such variable


#   % assert { $x == 1 }



#   % assert { $x == 1 }





#   % assert { $x * 5 < 100 } { {$x*5} {[info script]} } "In package002 "


proc assert { expr {debugexp ""} {msg ""}} {
set c [ catch { uplevel 1 expr \{ $expr \}	}  d ] 
#puts "$c:$d"


if { $c==0 } {
if { $d==1} {

return
} else {
set message "ASSERTION FAILED($expr)"
}
} else {
set message "ASSERTION FAILED($expr) threw an error: $d"
}
if { $msg != "" } {
append message " "
append message $msg
}
foreach exp $debugexp {
catch { uplevel 1 expr \{ $exp \} } res
append message " $exp:[list $res]"
}
flush stdout ;
puts stderr $message
flush stderr
after 100 ;
}








#  As a special case, if the contents of the variable pointed to by varname is "", then









#   set capture "" ;
#   foreach pin $pins {


#   }

#   set margins(capture) ""


proc fold_margins { varname margins } {
upvar 1 $varname overall_margins

assert { [info exists overall_margins] } { $varname $overall_margins}
assert { [llength $margins] == 2 } { $margins }
::ddr::type::check int [lindex $margins 0] "::ddr::utils::fold_margins.margins"
::ddr::type::check int [lindex $margins 1] "::ddr::utils::fold_margins.margins"
if { $overall_margins != "" } {
::ddr::type::check int [lindex $overall_margins 0] "::ddr::utils::fold_margins.overall_margins"
::ddr::type::check int [lindex $overall_margins 1] "::ddr::utils::fold_margins.overall_margins"
}
sett { s h } $margins
if { $overall_margins == "" } {
sett {setup hold} $margins 
} else {
sett { setup hold} $overall_margins

set setup [expr {$setup - $s < 0 ? $setup : $s }] ;
set hold [expr {$hold - $h < 0 ? $hold : $h }]
}
set overall_margins [list $setup $hold]
}

proc writeout {filename vars} {
set f [open $filename w]
foreach varname $vars {
upvar 1 $varname var
if { [array exists var] } {
puts $f "# array [list $varname]"
foreach {k v} [array get var] {
puts $f "  set [list $varname]($k) [list $v]" ;
}
} elseif { [info exists var] } {
puts $f "set [list $varname] [list $var]"
} else {
puts stderr "Can't find $var"	
}
}
close $f
}








proc normalise_clock_frequency { clock_freq } {
set normalised 0
set clock_period [expr {round ( 1000000.0 / $clock_freq  ) }]
if { ( $clock_freq >= 133 ) && ( $clock_freq <= 134 ) } {
set         clock_period        7500
set normalised 1
} elseif { ( $clock_freq >= 166 ) && ( $clock_freq <= 167 ) } {
set         clock_period        6000
set normalised 1
} elseif { ( $clock_freq >= 233 ) && ( $clock_freq <= 234 ) } {
set         clock_period        4285
set normalised 1
} elseif { ( $clock_freq >= 266 ) && ( $clock_freq <= 267 ) } {
set         clock_period        3750
set normalised 1
}
if { $normalised } {
global note_clock_has_been_normalised
message_out Note "$note_clock_has_been_normalised ${clock_period} ps."
}
set clock_freq_actually_used    [ expr { 1000000.0 / $clock_period } ]
set real_freq_in_mhz        [ format "%3.2f"  $clock_freq_actually_used ]
return [list $clock_freq_actually_used $clock_period]
}

proc min { a b } {
if { $a == "" } { 
return $b
} elseif { $a < $b } {
return $a
} else {
return $b
}
}

proc max { a b } {
if { $a == "" } { 
return $b
} elseif { $a > $b } {
return $a
} else {
return $b
}
}


proc expr_debug { exp } {
upvar expr_debug_e expr_debug_e
set expr_debug_e $exp
uplevel {
puts "-----------------"
puts "[regsub -all {[\n \t]+} $expr_debug_e " "]"
puts "-----------------"
puts [regsub -all {[\n \t]+} [subst $expr_debug_e] " "]
puts "-----------------"
set expr_debug_temp [expr $expr_debug_e]
puts "=$expr_debug_temp" 
puts "-----------------"
return $expr_debug_temp
}
}













proc degrees_to_clock_and_edge { degrees } {

if { ![string is integer $degrees] } {
assert {0} {$degrees} "degrees is not an integer"
if { [string is double $degrees] } {
set degrees [expr {round($degrees)}]
} else {
set degrees 0
}
}	
switch $degrees {
0 { return [list clk rising] }
90 { return [list write_clk falling] }
180 { return [list clk falling] }
270 { return [list write_clk rising] }
default { 
return [list dedicated rising]
}
}
assert {0} {$degrees} "degrees_to_clock_and_edge:Unreachable Code"
}








proc adjust_for_cas_latency { to_CASL delay from_CASL period } {

assert {$from_CASL == 2.5} {$from_CASL} "adjust_for_cas_latency only supports CASL of 2.5"
set normalise [expr { ($to_CASL - $from_CASL ) * $period }]
return [expr {round($delay + $normalise)}]
}




proc fix_up_tco {delays min_tco max_tco} {
array set res $delays
assert {[info exists res(sysclk_pin_min)]}
assert {[info exists res(sysclk_pin_max)]}
::ddr::type::check int $min_tco "::ddr::utils::fix_up_tco.min_tco"
::ddr::type::check int $max_tco "::ddr::utils::fix_up_tco.min_tco"
set res(sysclk_pin_min) $min_tco
set res(sysclk_pin_max) $max_tco
return [array get res]
}

}

