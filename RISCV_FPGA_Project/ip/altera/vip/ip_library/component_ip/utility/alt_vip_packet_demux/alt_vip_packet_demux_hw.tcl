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
# -- General information for the duplicator module                                                --
# -- This block receives Avalon-ST packets and forwards them to up to destinations.               --
# -- It optinonally includes one FIFO per destination to absorb ready latencies downstream.       --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Common module properties for VIP components
declare_general_component_info

# Component specific properties
set_module_property NAME alt_vip_packet_demux
set_module_property DISPLAY_NAME "Packet Demux"
set_module_property DESCRIPTION "Forward incoming packets to one of (up to) 16 outputs"
set_module_property TOP_LEVEL_HDL_FILE ./src_hdl/alt_vip_packet_demux.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_packet_demux

set_module_property VALIDATION_CALLBACK  demux_validation_callback
set_module_property ELABORATION_CALLBACK demux_elaboration_callback



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file ./src_hdl/alt_vip_packet_demux.sv $add_file_attribute

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

add_data_width_parameters  

add_parameter NUM_OUTPUTS int 2
set_parameter_property NUM_OUTPUTS        ALLOWED_RANGES       2:16
set_parameter_property NUM_OUTPUTS        DISPLAY_NAME         "Number of output ports"
set_parameter_property NUM_OUTPUTS        AFFECTS_ELABORATION  true
set_parameter_property NUM_OUTPUTS        HDL_PARAMETER        true

add_parameter CLIP_ADDRESS_BITS int 0
set_parameter_property CLIP_ADDRESS_BITS  DISPLAY_NAME        "Clip address bits"
set_parameter_property CLIP_ADDRESS_BITS  ALLOWED_RANGES      0:1
set_parameter_property CLIP_ADDRESS_BITS  DISPLAY_HINT        boolean
set_parameter_property CLIP_ADDRESS_BITS  AFFECTS_ELABORATION true
set_parameter_property CLIP_ADDRESS_BITS  HDL_PARAMETER       true

add_parameter REGISTER_OUTPUT int 0
set_parameter_property REGISTER_OUTPUT    ALLOWED_RANGES      0:1
set_parameter_property REGISTER_OUTPUT    DISPLAY_NAME        "Register dout interfaces"
set_parameter_property REGISTER_OUTPUT    DISPLAY_HINT        boolean
set_parameter_property REGISTER_OUTPUT    AFFECTS_ELABORATION false
set_parameter_property REGISTER_OUTPUT    HDL_PARAMETER       true

add_parameter PIPELINE_READY int 0
set_parameter_property PIPELINE_READY     ALLOWED_RANGES      0:1
set_parameter_property PIPELINE_READY     DISPLAY_NAME        "Pipeline dout ready signal"
set_parameter_property PIPELINE_READY     DISPLAY_HINT        boolean
set_parameter_property PIPELINE_READY     AFFECTS_ELABORATION false
set_parameter_property PIPELINE_READY     HDL_PARAMETER       true

# Add parameters for the data and command Avalon-ST message ports
add_av_st_event_parameters

add_av_st_event_user_width_parameter

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Validation callback                                                                          --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc demux_validation_callback {} {
   set addr_bits  [get_parameter_value NUM_OUTPUTS]
   set addr_bits  [clogb2_pure $addr_bits]
   if { $addr_bits > [get_parameter_value DST_WIDTH] } {
      send_message Error "The destination ID width must not be less than the log2 of demux outputs"
   }
}



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
proc demux_elaboration_callback {} {

    set data_width                   [get_parameter_value DATA_WIDTH]
    set d_src_width                  [get_parameter_value SRC_WIDTH]
    set d_dst_width                  [get_parameter_value DST_WIDTH]
    set d_context_width              [get_parameter_value CONTEXT_WIDTH]
    set d_task_width                 [get_parameter_value TASK_WIDTH]
    set d_user_width                 [get_parameter_value USER_WIDTH]

    #adding the input interface
    add_av_st_data_sink_port   av_st_din   $data_width   1   $d_dst_width   $d_src_width   $d_task_width   $d_context_width   $d_user_width   main_clock   0

    set fanout                      [get_parameter_value NUM_OUTPUTS]

    #working out the output destination width
    if { [get_parameter_value CLIP_ADDRESS_BITS] > 0 } {
      set addr_bits  [clogb2_pure $fanout]
      if { $d_dst_width > $addr_bits } {
         set out_dst_width [expr $d_dst_width - $addr_bits]
      } else {
         set out_dst_width 0
      }
    } else {
         set out_dst_width $d_dst_width
    }
    set d_control_width                [expr $d_src_width + $out_dst_width + $d_context_width + $d_task_width + $d_user_width]

    #adding the output interfaces
    for { set i 0 } { $i < $fanout } { incr i } {
        add_interface av_st_dout_$i avalon_streaming source
   	  set_interface_property av_st_dout_$i readyLatency 0
   	  set_interface_property av_st_dout_$i ASSOCIATED_CLOCK main_clock
   	  set_interface_property av_st_dout_$i ENABLED true

        add_interface_port av_st_dout_$i av_st_dout_valid_$i         valid         Output  1
        add_interface_port av_st_dout_$i av_st_dout_ready_$i         ready         Input   1
        add_interface_port av_st_dout_$i av_st_dout_startofpacket_$i startofpacket Output  1
        add_interface_port av_st_dout_$i av_st_dout_endofpacket_$i   endofpacket   Output  1
        add_interface_port av_st_dout_$i av_st_dout_data_$i          data          Output  [expr {$d_control_width + $data_width}]

        set_port_property av_st_dout_ready_$i         FRAGMENT_LIST "av_st_dout_ready@$i"
        set_port_property av_st_dout_valid_$i         FRAGMENT_LIST "av_st_dout_valid@$i"
        set_port_property av_st_dout_startofpacket_$i FRAGMENT_LIST "av_st_dout_startofpacket@$i"
        set_port_property av_st_dout_endofpacket_$i   FRAGMENT_LIST "av_st_dout_endofpacket@$i"
        set_port_property av_st_dout_data_$i          FRAGMENT_LIST "av_st_dout_data@[expr ($i+1)*($d_control_width+$data_width) - 1]:[expr $i*($d_control_width+$data_width)]"

        altera_pe_message_format::set_message_property          av_st_dout_$i                  PEID             0
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i argument         SYMBOLS_PER_BEAT 1
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i argument         SYMBOL_WIDTH     $data_width
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i destination      BASE            0
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i destination      SYMBOL_WIDTH    $out_dst_width
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i source           BASE            $out_dst_width
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i source           SYMBOL_WIDTH    $d_src_width
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i taskid           BASE            [expr $out_dst_width + $d_src_width]
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i taskid           SYMBOL_WIDTH    $d_task_width
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i context          BASE            [expr $out_dst_width + $d_src_width + $d_task_width]
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i context          SYMBOL_WIDTH    $d_context_width
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i user             BASE            [expr $out_dst_width + $d_src_width + $d_task_width + $d_context_width]
        altera_pe_message_format::set_message_subfield_property av_st_dout_$i user             SYMBOL_WIDTH    $d_user_width
        altera_pe_message_format::validate_and_create av_st_dout_$i
    }
}
