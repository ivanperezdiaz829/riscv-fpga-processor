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
# -- General information for the alt_vip_dil_sobel_scheduler module                                     --
# -- This block sources commands and sinks responses from the various components of the DIL to    --
# -- implement the required deinterlacing algorithms.                                             --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Common module properties for VIP components 
source ../../common_tcl/alt_vip_helper_common_hw.tcl
declare_general_component_info

source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../common_tcl/alt_vip_interfaces_common_hw.tcl

set_module_property NAME alt_vip_dil_vof_scheduler
set_module_property DISPLAY_NAME "Broadcast Deinterlacer scheduler"
set_module_property DESCRIPTION "Scheduler for the Broadcast deinterlacer core"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_dil_vof_scheduler.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_dil_vof_scheduler

set_module_property   ELABORATION_CALLBACK            dil_scheduler_elaboration_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files
add_file src_hdl/alt_vip_dil_vof_scheduler.sv $add_file_attribute
add_file src_hdl/alt_vip_dil_vof_scheduler.ocp $add_file_attribute
add_alt_vip_common_event_packet_decode_files
add_alt_vip_common_event_packet_encode_files

add_file alt_vip_dil_vof_scheduler.sdc SDC

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

add_parameter BUFFER0_BASE int 0
set_parameter_property BUFFER0_BASE DISPLAY_NAME "Base address of buffer 0"
set_parameter_property BUFFER0_BASE DISPLAY_HINT hexadecimal
set_parameter_property BUFFER0_BASE DESCRIPTION "The first buffer used to store incoming fields"
set_parameter_property BUFFER0_BASE HDL_PARAMETER true
set_parameter_property BUFFER0_BASE ENABLED true

add_parameter BUFFER1_BASE int 0
set_parameter_property BUFFER1_BASE DISPLAY_NAME "Base address of buffer 1"
set_parameter_property BUFFER1_BASE DISPLAY_HINT hexadecimal
set_parameter_property BUFFER1_BASE DESCRIPTION "The second buffer used to store incoming fields"
set_parameter_property BUFFER1_BASE HDL_PARAMETER true
set_parameter_property BUFFER1_BASE ENABLED true

add_parameter BUFFER2_BASE int 0
set_parameter_property BUFFER2_BASE DISPLAY_NAME "Base address of buffer 2"
set_parameter_property BUFFER2_BASE DISPLAY_HINT hexadecimal
set_parameter_property BUFFER2_BASE DESCRIPTION "The first buffer used to store incoming fields"
set_parameter_property BUFFER2_BASE HDL_PARAMETER true
set_parameter_property BUFFER2_BASE ENABLED true

add_parameter BUFFER3_BASE int 0
set_parameter_property BUFFER3_BASE DISPLAY_NAME "Base address of buffer 3"
set_parameter_property BUFFER3_BASE DISPLAY_HINT hexadecimal
set_parameter_property BUFFER3_BASE DESCRIPTION "The fourth buffer used to store incoming fields"
set_parameter_property BUFFER3_BASE HDL_PARAMETER true
set_parameter_property BUFFER3_BASE ENABLED true

add_parameter MOTION_BUFFER_BASE int 0
set_parameter_property   MOTION_BUFFER_BASE   DISPLAY_NAME         "Base address of for the motion field buffer"
set_parameter_property   MOTION_BUFFER_BASE   DESCRIPTION          "The buffer used to store motion values"
set_parameter_property   MOTION_BUFFER_BASE   DISPLAY_HINT         hexadecimal
set_parameter_property   MOTION_BUFFER_BASE   HDL_PARAMETER        true
set_parameter_property   MOTION_BUFFER_BASE   AFFECTS_ELABORATION  false

add_parameter LINE_OFFSET_BYTES INTEGER 160
set_parameter_property LINE_OFFSET_BYTES DISPLAY_NAME "The length (in bytes) of a line of pixels stored in memory"
set_parameter_property LINE_OFFSET_BYTES DESCRIPTION ""
set_parameter_property LINE_OFFSET_BYTES DISPLAY_HINT hexadecimal
set_parameter_property LINE_OFFSET_BYTES HDL_PARAMETER true

