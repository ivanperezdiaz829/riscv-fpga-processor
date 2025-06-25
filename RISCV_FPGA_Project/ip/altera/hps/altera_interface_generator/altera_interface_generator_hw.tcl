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


package require -exact qsys 12.0
package require -exact altera_terp 1.0

source ../util/constants.tcl
source ../util/procedures.tcl
source [file join $env(QUARTUS_ROOTDIR) .. ip altera hps util isw.tcl]

set_module_property NAME altera_interface_generator
set_module_property VERSION 13.1
set_module_property internal true
set_module_property analyze_hdl true
set_module_property elaboration_callback elaborate
set_module_property SUPPRESS_WARNINGS NO_PORTS_AFTER_ELABORATION

add_fileset synth quartus_synth synth
add_fileset verilog_sim sim_verilog sim
add_fileset vhdl_sim sim_vhdl sim

#~~~~~~~~~~~~~~~~~~~~~ START OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
source "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_interfaces/alt_mem_if_hps_emif/common_hps_emif.tcl"
#~~~~~~~~~~~~~~~~~~~~~ END OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

add_parameter interfaceDefinition string "interfaces {[ORDERED_NAMES] {}}"
set_parameter_property interfaceDefinition affects_elaboration true
set_parameter_property interfaceDefinition affects_generation true

add_parameter qipEntries string ""
set_parameter_property qipEntries affects_elaboration true
set_parameter_property qipEntries affects_generation true

add_parameter ignoreSimulation boolean false
set_parameter_property ignoreSimulation affects_elaboration false
set_parameter_property ignoreSimulation affects_generation true

add_parameter          hps_parameter_map string ""
set_parameter_property hps_parameter_map affects_elaboration false
set_parameter_property hps_parameter_map affects_generation  true

add_parameter	        device string "" ""
set_parameter_property 	device system_info_type DEVICE
set_parameter_property	device visible false

## -Presents a "foreach {key value} array_string body"
##  where value is an actual array instead of a string
## -Useful when navigating nested arrays
#proc array_foreach {iter data body} {
#    set key_name [lindex $iter 0]
#    set val_name [lindex $iter 1]
#    upvar 1 $key_name key
#    upvar 1 $val_name val
#    foreach inner_key inner_val $data {
#	set key $inner_key
#	clear_array val
#	array set val $inner_val
#	uplevel 1 eval $body
#    }
#}

# -Parameters: iter       - iter[0] is the declared key variable name
#                           iter[1] is the declared value array name
#              array_name - an array name
#              body       - body of code to execute
# -Allows navigation of nested arrays where the iteration is ordered
proc inorder_foreach_array {iter array_string body} {
    set key_name [lindex $iter 0]
    set val_name [lindex $iter 1]
    upvar 1 $key_name key
    upvar 1 $val_name val
    array set data $array_string
    foreach inner_key $data([ORDERED_NAMES]) {
	set key $inner_key
	clear_array val
	array set val $data($inner_key)
	uplevel 1 $body
    }
}

proc elaborate {} {
    array set data [get_parameter_value interfaceDefinition]
    array set interfaces $data(interfaces)
    
    foreach interface_name $interfaces([ORDERED_NAMES]) {
	clear_array interface
	array set interface $interfaces($interface_name)
	
	#Skip if this is an HDL only interface
	if { [info exists interface([HDL_ONLY])] == 0 } {
	    add_interface $interface_name $interface(type) $interface(direction)
	    clear_array properties
	    array set properties $interface(properties)
	    foreach property [array names properties] {
		set_interface_property $interface_name $property $properties($property)
	    }
	    
	    clear_array signals
	    array set signals $interface(signals)
	    foreach signal_name $signals([ORDERED_NAMES]) {
		clear_array signal
		array set signal $signals($signal_name)
		
		set direction $signal(direction)
		if {[string equal $direction "inout"]} {
		    set direction "bidir"
		}
		add_interface_port $interface_name $signal_name $signal(role) $direction $signal(width)
		
		#Process signal properties
		clear_array signal_properties
		array set signal_properties $signal(properties)
		foreach signal_property [array names signal_properties] {
		    set_port_property ${signal_name} ${signal_property} $signal_properties(${signal_property})
		}
	    }
	}
    }

    set qip [get_qip_strings]
    array set instances $data(instances)
    foreach instance_name $instances([ORDERED_NAMES]) {
	array set instance $instances($instance_name)
	set location $instance(location)
	if {$location != ""} {
	    lappend qip "set_instance_assignment -name HPS_LOCATION ${location} -entity %entityName% -to ${instance_name}"
	}
    }

    #handle qip entries
    foreach explicit_qip_entry [get_parameter_value qipEntries] {
	lappend qip $explicit_qip_entry
    }
    set_qip_strings $qip
	
#    #~~~~~~~~~~~~~~~~~~~~~ START OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    if {! [::alt_mem_if::util::qini::cfg_is_on hps_ip_suppress_sdram_synth]} {
#	validate_emif_component
#	define_memory_conduit [get_parameter_value HPS_PROTOCOL]
#    }
#    #~~~~~~~~~~~~~~~~~~~~~ END OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
}

