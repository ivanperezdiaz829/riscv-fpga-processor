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










package provide ::ddr::file 0.1

namespace eval ::ddr::file {
namespace export finder
















#   puts "0:[finder . log.txt 0]"
#   puts "1:[finder . log.txt 1]"
#   puts "2:[finder . log.txt 2]"



proc finder {dir file maxdepth} {
#puts "finder in $dir"
if { $maxdepth < 0 } { return [list] }
if { ! [file exists $dir] } { error "::ddr::file::finder:$dir doesn't exist" } 
set res [list]
if { [file type $dir] == "directory"  } {
if { $maxdepth > 0} {
set dirs [glob -nocomplain -directory $dir -- *]
foreach d $dirs {
set res [concat $res [finder $d $file [expr {$maxdepth - 1 }] ]]
}
}

} elseif { [file type $dir] == "file" } {
if { [file tail $dir] == $file } {
lappend res $dir
}
} else {
error "Unknown file type for $dir: [file type $dir]"
}
return $res
}	
}
