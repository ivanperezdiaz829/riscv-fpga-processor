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


proc get_peripheral_location {part atom peripheral_index} {
    load_package advanced_device

    load_device -part $part
    load_die_info

    set gids [get_sorted_gids $atom]
    set gid  [lindex $gids $peripheral_index]
    set location [get_die_data -gid $gid STRING_LOCATION]
    return $location
}

proc get_sorted_gids {atom} {
    set gids [get_die_gids -element $atom]
    if {[llength $gids] > 1} {
	set ic_design_names [list]
	foreach gid $gids {
	    set ic_design_name [get_die_data -gid $gid STRING_IC_DESIGN_NAME]
	    lappend ic_design_names $ic_design_name
	}
	
	set sorted_indices [lsort -ascii -indices $ic_design_names]
	set sorted_gids [list]
	foreach index $sorted_indices {
	    lappend sorted_gids [lindex $gids $index]
	}
    } else {
	set sorted_gids $gids
    }
    return $sorted_gids
}
