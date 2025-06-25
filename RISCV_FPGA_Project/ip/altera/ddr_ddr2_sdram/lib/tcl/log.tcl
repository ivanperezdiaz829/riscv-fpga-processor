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




package provide ::ddr::log 0.1
package require Itcl 


namespace eval ::ddr::log { 
itcl::class Logger {
private variable messages
private variable filehandle
private variable logFileName
private variable showhide





constructor { outputFile show hide } {
switch -- $outputFile {
"--" {
set filehandle stdout
}
"internal" {
set filehandle "internal"
}
default {
set filehandle [open $outputFile w]
set logFileName $outputFile
}
}
foreach s $show {
set showhide($s) 1
}
foreach h $hide {
if { [ info exists showhide($h)] } {
error "log tag $h appears on both show and hide list of logger"
}
set showhide($h) 0 
}
set fn $outputFile
}
# log { severity type msg } - write a log message if severity is high enough


public method log {severity type msg } {
set error [catch {
if { [info exists showhide($severity)] } {
if { $showhide($severity) } {
writeLog $severity $type $msg
}
} else {


writeLog UNKNOWN_LEVEL $type "Warning from logger: bad severity \"$severity\" used in next message:"
writeLog UNKNOWN_LEVEL $type $msg
}
} error_message]


if { $error } {
puts stderr "Error thrown inside logger on message \"$severity ($type) $msg\":"
puts stderr $error_message
}
}

public method getTail {} {
set res $messages
set messages ""
return $res
}


private method writeLog {severity type msg} {
set str "$severity ($type) $msg"
switch $filehandle {
stdout {
puts $str
} 
internal {
append messages $str
append messages "\n"
}
default {
puts $filehandle $str

}
}
}

destructor {
switch $filehandle {
stdout {
#puts "logger Closed"
} 
internal {
if { $messages != "" } {
puts stderr "Warning logger closed with messages stored internally"
puts stderr $messages
}
}
default {
close $filehandle
}
}	
}
}


}
