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

# | module alt_vip_scaler_scheduler

declare_general_component_info
set_module_property NAME alt_vip_fir_scheduler
set_module_property DISPLAY_NAME "FIR Scheduler"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_fir_scheduler.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_fir_scheduler

# | files

add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file src_hdl/alt_vip_fir_scheduler.sv $add_file_attribute

add_max_dim_parameters
add_bits_per_symbol_parameters

add_parameter EDGE_ADAPTIVE_SHARPEN INTEGER 1
set_parameter_property EDGE_ADAPTIVE_SHARPEN DISPLAY_NAME "Use edge adaptive sharpen mode"
set_parameter_property EDGE_ADAPTIVE_SHARPEN DESCRIPTION ""
set_parameter_property EDGE_ADAPTIVE_SHARPEN ALLOWED_RANGES 0:1
set_parameter_property EDGE_ADAPTIVE_SHARPEN AFFECTS_ELABORATION false
set_parameter_property EDGE_ADAPTIVE_SHARPEN HDL_PARAMETER true
set_parameter_property EDGE_ADAPTIVE_SHARPEN DISPLAY_HINT boolean

add_parameter RUNTIME_CONTROL INTEGER 1
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Enable runtime blur threshold control"
set_parameter_property RUNTIME_CONTROL DESCRIPTION ""
set_parameter_property RUNTIME_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_CONTROL AFFECTS_ELABORATION true
set_parameter_property RUNTIME_CONTROL HDL_PARAMETER true
set_parameter_property RUNTIME_CONTROL DISPLAY_HINT boolean

add_parameter LOAD_AT_RUNTIME INTEGER 1
set_parameter_property LOAD_AT_RUNTIME DISPLAY_NAME "Enable runtime coefficient loading"
set_parameter_property LOAD_AT_RUNTIME DESCRIPTION ""
set_parameter_property LOAD_AT_RUNTIME ALLOWED_RANGES 0:1
set_parameter_property LOAD_AT_RUNTIME AFFECTS_ELABORATION true
set_parameter_property LOAD_AT_RUNTIME HDL_PARAMETER true
set_parameter_property LOAD_AT_RUNTIME DISPLAY_HINT boolean

add_parameter DEFAULT_SEARCH_RANGE INTEGER 15
set_parameter_property DEFAULT_SEARCH_RANGE DISPLAY_NAME "Default search range enable value"
set_parameter_property DEFAULT_SEARCH_RANGE DESCRIPTION ""
set_parameter_property DEFAULT_SEARCH_RANGE ALLOWED_RANGES 0:15
set_parameter_property DEFAULT_SEARCH_RANGE AFFECTS_ELABORATION false
set_parameter_property DEFAULT_SEARCH_RANGE HDL_PARAMETER true

add_parameter DEFAULT_UPPER_BLUR INTEGER 15
set_parameter_property DEFAULT_UPPER_BLUR DISPLAY_NAME "Default upper blur limit (per color plane)"
set_parameter_property DEFAULT_UPPER_BLUR DESCRIPTION ""
set_parameter_property DEFAULT_UPPER_BLUR AFFECTS_ELABORATION false
set_parameter_property DEFAULT_UPPER_BLUR HDL_PARAMETER true

add_parameter DEFAULT_LOWER_BLUR INTEGER 0
set_parameter_property DEFAULT_LOWER_BLUR DISPLAY_NAME "Default lower blur limit (per color plane)"
set_parameter_property DEFAULT_LOWER_BLUR DESCRIPTION ""
set_parameter_property DEFAULT_LOWER_BLUR AFFECTS_ELABORATION false
set_parameter_property DEFAULT_LOWER_BLUR HDL_PARAMETER true

add_parameter V_TAPS INTEGER 3
set_parameter_property V_TAPS DISPLAY_NAME "Vertical taps"
set_parameter_property V_TAPS DESCRIPTION ""
set_parameter_property V_TAPS ALLOWED_RANGES 1:64
set_parameter_property V_TAPS AFFECTS_ELABORATION false
set_parameter_property V_TAPS HDL_PARAMETER true

