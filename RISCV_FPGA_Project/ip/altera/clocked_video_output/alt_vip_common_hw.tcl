package require -exact sopc 9.1

# -- General helper functions --

proc log2 {max_value} {
	set l2 [expr int(ceil(log($max_value)/(log(2))))]
	return $l2
}

proc log2g {max_value} {
	set l2g [log2 [expr $max_value+1]]
	return $l2g
}

proc min {in_1 in_2} {
	if { $in_1 < $in_2 } {
		set temp $in_1
	} else {
		set temp $in_2
	}
	return $temp
}

proc max {in_1 in_2} {
	if { $in_1 > $in_2 } {
		set temp $in_1
	} else {
		set temp $in_2
	}
	return $temp
}

# -- General Info --

proc declare_general_module_info {} {
	set_module_property GROUP "Video and Image Processing"
	set_module_property VERSION 13.1
    set_module_property AUTHOR "Altera Corporation"
	set_module_property DATASHEET_URL file:///[get_module_property MODULE_DIRECTORY]doc/ug_vip.pdf
}

proc declare_general_component_info {} {
	set_module_property GROUP "Video and Image Processing/non-released"
	set_module_property VERSION 13.1
    set_module_property AUTHOR "Altera Corporation"
	set_module_property INTERNAL false
}

# -- Files --

proc add_common_pack_files {} {
	add_file src_hdl/alt_vipitc131_common_package.vhd {SYNTHESIS SIMULATION}
}

