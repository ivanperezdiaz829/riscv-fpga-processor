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







package provide ::ddr::mwinterface 0.1 


namespace eval ::ddr::mwinterface {
namespace export sentinel

proc report_msg { sever str } {
switch -glob -- $sever {
{[Ww]*}     { set severity "WARNING:" }
{[Ee]*}     { set severity "ERROR:  " }
{[Dd]*}     { set severity ">>>DEBUG>>>" }
{[Cc]*}		{ set severity "CRITWARNING:" } 
default     { set severity "NOTE:   " }
}
puts     stdout     "    MESSAGE             \"${severity}  $str\"" 
}
proc store_setting { key value } {
puts 	"STORESETTING $key \"$value\""
}
proc report_value { key name value {desc ""} } {
if { $desc == "" } { 

set desc " "
}
write_private $key $value
puts "REPORT\t$name\t$value\t$desc"
}
proc write_private { key value } {
puts 	"$key \"$value\""
}
proc report_margin { path margins } {
puts "REPORT\t$path\t[lindex $margins 0]\t[lindex $margins 1]\tps"
}

proc sentinel { d } {
return "mwinterface$d"
}
}
