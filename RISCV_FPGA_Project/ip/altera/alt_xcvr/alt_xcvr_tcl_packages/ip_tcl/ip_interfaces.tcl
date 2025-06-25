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



package provide alt_xcvr::ip_tcl::ip_interfaces 13.1 

package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::ip_tcl::ip_module

namespace eval ::alt_xcvr::ip_tcl::ip_interfaces:: {
  namespace export \
    add_fragment_prefix \
    create_fragmented_index_list \
    expand_fragmented_index_list \
    create_expanded_index_list \
    convert_list_to_map \
    partial_interface_message \
    create_fragmented_conduit \
    create_fragmented_interface
}


proc ::alt_xcvr::ip_tcl::ip_interfaces::add_fragment_prefix { frag_list prefix } {
  regsub -all {[0-9]+} $frag_list "${prefix}@&" frag_list
  return $frag_list
}


proc ::alt_xcvr::ip_tcl::ip_interfaces::create_fragmented_index_list { total_width group_width words width offset {list_select "used"} } {
  set used_list {}
  set unused_list {}

  set x 0
  set index 0

  while {$index < $total_width} {
    for {set y 0} {$y < $group_width && $index < $total_width} {incr y} {
      if {$x < $words && $y >= $offset && $y < [expr $offset + $width] } {
        set used_list [linsert $used_list 0 $index]
      } else {
        set unused_list [linsert $unused_list 0 $index]
      }
      incr index
    }
    incr x
  }

  set retval [expr {$list_select == "used" ? $used_list : $unused_list }]
  return $retval
}


proc ::alt_xcvr::ip_tcl::ip_interfaces::expand_fragmented_index_list { channels total_width index_list } {
  set new_list {}

  for {set c [expr $channels - 1]} {$c > 0} {set c [expr $c - 1]} {
    set add_val [expr $c * $total_width]
    foreach index $index_list {
      lappend new_list [expr $index + $add_val]
    }
  }
  set new_list [concat $new_list $index_list]

  return $new_list
}


proc ::alt_xcvr::ip_tcl::ip_interfaces::create_expanded_index_list { channels total_width group_width words width offset {list_select "default"} } {
  set retval [create_fragmented_index_list $total_width $group_width $words $width $offset $list_select]
  set retval [expand_fragmented_index_list $channels $total_width $retval]
  return $retval
}


proc ::alt_xcvr::ip_tcl::ip_interfaces::convert_list_to_map { index_list } {
  set map {}

  set upper_index [lindex $index_list 0]
  set lower_index $upper_index
  for {set x 1} {$x < [llength $index_list]} {incr x} {
    set item [lindex $index_list $x]
    set expect [expr $lower_index - 1]
    if {$item != $expect} {
      set str [expr {$upper_index == $lower_index ? $upper_index : "${upper_index}:${lower_index}" }]
      lappend map $str
      set upper_index $item
    }
    set lower_index $item
  }
  set str [expr {$upper_index == $lower_index ? $upper_index : "${upper_index}:${lower_index}" }]
  lappend map $str

  return $map
}

proc ::alt_xcvr::ip_tcl::ip_interfaces::partial_interface_message { if_pname pname total_width used_width used_map unused_map } {
  set message "$if_pname: For each ${total_width} bit word "
  # Used bits
  if {[llength $used_map] > 0} {
    set used_map [string map {" " ","} $used_map]
    set message "${message} the $used_width active data bits are ${pname}\[${used_map}\];" 
  }
  # Unused bits
  if {[llength $unused_map] > 0} {
    set unused_map [string map {" " ","} $unused_map]
    set message "${message} unused data bits are ${pname}\[${unused_map}\]."
  }
  ::alt_xcvr::ip_tcl::messages::ip_message info $message
}

proc ::alt_xcvr::ip_tcl::ip_interfaces::::create_fragmented_interface { condition pname src_port direction channels total_width group_width words width offset { used "used" } } {
    # Declare simplified data interface
    set used_list [create_fragmented_index_list $total_width $group_width $words $width $offset $used]
    if {$condition} {
      set used_list [expand_fragmented_index_list $channels $total_width $used_list]
      create_fragmented_conduit $pname [add_fragment_prefix $used_list $src_port] $direction $direction
    } else {
      partial_interface_message $pname $src_port $total_width [expr {$words * $width}] [convert_list_to_map $used_list] {}
    }
}

proc ::alt_xcvr::ip_tcl::ip_interfaces::::create_fragmented_conduit { pname fragment_list direction {ui_direction default} } {
  ::alt_xcvr::ip_tcl::ip_module::ip_add "interface.${pname}" conduit end
  ::alt_xcvr::ip_tcl::ip_module::ip_add "port.${pname}.${pname}" $pname
  ::alt_xcvr::ip_tcl::ip_module::ip_set "port.${pname}.direction" $direction
  ::alt_xcvr::ip_tcl::ip_module::ip_set "port.${pname}.width_expr" [llength $fragment_list]
  ::alt_xcvr::ip_tcl::ip_module::ip_set "port.${pname}.fragment_list" $fragment_list
  if {$ui_direction != "default" } {
    ::alt_xcvr::ip_tcl::ip_module::ip_set "interface.${pname}.assignment" [list "ui.blockdiagram.direction" $ui_direction]
  }
}



