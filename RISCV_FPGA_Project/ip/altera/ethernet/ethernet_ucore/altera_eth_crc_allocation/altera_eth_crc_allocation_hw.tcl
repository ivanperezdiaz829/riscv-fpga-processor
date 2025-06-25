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


package require -exact sopc 9.1

# +-----------------------------------
# | module altera_eth_crc_allocation
# | 
set_module_property DESCRIPTION "Altera Ethernet CRC Allocation"
set_module_property NAME altera_eth_crc_allocation
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet CRC Allocation"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_crc_allocation.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_crc_allocation
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_crc_allocation

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc_allocation.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc_allocation.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc_allocation.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc_allocation.v" {SYNOPSYS_SPECIFIC}
    }
    add_fileset_file altera_avalon_st_clock_crosser.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v"
    add_fileset_file altera_avalon_st_pipeline_base.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v"
}

proc sim_vhd {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc_allocation.v" {MENTOR_SPECIFIC}
	add_fileset_file mentor/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc_allocation.v" {ALDEC_SPECIFIC}
	add_fileset_file aldec/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_base.v" {ALDEC__SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc_allocation.v" {CADENCE_SPECIFIC}
	add_fileset_file cadence/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_crc_allocation.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc_allocation.v" {SYNOPSYS_SPECIFIC}
	add_fileset_file synopsys/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_base.v" {SYNOPSYS_SPECIFIC}
    }
	add_fileset_file altera_avalon_st_clock_crosser.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v"
   
}


# Utility routines
proc _get_empty_width {} {
  set symbols_per_beat 8
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  return $empty_width
}


proc validate {} {

  # Calculate the required payload data width
  # set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  # set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set symbols_per_beat 8
  set bits_per_symbol 8
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  if { $data_width < 1 } {
    send_message error "Data Width less than 1 is not supported (SYMBOLS_PER_BEAT: $symbols_per_beat; BITS_PER_SYMBOL: $bits_per_symbol)"
  }
}

proc elaborate {} {

  # set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  # set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set symbols_per_beat 8
  set bits_per_symbol  8
  set use_channel [get_parameter_value USE_CHANNEL]
  set_interface_property data_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property data_sink symbolsPerBeat $symbols_per_beat
  set_interface_property data_src dataBitsPerSymbol $bits_per_symbol
  set_interface_property data_src symbolsPerBeat $symbols_per_beat
  set_interface_property data_sink maxChannel $use_channel
  set_interface_property data_src maxChannel $use_channel
  
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property data_sink_data WIDTH $data_width
  set_port_property data_src_data WIDTH $data_width

  set empty_width [ _get_empty_width ]
  set_port_property data_sink_empty WIDTH $empty_width
  set_port_property data_src_empty WIDTH $empty_width
  
  set error_width [ get_parameter_value ERROR_WIDTH ]
  set_port_property data_sink_error WIDTH $error_width
  set_port_property data_src_error WIDTH $error_width+1

  set enable_1g10g_mac [ get_parameter_value ENABLE_1G10G_MAC ]



  if {$use_channel} {
    } else {
	set_port_property data_src_channel TERMINATION_VALUE 1
    set_port_property data_sink_channel TERMINATION_VALUE 1
	set_port_property data_src_channel TERMINATION true
    set_port_property data_sink_channel TERMINATION true
  }
  
  set use_ready [ get_parameter_value USE_READY ]	
  if {$use_ready} {
    } else {
	set_port_property data_sink_ready TERMINATION_VALUE 1
    set_port_property data_src_ready TERMINATION_VALUE 1
	set_port_property data_sink_ready TERMINATION true
    set_port_property data_src_ready TERMINATION true
  }
  
  if {$enable_1g10g_mac == 0} {
    set_interface_property clk_1g ENABLED false
    set_interface_property reset_1g ENABLED false
    
    set_port_property clk_1g TERMINATION true
    set_port_property reset_1g TERMINATION true
    
    set_port_property clk_1g TERMINATION_VALUE 0
    set_port_property reset_1g TERMINATION_VALUE 1
}

  if {$enable_1g10g_mac == 0} {
    set_interface_property crc_insert_1g_src ENABLED false
    
    set_port_property crc_insert_1g_src_ready TERMINATION true
    set_port_property crc_insert_1g_src_data TERMINATION true
    set_port_property crc_insert_1g_src_valid TERMINATION true

    set_port_property crc_insert_1g_src_ready TERMINATION_VALUE 0
    
    set_interface_property speed_select ENABLED false
    set_port_property speed_select TERMINATION true
    set_port_property speed_select TERMINATION_VALUE 0
  }
}


