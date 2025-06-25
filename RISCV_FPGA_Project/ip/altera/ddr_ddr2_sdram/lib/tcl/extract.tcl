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











package provide ::ddr::extract 0.1



if {[info exists argv0] && [string match quartus_tan* $argv0] } {
package require ::quartus::advanced_timing
package require ::quartus::timing
}
package require ::ddr::utils

namespace eval ::ddr::extract {
namespace export dump_node
namespace export hunt_node
namespace export dump_all
namespace export follow_edge
namespace export follow_edge2
namespace export pll_info
namespace export pll_phase
namespace export edge_delay_in_ps
namespace export is_pin

if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}











proc dump_node { node } {
set res ""
foreach i { name type delay synch_edges clock_edges fanout_edges asynch_edges clock_info} {
set $i [get_timing_node_info -info $i $node]
}
append res "($type) $name\n"
if { $clock_info != "" } { 
append res "clock_info:$clock_info\n"
}

foreach edgelist {asynch_edges synch_edges clock_edges fanout_edges} {
if { [catch { llength [set $edgelist] } ] } {
error [set $edgelist]
}
}

foreach se $asynch_edges {
set src_edge [get_timing_edge_info -info src_node $se]
append res " - asynch to [get_timing_node_info -info name $src_edge] [get_timing_edge_info -info delay_string $se]\n"
}
foreach se $synch_edges {
set src_edge [get_timing_edge_info -info src_node $se]
append res " - synch to [get_timing_node_info -info name $src_edge] [get_timing_edge_info -info delay_string $se]\n"
}
foreach se $clock_edges {
set src_edge [get_timing_edge_info -info src_node $se]
append res " - clock to [get_timing_node_info -info name $src_edge] [get_timing_edge_info -info delay_string $se]\n"
}
foreach se $fanout_edges {
set dst_edge [get_timing_edge_info -info dst_node $se]
append res " - fanout to [get_timing_node_info -info name $dst_edge] [get_timing_node_info -info type $dst_edge] [get_timing_edge_info -info delay_string $se]\n"
}
append res " \\ located at [get_timing_node_info -info location $node]"
return $res
}














proc hunt_node { name type } {
foreach_in_collection node [get_timing_nodes -type $type ] {
set nodename [get_timing_node_info -info name $node]
if { $nodename == $name } {
return $node
}
}
error "hunt_node: failed to find node $name of type $type"
}











proc dump_all {} {
foreach_in_collection edge [get_timing_edges] {	
set src_node [get_timing_edge_info -info src_node $edge]
set dst_node [get_timing_edge_info -info dst_node $edge]

set src_name [get_timing_node_info -info name $src_node]
set dst_name [get_timing_node_info -info name $dst_node]
puts  "$src_name --> $dst_name [get_timing_edge_info -info delay_string $edge]"
}
return
}











proc edge_delay_in_ps { edge } {

set src_node [get_timing_edge_info -info src_node $edge]
set src_node_delay_str [get_timing_node_info -info delay $src_node]
set src_node_delay [expr {round([lindex $src_node_delay_str 0] * 1000)}] ; # convert "4.551 ns" into 4551

set delayf [get_timing_edge_delay -total $edge]
set delay [expr {round([lindex $delayf 0] * 1000)}] ; # convert "4.551 ns" into 4551
set delay [expr {$delay + $src_node_delay}]

set d_icf [get_timing_edge_info -info ic_delay $edge]
set d_ic [expr {round([lindex $d_icf 0] * 1000)}] ; # convert "4.551 ns" into 4551
set d_cellf [get_timing_edge_info -info cell_delay $edge]
set d_cell [expr {round([lindex $d_cellf 0] * 1000)}] ; # convert "4.551 ns" into 4551
# assert { 0 } { $d_ic $d_cell $delay }
set delay2 [expr {$src_node_delay + $d_ic + $d_cell } ]

assert { $delay == $delay2} { $delay $delayf $delay2 $d_icf $d_ic $d_cellf $d_cell}
return $delay
}

proc is_pin { pinnode } {
return [string match PIN_* [get_timing_node_info -info location $pinnode]]
}

























# failflag is only set to an error message if it is "", i.e. there hasn't been an error already.
# One check to make sure that the variable pointed to by failflag is still "" at the end of a block is all that is necessary.




#  if { [follow_edge2 regnode synch {dq$} delays(delay3) dotty_nodes ""] } {
#		warn_user "Couldn't find..."
#  }

#  set errmsg ""
#  follow_edge2 regnode synch {reg1$} delays(pin_rmyeg) debug_callback errmsg
#  follow_edge2 regnode synch {reg2$} delays(pin_rmyeg) debug_callback errmsg

#  if { $errmsg != "" } {
#   puts "extraction failed: $errmsg"
#  }

