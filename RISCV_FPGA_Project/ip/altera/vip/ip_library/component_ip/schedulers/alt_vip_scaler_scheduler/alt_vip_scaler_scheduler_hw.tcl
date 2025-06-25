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
set_module_property NAME alt_vip_scaler_scheduler
set_module_property DISPLAY_NAME "Scaler Scheduler"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_scaler_scheduler.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_scaler_scheduler

# | files

add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file src_hdl/alt_vip_scaler_scheduler.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_scheduler.ocp $add_file_attribute

# | parameters

add_parameter ALGORITHM STRING POLYPHASE
set_parameter_property ALGORITHM DISPLAY_NAME "Scaling algorithm"
set_parameter_property ALGORITHM DESCRIPTION ""
set_parameter_property ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR BICUBIC POLYPHASE EDGE_ADAPT}
set_parameter_property ALGORITHM AFFECTS_ELABORATION true
set_parameter_property ALGORITHM HDL_PARAMETER true

add_parameter ENABLE_FIR INTEGER 0
set_parameter_property ENABLE_FIR DISPLAY_NAME "Enable post scaling sharpening filter"
set_parameter_property ENABLE_FIR DESCRIPTION ""
set_parameter_property ENABLE_FIR ALLOWED_RANGES 0:1
set_parameter_property ENABLE_FIR AFFECTS_ELABORATION true
set_parameter_property ENABLE_FIR HDL_PARAMETER true
set_parameter_property ENABLE_FIR DISPLAY_HINT boolean

add_parameter ENABLE_EDGE_ADAPT_COEFFS INTEGER 0
set_parameter_property ENABLE_EDGE_ADAPT_COEFFS DISPLAY_NAME "Enable edge adaptive coeffcients"
set_parameter_property ENABLE_EDGE_ADAPT_COEFFS DESCRIPTION ""
set_parameter_property ENABLE_EDGE_ADAPT_COEFFS ALLOWED_RANGES 0:1
set_parameter_property ENABLE_EDGE_ADAPT_COEFFS AFFECTS_ELABORATION false
set_parameter_property ENABLE_EDGE_ADAPT_COEFFS HDL_PARAMETER true
set_parameter_property ENABLE_EDGE_ADAPT_COEFFS DISPLAY_HINT boolean

add_parameter DEFAULT_EDGE_THRESH INTEGER 7
set_parameter_property DEFAULT_EDGE_THRESH DISPLAY_NAME "Default edge threshold"
set_parameter_property DEFAULT_EDGE_THRESH DESCRIPTION ""
set_parameter_property DEFAULT_EDGE_THRESH AFFECTS_ELABORATION false
set_parameter_property DEFAULT_EDGE_THRESH HDL_PARAMETER true

add_max_in_dim_parameters
set_parameter_property MAX_IN_WIDTH  AFFECTS_ELABORATION false
set_parameter_property MAX_IN_WIDTH  HDL_PARAMETER       true
set_parameter_property MAX_IN_HEIGHT AFFECTS_ELABORATION false
set_parameter_property MAX_IN_HEIGHT HDL_PARAMETER       true
add_max_out_dim_parameters
set_parameter_property MAX_OUT_WIDTH  AFFECTS_ELABORATION false
set_parameter_property MAX_OUT_WIDTH  HDL_PARAMETER       true
set_parameter_property MAX_OUT_HEIGHT AFFECTS_ELABORATION false
set_parameter_property MAX_OUT_HEIGHT HDL_PARAMETER       true

add_parameter RUNTIME_CONTROL INTEGER 1
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Enable runtime resolution control"
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

add_parameter H_BANKS INTEGER 1
set_parameter_property H_BANKS DISPLAY_NAME "Horizontal scaling coefficient banks"
set_parameter_property H_BANKS DESCRIPTION ""
set_parameter_property H_BANKS ALLOWED_RANGES 1:32
set_parameter_property H_BANKS AFFECTS_ELABORATION false
set_parameter_property H_BANKS HDL_PARAMETER true

