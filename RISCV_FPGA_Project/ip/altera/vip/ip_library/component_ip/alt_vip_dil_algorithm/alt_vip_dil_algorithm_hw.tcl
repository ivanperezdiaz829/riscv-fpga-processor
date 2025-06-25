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
# -- General information for the Deinterlacer II algorithmic component (HQ MA quality)            --
# -- This block interpolates the bob pixel (low-angle EDI) and merges with the weave pixel        --
# -- depending on the  motion value                                                               --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Common module properties for VIP components 
source ../../common_tcl/alt_vip_helper_common_hw.tcl
declare_general_component_info

source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../common_tcl/alt_vip_interfaces_common_hw.tcl


# Component specific properties
set_module_property   NAME                          alt_vip_dil_algorithm
set_module_property   DISPLAY_NAME                  "Deinterlace algorithmic core"
set_module_property   DESCRIPTION                   "Receives deinterlace commands (on the cmd interface), reads the video data on the bob, weave and motion interfaces and sources deinterlaced video on dout interface"

set_module_property   ELABORATION_CALLBACK          dil_algo_elaboration_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
add_alt_vip_common_pkg_files
add_alt_vip_common_event_packet_decode_files
add_alt_vip_common_event_packet_encode_files

add_file              src_hdl/alt_vip_dil_algorithm.sv     $add_file_attribute
set_module_property   TOP_LEVEL_HDL_FILE                   src_hdl/alt_vip_dil_algorithm.sv
set_module_property   TOP_LEVEL_HDL_MODULE                 alt_vip_dil_algorithm


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
add_bits_per_symbol_parameters
add_channels_nb_parameters
add_is_422_parameters


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
#clock
add_main_clock_port

add_av_st_event_parameters 

add_parameter SOURCE_ADDRESS INTEGER 0 "Source ID of deinterlace component on output interface(s)"
set_parameter_property SOURCE_ADDRESS DISPLAY_NAME "Deinterlace ID"
set_parameter_property SOURCE_ADDRESS AFFECTS_GENERATION false
set_parameter_property SOURCE_ADDRESS HDL_PARAMETER true
set_parameter_property SOURCE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property SOURCE_ADDRESS DERIVED false


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc dil_algo_elaboration_callback {} {

    set bits_per_symbol        [get_parameter_value BITS_PER_SYMBOL]
    set are_in_par             [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    set symbols_per_pixel      [get_parameter_value NUMBER_OF_COLOR_PLANES]

    set src_width              [get_parameter_value SRC_WIDTH]
    set dst_width              [get_parameter_value DST_WIDTH]
    set context_width          [get_parameter_value CONTEXT_WIDTH]
    set task_width             [get_parameter_value TASK_WIDTH]

    set weave_dwidth           [expr {$symbols_per_pixel * ($are_in_par ? $bits_per_symbol : 1)}]
    set dout_dwidth            [expr {$symbols_per_pixel * ($are_in_par ? $bits_per_symbol : 1)}]
    set motion_dwidth          8
    set bob_dwidth             [expr {2 * $weave_dwidth}]
    
    set src_id                 [get_parameter_value SOURCE_ADDRESS]
    
    add_av_st_cmd_sink_port    cmd                       1 $dst_width $src_width $task_width $context_width main_clock $src_id    
    add_av_st_data_sink_port   din_weave  $weave_dwidth  1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id    
    add_av_st_data_sink_port   din_bob    $bob_dwidth    1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id    
    add_av_st_data_sink_port   din_motion $motion_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id    
    add_av_st_data_source_port dout       $dout_dwidth   1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id
    
}



