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










package provide ::ddr::paths 0.1


package require ::ddr::utils
package require ::ddr::extract
package require ::ddr::type

namespace eval ::ddr::paths {
namespace export extract_c2_ddr
namespace export extract_c2_clkout
namespace export extract_clk_tco
namespace export check_datapath_present
namespace export sentinel	


if { [package require ::ddr::extract] != "" } {	namespace import ::ddr::extract::*	}
if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*	}



#  extract_c2_ddr $node "\|fred_auk_ddr_datapath:ddrio\|" - Extract the timing paths for c2 ddr






#   * "" if the node isn't the input of a ddr dq pin




proc extract_c2_ddr { node wrappername  enable_postamble debugproc} {
#puts "extract_c2_ddr $wrappername [dump_node $node]"

if { [get_timing_node_info -info type $node] != "pin" } { error "node $node ([get_timing_node_info -info name]) is not a pin" }
if { [info commands $debugproc] == "" } { error "debugproc $debugproc doesn't exist" }
if { [llength [info args $debugproc]] != 2 } { error "debugproc $debugproc has wrong args, wanted two got [info args $debugproc]" }


set fanout [get_timing_node_fanout $node]
if { [llength $fanout]  != 1 } { 
return ""
}
set int_node_name [get_timing_node_info -info name [lindex $fanout 0 0 ]]




if { ! [regexp "\\|${wrappername}_auk_ddr_datapath:ddr_io\\|${wrappername}_auk_ddr_dqs_group:.g_datapath:\[0-9\]+:g_ddr_io\\|altddio_bidir:.g_dq_io:" $int_node_name] } {
#puts "regexp no match \\|${wrappername}_auk_ddr_datapath:ddr_io\\| $int_node_name"
return ""
}
#puts "got pin"

set dq_pin_name [get_timing_node_info -info name $node]
#puts "-------------------------\npin $dq_pin_name is a DQ pin for $wrappername"
$debugproc dqpin $node


array unset lresult
array unset hresult


foreach hl { h l } {
set delays(dq_capture) 0
set regnode $node
set errmsg "" 
#puts "regnode is [dump_node $regnode]"
follow_edge2 regnode fanout {~COMBOUT$} delays(dq_capture) $debugproc errmsg
assert { $delays(dq_capture) > 0 } { $delays(dq_capture) } 
follow_edge2 regnode fanout "input_cell_${hl}\\\[\[0-9\]+\\\]\$" delays(dq_capture) $debugproc errmsg

if { $errmsg != "" } { puts $errmsg } 
#puts "regnode is [dump_node $regnode]"
#puts "$hl Register is [dump_node $regnode]"


set delays(clkctrl_capture) 0
set delays(dqs_clkctrl) 0
set dqsnode $regnode
follow_edge2 dqsnode clock "wire_dqs_clkctrl_outclk\\\[\[0-9\]+\\\]\$"  delays(clkctrl_capture) $debugproc errmsg

set clkctrl_node $dqsnode ;
#puts stderr "$hl dqs pin1 is [dump_node $clkctrl_node]"

follow_edge2 dqsnode clock "delayed_dqs\\\[\[0-9\]+\\\]\$"  delays(dqs_clkctrl) $debugproc errmsg
#puts "$hl dqs pin2 is [dump_node $dqsnode]"

follow_edge2 dqsnode clock "~"  delays(dqs_clkctrl) $debugproc ""

follow_edge2 dqsnode clock {\|combout\[[0-9]+\]} delays(dqs_clkctrl) $debugproc ""

follow_edge2 dqsnode clock ""  delays(dqs_clkctrl) $debugproc errmsg
#puts "$hl dqs pin4 is [dump_node $dqsnode]"
assert { [get_timing_node_info -info type $dqsnode] == "clk" || [get_timing_node_info -info type $dqsnode] == "pin" } {{[dump_node $dqsnode]}  {[get_timing_node_info -info type $dqsnode]}} "Tracking back from dq pin to dqs pin didn't get to a node of type clk or pin."

set delays(clkctrl_resync) $delays(clkctrl_capture) ;

set delays(capture_resync) 0
set resyncnode $regnode

if { $hl == "l" } {
follow_edge2 resyncnode fanout "input_latch_l\\\[\[0-9\]+\\\]\$" "" $debugproc errmsg 
}

follow_edge2 resyncnode fanout "resynched_data\\\[\[0-9\]+\\\]" delays(capture_resync) $debugproc errmsg

#puts "$hl resync register is [dump_node $resyncnode]"


if { $enable_postamble } {

set delays(clkctrl_posten) 0 
set postennode $clkctrl_node
#puts "clkctrl_node is [get_timing_node_info -info name $clkctrl_node]"
#puts "postennode is [get_timing_node_info -info name $postennode]"
#puts "the next line will fail:"
follow_edge2 postennode fanout "dq_enable\\\[\[0-9\]+\\\]\$" delays(clkctrl_posten) $debugproc errmsg
#puts "enable node is:[dump_node $postennode]"

set temp $regnode
set delays(posten_capture) 0
follow_edge2 temp synch "dq_enable\\\[\[0-9\]+\\\]\$" delays(posten_capture) $debugproc errmsg


#follow_edge2 clkctrlnode2 fanout "~OBSERVABLEOUT$" delays(posten_clkctrl) $debugproc errmsg
#puts "failed here"

set delays(postctrl_posten) 0 
set postctrlnode $postennode
follow_edge2 postctrlnode async "dq_enable_reset\\\[\[0-9\]+\\\]\$" delays(postctrl_posten) $debugproc errmsg

follow_edge2 postennode synch "dq_enable\\\[\[0-9\]+\\\]\~feeder$" "" $debugproc errmsg
#puts "postamble en feeder is [dump_node $postennode]"
}
if { $errmsg != "" } {

error "$errmsg"
}

#puts "delays are [array get delays]"

set re $wrappername

append re {_auk_ddr_dqs_group:\\g_datapath:([0-9]+):g_ddr_io\|resynched_data\[([0-9]+)\]}
set resync_reg_name [get_timing_node_info -info name $resyncnode]
if {! [regexp $re $resync_reg_name foobar dqsgroupnumber half_dq_number] } { 
error "regexp  $re didn't match $resync_reg_name at node [::ddr::extract::dump_node $resyncnode]"
}
set half_dq_number [expr {$dqsgroupnumber *16 + $half_dq_number} ]

set delays(name) $dq_pin_name
set delays(number) $half_dq_number
foreach {k v} [array get delays] {
if { $v == "h" } { 

} elseif {$v == "l" } {

} elseif { $k == "name" } {

} elseif { $k == "number" && [string is integer $v] } {

} elseif {[string is integer $v] && ($v > 0) } { 

} else {
assert {false} {$k $v} "Delay unreasonable"
}
}
array set ${hl}result [array get delays]
array unset delays

}




set ratio [expr { $lresult(dq_capture) *1.0 / $hresult(dq_capture) } ] 
if { $ratio < 1.0 } { set ratio [expr { 1.0 / $ratio} ] }
assert { $ratio < 1.5 } { $ratio $lresult(name) $lresult(number)  $hresult(number) $lresult(dq_capture) $hresult(dq_capture) } 

return [list [array get lresult] [array get hresult]]
}