add_parameter V_BANKS INTEGER 1
set_parameter_property V_BANKS DISPLAY_NAME "Vertical scaling coefficient banks"
set_parameter_property V_BANKS DESCRIPTION ""
set_parameter_property V_BANKS ALLOWED_RANGES 1:32
set_parameter_property V_BANKS AFFECTS_ELABORATION false
set_parameter_property V_BANKS HDL_PARAMETER true

add_parameter H_PHASE_WIDTH INTEGER 4
set_parameter_property H_PHASE_WIDTH DISPLAY_NAME "Horizontal division bits"
set_parameter_property H_PHASE_WIDTH DESCRIPTION ""
set_parameter_property H_PHASE_WIDTH ALLOWED_RANGES 1:32
set_parameter_property H_PHASE_WIDTH AFFECTS_ELABORATION false
set_parameter_property H_PHASE_WIDTH HDL_PARAMETER true

add_parameter V_PHASE_WIDTH INTEGER 4
set_parameter_property V_PHASE_WIDTH DISPLAY_NAME "Vertical division bits"
set_parameter_property V_PHASE_WIDTH DESCRIPTION ""
set_parameter_property V_PHASE_WIDTH ALLOWED_RANGES 1:32
set_parameter_property V_PHASE_WIDTH AFFECTS_ELABORATION false
set_parameter_property V_PHASE_WIDTH HDL_PARAMETER true

add_parameter V_TAPS INTEGER 8
set_parameter_property V_TAPS DISPLAY_NAME "Vertical taps"
set_parameter_property V_TAPS DESCRIPTION ""
set_parameter_property V_TAPS ALLOWED_RANGES 1:64
set_parameter_property V_TAPS AFFECTS_ELABORATION false
set_parameter_property V_TAPS HDL_PARAMETER true

add_parameter H_TAPS INTEGER 8
set_parameter_property H_TAPS DISPLAY_NAME "Horizontal taps "
set_parameter_property H_TAPS DESCRIPTION ""
set_parameter_property H_TAPS ALLOWED_RANGES 1:64
set_parameter_property H_TAPS AFFECTS_ELABORATION false
set_parameter_property H_TAPS HDL_PARAMETER true

add_parameter NO_BLANKING INTEGER 0
set_parameter_property NO_BLANKING DISPLAY_NAME "Video has no blanking"
set_parameter_property NO_BLANKING DESCRIPTION ""
set_parameter_property NO_BLANKING ALLOWED_RANGES 0:1
set_parameter_property NO_BLANKING AFFECTS_ELABORATION false
set_parameter_property NO_BLANKING HDL_PARAMETER true
set_parameter_property NO_BLANKING DISPLAY_HINT boolean

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
		set alg_name [get_parameter_value ALGORITHM]
		set match [string compare EDGE_ADAPT $alg_name]
		if { $match != 0 } {
			set match [string compare POLYPHASE $alg_name]
		}
		if { $match == 0 } {
			set control_exists [get_parameter_value LOAD_AT_RUNTIME]
		}
	}

   add_av_st_cmd_source_port   av_st_cmd_0   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_1   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_2   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_3   1   8   8   8   8   main_clock   0
   add_av_st_cmd_source_port   av_st_cmd_4   1   8   8   8   8   main_clock   0

   add_av_st_resp_sink_port    av_st_resp_0   1   8   8   8   8   main_clock  0
   add_av_st_resp_sink_port    av_st_resp_1   1   8   8   8   8   main_clock  0

	if { $control_exists > 0 } {
      add_av_st_cmd_source_port   av_st_cmd_5   1   8   8   8   8   main_clock   0
      add_av_st_resp_sink_port    av_st_resp_2   1   8   8   8   8   main_clock  0
	}

   if { [get_parameter_value ENABLE_FIR] > 0 } {
      add_av_st_resp_sink_port    av_st_resp_3   1   8   8   8   8   main_clock   0
      if { [get_parameter_value RUNTIME_CONTROL] > 0 } {
         add_av_st_cmd_source_port   av_st_cmd_6   2   8   8   8   8   main_clock   0
         add_av_st_resp_sink_port    av_st_resp_4   1   8   8   8   8   main_clock   0
      }
   } else {
      add_av_st_cmd_source_port   av_st_cmd_7   1   8   8   8   8   main_clock   0
   }

}
