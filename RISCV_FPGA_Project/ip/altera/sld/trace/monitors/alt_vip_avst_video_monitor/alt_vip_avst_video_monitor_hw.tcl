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
# -- The Avalon-ST Video Monitor component                                                        --
# --------------------------------------------------------------------------------------------------  


package require -exact sopc 11.0

# Component specific properties
set_module_property   NAME           alt_vip_avst_video_monitor
set_module_property   DISPLAY_NAME   "Avalon-ST Video Monitor"
set_module_property   DESCRIPTION    "Monitors an Avalon-ST Video connection to facilitate debug of a video system. Data is captured from the datapath and exposed via one or more Avalon-ST source interfaces"
set_module_property   GROUP                         "DSP/Video and Image Processing"
set_module_property   VERSION                       13.1
set_module_property   AUTHOR                        "Altera Corporation"
set_module_property   INTERNAL                      false
set_module_property   EDITABLE                      false
set_module_property   ANALYZE_HDL                   false
set_module_property   OPAQUE_ADDRESS_MAP            false


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Callback for the composition of this component (tap -> avst_video_distiller -> capture_buffer)
set_module_property COMPOSE_CALLBACK snoop_composition_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# BPS, CHANNELS_IN_SEQ and CHANNELS_IN_PAR, parameters used to caracterize the Avalon-ST Video input

add_parameter             BPS                int                    8
set_parameter_property    BPS                DISPLAY_NAME           "Bits per pixel per color plane"
set_parameter_property    BPS                ALLOWED_RANGES         4:20

add_parameter             CHANNELS_IN_PAR    int                    3
set_parameter_property    CHANNELS_IN_PAR    DISPLAY_NAME           "Number of color planes in parallel"
set_parameter_property    CHANNELS_IN_PAR    ALLOWED_RANGES         1:3
set_parameter_property    CHANNELS_IN_PAR    AFFECTS_ELABORATION    true

add_parameter             CHANNELS_IN_SEQ    int                    1
set_parameter_property    CHANNELS_IN_SEQ    DISPLAY_NAME           "Number of color planes in sequence"
set_parameter_property    CHANNELS_IN_SEQ    ALLOWED_RANGES         1:3


# BUFFER_DEPTH, the number of 64-bit word that can be stored before the capture applies
# back-pressure to the avst_video_distiller and causes a temporary interruption of processing and
# the transmission of overflow messages
add_parameter             BUFFER_DEPTH       int                    256 
set_parameter_property    BUFFER_DEPTH       DISPLAY_NAME           "Size of the capture buffer"
set_parameter_property    BUFFER_DEPTH       ALLOWED_RANGES         {16 32 64 128 256 512 1024 2048 4096}
set_parameter_property    BUFFER_DEPTH       DESCRIPTION            "The size of the capture buffer"
set_parameter_property    BUFFER_DEPTH       STATUS                 experimental

# THUMBNAIL_SUPPORT, enable/disable thumbnails
add_parameter             THUMBNAIL_SUPPORT    int                  0 
set_parameter_property    THUMBNAIL_SUPPORT    DISPLAY_NAME         "Capture video pixel data"
set_parameter_property    THUMBNAIL_SUPPORT    DISPLAY_HINT         boolean
set_parameter_property    THUMBNAIL_SUPPORT    ALLOWED_RANGES       0:1
set_parameter_property    THUMBNAIL_SUPPORT    DESCRIPTION          "Capture pixel data from the video datapath. Enabling this parameter creates additional Avalon-ST output capture and Avalon-MM Master ports, which are typically connected to the Trace Debug Interconnect component"
set_parameter_property    THUMBNAIL_SUPPORT    HDL_PARAMETER        true

add_parameter             CAPTURE_SYM_WIDTH     int                    32 
set_parameter_property    CAPTURE_SYM_WIDTH     DISPLAY_NAME           "Bit width of capture interface(s)"
set_parameter_property    CAPTURE_SYM_WIDTH     ALLOWED_RANGES         {8 16 32 64 128}


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameter GUI groups									  --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
add_display_item   "Video Data Format"     BPS parameter
add_display_item   "Video Data Format"     CHANNELS_IN_PAR parameter
add_display_item   "Video Data Format"     CHANNELS_IN_SEQ parameter
add_display_item   "Capture"              CAPTURE_SYM_WIDTH parameter
add_display_item   "Capture"              THUMBNAIL_SUPPORT parameter
add_display_item   "Capture"              BUFFER_DEPTH parameter

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static components                                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Declare a clock interfaces (main_clock) and instantiate a bridge to propagate it to sub-modules
add_instance             clock_bridge                    altera_clock_bridge
add_instance             reset_bridge                    altera_reset_bridge
add_connection           clock_bridge.out_clk            reset_bridge.clk
add_interface            clock      clock                end
add_interface            reset      reset                end
set_interface_property   clock      export_of            clock_bridge.in_clk
set_interface_property   reset      export_of            reset_bridge.in_reset

add_instance             tap        altera_trace_av_st_tap
add_connection           clock_bridge.out_clk            tap.clk
add_connection           reset_bridge.out_reset          tap.reset

add_interface            din        avalon_streaming     sink  
set_interface_property   din        export_of            tap.snk
add_interface            dout       avalon_streaming     source 
set_interface_property   dout       export_of            tap.src

add_instance             monitor    altera_trace_video_monitor
add_connection           clock_bridge.out_clk            monitor.clock
add_connection           reset_bridge.out_reset          monitor.reset
add_interface            control    avalon               slave 
add_interface            capture    avalon_streaming     source
set_interface_property   capture    export_of            monitor.capture
set_interface_property   control    export_of            monitor.control    
	
add_connection           tap.tap_out     monitor.tap


proc snoop_composition_callback {} {
    set  bps              [get_parameter_value BPS]
    set  channels_in_par  [get_parameter_value CHANNELS_IN_PAR]
    
    set_instance_parameter_value   tap      MON_SYM_WIDTH      $bps
    set_instance_parameter_value   tap      MON_DATA_WIDTH     [expr $bps * $channels_in_par]
    set_instance_parameter_value   tap      MON_CHANNEL_WIDTH  0
    set_instance_parameter_value   tap      MON_ERR_WIDTH      0
    set_instance_parameter_value   tap      MON_USES_READY     1
    set_instance_parameter_value   tap      MON_USES_PACKETS   1
    set_instance_parameter_value   tap      MON_EMPTY_WIDTH    0
     #[expr $data_width / $symbol_width]
    set_instance_parameter_value   tap      MON_READY_LATENCY  1
    set_instance_parameter_value   tap      MON_MAX_CHANNEL    0
    
    set_instance_parameter_value   monitor  BPS                $bps
    set_instance_parameter_value   monitor  CHANNELS_IN_PAR    $channels_in_par
    set_instance_parameter_value   monitor  CHANNELS_IN_SEQ    [get_parameter_value CHANNELS_IN_SEQ]
    set_instance_parameter_value   monitor  BUFFER_DEPTH       [get_parameter_value BUFFER_DEPTH]
    set_instance_parameter_value   monitor  THUMBNAIL_SUPPORT  [get_parameter_value THUMBNAIL_SUPPORT]
    set_instance_parameter_value   monitor  CAPTURE_SYM_WIDTH  [get_parameter_value CAPTURE_SYM_WIDTH]
}
