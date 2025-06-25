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


# $Id: //acds/rel/13.1/ip/avalon_st/altera_avalon_st_adapter/altera_avalon_st_adapter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
# -------------------------------------------------------------------------------
package require -exact sopc 11.0

set_module_property NAME                         altera_avalon_st_adapter
set_module_property DISPLAY_NAME                 "Avalon-ST Adapter"
set_module_property DESCRIPTION                  "Adapt mismatched Avalon-ST endpoints"
set_module_property VERSION                      13.1
set_module_property GROUP                        "Bridges/Streaming"
set_module_property AUTHOR                       "Altera Corporation"
set_module_property HIDE_FROM_SOPC               true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     true
set_module_property INTERNAL                     false
set_module_property COMPOSE_CALLBACK             composed
set_module_property ANALYZE_HDL                  FALSE

# ------------------------------------------------------------------------------
# Common Parameters (affects both Source and Sink Interfaces)
# ------------------------------------------------------------------------------
add_parameter inBitsPerSymbol Integer  8
set_parameter_property inBitsPerSymbol DISPLAY_NAME "Symbol Width"
set_parameter_property inBitsPerSymbol DESCRIPTION "Symbol Width"
set_parameter_property inBitsPerSymbol AFFECTS_ELABORATION true
set_parameter_property inBitsPerSymbol HDL_PARAMETER true
set_parameter_property inBitsPerSymbol GROUP "Common to Source & Sink Interfaces"

add_parameter inUsePackets Integer 0
set_parameter_property inUsePackets DISPLAY_NAME "Use Packet"
set_parameter_property inUsePackets AFFECTS_ELABORATION true
set_parameter_property inUsePackets DESCRIPTION "Add start & end of packet ports"
set_parameter_property inUsePackets HDL_PARAMETER true
set_parameter_property inUsePackets DISPLAY_HINT boolean
set_parameter_property inUsePackets GROUP "Common to Source & Sink Interfaces"

# ------------------------------------------------------------------------------
# Upstream Source Interface Parameters
# ------------------------------------------------------------------------------
add_parameter inDataWidth Integer 8
set_parameter_property inDataWidth DISPLAY_NAME "Source Data Width"
set_parameter_property inDataWidth DESCRIPTION "Data Width"
set_parameter_property inDataWidth AFFECTS_ELABORATION true
set_parameter_property inDataWidth HDL_PARAMETER true
set_parameter_property inDataWidth GROUP "Upstream Source Interface Parameters"

add_parameter inMaxChannel Integer 4
set_parameter_property inMaxChannel DISPLAY_NAME "Source Top Channel"
set_parameter_property inMaxChannel DESCRIPTION "Most Significant Source Channel ID"
set_parameter_property inMaxChannel AFFECTS_ELABORATION true
set_parameter_property inMaxChannel HDL_PARAMETER false
set_parameter_property inMaxChannel ALLOWED_RANGES {0:255}
set_parameter_property inMaxChannel GROUP "Upstream Source Interface Parameters"

add_parameter inChannelWidth Integer 3
set_parameter_property inChannelWidth DISPLAY_NAME "Source Channel Port Width"
set_parameter_property inChannelWidth DESCRIPTION "Source Channel Port Width"
set_parameter_property inChannelWidth AFFECTS_ELABORATION true
set_parameter_property inChannelWidth HDL_PARAMETER true
set_parameter_property inChannelWidth ALLOWED_RANGES {0:8}
set_parameter_property inChannelWidth GROUP "Upstream Source Interface Parameters"

add_parameter inErrorWidth Integer 2
set_parameter_property inErrorWidth DISPLAY_NAME "Source Error Port Width"
set_parameter_property inErrorWidth DESCRIPTION "Source Error Port Width"
set_parameter_property inErrorWidth AFFECTS_ELABORATION true
set_parameter_property inErrorWidth HDL_PARAMETER true
set_parameter_property inErrorWidth ALLOWED_RANGES {0:255}
set_parameter_property inErrorWidth GROUP "Upstream Source Interface Parameters"

add_parameter inErrorDescriptor STRING_LIST ""
set_parameter_property inErrorDescriptor DISPLAY_NAME "Source Error Descriptors"
set_parameter_property inErrorDescriptor DESCRIPTION "Descriptor for Every Bit of Source Error Signal"
set_parameter_property inErrorDescriptor GROUP "Upstream Source Interface Parameters"

add_parameter inUseEmptyPort Integer 0
set_parameter_property inUseEmptyPort DISPLAY_NAME "Source Uses Empty Port"
set_parameter_property inUseEmptyPort DESCRIPTION "Source Uses Empty Port"
set_parameter_property inUseEmptyPort AFFECTS_ELABORATION true
set_parameter_property inUseEmptyPort HDL_PARAMETER true
set_parameter_property inUseEmptyPort DISPLAY_HINT boolean
set_parameter_property inUseEmptyPort GROUP "Upstream Source Interface Parameters"

add_parameter inEmptyWidth Integer 1
set_parameter_property inEmptyWidth DISPLAY_NAME "Source Empty Port Width"
set_parameter_property inEmptyWidth DESCRIPTION "Derived from Source Symbols per Beat"
set_parameter_property inEmptyWidth DERIVED true
set_parameter_property inEmptyWidth GROUP "Upstream Source Interface Parameters"

add_parameter inUseValid Integer 1
set_parameter_property inUseValid DISPLAY_NAME "Source Uses Valid Port"
set_parameter_property inUseValid DESCRIPTION "Source Uses Valid Port"
set_parameter_property inUseValid AFFECTS_ELABORATION true
set_parameter_property inUseValid HDL_PARAMETER true
set_parameter_property inUseValid DISPLAY_HINT boolean
set_parameter_property inUseValid GROUP "Upstream Source Interface Parameters"

add_parameter inUseReady Integer 1
set_parameter_property inUseReady DISPLAY_NAME "Source Uses Ready Port"
set_parameter_property inUseReady DESCRIPTION "Source Uses Ready Port"
set_parameter_property inUseReady AFFECTS_ELABORATION true
set_parameter_property inUseReady HDL_PARAMETER true
set_parameter_property inUseReady DISPLAY_HINT boolean
set_parameter_property inUseReady GROUP "Upstream Source Interface Parameters"

add_parameter inReadyLatency Integer 0
set_parameter_property inReadyLatency DISPLAY_NAME "Source Ready Latency"
set_parameter_property inReadyLatency DESCRIPTION "Source Ready Latency"
set_parameter_property inReadyLatency AFFECTS_ELABORATION true
set_parameter_property inReadyLatency HDL_PARAMETER true
set_parameter_property inReadyLatency ALLOWED_RANGES {0:8}
set_parameter_property inReadyLatency GROUP "Upstream Source Interface Parameters"