proc get_instances_port_depends_on {port_ref} {
    upvar 1 $port_ref port
    
    set instances [list]
    if {[llength $port(fragments)] > 0} {
	foreach fragment $port(fragments) {
	    if {![is_fragment_wire $fragment] && ![is_fragment_literal $fragment]} {
		set instance [lindex [fragment_to_pieces $fragment] 0]
		lappend instances $instance
	    }
	}
	
    } elseif {$port(instance_name) != ""} {
	lappend instances $port(instance_name)
    }
    return $instances
}

proc filter_synthesis_style_simulation_data {data_ref synth_data_ref} {
    upvar 1 $data_ref                  data
    upvar 1 $synth_data_ref synth_data

    array set data_interfaces $data(interfaces)
    set interfaces([ORDERED_NAMES]) [list]
    funset filtered_instances
    foreach {interface_name style} $data(interface_sim_style) {
	if {[string compare $style "SYNTHESIS"] == 0} {
	    set interface_details $data_interfaces($interface_name)
	    set interfaces($interface_name) $interface_details
	    lappend interfaces([ORDERED_NAMES]) $interface_name
	    
	    # get port instance names
	    array set interface $interface_details
	    array set signals   $interface(signals)
	    foreach port_name $signals([ORDERED_NAMES]) {
		array set port $signals($port_name)
		foreach instance_name [get_instances_port_depends_on port] {
		    set filtered_instances($instance_name) 1
		}
	    }
	}
    }
    set synth_data(interfaces) [array get interfaces]
    
    funset instances
    set instances([ORDERED_NAMES]) [list]
    array set data_instances $data(instances)
    foreach instance_name [array names filtered_instances] {
	set instances($instance_name) $data_instances($instance_name)
	lappend instances([ORDERED_NAMES]) $instance_name
    }
    set synth_data(instances) [array get instances]

    # wires
    set wire_count 0
    if {[llength $data(wire_sim_style)] > 0} {
	set wire_count $data(intermediate_wire_count)
    }
    set synth_data(intermediate_wire_count) $wire_count
    array set data_wires_to_fragments $data(wires_to_fragments)
    funset wires_to_fragments
    foreach {wire style} $data(wire_sim_style) {
	if {[string compare $style "SYNTHESIS"] == 0} {
	    if {[info exists data_wires_to_fragments($wire)]} {
		set wires_to_fragments($wire) $data_wires_to_fragments($wire)
	    }
	}
    }
    set synth_data(wires_to_fragments) [array get wires_to_fragments]

    # assigns
    set synth_data(raw_assigns) [list]
    foreach {raw_assign style} $data(raw_assign_sim_style) {
	if {[string compare $style "SYNTHESIS"] == 0} {
	    lappend synth_data(raw_assigns) $raw_assign
	}
    }
}

proc warn_about_unsupported_styles {data_ref} {
    upvar 1 $data_ref data
    foreach construct {"wire" "raw_assign" "interface"} {
	set key "${construct}_sim_style"
	foreach {item style} $data($key) {
	    if {$style != "SYNTHESIS"} {
		send_message warning "Ignoring $construct construct $item with unsupported simulation rendering style $style."
	    }
	}
    }
}