proc add_avalon_mm_bursting_master_component_files {} {
	add_file src_hdl/alt_vipitc131_common_avalon_mm_bursting_master_fifo.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_avalon_mm_master.v {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_unpack_data.v {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_pulling_width_adapter.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_general_fifo.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_fifo_usedw_calculator.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_gray_clock_crosser.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_std_logic_vector_delay.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_one_bit_delay.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_logic_fifo.vhd {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_common_ram_fifo.vhd {SYNTHESIS SIMULATION}
}

proc add_avalon_st_input_component_files {} {
	add_file src_hdl/alt_vipitc131_common_stream_input.v {SYNTHESIS SIMULATION}
}

proc add_avalon_st_output_component_files {} {
	add_file src_hdl/alt_vipitc131_common_stream_output.v {SYNTHESIS SIMULATION}
}

proc add_avalon_mm_slave_component_files {} {
	add_file src_hdl/alt_vipitc131_common_avalon_mm_slave.v {SYNTHESIS SIMULATION}
}

proc add_prc_component_files {} {
	add_file src_hdl/alt_vipitc131_prc.v {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_prc_core.v {SYNTHESIS SIMULATION}
	add_file src_hdl/alt_vipitc131_prc_read_master.v {SYNTHESIS SIMULATION}
	add_avalon_mm_bursting_master_component_files
}

# -- Parameters --
proc add_max_dim_parameters {{x_min 32} {x_max 2600} {y_min 32} {y_max 2600}} {
	add_parameter MAX_WIDTH int [min $x_max [max $x_min 640]]
	set_parameter_property MAX_WIDTH DISPLAY_NAME "Maximum Frame width"
	set_parameter_property MAX_WIDTH ALLOWED_RANGES $x_min:$x_max
	set_parameter_property MAX_WIDTH DESCRIPTION "The maximum width of images / video frames"
	set_parameter_property MAX_WIDTH HDL_PARAMETER true
	
	add_parameter MAX_HEIGHT int [min $y_max [max $y_min 480]] 
	set_parameter_property MAX_HEIGHT DISPLAY_NAME "Maximum Frame height"
	set_parameter_property MAX_HEIGHT ALLOWED_RANGES $y_min:$y_max
	set_parameter_property MAX_HEIGHT DESCRIPTION "The maximum height of images / video frames"
	set_parameter_property MAX_HEIGHT HDL_PARAMETER true
}
proc add_bps_parameter {{bps_min 4} {bps_max 20}} {
	add_parameter BPS int 8
	set_parameter_property BPS DISPLAY_NAME "Bits per pixel per color plane"
	set_parameter_property BPS ALLOWED_RANGES $bps_min:$bps_max
	set_parameter_property BPS DESCRIPTION "The number of bits used per pixel, per color plane"
	set_parameter_property BPS HDL_PARAMETER true
}
proc add_channels_seq_par_parameters {{max_seq 4} {max_par 4}} {
	add_parameter CHANNELS_IN_SEQ int 1
	set_parameter_property CHANNELS_IN_SEQ DISPLAY_NAME "Number of color planes in sequence"
	set_parameter_property CHANNELS_IN_SEQ ALLOWED_RANGES 1:$max_seq
	set_parameter_property CHANNELS_IN_SEQ DESCRIPTION "The number color planes transmitted in sequence"
	set_parameter_property CHANNELS_IN_SEQ HDL_PARAMETER true
	
	add_parameter CHANNELS_IN_PAR int [min 3 $max_par]
	set_parameter_property CHANNELS_IN_PAR DISPLAY_NAME "Number of color planes in parallel"
	set_parameter_property CHANNELS_IN_PAR ALLOWED_RANGES 1:$max_par
	set_parameter_property CHANNELS_IN_PAR DESCRIPTION "The number color planes transmitted in parallel"
	set_parameter_property CHANNELS_IN_PAR HDL_PARAMETER true
}
proc add_channels_nb_parameters {{max_nb_channels 4}} {
	add_parameter NUMBERS_COLOR_PLANES int [min 3 $max_nb_channels]
	set_parameter_property NUMBERS_COLOR_PLANES DISPLAY_NAME "Number of color planes"
	set_parameter_property NUMBERS_COLOR_PLANES ALLOWED_RANGES 1:$max_nb_channels
	set_parameter_property NUMBERS_COLOR_PLANES DESCRIPTION "The number color planes transmitted"
	set_parameter_property NUMBERS_COLOR_PLANES HDL_PARAMETER true
	
	add_parameter COLOR_PLANES_ARE_IN_PARALLEL int 1
	set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL DISPLAY_NAME "Color planes transmitted in parallel"
	set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL ALLOWED_RANGES 0:1
	set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL DISPLAY_HINT boolean
	set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL DESCRIPTION "Whether color planes are transmitted in parallel"
	set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL HDL_PARAMETER true
}

proc add_rate_control_parameter {} {
	add_parameter RATE_CONTROL int 0
	set_parameter_property RATE_CONTROL DISPLAY_NAME "Controlled frame rate conversion"
	set_parameter_property RATE_CONTROL ALLOWED_RANGES 0:1
	set_parameter_property RATE_CONTROL DISPLAY_HINT boolean
	set_parameter_property RATE_CONTROL DESCRIPTION "Run-time control interface to control the frame rate"
	set_parameter_property RATE_CONTROL HDL_PARAMETER true
}

proc add_common_masters_parameter {} {
	add_parameter CLOCKS_ARE_SEPARATE int 0
	set_parameter_property CLOCKS_ARE_SEPARATE DISPLAY_NAME "Use separate clock for the Avalon-MM master interface(s)"
	set_parameter_property CLOCKS_ARE_SEPARATE ALLOWED_RANGES 0:1
	set_parameter_property CLOCKS_ARE_SEPARATE DISPLAY_HINT boolean
	set_parameter_property CLOCKS_ARE_SEPARATE DESCRIPTION "Use separate clock for the Avalon-MM master interface(s)"
	set_parameter_property CLOCKS_ARE_SEPARATE HDL_PARAMETER true
	
	add_parameter MEM_PORT_WIDTH int 256
	set_parameter_property MEM_PORT_WIDTH DISPLAY_NAME "Avalon-MM master(s) local ports width"
	set_parameter_property MEM_PORT_WIDTH ALLOWED_RANGES 16:256
	set_parameter_property MEM_PORT_WIDTH DESCRIPTION "The width in bits of the Avalon-MM master port(s)"
	set_parameter_property MEM_PORT_WIDTH HDL_PARAMETER true
}

proc add_master_parameter {master_name master_gui_name} {
	set FIFO_DEPTH ${master_name}_FIFO_DEPTH
	set BURST_TARGET ${master_name}_BURST_TARGET
	add_parameter $FIFO_DEPTH int 64
	set_parameter_property $FIFO_DEPTH DISPLAY_NAME "$master_gui_name FIFO depth"
	set_parameter_property $FIFO_DEPTH ALLOWED_RANGES {8 16 32 64 128 256 512 1024}
	set_parameter_property $FIFO_DEPTH DESCRIPTION "The depth of the write master FIFO"
	set_parameter_property $FIFO_DEPTH HDL_PARAMETER true
	
	add_parameter $BURST_TARGET int 32
	set_parameter_property $BURST_TARGET DISPLAY_NAME "$master_gui_name FIFO burst target"
	set_parameter_property $BURST_TARGET ALLOWED_RANGES {2 4 8 16 32 64 128 256}
	set_parameter_property $BURST_TARGET DESCRIPTION "The target burst size of the write master"
	set_parameter_property $BURST_TARGET HDL_PARAMETER true
}

proc add_base_address_parameter {} {
	add_parameter MEM_BASE_ADDR int 0
	set_parameter_property MEM_BASE_ADDR DISPLAY_NAME "Base address of storage space in memory"
	set_parameter_property MEM_BASE_ADDR ALLOWED_RANGES 0:'h1FFFFFFF
	set_parameter_property MEM_BASE_ADDR DESCRIPTION "The base address for the storage space used in memory"
	set_parameter_property MEM_BASE_ADDR HDL_PARAMETER true
}

proc add_burst_align_parameter {} {
	add_parameter BURST_ALIGNMENT int 1
	set_parameter_property BURST_ALIGNMENT DISPLAY_NAME "Align read/write bursts on read boundaries"
	set_parameter_property BURST_ALIGNMENT ALLOWED_RANGES 0:1
	set_parameter_property BURST_ALIGNMENT DISPLAY_HINT boolean
	set_parameter_property BURST_ALIGNMENT DESCRIPTION "Prevent memory transactions across memory row boundaries"
	set_parameter_property BURST_ALIGNMENT HDL_PARAMETER true
}

proc add_user_packets_mem_storage_parameters {} {	
	add_parameter USER_PACKETS_MAX_STORAGE int 0
	set_parameter_property USER_PACKETS_MAX_STORAGE DISPLAY_NAME "Storage space for user packets"
	set_parameter_property USER_PACKETS_MAX_STORAGE ALLOWED_RANGES 0:32
	set_parameter_property USER_PACKETS_MAX_STORAGE DESCRIPTION "The number of packets that can be buffered before being overwritten"
	set_parameter_property USER_PACKETS_MAX_STORAGE HDL_PARAMETER true
	
	add_parameter MAX_SYMBOLS_PER_PACKET int 10
	set_parameter_property MAX_SYMBOLS_PER_PACKET DISPLAY_NAME "Maximum packet length"
	set_parameter_property MAX_SYMBOLS_PER_PACKET ALLOWED_RANGES 1:16384
	set_parameter_property MAX_SYMBOLS_PER_PACKET DESCRIPTION "The maximum allowed length in symbols for user-defined packets (header included)"
	set_parameter_property MAX_SYMBOLS_PER_PACKET HDL_PARAMETER true
}
        
# -- Ports -- 
proc add_clock_port {clock_name} {
	add_interface $clock_name clock sink
	
	add_interface_port $clock_name ${clock_name}_clock clk Input 1
	add_interface_port $clock_name ${clock_name}_reset reset Input 1
}

proc add_main_clock_port {} {
	add_interface main_clock clock sink
	
	add_interface_port main_clock main_clock_clock clk Input 1
	add_interface_port main_clock main_clock_reset reset Input 1
}

proc add_av_st_vid_input_port {bps channels_in_par {input_name din} {clock main_clock}} {
	set data_width [expr $bps * $channels_in_par]
	
	add_interface $input_name avalon_streaming sink $clock
	
	set_interface_property $input_name dataBitsPerSymbol $bps
	set_interface_property $input_name symbolsPerBeat $channels_in_par
	set_interface_property $input_name errorDescriptor ""
	set_interface_property $input_name maxChannel 0
	set_interface_property $input_name readyLatency 1
	
	add_interface_port $input_name ${input_name}_ready ready output 1
	add_interface_port $input_name ${input_name}_valid valid input 1
	add_interface_port $input_name ${input_name}_data data input $data_width
	add_interface_port $input_name ${input_name}_startofpacket startofpacket input 1
	add_interface_port $input_name ${input_name}_endofpacket endofpacket input 1
}

proc add_av_st_vid_output_port {bps channels_in_par {output_name dout} {clock main_clock}} {
	set data_width [expr $bps * $channels_in_par]
	
	add_interface $output_name avalon_streaming source $clock
	
	set_interface_property $output_name dataBitsPerSymbol $bps
	set_interface_property $output_name symbolsPerBeat $channels_in_par
	set_interface_property $output_name errorDescriptor ""
	set_interface_property $output_name maxChannel 0
	set_interface_property $output_name readyLatency 1

	set_interface_property $output_name dataBitsPerSymbol $bps
	set_interface_property $output_name symbolsPerBeat $channels_in_par
	set_interface_property $output_name errorDescriptor ""
	set_interface_property $output_name maxChannel 0
	set_interface_property $output_name readyLatency 1

	add_interface_port $output_name ${output_name}_ready ready input 1
	add_interface_port $output_name ${output_name}_valid valid output 1
	add_interface_port $output_name ${output_name}_data data output $data_width
	add_interface_port $output_name ${output_name}_startofpacket startofpacket output 1
	add_interface_port $output_name ${output_name}_endofpacket endofpacket output 1
}
		
proc add_bursting_write_master_port {master_name mem_port_width burst_target burst_align {clock main_clock}} {
	add_interface $master_name avalon master $clock
	
	set_interface_property $master_name burstOnBurstBoundariesOnly $burst_align
	set_interface_property $master_name doStreamReads false
	set_interface_property $master_name doStreamWrites false
	set_interface_property $master_name linewrapBursts false

	add_interface_port $master_name ${master_name}_av_address address Output 32
	add_interface_port $master_name ${master_name}_av_write write Output 1
	add_interface_port $master_name ${master_name}_av_burstcount burstcount Output [log2g $burst_target]		
	add_interface_port $master_name ${master_name}_av_writedata writedata Output $mem_port_width
	add_interface_port $master_name ${master_name}_av_waitrequest waitrequest Input 1
}

proc add_bursting_read_master_port {master_name mem_port_width burst_target burst_align {clock main_clock}} {
	add_interface $master_name avalon master $clock

	set_interface_property $master_name burstOnBurstBoundariesOnly $burst_align
	set_interface_property $master_name doStreamReads false
	set_interface_property $master_name doStreamWrites false
	set_interface_property $master_name linewrapBursts false

	add_interface_port $master_name ${master_name}_av_address address Output 32
	add_interface_port $master_name ${master_name}_av_read read Output 1
	add_interface_port $master_name ${master_name}_av_burstcount burstcount Output [log2g $burst_target]
	add_interface_port $master_name ${master_name}_av_readdata readdata Input $mem_port_width
	add_interface_port $master_name ${master_name}_av_readdatavalid readdatavalid Input 1
	add_interface_port $master_name ${master_name}_av_waitrequest waitrequest Input 1
}

proc add_control_port {control_name width depth {has_interrupt 0} {clock main_clock}} {
	# the recommended name for a control interface is "control"
	
	add_interface $control_name avalon slave $clock
	
	set_interface_property $control_name addressAlignment NATIVE
	set_interface_property $control_name addressSpan $depth
	set_interface_property $control_name bridgesToMaster ""
	set_interface_property $control_name burstOnBurstBoundariesOnly false
	set_interface_property $control_name holdTime 0
	set_interface_property $control_name isMemoryDevice false
	set_interface_property $control_name isNonVolatileStorage false
	set_interface_property $control_name linewrapBursts false
	set_interface_property $control_name maximumPendingReadTransactions 0
	set_interface_property $control_name minimumUninterruptedRunLength 1
	set_interface_property $control_name printableDevice false
	set_interface_property $control_name readLatency 0
	set_interface_property $control_name readWaitTime 1
	set_interface_property $control_name setupTime 0
	set_interface_property $control_name timingUnits Cycles
	set_interface_property $control_name writeWaitTime 0

	add_interface_port $control_name ${control_name}_av_address address Input [log2g [expr $depth - 1]]
	add_interface_port $control_name ${control_name}_av_write write Input 1
	add_interface_port $control_name ${control_name}_av_writedata writedata Input $width
	add_interface_port $control_name ${control_name}_av_read read Input 1
	add_interface_port $control_name ${control_name}_av_readdata readdata Output $width
	
	if {$has_interrupt} {
		add_interface ${control_name}_interrupt interrupt sender $clock
		set_interface_property ${control_name}_interrupt associatedAddressablePoint $control_name
		add_interface_port ${control_name}_interrupt ${control_name}_av_irq irq Output 1
	}
}

proc add_av_st_event_debug_port {output_name bps channels_in_par num_ids {clock main_clock}} {
	set data_width [expr $bps * $channels_in_par]
	
	add_interface $output_name avalon_streaming source $clock
	
	set_interface_property $output_name dataBitsPerSymbol $bps
	set_interface_property $output_name symbolsPerBeat $channels_in_par
	set_interface_property $output_name errorDescriptor ""
	set_interface_property $output_name maxChannel $num_ids
	set_interface_property $output_name readyLatency 1

	add_interface_port $output_name ${output_name}_ready ready input 1
	add_interface_port $output_name ${output_name}_valid valid output 1
	add_interface_port $output_name ${output_name}_data data output $data_width
	add_interface_port $output_name ${output_name}_startofpacket startofpacket output 1
	add_interface_port $output_name ${output_name}_endofpacket endofpacket output 1
	add_interface_port $output_name ${output_name}_channel channel output [log2g [expr $num_ids + 1]]
}