# ------------------------------------------------------------------------------
# Downstream Sink Interface Parameters
# ------------------------------------------------------------------------------
add_parameter outDataWidth Integer 32
set_parameter_property outDataWidth DISPLAY_NAME "Sink Data Width"
set_parameter_property outDataWidth DESCRIPTION "Data Width"
set_parameter_property outDataWidth AFFECTS_ELABORATION true
set_parameter_property outDataWidth HDL_PARAMETER true
set_parameter_property outDataWidth GROUP "Downstream Sink Interface Parameters"

add_parameter outMaxChannel Integer 4
set_parameter_property outMaxChannel DISPLAY_NAME "Sink Top Channel"
set_parameter_property outMaxChannel DESCRIPTION "Most Significant Sink Channel ID"
set_parameter_property outMaxChannel AFFECTS_ELABORATION true
set_parameter_property outMaxChannel HDL_PARAMETER false
set_parameter_property outMaxChannel ALLOWED_RANGES {0:255}
set_parameter_property outMaxChannel GROUP "Downstream Sink Interface Parameters"

add_parameter outChannelWidth Integer 3
set_parameter_property outChannelWidth DISPLAY_NAME "Sink Channel Port Width"
set_parameter_property outChannelWidth DESCRIPTION "Sink Channel Port Width"
set_parameter_property outChannelWidth AFFECTS_ELABORATION true
set_parameter_property outChannelWidth HDL_PARAMETER true
set_parameter_property outChannelWidth ALLOWED_RANGES {0:8}
set_parameter_property outChannelWidth GROUP "Downstream Sink Interface Parameters"

add_parameter outErrorWidth Integer 2
set_parameter_property outErrorWidth DISPLAY_NAME "Sink Error Port Width"
set_parameter_property outErrorWidth DESCRIPTION "Sink Error Port Width"
set_parameter_property outErrorWidth AFFECTS_ELABORATION true
set_parameter_property outErrorWidth HDL_PARAMETER true
set_parameter_property outErrorWidth ALLOWED_RANGES {0:255}
set_parameter_property outErrorWidth GROUP "Downstream Sink Interface Parameters"

add_parameter outErrorDescriptor STRING_LIST ""
set_parameter_property outErrorDescriptor DISPLAY_NAME "Sink Error Descriptors"
set_parameter_property outErrorDescriptor DESCRIPTION "Descriptor for Every Bit of Sink Error Signal"
set_parameter_property outErrorDescriptor GROUP "Downstream Sink Interface Parameters"

add_parameter outUseEmptyPort Integer 0
set_parameter_property outUseEmptyPort DISPLAY_NAME "Sink Uses Empty Port"
set_parameter_property outUseEmptyPort DESCRIPTION "Sink Uses Empty Port"
set_parameter_property outUseEmptyPort AFFECTS_ELABORATION true
set_parameter_property outUseEmptyPort HDL_PARAMETER true
set_parameter_property outUseEmptyPort DISPLAY_HINT boolean
set_parameter_property outUseEmptyPort GROUP "Downstream Sink Interface Parameters"

add_parameter outEmptyWidth Integer 1
set_parameter_property outEmptyWidth DISPLAY_NAME "Sink Empty Port Width"
set_parameter_property outEmptyWidth DESCRIPTION "Derived from Sink Symbols per Beat"
set_parameter_property outEmptyWidth DERIVED true
set_parameter_property outEmptyWidth GROUP "Downstream Sink Interface Parameters"

add_parameter outUseValid Integer 1
set_parameter_property outUseValid DISPLAY_NAME "Sink Uses Valid Port"
set_parameter_property outUseValid DESCRIPTION "Sink Uses Valid Port"
set_parameter_property outUseValid AFFECTS_ELABORATION true
set_parameter_property outUseValid HDL_PARAMETER true
set_parameter_property outUseValid DISPLAY_HINT boolean
set_parameter_property outUseValid GROUP "Downstream Sink Interface Parameters"

add_parameter outUseReady Integer 1
set_parameter_property outUseReady DISPLAY_NAME "Sink Uses Ready Port"
set_parameter_property outUseReady DESCRIPTION "Sink Uses Ready Port"
set_parameter_property outUseReady AFFECTS_ELABORATION true
set_parameter_property outUseReady HDL_PARAMETER true
set_parameter_property outUseReady DISPLAY_HINT boolean
set_parameter_property outUseReady GROUP "Downstream Sink Interface Parameters"

add_parameter outReadyLatency Integer 0
set_parameter_property outReadyLatency DISPLAY_NAME "Sink Ready Latency"
set_parameter_property outReadyLatency DESCRIPTION "Sink Ready Latency"
set_parameter_property outReadyLatency AFFECTS_ELABORATION true
set_parameter_property outReadyLatency HDL_PARAMETER true
set_parameter_property outReadyLatency ALLOWED_RANGES {0:8}
set_parameter_property outReadyLatency GROUP "Downstream Sink Interface Parameters"

# ------------------------------------------------------------------------------
# Clock Related Parameters
# ------------------------------------------------------------------------------
# add_parameter ASYNC_CLOCKS Integer 0
# set_parameter_property ASYNC_CLOCKS DISPLAY_NAME "Asynchronous Clock Domains"
# set_parameter_property ASYNC_CLOCKS AFFECTS_ELABORATION true
# set_parameter_property ASYNC_CLOCKS DESCRIPTION "Source and Sink run on different clocks"
# set_parameter_property ASYNC_CLOCKS HDL_PARAMETER true
# set_parameter_property ASYNC_CLOCKS DISPLAY_HINT boolean
# set_parameter_property ASYNC_CLOCKS GROUP "Clock Domains"

# add_parameter CLOCK_CROSSING string "fifo"
# set_parameter_property CLOCK_CROSSING DISPLAY_NAME "Clock Crossing Logic"
# set_parameter_property CLOCK_CROSSING AFFECTS_ELABORATION true
# set_parameter_property CLOCK_CROSSING DESCRIPTION "Handshake for low bandwidth; FIFO for high."
# set_parameter_property CLOCK_CROSSING HDL_PARAMETER false
# set_parameter_property CLOCK_CROSSING ALLOWED_RANGES {"handshake" "fifo"}
# set_parameter_property CLOCK_CROSSING GROUP "Clock Domains"

# add_parameter FIFO_DEPTH Integer 8
# set_parameter_property FIFO_DEPTH DISPLAY_NAME "FIFO Depth"
# set_parameter_property FIFO_DEPTH AFFECTS_ELABORATION true
# set_parameter_property FIFO_DEPTH DESCRIPTION "Word depth of FIFO, if present"
# set_parameter_property FIFO_DEPTH HDL_PARAMETER true
# set_parameter_property FIFO_DEPTH DISPLAY_HINT integer
# set_parameter_property FIFO_DEPTH ALLOWED_RANGES {2:64}
# set_parameter_property FIFO_DEPTH GROUP "Clock Domains"

