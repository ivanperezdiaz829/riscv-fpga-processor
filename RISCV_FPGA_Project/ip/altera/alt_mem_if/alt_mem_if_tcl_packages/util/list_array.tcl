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


package provide alt_mem_if::util::list_array 0.1

package require alt_mem_if::util::messaging

namespace eval ::alt_mem_if::util::list_array:: {
	namespace export normalize_list
	namespace export safe_array_val
	namespace export update_or_append
	

	namespace import ::alt_mem_if::util::messaging::*
	
}


proc ::alt_mem_if::util::list_array::array_clean {inarr_name} {
	upvar 1 $inarr_name inarr
	
	array set inarr {}
	if {[llength [array names inarr]] > 0} {
		array unset inarr
	}
	
	return 1
}

proc ::alt_mem_if::util::list_array::lshift {listref} {
   
   upvar 1 $listref inputlist

   set shift_val  [lindex $inputlist 0]
   set inputlist [lreplace $inputlist[set inputlist {}] 0 0]
   return $shift_val
}


proc ::alt_mem_if::util::list_array::format_brace_string {input_string} {
	set return_string $input_string
	
	regsub {^\s*\{} $return_string "" return_string
	regsub {\}\s*$} $return_string "" return_string
	
	return $return_string
}


proc ::alt_mem_if::util::list_array::isnumber {v} {
    if {[regexp {^\s*[0-9]+\.?[0-9]*\s*$} $v match] == 1} {
		return 1
	} else {
		return 0
	}
}


proc ::alt_mem_if::util::list_array::normalize_list {input_list} {
	array set norm_list {}
	
	foreach item $input_list {
		if {[regexp {^\s*$} $item] == 0} {
			set norm_list($item) 1
		}
	}
	return [array names norm_list]
}

proc ::alt_mem_if::util::list_array::safe_array_val {inarr_name inkey} {
	upvar 1 $inarr_name inarr
	
	if {[info exists inarr($inkey)] == 0} {
		_eprint "Key $inkey does not exist in array"
		_eprint "Valid array keys are [array names inarr]"
		_error "Internal Error: Key $inkey does not exist in array $inarr_name!"
		return 0
	} else {
		return $inarr($inkey)
	}
}

proc ::alt_mem_if::util::list_array::update_or_append {inlist kvp} {
	upvar 1 $inlist list

	set kvp_list [split $kvp "="]
	set name [lindex $kvp_list 0]
	set val [lindex $kvp_list 1]

	set idx [lsearch -glob $list "${name}=*"]
	if { $idx >= 0 } {
		set list [lreplace $list $idx $idx $kvp]
	} else {
		lappend list $kvp
	}
}

proc ::alt_mem_if::util::list_array::intersect3 {list1 list2 inList1 inList2 inBoth} {

     upvar $inList1 in1
     upvar $inList2 in2
     upvar $inBoth  inB

     set in1 [list]
     set in2 [list]
     set inB [list]

     set list1 [lsort $list1]
     set list2 [lsort $list2]

     if { $list1 == $list2 } {
         set inB $list1
     } else {
         set i 0
         foreach element $list1 {
             if {[set p [lsearch [lrange $list2 $i end] $element]] == -1} {
                 lappend in1 $element
             } else {
                 if { $p > 0 } {
                     set e [expr {$i + $p -1}]
                     foreach entry [lrange $list2 $i $e] {
                         lappend in2 $entry
                     }
                     incr i $p
                 }
                 incr i
                 lappend inB $element
             }
         }
         foreach entry [lrange $list2 $i end] {
             lappend in2 $entry
         }
     }
 } ;