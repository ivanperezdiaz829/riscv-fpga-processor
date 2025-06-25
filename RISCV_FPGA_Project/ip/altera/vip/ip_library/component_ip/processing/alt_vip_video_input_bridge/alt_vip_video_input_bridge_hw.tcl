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
# -- General information for the Video input bridge component                                          --
# -- This block receives video data and generates responses and video output                      --
# -- data in Avalon-ST message Video format.                                                      --
# --------------------------------------------------------------------------------------------------

# Common module properties for VIP components
source ../../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../../common_tcl/alt_vip_files_common_hw.tcl
source ../../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../../common_tcl/alt_vip_interfaces_common_hw.tcl

declare_general_component_info

# Component specific properties
set_module_property DESCRIPTION ""
set_module_property NAME alt_vip_video_input_bridge
set_module_property DISPLAY_NAME "Video Input Bridge"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_video_input_bridge.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_video_input_bridge

set_module_property ELABORATION_CALLBACK vib_elaboration_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_alt_vip_common_video_packet_decode ../../..
add_file src_hdl/alt_vip_video_input_bridge.sv $add_file_attribute


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_bits_per_symbol_parameters
add_channels_nb_parameters

add_parameter NUMBER_OF_PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL DISPLAY_NAME NUMBER_OF_PIXELS_IN_PARALLEL
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL ALLOWED_RANGES {1}
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL AFFECTS_GENERATION false
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL HDL_PARAMETER true
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL DISPLAY_NAME "Number of pixels in parallel"

add_parameter DEFAULT_LINE_LENGTH INTEGER 1920
set_parameter_property DEFAULT_LINE_LENGTH DEFAULT_VALUE 1920
set_parameter_property DEFAULT_LINE_LENGTH DISPLAY_NAME DEFAULT_LINE_LENGTH
set_parameter_property DEFAULT_LINE_LENGTH UNITS None
set_parameter_property DEFAULT_LINE_LENGTH ALLOWED_RANGES 20:4096
set_parameter_property DEFAULT_LINE_LENGTH DISPLAY_HINT ""
set_parameter_property DEFAULT_LINE_LENGTH AFFECTS_GENERATION false
set_parameter_property DEFAULT_LINE_LENGTH HDL_PARAMETER true
set_parameter_property DEFAULT_LINE_LENGTH DISPLAY_NAME "Default line length"

add_parameter VIDEO_PROTOCOL_NO INTEGER 1
set_parameter_property VIDEO_PROTOCOL_NO DEFAULT_VALUE 1
set_parameter_property VIDEO_PROTOCOL_NO DISPLAY_NAME VIDEO_PROTOCOL_NO
set_parameter_property VIDEO_PROTOCOL_NO UNITS None
set_parameter_property VIDEO_PROTOCOL_NO ALLOWED_RANGES {1}
set_parameter_property VIDEO_PROTOCOL_NO DISPLAY_HINT ""
set_parameter_property VIDEO_PROTOCOL_NO AFFECTS_GENERATION false
set_parameter_property VIDEO_PROTOCOL_NO HDL_PARAMETER true
set_parameter_property VIDEO_PROTOCOL_NO DISPLAY_NAME "Video protocol version"

add_parameter RESP_SRC_ADDRESS INTEGER 1
set_parameter_property RESP_SRC_ADDRESS DEFAULT_VALUE 1
set_parameter_property RESP_SRC_ADDRESS DISPLAY_NAME RESP_SRC_ADDRESS
set_parameter_property RESP_SRC_ADDRESS UNITS None
set_parameter_property RESP_SRC_ADDRESS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property RESP_SRC_ADDRESS DISPLAY_HINT ""
set_parameter_property RESP_SRC_ADDRESS AFFECTS_GENERATION false
set_parameter_property RESP_SRC_ADDRESS HDL_PARAMETER true
set_parameter_property RESP_SRC_ADDRESS DISPLAY_NAME "Response source ID"

add_parameter RESP_DST_ADDRESS INTEGER 1
set_parameter_property RESP_DST_ADDRESS DEFAULT_VALUE 1
set_parameter_property RESP_DST_ADDRESS DISPLAY_NAME RESP_DST_ADDRESS
set_parameter_property RESP_DST_ADDRESS UNITS None
set_parameter_property RESP_DST_ADDRESS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property RESP_DST_ADDRESS DISPLAY_HINT ""
set_parameter_property RESP_DST_ADDRESS AFFECTS_GENERATION false
set_parameter_property RESP_DST_ADDRESS HDL_PARAMETER true
set_parameter_property RESP_DST_ADDRESS DISPLAY_NAME "Default response destination ID"

add_parameter DATA_SRC_ADDRESS INTEGER 2
set_parameter_property DATA_SRC_ADDRESS DEFAULT_VALUE 2
set_parameter_property DATA_SRC_ADDRESS DISPLAY_NAME DATA_SRC_ADDRESS
set_parameter_property DATA_SRC_ADDRESS UNITS None
set_parameter_property DATA_SRC_ADDRESS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property DATA_SRC_ADDRESS DISPLAY_HINT ""
set_parameter_property DATA_SRC_ADDRESS AFFECTS_GENERATION false
set_parameter_property DATA_SRC_ADDRESS HDL_PARAMETER true
set_parameter_property DATA_SRC_ADDRESS DISPLAY_NAME "Dout source ID"

add_av_st_event_parameters


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


proc vib_elaboration_callback {} {

    set bits_per_symbol         [get_parameter_value BITS_PER_SYMBOL]
    set symbols_per_pixel       [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set are_in_par              [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]

    if { $are_in_par > 0 } {
      set symbols_per_beat $symbols_per_pixel
    } else {
      set symbols_per_beat 1
    }

    set resp_src_address        [get_parameter_value RESP_SRC_ADDRESS]
    set resp_dst_address        [get_parameter_value RESP_DST_ADDRESS]
    set data_src_address        [get_parameter_value DATA_SRC_ADDRESS]

    set src_width               [get_parameter_value SRC_WIDTH]
    set dst_width               [get_parameter_value DST_WIDTH]
    set context_width           [get_parameter_value CONTEXT_WIDTH]
    set task_width              [get_parameter_value TASK_WIDTH]

    set dwidth                  [expr ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )]

    add_av_st_cmd_sink_port       av_st_cmd               1          $dst_width          $src_width   $task_width   $context_width        main_clock   $resp_src_address
    add_av_st_resp_source_port    av_st_resp              1          $dst_width          $src_width   $task_width   $context_width        main_clock   $resp_src_address
    add_av_st_data_source_port    av_st_dout      $dwidth 1          $dst_width          $src_width   $task_width   $context_width   0    main_clock   $data_src_address
    add_av_st_vid_input_port      av_st_vid_din   $bits_per_symbol   $symbols_per_beat                                                    main_clock

}