set inBitsPerSymbol_value     0
set inUsePackets_value        0

set inDataWidth_value         0
set inSymbolsPerBeat_value    0
set inMaxChannel_value        0
set inChannelWidth_value      0
set inErrorWidth_value        0
set inErrorDescriptor_value   0
set inUseEmptyPort_value      0
set inEmptyWidth_value        0
set inUseValid_value          0
set inUseReady_value          0
set inReadyLatency_value      0

set outDataWidth_value        0
set outSymbolsPerBeat_value   0
set outMaxChannel_value       0
set outChannelWidth_value     0
set outErrorWidth_value       0
set outErrorDescriptor_value  0
set outUseEmptyPort_value     0
set outEmptyWidth_value       0
set outUseValid_value         0
set outUseReady_value         0
set outReadyLatency_value     0

set connection_chain ""

# ------------------------------------------------------------------------------
# General procedures
# ------------------------------------------------------------------------------
proc log2ceil {num} {
   set val 0
   set i   1
   while { $i < $num } {
       set val [ expr $val + 1 ]
       set i   [ expr 1 << $val ]
   }

   return $val;
}

proc max { a b } { 
   if { $a > $b } {
       return $a
   } else {
       return $b
   }
}

# ------------------------------------------------------------------------------
# Read all parameters value and set them to global variables
# This implemented the re-initialization of the global variable
# ------------------------------------------------------------------------------
proc read_parameters_value {} {
   # Global variable used
   global inBitsPerSymbol_value
   global inUsePackets_value

   global inDataWidth_value
   global inSymbolsPerBeat_value
   global inMaxChannel_value
   global inChannelWidth_value
   global inErrorWidth_value
   global inErrorDescriptor_value
   global inUseEmptyPort_value
   global inEmptyWidth_value
   global inUseValid_value
   global inUseReady_value
   global inReadyLatency_value

   global outDataWidth_value
   global outSymbolsPerBeat_value
   global outMaxChannel_value
   global outChannelWidth_value
   global outErrorWidth_value
   global outErrorDescriptor_value
   global outUseEmptyPort_value
   global outEmptyWidth_value
   global outUseValid_value
   global outUseReady_value
   global outReadyLatency_value

   # Getting values from the parameter
   set inBitsPerSymbol_value           [get_parameter_value inBitsPerSymbol]
   set inUsePackets_value              [get_parameter_value inUsePackets]

   set inDataWidth_value               [get_parameter_value inDataWidth]
   set inSymbolsPerBeat_value          [expr $inDataWidth_value / $inBitsPerSymbol_value]
   set inMaxChannel_value              [get_parameter_value inMaxChannel]
   set inErrorWidth_value              [get_parameter_value inErrorWidth]
   set inErrorDescriptor_value         [get_parameter_value inErrorDescriptor]
   set inUseEmptyPort_value            [get_parameter_value inUseEmptyPort]
   set inUseValid_value                [get_parameter_value inUseValid]
   set inUseReady_value                [get_parameter_value inUseReady]
   set inReadyLatency_value            [get_parameter_value inReadyLatency]

   set outDataWidth_value              [get_parameter_value outDataWidth]
   set outSymbolsPerBeat_value         [expr $outDataWidth_value / $inBitsPerSymbol_value]
   set outMaxChannel_value             [get_parameter_value outMaxChannel]
   set outErrorWidth_value             [get_parameter_value outErrorWidth]
   set outErrorDescriptor_value        [get_parameter_value outErrorDescriptor]
   set outUseEmptyPort_value           [get_parameter_value outUseEmptyPort]
   set outUseValid_value               [get_parameter_value outUseValid]
   set outUseReady_value               [get_parameter_value outUseReady]
   set outReadyLatency_value           [get_parameter_value outReadyLatency]

   # set_parameter_value inChannelWidth  [log2ceil [expr {$inMaxChannel_value + 1}]]
   # set_parameter_value outChannelWidth [log2ceil [expr {$outMaxChannel_value + 1}]]
   set inChannelWidth_value            [get_parameter_value inChannelWidth]
   set outChannelWidth_value           [get_parameter_value outChannelWidth]

   set_parameter_value inEmptyWidth    [max [log2ceil $inSymbolsPerBeat_value] 1]
   set_parameter_value outEmptyWidth   [max [log2ceil $outSymbolsPerBeat_value] 1]
   set inEmptyWidth_value              [get_parameter_value inEmptyWidth]
   set outEmptyWidth_value             [get_parameter_value outEmptyWidth]
}

# ------------------------------------------------------------------------------
# Apparently it is not possible to query the type of an interface
#  thus all these getters to get the interface of components
# ------------------------------------------------------------------------------
proc get_clock_bridge_in_clock {adapter} {
   return "in_clk"
}
proc get_clock_bridge_out_clock {adapter} {
   return "out_clk"
}
proc get_reset_bridge_in_reset {adapter} {
   return "in_reset"
}
proc get_reset_bridge_out_reset {adapter} {
   return "out_reset"
}
proc get_reset_bridge_in_clock {adapter} {
   return "clk"
}
proc get_adapter_in {adapter} {
   return "in"
}
proc get_adapter_out {adapter} {
   return "out"
}

# ------------------------------------------------------------------------------
# Get unique names for instances
# ------------------------------------------------------------------------------
proc get_instance_unique_name {inst_type {user_prefix ""}} {
   # All prefixes has only alphabetical character
   set inst_prefix(altera_clock_bridge)   clk_bridge
   set inst_prefix(altera_reset_bridge)   rst_bridge
   set inst_prefix(data_format_adapter)   data_format_adapter
   set inst_prefix(channel_adapter)       channel_adapter
   set inst_prefix(error_adapter)         error_adapter
   set inst_prefix(timing_adapter)        timing_adapter
   set prefix ""

   if {![string equal $user_prefix ""]} {
      set prefix $user_prefix
   } elseif {[info exists inst_prefix($inst_type)]} {
      set prefix $inst_prefix($inst_type)
   } else {
      set prefix "other"
      send_message Warning "inst_type has not been registered with a prefix"
   }

   set insts [get_instances]
   set largest_id 0
   set known_id ""
   
   foreach inst $insts {
      if {[regexp "$prefix" "$inst"]} {
         set pieces        [split $inst "_"]
         set pieces_length [llength $pieces]
         set last_piece_id [expr {$pieces_length - 1}]
         set inst_id       [lindex $pieces $last_piece_id]
         set known_id      $inst_id
         if {$inst_id >= $largest_id} {
            set largest_id $inst_id
         }
      }
   }

   if {[string equal $known_id ""]} {
      set next_id 0
   } else {
      set next_id [expr {$largest_id + 1}]
   }
   set unique_name "$prefix\_$next_id"
   
   return $unique_name
}

