package require -exact sopc 10.0

# -- General Info --
set_module_property NAME alt_vip_cts
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Control Synchronizer"
set_module_property DESCRIPTION "The control synchronizer"
set_module_property GROUP "Video and Image Processing"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_vip.pdf
set_module_property AUTHOR "Altera Corporation"
set_module_property simulation_model_in_vhdl true

# -- Files --
add_file src_hdl/alt_vipcts131_cts_instruction_writer.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipcts131_cts_core.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipcts131_cts.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipcts131_common_control_packet_decoder.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipcts131_common_stream_input.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipcts131_common_stream_output.v {SYNTHESIS SIMULATION}

set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vipcts131_cts.v
set_module_property TOP_LEVEL_HDL_MODULE alt_vipcts131_cts


# -- Parameters --

add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

add_parameter BITS_PER_SYMBOL int 8
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per pixel per color plane"
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES 4:20
set_parameter_property BITS_PER_SYMBOL DESCRIPTION "The number of bits used per pixel, per color plane"
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER true

add_parameter NUMBER_OF_COLOR_PLANES int 3
set_parameter_property NUMBER_OF_COLOR_PLANES DISPLAY_NAME "Number of color planes"
set_parameter_property NUMBER_OF_COLOR_PLANES ALLOWED_RANGES 1:4
set_parameter_property NUMBER_OF_COLOR_PLANES DESCRIPTION "The number of color planes per pixel"
set_parameter_property NUMBER_OF_COLOR_PLANES HDL_PARAMETER true

add_parameter COLOUR_PLANES_ARE_IN_PARALLEL int 1
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DISPLAY_NAME "Color planes are in parallel"
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL ALLOWED_RANGES 0:1
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DISPLAY_HINT boolean
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DESCRIPTION "The color planes are arranged in parallel, otherwise in series"
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL HDL_PARAMETER true

add_parameter TRIGGER_ON_WIDTH_CHANGE int 1
set_parameter_property TRIGGER_ON_WIDTH_CHANGE DISPLAY_NAME "Trigger on width change"
set_parameter_property TRIGGER_ON_WIDTH_CHANGE ALLOWED_RANGES 0:1
set_parameter_property TRIGGER_ON_WIDTH_CHANGE DISPLAY_HINT boolean
set_parameter_property TRIGGER_ON_WIDTH_CHANGE DESCRIPTION "Start transfer of control data when there is a change in the width value from the current to the last control packet"
set_parameter_property TRIGGER_ON_WIDTH_CHANGE HDL_PARAMETER true

add_parameter TRIGGER_ON_HEIGHT_CHANGE int 1
set_parameter_property TRIGGER_ON_HEIGHT_CHANGE DISPLAY_NAME "Trigger on height change"
set_parameter_property TRIGGER_ON_HEIGHT_CHANGE ALLOWED_RANGES 0:1
set_parameter_property TRIGGER_ON_HEIGHT_CHANGE DISPLAY_HINT boolean 
set_parameter_property TRIGGER_ON_HEIGHT_CHANGE DESCRIPTION "Start transfer of control data when there is a change in the height value from the current to the last control packet"
set_parameter_property TRIGGER_ON_HEIGHT_CHANGE HDL_PARAMETER true

add_parameter TRIGGER_ON_IMAGE_SOP int 0
set_parameter_property TRIGGER_ON_IMAGE_SOP DISPLAY_NAME "Trigger on start of video data packet"
set_parameter_property TRIGGER_ON_IMAGE_SOP ALLOWED_RANGES 0:1
set_parameter_property TRIGGER_ON_IMAGE_SOP DISPLAY_HINT boolean 
set_parameter_property TRIGGER_ON_IMAGE_SOP DESCRIPTION "Start transfer of control data when the core receives the start of a video data packet"
set_parameter_property TRIGGER_ON_IMAGE_SOP HDL_PARAMETER true

add_parameter DISARM_ON_TRIGGER int 0
set_parameter_property DISARM_ON_TRIGGER DISPLAY_NAME "Require trigger reset via control port"
set_parameter_property DISARM_ON_TRIGGER ALLOWED_RANGES 0:1
set_parameter_property DISARM_ON_TRIGGER DISPLAY_HINT boolean
set_parameter_property DISARM_ON_TRIGGER DESCRIPTION "Core disarms it's trigger immediately after being triggered. The trigger must be re-armed via the control port"
set_parameter_property DISARM_ON_TRIGGER HDL_PARAMETER true

add_parameter MAX_INSTRUCTION_COUNT int 3
set_parameter_property MAX_INSTRUCTION_COUNT DISPLAY_NAME "Maximum number of control data entries"
set_parameter_property MAX_INSTRUCTION_COUNT ALLOWED_RANGES 1:10
set_parameter_property MAX_INSTRUCTION_COUNT DESCRIPTION "The maximum number of control data values that can be transferred from the core"
set_parameter_property MAX_INSTRUCTION_COUNT HDL_PARAMETER true

