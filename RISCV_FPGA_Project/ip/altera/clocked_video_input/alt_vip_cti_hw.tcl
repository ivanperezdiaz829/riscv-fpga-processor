package require -exact sopc 11.0

#General Info

set_module_property NAME alt_vip_cti
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Clocked Video Input"
set_module_property DESCRIPTION "The Clocked Video Input converts standard video formats such as BT656 and VGA to Avalon-ST Video."
set_module_property GROUP "Video and Image Processing/IO"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_vip.pdf
set_module_property AUTHOR "Altera Corporation"


set_module_property simulation_model_in_vhdl true

add_file src_hdl/alt_vipcti131_Vid2IS.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_Vid2IS_control.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_Vid2IS_av_st_output.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_Vid2IS_resolution_detection.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_Vid2IS_write_buffer.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_Vid2IS_embedded_sync_extractor.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_Vid2IS_sync_polarity_convertor.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_common_fifo.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_common_sync.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_common_sync_generation.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_common_frame_counter.v {SYNTHESIS SIMULATION}	
add_file src_hdl/alt_vipcti131_common_sample_counter.v {SYNTHESIS SIMULATION}	

add_file alt_vipcti131_cvi.sdc SDC

set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vipcti131_Vid2IS.v
set_module_property TOP_LEVEL_HDL_MODULE alt_vipcti131_Vid2IS


#Properties

add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

add_parameter BPS int 8
set_parameter_property BPS DISPLAY_NAME "Bits per pixel per color plane"
set_parameter_property BPS ALLOWED_RANGES 4:20
set_parameter_property BPS HDL_PARAMETER true
set_parameter_property BPS DISPLAY_UNITS "bits"
set_parameter_property BPS DESCRIPTION "The number of bits used per pixel, per color plane."

add_parameter NUMBER_OF_COLOUR_PLANES int 3
set_parameter_property NUMBER_OF_COLOUR_PLANES DISPLAY_NAME "Number of color planes"
set_parameter_property NUMBER_OF_COLOUR_PLANES ALLOWED_RANGES 1:4
set_parameter_property NUMBER_OF_COLOUR_PLANES HDL_PARAMETER true
set_parameter_property NUMBER_OF_COLOUR_PLANES DESCRIPTION "The number of color planes per pixel."

add_parameter COLOUR_PLANES_ARE_IN_PARALLEL int 1
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DISPLAY_NAME "Color plane transmission format"
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL ALLOWED_RANGES {0:Sequence 1:Parallel}
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL HDL_PARAMETER true
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DISPLAY_HINT radio
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DESCRIPTION "The color planes are arranged in parallel, otherwise in sequence."

add_parameter SYNC_TO int 0
set_parameter_property SYNC_TO DISPLAY_NAME "Field order"
set_parameter_property SYNC_TO ALLOWED_RANGES {"0:Field 0 first" "1:Field 1 first" "2:Any field first"}
set_parameter_property SYNC_TO HDL_PARAMETER true
set_parameter_property SYNC_TO DESCRIPTION "The field that is output first when syncing to a new video input."

add_display_item "Avalon-ST-Video Image Data Format" BPS parameter
add_display_item "Avalon-ST-Video Image Data Format" NUMBER_OF_COLOUR_PLANES parameter
add_display_item "Avalon-ST-Video Image Data Format" COLOUR_PLANES_ARE_IN_PARALLEL parameter
add_display_item "Avalon-ST-Video Image Data Format" SYNC_TO parameter

add_parameter USE_EMBEDDED_SYNCS int 0
set_parameter_property USE_EMBEDDED_SYNCS DISPLAY_NAME "Sync signals"
set_parameter_property USE_EMBEDDED_SYNCS ALLOWED_RANGES {"1:Embedded in video" "0:On separate wires"}
set_parameter_property USE_EMBEDDED_SYNCS HDL_PARAMETER true
set_parameter_property USE_EMBEDDED_SYNCS DISPLAY_HINT radio
set_parameter_property USE_EMBEDDED_SYNCS DESCRIPTION "Extract sync signals that are embedded in the video data, otherwise use separate sync signals."