# ------------------------------------------------------------------------------
# Get unique names for interfaces
# ------------------------------------------------------------------------------
proc get_interface_unique_name {intf_type {user_prefix ""}} {
   # All prefixes has only alphabetical character
   set intf_prefix(clock_sink) in_clk
   set intf_prefix(reset_sink) in_rst
   set intf_prefix(avalon_streaming_sink) in
   set intf_prefix(avalon_streaming_source) out

   if {![string equal $user_prefix ""]} {
      set prefix $user_prefix
   } elseif {[info exists intf_prefix($intf_type)]} {
      set prefix $intf_prefix($intf_type)
   } else {
      set prefix "other"
      send_message Warning "intf_type has not been registered with a prefix"
   }

   set intfs [get_interfaces]
   set largest_id 0
   set known_id ""
   foreach intf $intfs {
      if {[regexp "$prefix" "$intf"]} {
         set pieces        [split $intf "_"]
         set last_piece_id [expr {[llength $pieces] - 1}]
         set intf_id [lindex $pieces $last_piece_id]
         if {$intf_id > $largest_id} {
            set largest_id $intf_id
            set known_id $intf_id
         }
      }
   }

   if {[string equal $known_id ""]} {
      set next_id 0
   } else {
      set next_id [expr {$largest_id + 1}]
   }
   set unique_name "$prefix\_$next_id"

   return $unique_name
}

# ------------------------------------------------------------------------------
# Create clock sink interface and insert clock bridge
# ------------------------------------------------------------------------------
proc create_clock_interface {} {

   set clk_in_intf [get_interface_unique_name clock_sink]
   add_interface $clk_in_intf clock sink

   set clk_bridge_inst [get_instance_unique_name altera_clock_bridge]
   add_instance $clk_bridge_inst altera_clock_bridge

   set clk_bridge_in_clk [get_clock_bridge_in_clock $clk_bridge_inst]
   set_interface_property $clk_in_intf EXPORT_OF $clk_bridge_inst.$clk_bridge_in_clk

   return $clk_in_intf
}

# ------------------------------------------------------------------------------
# Create reset interface and insert reset bridge
# ------------------------------------------------------------------------------
proc create_reset_interface {clk_intf} {

   set rst_in_intf [get_interface_unique_name reset_sink]
   add_interface $rst_in_intf reset sink

   set rst_bridge_inst [get_instance_unique_name altera_reset_bridge]
   add_instance $rst_bridge_inst altera_reset_bridge

   set rst_bridge_in_rst [get_reset_bridge_in_reset $rst_bridge_inst]
   set_interface_property $rst_in_intf EXPORT_OF $rst_bridge_inst.$rst_bridge_in_rst

   set clk_export [get_interface_property $clk_intf EXPORT_OF]
   set clk_bridge_inst [lindex [split $clk_export "."] 0]
   set clk_bridge_out_clk [get_clock_bridge_out_clock $clk_bridge_inst]
   set rst_bridge_in_clk [get_reset_bridge_in_clock $rst_bridge_inst]
   add_connection $clk_bridge_inst.$clk_bridge_out_clk $rst_bridge_inst.$rst_bridge_in_clk

   return $rst_in_intf
}

# ------------------------------------------------------------------------------
# Create an (input) sink interface
# ------------------------------------------------------------------------------
proc create_sink_in_interface {clk_intf rst_intf} {
   set snk_intf [get_interface_unique_name avalon_streaming_sink]
   add_interface $snk_intf avalon_streaming sink
   return $snk_intf
}

# ------------------------------------------------------------------------------
# Create an (output) source interface
# ------------------------------------------------------------------------------
proc create_source_out_interface {clk_intf rst_intf} {
   set src_intf [get_interface_unique_name avalon_streaming_source]
   add_interface $src_intf avalon_streaming source
   return $src_intf
}

# ------------------------------------------------------------------------------
# Check the given inst if it's an exported source-in interface
# ------------------------------------------------------------------------------
proc is_in_interface {in_intf} {
   global connection_chain
   set chain_start [lindex $connection_chain 0]
   if {[string equal $in_intf $chain_start]} {
      return 1
   }
   return 0
}

# ------------------------------------------------------------------------------
# Check the given inst if it's an exported sink-out interface
# ------------------------------------------------------------------------------
proc is_out_interface {out_intf} {
   global connection_chain
   set chain_length [llength $connection_chain]
   set chain_end_id [expr {$chain_length - 1}]
   set chain_end [lindex $connection_chain $chain_end_id]
   if {[string equal $out_intf $chain_end]} {
      return 1
   }
   return 0
}

# ------------------------------------------------------------------------------
# Retrive port width, return 0 if not existing
# ------------------------------------------------------------------------------
proc get_instance_interface_port_width {inst intf port_name} {
   set port_width 0
   set ports [get_instance_interface_ports $inst $intf]
   foreach port $ports {
      if {[string equal $port $port_name]} {
         set port_width [get_instance_port_property $inst $port WIDTH]
         break
      }
   }
   return $port_width
}

# ------------------------------------------------------------------------------
# Retrive port width, return 0 if not existing
# ------------------------------------------------------------------------------
proc instance_interface_port_exists {inst intf port_name} {
   set port_exists 0
   set port_width [get_instance_interface_port_width $inst $intf $port_name]
   if {$port_width > 0} {
      set port_exists 1
   }
   return $port_exists
}

# ------------------------------------------------------------------------------
# A special case for use empty, it is a enum in the individual adapaters
#  thus we need to convert it from boolean
# ------------------------------------------------------------------------------
proc boolean_to_enum_use_empty {use_empty} {
   if {$use_empty} {
      return "YES"
   } else {
      return "NO"
   }
}

