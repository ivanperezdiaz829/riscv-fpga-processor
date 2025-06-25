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


namespace eval altera_tc_lib {

    namespace export decode_tristate_conduit_masters

    proc decode_tristate_conduit_masters { param } {

	regsub -all {\"} ${param} {'} param
	regsub -all {<\?xml[^?]+\?>} $param {} param
	regsub -all {</?info>} $param {} param

	regsub -all {(<slave[^/>]*)/>} $param {\1></slave>} param
	regsub -all {<slave name='([^']*)' *>} $param {\1|} param
	regsub -all {</slave>$} $param {} param
	regsub -all {</slave>} $param {|} param

	set slave_list [split $param "|" ]
	set num_slaves_x2 [ llength $slave_list ]

	set result [list]

	for { set i 0 } { $i < $num_slaves_x2 } { incr i } {
	    set slave_name [ lindex $slave_list $i ]
	    incr i
	    set slave [ lindex $slave_list $i ]

	    set slave_info [list]

	    regsub {<master ([^/>]+)/>} $slave {<master \1></master>} slave

	    regsub -all {<master name='([^']*)' *>} $slave {\1|} slave
	    regsub -all {</master>$} $slave {} slave
	    regsub -all {</master>} $slave {|} slave

	    set master_list [split $slave "|" ]
	    set num_masters_x2 [ llength $master_list ]

	    for { set j 0 } { $j < $num_masters_x2 } { incr j } {
		set master_name [ lindex $master_list $j ]
		incr j
		set master [ lindex $master_list $j ]

		set master_info [list]

		regsub -all {<pin ([^/>]+)/>} $master {\1|} master
		regsub      {\|$} $master {} master

		set port_list [split $master "|" ]
		set num_ports [ llength $port_list ]

		for { set k 0 } { $k < $num_ports } { incr k } {
		    set port [ lindex $port_list $k ]

		    regsub -all { *([a-z]+)='([^']*)' *} $port {\1|\2|} port
		    regsub -all {\|$} $port {} port

		    set attrib_list [split $port "|" ]
		    array set attrib_array ${attrib_list}

		    set role $attrib_array(role)
		    array unset attrib_array role

		    lappend master_info ${role} [array get attrib_array]

		}

		lappend slave_info $master_name
		lappend slave_info $master_info
	    }

	    lappend result $slave_name
	    lappend result $slave_info
	}

	return $result
    }
    namespace export iterate_through

### Iterate through an arbitrary set of lists with equal length ###

    proc iterate_through { list_variables
			   action
			   { includes {} }
			 } {

	handle_includes ${includes}

	eval "foreach $list_variables\
	    {\
		eval { ${action} } \
	    }\
        "
    }

    namespace export iterate_through_listinfo 

### Given a set of lists, iterate the index of each list and perform an action of some type. ###

    proc iterate_through_listinfo {
				 module_origin_list
				 signal_origin_list
				 signal_origin_type
				 signal_origin_width
				 signal_out_names
				 signal_in_names
				 signal_outen_names
				 shared_signal_names
				 action
				 { includes {} }
			     } {

	handle_includes ${includes}

	foreach master_path        ${module_origin_list} \
	        role               ${signal_origin_list} \
	        width              ${signal_origin_width} \
	        type               ${signal_origin_type} \
	        output_name        ${signal_out_names} \
	        input_name         ${signal_in_names} \
	        output_enable_name ${signal_outen_names} \
	        shared_name        ${shared_signal_names} \
	    {
		#Decode master path into master module and interface name
		if { [regexp {(.*)\.(.*)} $master_path junk master_module_name master_interface_name] } {
		    regsub -all -- {\.\./} ${master_module_name} "_" master_module_name
		    eval ${action}
		}
	    }
    }

