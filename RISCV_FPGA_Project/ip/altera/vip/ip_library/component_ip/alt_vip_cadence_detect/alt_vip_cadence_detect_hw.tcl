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
# -- General information for the cadence detect component                                         --
# -- This receives cadence detect commands on the cmd interface and video data on the other two   --
# -- inputs and outputs cadence responses which a scheduler may receive and act upon.             --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Common module properties for VIP components 
source ../../common_tcl/alt_vip_helper_common_hw.tcl
declare_general_component_info

source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../common_tcl/alt_vip_interfaces_common_hw.tcl

# Component specific properties
set_module_property   NAME alt_vip_cadence_detect
set_module_property   DISPLAY_NAME   "Cadence Detect core"
set_module_property   DESCRIPTION    "This receives cadence detect commands on the cmd interface and video data on the other two inputs and outputs cadence responses which a scheduler may receive and act upon."
set_module_property   TOP_LEVEL_HDL_FILE src_hdl/alt_vip_cadence_detect.sv
set_module_property   TOP_LEVEL_HDL_MODULE alt_vip_cadence_detect

set_module_property   ELABORATION_CALLBACK            cadence_detect_elaboration_callback
set_module_property   AUTHOR         "Altera Corporation"


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files
add_file src_hdl/alt_vip_cadence_detect.sv             $add_file_attribute
add_file src_hdl/alt_vip_null_cadence_detect_core.sv   $add_file_attribute
add_file src_hdl/alt_vip_32_cadence_detect_core.sv     $add_file_attribute
add_file src_hdl/alt_vip_22_cadence_detect_core.sv     $add_file_attribute
add_file src_hdl/alt_vip_32_22_cadence_detect_core.sv  $add_file_attribute
add_file src_hdl/alt_vip_cadence_diff_factor.sv        $add_file_attribute
add_file src_hdl/alt_vip_cadence_comb_factor.sv        $add_file_attribute
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
add_max_field_height_parameters

add_parameter KERNEL_SIZE_0 int 2
set_parameter_property    KERNEL_SIZE_0    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_0    HDL_PARAMETER         true

add_parameter KERNEL_SIZE_1 int 1
set_parameter_property    KERNEL_SIZE_1    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_1    HDL_PARAMETER         true

add_parameter KERNEL_SIZE_2 int 2
set_parameter_property    KERNEL_SIZE_2    AFFECTS_GENERATION    false
set_parameter_property    KERNEL_SIZE_2    HDL_PARAMETER         true


add_cadence_algo_parameters


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# the clock
add_main_clock_port
add_av_st_event_parameters


add_parameter SOURCE_ADDRESS INTEGER 0 "Source ID of cadence detect on output interface(s)"
set_parameter_property SOURCE_ADDRESS DISPLAY_NAME "Cadence detect ID"
set_parameter_property SOURCE_ADDRESS AFFECTS_GENERATION false
set_parameter_property SOURCE_ADDRESS HDL_PARAMETER true
set_parameter_property SOURCE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property SOURCE_ADDRESS DERIVED false

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
proc cadence_detect_elaboration_callback {} {

    set src_id                    [get_parameter_value SOURCE_ADDRESS]
    
    set bits_per_symbol           [get_parameter_value BITS_PER_SYMBOL]
    set symbols_per_pixel         [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set are_in_par                [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]

    set src_width                 [get_parameter_value SRC_WIDTH]
    set dst_width                 [get_parameter_value DST_WIDTH]
    set context_width             [get_parameter_value CONTEXT_WIDTH]
    set task_width                [get_parameter_value TASK_WIDTH]

    set field0_kernel_height      [get_parameter_value KERNEL_SIZE_0]
    set field1_kernel_height      [get_parameter_value KERNEL_SIZE_1]
    set field2_kernel_height      [get_parameter_value KERNEL_SIZE_2]
    
    set field0_dwidth             [expr {$field0_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
    set field1_dwidth             [expr {$field1_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
    set field2_dwidth             [expr {$field2_kernel_height * ($are_in_par ? $bits_per_symbol * $symbols_per_pixel : $bits_per_symbol )}]
   
    add_av_st_data_sink_port      av_st_field0 $field0_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id   
    add_av_st_data_sink_port      av_st_field1 $field1_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id   
    add_av_st_data_sink_port      av_st_field2 $field2_dwidth 1 $dst_width $src_width $task_width $context_width 0 main_clock $src_id   
                                         
    add_av_st_cmd_sink_port                cmd                1 $dst_width $src_width $task_width $context_width main_clock $src_id 
    add_av_st_resp_source_port            resp                1 $dst_width $src_width $task_width $context_width main_clock $src_id
    
    set cadence_algo              [get_parameter_value CADENCE_ALGORITHM_NAME]    
}



