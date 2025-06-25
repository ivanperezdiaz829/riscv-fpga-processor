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


# altera_trace_controller_hw.tcl

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_trace_controller
# | 
set_module_property NAME altera_trace_controller
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Verification/Debug & Performance"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Trace Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property compose_callback compose
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter CAPTURE_WIDTH INTEGER 32
set_parameter_property CAPTURE_WIDTH DEFAULT_VALUE 32
set_parameter_property CAPTURE_WIDTH DISPLAY_NAME "Bit width of capture interface(s)"
set_parameter_property CAPTURE_WIDTH UNITS None
set_parameter_property CAPTURE_WIDTH ALLOWED_RANGES 8,16,32,64,128
set_parameter_property CAPTURE_WIDTH DESCRIPTION "Width of the capture input signals"
set_parameter_property CAPTURE_WIDTH DISPLAY_HINT ""
set_parameter_property CAPTURE_WIDTH AFFECTS_GENERATION true
set_parameter_property CAPTURE_WIDTH HDL_PARAMETER false

add_parameter INPUTS INTEGER 2
set_parameter_property INPUTS DEFAULT_VALUE 2
set_parameter_property INPUTS DISPLAY_NAME "Number of inputs"
set_parameter_property INPUTS UNITS None
set_parameter_property INPUTS ALLOWED_RANGES 1:255
set_parameter_property INPUTS DESCRIPTION "Number of Avalon-ST capture inputs in each clock domain"
set_parameter_property INPUTS DISPLAY_HINT ""
set_parameter_property INPUTS AFFECTS_GENERATION true
set_parameter_property INPUTS HDL_PARAMETER false

add_parameter CLOCK_DOMAINS INTEGER 1
set_parameter_property CLOCK_DOMAINS DEFAULT_VALUE 1
set_parameter_property CLOCK_DOMAINS DISPLAY_NAME "Clock domains"
set_parameter_property CLOCK_DOMAINS UNITS None
set_parameter_property CLOCK_DOMAINS ALLOWED_RANGES 1:4
set_parameter_property CLOCK_DOMAINS DESCRIPTION "Number of input clock domains"
set_parameter_property CLOCK_DOMAINS DISPLAY_HINT ""
set_parameter_property CLOCK_DOMAINS AFFECTS_GENERATION true
set_parameter_property CLOCK_DOMAINS HDL_PARAMETER false
set_parameter_property CLOCK_DOMAINS enabled true
set_parameter_property CLOCK_DOMAINS STATUS experimental


add_parameter INTERNAL_MEM INTEGER 1
set_parameter_property INTERNAL_MEM DISPLAY_NAME "Use built-in buffer to store trace data"
set_parameter_property INTERNAL_MEM UNITS None
set_parameter_property INTERNAL_MEM ALLOWED_RANGES 0:1
set_parameter_property INTERNAL_MEM DESCRIPTION "Controls whether trace data is stored in memory internal to trace system component or externally"
set_parameter_property INTERNAL_MEM DISPLAY_HINT "boolean"
set_parameter_property INTERNAL_MEM AFFECTS_GENERATION true
set_parameter_property INTERNAL_MEM HDL_PARAMETER false
set_parameter_property INTERNAL_MEM enabled true

add_parameter MEMSIZE INTEGER 32768
set_parameter_property MEMSIZE DISPLAY_NAME "Buffer size"
set_parameter_property MEMSIZE UNITS None
set_parameter_property MEMSIZE ALLOWED_RANGES 8192,16384,32768,65536
set_parameter_property MEMSIZE DESCRIPTION "The size of the memory buffer to use"
set_parameter_property MEMSIZE DISPLAY_HINT ""
set_parameter_property MEMSIZE AFFECTS_GENERATION true
set_parameter_property MEMSIZE HDL_PARAMETER false

add_parameter EXTMEM_BASE INTEGER 0
set_parameter_property EXTMEM_BASE DISPLAY_NAME "External memory base address"
set_parameter_property EXTMEM_BASE UNITS None
set_parameter_property EXTMEM_BASE DESCRIPTION "The lowest address in external memory where trace data will be stored"
set_parameter_property EXTMEM_BASE DISPLAY_HINT "hexadecimal"
set_parameter_property EXTMEM_BASE AFFECTS_GENERATION true
set_parameter_property EXTMEM_BASE HDL_PARAMETER false
set_parameter_property EXTMEM_BASE enabled true