# ------------------------------------------------------------------------------
# Parameterize the given instance such that it matches its upstream source
#  if upstream source does not exist, use exported input interface parameters
#  applicable only to none-timing related parameters
# ------------------------------------------------------------------------------
proc match_source_non_timing_parameters {ref_inst affected_inst} {

   global inBitsPerSymbol_value
   global inUsePackets_value
   global inSymbolsPerBeat_value
   global inMaxChannel_value
   global inChannelWidth_value
   global inErrorWidth_value
   global inErrorDescriptor_value
   global inUseEmptyPort_value
   
   # Match against the given inst or the exported interface
   if {![is_in_interface $ref_inst]} {
   
      set ref_intf            [get_adapter_out $ref_inst]      
      set ref_bitsPerSymbol   [get_instance_interface_property $ref_inst $ref_intf dataBitsPerSymbol]
      set ref_maxChannel      [get_instance_interface_property $ref_inst $ref_intf maxChannel]
      set ref_errorDescriptor [get_instance_interface_property $ref_inst $ref_intf errorDescriptor]
      set ref_dataWidth       [get_instance_interface_port_width $ref_inst $ref_intf out_data]
      set ref_channelWidth    [get_instance_interface_port_width $ref_inst $ref_intf out_channel]
      set ref_errorWidth      [get_instance_interface_port_width $ref_inst $ref_intf out_error]
      set ref_usePackets      [instance_interface_port_exists $ref_inst $ref_intf out_startofpacket]
      set ref_useEmptyPort    [instance_interface_port_exists $ref_inst $ref_intf out_empty]
      
      set_instance_parameter $affected_inst inBitsPerSymbol    $ref_bitsPerSymbol
      set_instance_parameter $affected_inst inUsePackets       $ref_usePackets
      set_instance_parameter $affected_inst inSymbolsPerBeat   [expr {$ref_dataWidth / $ref_bitsPerSymbol}]
      set_instance_parameter $affected_inst inMaxChannel       $ref_maxChannel
      set_instance_parameter $affected_inst inChannelWidth     $ref_channelWidth
      set_instance_parameter $affected_inst inErrorWidth       $ref_errorWidth
      set_instance_parameter $affected_inst inErrorDescriptor  $ref_errorDescriptor
      set_instance_parameter $affected_inst inUseEmptyPort     [boolean_to_enum_use_empty $ref_useEmptyPort]
      
   } else {
   
      set_instance_parameter $affected_inst inBitsPerSymbol    $inBitsPerSymbol_value
      set_instance_parameter $affected_inst inUsePackets       $inUsePackets_value
      set_instance_parameter $affected_inst inSymbolsPerBeat   $inSymbolsPerBeat_value
      set_instance_parameter $affected_inst inMaxChannel       $inMaxChannel_value
      set_instance_parameter $affected_inst inChannelWidth     $inChannelWidth_value
      set_instance_parameter $affected_inst inErrorWidth       $inErrorWidth_value
      set_instance_parameter $affected_inst inErrorDescriptor  $inErrorDescriptor_value
      set_instance_parameter $affected_inst inUseEmptyPort     [boolean_to_enum_use_empty $inUseEmptyPort_value]
      
   }
}

# ------------------------------------------------------------------------------
# Parameterize the given instance such that it matches its upstream source
#  if upstream source does not exist, use exported input interface parameters
#  applicable only to timing related parameters
# ------------------------------------------------------------------------------
proc match_source_timing_parameters {ref_inst affected_inst} {
   
   global inUseReady_value
   global inReadyLatency_value

   if {![is_in_interface $ref_inst]} {
   
      set ref_intf         [get_adapter_out $ref_inst]      
      set ref_useReady     [instance_interface_port_exists $ref_inst $ref_intf out_ready]
      set ref_readyLatency [get_instance_interface_property $ref_inst $ref_intf readyLatency]
      
      set_instance_parameter $affected_inst inUseReady      $ref_useReady
      set_instance_parameter $affected_inst inReadyLatency  $ref_readyLatency
      
   } else {
      
      set_instance_parameter $affected_inst inUseReady      $inUseReady_value
      set_instance_parameter $affected_inst inReadyLatency  $inReadyLatency_value
      
   }
}

# ------------------------------------------------------------------------------
# Check if data format adapter is needed
# ------------------------------------------------------------------------------
proc need_data_format_adapter {src_inst snk_inst} {
   
   global inSymbolsPerBeat_value
   global inUseEmptyPort_value
   global outSymbolsPerBeat_value
   global outUseEmptyPort_value
   
   set src_num_symbols   $inSymbolsPerBeat_value
   set src_use_empty     $inUseEmptyPort_value
   set snk_num_symbols   $outSymbolsPerBeat_value
   set snk_use_empty     $outUseEmptyPort_value
   
   if {![is_in_interface $src_inst]} {
      set src_inst_out        [get_adapter_out $src_inst]
      set src_data_width      [get_instance_interface_port_width $src_inst $src_inst_out out_data]
      set src_bits_per_symbol [get_instance_interface_property $src_inst $src_inst_out dataBitsPerSymbol]
      set src_num_symbols     [expr {$src_data_width / $src_bits_per_symbol}]
      set src_use_empty       [instance_interface_port_exists $src_inst $src_inst_out out_empty]
   }
   
   if {![is_out_interface $snk_inst]} {
      set snk_inst_in         [get_adapter_in $snk_inst]
      set snk_data_width      [get_instance_interface_port_width $snk_inst $snk_inst_in in_data]
      set snk_bits_per_symbol [get_instance_interface_property $snk_inst $snk_inst_in dataBitsPerSymbol]
      set snk_num_symbols     [expr {$snk_data_width / $snk_bits_per_symbol}]
      set snk_use_empty       [instance_interface_port_exists $snk_inst $snk_inst_in in_empty]
   }
   
   set num_symbols_mismatch   [expr {$src_num_symbols != $snk_num_symbols}]
   set use_empty_mismatch     [expr {$src_use_empty != $snk_use_empty}]
   set need_adaptation        [expr {$num_symbols_mismatch | $use_empty_mismatch}]
   
   return $need_adaptation
}

# ------------------------------------------------------------------------------
# Inserting data format adapter
# ------------------------------------------------------------------------------
proc insert_data_format_adapter {} {

   global connection_chain
   global inSymbolsPerBeat_value
   global outSymbolsPerBeat_value
   global outUseEmptyPort_value
   global inReadyLatency_value
   
   set chain_end [lindex $connection_chain [expr {[llength $connection_chain] - 1}]]
   set iteration [expr {[llength $connection_chain] - 1}]
   set new_connection_chain ""
   
   for {set i 0} {$i<$iteration} {incr i} {
   
      set src_inst [lindex $connection_chain $i]
      set snk_inst [lindex $connection_chain [expr {$i + 1}]]
      lappend new_connection_chain $src_inst
      
      # The case where inUseEmptyPort=1, outUseEmptyPort=0, inSymbolsPerBeat_value=outSymbolsPerBeat_value>1
      #  is not handled here; the data format adapter itself emits warning
      if {[need_data_format_adapter $src_inst $snk_inst]} {

         set adapter [get_instance_unique_name data_format_adapter]
         add_instance $adapter data_format_adapter
         send_message Info "Inserting data_format_adapter: $adapter"
         lappend new_connection_chain $adapter
         
         match_source_non_timing_parameters $src_inst $adapter
         
         # Adaptation
         if {[string equal $snk_inst $chain_end]} {
            set_instance_parameter $adapter outSymbolsPerBeat  $outSymbolsPerBeat_value
            set_instance_parameter $adapter outUseEmptyPort    [boolean_to_enum_use_empty $outUseEmptyPort_value]
         } else {
            set snk_inst_in      [get_adapter_in $snk_inst]
            set data_width       [get_instance_interface_port_width $snk_inst $snk_inst_in in_data]
            set bits_per_symbol  [get_instance_interface_property $snk_inst $snk_inst_in dataBitsPerSymbol]
            set num_symbols      [expr {$data_width / $bits_per_symbol}]
            set use_empty        [instance_interface_port_exists $snk_inst $snk_inst_in in_empty]
            set_instance_parameter $adapter outSymbolsPerBeat  $num_symbols
            set_instance_parameter $adapter outUseEmptyPort    [boolean_to_enum_use_empty $use_empty]
         }
         
         # Optimization, as in the original transform
         if {$inSymbolsPerBeat_value == $outSymbolsPerBeat_value} {
            set_instance_parameter $adapter inReadyLatency  $inReadyLatency_value
         } else {
            set_instance_parameter $adapter inReadyLatency  0
         }
      }
   }
   
   # Refresh the new connection chain
   lappend new_connection_chain $chain_end
   set connection_chain ""
   foreach chain_item $new_connection_chain {
      lappend connection_chain $chain_item
   }
}