proc sim { outputName } {

#~~~~~~~~~~~~~~~~~~~~~ START OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    array set data [get_parameter_value interfaceDefinition]
    array set properties $data(properties)
    
    if {[info exists properties(IMPLEMENT_F2SDRAM_MEMORY_BACKED_SIM)] && !$properties(IMPLEMENT_F2SDRAM_MEMORY_BACKED_SIM)} {
	generate_hps_emif_component "hps" SIM_VERILOG
    }
#~~~~~~~~~~~~~~~~~~~~~ END OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	
    clear_array data
    array set data [get_parameter_value interfaceDefinition]
    
    set nonstandard_style_exists 0
    if {[llength $data(wire_sim_style)]
	|| [llength $data(raw_assign_sim_style)]
	|| [llength $data(interface_sim_style)] } {
	set nonstandard_style_exists 1
    }

    set params(interfaceSimulationOverridesStr) {}

    if {$nonstandard_style_exists} {
	warn_about_unsupported_styles data
	
	funset synth_data
	filter_synthesis_style_simulation_data data synth_data
	funset synth_terp_params
	process_synthesis_mapping synth_data synth_terp_params
	set synth_terp_params(interfacePeripheralList) [array get synth_data]
	set synth_terp_file [open altera_interface_generator.sv.terp]
	set synth_terp      [read $synth_terp_file]
	close $synth_terp_file
	set synth_terp_params(skip_rendering) {module 1 endmodule 1}
	set params(rawRtl) [altera_terp $synth_terp synth_terp_params] ;# output of synth terp
	set params(interfaceSimulationOverridesStr) $data(interface_sim_style)
    }

    add_files_to_simulation_fileset $data(interfaces)
    
    create_conduit_bfms $data(interfaces) $outputName
    
    # terp the simulation wrapper file
    set templateFile [ read [ open altera_sim_interface_generator.sv.terp ] ]
    
    set params(interfacePeripheralList) [array get data]
    set params(output_name) ${outputName}
    
    do_terp $templateFile params
}

proc compare_ranges {a b} {
    set colon [string first ":" $a]
    set a_num [string range $a 0 [expr $colon - 1]]
    set colon [string first ":" $b]
    set b_num [string range $b 0 [expr $colon - 1]]
    
    set result 1
    if {$a_num < $b_num} {
	set result -1
    } elseif {$a_num == $b_num} {
	set result 0
    }
    return $result
}

# increments $starting_index by width of range
proc create_indexed_signal {signal range starting_index_var} {
    upvar 1 $starting_index_var starting_index

    set range_parts [split $range ":"]
    set hi [lindex $range_parts 0]
    set lo [lindex $range_parts 1]
    set delta [expr {$hi - $lo}]
    set width [expr {$delta + 1}]
    
    set adjusted_range "[expr {$starting_index + $delta}]:$starting_index"
    set result "${signal}\[${adjusted_range}\]"
    
    incr starting_index $width
    return $result
}

proc range_to_width {range} {
    set parts [split $range ":"]
    set hi    [lindex $parts 0]
    set lo    [lindex $parts 1]
    return [expr $hi - $lo + 1]
}

proc verilog_constant {default_term filler_width} {
    set bit_char "0"
    if {$default_term} {
	set bit_char "1"
    }
    
    set bitstring [string repeat $bit_char $filler_width]
    set result "${filler_width}'b${bitstring}"
    
    return $result
}

proc verilog_constant_from_decimal {value width} {
    set bitstring ""
    for {set i 0} {$i < $width} {incr i} {
	set bit [expr {$value & 1}]
	set bitstring "${bit}${bitstring}"
	set value [expr {$value >> 1}]
    }
    
    set result "${width}'b${bitstring}"
    return $result
}

proc is_fragment_literal {frag} {
    return [expr {[string compare $frag "0"] == 0 ||
		  [string compare $frag "1"] == 0}]
}

proc is_fragment_wire {frag} {
    return [expr {[llength $frag] > 0 &&
		  [string compare [string index $frag 0] "@"] == 0}]
}

