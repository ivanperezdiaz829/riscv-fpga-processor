package require -exact sopc 10.0

# -- General Info --
set_module_property NAME alt_vip_swi
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Switch"
set_module_property DESCRIPTION "The Video Switch"
set_module_property GROUP "Video and Image Processing"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_vip.pdf
set_module_property AUTHOR "Altera Corporation"
set_module_property simulation_model_in_vhdl true
set_module_property simulation_model_in_verilog true

# -- Files --
add_file src_hdl/alt_vipswi131_switch_control.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipswi131_common_stream_input.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipswi131_common_stream_output.v {SYNTHESIS SIMULATION}

# -- Parameters --
add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

add_parameter BPS int 8
set_parameter_property BPS DISPLAY_NAME "Bits per pixel per color plane"
set_parameter_property BPS ALLOWED_RANGES 4:20
set_parameter_property BPS DESCRIPTION "The number of bits used per pixel, per color plane"

add_parameter NUMBER_OF_COLOUR_PLANES int 3
set_parameter_property NUMBER_OF_COLOUR_PLANES DISPLAY_NAME "Number of color planes"
set_parameter_property NUMBER_OF_COLOUR_PLANES ALLOWED_RANGES 1:4
set_parameter_property NUMBER_OF_COLOUR_PLANES DESCRIPTION "The number of color planes per pixel"

add_parameter COLOUR_PLANES_ARE_IN_PARALLEL Boolean 1
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DISPLAY_NAME "Color planes are in parallel"
set_parameter_property COLOUR_PLANES_ARE_IN_PARALLEL DESCRIPTION "The color planes are arranged in parallel, otherwise in series"

add_parameter NO_OF_INPUTS int 2
set_parameter_property NO_OF_INPUTS DISPLAY_NAME "Number of inputs"
set_parameter_property NO_OF_INPUTS ALLOWED_RANGES 1:12
set_parameter_property NO_OF_INPUTS DESCRIPTION "The number of Avalon ST Video inputs to the switch"

add_parameter NO_OF_OUTPUTS int 2
set_parameter_property NO_OF_OUTPUTS DISPLAY_NAME "Number of outputs"
set_parameter_property NO_OF_OUTPUTS ALLOWED_RANGES 1:12
set_parameter_property NO_OF_OUTPUTS DESCRIPTION "The number of Avalon ST Video outputs from the switch"

add_parameter ALPHA_ENABLED Boolean 0
set_parameter_property ALPHA_ENABLED DISPLAY_NAME "Enable alpha channel"
set_parameter_property ALPHA_ENABLED DESCRIPTION "Create an Avalon ST Video alpha port for each input and output"

add_parameter ALPHA_BPS int 8
set_parameter_property ALPHA_BPS DISPLAY_NAME "Alpha bits per pixel"
set_parameter_property ALPHA_BPS ALLOWED_RANGES 2:8
set_parameter_property ALPHA_BPS DESCRIPTION "The number of bits used per pixel, per color plane for the alpha ports"

# -- Parameters Validation--
#validation call back for disabling parameters
#set_module_property VALIDATION_CALLBACK tmp_validation_callback
#proc tmp_validation_callback {} {
#	
#}

# -- Static Ports -- 
# The clock
add_interface main_clock clock end
add_interface_port main_clock clock clk Input 1
add_interface_port main_clock reset reset Input 1

# Declare the Avalon slave interface
add_interface control avalon slave main_clock
set_interface_property control writeWaitTime 0
set_interface_property control addressAlignment NATIVE
set_interface_property control readWaitTime 1
set_interface_property control readLatency 0
# Declare all the signals that belong to the Slave interface
add_interface_port control control_read read input 1
add_interface_port control control_write write input 1
add_interface_port control control_address address input 5
add_interface_port control control_writedata writedata input 32
add_interface_port control control_readdata readdata output 32


