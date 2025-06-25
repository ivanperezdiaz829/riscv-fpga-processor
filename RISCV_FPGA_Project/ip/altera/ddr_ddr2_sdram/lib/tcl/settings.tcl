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









package provide ::ddr::settings 0.1

namespace eval ::ddr::settings {
namespace export read
namespace export read_temp












proc read  {filename array_name } {
upvar $array_name local_array





if  {[ catch { open $filename  r }   user_id  ]} {
error "Couldn't open settings file $filename (pwd is [pwd] script is [info script]) "
} else {
set line_number 0
while { [gets $user_id  in_line   ] >= 0 }  {
incr line_number
set in_line [string trimleft $in_line]
if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line] && ![regexp "^(?:\/\/.*)+$" $in_line]} { ;

if {[regexp {(\w+)\s*=([ a-zA-Z0-9_\.\-\/\t|:\[\]]*)(?:\-\-.*)?} $in_line dummy param_name param_value]} {
# no. see SPR158287 if {$param_value == ""} {set param_value "\"\""}
set local_array($param_name) [string trim $param_value]
} else {
error "line $line_number invalid parameter format: $in_line"
}
}

}
close $user_id
}
return
}




proc read_temp { filename } {
if { [ catch { open $filename  r }   user_id  ] } {
error "Cant read file '$filename'"
}
set    line_num                    0 
while { [gets $user_id  in_line   ] >= 0 }  {
set in_line [string trimleft $in_line]
set line_num [expr {$line_num + 1}]


if { [string compare $in_line  "" ] == 0 } { continue }
if { [scan $in_line   "%s" dummy  ] == -1} { continue }       
if { [ string compare [string index $in_line 0] - ] == 0 }   { continue }
scan  $in_line " %s = %s"   user_var   user_val
upvar $user_var x
set x $user_val
}
close $user_id
}
}