### Given a set of lists and a shared signal list, iterate the index of each list and divide
### the lists into mutually exclusive shared and unshared lists.
    
    namespace export segregate_shared_from_unshared

    proc segregate_shared_from_unshared {
					 module_origin_list
					 signal_origin_list
					 signal_origin_type
					 signal_origin_width
					 signal_out_names
					 signal_in_names
					 signal_outen_names
					 shared_signal_list
					 slave_interface_names
				     } {
	set unshared_module_origin_list ""
	set unshared_signal_origin_list ""
	set unshared_signal_origin_type ""
	set unshared_signal_origin_width ""
	set unshared_signal_output_names ""
	set unshared_signal_input_names ""
	set unshared_signal_output_enable_names ""
	set unshared_signal_slave_interface_names ""
	set shared_module_origin_list ""
	set shared_signal_origin_list ""
	set shared_signal_origin_type ""
	set shared_signal_origin_width ""
	set shared_signal_output_names ""
	set shared_signal_input_names ""
	set shared_signal_output_enable_names ""
	set shared_signal_names ""
	set shared_signal_slave_interface_names ""

	foreach module               ${module_origin_list} \
	        signal               ${signal_origin_list} \
	        type                 ${signal_origin_type} \
	        width                ${signal_origin_width} \
	        output_name          ${signal_out_names} \
	        input_name           ${signal_in_names} \
	        output_enable_name   ${signal_outen_names} \
	        shared               ${shared_signal_list} \
	        slave_interface_name ${slave_interface_names}\
	    {
		if { [string equal $shared ""] } {
		    lappend unshared_module_origin_list           ${module}
		    lappend unshared_signal_origin_list           ${signal}
		    lappend unshared_signal_origin_type           ${type}
		    lappend unshared_signal_origin_width          ${width}
		    lappend unshared_signal_output_names          ${output_name}
		    lappend unshared_signal_input_names           ${input_name}
		    lappend unshared_signal_output_enable_names   ${output_enable_name}
		    lappend unshared_signal_slave_interface_names ${slave_interface_name}
		} else {
		    lappend shared_module_origin_list           ${module}
		    lappend shared_signal_origin_list           ${signal}
		    lappend shared_signal_origin_type           ${type}
		    lappend shared_signal_origin_width          ${width}
		    lappend shared_signal_output_names          ${output_name}
		    lappend shared_signal_input_names           ${input_name}
		    lappend shared_signal_output_enable_names   ${output_enable_name}
		    lappend shared_signal_names                 ${shared}
		    lappend shared_signal_slave_interface_names ${slave_interface_name}
		}
	    }

	validate_sharing ${shared_module_origin_list} ${shared_signal_origin_type} ${shared_signal_names}

	set returned_array(unshared_module_origin_list) ${unshared_module_origin_list}
	set returned_array(unshared_signal_origin_list) ${unshared_signal_origin_list}
	set returned_array(unshared_signal_origin_type) ${unshared_signal_origin_type}
	set returned_array(unshared_signal_origin_width) ${unshared_signal_origin_width}
	set returned_array(unshared_signal_output_names) ${unshared_signal_output_names}
	set returned_array(unshared_signal_input_names) ${unshared_signal_input_names}
	set returned_array(unshared_signal_output_enable_names) ${unshared_signal_output_enable_names}
	set returned_array(unshared_signal_slave_interface_names) ${unshared_signal_slave_interface_names}
	set returned_array(shared_module_origin_list) ${shared_module_origin_list}
	set returned_array(shared_signal_origin_list) ${shared_signal_origin_list}
	set returned_array(shared_signal_origin_type) ${shared_signal_origin_type}
	set returned_array(shared_signal_origin_width) ${shared_signal_origin_width}
	set returned_array(shared_signal_output_names) ${shared_signal_output_names}
	set returned_array(shared_signal_input_names) ${shared_signal_input_names}
	set returned_array(shared_signal_output_enable_names) ${shared_signal_output_enable_names}
	set returned_array(shared_signal_names) ${shared_signal_names}
	set returned_array(shared_signal_slave_interface_names) ${shared_signal_slave_interface_names}

	return [array get returned_array]
    }

    namespace export create_derived_lists

### Given a parsed system info string, convert the data structure from a hash to a series of lists. ###

    proc create_derived_lists { sys_info {hierarchy_level 0} } {
	set slave_interface_list ""
	set module_origin_list ""
	set signal_origin_list ""
	set signal_origin_type ""
	set signal_origin_width ""
	set signal_output_names ""
	set signal_input_names ""
	set signal_output_enable_names ""

	set output_action {
	    uplevel 2 lappend signal_output_names ${output_name}
	    uplevel 2 lappend signal_input_names {{}}
	    uplevel 2 lappend signal_output_enable_names {{}}
	}
	set input_action {
	    uplevel 2 lappend signal_output_names {{}}
	    uplevel 2 lappend signal_input_names ${input_name}
	    uplevel 2 lappend signal_output_enable_names {{}}
	}
	set bidir_action {
	    uplevel 2 lappend signal_output_names ${output_name}
	    uplevel 2 lappend signal_input_names ${input_name}
	    uplevel 2 lappend signal_output_enable_names ${output_enable_name}
	}
	set tristatable_action {
	    uplevel 2 lappend signal_output_names ${output_name}
	    uplevel 2 lappend signal_input_names {{}}
	    uplevel 2 lappend signal_output_enable_names ${output_enable_name}
	}
	set includes {
	    output_action
	    input_action
	    bidir_action
	    tristatable_action
	}

	iterate_through_sysinfo ${sys_info} {} {} \
	    {
		uplevel lappend module_origin_list ${master_path}
		uplevel lappend signal_origin_list ${role}
		uplevel lappend signal_origin_type ${type}
		uplevel lappend signal_origin_width ${width}
		uplevel lappend slave_interface_list ${slave_interface_name}
		set ta_includes {input_name output_name output_enable_name slave_interface_name}
		type_action $type ${output_action} ${input_action} ${bidir_action} ${tristatable_action} $ta_includes
	    } $includes ${hierarchy_level}

	set returned_array(module_origin_list) ${module_origin_list}
	set returned_array(signal_origin_list) ${signal_origin_list}
	set returned_array(signal_origin_type) ${signal_origin_type}
	set returned_array(signal_origin_width) ${signal_origin_width}
	set returned_array(signal_output_names) ${signal_output_names}
	set returned_array(signal_input_names) ${signal_input_names}
	set returned_array(signal_output_enable_names) ${signal_output_enable_names}
	set returned_array(slave_interface_list) ${slave_interface_list}
	return [array get returned_array]
    }

    namespace export iterate_through_sysinfo

