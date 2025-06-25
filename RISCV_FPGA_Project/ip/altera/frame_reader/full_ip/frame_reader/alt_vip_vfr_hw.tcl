package require -exact sopc 10.0

# -- General Info --
set_module_property NAME alt_vip_vfr
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Frame Reader"
set_module_property DESCRIPTION "The Frame Reader Megacore can be used to read a video stream from video frames stored a memory buffer"
set_module_property GROUP "Video and Image Processing"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_vip.pdf
set_module_property AUTHOR "Altera Corporation"
set_module_property simulation_model_in_vhdl true
set_module_property simulation_model_in_verilog true

# -- Files --
add_file src_hdl/alt_vipvfr131_vfr.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipvfr131_vfr_controller.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipvfr131_vfr_control_packet_encoder.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipvfr131_prc.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipvfr131_prc_core.v {SYNTHESIS SIMULATION}
add_file src_hdl/alt_vipvfr131_prc_read_master.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_package.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_avalon_mm_bursting_master_fifo.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_avalon_mm_master.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_unpack_data.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_avalon_mm_slave.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_stream_output.v {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_pulling_width_adapter.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_general_fifo.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_fifo_usedw_calculator.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_gray_clock_crosser.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_std_logic_vector_delay.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_one_bit_delay.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_logic_fifo.vhd {SYNTHESIS SIMULATION}
add_file ../../common_hdl/alt_vipvfr131_common_ram_fifo.vhd {SYNTHESIS SIMULATION}
add_file alt_vipvfr131_vfr.sdc SDC

set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vipvfr131_vfr.v
set_module_property TOP_LEVEL_HDL_MODULE alt_vipvfr131_vfr

# -- Parameters --
add_parameter FAMILY string "Cyclone IV"
set_parameter_property FAMILY DISPLAY_NAME "Device family selected"
set_parameter_property FAMILY DESCRIPTION "Current device family selected"
set_parameter_property FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property FAMILY VISIBLE false

add_parameter BITS_PER_PIXEL_PER_COLOR_PLANE int 8
set_parameter_property BITS_PER_PIXEL_PER_COLOR_PLANE DISPLAY_NAME "Bits per pixel per color plane"
set_parameter_property BITS_PER_PIXEL_PER_COLOR_PLANE ALLOWED_RANGES 4:16
set_parameter_property BITS_PER_PIXEL_PER_COLOR_PLANE DESCRIPTION "The number of bits used per pixel, per color plane"
set_parameter_property BITS_PER_PIXEL_PER_COLOR_PLANE HDL_PARAMETER true

add_parameter NUMBER_OF_CHANNELS_IN_PARALLEL int 3
set_parameter_property NUMBER_OF_CHANNELS_IN_PARALLEL DISPLAY_NAME "Number of color planes in parallel"
set_parameter_property NUMBER_OF_CHANNELS_IN_PARALLEL ALLOWED_RANGES 1:4
set_parameter_property NUMBER_OF_CHANNELS_IN_PARALLEL DESCRIPTION "The number color planes transmitted in parallel"
set_parameter_property NUMBER_OF_CHANNELS_IN_PARALLEL HDL_PARAMETER true

add_parameter NUMBER_OF_CHANNELS_IN_SEQUENCE int 1
set_parameter_property NUMBER_OF_CHANNELS_IN_SEQUENCE DISPLAY_NAME "Number of color planes in sequence"
set_parameter_property NUMBER_OF_CHANNELS_IN_SEQUENCE ALLOWED_RANGES 1:3
set_parameter_property NUMBER_OF_CHANNELS_IN_SEQUENCE DESCRIPTION "The number color planes transmitted in sequence"
set_parameter_property NUMBER_OF_CHANNELS_IN_SEQUENCE HDL_PARAMETER true

add_parameter MAX_IMAGE_WIDTH int 640
set_parameter_property MAX_IMAGE_WIDTH DISPLAY_NAME "Maximum Image width"
set_parameter_property MAX_IMAGE_WIDTH ALLOWED_RANGES 32:2600
set_parameter_property MAX_IMAGE_WIDTH DESCRIPTION "The maximum width of images / video frames"
set_parameter_property MAX_IMAGE_WIDTH HDL_PARAMETER true

add_parameter MAX_IMAGE_HEIGHT int 480
set_parameter_property MAX_IMAGE_HEIGHT DISPLAY_NAME "Maximum Image height"
set_parameter_property MAX_IMAGE_HEIGHT ALLOWED_RANGES 32:2600
set_parameter_property MAX_IMAGE_HEIGHT DESCRIPTION "The maximum height of images / video frames"
set_parameter_property MAX_IMAGE_HEIGHT HDL_PARAMETER true

add_parameter MEM_PORT_WIDTH int 256
set_parameter_property MEM_PORT_WIDTH DISPLAY_NAME "Master port width"
set_parameter_property MEM_PORT_WIDTH ALLOWED_RANGES 16:256
set_parameter_property MEM_PORT_WIDTH DESCRIPTION "The width in bits of the master port"
set_parameter_property MEM_PORT_WIDTH HDL_PARAMETER true

add_parameter RMASTER_FIFO_DEPTH int 64
set_parameter_property RMASTER_FIFO_DEPTH DISPLAY_NAME "Read master FIFO depth"
set_parameter_property RMASTER_FIFO_DEPTH ALLOWED_RANGES 8:1024
set_parameter_property RMASTER_FIFO_DEPTH DESCRIPTION "The depth of the read master FIFO"
set_parameter_property RMASTER_FIFO_DEPTH HDL_PARAMETER true

add_parameter RMASTER_BURST_TARGET int 32
set_parameter_property RMASTER_BURST_TARGET DISPLAY_NAME "Read master FIFO burst target"
set_parameter_property RMASTER_BURST_TARGET ALLOWED_RANGES 2:256
set_parameter_property RMASTER_BURST_TARGET DESCRIPTION "The target burst size of the read master"
set_parameter_property RMASTER_BURST_TARGET HDL_PARAMETER true

add_parameter CLOCKS_ARE_SEPARATE int 1
set_parameter_property CLOCKS_ARE_SEPARATE DISPLAY_NAME "Use separate clock for the Avalon-MM master interface"
set_parameter_property CLOCKS_ARE_SEPARATE ALLOWED_RANGES 0:1
set_parameter_property CLOCKS_ARE_SEPARATE DISPLAY_HINT boolean
set_parameter_property CLOCKS_ARE_SEPARATE DESCRIPTION "Use separate clock for the Avalon-MM master interface"
set_parameter_property CLOCKS_ARE_SEPARATE HDL_PARAMETER true

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ENABLED true
add_interface_port clock_reset clock clk Input 1
add_interface_port clock_reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_master
# | 
add_interface clock_master clock end
set_interface_property clock_master ENABLED true
add_interface_port clock_master master_clock clk Input 1
add_interface_port clock_master master_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave
# | 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressAlignment NATIVE
set_interface_property avalon_slave addressSpan 32
set_interface_property avalon_slave bridgesToMaster ""
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave isMemoryDevice false
set_interface_property avalon_slave isNonVolatileStorage false
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave minimumUninterruptedRunLength 1
set_interface_property avalon_slave printableDevice false
set_interface_property avalon_slave readLatency 1
set_interface_property avalon_slave readWaitTime 0
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_slave ENABLED true

add_interface_port avalon_slave slave_address address Input 5
add_interface_port avalon_slave slave_write write Input 1
add_interface_port avalon_slave slave_writedata writedata Input 32
add_interface_port avalon_slave slave_read read Input 1
add_interface_port avalon_slave slave_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point interrupt_sender
# | 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint avalon_slave

set_interface_property interrupt_sender ASSOCIATED_CLOCK clock_reset
set_interface_property interrupt_sender ENABLED true

add_interface_port interrupt_sender slave_irq irq Output 1
# | 
# +-----------------------------------

# -- Dynamic Ports (elaboration callback) --
set_module_property ELABORATION_CALLBACK vfr_elaboration_callback
proc vfr_elaboration_callback {} {
  	# +-----------------------------------
	# | connection point avalon_streaming_source
	# | 
	set color_planes_in_parallel [get_parameter_value NUMBER_OF_CHANNELS_IN_PARALLEL]
	set bps [get_parameter_value BITS_PER_PIXEL_PER_COLOR_PLANE]
	set data_width [expr $bps * $color_planes_in_parallel]
	
	add_interface avalon_streaming_source avalon_streaming start
	set_interface_property avalon_streaming_source dataBitsPerSymbol $bps
	set_interface_property avalon_streaming_source symbolsPerBeat $color_planes_in_parallel
	set_interface_property avalon_streaming_source errorDescriptor ""
	set_interface_property avalon_streaming_source maxChannel 0
	set_interface_property avalon_streaming_source readyLatency 1
	
	add_interface_port avalon_streaming_source dout_data data Output $data_width
	add_interface_port avalon_streaming_source dout_valid valid Output 1
	add_interface_port avalon_streaming_source dout_ready ready Input 1
	add_interface_port avalon_streaming_source dout_startofpacket startofpacket Output 1
	add_interface_port avalon_streaming_source dout_endofpacket endofpacket Output 1	
	
	set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock_reset
	set_interface_property avalon_streaming_source ENABLED true	
	# | 
	# +-----------------------------------
	
	# +-----------------------------------
	# | connection point avalon_master
	# | 
	set mem_port_width [get_parameter_value MEM_PORT_WIDTH]
	add_interface avalon_master avalon start
	set_interface_property avalon_master burstOnBurstBoundariesOnly false
	set_interface_property avalon_master doStreamReads false
	set_interface_property avalon_master doStreamWrites false
	set_interface_property avalon_master linewrapBursts false
	
	set_interface_property avalon_master ASSOCIATED_CLOCK clock_master
	set_interface_property avalon_master ENABLED true
	
	set burst_target [get_parameter_value RMASTER_BURST_TARGET]
	add_interface_port avalon_master master_address address Output 32
	add_interface_port avalon_master master_burstcount burstcount Output [expr int(ceil((log($burst_target + 1))/(log(2))))]		
	add_interface_port avalon_master master_readdata readdata Input $mem_port_width
	add_interface_port avalon_master master_read read Output 1
	add_interface_port avalon_master master_readdatavalid readdatavalid Input 1
	add_interface_port avalon_master master_waitrequest waitrequest Input 1
	# | 
	# +-----------------------------------
}






