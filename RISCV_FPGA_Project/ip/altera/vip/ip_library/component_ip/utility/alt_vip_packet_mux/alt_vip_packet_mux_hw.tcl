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


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General information for the packet_mux module                                                --
# -- This block sinks Avalon-ST packets from up to 16 independent sources, reading one of them,   --
# -- whilst holding off the other(s) if necessary.                                                --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Common module properties for VIP components
declare_general_component_info

# Component specific properties
set_module_property NAME alt_vip_packet_mux
set_module_property DISPLAY_NAME "Packet Mux"
set_module_property Description  "Mux up to 16 incoming streams of Avalon-ST packets"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_packet_mux.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_packet_mux

set_module_property ELABORATION_CALLBACK mux_elaboration_callback
set_module_property VALIDATION_CALLBACK mux_validation_callback



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file src_hdl/alt_vip_packet_mux.sv $add_file_attribute


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

add_data_width_parameters

add_parameter NUM_INPUTS INTEGER 2
set_parameter_property NUM_INPUTS DISPLAY_NAME "Number of inputs"
set_parameter_property NUM_INPUTS ALLOWED_RANGES 2:16
set_parameter_property NUM_INPUTS AFFECTS_ELABORATION  true
set_parameter_property NUM_INPUTS HDL_PARAMETER true

add_parameter REGISTER_OUTPUT INTEGER 0
set_parameter_property REGISTER_OUTPUT DISPLAY_NAME "Register dout"
set_parameter_property REGISTER_OUTPUT ALLOWED_RANGES 0:1
set_parameter_property REGISTER_OUTPUT DISPLAY_HINT boolean
set_parameter_property REGISTER_OUTPUT HDL_PARAMETER true

add_parameter PIPELINE_READY INTEGER 0
set_parameter_property PIPELINE_READY DISPLAY_NAME "Pipeline dout ready"
set_parameter_property PIPELINE_READY ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_READY DISPLAY_HINT boolean
set_parameter_property PIPELINE_READY HDL_PARAMETER true

add_parameter NAME string "undefined"
set_parameter_property NAME     DISPLAY_NAME        "Name"
set_parameter_property NAME     DISPLAY_HINT        string
set_parameter_property NAME     AFFECTS_ELABORATION false
set_parameter_property NAME     HDL_PARAMETER       true

# Add parameters for the data and command Avalon-ST message ports
add_av_st_event_parameters

add_av_st_event_user_width_parameter



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
# The main clock and associated reset
add_main_clock_port

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc mux_elaboration_callback {} {
   set data_width          [get_parameter_value DATA_WIDTH]
   set d_src_width         [get_parameter_value SRC_WIDTH]
   set d_dst_width         [get_parameter_value DST_WIDTH]
   set d_context_width     [get_parameter_value CONTEXT_WIDTH]
   set d_task_width        [get_parameter_value TASK_WIDTH]
   set d_user_width        [get_parameter_value USER_WIDTH]
   set d_control_width     [expr $d_src_width + $d_dst_width + $d_context_width + $d_task_width + $d_user_width]
   
   #add the command port
   add_av_st_cmd_sink_port   av_st_cmd   1   $d_dst_width   $d_src_width   $d_task_width   $d_context_width   main_clock   0

   set num_inputs          [get_parameter_value NUM_INPUTS]
   for { set i 0 } { $i < $num_inputs } { incr i } {
      add_interface av_st_din_$i avalon_streaming sink
      set_interface_property av_st_din_$i readyLatency 0
      set_interface_property av_st_din_$i ASSOCIATED_CLOCK main_clock
      set_interface_property av_st_din_$i ENABLED true

      add_interface_port av_st_din_$i av_st_din_valid_$i         valid         Input  1
      add_interface_port av_st_din_$i av_st_din_ready_$i         ready         Output 1
      add_interface_port av_st_din_$i av_st_din_startofpacket_$i startofpacket Input  1
      add_interface_port av_st_din_$i av_st_din_endofpacket_$i   endofpacket   Input  1
      add_interface_port av_st_din_$i av_st_din_data_$i          data          Input  [expr {$d_control_width + $data_width}]

      set_port_property av_st_din_ready_$i         FRAGMENT_LIST "av_st_din_ready@$i"
      set_port_property av_st_din_valid_$i         FRAGMENT_LIST "av_st_din_valid@$i"
      set_port_property av_st_din_startofpacket_$i FRAGMENT_LIST "av_st_din_startofpacket@$i"
      set_port_property av_st_din_endofpacket_$i   FRAGMENT_LIST "av_st_din_endofpacket@$i"
      set_port_property av_st_din_data_$i          FRAGMENT_LIST "av_st_din_data@[expr ($i+1)*($d_control_width+$data_width) - 1]:[expr $i*($d_control_width+$data_width)]"

      altera_pe_message_format::set_message_property          av_st_din_$i                  PEID             0
      altera_pe_message_format::set_message_subfield_property av_st_din_$i argument         SYMBOLS_PER_BEAT 1
      altera_pe_message_format::set_message_subfield_property av_st_din_$i argument         SYMBOL_WIDTH     $data_width
      altera_pe_message_format::set_message_subfield_property av_st_din_$i destination      BASE            0
      altera_pe_message_format::set_message_subfield_property av_st_din_$i destination      SYMBOL_WIDTH    $d_dst_width
      altera_pe_message_format::set_message_subfield_property av_st_din_$i source           BASE            $d_dst_width
      altera_pe_message_format::set_message_subfield_property av_st_din_$i source           SYMBOL_WIDTH    $d_src_width
      altera_pe_message_format::set_message_subfield_property av_st_din_$i taskid           BASE            [expr $d_dst_width + $d_src_width]
      altera_pe_message_format::set_message_subfield_property av_st_din_$i taskid           SYMBOL_WIDTH    $d_task_width
      altera_pe_message_format::set_message_subfield_property av_st_din_$i context          BASE            [expr $d_dst_width + $d_src_width + $d_task_width]
      altera_pe_message_format::set_message_subfield_property av_st_din_$i context          SYMBOL_WIDTH    $d_context_width
      altera_pe_message_format::set_message_subfield_property av_st_din_$i user             BASE            [expr $d_dst_width + $d_src_width + $d_task_width + $d_context_width]
      altera_pe_message_format::set_message_subfield_property av_st_din_$i user             SYMBOL_WIDTH    $d_user_width
      altera_pe_message_format::validate_and_create av_st_din_$i
   }

   #data output interface
   add_av_st_data_source_port   av_st_dout   $data_width   1   $d_dst_width   $d_src_width   $d_task_width   $d_context_width   $d_user_width   main_clock   0

}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Checking parameters (validation callback)                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc mux_validation_callback {} {

   #command port must have an Event ID width of at least 1 bit
   if { [get_parameter_value TASK_WIDTH] < 1 } {
      send_message Error "The Task ID width for the command port must be at least 1 bit"
   }

}