# -- Static Ports -- 
# The clock
add_interface main_clock clock sink
add_interface_port main_clock clock clk input 1
add_interface_port main_clock reset reset input 1

# The Slave
add_interface slave avalon end
set_interface_property slave addressAlignment NATIVE
set_interface_property slave addressSpan 32
set_interface_property slave bridgesToMaster ""
set_interface_property slave burstOnBurstBoundariesOnly false
set_interface_property slave holdTime 0
set_interface_property slave isMemoryDevice false
set_interface_property slave isNonVolatileStorage false
set_interface_property slave linewrapBursts false
set_interface_property slave maximumPendingReadTransactions 0
set_interface_property slave minimumUninterruptedRunLength 1
set_interface_property slave printableDevice false
set_interface_property slave readLatency 1
set_interface_property slave readWaitTime 0
set_interface_property slave setupTime 0
set_interface_property slave timingUnits Cycles
set_interface_property slave writeWaitTime 0
set_interface_property slave ASSOCIATED_CLOCK main_clock
add_interface_port slave slave_read read Input 1
add_interface_port slave slave_readdata readdata Output 32
add_interface_port slave slave_write write Input 1
add_interface_port slave slave_writedata writedata Input 32
add_interface_port slave slave_address address Input 5

# The Master
add_interface master avalon start
set_interface_property master adaptsTo ""
set_interface_property master burstOnBurstBoundariesOnly false
set_interface_property master doStreamReads false
set_interface_property master doStreamWrites false
set_interface_property master linewrapBursts false
set_interface_property master ASSOCIATED_CLOCK main_clock
add_interface_port master master_address address Output 32
add_interface_port master master_writedata writedata Output 32
add_interface_port master master_write write Output 1
add_interface_port master master_waitrequest waitrequest Input 1

# Interrupt Sender
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint slave
set_interface_property interrupt_sender ASSOCIATED_CLOCK main_clock
add_interface_port interrupt_sender status_update_int irq Output 1

#validation call back for disabling parameters
set_module_property VALIDATION_CALLBACK cts_validation_callback

proc cts_validation_callback {} {
	set colour_planes_in_parallel [get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL]
	set number_of_colour_planes [get_parameter_value NUMBER_OF_COLOR_PLANES]
	set bps [get_parameter_value BITS_PER_SYMBOL]
	 set family [get_parameter_value FAMILY]	

	if { ($colour_planes_in_parallel==1) && ($number_of_colour_planes>=4) && ($bps>14) } {
		send_message error "When color planes are in parallel and are greater than 3, the bits per color plane are limited to 14"
	}
	
	set trigger_on_sop [get_parameter_value TRIGGER_ON_IMAGE_SOP]
	set trigger_on_width [get_parameter_value TRIGGER_ON_WIDTH_CHANGE]
	set trigger_on_height [get_parameter_value TRIGGER_ON_HEIGHT_CHANGE]
	
	if { ($trigger_on_sop) && ($trigger_on_width || $trigger_on_height) } {
		send_message error "When triggering on a start of image packet, the core cannot also trigger on a width or height change"
	}
	
	if { !$trigger_on_sop && !$trigger_on_width &&  !$trigger_on_height } {
		send_message error "A trigger event must be specified"
	}
	
}


# -- Dynamic Ports (evaluation callback) --
set_module_property ELABORATION_CALLBACK cvo_elaboration_callback
proc cvo_elaboration_callback {} {
	# Avalon streaming ports
	set color_planes_are_in_parallel [get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL]
	set number_of_color_planes [get_parameter_value NUMBER_OF_COLOR_PLANES] 
	set bps [get_parameter_value BITS_PER_SYMBOL]
	if { $color_planes_are_in_parallel == 0 } {
		set symbols_per_beat 1
		set data_width $bps
	} else {
		set symbols_per_beat $number_of_color_planes
		set data_width [expr $bps * $number_of_color_planes]
	}
	
	add_interface din avalon_streaming sink
	set_interface_property din dataBitsPerSymbol $bps
	set_interface_property din symbolsPerBeat $symbols_per_beat
	set_interface_property din readyLatency 1
	add_interface_port din din_data data input $data_width
	add_interface_port din din_valid valid input 1
	add_interface_port din din_ready ready output 1
	add_interface_port din din_startofpacket startofpacket input 1
	add_interface_port din din_endofpacket endofpacket input 1
	set_interface_property din ASSOCIATED_CLOCK main_clock
		
	add_interface dout avalon_streaming source main_clock
	set_interface_property dout dataBitsPerSymbol $bps
	set_interface_property dout symbolsPerBeat $symbols_per_beat
	set_interface_property dout readyLatency 1
	add_interface_port dout dout_data data output $data_width
	add_interface_port dout dout_valid valid output 1
	add_interface_port dout dout_ready ready input 1
	add_interface_port dout dout_startofpacket startofpacket output 1
	add_interface_port dout dout_endofpacket endofpacket output 1
	set_interface_property din ASSOCIATED_CLOCK main_clock
}