# +-----------------------------------
# | files
# | 
add_file altera_eth_crc_allocation.v {SYNTHESIS}
add_file altera_eth_crc_allocation.ocp {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS}
# | 
# +-----------------------------------



# +-----------------------------------
# | parameters
# | 
add_parameter BITSPERSYMBOL INTEGER 8 
set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property BITSPERSYMBOL IS_HDL_PARAMETER true
set_parameter_property BITSPERSYMBOL ALLOWED_RANGES 1:256
set_parameter_property BITSPERSYMBOL ENABLED false

add_parameter SYMBOLSPERBEAT INTEGER 8 
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT IS_HDL_PARAMETER true
set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES 1:256
set_parameter_property SYMBOLSPERBEAT ENABLED false

add_parameter ERROR_WIDTH INTEGER 2
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER true
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32

add_parameter USE_CHANNEL INTEGER 0 
set_parameter_property USE_CHANNEL DISPLAY_NAME "Add channel interface "
set_parameter_property USE_CHANNEL DEFAULT_VALUE 0
set_parameter_property USE_CHANNEL DISPLAY_HINT boolean
set_parameter_property USE_CHANNEL DESCRIPTION "Add channel interface "
set_parameter_property USE_CHANNEL AFFECTS_GENERATION false
set_parameter_property USE_CHANNEL HDL_PARAMETER true

add_parameter USE_READY INTEGER 1 "If set, supports backpressure"
set_parameter_property USE_READY DISPLAY_NAME USE_READY
set_parameter_property USE_READY UNITS None
set_parameter_property USE_READY DISPLAY_HINT "boolean"
set_parameter_property USE_READY AFFECTS_GENERATION false
set_parameter_property USE_READY AFFECTS_ELABORATION true
set_parameter_property USE_READY IS_HDL_PARAMETER false

add_parameter ENABLE_1G10G_MAC INTEGER 0
set_parameter_property ENABLE_1G10G_MAC DISPLAY_NAME "1G/10G MAC"
set_parameter_property ENABLE_1G10G_MAC DISPLAY_HINT boolean
set_parameter_property ENABLE_1G10G_MAC DESCRIPTION "Enable 1G/10G MAC support"
set_parameter_property ENABLE_1G10G_MAC HDL_PARAMETER false
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clk_10g clock end
set_interface_property clk_10g ENABLED true
add_interface_port clk_10g clk_10g clk Input 1

add_interface clk_1g clock end
set_interface_property clk_1g ENABLED true
add_interface_port clk_1g clk_1g clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset_10g reset end
set_interface_property reset_10g associatedClock clk_10g
set_interface_property reset_10g synchronousEdges DEASSERT

set_interface_property reset_10g ENABLED true

add_interface_port reset_10g reset_10g reset Input 1

add_interface reset_1g reset end
set_interface_property reset_1g associatedClock clk_1g
set_interface_property reset_1g synchronousEdges DEASSERT

set_interface_property reset_1g ENABLED true

add_interface_port reset_1g reset_1g reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_reset
# |
add_interface csr_reset reset end
set_interface_property csr_reset associatedClock clk_10g
set_interface_property csr_reset synchronousEdges DEASSERT
set_interface_property csr_reset ENABLED true
add_interface_port csr_reset csr_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr
# | 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr bridgesToMaster ""
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr holdTime 0
set_interface_property csr isMemoryDevice false
set_interface_property csr isNonVolatileStorage false
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr printableDevice false
set_interface_property csr readLatency 1
set_interface_property csr readWaitTime 0
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr associatedClock clk_10g
set_interface_property csr associatedReset reset_10g
set_interface_property csr ENABLED true