add_parameter EXTMEM_SIZE INTEGER 0x100000
set_parameter_property EXTMEM_SIZE DISPLAY_NAME "External memory buffer size"
set_parameter_property EXTMEM_SIZE UNITS bytes
set_parameter_property EXTMEM_SIZE DESCRIPTION "The number of bytes in external memory used to store trace data"
set_parameter_property EXTMEM_SIZE DISPLAY_HINT "hexadecimal"
set_parameter_property EXTMEM_SIZE AFFECTS_GENERATION true
set_parameter_property EXTMEM_SIZE HDL_PARAMETER false
set_parameter_property EXTMEM_SIZE enabled true


add_parameter CLOCK_RATE INTEGER 0
set_parameter_property CLOCK_RATE SYSTEM_INFO { CLOCK_RATE clk }
set_parameter_property CLOCK_RATE DISPLAY_NAME "Clock frequency"
set_parameter_property CLOCK_RATE UNITS Hertz

add_parameter          WAKE_UP_MODE string             "IDLE"
set_parameter_property WAKE_UP_MODE DEFAULT_VALUE      "IDLE"
set_parameter_property WAKE_UP_MODE DISPLAY_NAME       "Wake up mode"
set_parameter_property WAKE_UP_MODE UNITS              None
set_parameter_property WAKE_UP_MODE ALLOWED_RANGES     {"IDLE:IDLE" "CAPTURE:CAPTURE" "FIFO:FIFO"}
set_parameter_property WAKE_UP_MODE DESCRIPTION        "what happens on release of reset"
set_parameter_property WAKE_UP_MODE DISPLAY_HINT       ""
set_parameter_property WAKE_UP_MODE AFFECTS_GENERATION true
set_parameter_property WAKE_UP_MODE HDL_PARAMETER      true
set_parameter_property WAKE_UP_MODE STATUS experimental

add_parameter          PIPELINE_STAGE_ON_ALL_INPUTS boolean            true
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DEFAULT_VALUE      true
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DISPLAY_NAME       "Insert pipeline stages on all capture inputs"
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS UNITS              None
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DESCRIPTION        ""
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DISPLAY_HINT       ""
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS AFFECTS_GENERATION true
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS HDL_PARAMETER      false

add_parameter          PERIODIC_TS_REQ_STARTUP integer            0
set_parameter_property PERIODIC_TS_REQ_STARTUP DEFAULT_VALUE      0
set_parameter_property PERIODIC_TS_REQ_STARTUP DISPLAY_NAME       "Periodic Timestamp service default period"
set_parameter_property PERIODIC_TS_REQ_STARTUP UNITS              None
set_parameter_property PERIODIC_TS_REQ_STARTUP DESCRIPTION        ""
set_parameter_property PERIODIC_TS_REQ_STARTUP DISPLAY_HINT       ""
set_parameter_property PERIODIC_TS_REQ_STARTUP AFFECTS_GENERATION true
set_parameter_property PERIODIC_TS_REQ_STARTUP HDL_PARAMETER      true
set_parameter_property PERIODIC_TS_REQ_STARTUP STATUS experimental

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameter GUI groups									  --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
add_display_item   "Capture"           CAPTURE_WIDTH parameter
add_display_item   "Capture"           INPUTS parameter
add_display_item   "Buffering"         INTERNAL_MEM parameter
add_display_item   "Buffering"         MEMSIZE parameter
add_display_item   "Buffering"         EXTMEM_BASE parameter
add_display_item   "Buffering"         EXTMEM_SIZE parameter
add_display_item   "Advanced"          PIPELINE_STAGE_ON_ALL_INPUTS parameter
add_display_item   "Advanced"          CLOCK_RATE parameter
add_display_item   "Advanced"          PERIODIC_TS_REQ_STARTUP parameter
add_display_item   "Advanced"          WAKE_UP_MODE parameter
add_display_item   "Advanced"          CLOCK_DOMAINS parameter

# +-----------------------------------
# | connection point clock
# | 
add_interface clk clock end

add_interface reset reset end

add_interface h2t avalon_streaming end

