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


######################################
#
# API for creating the data structure
# used by altera_interface_generator.
# Source inside of a namespace of a
# hw.tcl component for best results.
#
# Requires: procedures.tcl for
#             funset{}
#           constants.tcl for
#             ORDERED_NAMES
#
######################################


######################################
# Alias a namespac var with an available local name.
# Useful for aliasing arrays where the namespace-qualified path contains variables.
# e.g. { namespace_alias ::a::$var_name var
#        set str $var(key)
#      }
# instead of 
#      { variable ::a::$var_name
#        set str $$var_name(key)   ;# This doesn't work!
#      }
proc namespace_alias {qual_name alias} {
######################################
    uplevel upvar 0 $qual_name $alias
}

# Names of interfaces, in order of creation
variable interface_names

# Array of generated instances
variable instances

# Something(?) of bfm types to properties
variable bfm_types

# Number of intermediate wires being used
variable intermediate_wire_count

# array of raw wire to fragment relationships
variable wires_to_fragments

# raw assigns
variable raw_assigns

# list of constraints
variable constraints

# simulation rendering style
variable wire_sim_style
variable raw_assign_sim_style
variable interface_sim_style

# special properties
variable properties

# Definitions of interfaces. Variable name is the interface name, array value is the interface def array.
# Signals stored in nested namespaces. Nested namespace name is the interface name, variable name is signal
# name, array value is signal
namespace eval interface_def {}

# Adds an interface to the border. Does not modify the Qsys model.
proc add_interface {interface_name type direction} {
    variable interface_names
    lappend interface_names $interface_name
    namespace_alias interface_def::$interface_name interface
    if {[info exists interface]} {
	send_message error "Internal Error: Interface ${interface_name} cannot be added twice."
    }
    #	array set interface "type $type direction $direction moduleName $module_name signals {[ORDERED_NAMES] {}} properties {}"
    set interface(type)       $type
    set interface(direction)  $direction
    
    namespace eval interface_def::${interface_name} {}
    namespace_alias interface_def::${interface_name}::[ORDERED_NAMES] ordered_names
    set ordered_names [list]
#    set interface(signals)    "[ORDERED_NAMES] {}"
    set interface(properties) {}
}

# Adds a port to an interface on the border. Does not modify the Qsys model.
proc add_interface_port {interface_name port_name role direction width {instance_name ""} {internal_name ""}} {
#    namespace_alias interface_def::$interface_name interface
    namespace_alias interface_def::${interface_name}::[ORDERED_NAMES] ordered_names
    namespace_alias interface_def::${interface_name}::$port_name      port
    
#    array set signals $interface(signals)
    if {[string compare $instance_name ""] == 0} {
	set instance_name $interface_name
    }
    if {[string compare $internal_name ""] == 0} {
	set internal_name $port_name
    }
    array set port [list role $role direction $direction width $width internal_name $internal_name instance_name $instance_name properties {} fragments {}]
#    set signals($port_name) $port
#    set ordered_names $signals([ORDERED_NAMES])
    lappend ordered_names $port_name
#    set signals([ORDERED_NAMES]) $ordered_names
#    set interface(signals) [array get signals]
}

proc allocate_wire {} {
    variable intermediate_wire_count

    set index $intermediate_wire_count
    incr intermediate_wire_count
    
    return [list intermediate ${index}]
}

proc allocate_wires {amount} {
    variable intermediate_wire_count
    
    set low $intermediate_wire_count
    incr intermediate_wire_count $amount
    set high [expr {$intermediate_wire_count - 1}]
    
    return [list intermediate $high $low]
}

proc set_wire_simulation_rendering {wire type} {
    variable wire_sim_style
    if {[string compare $type "SYNTHESIS"] == 0} {
	set wire_sim_style($wire) $type
    } elseif {[string compare $type "DEFAULT"] == 0} {
	if {[info exists wire_sim_style($wire)]} {
	    unset wire_sim_style($wire)
	}
    }
}


proc wire_tofragment {wire} {
    lassign $wire name high low
    if {[llength $wire] < 3} {
	set low $high
    }
    return "@${name}(${high}:${low})"
}

proc wire_tortl {wire} {
    lassign $wire name high low
    if {[llength $wire] < 3} {
	set low $high
    }
    return "${name}\[${high}:${low}\]"
}

