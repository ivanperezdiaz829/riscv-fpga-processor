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


## +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_pkt_backpressure_control
# | 
set_module_property NAME altera_eth_pkt_backpressure_control
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Packet Backpressure Controller"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_pkt_backpressure_control.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_pkt_backpressure_control
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_pkt_backpressure_control

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pkt_backpressure_control.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pkt_backpressure_control.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pkt_backpressure_control.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pkt_backpressure_control.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pkt_backpressure_control.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pkt_backpressure_control.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pkt_backpressure_control.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pkt_backpressure_control.v" {SYNOPSYS_SPECIFIC}
   }
}



proc validate {} {
  
  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]

  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  if { $data_width < 1 } {
    send_message error "Data Width less than 1 is not supported (SYMBOLS_PER_BEAT: $symbols_per_beat; BITS_PER_SYMBOL: $bits_per_symbol)"
  }
}

proc elaborate {} {

  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set use_ready [ get_parameter_value USE_READY ]
  set error_width [ get_parameter_value ERROR_WIDTH ]
  set use_pause [ get_parameter_value USE_PAUSE ]
  set pausebeats_width 32
  set csr_datapath_width 32
  set csr_address_width 1

  set_interface_property avalon_st_sink_data dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_st_sink_data symbolsPerBeat $symbols_per_beat
  set_interface_property avalon_st_source_data dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_st_source_data symbolsPerBeat $symbols_per_beat
 	
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property data_sink_data WIDTH $data_width
  set_port_property data_src_data WIDTH $data_width
  
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  set_port_property data_sink_empty WIDTH $empty_width
  set_port_property data_src_empty WIDTH $empty_width

  set_interface_property avalon_st_pause dataBitsPerSymbol $pausebeats_width
  set_port_property pausebeats_sink_data WIDTH $pausebeats_width

  set_port_property csr_address WIDTH $csr_address_width 
  set_port_property csr_address VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property csr_writedata WIDTH $csr_datapath_width
  set_port_property csr_readdata WIDTH $csr_datapath_width
 
  if {$use_ready == 0} {
    set_port_property data_sink_ready TERMINATION true
    set_port_property data_sink_ready TERMINATION_VALUE 1
    set_port_property data_src_ready TERMINATION true
    set_port_property data_src_ready TERMINATION_VALUE 1
  }
  
  if {$error_width > 0} {
    set_port_property data_sink_error WIDTH $error_width
    set_port_property data_src_error WIDTH $error_width
  } else {
    set_port_property data_sink_error WIDTH 1
    set_port_property data_src_error WIDTH 1
    set_port_property data_sink_error TERMINATION true
    set_port_property data_sink_error TERMINATION_VALUE 0
    set_port_property data_src_error TERMINATION true
  }
  set_port_property data_src_error VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property data_sink_error VHDL_TYPE STD_LOGIC_VECTOR
   
  if {$use_pause == 0} {
    set_port_property pausebeats_sink_valid TERMINATION true
    set_port_property pausebeats_sink_valid TERMINATION_VALUE 0
    set_port_property pausebeats_sink_data TERMINATION true
    set_port_property pausebeats_sink_data TERMINATION_VALUE 0
  }
   
}

