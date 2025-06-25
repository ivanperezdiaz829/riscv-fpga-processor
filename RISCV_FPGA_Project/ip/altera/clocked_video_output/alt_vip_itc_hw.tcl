package require -exact sopc 11.0

#General Info

set_module_property NAME alt_vip_itc
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Clocked Video Output"
set_module_property DESCRIPTION "The Clocked Video Output converts Avalon-ST Video to standard video formats such as BT656 or VGA."
set_module_property GROUP "Video and Image Processing/IO"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_vip.pdf
set_module_property AUTHOR "Altera Corporation"

set_module_property simulation_model_in_vhdl true

add_file src_hdl/alt_vipitc131_IS2Vid.sv {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_IS2Vid_sync_compare.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_IS2Vid_calculate_mode.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_IS2Vid_control.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_IS2Vid_mode_banks.sv {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_IS2Vid_statemachine.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_fifo.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_generic_count.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_to_binary.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_sync.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_trigger_sync.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_sync_generation.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_frame_counter.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipitc131_common_sample_counter.v {SYNTHESIS SIMULATION}	
add_file alt_vipitc131_cvo.sdc SDC

set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vipitc131_IS2Vid.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vipitc131_IS2Vid

#Properties

# -- Parameters --
add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

# IMAGE DATA FORMAT
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

add_parameter BPS int 8
set_parameter_property BPS DISPLAY_NAME "Bits per pixel per color plane"
set_parameter_property BPS ALLOWED_RANGES 4:20
set_parameter_property BPS HDL_PARAMETER true
set_parameter_property BPS DISPLAY_UNITS "bits"
set_parameter_property BPS DESCRIPTION "The number of bits used per pixel, per color plane."

add_parameter INTERLACED int 0
set_parameter_property INTERLACED DISPLAY_NAME "Interlaced video"
set_parameter_property INTERLACED ALLOWED_RANGES 0:1
set_parameter_property INTERLACED HDL_PARAMETER true
set_parameter_property INTERLACED DISPLAY_HINT boolean
set_parameter_property INTERLACED DESCRIPTION "The default output format is interlaced or progressive."

add_parameter H_ACTIVE_PIXELS int 1920
set_parameter_property H_ACTIVE_PIXELS DISPLAY_NAME "Image width / Active pixels"
set_parameter_property H_ACTIVE_PIXELS ALLOWED_RANGES 32:2600
set_parameter_property H_ACTIVE_PIXELS HDL_PARAMETER true
set_parameter_property H_ACTIVE_PIXELS DISPLAY_UNITS "pixels"
set_parameter_property H_ACTIVE_PIXELS DESCRIPTION "The default output format active picture width."

add_parameter V_ACTIVE_LINES int 1200
set_parameter_property V_ACTIVE_LINES DISPLAY_NAME "Image height / Active lines"
set_parameter_property V_ACTIVE_LINES ALLOWED_RANGES 32:2600
set_parameter_property V_ACTIVE_LINES HDL_PARAMETER true
set_parameter_property V_ACTIVE_LINES DISPLAY_UNITS "lines"
set_parameter_property V_ACTIVE_LINES DESCRIPTION "The default output format active picture height."

add_parameter ACCEPT_COLOURS_IN_SEQ int 0
set_parameter_property ACCEPT_COLOURS_IN_SEQ DISPLAY_NAME "Allow output of channels in sequence"
set_parameter_property ACCEPT_COLOURS_IN_SEQ ALLOWED_RANGES 0:2
set_parameter_property ACCEPT_COLOURS_IN_SEQ HDL_PARAMETER true
set_parameter_property ACCEPT_COLOURS_IN_SEQ DISPLAY_HINT boolean
set_parameter_property ACCEPT_COLOURS_IN_SEQ DESCRIPTION "Enable the output of sequential and parallel color plane arrangements."

#GENERAL
add_parameter FIFO_DEPTH int 1920
set_parameter_property FIFO_DEPTH DISPLAY_NAME "Pixel fifo size"
set_parameter_property FIFO_DEPTH ALLOWED_RANGES 32:65000
set_parameter_property FIFO_DEPTH HDL_PARAMETER true
set_parameter_property FIFO_DEPTH DISPLAY_UNITS "pixels"
set_parameter_property FIFO_DEPTH DESCRIPTION "The depth of the FIFO that is used for clock crossing and rate smoothing."

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

add_parameter NO_OF_MODES int 1
set_parameter_property NO_OF_MODES DISPLAY_NAME "Runtime configurable video modes"
set_parameter_property NO_OF_MODES ALLOWED_RANGES 1:13
set_parameter_property NO_OF_MODES HDL_PARAMETER true
set_parameter_property NO_OF_MODES DISPLAY_UNITS "modes"
set_parameter_property NO_OF_MODES DESCRIPTION "Set the number of output video formats that can be stored in parallel."
 
add_parameter THRESHOLD int 1919
set_parameter_property THRESHOLD DISPLAY_NAME "Fifo level at which to start output"
set_parameter_property THRESHOLD ALLOWED_RANGES 0:65000
set_parameter_property THRESHOLD HDL_PARAMETER true
set_parameter_property THRESHOLD DISPLAY_UNITS "pixels"
set_parameter_property THRESHOLD DESCRIPTION "Video output will start when the FIFO fill level reaches this threshold."

add_parameter STD_WIDTH int 1
set_parameter_property STD_WIDTH DISPLAY_NAME "Width of vid_std bus"
set_parameter_property STD_WIDTH ALLOWED_RANGES 1:16
set_parameter_property STD_WIDTH HDL_PARAMETER true
set_parameter_property STD_WIDTH DISPLAY_UNITS "bits"
set_parameter_property STD_WIDTH DESCRIPTION "Sets the width in bits of the vid_std bus."

add_parameter GENERATE_SYNC int 0
set_parameter_property GENERATE_SYNC DISPLAY_NAME "Accept synchronization outputs"
set_parameter_property GENERATE_SYNC ALLOWED_RANGES 0:1
set_parameter_property GENERATE_SYNC HDL_PARAMETER true
set_parameter_property GENERATE_SYNC DISPLAY_HINT boolean
set_parameter_property GENERATE_SYNC DESCRIPTION "Include the sof and sof_locked input signals, which the output video can be synchronized to."

#SYNCS
add_parameter USE_EMBEDDED_SYNCS int 0
set_parameter_property USE_EMBEDDED_SYNCS DISPLAY_NAME "Syncs signals"
set_parameter_property USE_EMBEDDED_SYNCS ALLOWED_RANGES  {"1:Embedded in video" "0:On separate wires"}
set_parameter_property USE_EMBEDDED_SYNCS HDL_PARAMETER true
set_parameter_property USE_EMBEDDED_SYNCS DISPLAY_HINT radio
set_parameter_property USE_EMBEDDED_SYNCS DESCRIPTION "Insert sync signals into the video data, otherwise use separate sync signals."

add_parameter AP_LINE int 0
set_parameter_property AP_LINE DISPLAY_NAME "Active picture line"
set_parameter_property AP_LINE ALLOWED_RANGES 0:50000
set_parameter_property AP_LINE HDL_PARAMETER true
set_parameter_property AP_LINE DESCRIPTION "The line number that should be used for the first line of active picture in the frame."

add_parameter V_BLANK int 0
set_parameter_property V_BLANK DISPLAY_NAME "Vertical blanking"
set_parameter_property V_BLANK ALLOWED_RANGES 0:50000
set_parameter_property V_BLANK HDL_PARAMETER true
set_parameter_property V_BLANK DISPLAY_UNITS "lines"
set_parameter_property V_BLANK DESCRIPTION "The size of the vertical blanking for the frame or after the active picture of field 1 ends."

add_parameter H_BLANK int 0
set_parameter_property H_BLANK DISPLAY_NAME "Horizontal blanking"
set_parameter_property H_BLANK ALLOWED_RANGES 0:50000
set_parameter_property H_BLANK HDL_PARAMETER true
set_parameter_property H_BLANK DISPLAY_UNITS "pixels"
set_parameter_property H_BLANK DESCRIPTION "The size of the horizontal blanking for the frame."

add_parameter H_SYNC_LENGTH int 44
set_parameter_property H_SYNC_LENGTH DISPLAY_NAME "Horizontal sync"
set_parameter_property H_SYNC_LENGTH ALLOWED_RANGES 0:50000
set_parameter_property H_SYNC_LENGTH HDL_PARAMETER true
set_parameter_property H_SYNC_LENGTH DISPLAY_UNITS "pixels"
set_parameter_property H_SYNC_LENGTH DESCRIPTION "The size of the horizontal sync for the frame."

add_parameter H_FRONT_PORCH int 88
set_parameter_property H_FRONT_PORCH DISPLAY_NAME "Horizontal front porch"
set_parameter_property H_FRONT_PORCH ALLOWED_RANGES 0:50000
set_parameter_property H_FRONT_PORCH HDL_PARAMETER true
set_parameter_property H_FRONT_PORCH DISPLAY_UNITS "pixels"
set_parameter_property H_FRONT_PORCH DESCRIPTION "The size of the horizontal front porch for the frame."

add_parameter H_BACK_PORCH int 148
set_parameter_property H_BACK_PORCH DISPLAY_NAME "Horizontal back porch"
set_parameter_property H_BACK_PORCH ALLOWED_RANGES 0:50000
set_parameter_property H_BACK_PORCH HDL_PARAMETER true
set_parameter_property H_BACK_PORCH DISPLAY_UNITS "pixels"
set_parameter_property H_BACK_PORCH DESCRIPTION "The size of the horizontal back porch for the frame."

add_parameter V_SYNC_LENGTH int 5
set_parameter_property V_SYNC_LENGTH DISPLAY_NAME "Vertical sync"
set_parameter_property V_SYNC_LENGTH ALLOWED_RANGES 0:50000
set_parameter_property V_SYNC_LENGTH HDL_PARAMETER true
set_parameter_property V_SYNC_LENGTH DISPLAY_UNITS "lines"
set_parameter_property V_SYNC_LENGTH DESCRIPTION "The size of the vertical sync for the frame or field 1."

add_parameter V_FRONT_PORCH int 4
set_parameter_property V_FRONT_PORCH DISPLAY_NAME "Vertical front porch"
set_parameter_property V_FRONT_PORCH ALLOWED_RANGES 0:50000
set_parameter_property V_FRONT_PORCH HDL_PARAMETER true
set_parameter_property V_FRONT_PORCH DISPLAY_UNITS "lines"
set_parameter_property V_FRONT_PORCH DESCRIPTION "The size of the vertical front porch for the frame or field 1."

add_parameter V_BACK_PORCH int 36
set_parameter_property V_BACK_PORCH DISPLAY_NAME "Vertical back porch"
set_parameter_property V_BACK_PORCH ALLOWED_RANGES 0:50000
set_parameter_property V_BACK_PORCH HDL_PARAMETER true
set_parameter_property V_BACK_PORCH DISPLAY_UNITS "lines"
set_parameter_property V_BACK_PORCH DESCRIPTION "The size of the vertical back porch for the frame or field 1."

add_parameter F_RISING_EDGE int 0
set_parameter_property F_RISING_EDGE DISPLAY_NAME "F rising edge line"
set_parameter_property F_RISING_EDGE ALLOWED_RANGES 0:50000
set_parameter_property F_RISING_EDGE HDL_PARAMETER true
set_parameter_property F_RISING_EDGE DESCRIPTION "The line number that field 1 should start on."

add_parameter F_FALLING_EDGE int 0
set_parameter_property F_FALLING_EDGE DISPLAY_NAME "F falling edge line"
set_parameter_property F_FALLING_EDGE ALLOWED_RANGES 0:50000
set_parameter_property F_FALLING_EDGE HDL_PARAMETER true
set_parameter_property F_FALLING_EDGE DESCRIPTION "The line number that field 0 should start on."

add_parameter FIELD0_V_RISING_EDGE int 0
set_parameter_property FIELD0_V_RISING_EDGE DISPLAY_NAME "Vertical blanking rising edge line"
set_parameter_property FIELD0_V_RISING_EDGE ALLOWED_RANGES 0:50000
set_parameter_property FIELD0_V_RISING_EDGE HDL_PARAMETER true
set_parameter_property FIELD0_V_RISING_EDGE DESCRIPTION "The line number that that active picture for field 0 ends and the vertical blanking begins."

add_parameter FIELD0_V_BLANK int 0
set_parameter_property FIELD0_V_BLANK DISPLAY_NAME "Vertical blanking"
set_parameter_property FIELD0_V_BLANK ALLOWED_RANGES 0:50000
set_parameter_property FIELD0_V_BLANK HDL_PARAMETER true
set_parameter_property FIELD0_V_BLANK DISPLAY_UNITS "lines"
set_parameter_property FIELD0_V_BLANK DESCRIPTION "The size of the vertical blanking after the active picture of field 0 ends."

add_parameter FIELD0_V_SYNC_LENGTH int 0
set_parameter_property FIELD0_V_SYNC_LENGTH DISPLAY_NAME "Vertical sync"
set_parameter_property FIELD0_V_SYNC_LENGTH ALLOWED_RANGES 0:50000
set_parameter_property FIELD0_V_SYNC_LENGTH HDL_PARAMETER true
set_parameter_property FIELD0_V_SYNC_LENGTH DISPLAY_UNITS "lines"
set_parameter_property FIELD0_V_SYNC_LENGTH DESCRIPTION "The size of the vertical sync for field 0."

add_parameter FIELD0_V_FRONT_PORCH int 0
set_parameter_property FIELD0_V_FRONT_PORCH DISPLAY_NAME "Vertical front porch"
set_parameter_property FIELD0_V_FRONT_PORCH ALLOWED_RANGES 0:50000
set_parameter_property FIELD0_V_FRONT_PORCH HDL_PARAMETER true
set_parameter_property FIELD0_V_FRONT_PORCH DISPLAY_UNITS "lines"
set_parameter_property FIELD0_V_FRONT_PORCH DESCRIPTION "The size of the vertical front porch for field 0."

add_parameter FIELD0_V_BACK_PORCH int 0
set_parameter_property FIELD0_V_BACK_PORCH DISPLAY_NAME "Vertical back porch"
set_parameter_property FIELD0_V_BACK_PORCH ALLOWED_RANGES 0:50000
set_parameter_property FIELD0_V_BACK_PORCH HDL_PARAMETER true
set_parameter_property FIELD0_V_BACK_PORCH DISPLAY_UNITS "lines"
set_parameter_property FIELD0_V_BACK_PORCH DESCRIPTION "The size of the vertical back porch for field 0."

add_parameter ANC_LINE int 0
set_parameter_property ANC_LINE DISPLAY_NAME "Ancillary packet insertion line"
set_parameter_property ANC_LINE ALLOWED_RANGES 0:50000
set_parameter_property ANC_LINE HDL_PARAMETER true
set_parameter_property ANC_LINE DESCRIPTION "The line number to start inserting ancillary packets into for the frame or field 1."

add_parameter FIELD0_ANC_LINE int 0
set_parameter_property FIELD0_ANC_LINE DISPLAY_NAME "Ancillary packet insertion line"
set_parameter_property FIELD0_ANC_LINE ALLOWED_RANGES 0:50000
set_parameter_property FIELD0_ANC_LINE HDL_PARAMETER true
set_parameter_property FIELD0_ANC_LINE DESCRIPTION "The line number to start inserting ancillary packets into for field 0."

#Order due to spr 333763
add_display_item "Image Data Format" H_ACTIVE_PIXELS parameter
add_display_item "Image Data Format" V_ACTIVE_LINES parameter
add_display_item "Image Data Format" BPS parameter
add_display_item "Image Data Format" NUMBER_OF_COLOUR_PLANES parameter
add_display_item "Image Data Format" COLOUR_PLANES_ARE_IN_PARALLEL parameter
add_display_item "Image Data Format" ACCEPT_COLOURS_IN_SEQ parameter
add_display_item "Image Data Format" INTERLACED parameter

add_display_item "Syncs Configuration" USE_EMBEDDED_SYNCS parameter
add_display_item "Syncs Configuration" AP_LINE parameter
add_display_item "Syncs Configuration" "Frame / Field 1 Parameters" group
add_display_item "Syncs Configuration" "Interlaced and Field 0 Parameters" group

add_display_item "General Parameters" FIFO_DEPTH parameter
add_display_item "General Parameters" THRESHOLD parameter
add_display_item "General Parameters" CLOCKS_ARE_SAME parameter
add_display_item "General Parameters" USE_CONTROL parameter
add_display_item "General Parameters" GENERATE_SYNC parameter
add_display_item "General Parameters" NO_OF_MODES parameter
add_display_item "General Parameters" STD_WIDTH parameter

add_display_item "Frame / Field 1 Parameters" ANC_LINE parameter
add_display_item "Frame / Field 1 Parameters" "Embedded Syncs Only - Frame / Field 1" group
add_display_item "Frame / Field 1 Parameters" "Separate Syncs Only - Frame / Field 1" group

add_display_item "Embedded Syncs Only - Frame / Field 1" H_BLANK parameter
add_display_item "Embedded Syncs Only - Frame / Field 1" V_BLANK parameter

add_display_item "Separate Syncs Only - Frame / Field 1" H_SYNC_LENGTH parameter
add_display_item "Separate Syncs Only - Frame / Field 1" H_FRONT_PORCH parameter
add_display_item "Separate Syncs Only - Frame / Field 1" H_BACK_PORCH parameter
add_display_item "Separate Syncs Only - Frame / Field 1" V_SYNC_LENGTH parameter
add_display_item "Separate Syncs Only - Frame / Field 1" V_FRONT_PORCH parameter
add_display_item "Separate Syncs Only - Frame / Field 1" V_BACK_PORCH parameter

add_display_item "Interlaced and Field 0 Parameters" F_RISING_EDGE parameter
add_display_item "Interlaced and Field 0 Parameters" F_FALLING_EDGE parameter
add_display_item "Interlaced and Field 0 Parameters" FIELD0_V_RISING_EDGE parameter
add_display_item "Interlaced and Field 0 Parameters" FIELD0_ANC_LINE parameter
add_display_item "Interlaced and Field 0 Parameters" "Embedded Syncs Only - Field 0" group
add_display_item "Interlaced and Field 0 Parameters" "Separate Syncs Only - Field 0" group

add_display_item "Embedded Syncs Only - Field 0" FIELD0_V_BLANK parameter

add_display_item "Separate Syncs Only - Field 0" FIELD0_V_SYNC_LENGTH parameter
add_display_item "Separate Syncs Only - Field 0" FIELD0_V_FRONT_PORCH parameter
add_display_item "Separate Syncs Only - Field 0" FIELD0_V_BACK_PORCH parameter
 
#define the is_clk_rst - this is the only non parameter dependent interface
add_interface is_clk_rst clock sink
add_interface_port is_clk_rst is_clk clk input 1
add_interface_port is_clk_rst rst reset input 1


#the elaboration callback
set_module_property ELABORATION_CALLBACK cvo_elaboration_callback

proc cvo_elaboration_callback {} {
	# Control Port
	set use_control [get_parameter_value USE_CONTROL]
	if { $use_control==1 } {
		add_interface control avalon slave is_clk_rst
		set_interface_property control addressAlignment NATIVE		
		set_interface_property control addressSpan 256
		set_interface_property control isMemoryDevice 0
		set_interface_property control readWaitTime 0
		set_interface_property control writeWaitTime 0
		#associate control status_update_irq
		add_interface_port control av_address address input 8
		add_interface_port control av_read read input 1
		add_interface_port control av_readdata readdata output 16
		add_interface_port control av_write write input 1
		add_interface_port control av_waitrequest waitrequest output 1
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
	add_interface din avalon_streaming sink is_clk_rst
	set_interface_property din dataBitsPerSymbol $bps
	set_interface_property din symbolsPerBeat $symbols_per_beat
	set_interface_property din readyLatency 1
	add_interface_port din is_data data input $data_width
	add_interface_port din is_valid valid input 1
	add_interface_port din is_ready ready output 1
	add_interface_port din is_sop startofpacket input 1
	add_interface_port din is_eop endofpacket input 1
	
	
	# Video signals - SOPC Builder needs to treat these as asynchronous signals
	add_interface clocked_video conduit source
	set clocks_are_same [get_parameter_value CLOCKS_ARE_SAME]
	if { $clocks_are_same == 0 } {
		add_interface_port clocked_video vid_clk export input 1
	} 
	
	add_interface_port clocked_video vid_data export output $data_width
	add_interface_port clocked_video underflow export output 1
	
	if { $use_control==1 } {
		add_interface_port clocked_video vid_mode_change export output 1
		
		set std_width [get_parameter_value STD_WIDTH]
		add_interface_port clocked_video vid_std export output $std_width
		
		set generate_sync [get_parameter_value GENERATE_SYNC]
		if { $generate_sync!=0 } {
			add_interface_port clocked_video vid_vcoclk_div export output 1
			add_interface_port clocked_video vid_sof_locked export output 1
			add_interface_port clocked_video vid_sof export output 1
			add_interface_port clocked_video sof_locked export input 1
			add_interface_port clocked_video sof export input 1
		}
	}
		
	set use_embedded_syncs [get_parameter_value USE_EMBEDDED_SYNCS]
	if { $use_embedded_syncs == 1 } {	
		add_interface_port clocked_video vid_trs export output 1
		add_interface_port clocked_video vid_ln export output 11
	} else {
		add_interface_port clocked_video vid_datavalid export output 1
		add_interface_port clocked_video vid_v_sync export output 1		
		add_interface_port clocked_video vid_h_sync export output 1
		add_interface_port clocked_video vid_f export output 1
		add_interface_port clocked_video vid_h export output 1
		add_interface_port clocked_video vid_v export output 1
	}
}
