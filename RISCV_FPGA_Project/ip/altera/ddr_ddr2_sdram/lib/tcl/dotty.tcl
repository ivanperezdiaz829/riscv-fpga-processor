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









package provide ::ddr::dotty 0.1

package require ::quartus::advanced_timing
package require ::quartus::project 			;
package require ::ddr::extract 

namespace eval ::ddr::dotty { 
namespace export draw

proc makelabel { node } {
set n [get_timing_node_info -info name $node]
set d [get_timing_node_info -info delay $node]
set l [split $n |]
if { $d != "0.000 ns" } {
lappend l "(delay:$d)"
}
return "\"[join $l \\n]\""
}















proc draw { filename nodelist } {
set f [open $filename w]
puts $f "digraph G {"
set label "[get_global_assignment -name FAMILY]([get_global_assignment -name DEVICE]) [info script]\\n [clock format [clock seconds]]"
puts $f "graph \[center=true rankdir=TB label=\"$label\" size=15.5,10 ranksep=0.5\];"
puts $f "node \[fontname=Times fontsize=6 height=0.2 shape=rectangle \];"
puts $f "edge \[fontname=Times fontsize=6 \];"
if { [array exists includenodes ]} { array unset includenodes }
foreach nodeid $nodelist {
set includenodes($nodeid) ""
}
foreach_in_collection edge [get_timing_edges] {
set from [get_timing_edge_info -info src_node $edge]
set to [get_timing_edge_info -info dst_node $edge]
if { [info exists includenodes($to)] && [info exists includenodes($from)] } {
set fromn [get_timing_node_info -info name $from]
set ton [get_timing_node_info -info name $to]
set delay "[get_timing_edge_delay -total $edge]"
puts $f "/* from->to\n$fromn\n$ton\n*/"
puts $f "[makelabel $from] -> [makelabel $to] \[label=\"$delay\"\]"
#puts "[makelabel $fromn] -> [makelabel $ton]"
set includenodes($to) 1
set includenodes($from) 1
}
}
foreach {k v} [array get includenodes] {
if { $v != 1 } {
puts stderr "dotty didn't draw [::ddr::extract::dump_node $k]"
}		
}
puts $f "}"
close $f
array unset includenodes
}
}
