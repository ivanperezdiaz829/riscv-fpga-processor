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


# +-----------------------------------
# |
# | altera_usb_debug_fifos "altera_usb_debug_fifos" v1.0
# |
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
# |
package require -exact sopc 10.1
# |
# +-----------------------------------

# +-----------------------------------
# | handy functions
# |
proc log2ceil {num} {
    #make log(0), log(1) = 1
    set val 1
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }
    return $val;
}
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_usb_debug_fifos
# |
set_module_property NAME altera_usb_debug_fifos
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Verification/Debug & Performance"
set_module_property DISPLAY_NAME "USB Debug FIFOs"
set_module_property TOP_LEVEL_HDL_FILE altera_usb_debug_fifos.v
set_module_property TOP_LEVEL_HDL_MODULE altera_usb_debug_fifos
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_file altera_usb_debug_fifos.v        {SYNTHESIS SIMULATION}
add_file altera_usb_debug_prbs8.v        {SYNTHESIS SIMULATION}
add_file altera_usb_debug_i2c.v          {SYNTHESIS SIMULATION}
add_file altera_usb_debug_i2c_slave.v    {SYNTHESIS SIMULATION}
#
add_file $::env(QUARTUS_ROOTDIR)/../ip/altera/merlin/altera_reset_controller/altera_reset_synchronizer.v                            {SYNTHESIS SIMULATION}
add_file $::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v   {SYNTHESIS SIMULATION}
add_file $::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv          {SYNTHESIS SIMULATION}
#needed by altera_avalon_st_clock_crosser.v,altera_avalon_st_pipeline_stage.sv
add_file $::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v            {SYNTHESIS SIMULATION}

# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter DEVICE_FAMILY STRING "StratixIV"
set_parameter_property DEVICE_FAMILY VISIBLE false
set_parameter_property DEVICE_FAMILY AFFECTS_GENERATION false
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true
set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY

add_parameter AUTO_CLOCK_RATE INTEGER 0
set_parameter_property AUTO_CLOCK_RATE VISIBLE false
set_parameter_property AUTO_CLOCK_RATE AFFECTS_GENERATION false
set_parameter_property AUTO_CLOCK_RATE HDL_PARAMETER false
set_parameter_property AUTO_CLOCK_RATE SYSTEM_INFO {CLOCK_RATE av_clk}

add_parameter USE_DCFIFO INTEGER 1
set_parameter_property USE_DCFIFO DISPLAY_NAME "Dual Clocks"
set_parameter_property USE_DCFIFO ALLOWED_RANGES {"0:No" "1:Yes"}
set_parameter_property USE_DCFIFO AFFECTS_GENERATION false
set_parameter_property USE_DCFIFO HDL_PARAMETER true

add_parameter FIFO_DEPTH INTEGER 256
set_parameter_property FIFO_DEPTH DISPLAY_NAME "FIFO Depth"
set_parameter_property FIFO_DEPTH ALLOWED_RANGES {"4:4" "8:8" "16:16" "32:32" "64:64" "128:128" "256:256" "512:512" "1024:1K (1xM9K)" "2048:2K"}
set_parameter_property FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property FIFO_DEPTH HDL_PARAMETER true

add_parameter PURPOSE INTEGER -1
set_parameter_property PURPOSE DISPLAY_NAME "Purpose ID"
set_parameter_property PURPOSE ALLOWED_RANGES {"-1:RAM" "0:Unknown" "1:Transacto" "2:Config ROM" "3:Packet Stream" "4:Nios II DPX Debugger" "5:Dual Nios II DPX Debugger"}
set_parameter_property PURPOSE AFFECTS_GENERATION false
set_parameter_property PURPOSE HDL_PARAMETER true

