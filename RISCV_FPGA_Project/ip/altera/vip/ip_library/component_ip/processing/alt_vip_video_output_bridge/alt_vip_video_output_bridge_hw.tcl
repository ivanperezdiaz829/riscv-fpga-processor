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


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General information for the Video output bridge component                                    --
# -- This block transmits video data received in the Avalon-ST message Video format               --
# -- in response to commands.                                                                     --
# --------------------------------------------------------------------------------------------------

# Common module properties for VIP components
source ../../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../../common_tcl/alt_vip_files_common_hw.tcl
source ../../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../../common_tcl/alt_vip_interfaces_common_hw.tcl

declare_general_component_info

# Component specific properties
set_module_property DESCRIPTION ""
set_module_property NAME alt_vip_video_output_bridge
set_module_property DISPLAY_NAME "Video Output Bridge"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_video_output_bridge.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_video_output_bridge

set_module_property ELABORATION_CALLBACK vob_elaboration_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_video_packet_encode ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file src_hdl/alt_vip_video_output_bridge.sv $add_file_attribute
add_file src_hdl/alt_vip_video_output_bridge.ocp $add_file_attribute


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_bits_per_symbol_parameters
add_channels_nb_parameters

add_parameter NUMBER_OF_PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL ALLOWED_RANGES 1:4
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL AFFECTS_GENERATION false
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL HDL_PARAMETER true
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL DISPLAY_NAME "Number of pixels in parallel"

add_parameter VIDEO_PROTOCOL_NO INTEGER 1
set_parameter_property VIDEO_PROTOCOL_NO DEFAULT_VALUE 1
set_parameter_property VIDEO_PROTOCOL_NO UNITS None
set_parameter_property VIDEO_PROTOCOL_NO ALLOWED_RANGES 1:1
set_parameter_property VIDEO_PROTOCOL_NO DISPLAY_HINT ""
set_parameter_property VIDEO_PROTOCOL_NO AFFECTS_GENERATION false
set_parameter_property VIDEO_PROTOCOL_NO HDL_PARAMETER true
set_parameter_property VIDEO_PROTOCOL_NO DISPLAY_NAME "Video protocol version"

add_av_st_event_parameters

add_parameter LOW_LATENCY_COMMAND_MODE INTEGER 0
set_parameter_property LOW_LATENCY_COMMAND_MODE DISPLAY_NAME "Low latency command mode (for CVI)"
set_parameter_property LOW_LATENCY_COMMAND_MODE ALLOWED_RANGES 0:1
set_parameter_property LOW_LATENCY_COMMAND_MODE DISPLAY_HINT boolean
set_parameter_property LOW_LATENCY_COMMAND_MODE HDL_PARAMETER true
set_parameter_property LOW_LATENCY_COMMAND_MODE VISIBLE false


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

add_main_clock_port


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc vob_elaboration_callback {} {

    set bits_per_symbol         [get_parameter_value BITS_PER_SYMBOL]
    set symbols_per_pixel       [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set are_in_par              [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]

    if { $are_in_par > 0 } {
      set symbols_per_beat $symbols_per_pixel
    } else {
      set symbols_per_beat 1
    }

    set src_width               [get_parameter_value SRC_WIDTH]
    set dst_width               [get_parameter_value DST_WIDTH]
    set context_width           [get_parameter_value CONTEXT_WIDTH]
    set task_width              [get_parameter_value TASK_WIDTH]

    set dwidth                  [expr ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )]

    # Source ID here is zero as the VOB has no Avalon-ST Video sources :
    add_av_st_cmd_sink_port     av_st_cmd                1          $dst_width          $src_width   $task_width   $context_width        main_clock   0
    add_av_st_data_sink_port    av_st_din        $dwidth 1          $dst_width          $src_width   $task_width   $context_width   0    main_clock   0
    add_av_st_vid_output_port   av_st_vid_dout   $bits_per_symbol   $symbols_per_beat                                                    main_clock

}
