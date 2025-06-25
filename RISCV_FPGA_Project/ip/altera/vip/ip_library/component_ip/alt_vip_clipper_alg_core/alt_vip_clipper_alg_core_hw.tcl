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


source ../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../common_tcl/alt_vip_interfaces_common_hw.tcl

# ------------------------------------------------------------------------------------------------------------
# --                                                                                                        --
# -- General information for the clipper algorithmic core module                                            --
# -- This block sinks Avalon-ST Message Data packets from a single source and crops data from the start     --
# -- and/or end of the packet as per the commands issued through the Avalon-ST Message Command interface.   --
# -- The resulting packets are output through a single Avalon-ST Message Data source                        --
# --                                                                                                        --
# ------------------------------------------------------------------------------------------------------------

# Common module properties for VIP components
declare_general_component_info

# Component specific properties
set_module_property NAME alt_vip_clipper_alg_core
set_module_property DISPLAY_NAME "Clipper Algorithmic Core"
set_module_property DESCRIPTION "Removes pixels from the start and/or end of video lines"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_clipper_alg_core.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_clipper_alg_core

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

add_alt_vip_common_pkg_files
add_alt_vip_common_event_packet_decode_files
add_alt_vip_common_event_packet_encode_files
add_file src_hdl/alt_vip_clipper_alg_core.sv $add_file_attribute

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

add_channels_nb_parameters
add_bits_per_symbol_parameters

# Add parameters for the data and command Avalon-ST message ports
add_av_st_event_parameters

add_parameter DATA_SRC_ADDRESS INTEGER 2
set_parameter_property DATA_SRC_ADDRESS DISPLAY_NAME "dout Source ID"
set_parameter_property DATA_SRC_ADDRESS AFFECTS_GENERATION false
set_parameter_property DATA_SRC_ADDRESS HDL_PARAMETER true

add_parameter PIPELINE_DATA_OUTPUT INTEGER 0
set_parameter_property PIPELINE_DATA_OUTPUT DISPLAY_NAME "Pipeline din ready"
set_parameter_property PIPELINE_DATA_OUTPUT ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_DATA_OUTPUT DISPLAY_HINT BOOLEAN
set_parameter_property PIPELINE_DATA_OUTPUT AFFECTS_GENERATION false
set_parameter_property PIPELINE_DATA_OUTPUT HDL_PARAMETER true

add_max_in_dim_parameters
set_parameter_property MAX_IN_HEIGHT VISIBLE       false
set_parameter_property MAX_IN_HEIGHT HDL_PARAMETER false


add_parameter          LEFT_OFFSET int 10
set_parameter_property LEFT_OFFSET DISPLAY_NAME "Left Offset"
set_parameter_property LEFT_OFFSET ALLOWED_RANGES 0:1920
set_parameter_property LEFT_OFFSET DESCRIPTION "The number of pixels to the left edge of the clipping surface"
set_parameter_property LEFT_OFFSET HDL_PARAMETER true
set_parameter_property LEFT_OFFSET AFFECTS_ELABORATION true

add_parameter          RIGHT_OFFSET int 10
set_parameter_property RIGHT_OFFSET DISPLAY_NAME "Right Offset"
set_parameter_property RIGHT_OFFSET ALLOWED_RANGES 0:1920
set_parameter_property RIGHT_OFFSET DESCRIPTION "The number of pixels to the right edge of the clipping surface"
set_parameter_property RIGHT_OFFSET HDL_PARAMETER true
set_parameter_property RIGHT_OFFSET AFFECTS_ELABORATION true

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


# | Dynamic ports (elaboration callback)
set_module_property ELABORATION_CALLBACK clipper_elaboration_callback
proc clipper_elaboration_callback {} {
    set src_id                      [get_parameter_value DATA_SRC_ADDRESS]

    #setting up the command port
    set src_width                   [get_parameter_value SRC_WIDTH]
    set dst_width                   [get_parameter_value DST_WIDTH]
    set context_width               [get_parameter_value CONTEXT_WIDTH]
    set task_width                  [get_parameter_value TASK_WIDTH]
    add_av_st_cmd_sink_port   av_st_cmd   1   $dst_width   $src_width   $task_width   $context_width   main_clock   $src_id

    #setting up the data input port
    set bits_per_symbol             [get_parameter_value BITS_PER_SYMBOL]
    set symbols_per_pixel           [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set are_in_par                  [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    if {$are_in_par > 0} {
      set data_width [expr $bits_per_symbol * $symbols_per_pixel]
    } else {
      set data_width $bits_per_symbol
    }
    add_av_st_data_sink_port   av_st_din   $data_width   1   $dst_width   $src_width   $task_width   $context_width   0   main_clock   $src_id

    #setting up the data output port
    add_av_st_data_source_port   av_st_dout   $data_width   1   $dst_width   $src_width   $task_width   $context_width   0   main_clock   $src_id
}
