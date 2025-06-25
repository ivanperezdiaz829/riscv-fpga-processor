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







package provide ::ddr::type 0.1
package require ::ddr::utils

namespace eval ::ddr::type {
namespace export check 

if { [package require ::ddr::utils] != "" }   { namespace import ::ddr::utils::*     }








#  * {enum ta tb tc...} - 'ta' or 'tb' or 'tc'
#  * {struct s1 t1 s2 t2...} - A list of alternating key and values (like you might get from [array get foo]) where s1 has type t1 etc
#  * {struct_partial s1 t1 s2 t2 } - As above, but there may be extra data items in the structure


#   proc myproc { option } {

#   }

proc check { type data  {pathname ""}} {
if { $type == "str" } {
return 
} elseif { $type == "int" } {
if { [catch { expr {$data + 0} } ] } { assert {0} {} "type error: $pathname=$data is not of type $type" }
return 
} elseif { [lindex $type 0] == "struct" || [lindex $type 0] == "struct_partial" } {
if { [lindex $type 0] == "struct_partial" } {
set allow_extras 1
} else {
set allow_extras 0
}

# in the array correctly. Set the types to "SEEN" when items are found.

assert { ! [array exists typearr] }
assert { ! [array exists typearr_seen] }
array set typearr [lrange $type 1 end] ;

foreach {k v} [array get typearr] {
set typearr_seen($k) 0
}
foreach {name d} $data {
if { ! [ info exists typearr($name) ] } {
if { ! $allow_extras } {
puts "TYPE WARNING: data contains item $pathname.$name=$d not in type description"
}
} else {
set dtype $typearr($name)
check $dtype $d "$pathname.$name"
incr typearr_seen($name)
}
}
foreach {k v } [array get typearr] {
if { $typearr_seen($k) == 1  } {

} else {
assert {0} {} "TYPE ERROR: $pathname.$k found $typearr_seen($k) times" 
}
}
array unset typearr
} elseif { [lindex $type 0] == "enum" } {

set typeok 0
foreach item [lrange $type 1 end  ] {
if { $item == $data } {
set typeok 1
break
}
}
assert { $typeok } {$type $data} "data not one of items in enum"
} else {
error "bad type description : '$type'"
}
}

}
