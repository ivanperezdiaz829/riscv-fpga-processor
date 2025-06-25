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
set_module_property   NAME           altera_trace_video_monitor
set_module_property   DISPLAY_NAME   "Avalon-ST Video Monitor Core"
set_module_property   DESCRIPTION    "Monitors an Avalon-ST Video connection to facilitate debug of a video system. Data is captured from the datapath and exposed via one or more Avalon-ST source interfaces"
set_module_property   GROUP                         "DSP/Video and Image Processing"
set_module_property   VERSION                       13.1
set_module_property   AUTHOR                        "Altera Corporation"
set_module_property   INTERNAL                      true
set_module_property   EDITABLE                      false
set_module_property   ANALYZE_HDL                   false


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

# The chain of components to compose (tap -> avst_video_distiller -> capture_buffer)
add_instance    tap                  altera_trace_video_tap_bridge
add_instance    monitor              altera_trace_av_st_monitor

# Declare a clock interfaces (main_clock) and instantiate a bridge to propagate it to sub-modules
add_instance               clock_bridge                 altera_clock_bridge
add_instance               reset_bridge                 altera_reset_bridge
add_connection             clock_bridge.out_clk         reset_bridge.clk
add_interface              clock      clock             end
add_interface              reset      reset             end
set_interface_property     clock      export_of         clock_bridge.in_clk
set_interface_property     reset      export_of         reset_bridge.in_reset

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Composition callbacks                                                                        --
# -- Chaining the components, wiring up the clocks and exposing external interfaces               --                                                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# compose_alt_vip_monitor
# \param    monitor_name,       name of the alt_vip_debug_capture instance
# \param    msg_clock,          the clock interface for the Avalon-ST connection to the distiller
# \param    msg_reset,          the reset interface (associated to msg_clock)
proc compose_alt_trace_tap {tap_name msg_clock msg_reset symbol_width data_width } {
    set_instance_parameter_value   $tap_name      MON_SYM_WIDTH      $symbol_width
    set_instance_parameter_value   $tap_name      MON_DATA_WIDTH     $data_width
    set_instance_parameter_value   $tap_name      MON_CHANNEL_WIDTH  0
    set_instance_parameter_value   $tap_name      MON_ERR_WIDTH      0
    set_instance_parameter_value   $tap_name      MON_USES_READY     1
    set_instance_parameter_value   $tap_name      MON_USES_PACKETS   1
    set_instance_parameter_value   $tap_name      MON_EMPTY_WIDTH    0
     #[expr $data_width / $symbol_width]
    set_instance_parameter_value   $tap_name      MON_READY_LATENCY  1
    set_instance_parameter_value   $tap_name      MON_MAX_CHANNEL    0

    add_connection                 $msg_clock     $tap_name.clk
    add_connection                 $msg_reset     $tap_name.reset
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Composition callbacks                                                                        --
# -- Chaining the components, wiring up the clocks and exposing external interfaces               --                                                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
# compose_alt_vip_monitor
# \param    monitor_name,       name of the alt_vip_monitor instance
# \param    msg_clock,          the clock interface for the Avalon-ST connection to the distiller
# \param    msg_reset,          the reset interface (associated to msg_clock)
# \param    msg_width,          the width of the Avalon-ST connection between the distiller and
#                               the capture
# \param    debug_clock,        the clock interface for the input/output Avalon-ST connections to
#                               the debug fabric
# \param    debug_reset,        the reset interface (associated to debug_clock)
# \param    debug_width,        the width of the Avalon-ST debug output connection (debug_out)
# \param    buffer_depth,       number of input words (msg_width bits) that can be stored by the
#                               capture before overflow
# \param    clocks_are_same,    whether the Avalon-ST debug connections debug_in and debug_out are
#                               clocked with msg_clock and debug_clock should not be used
# \param    cmd_width,          size of the master interface to the distiller
proc compose_alt_vip_monitor {monitor_name msg_clock msg_reset symbol_width data_width } {
    set_instance_parameter_value   $monitor_name      MON_DATA_WIDTH          $data_width
    set_instance_parameter_value   $monitor_name      MON_EMPTY_WIDTH         0
     #[expr $data_width / $symbol_width]                                      
    set_instance_parameter_value   $monitor_name      MON_ERR_WIDTH           0
    set_instance_parameter_value   $monitor_name      MON_CHANNEL_WIDTH       0
    set_instance_parameter_value   $monitor_name      MON_READY_LATENCY       1
                                                                              
    set_instance_parameter_value   $monitor_name      COUNTER_WIDTHS          24
    set_instance_parameter_value   $monitor_name      BUFFER_DEPTH_WIDTH      4
    # Captured words is 1 + ceil(9 / channels_in_seq)                         
    set_instance_parameter_value   $monitor_name      TAP_CAPTURED_WORDS      6
    
    set_instance_parameter_value   $monitor_name      TRACE_OUT_SYMBOL_WIDTH  [expr [get_parameter_value CAPTURE_SYM_WIDTH] / 8]   
    
    add_connection                 $msg_clock         $monitor_name.clk
    add_connection                 $msg_reset         $monitor_name.reset
}

proc compose_alt_pixel_grabber {pixel_grabber_name msg_clock msg_reset number_symbols_in_par data_width } {
    add_instance $pixel_grabber_name     altera_trace_av_st_video_pixel_grabber_monitor
    # needs updating to include all params etc...
    set_instance_parameter_value   $pixel_grabber_name     MON_NUM_PIXELS	       [get_parameter_value    CHANNELS_IN_PAR]
    set_instance_parameter_value   $pixel_grabber_name     MON_PIXEL_WIDTH	       [get_parameter_value    BPS]
    set_instance_parameter_value   $pixel_grabber_name     FULL_TS_LENGTH          48
    set_instance_parameter_value   $pixel_grabber_name     MON_READY_LATENCY       1    
    set_instance_parameter_value   $pixel_grabber_name     TRACE_OUT_SYM_WIDTH     [expr [get_parameter_value CAPTURE_SYM_WIDTH] / 8]   
    add_connection                 $msg_clock         $pixel_grabber_name.clk
    add_connection                 $msg_reset         $pixel_grabber_name.reset
}


proc connect_with_pipeline {pipe capture_width clock reset from to} {
    add_instance $pipe altera_avalon_st_pipeline_stage
    set_instance_parameter_value     $pipe USE_PACKETS 1
    set_instance_parameter_value     $pipe BITS_PER_SYMBOL 8           
    set_instance_parameter_value     $pipe SYMBOLS_PER_BEAT  [expr $capture_width / 8]
    set_instance_parameter_value     $pipe PIPELINE_READY 1
    if {$capture_width == 8} {
       set_instance_parameter_value $pipe USE_EMPTY 0           	   
    } else {
       set_instance_parameter_value $pipe USE_EMPTY 1           	   
    }

    add_connection $clock   $pipe.cr0
    add_connection $reset   $pipe.cr0_reset
    add_connection $from    $pipe.sink0
    add_connection $pipe.source0 $to			
}


proc snoop_composition_callback {} {
    set  bps              [get_parameter_value    BPS]
    set  channels_par     [get_parameter_value    CHANNELS_IN_PAR]
    set  channels_seq     [get_parameter_value    CHANNELS_IN_SEQ]
    set  tb_support       [get_parameter_value    THUMBNAIL_SUPPORT]
    set  capture_width    [get_parameter_value    CAPTURE_SYM_WIDTH]
    
    # The size of the Avalon-MM bus between the capture and the distiller
    # ctrl_addr_width expressed in words for the slave of the distiller
    set cmd_data_width    32
    
    set  avst_clock       clock_bridge.out_clk
    set  avst_reset       reset_bridge.out_reset


    # Export Avalon-ST Video input/output interfaces for the connection monitored
    # The snoop block operates transparently, no extra registering/pipelining block is inserted into
    # the path; no back-pressure is applied (unless it is applied by the Avalon-ST Video output)
    add_interface            tap             conduit              end  
    set_interface_property   tap             export_of            tap.din

    # Export debug interface ports to connect to the debug fabric
    add_interface            control         avalon               slave 
    add_interface            capture         avalon_streaming     source
	
	set_interface_assignment capture         debug.providesServices             traceMonitor
	set_interface_assignment capture         debug.monitoredInterfaces          tap
	set_interface_assignment capture		 debug.param.virtual_register(-2) 	$channels_par
	set_interface_assignment capture		 debug.param.virtual_register(-3)	$channels_seq
	set_interface_assignment capture		 debug.param.virtual_register(-4)	$bps

    set_interface_assignment capture debug.param.setting.Enable {
        proc get_value {c i} {expr [trace_read_monitor $c $i 4] != 0}
        proc set_value {c i v} {trace_write_monitor $c $i 4 [expr ($v != 0) ? 0x301 : 0]}
        set hints boolean
    }

    # Parameterize the sub-components
    compose_alt_trace_tap    tap             $avst_clock  $avst_reset  $bps [expr $bps * $channels_par]
    compose_alt_vip_monitor  monitor         $avst_clock  $avst_reset  $bps [expr $bps * $channels_par]

    # Connect the monitor to the output of the snoop_tap
    add_connection    tap.dout0          monitor.tap_input

    # Include pixel monitor
    if {$tb_support} {
        compose_alt_pixel_grabber   pixel_monitor $avst_clock  $avst_reset $channels_par  [expr $bps * $channels_par]
		
		# Flag to show if tb_support (pixel capture) hardware is included in this monitor (0=on, !0=off)
		set_interface_assignment    capture		 debug.param.virtual_register(-5)	0
        
        set_interface_assignment capture debug.param.setting.Enable {
			# Write to both video and pixel monitors
			proc get_value {c i} {
				set vid [expr [trace_read_monitor $c $i 4]]
				if {($vid & 0x1) == 0} {
					# Disabled
					expr 0
				} else {
					set pix [expr [trace_read_monitor $c $i 36]]
					if {($pix & 0x1) != 0} {
						# Enabled with Pixel Data
						expr 2
					} else {
						# Enabled
						expr 1
					}
				}
			}
            proc set_value {c i v} {
				trace_write_monitor $c $i 4  [expr ($v != 0) ? 0x301 : 0]
				trace_write_monitor $c $i 36 [expr ($v == 2) ? 0x1 : 0]
			}
			set enum {0 Disable 1 Enable 2 {Enable with Pixel Data}}
        }

        # Register 5 b15:0 is the LFSR mask (must be 2^n - 1), b31:16 is the minimum gap.
        # Gap is calculated as min + (rand() & mask)
        set_interface_assignment capture debug.param.setting.Capture\ Rate\ per\ 1000000 {
            proc get_value {c i} {set v [trace_read_monitor $c $i 37]; expr 1000000 / (1 + (($v >> 16) & 0xFFFF) + (($v & 0xFFFF) / 2))}
            proc set_value {c i v} {
                set gap [expr 1000000/$v - 1]
                if {$gap > 98300} { set gap 98300 }
                if {$gap <= 0} {
                    set reg 0
                } else {
                    set half [expr $gap / 2]
                    for {set pow 1} {$pow < $half} {set pow [expr $pow * 2]} {}
                    set mask [expr $pow - 1]
                    set reg [expr (($gap - $mask / 2) << 16) + $mask]
                }
                trace_write_monitor $c $i 37 $reg
            }
            set range {10 1000}
        }

       # set_interface_assignment capture debug.param.setting.Colour\ Space {
       #     proc get_value {c i} {trace_read_monitor $c $i -1}
       #     proc set_value {c i v} {trace_write_monitor $c $i -1 $v}
       #     set enum {0 RGB 4 {YCbCr 4:4:4 HD} 5 {YCbCr 4:2:2 HD} 6 {YCbCr 4:2:0 HD} 8 {YCbCr 4:4:4 SD} 9 {YCbCr 4:2:2 SD} 10 {YCbCr 4:2:0 SD}}
       # }


        add_connection           tap.dout1                            pixel_monitor.tap_input

		# Mux capture interfaces together
		add_instance capture_mux multiplexer
		set_instance_parameter_value capture_mux bitsPerSymbol 8
		set_instance_parameter_value capture_mux symbolsPerBeat [expr $capture_width / 8]
		set_instance_parameter_value capture_mux errorWidth 0
		set_instance_parameter_value capture_mux outChannelWidth 1
		set_instance_parameter_value capture_mux numInputInterfaces 2
		set_instance_parameter_value capture_mux usePackets true
		set_instance_parameter_value capture_mux useHighBitsOfChannel false
		set_instance_parameter_value capture_mux packetScheduling true
		add_connection $avst_clock capture_mux.clk
		add_connection $avst_reset capture_mux.reset
		connect_with_pipeline monitor_pipe $capture_width $avst_clock $avst_reset monitor.capture capture_mux.in0
		connect_with_pipeline pixel_pipe $capture_width $avst_clock $avst_reset pixel_monitor.capture capture_mux.in1

		# Remove bits which indicate input interface
		add_instance capture_channel altera_avalon_st_channel_stripper
		set_instance_parameter_value capture_channel SYMBOL_WIDTH 8
		set_instance_parameter_value capture_channel DATA_WIDTH $capture_width
		
		add_connection $avst_clock capture_channel.clk
		add_connection $avst_reset capture_channel.reset
		add_connection capture_mux.out capture_channel.in

		# Split control interface into two halves
		add_instance control_bridge altera_avalon_mm_bridge
		set_instance_parameter_value control_bridge ADDRESS_WIDTH 8
		set_instance_parameter_value control_bridge MAX_PENDING_RESPONSES 1
		set_instance_parameter_value control_bridge PIPELINE_COMMAND 0
		set_instance_parameter_value control_bridge PIPELINE_RESPONSE 0
		add_connection $avst_clock control_bridge.clk
		add_connection $avst_reset control_bridge.reset
		set c0 [add_connection control_bridge.m0 monitor.csr_s]
		set_connection_parameter $c0 baseAddress 0
		set c1 [add_connection control_bridge.m0 pixel_monitor.csr_s]
		set_connection_parameter $c1 baseAddress 0x80

        set_interface_property   control         export_of            control_bridge.s0    
        set_interface_property   capture         export_of            capture_channel.out
		set_interface_assignment capture debug.interfaceGroup {associatedControl control}
    } else {
		set_interface_assignment capture		 debug.param.virtual_register(-5)	1
        set_interface_property   control         export_of            				monitor.csr_s    
        set_interface_property   capture         export_of            				monitor.capture
		set_interface_assignment capture debug.interfaceGroup {associatedControl control}
    }

    set_interface_assignment capture debug.typeName alt_vip_avst_video_monitor.capture
    set_instance_parameter_value monitor TYPE_NUM 272
}