proc extract_s2_clkout { node clockname tcovar} {
set node_name [get_timing_node_info -info name $node]
if { [get_timing_node_info -info type $node] != "pin" } { error "node $node ([get_timing_node_info -info name]) is not a pin" }

if { $node_name == $clockname } {
set tco 0
set errmsg ""

follow_edge2 node clock {~ddio_data_in_reg$} tco "" errmsg


for { set i 0 } { $i < 6 } {incr i } {
if { [llength [get_timing_node_fanin -type clock $node]] == "1" } {
follow_edge2 node clock "" tco "" errmsg
} else { 
break
}
}


if { ! [string match PIN_* [get_timing_node_info -info location $node]] || [get_timing_node_info -info type $node] != "clk" || [llength [get_timing_node_fanin -type clock $node]] != "0" } {

assert {0} {$node {[dump_node $node]}} "Couldn't find node of type clk when after fbc input"  
}

if { $errmsg == "" } {
upvar $tcovar up_tco
set up_tco $tco
return 1
} else {
puts "error: $errmsg"
return 0
}
} else {
return 0
}
}

















proc extract_clk_tco {family clkout_type wrappername clk_pin_names node min_tco_name max_tco_name} {
assert {$family=="cycloneii" || $family=="stratixii" } {$family} "::ddr::path::extract_tco: Only families 'cycloneii', and 'stratixii' are supported"
assert {$clkout_type == "ddio" || [string is integer $clkout_type]} {$clkout_type} "::ddr::paths::extract_clk_tco"
::ddr::type::check int $node
assert {$min_tco_name != ""}
assert {$max_tco_name != ""}
upvar 1 $min_tco_name min_tco
upvar 1 $max_tco_name max_tco
assert {[info exists min_tco]} {$min_tco_name}
assert {[info exists max_tco]} {$max_tco_name}

assert {$clkout_type=="ddio" || $family=="stratixii"} {$clkout_type} "Only ddio mode supported for non-StratixII Families"


set fanin [get_timing_node_info -info asynch_edges $node]
if { [llength $fanin]  >= 1 } { 
set found_tco 0
set mux $node
set failflag ""


set report_fail 0 	

set basename "${wrappername}_auk_ddr_datapath:ddr_io\\|${wrappername}_auk_ddr_clk_gen:ddr_clk_gen\\|altddio_out:ddr_clk_out_\[np\]"
if { $family == "cyclone" } {


::ddr::extract::follow_edge2 mux async "\\|${wrappername}_auk_ddr_clk_gen:ddr_clk_gen\\|altddio_out:ddr_clk_out_.\\|mux\\\[\[0-9\]\\\]~COMBOUT\$" found_tco "" failflag
if {$failflag=="" } { 
set report_fail 1
}
::ddr::extract::follow_edge2 mux async "~DELAY_CELL\$" found_tco "" failflag
} elseif { $family == "cycloneii" } {
::ddr::extract::follow_edge2 mux async "${basename}\\|ddio_out_...:auto_generated\\|muxa\\\[\[0-9\]\\\]\$" found_tco "" failflag
::ddr::extract::follow_edge2 mux async "~DELAY_CELL\$" found_tco "" failflag
} elseif { $family == "stratixii" } {
if { $clkout_type == "ddio" } {















::ddr::extract::follow_edge2 mux async "${basename}\\|ddio_out_...:auto_generated\\|ddio_outa\\\[\[0-9\]+\\\].ddio_data_in_reg\$" "" "" failflag
if { $failflag == "" } { set report_fail 1 }
set mux $node
::ddr::extract::follow_edge2 mux clock "\\|altpll:altpll_component\\|_clk.~clkctrl\$" found_tco "" failflag
set to_wdata_r 0
::ddr::extract::follow_edge2 mux fanout "\\|${wrappername}_auk_ddr_datapath:ddr_io\\|${wrappername}_auk_ddr_dqs_group:.g_datapath:0:g_ddr_io\\|wdata_r\\\[0\\\]\$" to_wdata_r "" failflag
set found_tco [expr {$found_tco - $to_wdata_r}]
} else {

set pinname [get_timing_node_info -info name $node]
set match 0
foreach clkname $clk_pin_names {
if { $clkname == $pinname } {
set match 1
break
}
}
if {$match} {
set report_fail 1
#puts "pin $pinname matches $clk_pin_names"
set found_tco 0
set to_wdata_r 0


















set temp $node
::ddr::extract::follow_edge2 temp clock "" found_tco "" failflag
::ddr::extract::follow_edge2 temp clock ":altpll_component\\|" found_tco "" failflag
::ddr::extract::follow_edge2 temp clock "" found_tco "" failflag

::ddr::extract::follow_edge2 temp fanout ":altpll_component\\|_clk0\$" to_wdata_r "" failflag

::ddr::extract::follow_edge2 temp fanout "\\|${wrappername}_auk_ddr_datapath:ddr_io\\|${wrappername}_auk_ddr_dqs_group:.g_datapath:0:g_ddr_io\\|wdata_r\\\[0\\\]\$" to_wdata_r "" failflag
set found_tco [expr {$found_tco - $to_wdata_r}]
} else {
#puts "pin $pinname doesn't match $clk_pin_names"
set failflag "Pin name didn't match $clk_pin_names"
}
}
} elseif { $family == "stratix" } {
::ddr::extract::follow_edge2 mux async "${basename}\\|stratix_ddio_out_no_areset:ddio_out\\\[\[0-9\]+\\\]\\|ioatom.dff_out1" found_tco "" failflag
} else { 
assert {0} {$family} "Unknown Family"
}
if { $failflag == "" } {
#puts "yes $found_tco"

set min_tco [::ddr::utils::min $min_tco $found_tco]
set max_tco [::ddr::utils::max $max_tco $found_tco]
return 1
} else {
if { $report_fail } {
puts "extract_clk_tco: unexpected clk_to_sdram extraction failure $failflag"
}
return 0
}
} else {
return 0
}
}














proc check_datapath_present { wrappername } {
#puts "Looking for $wrappername"
package require ::quartus::project

set num_matches 0;
set datapath_name_list ""
array unset datapath_hier_path
array set datapath_hier_path {}

set datapath_names [get_names -filter *auk_ddr_datapath* -node_type hierarchy]




set paths [list]
foreach_in_collection found_datapath $datapath_names {
set item_to_test [get_name_info -info full_path $found_datapath]
#puts "check_datapath_present $item_to_test"

if {[regexp -nocase {^(.*\|)(\S+)_auk_ddr_datapath:\w+$} $item_to_test full_path hier_path datapath_name]} {
if { $datapath_name == $wrappername } {
lappend paths $full_path
}
}
}
#puts "check_datapath_present($wrappername) found '$paths'"
if { [llength $paths] == 1 } {
return 1
} elseif {[llength $paths] == 2} {
puts "Working around SPR197866..."
return 1
} else {
#puts "check_datapath:skipping ..."
return 0
}
}

proc sentinel { d } {
return "pathssentinel$d"
}


}
