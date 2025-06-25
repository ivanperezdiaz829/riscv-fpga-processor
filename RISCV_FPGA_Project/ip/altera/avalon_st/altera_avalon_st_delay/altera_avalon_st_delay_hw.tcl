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


# $File: //acds/rel/13.1/ip/avalon_st/altera_avalon_st_delay/altera_avalon_st_delay_hw.tcl $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
#------------------------------------------------------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_st_delay
# | 
set_module_property NAME altera_avalon_st_delay
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Bridges and Adapters/Streaming"
set_module_property DISPLAY_NAME "Avalon-ST Delay"
set_module_property DESCRIPTION "Avalon-ST Delay"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_st_delay.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_st_delay
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_st_delay.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter NUMBER_OF_DELAY_CLOCKS INTEGER 1
set_parameter_property NUMBER_OF_DELAY_CLOCKS DISPLAY_NAME NUMBER_OF_DELAY_CLOCKS
set_parameter_property NUMBER_OF_DELAY_CLOCKS UNITS None
set_parameter_property NUMBER_OF_DELAY_CLOCKS ALLOWED_RANGES 0:16
set_parameter_property NUMBER_OF_DELAY_CLOCKS DISPLAY_HINT ""
set_parameter_property NUMBER_OF_DELAY_CLOCKS AFFECTS_ELABORATION true
set_parameter_property NUMBER_OF_DELAY_CLOCKS AFFECTS_GENERATION false
set_parameter_property NUMBER_OF_DELAY_CLOCKS IS_HDL_PARAMETER true

add_parameter DATA_WIDTH INTEGER 8
set_parameter_property DATA_WIDTH DISPLAY_NAME DATA_WIDTH
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH ALLOWED_RANGES 1:512
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH IS_HDL_PARAMETER true

add_parameter BITS_PER_SYMBOL INTEGER 8
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME BITS_PER_SYMBOL
set_parameter_property BITS_PER_SYMBOL UNITS None
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES 1:512
set_parameter_property BITS_PER_SYMBOL DISPLAY_HINT ""
set_parameter_property BITS_PER_SYMBOL AFFECTS_ELABORATION true
set_parameter_property BITS_PER_SYMBOL AFFECTS_GENERATION false
set_parameter_property BITS_PER_SYMBOL IS_HDL_PARAMETER true

add_parameter USE_PACKETS INTEGER 0
set_parameter_property USE_PACKETS DISPLAY_NAME USE_PACKETS
set_parameter_property USE_PACKETS UNITS None
set_parameter_property USE_PACKETS DISPLAY_HINT boolean
set_parameter_property USE_PACKETS AFFECTS_ELABORATION true
set_parameter_property USE_PACKETS AFFECTS_GENERATION false
set_parameter_property USE_PACKETS IS_HDL_PARAMETER true

add_parameter USE_CHANNEL INTEGER 0
set_parameter_property USE_CHANNEL DISPLAY_NAME USE_CHANNEL
set_parameter_property USE_CHANNEL UNITS None
set_parameter_property USE_CHANNEL DISPLAY_HINT boolean
set_parameter_property USE_CHANNEL AFFECTS_ELABORATION true
set_parameter_property USE_CHANNEL AFFECTS_GENERATION false
set_parameter_property USE_CHANNEL IS_HDL_PARAMETER true

add_parameter CHANNEL_WIDTH INTEGER 1
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME CHANNEL_WIDTH
set_parameter_property CHANNEL_WIDTH UNITS None
set_parameter_property CHANNEL_WIDTH DISPLAY_HINT ""
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH AFFECTS_GENERATION false
set_parameter_property CHANNEL_WIDTH IS_HDL_PARAMETER true

add_parameter MAX_CHANNELS INTEGER 1
set_parameter_property MAX_CHANNELS DISPLAY_NAME MAX_CHANNELS
set_parameter_property MAX_CHANNELS UNITS None
set_parameter_property MAX_CHANNELS DISPLAY_HINT ""
set_parameter_property MAX_CHANNELS AFFECTS_ELABORATION true
set_parameter_property MAX_CHANNELS AFFECTS_GENERATION false
set_parameter_property MAX_CHANNELS IS_HDL_PARAMETER false

add_parameter USE_ERROR INTEGER 0
set_parameter_property USE_ERROR DISPLAY_NAME USE_ERROR
set_parameter_property USE_ERROR UNITS None
set_parameter_property USE_ERROR DISPLAY_HINT boolean
set_parameter_property USE_ERROR AFFECTS_ELABORATION true
set_parameter_property USE_ERROR AFFECTS_GENERATION false
set_parameter_property USE_ERROR IS_HDL_PARAMETER true

add_parameter ERROR_WIDTH INTEGER 1
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER true
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point in
# |
add_interface in avalon_streaming end
set_interface_property in errorDescriptor ""
set_interface_property in readyLatency 0

set_interface_property in ASSOCIATED_CLOCK clk

add_interface_port in in0_valid valid Input 1
add_interface_port in in0_startofpacket startofpacket Input 1
add_interface_port in in0_endofpacket endofpacket Input 1
# |
# +-----------------------------------