# -- Dynamic Ports (evaluation callback) --
set_module_property ELABORATION_CALLBACK swi_elaboration_callback
proc swi_elaboration_callback {} {
	# Avalon streaming source(s)
	set bps [get_parameter_value BPS]
	set number_of_colour_planes [get_parameter_value NUMBER_OF_COLOUR_PLANES]
	set colour_planes_are_in_parallel [get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL]
	set data_width [expr {$colour_planes_are_in_parallel ? [expr $bps * $number_of_colour_planes] : $bps}]
    set alpha_enabled [get_parameter_value ALPHA_ENABLED]
    set alpha_bps [get_parameter_value ALPHA_BPS]

	# Optional input output interfaces	
    for {set input 0} {$input < [get_parameter_value NO_OF_INPUTS]} {incr input} {
        # Declare the interface
        add_interface din_${input} avalon_streaming sink main_clock
        set_interface_property din_${input} dataBitsPerSymbol $bps
        set_interface_property din_${input} readyLatency 1
		set_interface_property din_${input} symbolsPerBeat [expr {$colour_planes_are_in_parallel ? $number_of_colour_planes : 1}]
        # Declare signals
        add_interface_port din_${input} din_${input}_ready ready output 1
        add_interface_port din_${input} din_${input}_valid valid input 1
        add_interface_port din_${input} din_${input}_data data input $data_width
        add_interface_port din_${input} din_${input}_startofpacket startofpacket input 1
        add_interface_port din_${input} din_${input}_endofpacket endofpacket input 1
        
        if {$alpha_enabled} {
            # Declare the interface
            add_interface alpha_in_${input} avalon_streaming sink main_clock
            # Set interface properties
            set_interface_property alpha_in_${input} dataBitsPerSymbol $alpha_bps
            set_interface_property alpha_in_${input} readyLatency 1
            set_interface_property alpha_in_${input} symbolsPerBeat 1
            # Declare signals
            add_interface_port alpha_in_${input} alpha_in_${input}_ready ready output 1
            add_interface_port alpha_in_${input} alpha_in_${input}_valid valid input 1
            add_interface_port alpha_in_${input} alpha_in_${input}_data data input $alpha_bps
            add_interface_port alpha_in_${input} alpha_in_${input}_startofpacket startofpacket input 1
            add_interface_port alpha_in_${input} alpha_in_${input}_endofpacket endofpacket input 1
        }
    }
    for {set output 0} {$output < [get_parameter_value NO_OF_OUTPUTS]} {incr output} {
        # Declare the interface
        add_interface dout_${output} avalon_streaming source main_clock
        set_interface_property dout_${output} dataBitsPerSymbol $bps
        set_interface_property dout_${output} readyLatency 1
		set_interface_property dout_${output} symbolsPerBeat [expr {$colour_planes_are_in_parallel ? $number_of_colour_planes : 1}]
        # Declare signals
        add_interface_port dout_${output} dout_${output}_ready ready input 1
        add_interface_port dout_${output} dout_${output}_valid valid output 1
        add_interface_port dout_${output} dout_${output}_data data output $data_width
        add_interface_port dout_${output} dout_${output}_startofpacket startofpacket output 1
        add_interface_port dout_${output} dout_${output}_endofpacket endofpacket output 1
        if {$alpha_enabled} {
            # Declare the interface
            add_interface alpha_out_${output} avalon_streaming source main_clock
            # Set interface properties
            set_interface_property alpha_out_${output} dataBitsPerSymbol $alpha_bps
            set_interface_property alpha_out_${output} readyLatency 1
            set_interface_property alpha_out_${output} symbolsPerBeat 1
            # Declare signals
            add_interface_port alpha_out_${output} alpha_out_${output}_ready ready input 1
            add_interface_port alpha_out_${output} alpha_out_${output}_valid valid output 1
            add_interface_port alpha_out_${output} alpha_out_${output}_data data output $alpha_bps
            add_interface_port alpha_out_${output} alpha_out_${output}_startofpacket startofpacket output 1
            add_interface_port alpha_out_${output} alpha_out_${output}_endofpacket endofpacket output 1
        }
    }
}

# -- Top level file with velocity (generate callback) --
set_module_property GENERATION_CALLBACK swi_generation_callback
proc swi_generation_callback {} {
    send_message info "Starting Generation"
    # Get generation settings
    set language [get_generation_property HDL_LANGUAGE]
    set outdir [get_generation_property OUTPUT_DIRECTORY]
    set outputname [get_generation_property OUTPUT_NAME]
    set quartus_rootdir $::env(QUARTUS_ROOTDIR)
    set java_linux ${quartus_rootdir}/linux/jre/bin/java
    set java_windows ${quartus_rootdir}/bin/jre/bin/java.exe


    # Locat Java in Quartus
    if {[file exists $java_linux]} {
        set java_path $java_linux
        send_message info "Found java binary at $java_path"
    } elseif {[file exists $java_windows]} {
        set java_path $java_windows
        send_message info "Found java binary at $java_path"
    } else {
        set java_path java
        send_message info "Failed to find java binary"
    }

	# Create directory 
    file mkdir $outdir
    
    set verilog_name $outputname
    
    # Velocity the template
    if { $language == "vhdl" } {
        exec $java_path -jar jar/switch.jar src_hdl/alt_vipswi131_swi_vhdl.vm $outdir ${outputname}.vhd SWI_NAME=${outputname} SWI_BPS=[get_parameter_value BPS] SWI_NUMBER_OF_COLOUR_PLANES=[get_parameter_value NUMBER_OF_COLOUR_PLANES] SWI_COLOUR_PLANES_ARE_IN_PARALLEL=[get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL] SWI_NO_OF_INPUTS=[get_parameter_value NO_OF_INPUTS] SWI_NO_OF_OUTPUTS=[get_parameter_value NO_OF_OUTPUTS] SWI_ALPHA_ENABLED=[get_parameter_value ALPHA_ENABLED] SWI_ALPHA_BPS=[get_parameter_value ALPHA_BPS]
        add_file "${outdir}/${outputname}.vhd" {SYNTHESIS SIMULATION}
        set verilog_name ${outputname}_verilog
    }
        
    exec $java_path -jar jar/switch.jar src_hdl/alt_vipswi131_swi.vm $outdir ${verilog_name}.v SWI_NAME=${verilog_name} SWI_BPS=[get_parameter_value BPS] SWI_NUMBER_OF_COLOUR_PLANES=[get_parameter_value NUMBER_OF_COLOUR_PLANES] SWI_COLOUR_PLANES_ARE_IN_PARALLEL=[get_parameter_value COLOUR_PLANES_ARE_IN_PARALLEL] SWI_NO_OF_INPUTS=[get_parameter_value NO_OF_INPUTS] SWI_NO_OF_OUTPUTS=[get_parameter_value NO_OF_OUTPUTS] SWI_ALPHA_ENABLED=[get_parameter_value ALPHA_ENABLED] SWI_ALPHA_BPS=[get_parameter_value ALPHA_BPS]
    
    add_file "${outdir}/${verilog_name}.v" {SYNTHESIS SIMULATION}
}
