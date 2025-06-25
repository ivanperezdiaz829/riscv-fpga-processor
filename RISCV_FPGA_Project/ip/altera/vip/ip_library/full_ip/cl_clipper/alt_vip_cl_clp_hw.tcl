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
#--                                                                                               --
#-- _hw.tcl compose file for Component Library Clipper (Clipper 2)                                  --
#--                                                                                               --
#---------------------------------------------------------------------------------------------------


source ../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl

declare_general_module_info
set_module_property NAME alt_vip_cl_clp
set_module_property DISPLAY_NAME "Clipper II"
set_module_property DESCRIPTION "The Clipper II clips a specified portion from an input video field."

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Validation callback to check legality of parameter set
set_module_property VALIDATION_CALLBACK clp_validation_callback

# Callback for the composition of this component
set_module_property COMPOSE_CALLBACK clp_composition_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

set x_min 20
set x_max 4096
set y_min 20
set y_max 4096

add_device_family_parameter

add_max_in_dim_parameters
set_parameter_property MAX_IN_WIDTH   DEFAULT_VALUE       1920
set_parameter_property MAX_IN_WIDTH   ENABLED             true
set_parameter_property MAX_IN_WIDTH   AFFECTS_ELABORATION true

set_parameter_property MAX_IN_HEIGHT  DEFAULT_VALUE       1080
set_parameter_property MAX_IN_HEIGHT  ENABLED             true
set_parameter_property MAX_IN_HEIGHT  AFFECTS_ELABORATION true

add_parameter BITS_PER_SYMBOL int 10
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES 4:20
set_parameter_property BITS_PER_SYMBOL DESCRIPTION "The number of bits per Avalon-ST symbol"
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER true
set_parameter_property BITS_PER_SYMBOL AFFECTS_ELABORATION true

#add_parameter NUMBER_OF_COLOR_PLANES int 3
#set_parameter_property NUMBER_OF_COLOR_PLANES DISPLAY_NAME "Number of color planes"
#set_parameter_property NUMBER_OF_COLOR_PLANES ALLOWED_RANGES 1:4
#set_parameter_property NUMBER_OF_COLOR_PLANES DESCRIPTION "Number of color planes in sequence or parallel"
#set_parameter_property NUMBER_OF_COLOR_PLANES HDL_PARAMETER true
#set_parameter_property NUMBER_OF_COLOR_PLANES AFFECTS_ELABORATION true

#add_parameter COLOR_PLANES_ARE_IN_PARALLEL int 1
#set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL DISPLAY_NAME "Color planes are in parallel"
#set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL ALLOWED_RANGES 0:1
#set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL DISPLAY_HINT boolean
#set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL DESCRIPTION "Check this box if your Avalon-ST symbols are sent in parallel"
#set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL HDL_PARAMETER true
#set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL AFFECTS_ELABORATION true

add_channels_nb_parameters {4}

add_parameter          CLIPPING_METHOD string OFFSETS
set_parameter_property CLIPPING_METHOD DISPLAY_NAME "Clipping method"
set_parameter_property CLIPPING_METHOD ALLOWED_RANGES {OFFSETS RECTANGLE}
set_parameter_property CLIPPING_METHOD DISPLAY_HINT ""
set_parameter_property CLIPPING_METHOD DESCRIPTION "Offsets mode will clip a portion of the image based on how large each offset is from the edge of the input image. Rectangle mode will clip an image of width * height dimensions from the starting left and right offset."
set_parameter_property CLIPPING_METHOD HDL_PARAMETER true
set_parameter_property CLIPPING_METHOD AFFECTS_ELABORATION true

add_parameter          LEFT_OFFSET int 10
set_parameter_property LEFT_OFFSET DISPLAY_NAME "Left Offset"
set_parameter_property LEFT_OFFSET ALLOWED_RANGES 0:1920
set_parameter_property LEFT_OFFSET DESCRIPTION "The number of pixels to the left edge of the clipping surface"
set_parameter_property LEFT_OFFSET HDL_PARAMETER true
set_parameter_property LEFT_OFFSET AFFECTS_ELABORATION true

add_parameter          RIGHT_OFFSET int 10
set_parameter_property RIGHT_OFFSET DISPLAY_NAME "Right Offset"
set_parameter_property RIGHT_OFFSET ALLOWED_RANGES 0:1920
set_parameter_property RIGHT_OFFSET DESCRIPTION "The number of pixels from the right edge of the image to the right edge of the clipping surface"
set_parameter_property RIGHT_OFFSET HDL_PARAMETER true
set_parameter_property RIGHT_OFFSET AFFECTS_ELABORATION true
set_parameter_property RIGHT_OFFSET ENABLED true