# ------------------------------------------------------------------------------
# Check if channel adapter is needed
# ------------------------------------------------------------------------------
proc need_channel_adapter {src_inst snk_inst} {
   
   global inMaxChannel_value
   global outMaxChannel_value
   global inChannelWidth_value
   global outChannelWidth_value
   
   set src_max_channel $inMaxChannel_value
   set snk_max_channel $outMaxChannel_value
   set src_channel_width $inChannelWidth_value
   set snk_channel_width $outChannelWidth_value
   
   if {![is_in_interface $src_inst]} {
      set src_inst_out        [get_adapter_out $src_inst]
      set src_channel_width   [get_instance_interface_port_width $src_inst $src_inst_out out_channel]
      set src_max_channel     [get_instance_interface_property $src_inst $src_inst_out maxChannel]
   }
   
   if {![is_out_interface $snk_inst]} {
      set snk_intf_in         [get_adapter_in $snk_inst]
      set snk_channel_width   [get_instance_interface_port_width $snk_inst $snk_intf_in in_channel]
      set snk_max_channel     [get_instance_interface_property $snk_inst $snk_intf_in maxChannel]
   }
   
   set max_channel_mismatch   [expr {$src_max_channel != $snk_max_channel}]
   set channel_width_mismatch [expr {$src_channel_width != $snk_channel_width}]
   set need_adaptation        [expr {$max_channel_mismatch | $channel_width_mismatch}]
   
   if {$channel_width_mismatch == 0} {
      if {$src_channel_width == 0} {
         set need_adaptation 0
      }
   }
   
   return $need_adaptation
}

# ------------------------------------------------------------------------------
# Inserting channel adapter
# ------------------------------------------------------------------------------
proc insert_channel_adapter {} {

   global connection_chain
   global outMaxChannel_value
   global outChannelWidth_value

   set chain_end [lindex $connection_chain [expr {[llength $connection_chain] - 1}]]
   set iteration [expr {[llength $connection_chain] - 1}]
   set new_connection_chain ""
   
   for {set i 0} {$i<$iteration} {incr i} {
   
      set src_inst [lindex $connection_chain $i]
      set snk_inst [lindex $connection_chain [expr {$i + 1}]]
      lappend new_connection_chain $src_inst
      
      if {[need_channel_adapter $src_inst $snk_inst]} {

         set adapter [get_instance_unique_name channel_adapter]
         add_instance $adapter channel_adapter
         send_message Info "Inserting channel_adapter: $adapter"
         lappend new_connection_chain $adapter
         
         match_source_non_timing_parameters $src_inst $adapter
         match_source_timing_parameters $src_inst $adapter
         
         # Adaptation
         if {[string equal $snk_inst $chain_end]} {
            set_instance_parameter $adapter outMaxChannel   $outMaxChannel_value
            set_instance_parameter $adapter outChannelWidth $outChannelWidth_value
         } else {
            set snk_inst_in [get_adapter_in $snk_inst]
            set max_channel   [get_instance_interface_property $snk_inst $snk_inst_in maxChannel]
            set channel_width [get_instance_interface_port_width $snk_inst $snk_inst_in in_channel]
            set_instance_parameter $adapter outMaxChannel    $max_channel
            set_instance_parameter $adapter outChannelWidth  $channel_width
         }
      }
   }
   
   # Refresh the new connection chain
   lappend new_connection_chain $chain_end
   set connection_chain ""
   foreach chain_item $new_connection_chain {
      lappend connection_chain $chain_item
   }
}

# ------------------------------------------------------------------------------
# Check if error adapter is needed
# ------------------------------------------------------------------------------
proc need_error_adapter {src_inst snk_inst} {
   
   global inErrorWidth_value
   global inErrorDescriptor_value
   global outErrorWidth_value
   global outErrorDescriptor_value
   
   set src_error_width $inErrorWidth_value
   set snk_error_width $outErrorWidth_value
   set src_err_descr $inErrorDescriptor_value
   set snk_err_descr $outErrorDescriptor_value
   
   if {![is_in_interface $src_inst]} {
      set src_inst_out     [get_adapter_out $src_inst]
      set src_error_width  [get_instance_interface_port_width $src_inst $src_inst_out out_error]
      set src_err_descr    [get_instance_interface_property $src_inst $src_inst_out errorDescriptor]
   }
   
   if {![is_out_interface $snk_inst]} {
      set snk_inst_in      [get_adapter_in $snk_inst]
      set snk_error_width  [get_instance_interface_port_width $snk_inst $snk_inst_in in_error]
      set snk_err_descr    [get_instance_interface_property $snk_inst $snk_inst_in errorDescriptor]
   }
   
   # There's no need to compare errorWidth, it seems
   set error_width_mismatch [expr {$src_error_width != $snk_error_width}]
   set err_descr_mismatch 0
   set src_err_descr_length [llength $src_err_descr]
   set snk_err_descr_length [llength $snk_err_descr]
   if {$src_err_descr_length == $snk_err_descr_length} {
      for {set i 0} {$i<$src_err_descr_length} {incr i} {
         set src_descr_i [lindex $src_err_descr $i]
         set snk_descr_i [lindex $snk_err_descr $i]
         if {![string equal $src_descr_i $snk_descr_i]} {
            set err_descr_mismatch 1
            break
         }
      }
   } else {
      set err_descr_mismatch 1
   }
   
   set need_adaptation [expr {$error_width_mismatch | $err_descr_mismatch}]
   
   if {!$error_width_mismatch} {
      set only_one_side_has_descriptor 0
      set snk_has_other 0
      if {$src_err_descr_length == 0 && $snk_err_descr_length != 0} {
         set only_one_side_has_descriptor 1
         for {set i 0} {$i<$snk_err_descr_length} {incr i} {
            set snk_descr_i [lindex $snk_err_descr $i]
            if {[string equal "other" $snk_descr_i]} {
               set snk_has_other 1
               break
            }
         }
      }
      if {$src_err_descr_length != 0 && $snk_err_descr_length == 0} {
         set only_one_side_has_descriptor 1
      }
      if {$only_one_side_has_descriptor == 1 && $snk_has_other == 0} {
         set need_adaptation 0
      }
   }
   
   return $need_adaptation
}