proc fragment_to_pieces {frag} {
    set colon [string first ":" $frag]
    set inst  [string range $frag 0 [expr $colon - 1]]
    
    set left_paren [string last "(" $frag]
    set port       [string range $frag [expr $colon + 1] [expr $left_paren - 1]]
    
    set right_paren [string last ")" $frag]
    set range       [string range $frag [expr $left_paren + 1] [expr $right_paren - 1]]
    return [list $inst $port $range]
}

proc wire_fragment_to_pieces {frag} {
    set frag [string trimleft $frag "@"]

    set left_paren [string last "(" $frag]
    set wire       [string range $frag 0 [expr {$left_paren - 1}]]
    
    set right_paren [string last ")" $frag]
    set range       [string range $frag [expr {$left_paren + 1}] [expr {$right_paren - 1}]]
    return [list $wire $range]
}

# use fragment_to_pieces?
proc get_fragment_width {fragment} {
    set result 1
    set left_paren [string first "(" $fragment]
    if {$left_paren != -1} {
	set right_paren [string first ")" $fragment]
	if {$right_paren > $left_paren} {
	    set range       [string range $fragment [expr $left_paren + 1] [expr $right_paren - 1]]
	    set result [range_to_width $range]
	}
    }
    return $result
}

proc process_synthesis_mapping {definition_ref mapped_ref} {
    upvar 1 $definition_ref definition
    upvar 1 $mapped_ref     mapped
    
    set exported_signal_literal_assignments [list]
    set tristate_output_assignments [list]
    set fragment_lists [list]
    set raw_assigns $definition(raw_assigns)

    inorder_foreach_array {interface_name interface} $definition(interfaces) {
	inorder_foreach_array {signal_name signal} $interface(signals) {
	    set direction $signal(direction)
	    set fragments $signal(fragments)
	    # backward compatibility with instance/internal name
	    if {[llength $fragments] == 0} {
		set frag_inst   $signal(instance_name)
		set frag_signal $signal(internal_name)
		set frag_range  "[expr ${signal(width)} - 1]:0"
		set fragments "${frag_inst}:${frag_signal}($frag_range)"
	    }

	    # break list of fragments for each qsys signal into individual fragment to signal relationships
	    # reverse iterate so qsys signal index can be counted
	    set current_signal_index 0
	    foreach {frag} [lreverse $fragments] {
		set frag_width [get_fragment_width $frag]
		lappend fragment_lists [list $signal_name $current_signal_index $direction $frag]
		incr current_signal_index $frag_width
	    }

	    # tristate output
	    if {[info exists signal(tristate_output)]} {
		set tristate_output $signal(tristate_output)
		lappend tristate_output_assignments $signal_name $tristate_output
	    }
	}
    }
    
    # map each wire to its fragment
    foreach {wire_name_index raw_fragment_list} $definition(wires_to_fragments) {
	set direction [lindex $raw_fragment_list 0]
	set frags     [lindex $raw_fragment_list 1]
	
	lassign $wire_name_index wire_name high low
	if {[llength $wire_name_index] < 3} {
	    set low $high
	}
	set current_signal_index $low
	foreach {frag} [lreverse $frags] {
	    set frag_width [get_fragment_width $frag]
	    lappend fragment_lists [list $wire_name $current_signal_index $direction $frag]
	    incr current_signal_index $frag_width
	}
    }

    # process the fragment/signal relationship into the fragment's perspective
    foreach fragment_list $fragment_lists {
	lassign $fragment_list signal_name starting_index direction frag
	set current_signal_index 0
	
	if {[is_fragment_literal $frag]} {
	    if {[string compare -nocase $direction "output"] == 0} {
		set fragment_partner [create_indexed_signal $signal_name "0:0" starting_index]
		lappend exported_signal_literal_assignments $fragment_partner [verilog_constant $frag 1]
	    }
	} elseif {[is_fragment_wire $frag]} {
	    lassign [wire_fragment_to_pieces $frag] wire_name wire_range
	    set fragment_partner [create_indexed_signal $signal_name $wire_range starting_index]
	    
	    if {[string compare -nocase $direction "output"] == 0} {
		lappend wires_driving_module_ports($wire_name)        $fragment_partner
		lappend wires_driving_module_ports_ranges($wire_name) $wire_range
	    } else {
		lappend wires_driven_by_module_ports($wire_name)        $fragment_partner
		lappend wires_driven_by_module_ports_ranges($wire_name) $wire_range
	    }
	} else {
	    # add instance
	    set frag_pieces [fragment_to_pieces $frag]
	    set frag_inst   [lindex $frag_pieces 0]
	    set frag_signal [lindex $frag_pieces 1]
	    set frag_range  [lindex $frag_pieces 2]
		
	    if {[info exists instance_to_ports($frag_inst)] == 0} {
		set instance_to_ports($frag_inst) {}
	    }
	    clear_array instance_ports
	    array set instance_ports $instance_to_ports($frag_inst)
	    set instance_ports($frag_signal) 1
	    set instance_to_ports($frag_inst) [array get instance_ports]
	    
	    set instance_port_key ${frag_inst}.${frag_signal}
	    if {[info exists instance_port_to_fragpartner_names($instance_port_key)] == 0} {
		set instance_port_to_fragpartner_names($instance_port_key)  [list]
		set instance_port_to_fragpartner_ranges($instance_port_key) [list]
	    }
	    set fragment_partner [create_indexed_signal $signal_name $frag_range starting_index]
	    lappend instance_port_to_fragpartner_names($instance_port_key)  $fragment_partner
	    lappend instance_port_to_fragpartner_ranges($instance_port_key) $frag_range
	    
	    set rtl_signal_dir($instance_port_key) $direction
	}
    }
    
    # TODO: make sure we don't process these for outputs!!!
    inorder_foreach_array {instance_name instance} $definition(instances) {
	foreach {signal_name width} $instance(signal_widths) {
	    set instance_port_key ${instance_name}.${signal_name}
	    set instance_port_width($instance_port_key) $width
	}
	foreach {signal_name default_term} $instance(signal_default_terminations) {
	    set instance_port_key ${instance_name}.${signal_name}
	    set instance_port_default_term($instance_port_key) $default_term
	}
	foreach {signal_name terminations} $instance(signal_terminations) {
	    foreach {range value} $terminations {
		set width [range_to_width $range]
		set literal [verilog_constant_from_decimal $value $width]

		set instance_port_key ${instance_name}.${signal_name}
		if {[info exists instance_port_to_fragpartner_names($instance_port_key)] == 0} {
		    set instance_port_to_fragpartner_names($instance_port_key)  [list]
		    set instance_port_to_fragpartner_ranges($instance_port_key) [list]
		}
		lappend instance_port_to_fragpartner_names($instance_port_key)  $literal
		lappend instance_port_to_fragpartner_ranges($instance_port_key) $range

		if {[info exists instance_to_ports($instance_name)] == 0} {
		    set instance_to_ports($instance_name) {}
		}
		clear_array instance_ports
		array set instance_ports $instance_to_ports($instance_name)
		set instance_ports($signal_name) 1
		set instance_to_ports($instance_name) [array get instance_ports]
		
		set rtl_signal_dir($instance_port_key) "input"
	    }
	}
    }
    
    set floating_width 0
    
    # convert the fragments to concatenations
    foreach instance_name [array names instance_to_ports] {
	funset instance_ports
	set instance_ports $instance_to_ports($instance_name)
	
	#array set instances  $definition(instances)
	#array set instance   $instances($instance_name)
	#array set port_infos $instance(ports)
	
	set new_instance_ports [list]
	
	foreach {port_name throwaway} $instance_ports {
	    lappend new_instance_ports $port_name
	    set instance_port_key ${instance_name}.${port_name}
	    
	    set direction $rtl_signal_dir($instance_port_key)
	    # todo: guarantee input/output are always lowercase and exactly those strings further upstream aka api
	    set direction [string tolower $direction]
	    
	    set fragpartner_names $instance_port_to_fragpartner_names($instance_port_key)
	    set fragpartner_ranges $instance_port_to_fragpartner_ranges($instance_port_key)
	    
	    set width -1
	    set default_term 0
	    #set port_info $port_infos($port_name)

	    # TODO: if input
	    if {[info exists instance_port_width($instance_port_key)]} {
		set width $instance_port_width($instance_port_key)	
	    }
	    if {[info exists instance_port_default_term($instance_port_key)]} {
		set default_term $instance_port_default_term($instance_port_key)
	    }

	    # jacl doesn't work with -command on this specific sort so do a sort on the high ranges only
	    set hi_list [list]
	    foreach range $fragpartner_ranges {
		set parts [split $range ":"]
		lappend hi_list [lindex $parts 0]
	    }
	    set indices [lsort-indices -decreasing -integer $hi_list]

	    if {$width == -1} {
		set current_index -1
	    } else {
		set current_index [expr {$width - 1}]
	    }
	    
	    set final_fragpartner_names  [list]
	    set final_fragpartner_ranges [list]

	    order_frag $fragpartner_names $fragpartner_ranges $indices $current_index $direction $default_term floating_width final_fragpartner_names final_fragpartner_ranges
	    
	    set instance_port_to_fragpartner_names($instance_port_key) $final_fragpartner_names
	    set instance_port_to_fragpartner_ranges($instance_port_key) $final_fragpartner_ranges
	}
	# convert the set to a list
	set instance_to_ports($instance_name) $new_instance_ports
    }

    # assign statements for wire to module ports
    foreach wire_name [array names wires_driving_module_ports] {
	set names  $wires_driving_module_ports($wire_name)
	set ranges $wires_driving_module_ports_ranges($wire_name)

	foreach name $names range $ranges {
	    set lhs $name
	    set rhs "${wire_name}\[${range}\]"
	    lappend raw_assigns [list $lhs $rhs]
	}
    } 
    foreach wire_name [array names wires_driven_by_module_ports] {
	set names  $wires_driven_by_module_ports($wire_name)
	set ranges $wires_driven_by_module_ports_ranges($wire_name)
	
	foreach name $names range $ranges {
	    set lhs "${wire_name}\[${range}\]"
	    set rhs "$name"
	    lappend raw_assigns [list $lhs $rhs]
	}
    }
    
    # tristate output assignments: convert the oe and output to rtl-happy
    set mapped(tristate_output_assignments) [list]
    foreach {signal_name tristate_output} $tristate_output_assignments {
	lassign $tristate_output oe output

	# if oe is blank, assume always 1
	if {[string compare $oe "" ] == 0} {
	    set oe "'1"
	} else {
	    lassign $oe oe_name oe_index
	    set oe     "${oe_name}\[${oe_index}\]"
	}
	# if output is blank, assume always 0
	if {[string compare $output "" ] == 0} {
	    set output "'0"
	} else {
	    lassign $output output_name output_index
	    set output "${output_name}\[${output_index}\]"
	}
	
	lappend mapped(tristate_output_assignments) $signal_name $oe $output
    }
    
    set mapped(instance_port_to_fragpartner_names_string)  [array get instance_port_to_fragpartner_names]
    set mapped(instance_port_to_fragpartner_ranges_string) [array get instance_port_to_fragpartner_ranges]
    set mapped(instance_to_ports_string) [array get instance_to_ports]
    set mapped(exported_signal_literal_assignments) $exported_signal_literal_assignments
    set mapped(floating_width) $floating_width
    set mapped(raw_assigns) $raw_assigns
}