add_parameter          TOP_OFFSET int 10
set_parameter_property TOP_OFFSET DISPLAY_NAME "Top Offset"
set_parameter_property TOP_OFFSET ALLOWED_RANGES 0:1080
set_parameter_property TOP_OFFSET DESCRIPTION "The number of pixels to the top edge of the clipping surface"
set_parameter_property TOP_OFFSET HDL_PARAMETER true
set_parameter_property TOP_OFFSET AFFECTS_ELABORATION true

add_parameter          BOTTOM_OFFSET int 10
set_parameter_property BOTTOM_OFFSET DISPLAY_NAME "Bottom Offset"
set_parameter_property BOTTOM_OFFSET ALLOWED_RANGES 0:1080
set_parameter_property BOTTOM_OFFSET DESCRIPTION "The number of pixels from the bottom edge of the image to the bottom edge of the clipping surface"
set_parameter_property BOTTOM_OFFSET HDL_PARAMETER true
set_parameter_property BOTTOM_OFFSET AFFECTS_ELABORATION true
set_parameter_property BOTTOM_OFFSET ENABLED true

add_parameter          RECTANGLE_WIDTH int 10
set_parameter_property RECTANGLE_WIDTH DISPLAY_NAME "Width"
set_parameter_property RECTANGLE_WIDTH ALLOWED_RANGES 0:1920
set_parameter_property RECTANGLE_WIDTH DESCRIPTION "The width of the output image."
set_parameter_property RECTANGLE_WIDTH HDL_PARAMETER false
set_parameter_property RECTANGLE_WIDTH AFFECTS_ELABORATION true
set_parameter_property RECTANGLE_WIDTH ENABLED false

add_parameter          RECTANGLE_HEIGHT int 10
set_parameter_property RECTANGLE_HEIGHT DISPLAY_NAME "Height"
set_parameter_property RECTANGLE_HEIGHT ALLOWED_RANGES 0:1080
set_parameter_property RECTANGLE_HEIGHT DESCRIPTION "The height of the output image."
set_parameter_property RECTANGLE_HEIGHT HDL_PARAMETER false
set_parameter_property RECTANGLE_HEIGHT AFFECTS_ELABORATION true
set_parameter_property RECTANGLE_HEIGHT ENABLED false

add_parameter          RUNTIME_CONTROL int 1
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Enable runtime control of clipping parameters"
set_parameter_property RUNTIME_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_CONTROL DISPLAY_HINT boolean
set_parameter_property RUNTIME_CONTROL DESCRIPTION "Allows the output frame dimensions to be altered through the Control (Avalon-MM Slave) port. If this option is not selected the output dimensions are fixed to the specified values."
set_parameter_property RUNTIME_CONTROL HDL_PARAMETER true
set_parameter_property RUNTIME_CONTROL AFFECTS_ELABORATION true

add_display_item "Video Data Format" MAX_IN_WIDTH parameter
add_display_item "Video Data Format" MAX_IN_HEIGHT parameter
add_display_item "Video Data Format" BITS_PER_SYMBOL parameter
add_display_item "Video Data Format" NUMBER_OF_COLOR_PLANES parameter
add_display_item "Video Data Format" COLOR_PLANES_ARE_IN_PARALLEL parameter

add_display_item "Clipping Options" RUNTIME_CONTROL parameter
add_display_item "Clipping Options" CLIPPING_METHOD parameter
add_display_item "Clipping Options" LEFT_OFFSET parameter
add_display_item "Clipping Options" TOP_OFFSET parameter
add_display_item "Clipping Options" RIGHT_OFFSET parameter
add_display_item "Clipping Options" BOTTOM_OFFSET parameter
add_display_item "Clipping Options" RECTANGLE_WIDTH parameter
add_display_item "Clipping Options" RECTANGLE_HEIGHT parameter


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static components                                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# The chain of components to compose :
add_instance   video_in             alt_vip_video_input_bridge     $isVersion
add_instance   user_packet_demux    alt_vip_packet_demux           $isVersion
add_instance   clipper_core         alt_vip_clipper_alg_core       $isVersion
add_instance   user_packet_mux      alt_vip_packet_mux             $isVersion
add_instance   video_out            alt_vip_video_output_bridge    $isVersion
add_instance   scheduler            alt_vip_clipper_scheduler      $isVersion
add_instance   av_st_clk_bridge     altera_clock_bridge            $acdsVersion
add_instance   av_st_reset_bridge   altera_reset_bridge            $acdsVersion