add_parameter MOTION_LINE_OFFSET_BYTES INTEGER 64
set_parameter_property MOTION_LINE_OFFSET_BYTES DISPLAY_NAME "The length (in bytes) of a line of motion value stored in memory"
set_parameter_property MOTION_LINE_OFFSET_BYTES DESCRIPTION ""
set_parameter_property MOTION_LINE_OFFSET_BYTES DISPLAY_HINT hexadecimal
set_parameter_property MOTION_LINE_OFFSET_BYTES HDL_PARAMETER true

add_parameter SOURCE_ADDRESS INTEGER 0 "Source ID of deinterlacer scheduler on output interface(s)"
set_parameter_property SOURCE_ADDRESS DISPLAY_NAME "Deinterlacer Scheduler ID"
set_parameter_property SOURCE_ADDRESS AFFECTS_GENERATION false
set_parameter_property SOURCE_ADDRESS HDL_PARAMETER true
set_parameter_property SOURCE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property SOURCE_ADDRESS DERIVED false

add_max_line_length_parameters
add_max_field_height_parameters
add_av_st_event_parameters

add_cadence_detect_parameters

add_parameter RUNTIME_CONTROL INTEGER 1
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Enable runtime control of cadence detect"
set_parameter_property RUNTIME_CONTROL DESCRIPTION ""
set_parameter_property RUNTIME_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_CONTROL AFFECTS_ELABORATION true
set_parameter_property RUNTIME_CONTROL HDL_PARAMETER true
set_parameter_property RUNTIME_CONTROL DISPLAY_HINT boolean

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
# The main clock and associated reset
add_main_clock_port


		 
add_interface control_slave_rsp avalon_streaming end
set_interface_property control_slave_rsp associatedClock main_clock
set_interface_property control_slave_rsp dataBitsPerSymbol 8
set_interface_property control_slave_rsp errorDescriptor ""
set_interface_property control_slave_rsp maxChannel 0
set_interface_property control_slave_rsp readyLatency 0
		
set_interface_property control_slave_rsp ASSOCIATED_CLOCK main_clock
set_interface_property control_slave_rsp ENABLED false
					

add_interface control_slave_cmd avalon_streaming start
set_interface_property control_slave_cmd associatedClock main_clock
set_interface_property control_slave_cmd dataBitsPerSymbol 8
set_interface_property control_slave_cmd errorDescriptor ""
set_interface_property control_slave_cmd maxChannel 0
set_interface_property control_slave_cmd readyLatency 0
		
set_interface_property control_slave_cmd ASSOCIATED_CLOCK main_clock
set_interface_property control_slave_cmd ENABLED false


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  


proc dil_scheduler_elaboration_callback {} {

    set cadence_detection [get_parameter_value CADENCE_DETECTION]
    set control_exists    [get_parameter_value RUNTIME_CONTROL]

    set src_width       [get_parameter_value SRC_WIDTH]
    set dst_width       [get_parameter_value DST_WIDTH]
    set context_width   [get_parameter_value CONTEXT_WIDTH]
    set task_width      [get_parameter_value TASK_WIDTH]

    # Eleven static command ports
    # name   elements_per_beat   dst_width   src_width   task_width   context_width    clock    pe_id 
    add_av_st_cmd_source_port cmd0  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd1  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd2  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd3  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd4  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd5  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd6  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd7  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd8  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd9  1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd11 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd13 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    add_av_st_cmd_source_port cmd14 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
	
    # One static response ports
    add_av_st_resp_sink_port  resp0 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    
    # VOF response port
    add_av_st_resp_sink_port  resp3 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0

    if { $control_exists } {
        add_av_st_cmd_source_port cmd12 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
        add_av_st_resp_sink_port  resp2 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    }
    
    # One optional cmd/resp for cadence detection
    if {$cadence_detection} {
        add_av_st_cmd_source_port cmd10 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
        add_av_st_resp_sink_port  resp1 1  $dst_width  $src_width  $task_width  $context_width  main_clock  0
    }
    
}