add_parameter ADD_DATA_ENABLE_SIGNAL int 0
set_parameter_property ADD_DATA_ENABLE_SIGNAL DISPLAY_NAME "Add data enable signal"
set_parameter_property ADD_DATA_ENABLE_SIGNAL ALLOWED_RANGES 0:1
set_parameter_property ADD_DATA_ENABLE_SIGNAL HDL_PARAMETER true
set_parameter_property ADD_DATA_ENABLE_SIGNAL DISPLAY_HINT boolean
set_parameter_property ADD_DATA_ENABLE_SIGNAL DESCRIPTION "The vid_de signal appears and vid_datavalid becomes a true data valid signal only when separate sync mode is selected"
set_parameter_property ADD_DATA_ENABLE_SIGNAL DEFAULT_VALUE 0

add_parameter ACCEPT_COLOURS_IN_SEQ int 0
set_parameter_property ACCEPT_COLOURS_IN_SEQ DISPLAY_NAME "Allow color planes in sequence input"
set_parameter_property ACCEPT_COLOURS_IN_SEQ ALLOWED_RANGES 0:2
set_parameter_property ACCEPT_COLOURS_IN_SEQ HDL_PARAMETER true
set_parameter_property ACCEPT_COLOURS_IN_SEQ DISPLAY_HINT boolean
set_parameter_property ACCEPT_COLOURS_IN_SEQ DESCRIPTION "Include the vid_hd_sdn input signal that enables input of sequential or parallel color plane arrangements."

add_parameter USE_STD int 0
set_parameter_property USE_STD DISPLAY_NAME "Use vid_std bus"
set_parameter_property USE_STD ALLOWED_RANGES 0:1
set_parameter_property USE_STD HDL_PARAMETER true
set_parameter_property USE_STD DISPLAY_HINT boolean
set_parameter_property USE_STD DESCRIPTION "Include the vid_std input bus which allows the current standard to be read from the register map."

add_parameter STD_WIDTH int 1
set_parameter_property STD_WIDTH DISPLAY_NAME "Width of vid_std bus"
set_parameter_property STD_WIDTH ALLOWED_RANGES 1:16
set_parameter_property STD_WIDTH HDL_PARAMETER true
set_parameter_property STD_WIDTH DISPLAY_UNITS "bits"
set_parameter_property STD_WIDTH DESCRIPTION "Sets the width in bits of the vid_std bus."

add_parameter GENERATE_ANC int 0
set_parameter_property GENERATE_ANC DISPLAY_NAME "Extract ancillary packets"
set_parameter_property GENERATE_ANC ALLOWED_RANGES 0:1
set_parameter_property GENERATE_ANC HDL_PARAMETER true
set_parameter_property GENERATE_ANC DISPLAY_HINT boolean
set_parameter_property GENERATE_ANC DESCRIPTION "Enable the extraction of ancillary packets."

add_display_item "Clocked Video Parameters" USE_EMBEDDED_SYNCS parameter
add_display_item "Clocked Video Parameters" ADD_DATA_ENABLE_SIGNAL parameter
add_display_item "Clocked Video Parameters" ACCEPT_COLOURS_IN_SEQ parameter
add_display_item "Clocked Video Parameters" USE_STD parameter
add_display_item "Clocked Video Parameters" STD_WIDTH parameter
add_display_item "Clocked Video Parameters" GENERATE_ANC parameter

add_parameter INTERLACED int 0
set_parameter_property INTERLACED DISPLAY_NAME "Interlaced or progressive"
set_parameter_property INTERLACED ALLOWED_RANGES {0:Progressive 1:Interlaced}
set_parameter_property INTERLACED HDL_PARAMETER true
set_parameter_property INTERLACED DISPLAY_HINT radio
set_parameter_property INTERLACED DESCRIPTION "Before the video format has been detected it defaults to interlaced or progressive."

add_parameter H_ACTIVE_PIXELS_F0 int 1920
set_parameter_property H_ACTIVE_PIXELS_F0 DISPLAY_NAME "Width"
set_parameter_property H_ACTIVE_PIXELS_F0 ALLOWED_RANGES 32:2600
set_parameter_property H_ACTIVE_PIXELS_F0 HDL_PARAMETER true
set_parameter_property H_ACTIVE_PIXELS_F0 DISPLAY_UNITS "pixels"
set_parameter_property H_ACTIVE_PIXELS_F0 DESCRIPTION "Before the video format has been detected it defaults to this width."

