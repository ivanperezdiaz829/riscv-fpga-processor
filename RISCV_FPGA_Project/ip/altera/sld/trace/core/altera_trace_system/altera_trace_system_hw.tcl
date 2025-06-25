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


# altera_trace_system_hw.tcl

# +-----------------------------------
# | request TCL package from ACDS 13.0
# | 
package require -exact qsys 13.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_trace_system
# | 
set_module_property NAME altera_trace_system
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Verification/Debug & Performance"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Trace System"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property OPAQUE_ADDRESS_MAP false
set_module_property EDITABLE false
set_module_property composition_callback compose
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter MANUAL_DEBUG_FABRIC INTEGER 1
set_parameter_property MANUAL_DEBUG_FABRIC DISPLAY_NAME "Export interfaces for connection to manual debug fabric"
set_parameter_property MANUAL_DEBUG_FABRIC ALLOWED_RANGES {"0:No" "1:Yes"}
set_parameter_property MANUAL_DEBUG_FABRIC new_instance_value 0

add_parameter HOST_TYPE STRING JTAG
set_parameter_property HOST_TYPE DISPLAY_NAME "Connection to host"
set_parameter_property HOST_TYPE UNITS None
set_parameter_property HOST_TYPE ALLOWED_RANGES {JTAG:JTAG USB:USB}
set_parameter_property HOST_TYPE DESCRIPTION "Select type of connection to host"
set_parameter_property HOST_TYPE AFFECTS_GENERATION true
set_parameter_property HOST_TYPE HDL_PARAMETER false

add_parameter HOST_LINK_NAME STRING {}
set_parameter_property HOST_LINK_NAME DISPLAY_NAME "Automatic connection name"
set_parameter_property HOST_LINK_NAME UNITS None
set_parameter_property HOST_LINK_NAME DESCRIPTION "Name of automatic host link to use"
set_parameter_property HOST_LINK_NAME AFFECTS_GENERATION true
set_parameter_property HOST_LINK_NAME HDL_PARAMETER false

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

#add_parameter CLOCK_DOMAINS INTEGER 1
#set_parameter_property CLOCK_DOMAINS DEFAULT_VALUE 1
#set_parameter_property CLOCK_DOMAINS DISPLAY_NAME "Clock domains"
#set_parameter_property CLOCK_DOMAINS UNITS None
#set_parameter_property CLOCK_DOMAINS ALLOWED_RANGES 1:4
#set_parameter_property CLOCK_DOMAINS DESCRIPTION "Number of input clock domains"
#set_parameter_property CLOCK_DOMAINS DISPLAY_HINT ""
#set_parameter_property CLOCK_DOMAINS AFFECTS_GENERATION true
#set_parameter_property CLOCK_DOMAINS HDL_PARAMETER false
#set_parameter_property CLOCK_DOMAINS enabled true
#set_parameter_property CLOCK_DOMAINS STATUS experimental


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

add_parameter          ENABLE_BETA_EXTERNAL_MEM boolean "" ""
set_parameter_property ENABLE_BETA_EXTERNAL_MEM system_info_type quartus_ini 
set_parameter_property ENABLE_BETA_EXTERNAL_MEM system_info_arg  trace_system_enable_external_buffer_beta
set_parameter_property ENABLE_BETA_EXTERNAL_MEM visible false

add_parameter CLOCK_RATE INTEGER 0
set_parameter_property CLOCK_RATE SYSTEM_INFO { CLOCK_RATE clk }
set_parameter_property CLOCK_RATE DISPLAY_NAME "Clock frequency"
set_parameter_property CLOCK_RATE UNITS Hertz

#add_parameter          WAKE_UP_MODE string             "IDLE"
#set_parameter_property WAKE_UP_MODE DEFAULT_VALUE      "IDLE"
#set_parameter_property WAKE_UP_MODE DISPLAY_NAME       "Wake up mode"
#set_parameter_property WAKE_UP_MODE UNITS              None
#set_parameter_property WAKE_UP_MODE ALLOWED_RANGES     {"IDLE:IDLE" "CAPTURE:CAPTURE" "FIFO:FIFO"}
#set_parameter_property WAKE_UP_MODE DESCRIPTION        "what happens on release of reset"
#set_parameter_property WAKE_UP_MODE DISPLAY_HINT       ""
#set_parameter_property WAKE_UP_MODE AFFECTS_GENERATION true
#set_parameter_property WAKE_UP_MODE HDL_PARAMETER      true
#set_parameter_property WAKE_UP_MODE STATUS experimental

add_parameter          PIPELINE_STAGE_ON_ALL_INPUTS boolean            true
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DEFAULT_VALUE      true
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DISPLAY_NAME       "Insert pipeline stages on all capture inputs"
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS UNITS              None
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DESCRIPTION        ""
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS DISPLAY_HINT       ""
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS AFFECTS_GENERATION true
set_parameter_property PIPELINE_STAGE_ON_ALL_INPUTS HDL_PARAMETER      false

#add_parameter          PERIODIC_TS_REQ_STARTUP integer            0
#set_parameter_property PERIODIC_TS_REQ_STARTUP DEFAULT_VALUE      0
#set_parameter_property PERIODIC_TS_REQ_STARTUP DISPLAY_NAME       "Periodic Timestamp service default period"
#set_parameter_property PERIODIC_TS_REQ_STARTUP UNITS              None
#set_parameter_property PERIODIC_TS_REQ_STARTUP DESCRIPTION        ""
#set_parameter_property PERIODIC_TS_REQ_STARTUP DISPLAY_HINT       ""
#set_parameter_property PERIODIC_TS_REQ_STARTUP AFFECTS_GENERATION true
#set_parameter_property PERIODIC_TS_REQ_STARTUP HDL_PARAMETER      true
#set_parameter_property PERIODIC_TS_REQ_STARTUP STATUS experimental

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
#add_display_item   "Advanced"          PERIODIC_TS_REQ_STARTUP parameter
#add_display_item   "Advanced"          WAKE_UP_MODE parameter
#add_display_item   "Advanced"          CLOCK_DOMAINS parameter

