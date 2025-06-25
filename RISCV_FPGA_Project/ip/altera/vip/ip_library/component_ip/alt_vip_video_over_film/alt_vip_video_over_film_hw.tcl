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
# -- General information for the motion detect component                                          --
# -- This block receives motion detect commands (on the cmd interface), reads the video           --
# -- and previous motion information sources motion estimates on its output                       --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Common module properties for VIP components 
source ../../common_tcl/alt_vip_helper_common_hw.tcl
declare_general_component_info

source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../common_tcl/alt_vip_interfaces_common_hw.tcl

# Component specific properties
set_module_property   NAME alt_vip_video_over_film
set_module_property   DISPLAY_NAME   "Video over film core"
set_module_property   DESCRIPTION    "Receives motion detect and VOF commands (on the cmd interface), reads the video data on the video and motion interfaces and sources motion vectors on the motion and dout interfaces"
set_module_property   TOP_LEVEL_HDL_FILE src_hdl/alt_vip_video_over_film.sv
set_module_property   TOP_LEVEL_HDL_MODULE alt_vip_video_over_film

set_module_property   ELABORATION_CALLBACK motion_detect_elaboration_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files
add_file src_hdl/alt_vip_video_over_film.sv $add_file_attribute
add_alt_vip_common_event_packet_decode_files
add_alt_vip_common_event_packet_encode_files



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_bits_per_symbol_parameters
add_channels_nb_parameters
add_max_line_length_parameters

add_parameter KERNEL_SIZE_0 int 2 "Height of motion detection kernel field (in lines)"
set_parameter_property    KERNEL_SIZE_0    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_0    HDL_PARAMETER         true

add_parameter KERNEL_SIZE_1 int 1 "Height of motion detection kernel field (in lines)"
set_parameter_property    KERNEL_SIZE_1    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_1    HDL_PARAMETER         true

add_parameter KERNEL_SIZE_2 int 2 "Height of motion detection kernel field (in lines)"
set_parameter_property    KERNEL_SIZE_2    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_2    HDL_PARAMETER         true

add_parameter KERNEL_SIZE_3 int 1 "Height of motion detection kernel field (in lines)"
set_parameter_property    KERNEL_SIZE_3    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_3    HDL_PARAMETER         true

add_parameter MOTION_BPS int 7 "Precision of motion detection in bits"
set_parameter_property    MOTION_BPS       AFFECTS_GENERATION    false
set_parameter_property    MOTION_BPS       HDL_PARAMETER         true


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# the clock
add_main_clock_port

add_av_st_event_parameters 

add_parameter SOURCE_ADDRESS INTEGER 0 "Source ID of motion detect on output interface(s)"
set_parameter_property SOURCE_ADDRESS DISPLAY_NAME "Motion detect ID"
set_parameter_property SOURCE_ADDRESS AFFECTS_GENERATION false
set_parameter_property SOURCE_ADDRESS HDL_PARAMETER true
set_parameter_property SOURCE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property SOURCE_ADDRESS DERIVED false

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
proc motion_detect_elaboration_callback {} {

    set bits_per_symbol         [get_parameter_value BITS_PER_SYMBOL]
    set symbols_per_pixel       [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set are_in_par              [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    set src_id                  [get_parameter_value SOURCE_ADDRESS]

    set src_width               [get_parameter_value SRC_WIDTH]
    set dst_width               [get_parameter_value DST_WIDTH]
    set context_width           [get_parameter_value CONTEXT_WIDTH]
    set task_width              [get_parameter_value TASK_WIDTH]
     
    set field0_kernel_height    [get_parameter_value KERNEL_SIZE_0]
    set field1_kernel_height    [get_parameter_value KERNEL_SIZE_1]
    set field2_kernel_height    [get_parameter_value KERNEL_SIZE_2]
    set field3_kernel_height    [get_parameter_value KERNEL_SIZE_3]  
         
    set field0_dwidth           [expr {$field0_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
    set field1_dwidth           [expr {$field1_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
    set field2_dwidth           [expr {$field2_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
    set field3_dwidth           [expr {$field3_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
    
    set motion_dwidth           32
 
    # "Field in" data ports :
    add_av_st_data_sink_port    av_st_field0 $field0_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id  
    add_av_st_data_sink_port    av_st_field1 $field1_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id   
    add_av_st_data_sink_port    av_st_field2 $field2_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id   
    add_av_st_data_sink_port    av_st_field3 $field3_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id   
    add_av_st_cmd_sink_port     av_st_cmd                   1 $dst_width $src_width $task_width $context_width main_clock $src_id
    
    # Motion in/out ports :  
    add_av_st_data_sink_port    av_st_mem_motion_in    $motion_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id
    add_av_st_data_source_port  av_st_mem_motion_out   $motion_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id
    add_av_st_data_source_port  av_st_algo_motion_out  $motion_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id

    # VOF response port :
    add_av_st_resp_source_port            resp                1 $dst_width $src_width $task_width $context_width main_clock $src_id
    
}