add_parameter V_ACTIVE_LINES_F0 int 1080
set_parameter_property V_ACTIVE_LINES_F0 DISPLAY_NAME "Height - frame/field 0"
set_parameter_property V_ACTIVE_LINES_F0 ALLOWED_RANGES 32:2600
set_parameter_property V_ACTIVE_LINES_F0 HDL_PARAMETER true
set_parameter_property V_ACTIVE_LINES_F0 DISPLAY_UNITS "pixels"
set_parameter_property V_ACTIVE_LINES_F0 DESCRIPTION "Before the video format has been detected it defaults to this height."

add_parameter V_ACTIVE_LINES_F1 int 480
set_parameter_property V_ACTIVE_LINES_F1 DISPLAY_NAME "Height - field 1"
set_parameter_property V_ACTIVE_LINES_F1 ALLOWED_RANGES 32:1300
set_parameter_property V_ACTIVE_LINES_F1 HDL_PARAMETER true
set_parameter_property V_ACTIVE_LINES_F1 DISPLAY_UNITS "pixels"
set_parameter_property V_ACTIVE_LINES_F1 DESCRIPTION "Before the video format has been detected it defaults to this height."

add_display_item "Avalon-ST-Video Initial Control Packet" INTERLACED parameter
add_display_item "Avalon-ST-Video Initial Control Packet" H_ACTIVE_PIXELS_F0 parameter
add_display_item "Avalon-ST-Video Initial Control Packet" V_ACTIVE_LINES_F0 parameter
add_display_item "Avalon-ST-Video Initial Control Packet" V_ACTIVE_LINES_F1 parameter

add_parameter FIFO_DEPTH int 1920
set_parameter_property FIFO_DEPTH DISPLAY_NAME "Pixel FIFO size"
set_parameter_property FIFO_DEPTH ALLOWED_RANGES 32:65000
set_parameter_property FIFO_DEPTH HDL_PARAMETER true
set_parameter_property FIFO_DEPTH DISPLAY_UNITS "pixels"
set_parameter_property FIFO_DEPTH DESCRIPTION "The depth of the FIFO that is used for clock crossing and back-pressure absorbing."

add_parameter CLOCKS_ARE_SAME int 0
set_parameter_property CLOCKS_ARE_SAME DISPLAY_NAME "Video in and out use the same clock"
set_parameter_property CLOCKS_ARE_SAME ALLOWED_RANGES 0:1
set_parameter_property CLOCKS_ARE_SAME HDL_PARAMETER true
set_parameter_property CLOCKS_ARE_SAME DISPLAY_HINT boolean
set_parameter_property CLOCKS_ARE_SAME DESCRIPTION "Turn on if the video clock and the system clock are the same."

add_parameter USE_CONTROL int 0
set_parameter_property USE_CONTROL DISPLAY_NAME "Use control port"
set_parameter_property USE_CONTROL ALLOWED_RANGES 0:1
set_parameter_property USE_CONTROL HDL_PARAMETER true
set_parameter_property USE_CONTROL DISPLAY_HINT boolean
set_parameter_property USE_CONTROL DESCRIPTION "Enable the Avalon-MM slave port that can be used for control."

add_parameter GENERATE_SYNC int 0
set_parameter_property GENERATE_SYNC DISPLAY_NAME "Generate synchronization outputs"
set_parameter_property GENERATE_SYNC ALLOWED_RANGES {0:No 1:Yes 2:Only}
set_parameter_property GENERATE_SYNC HDL_PARAMETER true
set_parameter_property GENERATE_SYNC DESCRIPTION "Include the sof and sof_locked output signals that can be used for synchronization."

add_display_item "General Parameters" FIFO_DEPTH parameter
add_display_item "General Parameters" CLOCKS_ARE_SAME parameter
add_display_item "General Parameters" USE_CONTROL parameter
add_display_item "General Parameters" GENERATE_SYNC parameter
 
#define the is_clk_rst - this is the only non parameter dependent interface
add_interface is_clk_rst clock sink
add_interface_port is_clk_rst is_clk clk input 1
add_interface_port is_clk_rst rst reset input 1

#the elaboration callback
set_module_property ELABORATION_CALLBACK cvi_elaboration_callback
set_module_property VALIDATION_CALLBACK cvi_validation_callback

