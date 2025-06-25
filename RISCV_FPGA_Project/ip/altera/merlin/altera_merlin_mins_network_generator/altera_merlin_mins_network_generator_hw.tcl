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


#+ --------------------------------------------- 
#| "Network Generator" v1.0
#| 
#| Creates a network from a graph description  
#+ --------------------------------------------- 

package require -exact qsys 12.1


set_module_property NAME altera_merlin_mins_network_generator
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Network Generator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property COMPOSITION_CALLBACK compose

# 
# parameters
#

add_parameter DATA_WIDTH INTEGER 8
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data width"

add_parameter CHANNEL_WIDTH INTEGER 4
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME "Channel width"

add_parameter DRIVING_NODE  STRING_LIST
add_parameter DRIVEN_NODE STRING_LIST

set_parameter_property DRIVING_NODE  DISPLAY_NAME "Driving Node"
set_parameter_property DRIVEN_NODE   DISPLAY_NAME "Driven Node"

add_parameter PIPELINE_MUX_OUTPUTS INTEGER 1
set_parameter_property PIPELINE_MUX_OUTPUTS DISPLAY_NAME "Pipeline mux outputs"
set_parameter_property PIPELINE_MUX_OUTPUTS ALLOWED_RANGES "0:1"
set_parameter_property PIPELINE_MUX_OUTPUTS DISPLAY_HINT "boolean"

add_parameter NO_COLLISIONS INTEGER
set_parameter_property NO_COLLISIONS DISPLAY_NAME "No collisions"
set_parameter_property NO_COLLISIONS ALLOWED_RANGES "0:1"
set_parameter_property NO_COLLISIONS DISPLAY_HINT "boolean"

add_parameter NODE  STRING_LIST
add_parameter PARAMETER STRING_LIST
add_parameter VALUE STRING_LIST

set_parameter_property NODE DISPLAY_NAME "Node"
set_parameter_property PARAMETER DISPLAY_NAME "Parameter"
set_parameter_property VALUE DISPLAY_NAME "Value"

# 
# display items
# 
add_display_item "Connectivity" connectivity_table GROUP TABLE
add_display_item connectivity_table DRIVING_NODE  PARAMETER
add_display_item connectivity_table DRIVEN_NODE PARAMETER

add_display_item "Node Parameters" parameter_table GROUP TABLE
add_display_item parameter_table NODE PARAMETER
add_display_item parameter_table PARAMETER PARAMETER
add_display_item parameter_table VALUE PARAMETER

#
# composition callback
#
proc compose { } {

    array set fanout_by_node [ create_fanout_hash ]
    array set fanin_by_node  [ create_fanin_hash  ]
    array set type_by_node  [ determine_node_types fanout_by_node fanin_by_node ]

    add_components type_by_node
    parameterize_fanin_components fanin_by_node
    parameterize_fanout_components fanout_by_node
    parameterize_data_and_channel_widths type_by_node
    parameterize_nodes_with_user_parameters

    connect_clocks_and_resets type_by_node
    connect_drivers_to_sinks type_by_node fanout_by_node fanin_by_node

    export_unconnected_nodes fanout_by_node fanin_by_node

    set_routing_assignments fanout_by_node fanin_by_node
}

proc parameterize_nodes_with_user_parameters { } {

    set nodes      [ get_parameter_value NODE ]
    set parameters [ get_parameter_value PARAMETER ]
    set values     [ get_parameter_value VALUE ]

    for { set i 0 } { $i < [ llength $nodes ] } { incr i } {
        set_instance_parameter [ lindex $nodes $i ] [ lindex $parameters $i] [ lindex $values $i ]
    }
}

proc set_routing_assignments { fanout_name fanin_name } {

    upvar $fanout_name fanout_by_node
    upvar $fanin_name fanin_by_node

    foreach input_node [ obtain_input_nodes fanin_by_node ] {
        array set channel_by_node [ list ]
        array unset channel_by_node

        append_channels $input_node "" channel_by_node fanout_by_node 

        foreach { output_node channel } [ array get channel_by_node ] {
            set_interface_assignment $input_node "merlin.channel.${output_node}" $channel
            set_interface_assignment $input_node "merlin.flow.${output_node}" $output_node
        }
    }

}

proc append_channels { input_node input_channel routing_name fanout_name } {

    upvar $routing_name channel_by_node
    upvar $fanout_name fanout_by_node

    set fanout_list $fanout_by_node($input_node)

    if { [ llength $fanout_list ] == 0 } {
        set channel_by_node($input_node) $input_channel
        return
    }

    for { set i 0 } { $i < [ llength $fanout_list ] } { incr i } {
        set node_channel ""
        if { [ llength $fanout_list ] > 1 } {
            set node_channel [ string repeat "0" [ llength $fanout_list ] ]
            set bit_index    [ expr [ llength $fanout_list ] - $i - 1 ]
            set node_channel [ string replace $node_channel $bit_index $bit_index "1" ]
        }

        set next_channel "${node_channel}${input_channel}"
        set fanout [ lindex $fanout_list $i ]
        append_channels $fanout $next_channel channel_by_node fanout_by_node
    }

}


