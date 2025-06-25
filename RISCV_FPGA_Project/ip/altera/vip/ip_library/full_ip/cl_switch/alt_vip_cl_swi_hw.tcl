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


package require -exact qsys 12.0

# -- General Info --
set_module_property NAME alt_vip_cl_swi
set_module_property VERSION 13.0
set_module_property DISPLAY_NAME "Switch II"
set_module_property DESCRIPTION "The Video Switch"
set_module_property GROUP "DSP/Video and Image Processing"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_vip.pdf
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true 

# -- Files --
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL alt_vip_cl_switch_wrap
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS true
add_fileset_file alt_vip_cl_switch.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch.sv
add_fileset_file alt_vip_cl_switch_control.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch_control.sv
add_fileset_file alt_vip_cl_switch_wrap.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch_wrap.sv
add_fileset_file alt_vip_common_stream_input.v VERILOG PATH ../../common_hdl/modules/alt_vip_common_stream_input/src_hdl/alt_vip_common_stream_input.v
add_fileset_file alt_vip_common_stream_output.sv SYSTEM_VERILOG PATH ../../common_hdl/modules/alt_vip_common_stream_output/src_hdl/alt_vip_common_stream_output.sv

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL alt_vip_cl_switch_wrap
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS true
add_fileset_file alt_vip_cl_switch.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch.sv
add_fileset_file alt_vip_cl_switch_control.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch_control.sv
add_fileset_file alt_vip_cl_switch_wrap.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch_wrap.sv
add_fileset_file alt_vip_common_stream_input.v VERILOG PATH ../../common_hdl/modules/alt_vip_common_stream_input/src_hdl/alt_vip_common_stream_input.v
add_fileset_file alt_vip_common_stream_output.sv SYSTEM_VERILOG PATH ../../common_hdl/modules/alt_vip_common_stream_output/src_hdl/alt_vip_common_stream_output.sv

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL alt_vip_cl_switch_wrap
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS true
add_fileset_file alt_vip_cl_switch.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch.sv
add_fileset_file alt_vip_cl_switch_control.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch_control.sv
add_fileset_file alt_vip_cl_switch_wrap.sv SYSTEM_VERILOG PATH src_hdl/alt_vip_cl_switch_wrap.sv
add_fileset_file alt_vip_common_stream_input.v VERILOG PATH ../../common_hdl/modules/alt_vip_common_stream_input/src_hdl/alt_vip_common_stream_input.v
add_fileset_file alt_vip_common_stream_output.sv SYSTEM_VERILOG PATH ../../common_hdl/modules/alt_vip_common_stream_output/src_hdl/alt_vip_common_stream_output.sv

# -- Parameters --
add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

add_parameter READY_LATENCY INTEGER 1
set_parameter_property READY_LATENCY DISPLAY_NAME "Ready Latency"
set_parameter_property READY_LATENCY ALLOWED_RANGES 0:1
set_parameter_property READY_LATENCY DESCRIPTION "The latency of the switch's Avalon ST Video Ready signal"
set_parameter_property READY_LATENCY AFFECTS_ELABORATION true
set_parameter_property READY_LATENCY HDL_PARAMETER true

add_parameter NO_OF_INPUTS INTEGER 2
set_parameter_property NO_OF_INPUTS DISPLAY_NAME "Number of inputs"
set_parameter_property NO_OF_INPUTS ALLOWED_RANGES 1:12
set_parameter_property NO_OF_INPUTS DESCRIPTION "The number of Avalon ST Video inputs to the switch"
set_parameter_property NO_OF_INPUTS AFFECTS_ELABORATION true
set_parameter_property NO_OF_INPUTS HDL_PARAMETER true

add_parameter NO_OF_OUTPUTS INTEGER 2
set_parameter_property NO_OF_OUTPUTS DISPLAY_NAME "Number of outputs"
set_parameter_property NO_OF_OUTPUTS ALLOWED_RANGES 1:12
set_parameter_property NO_OF_OUTPUTS DESCRIPTION "The number of Avalon ST Video outputs from the switch"
set_parameter_property NO_OF_OUTPUTS AFFECTS_ELABORATION true
set_parameter_property NO_OF_OUTPUTS HDL_PARAMETER true

add_parameter BPS INTEGER 8
set_parameter_property BPS DISPLAY_NAME "Bits per pixel per color plane"
set_parameter_property BPS ALLOWED_RANGES 4:20
set_parameter_property BPS DESCRIPTION "The number of bits used per pixel, per color plane"
set_parameter_property BPS AFFECTS_ELABORATION true
set_parameter_property BPS HDL_PARAMETER true