proc cvi_validation_callback {} {
    set_parameter_property ADD_DATA_ENABLE_SIGNAL ENABLED false
    set use_embed_syncs [get_parameter_value USE_EMBEDDED_SYNCS]
    set add_de_signal [get_parameter_value ADD_DATA_ENABLE_SIGNAL]   
    set family [get_parameter_value FAMILY]	
	
    if {$use_embed_syncs == 0} {
       set_parameter_property ADD_DATA_ENABLE_SIGNAL ENABLED true
       if {$add_de_signal == 1} {
	      send_message warning "The vid_de signal appears and indicates active picture. The vid_datavalid signal becomes a true data valid signal and indicates vid_data is valid."
       } else {
          send_message warning "The vid_datavalid signal indicates active picture."
       } 
    }
}

proc cvi_elaboration_callback {} {
    set add_de_signal [get_parameter_value ADD_DATA_ENABLE_SIGNAL]

	# Control Port
	set use_control [get_parameter_value USE_CONTROL]
	if { $use_control==1 } {
		add_interface control avalon slave is_clk_rst
		set_interface_property control addressAlignment NATIVE		
		set_interface_property control addressSpan 8
		set_interface_property control isMemoryDevice 0
		set_interface_property control readWaitTime 0
		set_interface_property control writeWaitTime 0
		#associate control status_update_irq
		add_interface_port control av_address address input 4
		add_interface_port control av_read read input 1
		add_interface_port control av_readdata readdata output 16
		add_interface_port control av_write write input 1
		add_interface_port control av_writedata writedata input 16
		
		# Interrupt port
		add_interface status_update_irq interrupt end is_clk_rst
		add_interface_port status_update_irq status_update_int irq output 1
		set_interface_property status_update_irq associatedAddressablePoint control
	}

	# Avalon streaming input port
	set color_planes_are_in_parallel [get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL]
	set number_of_color_planes [get_parameter_value NUMBER_OF_COLOUR_PLANES]
	set bps [get_parameter_value BPS]
	if { $color_planes_are_in_parallel == 0 } {
		set symbols_per_beat 1
		set data_width $bps
	} else {
		set symbols_per_beat $number_of_color_planes
		set data_width [expr $bps * $number_of_color_planes]
	}
	add_interface dout avalon_streaming source is_clk_rst
	set_interface_property dout dataBitsPerSymbol $bps
	set_interface_property dout symbolsPerBeat $symbols_per_beat
	set_interface_property dout readyLatency 1
	add_interface_port dout is_data data output $data_width
	add_interface_port dout is_valid valid output 1
	add_interface_port dout is_ready ready input 1
	add_interface_port dout is_sop startofpacket output 1
	add_interface_port dout is_eop endofpacket output 1
	
	
	# Video signals - SOPC Builder needs to treat these as asynchronous signals
	add_interface clocked_video conduit sink
	set clocks_are_same [get_parameter_value CLOCKS_ARE_SAME]
	if { $clocks_are_same == 0 } {
		add_interface_port clocked_video vid_clk export input 1
	} 
	
	add_interface_port clocked_video vid_data export input $data_width
	add_interface_port clocked_video overflow export output 1
	add_interface_port clocked_video vid_datavalid export input 1
	add_interface_port clocked_video vid_locked export input 1
	
	if { $use_control==1 } {
		set use_std [get_parameter_value USE_STD]
		if { $use_std != 0 } {
			set std_width [get_parameter_value STD_WIDTH]
			add_interface_port clocked_video vid_std export input $std_width	
		}
		
		set generate_sync [get_parameter_value GENERATE_SYNC]
		if { $generate_sync!=0 } {
			add_interface_port clocked_video refclk_div export output 1
			add_interface_port clocked_video sof_locked export output 1
			add_interface_port clocked_video sof export output 1
            if { $generate_sync==2 } {
                set_interface_property dout ENABLED false
            }
		}
	}
		
	set use_embedded_syncs [get_parameter_value USE_EMBEDDED_SYNCS]
	if { $use_embedded_syncs == 0 } {	
		add_interface_port clocked_video vid_v_sync export input 1		
		add_interface_port clocked_video vid_h_sync export input 1
		add_interface_port clocked_video vid_f export input 1
        if {$add_de_signal == 1} {
           add_interface_port clocked_video vid_de export input 1
		}
	}
	
	set accept_colours_in_seq [get_parameter_value ACCEPT_COLOURS_IN_SEQ]
	if { $color_planes_are_in_parallel == 1 && $accept_colours_in_seq != 0 } {
		add_interface_port clocked_video vid_hd_sdn export input 1
	}
	

	
}