# ------------------------------------------------------------------------------
# Inserting error adapter
# ------------------------------------------------------------------------------
proc insert_error_adapter {} {

   global connection_chain
   global outErrorWidth_value
   global outErrorDescriptor_value
   
   set chain_end [lindex $connection_chain [expr {[llength $connection_chain] - 1}]]
   set iteration [expr {[llength $connection_chain] - 1}]
   set new_connection_chain ""
   
   for {set i 0} {$i<$iteration} {incr i} {
   
      set src_inst [lindex $connection_chain $i]
      set snk_inst [lindex $connection_chain [expr {$i + 1}]]
      lappend new_connection_chain $src_inst
      
      if {[need_error_adapter $src_inst $snk_inst]} {

         set adapter [get_instance_unique_name error_adapter]
         add_instance $adapter error_adapter
         send_message Info "Inserting error_adapter: $adapter"
         lappend new_connection_chain $adapter
         
         match_source_non_timing_parameters $src_inst $adapter
         match_source_timing_parameters $src_inst $adapter
         
         # Adaptation
         if {[string equal $snk_inst $chain_end]} {
            set_instance_parameter $adapter outErrorWidth      $outErrorWidth_value
            set_instance_parameter $adapter outErrorDescriptor $outErrorDescriptor_value
         } else {
            set snk_inst_in [get_adapter_in $snk_inst]
            set error_width [get_instance_interface_port_width $snk_inst $snk_inst_in in_error]
            set error_descr [get_instance_interface_property $snk_inst $snk_inst_in errorDescriptor]
            set_instance_parameter $adapter outErrorWidth      $error_width
            set_instance_parameter $adapter outErrorDescriptor $error_descr
         }
      }
   }
   
   # Refresh the new connection chain
   lappend new_connection_chain $chain_end
   set connection_chain ""
   foreach chain_item $new_connection_chain {
      lappend connection_chain $chain_item
   }
}

# ------------------------------------------------------------------------------
# Check if error adapter is needed
# ------------------------------------------------------------------------------
proc need_timing_adapter {src_inst snk_inst} {
   
   global inUseValid_value
   global inUseReady_value
   global inReadyLatency_value
   global outUseValid_value
   global outUseReady_value
   global outReadyLatency_value
   
   set src_use_valid       $inUseValid_value
   set src_use_ready       $inUseReady_value
   set src_ready_latency   $inReadyLatency_value
   set snk_use_valid       $outUseValid_value
   set snk_use_ready       $outUseReady_value
   set snk_ready_latency   $outReadyLatency_value
   
   if {![is_in_interface $src_inst]} {
      set src_inst_out        [get_adapter_out $src_inst]
      set src_use_valid       [get_instance_interface_port_width $src_inst $src_inst_out out_valid]
      set src_use_ready       [get_instance_interface_port_width $src_inst $src_inst_out out_ready]
      set src_ready_latency   [get_instance_interface_property $src_inst $src_inst_out readyLatency]
   }
   
   if {![is_out_interface $snk_inst]} {
      set snk_inst_in         [get_adapter_in $snk_inst]
      set snk_use_valid       [get_instance_interface_port_width $snk_inst $snk_inst_in in_valid]
      set snk_use_ready       [get_instance_interface_port_width $snk_inst $snk_inst_in in_ready]
      set snk_ready_latency   [get_instance_interface_property $snk_inst $snk_inst_in readyLatency]
   }
   
   set use_valid_mismatch     [expr {$src_use_valid != $snk_use_valid}]
   set use_ready_mismatch     [expr {$src_use_ready != $snk_use_ready}]
   set ready_latency_mismatch [expr {$src_ready_latency != $snk_ready_latency}]
   
   set need_adaptation [expr {$use_valid_mismatch | $use_ready_mismatch | $ready_latency_mismatch}]
   
   return $need_adaptation
}

# ------------------------------------------------------------------------------
# Inserting timing adapter
# ------------------------------------------------------------------------------
proc insert_timing_adapter {} {

   global connection_chain
   global inUseValid_value
   global outUseValid_value
   global outUseReady_value
   global outReadyLatency_value
   
   set chain_start   [lindex $connection_chain 0]
   set chain_end     [lindex $connection_chain [expr {[llength $connection_chain] - 1}]]
   set iteration [expr {[llength $connection_chain] - 1}]
   set new_connection_chain ""
   
   for {set i 0} {$i<$iteration} {incr i} {
   
      set src_inst [lindex $connection_chain $i]
      set snk_inst [lindex $connection_chain [expr {$i + 1}]]
      lappend new_connection_chain $src_inst
      
      if {[need_timing_adapter $src_inst $snk_inst]} {

         set adapter [get_instance_unique_name timing_adapter]
         add_instance $adapter timing_adapter
         send_message Info "Inserting timing_adapter: $adapter"
         lappend new_connection_chain $adapter
         
         match_source_non_timing_parameters $src_inst $adapter
         match_source_timing_parameters $src_inst $adapter
         
         # Adaptation
         if {[string equal $src_inst $chain_start]} {
            set_instance_parameter $adapter inUseValid $inUseValid_value
         } else {
            set src_inst_out  [get_adapter_out $src_inst]
            set use_valid     [get_instance_interface_port_width $src_inst $src_inst_out out_valid]
            set_instance_parameter $adapter inUseValid $use_valid
         }
         
         if {[string equal $snk_inst $chain_end]} {
            set_instance_parameter $adapter outUseValid     $outUseValid_value
            set_instance_parameter $adapter outUseReady     $outUseReady_value
            set_instance_parameter $adapter outReadyLatency $outReadyLatency_value
         } else {
            set snk_inst_in   [get_adapter_in $snk_inst]
            set use_valid     [get_instance_interface_port_width $snk_inst $snk_inst_in in_valid]
            set use_ready     [get_instance_interface_port_width $snk_inst $snk_inst_in in_ready]
            set ready_latency [get_instance_interface_property $snk_inst $snk_inst_in readyLatency]
            set_instance_parameter $adapter outUseValid     $use_valid
            set_instance_parameter $adapter outUseReady     $use_ready
            set_instance_parameter $adapter outReadyLatency $ready_latency
         }
      }
   }
   
   # Refresh the new connection chain
   lappend new_connection_chain $chain_end
   set connection_chain ""
   foreach chain_item $new_connection_chain {
      lappend connection_chain $chain_item
   }
}

# ------------------------------------------------------------------------------
# Check if pass_through bridge is needed
# ------------------------------------------------------------------------------
proc need_pass_through_bridge {} {
   global connection_chain
   return [expr {[llength $connection_chain] == 2}]
}