add_parameter NUMBER_OF_COLOUR_PLANES INTEGER 3
set_parameter_property NUMBER_OF_COLOUR_PLANES DISPLAY_NAME "Number of color planes"
set_parameter_property NUMBER_OF_COLOUR_PLANES ALLOWED_RANGES 1:4
set_parameter_property NUMBER_OF_COLOUR_PLANES DESCRIPTION "The number of color planes per pixel"
set_parameter_property NUMBER_OF_COLOUR_PLANES AFFECTS_ELABORATION true
set_parameter_property NUMBER_OF_COLOUR_PLANES HDL_PARAMETER true

add_parameter COLOUR_PLANES_ARE_IN_PARALLEL BOOLEAN 1
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DISPLAY_NAME "Color planes are in parallel"
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DESCRIPTION "The color planes are arranged in parallel, otherwise in series"
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL AFFECTS_ELABORATION true
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL HDL_PARAMETER true

add_parameter NUMBER_OF_PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL DISPLAY_NAME "Number of pixels in parallel"
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL ALLOWED_RANGES 1:1
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL DESCRIPTION "This number of pixels are arranged in parallel, set to 1 to arrange them in series"
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL AFFECTS_ELABORATION true
set_parameter_property NUMBER_OF_PIXELS_IN_PARALLEL HDL_PARAMETER true

add_parameter CHANNEL_WIDTH INTEGER 0
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME "The width of the channel bus"
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES 0:2
set_parameter_property CHANNEL_WIDTH DESCRIPTION "This sets the width of the din_channel and dout_channel signals, set to 0 if the channel is not required"
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true
set_parameter_property CHANNEL_WIDTH DERIVED true

add_parameter NUM_CHANNELS INTEGER 0
set_parameter_property NUM_CHANNELS DISPLAY_NAME "The maximum channel number"
set_parameter_property NUM_CHANNELS ALLOWED_RANGES 0:4
set_parameter_property NUM_CHANNELS DESCRIPTION "This sets the maximum channel number that can be transmitted on the channel bus"
set_parameter_property NUM_CHANNELS AFFECTS_ELABORATION true
set_parameter_property NUM_CHANNELS HDL_PARAMETER true

add_parameter ALPHA_ENABLED Boolean false
set_parameter_property ALPHA_ENABLED ALLOWED_RANGES 0:4
set_parameter_property ALPHA_ENABLED VISIBLE false
set_parameter_property ALPHA_ENABLED HDL_PARAMETER false
set_parameter_property ALPHA_ENABLED DERIVED true

# -- Static Ports -- 
# The clock
add_interface main_clock clock end
add_interface_port main_clock clock clk Input 1
add_interface_port main_clock reset reset Input 1

# Declare the Avalon slave interface
add_interface control avalon slave main_clock
set_interface_property control writeWaitTime 0
set_interface_property control addressAlignment DYNAMIC
set_interface_property control readWaitTime 1
set_interface_property control readLatency 0
# Declare all the signals that belong to the Slave interface
add_interface_port control control_read read input 1
add_interface_port control control_write write input 1
add_interface_port control control_address address input 5
add_interface_port control control_writedata writedata input 32
add_interface_port control control_readdata readdata output 32

add_interface interrupt interrupt end main_clock
add_interface_port interrupt control_interrupt irq output 1
set_interface_property interrupt associatedAddressablePoint control

#validation call back for disabling parameters
set_module_property VALIDATION_CALLBACK validation_callback
proc validation_callback {} {
	# upgrade check
	set alpha_enable [get_parameter_value ALPHA_ENABLED]
	
	if {$alpha_enable == "true"} {
		set name [get_module_property DISPLAY_NAME]
		send_message WARNING "$name: You have upgraded from a version of the Switch before or equal to 12.1 which used seperate Alpha inputs, please see upgrade note below:"
		send_message WARNING "$name: Alpha inputs are no longer supported from 13.0 onwards, please use Color Plane Sequencer to insert alpha channel"
	} 
}

# Temp resolution to helper function lib mismatch:
# clogb2_pure: ceil(log2(x))
# ceil(log2(4)) = 2 wires are required to address a memory of depth 4
proc clogb2_pure {max_value} {
   set l2 [expr int(ceil(log($max_value)/(log(2))))]
   if { $l2 == 0 } {
      set l2 1
   }
   return $l2
}