add_parameter UPDATE_TAPS INTEGER 9
set_parameter_property UPDATE_TAPS DISPLAY_NAME "Length of coefficient packet from runtime update"
set_parameter_property UPDATE_TAPS DESCRIPTION ""
set_parameter_property UPDATE_TAPS ALLOWED_RANGES 1:4097
set_parameter_property UPDATE_TAPS AFFECTS_ELABORATION false
set_parameter_property UPDATE_TAPS HDL_PARAMETER true

add_parameter NO_BLANKING INTEGER 0
set_parameter_property NO_BLANKING DISPLAY_NAME "Video has no blanking"
set_parameter_property NO_BLANKING DESCRIPTION ""
set_parameter_property NO_BLANKING ALLOWED_RANGES 0:1
set_parameter_property NO_BLANKING AFFECTS_ELABORATION false
set_parameter_property NO_BLANKING HDL_PARAMETER true
set_parameter_property NO_BLANKING DISPLAY_HINT boolean

add_parameter INSIDE_SCALER INTEGER 0
set_parameter_property INSIDE_SCALER DISPLAY_NAME "Turn on if FIR Scheduler is used inside the Scaler II"
set_parameter_property INSIDE_SCALER DESCRIPTION ""
set_parameter_property INSIDE_SCALER ALLOWED_RANGES 0:1
set_parameter_property INSIDE_SCALER AFFECTS_ELABORATION true
set_parameter_property INSIDE_SCALER HDL_PARAMETER true
set_parameter_property INSIDE_SCALER DISPLAY_HINT boolean

add_parameter INSIDE_NOISE_REDUCTION INTEGER 0
set_parameter_property INSIDE_NOISE_REDUCTION DISPLAY_NAME "Turn on if FIR Scheduler is used inside the Noise Reduction Megacore"
set_parameter_property INSIDE_NOISE_REDUCTION DESCRIPTION ""
set_parameter_property INSIDE_NOISE_REDUCTION ALLOWED_RANGES 0:1
set_parameter_property INSIDE_NOISE_REDUCTION AFFECTS_ELABORATION true
set_parameter_property INSIDE_NOISE_REDUCTION HDL_PARAMETER true
set_parameter_property INSIDE_NOISE_REDUCTION DISPLAY_HINT boolean

add_parameter ENCODER_PIPELINE_STAGE INTEGER 0
set_parameter_property ENCODER_PIPELINE_STAGE DISPLAY_NAME "Pipeline command interfaces"
set_parameter_property ENCODER_PIPELINE_STAGE DESCRIPTION ""
set_parameter_property ENCODER_PIPELINE_STAGE ALLOWED_RANGES 0:1
set_parameter_property ENCODER_PIPELINE_STAGE AFFECTS_ELABORATION false
set_parameter_property ENCODER_PIPELINE_STAGE HDL_PARAMETER true
set_parameter_property ENCODER_PIPELINE_STAGE DISPLAY_HINT boolean

# | connection point clock_reset

add_main_clock_port

# | Dynamic ports (elaboration callback)
set_module_property ELABORATION_CALLBACK scl_sched_elaboration_callback
proc scl_sched_elaboration_callback {} {

	set control_exists [get_parameter_value RUNTIME_CONTROL]
	if { $control_exists == 0 } {
		set control_exists [get_parameter_value LOAD_AT_RUNTIME]
	}

   add_av_st_cmd_source_port   av_st_cmd_0   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_1   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_3   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_4   1   8   8   8   8   main_clock   0

   add_av_st_resp_sink_port    av_st_resp_0   1   8   8   8   8   main_clock  0

	if { $control_exists > 0 } {
      set args_in_par 1
      if { [get_parameter_value INSIDE_SCALER] > 0 } {
         set args_in_par 2
      }
      add_av_st_cmd_source_port   av_st_cmd_5   1   8   8   8   8   main_clock   0
      add_av_st_resp_sink_port    av_st_resp_2   $args_in_par   8   8   8   8   main_clock  0
	}

   if { [get_parameter_value INSIDE_NOISE_REDUCTION] > 0 } {
      if { [get_parameter_value RUNTIME_CONTROL] > 0 } {
         add_av_st_cmd_source_port   av_st_cmd_6   2   8   8   8   8   main_clock   0
      }
   } else {
      add_av_st_cmd_source_port   av_st_cmd_7   1   8   8   8   8   main_clock   0
   }

}