proc hookup_wires {wire1 wire2} {
    set rendering_type ""
    variable wire_sim_style
    set style ""
    if {[info exists wire_sim_style($wire1)]} {
	set style $wire_sim_style($wire1)
    }
    add_raw_assign [wire_tortl $wire1] [wire_tortl $wire2] $style
}

################################################
# Set instance port fragments to a wire.
#
# Can be used to have a wire "drive"
# instance ports or be "driven_by" them.
proc set_wire_port_fragments {wire verb args} {
################################################
    variable wires_to_fragments

    if {[string compare -nocase $verb "drives"] == 0} {
	set direction "input"
    } elseif {[string compare -nocase $verb "driven_by"] == 0} {
	set direction "output"
    } else {
	return
    }
    set wires_to_fragments($wire) [list $direction $args]
}

################################################
# Add a raw assign statement to the RTL.
#
proc add_raw_assign {lhs rhs {simulation_rendering ""}} {
################################################
    variable raw_assigns
    set raw_assign [list $lhs $rhs]
    lappend raw_assigns $raw_assign

    if {[string compare $simulation_rendering "SYNTHESIS"] == 0} {
	variable raw_assign_sim_style
	set raw_assign_sim_style($raw_assign) $simulation_rendering
    }
}

# Allows for tristate output on a port. Only supports 1-bit signals. Only supports out and oe instances..
# For inout, set_port_fragments operates on the input portion and this proc works on the output portion
# For output, only use set_port_tristate_output and not set_port_fragments
proc set_port_tristate_output {interface_name port_name output_fragment oe_fragment} {
    namespace_alias interface_def::${interface_name}::$port_name      signal
    variable wires_to_fragments
    
    # allocate wire for output
    set output_wire ""
    if {$output_fragment != ""} {
	set output_wire [allocate_wire]
	set wires_to_fragments($output_wire) [list output $output_fragment]
    }
    
    # allocate wire for oe
    set oe_wire ""
    if {$oe_fragment != ""} {
	set oe_wire [allocate_wire]
	set wires_to_fragments($oe_wire) [list output $oe_fragment]
    }

    # make the tristate output assignment
    set signal(tristate_output) [list $oe_wire $output_wire]
}

# Sets a property of an interface on the border. Does not modify the Qsys model.
proc set_interface_property {interface_name property value} {
    namespace_alias interface_def::$interface_name interface
    array set properties $interface(properties)
    set properties($property) $value
    set interface(properties) [array get properties]
}

proc set_interface_meta_property {interface_name meta_property_name value} {
    namespace_alias interface_def::$interface_name interface
    set interface($meta_property_name) $value
}

proc set_interface_simulation_rendering {interface_name type} {
    variable interface_sim_style
    if {[string compare $type "SYNTHESIS"] == 0} {
	set interface_sim_style($interface_name) $type
    } elseif {[string compare $type "DEFAULT"] == 0} {
	if {[info exists interface_sim_style($interface_name)]} {
	    unset interface_sim_style($interface_name)
	}
    }
}

proc set_port_property {interface_name port_name property_name value} {
    namespace_alias interface_def::${interface_name}::$port_name      port
#    namespace_alias interface_def::$interface_name interface
#    array set signals    $interface(signals)
#    array set signal     $signals($port_name)
    array set properties $port(properties)
    
    set properties($property_name) $value

    set port(properties)  [array get properties]
#    set signals($port_name) [array get signal]
#    set interface(signals)  [array get signals]
}

proc set_port_generation_details {interface_name port_name inst_name {internal_name ""}} {
    if {[string compare $internal_name ""] == 0} {
	set internal_name $port_name
    }
    namespace_alias interface_def::$interface_name::$port_name      signal
#    namespace_alias interface_def::$interface_name interface
#    array set signals $interface(signals)
#    array set signal $signals($port_name)
    set signal(internal_name) $internal_name
    set signal(instance_name) $inst_name
    
#    set signals($port_name) [array get signal]
#    set interface(signals)  [array get signals]
}

proc set_port_fragments {interface_name port_name args} {
    namespace_alias interface_def::${interface_name}::$port_name      signal
    set signal(fragments) $args
#    foreach {frag_inst frag_signal frag_range} $args {
#	lappend signal(fragments) $frag_inst $frag_signal $frag_range
#    }
}