add_parameter dI2C_RAM_FILE STRING "altera_usb_debug_i2c_ram.hex"
set_parameter_property dI2C_RAM_FILE DISPLAY_NAME "I2C RAM Filename"
set_parameter_property dI2C_RAM_FILE AFFECTS_GENERATION false
set_parameter_property dI2C_RAM_FILE HDL_PARAMETER false

add_parameter I2C_RAM_FILE STRING
set_parameter_property I2C_RAM_FILE DERIVED true
set_parameter_property I2C_RAM_FILE VISIBLE false
set_parameter_property I2C_RAM_FILE AFFECTS_GENERATION false
set_parameter_property I2C_RAM_FILE HDL_PARAMETER true

add_parameter NUM_MGMT_CHANNELBITS INTEGER 0
set_parameter_property NUM_MGMT_CHANNELBITS DISPLAY_NAME "Number of Management Channels"
set_parameter_property NUM_MGMT_CHANNELBITS ALLOWED_RANGES 0:32
set_parameter_property NUM_MGMT_CHANNELBITS AFFECTS_GENERATION false
set_parameter_property NUM_MGMT_CHANNELBITS HDL_PARAMETER true

add_parameter NUM_MGMT_DATABITS INTEGER 1
set_parameter_property NUM_MGMT_DATABITS DISPLAY_NAME "Number of Management Data Bits"
set_parameter_property NUM_MGMT_DATABITS ALLOWED_RANGES 1:32
set_parameter_property NUM_MGMT_DATABITS AFFECTS_GENERATION false
set_parameter_property NUM_MGMT_DATABITS HDL_PARAMETER true
# |
# +-----------------------------------

# +-----------------------------------
# |
# | Validation callback
proc validate {} {
    set purpose [get_parameter_value PURPOSE]
    if {$purpose < 0} {
        set_parameter_property dI2C_RAM_FILE    ENABLED true
        set_parameter_value I2C_RAM_FILE [get_parameter_value dI2C_RAM_FILE]
    } else {
        set_parameter_property dI2C_RAM_FILE    ENABLED false
        set_parameter_value I2C_RAM_FILE "UNUSED"
    }

    set num_mgmt_channelbits [get_parameter_value NUM_MGMT_CHANNELBITS]
    set_parameter_property NUM_MGMT_CHANNELBITS ENABLED true
    if {$num_mgmt_channelbits} {
        set_parameter_property NUM_MGMT_DATABITS    ENABLED true
    } else {
        set_parameter_property NUM_MGMT_DATABITS    ENABLED false
    }
}
# |
# +-----------------------------------

# +-----------------------------------
# | connection point usb_if
# |
add_interface usb_if conduit end
set_interface_property usb_if ENABLED true
add_interface_port usb_if fpga_clk    clk     Input 1
add_interface_port usb_if fpga_arst_n reset_n Input 1
add_interface_port usb_if fpga_full   full    Output 1
add_interface_port usb_if fpga_empty  empty   Output 1
add_interface_port usb_if fpga_wr_n   wr_n    Input 1
add_interface_port usb_if fpga_rd_n   rd_n    Input 1
add_interface_port usb_if fpga_oe_n   oe_n    Input 1
add_interface_port usb_if fpga_data   data    Bidir 8
add_interface_port usb_if fpga_addr   addr    Bidir 2
add_interface_port usb_if fpga_scl    scl     Bidir 1
add_interface_port usb_if fpga_sda    sda     Bidir 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point av_clk
# |
add_interface av_clk clock end
set_interface_property av_clk ENABLED true
set_interface_property av_clk clockRate 0
add_interface_port av_clk av_clk clk Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point av_clk_out
# |
add_interface av_clk_out clock start
set_interface_property av_clk_out ENABLED true
set_interface_property av_clk_out clockRate 48000000
set_interface_property av_clk_out clockRateKnown true
add_interface_port av_clk_out av_clk_out clk Output 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point av_reset_out
# |
add_interface av_reset_out reset start
set_interface_property av_reset_out ENABLED true
set_interface_property av_reset_out associatedClock av_clk_out
set_interface_property av_reset_out associatedResetSinks none
add_interface_port av_reset_out av_arst_out reset Output 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point avst_src
# |
add_interface avst_src avalon_streaming start
set_interface_property avst_src ENABLED true
set_interface_property avst_src associatedClock av_clk_out
set_interface_property avst_src associatedReset av_reset_out
set_interface_property avst_src dataBitsPerSymbol 8
set_interface_property avst_src errorDescriptor ""
set_interface_property avst_src maxChannel 0
set_interface_property avst_src readyLatency 0
add_interface_port avst_src avst_src_ready ready Input 1
add_interface_port avst_src avst_src_valid valid Output 1
add_interface_port avst_src avst_src_data data Output 8
# |
# +-----------------------------------