# +-----------------------------------
# | connection point clock
# | 
add_interface clk clock end

add_interface reset reset start

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
add_connection clock0.out_clk reset0.clk

add_instance reset1 altera_reset_bridge
set_interface_property reset export_of reset1.out_reset
add_connection clock0.out_clk reset1.clk
add_connection reset0.out_reset reset1.in_reset

add_instance tracesys altera_trace_fabric
set_instance_parameter_value tracesys WAKE_UP_MODE IDLE
set_instance_parameter_value tracesys PERIODIC_TS_REQ_STARTUP 0
add_connection clock0.out_clk tracesys.clk
add_connection reset0.out_reset tracesys.reset

# | 
# +-----------------------------------

proc compose {} {
    set external_mem_en [get_parameter_value ENABLE_BETA_EXTERNAL_MEM]
    set_parameter_property INTERNAL_MEM visible [string equal $external_mem_en "true"]
    set_parameter_property EXTMEM_BASE visible [string equal $external_mem_en "true"]
    set_parameter_property EXTMEM_SIZE visible [string equal $external_mem_en "true"]

    set capture_width [get_parameter_value CAPTURE_WIDTH]
	set inputs [get_parameter_value INPUTS]

	set settings [list]
	for { set i 0 } { $i < $inputs } { incr i } {
		lappend settings "trace_width $capture_width addr_width 6 read_latency 0"
	}
	set_instance_parameter_value tracesys SETTINGS $settings
    
	set internal_mem [get_parameter_value INTERNAL_MEM]
    if {$internal_mem} {
    	set memsize [get_parameter_value MEMSIZE]
    } else {
    	set memsize 0
    }
    set_instance_parameter_value tracesys MEMSIZE       $memsize
    set_instance_parameter_value tracesys EXTMEM_BASE   [get_parameter_value EXTMEM_BASE]
    set_instance_parameter_value tracesys EXTMEM_SIZE   [get_parameter_value EXTMEM_SIZE]
	set_instance_parameter_value tracesys PIPELINE_STAGE_ON_ALL_INPUTS [get_parameter_value PIPELINE_STAGE_ON_ALL_INPUTS]

	set host_type [get_parameter_value HOST_TYPE]
	set manual [get_parameter_value MANUAL_DEBUG_FABRIC]
	set host_link_name [get_parameter_value HOST_LINK_NAME]

	if {$manual} {
		# Manual fabric modes
	    if {$host_type == "USB"} {
			add_instance link altera_usb_debug_link
			set_instance_parameter_value link DUAL_CLOCK 1
			set_instance_parameter_value link FIFO_DEPTH 256
			set_instance_parameter_value link CHANNEL_WIDTH 8
			set_instance_parameter_value link MANUAL_DEBUG_FABRIC 1
    
	    	add_connection clock0.out_clk link.debug_clk_in
    		add_connection link.debug_reset reset0.in_reset
	
			add_interface usb_if conduit end
			set_interface_property usb_if export_of link.usb_if
			set_interface_assignment usb_if qsys.ui.export usb
    	} else {
			add_instance link altera_jtag_debug_link
			set_instance_parameter_value link USE_PLI 0
			set_instance_parameter_value link PLI_PORT 50000
			set_instance_parameter_value link CHANNEL_WIDTH 8
			set_instance_parameter_value link MANUAL_DEBUG_FABRIC 1
    
    		add_connection clock0.out_clk link.clk
    		add_connection link.debug_reset reset0.in_reset
		}

		add_instance fabric altera_debug_fabric
		set_instance_parameter_value fabric STREAMS 1
		set_instance_parameter_value fabric MASTERS 0
		set_instance_parameter_value fabric USE_ROM 0
		set_instance_parameter_value fabric STREAM_CONFIG {{ mfr_code 0x6E type_code 261 ready 1 channel_width 1 downReadyLatency 0 upReadyLatency 0 }}
		set_instance_parameter_value fabric CHANNEL_WIDTH 8
		add_connection clock0.out_clk fabric.clk
		add_connection reset0.out_reset fabric.reset

		add_connection link.h2t fabric.h2t
		add_connection fabric.t2h link.t2h
		add_connection link.mgmt fabric.mgmt

		add_connection fabric.h2t_0 tracesys.h2t
		add_connection tracesys.t2h fabric.t2h_0

    } else {
		add_instance endpoint altera_avalon_st_debug_agent_endpoint
		set_instance_parameter_value endpoint CHANNEL_WIDTH 1
		set_instance_parameter_value endpoint READY_LATENCY 0
		set_instance_parameter_value endpoint MFR_CODE 110
		set_instance_parameter_value endpoint TYPE_CODE 261
		set_instance_parameter_value endpoint PREFER_HOST $host_link_name

    	add_connection clock0.out_clk endpoint.clk
   		add_connection endpoint.reset reset0.in_reset
		add_connection endpoint.h2t tracesys.h2t
		add_connection tracesys.t2h endpoint.t2h
    }

	if {$internal_mem == 0} {
		# Export the master interface from the capture controller
	
		set_interface_property storage_master export_of tracesys.storage_master
		set_interface_property storage_master enabled true
	}

	for { set i 0 } { $i < $inputs } { incr i } {
		set capture "capture_$i"
		set control "control_$i"

		add_interface $capture avalon_streaming end
		set_interface_property $capture export_of tracesys.$capture

		add_interface $control avalon start
		set_interface_property $control export_of tracesys.$control
	}
	
}