add_interface t2h avalon_streaming source

set_interface_assignment h2t debug.providesServices traceCapture
set_interface_assignment h2t debug.interfaceGroup {associatedT2h t2h}

add_interface storage_master avalon start
set_interface_property storage_master enabled false
# | 
# +-----------------------------------

# +-----------------------------------
# | children
# | 
add_instance clock0 altera_clock_bridge
set_interface_property clk export_of clock0.in_clk

add_instance reset0 altera_reset_bridge
set_interface_property reset export_of reset0.in_reset
add_connection clock0.out_clk reset0.clk

add_instance h2t_pipeline altera_avalon_st_pipeline_stage
set_instance_parameter_value h2t_pipeline USE_PACKETS 1
add_connection clock0.out_clk h2t_pipeline.cr0
add_connection reset0.out_reset h2t_pipeline.cr0_reset
set_interface_property h2t export_of h2t_pipeline.sink0

add_instance demux demultiplexer
set_instance_parameter_value demux bitsPerSymbol 8
set_instance_parameter_value demux symbolsPerBeat 1
set_instance_parameter_value demux errorWidth 0
set_instance_parameter_value demux inChannelWidth 2
set_instance_parameter_value demux numOutputInterfaces 2
set_instance_parameter_value demux usePackets true
set_instance_parameter_value demux useHighBitsOfChannel true
add_connection clock0.out_clk demux.clk
add_connection reset0.out_reset demux.reset
add_connection h2t_pipeline.source0 demux.in

add_instance t2h_pipeline altera_avalon_st_pipeline_stage
set_instance_parameter_value t2h_pipeline USE_PACKETS 1
add_connection clock0.out_clk t2h_pipeline.cr0
add_connection reset0.out_reset t2h_pipeline.cr0_reset
set_interface_property t2h export_of t2h_pipeline.source0

add_instance mux multiplexer
set_instance_parameter_value mux bitsPerSymbol 8
set_instance_parameter_value mux symbolsPerBeat 1
set_instance_parameter_value mux errorWidth 0
set_instance_parameter_value mux outChannelWidth 2
set_instance_parameter_value mux numInputInterfaces 2
set_instance_parameter_value mux usePackets true
set_instance_parameter_value mux useHighBitsOfChannel true
set_instance_parameter_value mux packetScheduling true
add_connection clock0.out_clk mux.clk
add_connection reset0.out_reset mux.reset
add_connection mux.out t2h_pipeline.sink0

# Transacto lite on channel 0
add_instance trans0 altera_trace_transacto_lite
add_connection clock0.out_clk trans0.clk
add_connection reset0.out_reset trans0.reset
add_connection demux.out0 trans0.h2t
add_connection trans0.t2h mux.in0

# Rom at address 0 in config space 
add_instance rom altera_trace_rom
add_connection clock0.out_clk rom.clk
add_connection reset0.out_reset rom.reset
set c [add_connection trans0.master rom.rom]
set_connection_parameter $c baseAddress 0

# Capture controller at address 256 in config space
add_instance capture altera_trace_capture_controller
add_connection clock0.out_clk capture.clk
add_connection reset0.out_reset capture.reset
set c [add_connection trans0.master capture.csr_slave]
set_connection_parameter $c baseAddress 256

# Discard anything sent from h2t on channel 1
add_instance capture_sink altera_avalon_st_null_sink
add_connection clock0.out_clk capture_sink.clk
add_connection reset0.out_reset capture_sink.reset
add_connection demux.out1 capture_sink.in

#wide_capture_pipeline lives between the capture controller and the width adapter to improve FMAX...
# this is becasue we have the output of a fifo from the captuer controller and valid is not a single bit.
add_instance wide_capture_pipeline altera_avalon_st_pipeline_stage
#set_instance_parameter_value wide_capture_pipeline inSymbolsPerBeat {set in callback}   
#  note: this is also used to dynamically determin if use_empty == 1
set_instance_parameter_value wide_capture_pipeline BITS_PER_SYMBOL 8           
set_instance_parameter_value wide_capture_pipeline USE_PACKETS     1
set_instance_parameter_value wide_capture_pipeline PIPELINE_READY  1
add_connection clock0.out_clk   wide_capture_pipeline.cr0
add_connection reset0.out_reset wide_capture_pipeline.cr0_reset
add_connection capture.t2h      wide_capture_pipeline.sink0