proc order_frag {fragpartner_names fragpartner_ranges indices current_index direction default_term floating_width_ref final_fragpartner_names_ref final_fragpartner_ranges_ref} {
    upvar 1 $floating_width_ref floating_width
    upvar 1 $final_fragpartner_names_ref final_fragpartner_names
    upvar 1 $final_fragpartner_ranges_ref final_fragpartner_ranges
    foreach index $indices {
	set range [lindex $fragpartner_ranges $index]
	set token [lindex $fragpartner_names  $index]
	set parts [split $range ":"]
	set hi [lindex $parts 0]
	set lo  [lindex $parts 1]
	if {$current_index == -1} {
	    set current_index $hi
	}
	
	if {$current_index > $hi} {
	    # for gaps, either use default termination or connect it to a floating wire (input,output respectively)
	    set filler_hi [expr $hi + 1]
	    set filler_width [expr $current_index - $filler_hi + 1]
	    lappend final_fragpartner_ranges "${current_index}:${filler_hi}"
	    set current_index $hi
	    if {[string compare $direction "input" ] == 0} {
		lappend final_fragpartner_names  [verilog_constant $default_term $filler_width]
	    } else {
		# TODO: move this somewhere so there isn't duplicate code
		set floating_lo $floating_width
		incr floating_width $filler_width
		set floating_hi [expr {$floating_width - 1}]
		set name "floating\[${floating_hi}:${floating_lo}\]"
		lappend final_fragpartner_names  $name
	    }
	}
	if {$current_index == $hi} {
	    lappend final_fragpartner_names  $token
	    lappend final_fragpartner_ranges $range
	    set current_index [expr $lo - 1]
	} else {
	    send_message error "this is impossible! ${current_index} - ${hi} - ${instance_port_key}"
	    send_message error "fragpartner_names: ${fragpartner_names}"
	    send_message error "fragpartner_ranges: ${fragpartner_ranges}"
	    send_message error "hi_list: ${hi_list}"
	    send_message error "indices: ${indices}"
	}
	# TODO: wires for output termination in gaps
    }
    if {$current_index > -1} {
	set filler_width [expr $current_index + 1]
	lappend final_fragpartner_ranges "${current_index}:0"
	if {[string compare $direction "input" ] == 0} {
	    # add remaining term
	    lappend final_fragpartner_names  [verilog_constant $default_term $filler_width]
	} else {
	    set floating_lo $floating_width
	    incr floating_width $filler_width
	    set floating_hi [expr {$floating_width - 1}]
	    set name "floating\[${floating_hi}:${floating_lo}\]"
	    lappend final_fragpartner_names  $name
	}
    }
}