proc export_unconnected_nodes { fanout_name fanin_name } {

    upvar $fanout_name fanout_by_node
    upvar $fanin_name fanin_by_node

    foreach node [ obtain_input_nodes $fanin_name ] {
        add_interface $node avalon_streaming sink
        set_interface_property $node EXPORT_OF ${node}.sink
    }

    foreach node [ get_parameter_value DRIVEN_NODE ] {
        set fanout $fanout_by_node($node)

        if { [ llength $fanout ] == 0 } {
            add_interface $node avalon_streaming source
            set_interface_property $node EXPORT_OF ${node}.src
        }
    }
}

proc obtain_input_nodes { fanin_name } {

    upvar $fanin_name fanin_by_node
    set input_nodes [ list ]

    foreach node [ get_parameter_value DRIVING_NODE ] {
        set fanin $fanin_by_node($node)

        if { [ llength $fanin ] == 0 } {
            lappend input_nodes $node
        }
    }

    return $input_nodes
}

proc parameterize_data_and_channel_widths { types_name } {

    upvar $types_name type_by_node

    foreach { node type } [ array get type_by_node ] {
        set_instance_parameter $node ST_DATA_W [ get_parameter_value DATA_WIDTH ]
        set_instance_parameter $node ST_CHANNEL_W [ get_parameter_value CHANNEL_WIDTH ]
    }

}

proc parameterize_fanin_components { fanin_name } {
    
    upvar $fanin_name fanin_by_node
    set no_collisions [ get_parameter_value NO_COLLISIONS ]

    foreach { node fanin } [ array get fanin_by_node ] {
        if { [ llength $fanin ] > 1 } {
            set_instance_parameter $node NUM_INPUTS [ llength $fanin ]

            if { $no_collisions == 0 } {
                set_instance_parameter $node PIPELINE_ARB 1
            } else {
                set_instance_parameter $node ARBITRATION_SCHEME "no-arb"
            }
        }
    }

}

proc parameterize_fanout_components { fanout_name } {
    
    upvar $fanout_name fanout_by_node

    foreach { node fanout } [ array get fanout_by_node ] {
        if { [ llength $fanout ] > 1 } {
            set_instance_parameter $node NUM_OUTPUTS [ llength $fanout ]
        }
    }

}

proc connect_drivers_to_sinks { types_name fanout_name fanin_name } {

    upvar $types_name type_by_node
    upvar $fanout_name fanout_by_node
    upvar $fanin_name fanin_by_node

    foreach { driver fanout } [ array get fanout_by_node ] {
        for { set i 0 } { $i < [ llength $fanout ] } { incr i } {

            set out_intf_name [ get_driver_intf_name $i $fanout ]
            set sink [ lindex $fanout $i ]
            set in_intf_name [ get_sink_intf_name $i $driver $fanin_by_node($sink) ]

            if { [ is_driver_output_pipelined $driver type_by_node ] } {
                make_pipelined_connection $driver $out_intf_name $sink $in_intf_name
            } else {
                add_connection ${driver}.${out_intf_name} ${sink}.${in_intf_name}
            }
        }
    }

}

proc is_driver_output_pipelined { driver types_name } {

    upvar $types_name type_by_node

    set pipeline_mux_output [ get_parameter_value PIPELINE_MUX_OUTPUTS ]
    set driver_is_mux       [ expr [ string compare $type_by_node($driver) "altera_merlin_multiplexer" ] == 0 ]

    if { $pipeline_mux_output && $driver_is_mux } {
        return 1
    }
    
    return 0
}

proc get_sink_intf_name { current_index driver fanin_list } {

    set in_index [ lsearch $fanin_list $driver ]
    set in_intf_name "sink${in_index}"
    if { [ llength $fanin_list ] == 1 } {
        set in_intf_name "sink"
    }
    return $in_intf_name
}

proc get_driver_intf_name { current_index fanout_list } {

    set out_intf_name "src${current_index}"
    if { [ llength $fanout_list ] == 1 } {
        set out_intf_name "src"
    }

    return $out_intf_name
}

proc make_pipelined_connection { driver driver_intf_name sink sink_intf_name } {

    set pipeline_name [ add_pipeline $driver $driver_intf_name ]

    add_connection ${driver}.${driver_intf_name} ${pipeline_name}.in
    add_connection ${pipeline_name}.out ${sink}.${sink_intf_name}

}