# Width adapter to convert width of capture output
add_instance capture_width data_format_adapter
set_instance_parameter_value capture_width inUsePackets 1
set_instance_parameter_value capture_width inBitsPerSymbol 8
#set_instance_parameter_value capture_width inSymbolsPerBeat {set in callback}
set_instance_parameter_value capture_width outSymbolsPerBeat 1
add_connection clock0.out_clk                capture_width.clk
add_connection reset0.out_reset              capture_width.reset
add_connection wide_capture_pipeline.source0 capture_width.in

# Add a pipeline stage to improve the fmax    
add_instance capture_pipeline altera_avalon_st_pipeline_stage
set_instance_parameter_value capture_pipeline USE_PACKETS    1
set_instance_parameter_value capture_pipeline PIPELINE_READY 1
add_connection clock0.out_clk           capture_pipeline.cr0
add_connection reset0.out_reset         capture_pipeline.cr0_reset
add_connection capture_width.out        capture_pipeline.sink0
add_connection capture_pipeline.source0 mux.in1


# | 
# +-----------------------------------

proc compose {} {
    set domains [get_parameter_value CLOCK_DOMAINS]
    set internal_mem [get_parameter_value INTERNAL_MEM]
    set memsize [get_parameter_value MEMSIZE]
    set extmemBase [get_parameter_value EXTMEM_BASE]
    set extmemSize [get_parameter_value EXTMEM_SIZE]
    set inputs [get_parameter_value INPUTS]
    set capture_width [get_parameter_value CAPTURE_WIDTH]
    set clock_rate [get_parameter_value CLOCK_RATE]
	set pipeline_inputs [get_parameter_value PIPELINE_STAGE_ON_ALL_INPUTS]

	# In future we'll need more agents for more clock domains
	set agents [expr 1 + $domains]

	set channelBits [expr "[log2ceil $agents]"]
	#send_message {text info} "agents: $agents channelBits: $channelBits"

	set_instance_parameter_value demux numOutputInterfaces $agents
	set_instance_parameter_value demux inChannelWidth $channelBits
	set_instance_parameter_value h2t_pipeline CHANNEL_WIDTH $channelBits
	set_instance_parameter_value h2t_pipeline MAX_CHANNEL [expr (1 << $channelBits) - 1]

	set_instance_parameter_value mux numInputInterfaces $agents
	set_instance_parameter_value mux outChannelWidth $channelBits
	set_instance_parameter_value t2h_pipeline CHANNEL_WIDTH $channelBits
	set_instance_parameter_value t2h_pipeline MAX_CHANNEL [expr (1 << $channelBits) - 1]

    set_instance_parameter_value  wide_capture_pipeline SYMBOLS_PER_BEAT  [expr $capture_width / 8]
    if {$capture_width == 8} {
    	   set_instance_parameter_value wide_capture_pipeline USE_EMPTY 0           	   
    } else {
    	   set_instance_parameter_value wide_capture_pipeline USE_EMPTY 1           	   
    }
	
	for { set j 1 } { $j < $domains } { incr j } {
		set c [expr $j+1]
		add_interface clk$j clock end
		add_interface reset$j reset end

		add_instance clock$j altera_clock_bridge
		set_interface_property clk$j export_of clock$j.in_clk

		add_instance reset$j altera_reset_bridge
		set_interface_property reset$j export_of reset$j.in_reset
		add_connection clock$j.out_clk reset$j.clk

		# Add clock domain crossers for transacto lite
		# TODO: Add a hidden parameter to control synchroniser depth
		add_instance trans_h2t$j altera_avalon_st_handshake_clock_crosser
		set_instance_parameter_value trans_h2t$j USE_PACKETS 1
		add_connection clock0.out_clk trans_h2t$j.in_clk
		add_connection reset0.out_reset trans_h2t$j.in_clk_reset
		add_connection clock$j.out_clk trans_h2t$j.out_clk
		add_connection reset$j.out_reset trans_h2t$j.out_clk_reset
		add_connection demux.out$c trans_h2t$j.in

		add_instance trans_t2h$j altera_avalon_st_handshake_clock_crosser
		set_instance_parameter_value trans_t2h$j USE_PACKETS 1
		add_connection clock$j.out_clk trans_t2h$j.in_clk
		add_connection reset$j.out_reset trans_t2h$j.in_clk_reset
		add_connection clock0.out_clk trans_t2h$j.out_clk
		add_connection reset0.out_reset trans_t2h$j.out_clk_reset
		add_connection trans_t2h$j.out mux.in$c
		
		# Add transacto lite for this clock domain (on channel 2+)
		add_instance trans$j altera_trace_transacto_lite
		add_connection clock$j.out_clk trans$j.clk
		add_connection reset$j.out_reset trans$j.reset
		add_connection trans_h2t$j.out trans$j.h2t
		add_connection trans$j.t2h trans_t2h$j.in
	}

	set_instance_parameter_value capture_width inSymbolsPerBeat [expr $capture_width / 8]

	if {$internal_mem > 0} {
		# If using built-in memory then create a memory of a suitable size and connect it up
		add_instance mem altera_avalon_onchip_memory2

		set_instance_parameter_value mem dataWidth $capture_width
		set_instance_parameter_value mem memorySize $memsize
		set_instance_parameter_value mem initMemContent false
		set_instance_parameter_value mem slave1Latency 2
		
		add_connection clock0.out_clk mem.clk1
		add_connection reset0.out_reset mem.reset1
		add_connection capture.storage_mm_master mem.s1
	
		set_interface_property storage_master enabled false
	} else {
		# Export the master interface from the capture controller
	
		set_interface_property storage_master export_of capture.storage_mm_master
		set_interface_property storage_master enabled true
	}

	set domainChannels      [expr 1 + $inputs]
	set domainChannelBits   [expr "[log2ceil $domainChannels]"]
	
	set traceChannelBits   [expr "[log2ceil $domains] + $domainChannelBits"]
	set buff_symbol_width  [expr $capture_width/ 8]
	set num_addr_locations [expr $memsize / $buff_symbol_width]
	
	if {$internal_mem > 0} {
		set buffAddrWidth [expr [log2ceil $num_addr_locations] ]
		set buffStart 0
		set buffSize $num_addr_locations
		set_parameter_property MEMSIZE enabled true
		set_parameter_property EXTMEM_BASE enabled false
		set_parameter_property EXTMEM_SIZE enabled false
	} else {
		set buffAddrWidth 31
		set buffStart $extmemBase
		set buffSize $num_addr_locations
		set_parameter_property MEMSIZE enabled false
		set_parameter_property EXTMEM_BASE enabled true
		set_parameter_property EXTMEM_SIZE enabled true
	}
	
	set_instance_parameter_value capture TRACE_DATA_WIDTH         $capture_width
	set_instance_parameter_value capture TRACE_SYMBOL_WIDTH       8
	set_instance_parameter_value capture TRACE_CHNL_WIDTH         $traceChannelBits
	set_instance_parameter_value capture TRACE_MAX_CHNL           [expr (1 << $traceChannelBits) - 1]
	set_instance_parameter_value capture BUFF_ADDR_WIDTH          $buffAddrWidth
	set_instance_parameter_value capture BUFF_LIMIT_LO            $buffStart
	set_instance_parameter_value capture BUFF_SIZE                $buffSize
#	set_instance_parameter_value capture ALIGNMENT_BOUNDARIES     0
#	set_instance_parameter_value capture MAX_OUT_PACKET_LENGTH    0
#	set_instance_parameter_value capture CREDIT_WIDTH             0
# cell header parameterisation                                    
#	set_instance_parameter_value capture PACKET_LEN_BITS          0
#	set_instance_parameter_value capture NUM_PPD                  0

	if {$capture_width == 64} {
# using num_ppd == 4 instead of 5 as this allows room for more monitors... 
		set_instance_parameter_value capture NUM_PPD                  4
	} else {
		set_instance_parameter_value capture NUM_PPD                  2	
	}

# wakeup modes	                                                  
	set_instance_parameter_value capture WAKE_UP_MODE             [get_parameter_value WAKE_UP_MODE           ]
	set_instance_parameter_value capture PERIODIC_TS_REQ_STARTUP  [get_parameter_value PERIODIC_TS_REQ_STARTUP]
# debug
#	set_instance_parameter_value capture DEBUG_READBACK           0

	set symbolsPerBeat [expr $capture_width / 8]
	
	if {$domains > 1} {
		add_instance capture_mux multiplexer
		set_instance_parameter_value capture_mux bitsPerSymbol 8
		set_instance_parameter_value capture_mux symbolsPerBeat 1
		set_instance_parameter_value capture_mux errorWidth 0
		set_instance_parameter_value capture_mux outChannelWidth 2
		set_instance_parameter_value capture_mux numInputInterfaces 2
		set_instance_parameter_value capture_mux usePackets true
		set_instance_parameter_value capture_mux useHighBitsOfChannel true
		set_instance_parameter_value capture_mux packetScheduling true
		add_connection clock0.out_clk capture_mux.clk
		add_connection reset0.out_reset capture_mux.reset
		add_connection capture_mux.out capture.trace_packet_sink

		set_instance_parameter_value capture_mux symbolsPerBeat     $symbolsPerBeat
		set_instance_parameter_value capture_mux numInputInterfaces $domains
		set_instance_parameter_value capture_mux outChannelWidth    $traceChannelBits
	}

	# ROM contents are:
	# @0: ROM version number
	# @4: Number of clock domains
	set rom_contents [format "%08X%08X" $domains 1]

	set id 0
	set addr 512

	for { set j 0 } { $j < $domains } { incr j } {

		add_instance capture_mux$j multiplexer
		set_instance_parameter_value capture_mux$j bitsPerSymbol 8
		set_instance_parameter_value capture_mux$j symbolsPerBeat     $symbolsPerBeat
		set_instance_parameter_value capture_mux$j errorWidth 0
		set_instance_parameter_value capture_mux$j numInputInterfaces $domainChannels
		set_instance_parameter_value capture_mux$j outChannelWidth    $domainChannelBits
		set_instance_parameter_value capture_mux$j usePackets true
		set_instance_parameter_value capture_mux$j useHighBitsOfChannel true
		set_instance_parameter_value capture_mux$j packetScheduling true
		add_connection clock$j.out_clk capture_mux$j.clk
		add_connection reset$j.out_reset capture_mux$j.reset

		# TODO: Add channel adapter if clock domains are different widths
		
		if {$j > 0} {
			# Clock domain crosser 
			# TODO: Add a hidden parameter to control synchroniser depth
			add_instance capture_crosser$j altera_avalon_dc_fifo
			set_instance_parameter_value capture_crosser$j BITS_PER_SYMBOL 8
			set_instance_parameter_value capture_crosser$j SYMBOLS_PER_BEAT $symbolsPerBeat
			set_instance_parameter_value capture_crosser$j FIFO_DEPTH 16
			set_instance_parameter_value capture_crosser$j CHANNEL_WIDTH $domainChannelBits
			set_instance_parameter_value capture_crosser$j USE_PACKETS 1
			add_connection clock$j.out_clk capture_crosser$j.in_clk
			add_connection reset$j.out_reset capture_crosser$j.in_clk_reset
			add_connection clock0.out_clk capture_crosser$j.out_clk
			add_connection reset0.out_reset capture_crosser$j.out_clk_reset
			add_connection capture_mux$j.out capture_crosser$j.in
			add_connection capture_crosser$j.out capture_mux.in$j
		} elseif {$domains > 1} {
			add_connection capture_mux$j.out capture_mux.in$j
		} else {
			add_connection capture_mux0.out capture.trace_packet_sink
		}

		add_instance sync$j altera_trace_timestamp_monitor
		set_instance_parameter_value sync$j TRACE_DATA_WIDTH $capture_width
		set_instance_parameter_value sync$j FULL_TS_LENGTH 40
		set_instance_parameter_value sync$j SHORT_TS_BITS 16
		set ts_widths [expr (16 << 8) + 40]

		add_connection clock$j.out_clk sync$j.clock
		add_connection reset$j.out_reset sync$j.reset_sink
		add_connection capture.st_sync_req_clk sync$j.ts_sync_req
	
		if { $pipeline_inputs == "true"} {	
			# add an instance of the pipeline bridge
		   set input_pipe "sync_pipe$j"
           add_instance $input_pipe altera_avalon_st_pipeline_stage
           set_instance_parameter_value     $input_pipe USE_PACKETS 1
           set_instance_parameter_value     $input_pipe BITS_PER_SYMBOL 8           
           set_instance_parameter_value     $input_pipe SYMBOLS_PER_BEAT  [expr $capture_width / 8]
           set_instance_parameter_value     $input_pipe PIPELINE_READY 1
           if {$capture_width == 8} {
           	   set_instance_parameter_value $input_pipe USE_EMPTY 0           	   
           } else {
           	   set_instance_parameter_value $input_pipe USE_EMPTY 1           	   
           }

           add_connection clock$j.out_clk     $input_pipe.cr0
           add_connection reset$j.out_reset   $input_pipe.cr0_reset
           add_connection sync$j.capture      $input_pipe.sink0
           add_connection $input_pipe.source0 capture_mux$j.in0			
		} else {
			add_connection sync$j.capture capture_mux$j.in0
		}

		incr id
		incr addr 256

		# For each clock domain
		# @+0: clock rate
		# @+4: number of monitors
		set rom_contents [format "%08X%08X%08X%s" $ts_widths $inputs $clock_rate $rom_contents]

		if {$j == 0} {
			set dom ""
		} else {
			set dom $j
		}

		for { set i 0 } { $i < $inputs } { incr i } {
			set capture "capture${dom}_$i"
			set control "control${dom}_$i"
			set bridge "bridge${j}_$i"
			set k [expr $i + 1]

			add_interface $control avalon start

			add_interface $capture avalon_streaming end

			if { $pipeline_inputs == "true"} {	
				# add an instance of the pipeline bridge
				set input_pipe "capture_pipe${j}_$i"
				add_instance $input_pipe altera_avalon_st_pipeline_stage
				set_instance_parameter_value     $input_pipe USE_PACKETS 1
				set_instance_parameter_value     $input_pipe BITS_PER_SYMBOL 8           
				set_instance_parameter_value     $input_pipe SYMBOLS_PER_BEAT  [expr $capture_width / 8]
				set_instance_parameter_value     $input_pipe PIPELINE_READY 1
				if {$capture_width == 8} {
					set_instance_parameter_value     $input_pipe USE_EMPTY 0           	   
				} else {
					set_instance_parameter_value     $input_pipe USE_EMPTY 1           	   
				}

				add_connection clock$j.out_clk       $input_pipe.cr0
				add_connection reset$j.out_reset     $input_pipe.cr0_reset
				add_connection $input_pipe.source0 capture_mux$j.in$k			
				set_interface_property $capture export_of $input_pipe.sink0
			} else {
				set_interface_property $capture export_of capture_mux$j.in$k
			}
		
			set_interface_assignment $capture debug.channelOffset $id
			set_interface_assignment $capture debug.controlledBy h2t
			set_interface_assignment $capture debug.interfaceGroup [list associatedControl $control]

			add_instance $bridge altera_avalon_mm_bridge
			set_instance_parameter_value $bridge ADDRESS_WIDTH 8
			set_instance_parameter_value $bridge MAX_PENDING_RESPONSES 1
			set_instance_parameter_value $bridge PIPELINE_COMMAND 0
			set_instance_parameter_value $bridge PIPELINE_RESPONSE 0

			add_connection clock$j.out_clk $bridge.clk
			add_connection reset$j.out_reset $bridge.reset
			set c [add_connection trans$j.master $bridge.s0]
			set_interface_property $control export_of $bridge.m0

			set_connection_parameter $c baseAddress $addr

			incr id
			incr addr 256
		}

		# Set transacto address width (it's a word address)
		set_instance_parameter_value trans$j ADDR_WIDTH [expr [log2ceil $addr] - 2]
	
		set addr 0
	}
	
	# Configure ROM with information about system
	set_instance_parameter_value rom REG_VALUE_STRING $rom_contents
	set rom_regs [expr [string length $rom_contents] / 8]
	set_instance_parameter_value rom NUM_REGS $rom_regs
	set_instance_parameter_value rom ADDR_WIDTH [log2ceil $rom_regs]
	
	#send_message info "Trace ROM: $rom_contents $rom_regs"
}

proc log2ceil x "expr {int(ceil(log(\$x)/[expr log(2)]))}"