proc synth { outputName } {


#~~~~~~~~~~~~~~~~~~~~~ START OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    array set data [get_parameter_value interfaceDefinition]
    array set properties $data(properties)
    
    if {[info exists properties(SUPPRESS_SDRAM_SYNTH)] && !$properties(SUPPRESS_SDRAM_SYNTH)} {
	generate_hps_emif_component "hps" QUARTUS_SYNTH
    } 
#~~~~~~~~~~~~~~~~~~~~~ END OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	
    # RTL
    set template_file [open altera_interface_generator.sv.terp]
    set template      [read $template_file]
    close $template_file

    set params(interfacePeripheralList) [get_parameter_value interfaceDefinition]
    set params(output_name) ${outputName}

    array set definition $params(interfacePeripheralList)
    process_synthesis_mapping definition params
    
    set params(skip_rendering) {}

    do_terp $template params

    render_sdc_file $outputName $params(interfacePeripheralList)

    
    populate_hps_parameter_map hps_parameter_map
    generate_hps_xml_file definition hps_parameter_map
}

################################################################################
# Renders an sdc file and adds it to the current fileset
# if constraints were declared.
#
proc render_sdc_file {output_name data_string} {
################################################################################
    array set ds $data_string
    set constraints $ds(constraints)
    if {[llength $constraints] > 0} {
	set sdc_contents [join $constraints "\n"]
	add_fileset_file ${output_name}.sdc SDC TEXT $sdc_contents
    }
}

proc populate_hps_parameter_map {map_ref} {
    upvar 1 $map_ref map
    array set map [get_parameter_value hps_parameter_map]
}

proc generate_hps_xml_file {definition_ref hps_parameter_map_ref} {
    upvar 1 $definition_ref        definition
    upvar 1 $hps_parameter_map_ref hps_parameter_map
    
    array set properties $definition(properties)
    if {[info exists properties(GENERATE_ISW)] && $properties(GENERATE_ISW)} {
	add_fileset_file "hps.pre.xml" HPS_ISW TEXT [isw::render_hps_xml_file hps_parameter_map]
    }
}