# +-----------------------------------
# | connection point out
# |
add_interface out avalon_streaming start
set_interface_property out errorDescriptor ""
set_interface_property out maxChannel 0
set_interface_property out readyLatency 0

set_interface_property out ASSOCIATED_CLOCK clk

add_interface_port out out0_valid valid Output 1
add_interface_port out out0_startofpacket startofpacket Output 1
add_interface_port out out0_endofpacket endofpacket Output 1
# |
# +-----------------------------------


# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end

set_interface_property clk ENABLED true

add_interface_port clk reset_n reset_n Input 1
add_interface_port clk clk clk Input 1
# | 
# +-----------------------------------


proc elaborate {} {

   set use_packets_value      [get_parameter_value USE_PACKETS]

   set use_channel_value      [get_parameter_value USE_CHANNEL]
   set channel_width_value    [get_parameter_value CHANNEL_WIDTH]
   set max_channel_value      [get_parameter_value MAX_CHANNELS]

   set use_error_value        [get_parameter_value USE_ERROR]
   set error_width_value      [get_parameter_value ERROR_WIDTH]

   set data_width_value       [get_parameter_value DATA_WIDTH]
   set bits_per_symbol_value  [get_parameter_value BITS_PER_SYMBOL]
   set symbols_per_beat_value [expr $data_width_value / $bits_per_symbol_value]

   if {$symbols_per_beat_value > 1} {
      set empty_width_value 1
   } else {
      set empty_width_value 1
   }
   if {$symbols_per_beat_value > 2} {
      set empty_width_value 2
   }
   if {$symbols_per_beat_value > 4} {
      set empty_width_value 3
   }
   if {$symbols_per_beat_value > 8} {
      set empty_width_value 4
   }
   if {$symbols_per_beat_value > 16} {
      set empty_width_value 5
   }
   if {$symbols_per_beat_value > 32} {
      set empty_width_value 6
   }
   if {$symbols_per_beat_value > 64} {
      set empty_width_value 7
   } 
   if {$symbols_per_beat_value > 128} {
      set empty_width_value 8
   } 
	

   # Set Port Widths
   set_interface_property in symbolsPerBeat $symbols_per_beat_value
   set_interface_property in dataBitsPerSymbol $bits_per_symbol_value
   add_interface_port in in0_data data Input $data_width_value

   set_interface_property out symbolsPerBeat $symbols_per_beat_value
   set_interface_property out dataBitsPerSymbol $bits_per_symbol_value
   add_interface_port out out0_data data Output $data_width_value
	

   # Enable/Disable Interfaces
   set_interface_property in ENABLED true
   set_interface_property out ENABLED true


   # Terminate Unused Ports
   if { $use_packets_value == 0 } {
      add_interface_port in in0_empty empty Input 1
      set_port_property in0_startofpacket TERMINATION 1
      set_port_property in0_startofpacket TERMINATION_VALUE 1'b0
      set_port_property in0_endofpacket TERMINATION 1
      set_port_property in0_endofpacket TERMINATION_VALUE 1'b0
      set_port_property in0_empty TERMINATION 1
      set_port_property in0_empty TERMINATION_VALUE 0

      add_interface_port out out0_empty empty Output 1
      set_port_property out0_startofpacket TERMINATION 1
      set_port_property out0_endofpacket TERMINATION 1
      set_port_property out0_empty TERMINATION 1

   } else {
      add_interface_port in in0_empty empty Input $empty_width_value
      add_interface_port out out0_empty empty Output $empty_width_value

   }

   if { $use_channel_value == 0 } {
      add_interface_port in in0_channel channel Input 1 
      set_interface_property in maxChannel 0
      set_port_property in0_channel TERMINATION 1
      set_port_property in0_channel TERMINATION_VALUE 0

      add_interface_port out out0_channel channel Output 1
      set_interface_property out maxChannel 0
      set_port_property out0_channel TERMINATION 1

   } else {
      if { $channel_width_value == 0 } {
         add_interface_port in in0_channel channel Input 1 
         set_interface_property in maxChannel 0
         set_port_property in0_channel TERMINATION 1
         set_port_property in0_channel TERMINATION_VALUE 0

         add_interface_port out out0_channel channel Output 1
         set_interface_property out maxChannel 0
         set_port_property out0_channel TERMINATION 1

      } else {
         add_interface_port in in0_channel channel Input $channel_width_value
         set_interface_property in maxChannel $max_channel_value

         add_interface_port out out0_channel channel Output $channel_width_value
         set_interface_property out maxChannel $max_channel_value

      }
   }

   if { $use_error_value == 0 } {
      add_interface_port in in0_error error Input 1
      set_port_property in0_error TERMINATION 1
      set_port_property in0_error TERMINATION_VALUE 0

      add_interface_port out out0_error error Output 1
      set_port_property out0_error TERMINATION 1

   } else {
      if { $error_width_value == 0 } {
         add_interface_port in in0_error error Input 1
         set_port_property in0_error TERMINATION 1
         set_port_property in0_error TERMINATION_VALUE 0

         add_interface_port out out0_error error Output 1
         set_port_property out0_error TERMINATION 1

      } else {
         add_interface_port in in0_error error Input $error_width_value
         add_interface_port out out0_error error Output $error_width_value

      }
   }

}

