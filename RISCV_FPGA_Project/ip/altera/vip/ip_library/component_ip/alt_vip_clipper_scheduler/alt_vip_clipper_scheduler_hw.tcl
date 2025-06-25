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

# | module alt_vip_clipper_scheduler

declare_general_component_info
set_module_property NAME alt_vip_clipper_scheduler
set_module_property DISPLAY_NAME "Clipper Scheduler"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_clipper_scheduler.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_clipper_scheduler

# | files

add_alt_vip_common_pkg_files
add_alt_vip_common_event_packet_decode_files
add_alt_vip_common_event_packet_encode_files
add_file src_hdl/alt_vip_clipper_scheduler.sv $add_file_attribute

#add_max_dim_parameters
add_bits_per_symbol_parameters

# Add MAX_IN_WIDTH and MAX_IN_HEIGHT parameters
add_max_in_dim_parameters

add_parameter          RECTANGLE_MODE int 1
set_parameter_property RECTANGLE_MODE DISPLAY_NAME "Rectangle Mode"
set_parameter_property RECTANGLE_MODE ALLOWED_RANGES 0:1
set_parameter_property RECTANGLE_MODE DISPLAY_HINT boolean
set_parameter_property RECTANGLE_MODE DESCRIPTION "Offsets mode will clip a portion of the image based on how large each offset is from the edge of the input image. Rectangle mode will clip an image of width * height dimensions from the starting left and right offset."
set_parameter_property RECTANGLE_MODE HDL_PARAMETER true
set_parameter_property RECTANGLE_MODE AFFECTS_ELABORATION true

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

add_parameter          TOP_OFFSET int 10
set_parameter_property TOP_OFFSET DISPLAY_NAME "Top Offset"
set_parameter_property TOP_OFFSET ALLOWED_RANGES 0:1080
set_parameter_property TOP_OFFSET DESCRIPTION "The number of pixels to the top edge of the clipping surface"
set_parameter_property TOP_OFFSET HDL_PARAMETER true
set_parameter_property TOP_OFFSET AFFECTS_ELABORATION true

add_parameter          BOTTOM_OFFSET int 10
set_parameter_property BOTTOM_OFFSET DISPLAY_NAME "Bottom Offset"
set_parameter_property BOTTOM_OFFSET ALLOWED_RANGES 0:1080
set_parameter_property BOTTOM_OFFSET DESCRIPTION "The number of pixels to the bottom edge of the clipping surface"
set_parameter_property BOTTOM_OFFSET HDL_PARAMETER true
set_parameter_property BOTTOM_OFFSET AFFECTS_ELABORATION true

add_parameter RUNTIME_CONTROL INTEGER 0
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Runtime control"
set_parameter_property RUNTIME_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_CONTROL DISPLAY_HINT BOOLEAN
set_parameter_property RUNTIME_CONTROL AFFECTS_GENERATION true
set_parameter_property RUNTIME_CONTROL HDL_PARAMETER true

# | connection point clock_reset

add_main_clock_port

# | Dynamic ports (elaboration callback)
set_module_property ELABORATION_CALLBACK clp_sched_elaboration_callback
proc clp_sched_elaboration_callback {} {
   #  scheduler.av_st_cmd_0	     ->     video_in.cmd
   #  scheduler.av_st_cmd_1   	 ->     line_buffer.cmd             X
   #  scheduler.av_st_cmd_2   	 ->     kernel_creator.cmd          X
   #  scheduler.av_st_cmd_3   	 ->     scaler_alg_core.cmd
   #  scheduler.av_st_cmd_4      ->     video_out.cmd
   #  scheduler.av_st_cmd_5      ->     scaler_control_slave.cmd
   #  video_in.resp       	     ->     scheduler.av_st_resp_0
   #  kernel_creator.resp        ->     scheduler.av_st_resp_1      X
   #  scaler_control_slave.resp  ->     scheduler.av_st_resp_2

   set control_exists [get_parameter_value RUNTIME_CONTROL]

   add_av_st_cmd_source_port   av_st_cmd_video_in          1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_core              1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_video_out         1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_user_packet_mux   1   8   8   8   8   main_clock   0
   add_av_st_resp_sink_port    av_st_resp_video_in         1   8   8   8   8   main_clock   0

	if { $control_exists > 0 } {
      add_av_st_cmd_source_port   av_st_cmd_control_slave    1   8   8   8   8   main_clock  0
      add_av_st_resp_sink_port    av_st_resp_control_slave   1   8   8   8   8   main_clock  0
	}

}