# Adds a module to the generated RTL
proc add_module_instance {inst_name entity_name {location ""}} {
    variable instances
    set ordered_names $instances([ORDERED_NAMES])
    lappend ordered_names $inst_name
    set instances([ORDERED_NAMES]) $ordered_names

    set instance(entity_name) $entity_name
    set instance(location)    $location
    set instance(parameters)  {}
    set instance(signal_terminations) {}
    set instance(signal_widths) {}
    set instance(signal_default_terminations) {}
    set instances($inst_name) [array get instance]
}

# Set termination details for an instance INPUT port.
#  args: list where first element is a range, next element is the decimal termination value, repeated..
proc set_instance_port_termination {instance_name port_name width default_term args} {
    variable instances
    
    array set instance $instances($instance_name)
    array set signal_terminations $instance(signal_terminations)
    
    if {([llength $args] % 2) == 0} {
	set signal_terminations($port_name) $args
    } else {
	error "Individual termination settings must be in pairs."
    }
    
    set instance(signal_terminations) [array get signal_terminations]
    
    array set signal_widths $instance(signal_widths)
    set signal_widths($port_name) $width
    set instance(signal_widths) [array get signal_widths]
    
    array set signal_default_terminations $instance(signal_default_terminations)
    set signal_default_terminations($port_name) $default_term
    set instance(signal_default_terminations) [array get signal_default_terminations]
    
    set instances($instance_name) [array get instance]
}

proc set_instance_parameter {instance_name parameter value} {
    variable instances
    array set instance   $instances($instance_name)
    array set parameters $instance(parameters)
    set parameters($parameter) $value
    set instance(parameters) [array get parameters]
    set instances($instance_name) [array get instance]
}

proc add_raw_sdc_constraint {constraint} {
    variable constraints
    lappend constraints $constraint
}

proc set_property {property value} {
    variable properties
    set properties($property) $value
}

# Initializes the border.
# TODO: make a test that ensures this erases the contents
proc init {} {
    eval "namespace delete interface_def" ;# ensures the namespace is properly deleted
    namespace eval interface_def {}
    
    variable intermediate_wire_count 0
    variable interface_names [list]
    variable bfm_types {}
    variable instances
    funset instances
    set instances([ORDERED_NAMES]) [list]
    variable wires_to_fragments
    funset wires_to_fragments
    variable raw_assigns [list]
    variable constraints [list]
    
    variable wire_sim_style
    funset wire_sim_style
    variable raw_assign_sim_style
    funset raw_assign_sim_style
    variable interface_sim_style
    funset interface_sim_style
    variable properties
    funset properties
}

proc set_bfm_types {new_bfm_types} {
    variable bfm_types
    set bfm_types $new_bfm_types
}

# Serializes the border as a Tcl array.
proc serialize {var_name} {
    variable interface_names
    variable instances
    variable bfm_types
    variable intermediate_wire_count
    variable wires_to_fragments
    variable raw_assigns
    variable constraints
    variable wire_sim_style
    variable raw_assign_sim_style
    variable interface_sim_style
    variable properties
    upvar 1  $var_name data
    
    set interfaces [list [ORDERED_NAMES] $interface_names]
    foreach interface_name $interface_names {
	namespace_alias interface_def::$interface_name interface
	set interface_string [array get interface]
	
	namespace_alias interface_def::${interface_name}::[ORDERED_NAMES] ordered_names
	set signals [list [ORDERED_NAMES] $ordered_names]
	foreach signal_name $ordered_names {
	    namespace_alias interface_def::${interface_name}::$signal_name      signal
	    lappend signals $signal_name [array get signal]
	}
	lappend interface_string signals $signals
#	set interfaces($interface_name) [array get interface]
	lappend interfaces $interface_name $interface_string
    }
    set data(interfaces) $interfaces
    set data(instances)  [array get instances]
    # is this the best place for it? uses an outside parameter instead of internal data structures
    set bfm_types $bfm_types
    set data(bfm_types) $bfm_types
    set data(intermediate_wire_count) $intermediate_wire_count
    set data(wires_to_fragments)      [array get wires_to_fragments]
    set data(raw_assigns)             $raw_assigns
    set data(constraints)             $constraints
    set data(wire_sim_style)          [array get wire_sim_style]
    set data(raw_assign_sim_style)    [array get raw_assign_sim_style]
    set data(interface_sim_style)     [array get interface_sim_style]
    set data(properties)              [array get properties]
}

# Debug reporting.
proc debug_report {} {
    variable interface_names
    send_message debug "interface names: ${interface_names}"
}