### Given a TRISTATECONDUIT_INFO sysinfo string, traverse the array and perform given actions on each level.
### Variables available at level 1
###   slave_interface_name
### 
### Variables available at level 2
###   slave_interface_name
###   master_path
###   master_module_name
###   master_interface_name
###
### Variables available at level 3
###   slave_interface_name
###   master_path
###   master_module_name
###   master_interface_name
###   role
###   type   ( One of Output, Input, Bidirectional, Tristatable_Output )
###   width
###   output_name
###   input_name
###   output_enable_name

    proc iterate_through_sysinfo {
				  sys_info
				  level_1_action
				  level_2_action
				  level_3_action
				  { includes {} }
				  { hierarchy_level 0 }
			      } {

	handle_includes ${includes}

	#clear array
	if { [array exists slave_list] } { array unset slave_list }

	array set slave_list $sys_info

	foreach slave_interface_name [array names slave_list] {
	    #clear array
	    if { [array exists master_list] } { array unset master_list }

	    array set master_list $slave_list($slave_interface_name)

	    eval ${level_1_action}
	    
	    foreach master_path [array names master_list] {
		#clear array
		if { [array exists pin_list] } { array unset pin_list }

		array set pin_list $master_list($master_path)

		#Decode master path into master module and interface name
		regexp {(.*)\.(.*)} $master_path junk master_module_name master_interface_name

                #replace ../ with _ as required and take hierarcical cancel into account
		regsub -all -- {\.\./} ${master_module_name} "_" master_module_name
		regsub -all -- {\.\./} ${master_path}        "_" master_path

		for { set ii ${hierarchy_level} } { $ii > 0 } { set ii [expr $ii - 1] } {
		    regsub -- {^_} ${master_module_name} "" master_module_name
		    regsub -- {^_} ${master_path}        "" master_path
		} 

		eval ${level_2_action}

		foreach role [array names pin_list] {

		    if { ![string equal $role ""] } {
			#clear array
			if { [array exists pin_info] } { array unset pin_info }

			array set pin_info $pin_list($role)

			foreach var [array names pin_info] {

			    # This loop will set variables 
			    #  type ( Input, Output, Tristatable_Output, Bidirectional,) 
			    #  width
			    #  output_name
			    #  input_name
			    #  output_enable_name

			    set ${var} $pin_info($var)
			}

			eval ${level_3_action}
		    }
		}
	    }
	}	
    }

    namespace export validate_sharing

    proc validate_sharing {
			   shared_module_origin_list
			   shared_signal_origin_type
			   shared_signal_names
		       } {
	set thrown_error ""
	for { set i 0 } { $i < [llength $shared_signal_names] } { incr i } {
	    set module [lindex $shared_module_origin_list $i]
	    set type [lindex $shared_signal_origin_type $i]
	    set shared [lindex $shared_signal_names $i]
	    for { set j [expr $i + 1] } { $j < [llength $shared_signal_names] } { incr j } {
		set module2 [lindex $shared_module_origin_list $j]
		set type2 [lindex $shared_signal_origin_type $j]
		set shared2 [lindex $shared_signal_names $j]
		if { [string equal ${shared} ${shared2}] && [lsearch $thrown_error $shared] == -1 } {
		    if { ![string equal ${type} ${type2}] } {
			send_message error "Sharing error: $shared cannot share pins which have different pin types"
			lappend thrown_error $shared
		    }
		    if { [string equal ${module} ${module2}] } {
			send_message error "Sharing error: $shared cannot share pins which exist on the same module"
			lappend thrown_error $shared
		    }
		}
	    }
	}
    }

    namespace export type_action

### Given a pin type, perform given actions based on that pin type. ###

    proc type_action { 
		      pin_type
		      output_action
		      input_action
		      bidir_action
		      tristatable_action
		      { includes {} }
		      { init_action {} }
		  } {

	handle_includes ${includes}

	eval ${init_action}

	switch ${pin_type} {
	    "" { }
	    Output {
		eval ${output_action}
	    }
	    Input {
		eval ${input_action}
	    }
	    Bidirectional {
		eval ${bidir_action}
	    }
	    Tristatable_Output {
		eval ${tristatable_action}
	    }
	    default {
		send_message debug "Invalid pin type : ${pin_type}"
		send_message debug "  Output Action: ${output_action}"
		send_message debug "  Input Aciton: ${input_action}"
		send_message debug "  Bidir Action: ${bidir_action}"
		send_message debug "  Tri Action: ${tristatable_action}"
		send_message debug "  Includes: ${includes}"
		send_message debug "  Init: ${init_action}"
	    }
	}
    }

### Given a list of variables, connect each variable to its matching partner in the above scope. ###

    proc handle_includes { includes } {
	foreach include ${includes} {
	    uplevel upvar ${include} ${include}
	}
    }
}