# ------------------------------------------------------------------------------
# Inserting a pass through bridge if there's no adaptation needed
# ------------------------------------------------------------------------------
proc insert_pass_through_bridge {} {

   global connection_chain
   global outMaxChannel_value
   global outChannelWidth_value
   
   
   if {[need_pass_through_bridge]} {
      
      send_message Warning "No adaptation is needed; a pass through bridge is inserted"
      
      set chain_start   [lindex $connection_chain 0]
      set chain_end     [lindex $connection_chain [expr {[llength $connection_chain] - 1}]]
      set new_connection_chain ""
      lappend new_connection_chain $chain_start
      
      set adapter [get_instance_unique_name channel_adapter pass_through]
      add_instance $adapter channel_adapter
      send_message Info "Inserting channel_adapter: $adapter"
      lappend new_connection_chain $adapter
      
      match_source_non_timing_parameters $chain_start $adapter
      match_source_timing_parameters $chain_start $adapter
      
      # Adaptation... but it's the same
      set_instance_parameter $adapter outChannelWidth $outChannelWidth_value
      set_instance_parameter $adapter outMaxChannel   $outMaxChannel_value
      
      # Refresh the new connection chain
      lappend new_connection_chain $chain_end
      set connection_chain ""
      foreach chain_item $new_connection_chain {
         lappend connection_chain $chain_item
      }
   }
   
}

# ------------------------------------------------------------------------------
# Connect all adapters
# ------------------------------------------------------------------------------
proc connect_adapters {} {

   global connection_chain
   
   set chain_start   [lindex $connection_chain 0]
   set chain_end     [lindex $connection_chain [expr {[llength $connection_chain] - 1}]]
   
   if {[llength $connection_chain] <= 2} {
      send_message Error "There was no adaptation at all"
      return ""
   }
   
   for {set i 0} {$i <= [expr {[llength $connection_chain] - 2}]} {incr i} {
   
      set src_inst   [lindex $connection_chain $i]
      set snk_inst   [lindex $connection_chain [expr {$i + 1}]]
      
      if {[string equal $src_inst $chain_start]} {
      
         # First adapter to export to in interface
         set snk_inst_in [get_adapter_in $snk_inst]
         set_interface_property $src_inst EXPORT_OF "$snk_inst.$snk_inst_in"
         
      } elseif {[string equal $snk_inst $chain_end]} {
      
         # Last adapter to export to out interface
         set src_inst_out [get_adapter_out $src_inst]
         set_interface_property $snk_inst EXPORT_OF "$src_inst.$src_inst_out"
         
      } else {
      
         set src_inst_out [get_adapter_out $src_inst]
         set snk_inst_in [get_adapter_in $snk_inst]
         add_connection "$src_inst.$src_inst_out" "$snk_inst.$snk_inst_in"
         
      }
      
   }
}

# ------------------------------------------------------------------------------
# Connect all adapters with a clock and a reset source
# ------------------------------------------------------------------------------
proc connect_adapters_clock_and_reset {clk_intf rst_intf in_intf out_intf} {

   global connection_chain
   
   set in_intf_export [get_interface_property $in_intf EXPORT_OF]

   for {set i 1} {$i <= [expr {[llength $connection_chain] - 2}]} {incr i} {
      set adapter          [lindex $connection_chain $i]
      set adapter_in       [get_adapter_in $adapter]
      set adapter_in_clk   [get_instance_interface_property $adapter $adapter_in associatedClock]
      set adapter_in_rst   [get_instance_interface_property $adapter $adapter_in associatedReset]

      if {[string equal $in_intf_export "$adapter.$adapter_in"]} {
         
         # This is the first adapter, connect to the clock bridge directly
         set clk_export       [get_interface_property $clk_intf EXPORT_OF]
         set reset_export     [get_interface_property $rst_intf EXPORT_OF]
         set clk_inst         [lindex [split $clk_export "."] 0]
         set rst_inst         [lindex [split $reset_export "."] 0]
         set clk_inst_out_clk [get_clock_bridge_out_clock $clk_inst]
         set rst_inst_out_rst [get_reset_bridge_out_reset $rst_inst]
         set clk_start        "$clk_inst.$clk_inst_out_clk"
         set reset_start      "$rst_inst.$rst_inst_out_rst"
         set clk_end          "$adapter.$adapter_in_clk"
         set reset_end        "$adapter.$adapter_in_rst"
         add_connection $clk_start $clk_end
         add_connection $reset_start $reset_end

      } else {
      
         # This is for subsequent adapters, connect according to upstream source
         set upstream_adapter       [lindex $connection_chain [expr {$i - 1}]]
         set upstream_adapter_out   [get_adapter_out $upstream_adapter]
         set upstream_adapter_clk   [get_instance_interface_property $upstream_adapter $upstream_adapter_out associatedClock]
         set upstream_adapter_rst   [get_instance_interface_property $upstream_adapter $upstream_adapter_out associatedReset]
         
         # Always assume associatedClock is of type clock sink
         #  because we cannot query if a clock is source or sink
         set connections [get_connections]
         set clk_start ""
         set rst_start ""
         
         foreach connection $connections {
         
            set start_point   [lindex [split $connection "/"] 0]
            set end_point     [lindex [split $connection "/"] 1]
            
            # Found the clock source
            if {[string equal $end_point "$upstream_adapter.$upstream_adapter_clk"]} {
               set clk_start $start_point
               add_connection $clk_start "$adapter.$adapter_in_clk"
            }
            
            # Found the reset source
            if {[string equal $end_point "$upstream_adapter.$upstream_adapter_rst"]} {
               set rst_start $start_point
               add_connection $rst_start "$adapter.$adapter_in_rst"
            }
            
            # Found both, so break away from the loop
            if {![string equal $clk_start ""] && ![string equal $rst_start ""]} {
               break
            }
            
         }
         
         if {[string equal $clk_start ""]} {
            send_message Warning "No clock connection for $adapter $adapter_in_clk"
         }
         if {[string equal $rst_start ""]} {
            send_message Warning "No reset connection for $adapter $adapter_in_rst"
         }
      }
   }
}

# ------------------------------------------------------------------------------
# Construct the adapter
# ------------------------------------------------------------------------------
proc composed {} {

   # Always reset any global variables
   global connection_chain
   set connection_chain ""
   
   read_parameters_value

   # Create interfaces and bridges before the adaptation
   set clk_intf   [create_clock_interface]
   set rst_intf   [create_reset_interface $clk_intf]
   set in_intf    [create_sink_in_interface $clk_intf $rst_intf]
   set out_intf   [create_source_out_interface $clk_intf $rst_intf]
   
   # Initial connection chain
   lappend connection_chain $in_intf
   lappend connection_chain $out_intf

   # Inserting the adapters one by one
   insert_data_format_adapter
   insert_channel_adapter
   insert_error_adapter
   insert_timing_adapter
   insert_pass_through_bridge
   
   connect_adapters
   connect_adapters_clock_and_reset $clk_intf $rst_intf $in_intf $out_intf 
   
}
