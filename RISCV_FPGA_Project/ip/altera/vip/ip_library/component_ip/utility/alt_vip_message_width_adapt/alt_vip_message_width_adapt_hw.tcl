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


source ../../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../../common_tcl/alt_vip_files_common_hw.tcl
source ../../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../../common_tcl/alt_vip_interfaces_common_hw.tcl

# |
# +-----------------------------------

# +-----------------------------------
# | module alt_vip_message_width_adapt
# |
declare_general_component_info

set_module_property NAME alt_vip_message_width_adapt
set_module_property DISPLAY_NAME "Avalon-ST Message Width Adapter"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_message_width_adapt.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_message_width_adapt
set_module_property ELABORATION_CALLBACK adapt_elaboration_callback
set_module_property VALIDATION_CALLBACK adapt_validation_callback

# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file src_hdl/alt_vip_message_width_adapt.sv $add_file_attribute
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |

add_parameter IS_CMD_RESP INTEGER 1
set_parameter_property IS_CMD_RESP DISPLAY_NAME "Command/response interface"
set_parameter_property IS_CMD_RESP ALLOWED_RANGES 0:1
set_parameter_property IS_CMD_RESP DISPLAY_HINT boolean
set_parameter_property IS_CMD_RESP AFFECTS_ELABORATION true
set_parameter_property IS_CMD_RESP HDL_PARAMETER true

add_parameter ELEMENT_WIDTH_IN INTEGER 32
set_parameter_property ELEMENT_WIDTH_IN DISPLAY_NAME "Input pixel width"
set_parameter_property ELEMENT_WIDTH_IN AFFECTS_ELABORATION true
set_parameter_property ELEMENT_WIDTH_IN HDL_PARAMETER true

add_parameter ELEMENT_WIDTH_OUT INTEGER 32
set_parameter_property ELEMENT_WIDTH_OUT DISPLAY_NAME "Output pixel width"
set_parameter_property ELEMENT_WIDTH_OUT AFFECTS_ELABORATION true
set_parameter_property ELEMENT_WIDTH_OUT HDL_PARAMETER true

add_parameter ELEMENTS_IN_PAR INTEGER 1
set_parameter_property ELEMENTS_IN_PAR DISPLAY_NAME "Arguments/Pixels in parallel"
set_parameter_property ELEMENTS_IN_PAR AFFECTS_ELABORATION true
set_parameter_property ELEMENTS_IN_PAR HDL_PARAMETER true

add_av_st_event_parameters IN
add_av_st_event_user_width_parameter IN
add_av_st_event_parameters OUT
add_av_st_event_user_width_parameter OUT

# | connection point main_clock
add_main_clock_port

proc adapt_validation_callback {} {
   set in_user_width                [get_parameter_value IN_USER_WIDTH]
   set out_user_width               [get_parameter_value OUT_USER_WIDTH]
   set symbols                      [get_parameter_value ELEMENTS_IN_PAR]
   if { $symbols > 1 } {
      if { $in_user_width > 0 } {
         send_message Error "The input user width must be zero for command/response interfaces and interfaces with multiple elements in parallel"
      }
      if { $out_user_width > 0 } {
         send_message Error "The output user width must be zero for command/response interfaces and interfaces with multiple elements in parallel"
      }
   } else {
      if {[get_parameter_value IS_CMD_RESP] > 0} {
         if { $in_user_width > 0 } {
            send_message Error "The input user width must be zero for command/response interfaces and interfaces with multiple elements in parallel"
         }
         if { $out_user_width > 0 } {
            send_message Error "The output user width must be zero for command/response interfaces and interfaces with multiple elements in parallel"
         }
      }
   }
}

# | Dynamic ports (elaboration callback)
proc adapt_elaboration_callback {} {

   set src_width                   [get_parameter_value IN_SRC_WIDTH]
 	set dst_width                   [get_parameter_value IN_DST_WIDTH]
 	set context_width               [get_parameter_value IN_CONTEXT_WIDTH]
 	set task_width                  [get_parameter_value IN_TASK_WIDTH]
   set user_width                  [get_parameter_value IN_USER_WIDTH]
   set symbols                     [get_parameter_value ELEMENTS_IN_PAR]
   set element_width               [get_parameter_value ELEMENT_WIDTH_IN]
   if {[get_parameter_value IS_CMD_RESP] > 0} {
      add_av_st_cmd_sink_port   av_st_din   $symbols   $dst_width   $src_width   $task_width   $context_width   main_clock
   } else {
      add_av_st_data_sink_port  av_st_din   $element_width   $symbols   $dst_width   $src_width   $task_width   $context_width   $user_width   main_clock
   }

   set src_width                   [get_parameter_value OUT_SRC_WIDTH]
 	set dst_width                   [get_parameter_value OUT_DST_WIDTH]
 	set context_width               [get_parameter_value OUT_CONTEXT_WIDTH]
 	set task_width                  [get_parameter_value OUT_TASK_WIDTH]
   set user_width                  [get_parameter_value OUT_USER_WIDTH]
   set element_width               [get_parameter_value ELEMENT_WIDTH_OUT]
   if {[get_parameter_value IS_CMD_RESP] > 0} {
      add_av_st_cmd_source_port    av_st_dout  $symbols   $dst_width   $src_width   $task_width   $context_width   main_clock
   } else {
      add_av_st_data_source_port   av_st_dout  $element_width   $symbols   $dst_width   $src_width   $task_width   $context_width   $user_width   main_clock
   }

}