# Top level interfaces :
add_interface   main_clock   clock              end
add_interface   main_reset   reset              end
add_interface   din          avalon_streaming   sink
add_interface   dout         avalon_streaming   source

set_interface_property   main_clock   export_of   av_st_clk_bridge.in_clk
set_interface_property   main_reset   export_of   av_st_reset_bridge.in_reset
set_interface_property   din          export_of   video_in.av_st_vid_din
set_interface_property   dout         export_of   video_out.av_st_vid_dout

set_interface_property main_clock PORT_NAME_MAP {main_clock in_clk}
set_interface_property main_reset PORT_NAME_MAP {main_reset in_reset}

#parameter settings that don't change for input video bridge
set_instance_parameter_value   video_in   NUMBER_OF_PIXELS_IN_PARALLEL   1
set_instance_parameter_value   video_in   VIDEO_PROTOCOL_NO              1
set_instance_parameter_value   video_in   SRC_WIDTH                      8
set_instance_parameter_value   video_in   DST_WIDTH                      8
set_instance_parameter_value   video_in   CONTEXT_WIDTH                  8
set_instance_parameter_value   video_in   TASK_WIDTH                     8
set_instance_parameter_value   video_in   RESP_SRC_ADDRESS               0
set_instance_parameter_value   video_in   RESP_DST_ADDRESS               0
set_instance_parameter_value   video_in   DATA_SRC_ADDRESS               0

#parameter settings that don't change for demux
set_instance_parameter_value   user_packet_demux   SRC_WIDTH                     8
set_instance_parameter_value   user_packet_demux   DST_WIDTH                     8
set_instance_parameter_value   user_packet_demux   CONTEXT_WIDTH                 8
set_instance_parameter_value   user_packet_demux   TASK_WIDTH                    8
set_instance_parameter_value   user_packet_demux   USER_WIDTH                    0
set_instance_parameter_value   user_packet_demux   NUM_OUTPUTS                   2
set_instance_parameter_value   user_packet_demux   CLIP_ADDRESS_BITS             0
set_instance_parameter_value   user_packet_demux   REGISTER_OUTPUT               1

#parameter settings that don't change for the scaler core
set_instance_parameter_value   clipper_core   SRC_WIDTH              8
set_instance_parameter_value   clipper_core   DST_WIDTH              8
set_instance_parameter_value   clipper_core   CONTEXT_WIDTH          8
set_instance_parameter_value   clipper_core   TASK_WIDTH             8

#parameter settings that don't change for the user_packet_mux
set_instance_parameter_value   user_packet_mux   SRC_WIDTH              8
set_instance_parameter_value   user_packet_mux   DST_WIDTH              8
set_instance_parameter_value   user_packet_mux   CONTEXT_WIDTH          8
set_instance_parameter_value   user_packet_mux   TASK_WIDTH             8
set_instance_parameter_value   user_packet_mux   NUM_INPUTS             2
set_instance_parameter_value   user_packet_mux   USER_WIDTH             0

#parameter settings that don't change for output video bridge
set_instance_parameter_value   video_out   NUMBER_OF_PIXELS_IN_PARALLEL   1
set_instance_parameter_value   video_out   VIDEO_PROTOCOL_NO              1
set_instance_parameter_value   video_out   SRC_WIDTH                      8
set_instance_parameter_value   video_out   DST_WIDTH                      8
set_instance_parameter_value   video_out   CONTEXT_WIDTH                  8
set_instance_parameter_value   video_out   TASK_WIDTH                     8

# Av-ST Clock connections :
add_connection   av_st_clk_bridge.out_clk   av_st_reset_bridge.clk
add_connection   av_st_clk_bridge.out_clk   video_in.main_clock
add_connection   av_st_clk_bridge.out_clk   user_packet_demux.main_clock
add_connection   av_st_clk_bridge.out_clk   clipper_core.main_clock
add_connection   av_st_clk_bridge.out_clk   user_packet_mux.main_clock
add_connection   av_st_clk_bridge.out_clk   video_out.main_clock
add_connection   av_st_clk_bridge.out_clk   scheduler.main_clock

# Av-ST Reset connections :
add_connection   av_st_reset_bridge.out_reset   video_in.main_reset
add_connection   av_st_reset_bridge.out_reset   user_packet_demux.main_reset
add_connection   av_st_reset_bridge.out_reset   clipper_core.main_reset
add_connection   av_st_reset_bridge.out_reset   user_packet_mux.main_reset
add_connection   av_st_reset_bridge.out_reset   video_out.main_reset
add_connection   av_st_reset_bridge.out_reset   scheduler.main_reset