# +-----------------------------------
# | files
# | 
add_file altera_eth_pkt_backpressure_control.v {SYNTHESIS}
add_file altera_eth_pkt_backpressure_control.ocp {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter BITSPERSYMBOL INTEGER 8
set_parameter_property BITSPERSYMBOL DEFAULT_VALUE 8
set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property BITSPERSYMBOL IS_HDL_PARAMETER true
set_parameter_property BITSPERSYMBOL ALLOWED_RANGES 1:256

add_parameter SYMBOLSPERBEAT INTEGER 8
set_parameter_property SYMBOLSPERBEAT DEFAULT_VALUE 8
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT IS_HDL_PARAMETER true
set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES 1:256

add_parameter ERROR_WIDTH INTEGER 1
set_parameter_property ERROR_WIDTH DEFAULT_VALUE 1
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER true
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32

add_parameter USE_READY INTEGER 1
set_parameter_property USE_READY DISPLAY_NAME USE_READY
set_parameter_property USE_READY UNITS None
set_parameter_property USE_READY DISPLAY_HINT "boolean"
set_parameter_property USE_READY AFFECTS_GENERATION false
set_parameter_property USE_READY IS_HDL_PARAMETER true 

# This parameter is used to terminate the pause interface. It will not passed to the packet backpressure module
add_parameter USE_PAUSE INTEGER 1
set_parameter_property USE_PAUSE DISPLAY_NAME USE_PAUSE
set_parameter_property USE_PAUSE UNITS None
set_parameter_property USE_PAUSE DISPLAY_HINT "boolean"
set_parameter_property USE_PAUSE AFFECTS_GENERATION false
set_parameter_property USE_PAUSE IS_HDL_PARAMETER false
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_reset
# |
add_interface csr_reset reset end
set_interface_property csr_reset associatedClock clock_reset
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
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr explicitAddressSpan 0
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

set_interface_property csr ASSOCIATED_CLOCK clock_reset
set_interface_property csr ENABLED true

add_interface_port csr csr_write write Input 1
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_address address Input 1
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_source_data
# | 
add_interface avalon_st_source_data avalon_streaming start
set_interface_property avalon_st_source_data dataBitsPerSymbol 8
set_interface_property avalon_st_source_data errorDescriptor ""
set_interface_property avalon_st_source_data maxChannel 0
set_interface_property avalon_st_source_data readyLatency 0
set_interface_property avalon_st_source_data symbolsPerBeat 8

set_interface_property avalon_st_source_data ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_source_data ENABLED true

add_interface_port avalon_st_source_data data_src_sop startofpacket Output 1
add_interface_port avalon_st_source_data data_src_eop endofpacket Output 1
add_interface_port avalon_st_source_data data_src_valid valid Output 1
add_interface_port avalon_st_source_data data_src_ready ready Input 1
add_interface_port avalon_st_source_data data_src_data data Output 1
add_interface_port avalon_st_source_data data_src_empty empty Output 1
add_interface_port avalon_st_source_data data_src_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_sink_data
# | 
add_interface avalon_st_sink_data avalon_streaming end
set_interface_property avalon_st_sink_data dataBitsPerSymbol 8
set_interface_property avalon_st_sink_data errorDescriptor ""
set_interface_property avalon_st_sink_data maxChannel 0
set_interface_property avalon_st_sink_data readyLatency 0
set_interface_property avalon_st_sink_data symbolsPerBeat 8

set_interface_property avalon_st_sink_data ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_sink_data ENABLED true

add_interface_port avalon_st_sink_data data_sink_sop startofpacket Input 1
add_interface_port avalon_st_sink_data data_sink_eop endofpacket Input 1
add_interface_port avalon_st_sink_data data_sink_valid valid Input 1
add_interface_port avalon_st_sink_data data_sink_ready ready Output 1
add_interface_port avalon_st_sink_data data_sink_data data Input 1
add_interface_port avalon_st_sink_data data_sink_empty empty Input 1
add_interface_port avalon_st_sink_data data_sink_error error Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_pause
# | 
add_interface avalon_st_pause avalon_streaming end
set_interface_property avalon_st_pause dataBitsPerSymbol 32
set_interface_property avalon_st_pause errorDescriptor ""
set_interface_property avalon_st_pause maxChannel 0
set_interface_property avalon_st_pause readyLatency 0
set_interface_property avalon_st_pause symbolsPerBeat 1

set_interface_property avalon_st_pause ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_pause ENABLED true

add_interface_port avalon_st_pause pausebeats_sink_valid valid Input 1
add_interface_port avalon_st_pause pausebeats_sink_data data Input 32
# | 
# +-----------------------------------