# -- Dynamic Ports (evaluation callback) --
set_module_property ELABORATION_CALLBACK swi_elaboration_callback
proc swi_elaboration_callback {} {
	
	# Avalon streaming source(s)
	set ready_latency                  [get_parameter_value READY_LATENCY]
	set bits_per_sym                            [get_parameter_value BPS]
	set number_of_colour_planes        [get_parameter_value NUMBER_OF_COLOUR_PLANES]
	set colour_planes_are_in_parallel  [get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL]
	set number_of_pixels_in_parallel   [get_parameter_value NUMBER_OF_PIXELS_IN_PARALLEL]
	set no_of_symbols [expr {$colour_planes_are_in_parallel ? $number_of_colour_planes * $number_of_pixels_in_parallel : 1}]
	set data_width [expr {$colour_planes_are_in_parallel ? [expr $bits_per_sym * $number_of_colour_planes * $number_of_pixels_in_parallel] : $bits_per_sym}]
	set max_channel_number             [get_parameter_value NUM_CHANNELS]
	
	if { $max_channel_number > 0 } {
	    set channel_width [clogb2_pure $max_channel_number]
	} else {
	    set channel_width 0
	}
	set_parameter_value CHANNEL_WIDTH $channel_width
	
	# Optional input output interfaces	
    for {set input 0} {$input < [get_parameter_value NO_OF_INPUTS]} {incr input} {
        # Declare the interface
        add_interface din_${input} avalon_streaming sink main_clock
        set_interface_property din_${input} dataBitsPerSymbol $bits_per_sym
        set_interface_property din_${input} readyLatency $ready_latency
        set_interface_property din_${input} symbolsPerBeat $no_of_symbols
        set_interface_property din_${input} maxChannel $max_channel_number
		
        # Declare signals
        add_interface_port din_${input} din_${input}_ready ready output 1
        set_port_property din_${input}_ready FRAGMENT_LIST "din_ready@${input}"
        
        add_interface_port din_${input} din_${input}_valid valid input 1
        set_port_property din_${input}_valid FRAGMENT_LIST "din_valid@${input}"
        
        add_interface_port din_${input} din_${input}_data data input $data_width
        set bottom [expr ${input} * ${data_width}]
        set top [expr ${bottom} + ${data_width} - 1]
        set_port_property din_${input}_data FRAGMENT_LIST "din_data@${top}:${bottom}"
        
        add_interface_port din_${input} din_${input}_startofpacket startofpacket input 1
        set_port_property din_${input}_startofpacket FRAGMENT_LIST "din_startofpacket@${input}"
        
        add_interface_port din_${input} din_${input}_endofpacket endofpacket input 1
        set_port_property din_${input}_endofpacket FRAGMENT_LIST "din_endofpacket@${input}"
        
        if { $max_channel_number > 0 } {
            add_interface_port din_${input} din_${input}_channel channel input $channel_width
            set bottom [expr ${input} * ${channel_width}]
            set top [expr ${bottom} + ${channel_width} - 1]
            set_port_property din_${input}_channel FRAGMENT_LIST "din_channel@${top}:${bottom}"
        }
    }
    
    for {set output 0} {$output < [get_parameter_value NO_OF_OUTPUTS]} {incr output} {
        # Declare the interface
        add_interface dout_${output} avalon_streaming source main_clock
        set_interface_property dout_${output} dataBitsPerSymbol $bits_per_sym
        set_interface_property dout_${output} readyLatency $ready_latency
        set_interface_property dout_${output} symbolsPerBeat $no_of_symbols
        set_interface_property dout_${output} maxChannel $max_channel_number
        
		# Declare signals
        add_interface_port dout_${output} dout_${output}_ready ready input 1
        set_port_property dout_${output}_ready FRAGMENT_LIST "dout_ready@${output}"
        
        add_interface_port dout_${output} dout_${output}_valid valid output 1
        set_port_property dout_${output}_valid FRAGMENT_LIST "dout_valid@${output}"
        
        add_interface_port dout_${output} dout_${output}_data data output $data_width
        set bottom [expr ${output} * ${data_width}]
        set top [expr ${bottom} + ${data_width} - 1]
        set_port_property dout_${output}_data FRAGMENT_LIST "dout_data@${top}:${bottom}"
        
        add_interface_port dout_${output} dout_${output}_startofpacket startofpacket output 1
        set_port_property dout_${output}_startofpacket FRAGMENT_LIST "dout_startofpacket@${output}"
        
        add_interface_port dout_${output} dout_${output}_endofpacket endofpacket output 1
        set_port_property dout_${output}_endofpacket FRAGMENT_LIST "dout_endofpacket@${output}"
        
        if { $max_channel_number > 0 } {
            add_interface_port dout_${output} dout_${output}_channel channel output $channel_width
            set bottom [expr ${output} * ${channel_width}]
            set top [expr ${bottom} + ${channel_width} - 1]
            set_port_property dout_${output}_channel FRAGMENT_LIST "dout_channel@${top}:${bottom}"
        }
    }
}