proc follow_edge2 { node type regexp delayvar debug_proc failflag} {
upvar $node upnode
::ddr::utils::assert { $upnode != "" } {node}














switch -- $type {
synch {
set i synch_edges



set dir src_node
set force_pin 0
}
clock {
set i clock_edges
set dir src_node
set force_pin 0
}
async {
set i asynch_edges
set dir src_node
set force_pin 0
}
fanout {
set i fanout_edges
set dir dst_node
set force_pin 0
}
pin_clock {
set i clock_edges
set dir src_node
set force_pin 1
}
default {
error "Bad type for follow edge. Must be one of (synch,clock,async,fanout,pin_clock). Got:$type "
}
}





set nodes_to_process [list]  
foreach edge [get_timing_node_info -info $i $upnode] {
set nextnode [get_timing_edge_info -info $dir $edge]
set delay [edge_delay_in_ps $edge]
lappend nodes_to_process [list $nextnode $delay [list]]
}


set output_nodes [list]

while { [llength $nodes_to_process ] > 0 } {
assert { [llength $nodes_to_process] < 1000000 } 
sett {n del feedernodes}  [lindex $nodes_to_process 0]
set nodes_to_process [lrange $nodes_to_process 1 end]

set name [get_timing_node_info -info name $n]

if { [regexp $regexp $name] && (! $force_pin || [is_pin $n]) } {
lappend output_nodes [list $n $del $feedernodes]
} elseif { [regexp "~(feeder(_\[0-9\]+)?|clkctrl|clkctrl_\[rde\])\$" $name]  } {


foreach edge [get_timing_node_info -info $i $n] {
set nextnode [get_timing_edge_info -info $dir $edge]
set delay [expr { [edge_delay_in_ps $edge] + $del } ] ;
lappend nodes_to_process [list $nextnode $delay [concat $feedernodes [list $n]] ]
}
} else {

}
}
if { [llength $output_nodes] == 1 } {
sett {next_node d feedernodes} [lindex $output_nodes 0]

set upnode $next_node

if { $delayvar != "" } {
upvar 1 $delayvar updelay
incr updelay $d
}

foreach feedernode [concat $feedernodes [list $next_node]] {
if { $debug_proc != "" } {
$debug_proc $node $feedernode; # i.e. "myproc regnode 123"
}
}
return 0
} else {
#puts "failflag: $failflag"
if { $failflag != "" } {
upvar 1 $failflag failmsg 
#puts "failmsg:$failmsg"
if { $failmsg == "" } {
set failmsg "Moving $node failed: Wanted $regexp on node [dump_node $upnode]"
}
}
return 1
}
}















#  Find the node that clocks the register called "mynode":
#   set n [hunt_node "mynode" reg]


proc follow_edge { node type {regexp ""} {delayN ""} } {

if { [catch { expr {$node +1 } } ] } { error "Parameter node to follow_edge must be an integer, not $node" }
switch -- $type {
synch {
set i synch_edges



set dir src_node
}
clock {
set i clock_edges
set dir src_node
}
async {
set i asynch_edges
set dir src_node
}

fanout {
set i fanout_edges
set dir dst_node
}
default {
error "Bad type for follow edge. Must be one of (synch,clock,fanout)."
}
}
set edges_all [get_timing_node_info -info $i $node]
set nextnodes [list]
foreach edge $edges_all {
set nextnode [get_timing_edge_info -info $dir $edge]
set name [get_timing_node_info -info name $nextnode]
set delay [get_timing_edge_delay -total $edge]
set delay [expr {int([lindex $delay 0] * 1000)}] ; # convert "4.551 ns" into 4551
if { [regexp $regexp $name] } {
lappend nextnodes [list $nextnode $delay]
}
}
if { [llength $nextnodes] != 1 } {
error "Less/More than one ([llength $nextnodes]) matching timing edge found for node: [dump_node $node]\nWas trying to follow an $type edge that matched $regexp"
}
::ddr::utils::sett {node delay} [lindex $nextnodes 0]
if {$delayN != "" } { 
upvar $delayN delayVar
incr delayVar $delay  
}
return $node
}



#  ::ddr::extract::pll_info {node } 










proc pll_info  { node } {
if { $node == "" } {
error "pll_info: invalid node id (was \"$node\")"
}
set name [get_timing_node_info -info name $node]
if { [string match *altpll* $name ] && [string match *_clk* $name] } {
set clock_edges [get_timing_node_info -info clock_edges $node] 
if { [llength $clock_edges] != 1 } {
error "node $name has more than one incomming clock edges, can't find pll shift from it."
} 
set clock_edge [lindex $clock_edges 0]
set delay [get_timing_edge_info -info cell_delay $clock_edge]
# delay looks like "-1.003 ns"
return [lindex $delay 0]
} else {
error "name of node ($name) doesn't look like the clkout of a pll. It doesn't match *altpll* and *_clk*."
}
}










#   A list of {phase shift in ps, phase angle in degrees (0 <= x < 360) }




#   ::ddr::extract::pll_phase  "${rootpath}rdata\[0\]"  "${rootpath}dq_enable_reset\[0\]"   $clock_period

proc pll_phase { sys_reg clk1_reg clk_period } {
set n1 [hunt_node $sys_reg reg]
set n2 [hunt_node $clk1_reg reg]


for { set i 0 } { $i < 3 } {incr i } {
set n1 [follow_edge $n1 clock]
set n2 [follow_edge $n2 clock]
catch {
set pll0 [pll_info $n2]
set pll1 [pll_info $n1]
break	
}
}


set shift [expr {1000.0 * (0.0 + $pll0 - $pll1)}]
if { $shift < 0.0 } {
set shift [expr {$shift + $clk_period} ]
}
set deg [expr {$shift * 360.0 / $clk_period}]
return [list $shift $deg]
} 
}











# if { 0 } {


# 	puts "Compile done"
# }

# set c [hunt_node "clk~out0" comb]
# set n1 [hunt_node "o1~reg0" reg]
# set n2 [hunt_node "o2~reg0" reg]



# puts "PLL clock 1"



# puts "PLL clock 2"






# set clk_period [expr {1000 / 100} ]
# set shift [expr {0.0 + $pll0 - $pll1}]
# if { $shift < 0.0 } {
# 	set shift [expr {$shift + $clk_period} ]
# }
# set deg [expr {$shift * 360.0 / $clk_period}]
# puts "pll shift is $shift ns / $deg deg"