proc add_pipeline { driver driver_intf_name } {

    set pipeline_name ${driver}_${driver_intf_name}_pipeline 

    add_instance $pipeline_name altera_avalon_sc_fifo
    set_instance_parameter $pipeline_name BITS_PER_SYMBOL   [ get_parameter_value DATA_WIDTH ]
    set_instance_parameter $pipeline_name USE_PACKETS       1
    set_instance_parameter $pipeline_name CHANNEL_WIDTH     [ get_parameter_value CHANNEL_WIDTH ]
    set_instance_parameter $pipeline_name FIFO_DEPTH        3
    set_instance_parameter $pipeline_name USE_MEMORY_BLOCKS 0
    set_instance_parameter $pipeline_name EMPTY_LATENCY     1
    set_instance_parameter $pipeline_name ENABLE_EXPLICIT_MAXCHANNEL true
    set_instance_parameter $pipeline_name EXPLICIT_MAXCHANNEL 0

    add_connection clk.clk ${pipeline_name}.clk
    add_connection clk.clk_reset ${pipeline_name}.clk_reset

    return $pipeline_name
}

proc connect_clocks_and_resets { types_name } {

    upvar $types_name type_by_node

    add_clock_source

    foreach { node type } [ array get type_by_node ] {
        add_connection clk.clk ${node}.clk
        add_connection clk.clk_reset ${node}.clk_reset
    }
}


proc add_components { types_name } {

    upvar $types_name type_by_node
    array set components_by_node [ list ]

    foreach { node type } [ array get type_by_node ] {
        add_instance $node $type
    }
}

proc determine_node_types { fanout_name fanin_name } {

    upvar $fanout_name fanout_by_node
    upvar $fanin_name fanin_by_node

    array set type_by_node [ list ]

    foreach { node fanout } [ array get fanout_by_node ] {
        if { [ llength $fanout ] > 1 } {
            set type_by_node($node) "altera_merlin_demultiplexer"
        }

        if { [ llength $fanout ] == 1 && [ llength $fanin_by_node($node) ] <= 1 } {
            set type_by_node($node) "altera_merlin_st_pass_through"
        }
    }

    foreach { node fanin } [ array get fanin_by_node ] {
        if { [ llength $fanin ] > 1 } {
            set type_by_node($node) "altera_merlin_multiplexer"
        }

        if { [ llength $fanin ] == 1 && [ llength $fanout_by_node($node) ] <= 1 } {
            set type_by_node($node) "altera_merlin_st_pass_through"
        }
    }

    return [ array get type_by_node ]
}

proc set_data_widths { component_by_node } {

    foreach { node component } $component_by_node {
        set_instance_parameter $component ST_DATA_W [ get_parameter_value DATA_WIDTH ]
    }
}

proc set_channel_widths { component_by_node } {

    foreach { node component } $component_by_node {
        set_instance_parameter $component ST_CHANNEL_W [ get_parameter_value CHANNEL_WIDTH ]
    }
}

proc add_clock_source { } {
    add_instance clk clock_source

    add_interface clk clock sink
    set_interface_property clk EXPORT_OF clk.clk_in

    add_interface reset_n reset sink
    set_interface_property reset_n EXPORT_OF clk.clk_in_reset

    set_instance_parameter clk resetSynchronousEdges DEASSERT
}

#+ -------------------------------------------
# Creates a map of nodes to fanin nodes.
# Every node in the connectivity graph is accounted for,
# even those that do not have fanin (they get an empty list).
#+ -------------------------------------------
proc create_fanin_hash { } {

    set sinks   [ get_parameter_value DRIVEN_NODE ]
    set drivers [ get_parameter_value DRIVING_NODE ]
    array set fanin_by_node [ list ]

    for { set i 0 } { $i < [ llength $sinks ] } { incr i } {
        set sink   [ lindex $sinks $i ]
        set driver [ lindex $drivers $i ]

        if { [ info exists fanin_by_node($sink) ] } {
            lappend fanin_by_node($sink) $driver
        } else {
            set fanin_by_node($sink) [ list $driver ]
        }

        if { ![ info exists fanin_by_node($driver) ] } {
            set fanin_by_node($driver) [ list ]
        }
    }

    return [ array get fanin_by_node ]
}

#+ -------------------------------------------
# Creates a map of nodes to fanout nodes.
# Every node in the connectivity graph is accounted for,
# even those that do not fanout (they get an empty list).
#+ -------------------------------------------
proc create_fanout_hash { } {

    set drivers [ get_parameter_value DRIVING_NODE ]
    set sinks   [ get_parameter_value DRIVEN_NODE ]
    array set fanout_by_node [ list ]

    for { set i 0 } { $i < [ llength $drivers ] } { incr i } {
        set driver [ lindex $drivers $i ]
        set sink   [ lindex $sinks $i ]

        if { [ info exists fanout_by_node($driver) ] } {
            lappend fanout_by_node($driver) $sink
        } else {
            set fanout_by_node($driver) [ list $sink ]
        }

        if { ![ info exists fanout_by_node($sink) ] } {
            set fanout_by_node($sink) [ list ]
        }
    }

    return [ array get fanout_by_node ]
}