# +-----------------------------------
# | connection point avst_sink
# |
add_interface avst_sink avalon_streaming end
set_interface_property avst_sink ENABLED true
set_interface_property avst_sink associatedClock av_clk_out
set_interface_property avst_sink associatedReset av_reset_out
set_interface_property avst_sink dataBitsPerSymbol 8
set_interface_property avst_sink errorDescriptor ""
set_interface_property avst_sink maxChannel 0
set_interface_property avst_sink readyLatency 0
add_interface_port avst_sink avst_sink_ready ready Output 1
add_interface_port avst_sink avst_sink_valid valid Input 1
add_interface_port avst_sink avst_sink_data data Input 8
# |
# +-----------------------------------

# +-----------------------------------
# | connection point mgmt_if
# |
add_interface mgmt_if avalon_streaming start
set_interface_property mgmt_if associatedClock av_clk_out
set_interface_property mgmt_if associatedReset av_reset_out
set_interface_property mgmt_if dataBitsPerSymbol 2
set_interface_property mgmt_if errorDescriptor ""
set_interface_property mgmt_if readyLatency 0
add_interface_port mgmt_if mgmt_valid valid Output 1
add_interface_port mgmt_if mgmt_channel channel Output 8
add_interface_port mgmt_if mgmt_data data Output 2
# |
# +-----------------------------------

# +-----------------------------------
# |
# | Elaboration callback
proc elaborate {} {
    set use_dcfifo           [get_parameter_value USE_DCFIFO]
    set av_clk_rate          [get_parameter_value AUTO_CLOCK_RATE]
    set num_mgmt_channelbits [get_parameter_value NUM_MGMT_CHANNELBITS]
    set num_mgmt_databits    [get_parameter_value NUM_MGMT_DATABITS]
    set mgmt_channel_width  [expr {($num_mgmt_channelbits) ? $num_mgmt_channelbits : 1}]
    set mgmt_data_width     [expr {($num_mgmt_databits)    ? $num_mgmt_databits    : 1}]

	if {$use_dcfifo} {
	 	set_interface_property av_clk_out associatedDirectClock av_clk
		set_interface_property av_clk_out clockRate $av_clk_rate
		set_interface_property av_clk_out clockRateKnown [expr {$av_clk_rate > 0}]
	} else {
		set_interface_property av_clk ENABLED false
		set_port_property av_clk termination true
	}

    set_interface_property mgmt_if dataBitsPerSymbol $mgmt_data_width
    set_interface_property mgmt_if maxChannel [expr {(1<<$mgmt_channel_width) - 1}]
    set_port_property mgmt_channel width $mgmt_channel_width
    set_port_property mgmt_data width $mgmt_data_width
    if {$num_mgmt_channelbits > 0} {
        set_interface_property mgmt_if ENABLED true
    } else {
        set_interface_property mgmt_if ENABLED false
        set_port_property mgmt_valid   TERMINATION TRUE
        set_port_property mgmt_channel TERMINATION TRUE
        set_port_property mgmt_data    TERMINATION TRUE
    }
}
# |
# +-----------------------------------
