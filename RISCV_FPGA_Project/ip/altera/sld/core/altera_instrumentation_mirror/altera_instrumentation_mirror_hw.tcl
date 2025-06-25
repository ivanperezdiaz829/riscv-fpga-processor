# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# $Id: //acds/rel/13.1/ip/sld/core/altera_instrumentation_mirror/altera_instrumentation_mirror_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact qsys 13.0
package require altera_terp 1.0

#  -----------------------------------
# | altera_instrumentation_mirror
#  -----------------------------------
set_module_property name altera_instrumentation_mirror
set_module_property version 13.1
set_module_property group "Verification/Debug & Performance"
set_module_property display_name "Mirror for debug fabric"
set_module_property editable false
set_module_property internal true
set_module_property elaboration_callback elaborate

add_fileset synth quartus_synth generate "Quartus Synthesis"

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter COUNT       integer  1 "Number of nodes (including mirror)"
add_parameter MAX_WIDTH   integer 32 "Width of mirror node send/receive port"
add_parameter INNER_WIDTH integer  4 "Width of each nodes send/receive port"
add_parameter MIRROR_SLOT integer  0 "Which slot contains the mirror"
add_parameter NODE_SLOTS  string  {} "Which slots contain node information"
add_parameter PASS_SLOTS  string  {} "Which slots pass through to this fabric"

#  -----------------------------------
# | interfaces
#  -----------------------------------
add_interface nodes conduit end
add_interface_port nodes send send Input COUNT*MAX_WIDTH
add_interface_port nodes receive receive Output COUNT*MAX_WIDTH

add_interface pass conduit end
set_interface_property pass enabled false		
add_interface_port pass pass_send send Output 1
set_port_property pass_send termination true
add_interface_port pass pass_receive receive Input 1
set_port_property pass_receive termination true

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
	set pass      [llength [get_parameter_value PASS_SLOTS] ]
	set max_width [get_parameter_value MAX_WIDTH]
	
	if {$pass != 0} {
		set_interface_property pass enabled true		
	
		set pass_width [expr {$pass * $max_width}]
		set_port_property pass_send width_expr $pass_width
		set_port_property pass_send termination false
		set_port_property pass_receive width_expr $pass_width
		set_port_property pass_receive termination false
	}
}


#    Slot 3   Slot 2   Slot 1   Slot 0
#  |        |        |        |        |
#  | 0000bb | 0000cc | 223300 | 0000aa |


#  -----------------------------------
# | Generation callback
#  -----------------------------------
proc generate output_name {
    set this_dir      [get_module_property MODULE_DIRECTORY]
    set template_file [file join $this_dir "altera_instrumentation_mirror.sv.terp"]

    set template    [read [ open $template_file r ] ]

	set count        [get_parameter_value COUNT]
	set max_width    [get_parameter_value MAX_WIDTH]
	set single_width [get_parameter_value INNER_WIDTH]
	set mirror_slot  [get_parameter_value MIRROR_SLOT]
	set node_slots   [get_parameter_value NODE_SLOTS]
	set pass_slots   [get_parameter_value PASS_SLOTS]

	# Set each slot to 0 - will be overwritten when in use
	for {set i 0} {$i < $count} {incr i} {
		set jj [expr {$i * $max_width }]
		array set assign_map [list $jj "receive\[$jj+:$max_width\] = $max_width'b0"]
	}

	set assigns [list]

	set n [llength $node_slots]
	set spare_width [expr {$max_width - $single_width}]
	set remain $max_width
	
	set ii [expr {$mirror_slot * $max_width} ]
	
	for {set i 0} {$i < $n} {incr i} {
		set j [lindex $node_slots $i]
		
		set jj [expr {$j * $max_width }]  		

		array set assign_map [list $jj "receive\[$jj+:$single_width\] = send\[$ii+:$single_width\]"]
		array set assign_map [list $ii "receive\[$ii+:$single_width\] = send\[$jj+:$single_width\]"]
		
		set kk [expr {$jj + $single_width}]
		array set assign_map [list $kk "receive\[$kk+:$spare_width\] = $spare_width'b0"]
		
		incr ii $single_width
		set remain [expr {$remain - $single_width}]
	}

	if {$remain != "0"} {
		array set assign_map [list $ii "receive\[$ii+:$remain\] = $remain'b0"]
	}

	set pass [llength $pass_slots]
	if {$pass != 0} {
		set pass_width [expr {$pass * $max_width}]

		for {set i 0} {$i < $pass} {incr i} {
			set j [lindex $pass_slots $i]
		
			set ii [expr {$i * $max_width }]  		
			set jj [expr {$j * $max_width }]  		

			array set assign_map [list $jj "receive\[$jj+:$max_width\] = pass_receive\[$ii+:$max_width\]"]
			lappend assigns "pass_send\[$ii+:$max_width\] = send\[$jj+:$max_width\]"
		}
	} else {
		set pass_width 1
		lappend assigns "pass_send = 1'b0"
	}
	
	# Sort assignments into order for easy to understand output
	foreach j [lsort -integer [array names assign_map] ] {
		lappend assigns $assign_map($j)
	}

    # Collect parameter values for Terp
    set params(output_name) $output_name
	set params(width) [expr {$count * $max_width}]
	set params(pass_width) $pass_width
	set params(assigns) $assigns

	set result [altera_terp $template params]

    add_fileset_file ${output_name}.sv system_verilog text $result top_level_file
}