add_interface_port csr csr_write write Input 1
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_address address Input 1
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_sink
# | 
add_interface data_sink avalon_streaming end
set_interface_property data_sink dataBitsPerSymbol 8
set_interface_property data_sink errorDescriptor ""
set_interface_property data_sink maxChannel 1
set_interface_property data_sink readyLatency 0
set_interface_property data_sink symbolsPerBeat 8

set_interface_property data_sink associatedClock clk_10g
set_interface_property data_sink associatedReset reset_10g
set_interface_property data_sink ENABLED true

add_interface_port data_sink data_sink_sop startofpacket Input 1
add_interface_port data_sink data_sink_eop endofpacket Input 1
add_interface_port data_sink data_sink_valid valid Input 1
add_interface_port data_sink data_sink_ready ready Output 1
add_interface_port data_sink data_sink_data data Input 64
add_interface_port data_sink data_sink_empty empty Input 3
add_interface_port data_sink data_sink_error error Input 1
add_interface_port data_sink data_sink_channel channel Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_src
# | 
add_interface data_src avalon_streaming start
set_interface_property data_src dataBitsPerSymbol 8
set_interface_property data_src errorDescriptor ""
set_interface_property data_src maxChannel 1
set_interface_property data_src readyLatency 0
set_interface_property data_src symbolsPerBeat 8

set_interface_property data_src associatedClock clk_10g
set_interface_property data_src associatedReset reset_10g
set_interface_property data_src ENABLED true

add_interface_port data_src data_src_sop startofpacket Output 1
add_interface_port data_src data_src_eop endofpacket Output 1
add_interface_port data_src data_src_valid valid Output 1
add_interface_port data_src data_src_ready ready Input 1
add_interface_port data_src data_src_data data Output 64
add_interface_port data_src data_src_empty empty Output 3
add_interface_port data_src data_src_error error Output 2
add_interface_port data_src data_src_channel channel Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point crc_insert_10g_src
# | 
add_interface crc_insert_10g_src avalon_streaming start
set_interface_property crc_insert_10g_src dataBitsPerSymbol 1
set_interface_property crc_insert_10g_src errorDescriptor ""
set_interface_property crc_insert_10g_src maxChannel 0
set_interface_property crc_insert_10g_src readyLatency 0
set_interface_property crc_insert_10g_src symbolsPerBeat 1

set_interface_property crc_insert_10g_src associatedClock clk_10g
set_interface_property crc_insert_10g_src associatedReset reset_10g
set_interface_property crc_insert_10g_src ENABLED true

add_interface_port crc_insert_10g_src crc_insert_10g_src_data data Output 1
add_interface_port crc_insert_10g_src crc_insert_10g_src_valid valid Output 1
add_interface_port crc_insert_10g_src crc_insert_10g_src_ready ready Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point crc_insert_1g_src
# | 
add_interface crc_insert_1g_src avalon_streaming start
set_interface_property crc_insert_1g_src dataBitsPerSymbol 1
set_interface_property crc_insert_1g_src errorDescriptor ""
set_interface_property crc_insert_1g_src maxChannel 0
set_interface_property crc_insert_1g_src readyLatency 0
set_interface_property crc_insert_1g_src symbolsPerBeat 1

set_interface_property crc_insert_1g_src associatedClock clk_1g
set_interface_property crc_insert_1g_src associatedReset reset_1g
set_interface_property crc_insert_1g_src ENABLED true

add_interface_port crc_insert_1g_src crc_insert_1g_src_data data Output 1
add_interface_port crc_insert_1g_src crc_insert_1g_src_valid valid Output 1
add_interface_port crc_insert_1g_src crc_insert_1g_src_ready ready Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point speed_select
# | 
add_interface speed_select conduit end
set_interface_property speed_select ENABLED true
add_interface_port speed_select speed_select export Input 2
# | 
# +-----------------------------------