# Datapath connections
add_connection   video_in.av_st_dout              user_packet_demux.av_st_din
add_connection   user_packet_demux.av_st_dout_1   user_packet_mux.av_st_din_1
add_connection   user_packet_demux.av_st_dout_0   clipper_core.av_st_din
add_connection   user_packet_mux.av_st_dout       video_out.av_st_din

# Scheduler/command connections
add_connection   scheduler.av_st_cmd_video_in          video_in.av_st_cmd
add_connection   scheduler.av_st_cmd_core          clipper_core.av_st_cmd
add_connection   video_in.av_st_resp            scheduler.av_st_resp_video_in


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Validation callback                                                                          --
# -- Checking the legality of the parameter set chosen by the user                                --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc clp_validation_callback {} {
    #set symbols_in_seq [get_parameter_value SYMBOLS_IN_SEQ]
    #set symbols_in_par [get_parameter_value SYMBOLS_IN_PAR]
    set family [get_parameter_value FAMILY]

    #if { $symbols_in_seq > 1 } {
    #   if { $symbols_in_par > 1 } {
    #      send_message error "The symbols for each pixel must be transmitted either entirely in sequence or entirely in parallel"
    #   }
    #}

    set limit [get_parameter_value BITS_PER_SYMBOL]
    set limit [expr {pow(2, $limit)}]
    set limit [expr {$limit - 1}]
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Composition callback                                                                        --
# -- Chaining the components, wiring up the clocks and exposing external interfaces               --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc clp_composition_callback {} {
    global isVersion

    set cmp [string compare [get_parameter_value CLIPPING_METHOD] "RECTANGLE"]
    if { $cmp == 0 } {
        # Rectangle mode
        set_parameter_property RECTANGLE_WIDTH ENABLED true
        set_parameter_property RECTANGLE_HEIGHT ENABLED true
        set_parameter_property RIGHT_OFFSET ENABLED false
        set_parameter_property BOTTOM_OFFSET ENABLED false
        set right_offset [get_parameter_value RECTANGLE_WIDTH]
        set bottom_offset [get_parameter_value RECTANGLE_HEIGHT]
        set rectangle_mode 1
    } else {
        # Offsets mode
        set_parameter_property RECTANGLE_WIDTH ENABLED false
        set_parameter_property RECTANGLE_HEIGHT ENABLED false
        set_parameter_property RIGHT_OFFSET ENABLED true
        set_parameter_property BOTTOM_OFFSET ENABLED true
        set right_offset [get_parameter_value RIGHT_OFFSET]
        set bottom_offset [get_parameter_value BOTTOM_OFFSET]
        set rectangle_mode 0
    }

    set colours_in_par [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    set number_of_colours [get_parameter_value NUMBER_OF_COLOR_PLANES]

    set bits_per_symbol [get_parameter_value BITS_PER_SYMBOL]
    set num_par_symbols [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set video_data_width [ expr $bits_per_symbol * [ expr $colours_in_par > 0 ? $num_par_symbols : 1]]

    set_instance_parameter_value   video_in   BITS_PER_SYMBOL               [get_parameter_value BITS_PER_SYMBOL]
    set_instance_parameter_value   video_in   NUMBER_OF_COLOR_PLANES        $number_of_colours
    set_instance_parameter_value   video_in   COLOR_PLANES_ARE_IN_PARALLEL  $colours_in_par
    set_instance_parameter_value   video_in   DEFAULT_LINE_LENGTH           [get_parameter_value MAX_IN_WIDTH]

    #send_message info "data_width:$video_data_width, bps:$bits_per_symbol, number_of_colours:$number_of_colours, colours_in_par:$colours_in_par"

    #parameterise the user_packet_demux
    set_instance_parameter_value   user_packet_demux   DATA_WIDTH                    $video_data_width

    #parameterise the clipper core
    set_instance_parameter_value   clipper_core   NUMBER_OF_COLOR_PLANES        $number_of_colours
    set_instance_parameter_value   clipper_core   COLOR_PLANES_ARE_IN_PARALLEL  $colours_in_par
    set_instance_parameter_value   clipper_core   BITS_PER_SYMBOL               [get_parameter_value BITS_PER_SYMBOL]
    set_instance_parameter_value   clipper_core   MAX_IN_WIDTH                  [get_parameter_value MAX_IN_WIDTH]
    set_instance_parameter_value   clipper_core   LEFT_OFFSET                   [get_parameter_value LEFT_OFFSET]
    set_instance_parameter_value   clipper_core   RIGHT_OFFSET                  $right_offset

    #parameterise the user_packet_mux
    set_instance_parameter_value   user_packet_mux   DATA_WIDTH                    $video_data_width

    #parameterise the output video bridge
    set_instance_parameter_value   video_out   BITS_PER_SYMBOL               [get_parameter_value BITS_PER_SYMBOL]
    set_instance_parameter_value   video_out   NUMBER_OF_COLOR_PLANES        $number_of_colours
    set_instance_parameter_value   video_out   COLOR_PLANES_ARE_IN_PARALLEL  $colours_in_par

    #parameterise the scheduler
    set_instance_parameter_value   scheduler   MAX_IN_HEIGHT             [get_parameter_value MAX_IN_HEIGHT]
    set_instance_parameter_value   scheduler   MAX_IN_WIDTH              [get_parameter_value MAX_IN_WIDTH]
    set_instance_parameter_value   scheduler   RUNTIME_CONTROL           [get_parameter_value RUNTIME_CONTROL]
    set_instance_parameter_value   scheduler   RECTANGLE_MODE            $rectangle_mode
    set_instance_parameter_value   scheduler   LEFT_OFFSET               [get_parameter_value LEFT_OFFSET]
    set_instance_parameter_value   scheduler   RIGHT_OFFSET              $right_offset
    set_instance_parameter_value   scheduler   TOP_OFFSET                [get_parameter_value TOP_OFFSET]
    set_instance_parameter_value   scheduler   BOTTOM_OFFSET             $bottom_offset
   
    set slave_needed 0
    if  { [get_parameter_value RUNTIME_CONTROL] > 0 } {
        set slave_needed 1
    }

    if {$slave_needed > 0 } {
        add_instance     control_slave                       alt_vip_control_slave $isVersion

        add_connection   av_st_clk_bridge.out_clk            control_slave.main_clock
        add_connection   av_st_reset_bridge.out_reset        control_slave.main_reset
        add_connection   scheduler.av_st_cmd_control_slave   control_slave.av_st_cmd
        add_connection   control_slave.av_st_resp            scheduler.av_st_resp_control_slave

        add_interface   control    avalon   slave
        set_interface_property   control   export_of   control_slave.av_mm_control

        # Set parameters
        set_instance_parameter_value   control_slave   NUM_READ_REGISTERS              0
        set_instance_parameter_value   control_slave   NUM_TRIGGER_REGISTERS           4
        set_instance_parameter_value   control_slave   NUM_BLOCKING_TRIGGER_REGISTERS  0
        set_instance_parameter_value   control_slave   NUM_RW_REGISTERS                0
        set_instance_parameter_value   control_slave   NUM_INTERRUPTS                  0
        set_instance_parameter_value   control_slave   MM_CONTROL_REG_BYTES            1
        set_instance_parameter_value   control_slave   MM_READ_REG_BYTES               1
        set_instance_parameter_value   control_slave   MM_TRIGGER_REG_BYTES            4
        set_instance_parameter_value   control_slave   MM_RW_REG_BYTES                 1
        set_instance_parameter_value   control_slave   MM_ADDR_WIDTH                   3
        set_instance_parameter_value   control_slave   SRC_WIDTH                       8
        set_instance_parameter_value   control_slave   DST_WIDTH                       8
        set_instance_parameter_value   control_slave   TASK_WIDTH                      8
        set_instance_parameter_value   control_slave   CONTEXT_WIDTH                   8
        set_instance_parameter_value   control_slave   RESP_SOURCE                     0
        set_instance_parameter_value   control_slave   RESP_DEST                       0
        set_instance_parameter_value   control_slave   RESP_CONTEXT                    0
        set_instance_parameter_value   control_slave   DOUT_SOURCE                     0
        set_instance_parameter_value   control_slave   USE_MEMORY                      0
        set_instance_parameter_value   control_slave   PIPELINE_READ                   1
        set_instance_parameter_value   control_slave   PIPELINE_RESPONSE               0
        set_instance_parameter_value   control_slave   PIPELINE_DATA                   0
        set_instance_parameter_value   control_slave   DATA_INPUT                      0
        set_instance_parameter_value   control_slave   DATA_OUTPUT                     0
        set_instance_parameter_value   control_slave   FAST_REGISTER_UPDATES           0
    }

    add_connection   clipper_core.av_st_dout               user_packet_mux.av_st_din_0
    add_connection   scheduler.av_st_cmd_video_out         video_out.av_st_cmd
    add_connection   scheduler.av_st_cmd_user_packet_mux   user_packet_mux.av_st_cmd
}
