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
# | module altera_eth_frame_decoder
# | 
set_module_property DESCRIPTION "Altera Ethernet Frame Decoder"
set_module_property NAME altera_eth_frame_decoder
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Frame Decoder"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_frame_decoder.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_frame_decoder
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

# Utility routines
proc _get_empty_width {} {
  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  return $empty_width
}

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_frame_decoder

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "mentor/altera_eth_frame_decoder.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "aldec/altera_eth_frame_decoder.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "cadence/altera_eth_frame_decoder.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_frame_decoder.v" {SYNOPSYS_SPECIFIC}
    }
    add_fileset_file altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv"
    add_fileset_file altera_avalon_st_pipeline_base.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v"
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "mentor/altera_eth_frame_decoder.v" {MENTOR_SPECIFIC}
	add_fileset_file mentor/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
	add_fileset_file mentor/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_stage.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "aldec/altera_eth_frame_decoder.v" {ALDEC_SPECIFIC}
	add_fileset_file aldec/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_base.v" {ALDEC__SPECIFIC}
	add_fileset_file aldec/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_stage.sv" {ALDEC__SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "cadence/altera_eth_frame_decoder.v" {CADENCE_SPECIFIC}
	add_fileset_file cadence/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}
	add_fileset_file cadence/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_stage.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_frame_decoder.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_frame_decoder.v" {SYNOPSYS_SPECIFIC}
	add_fileset_file synopsys/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_base.v" {SYNOPSYS_SPECIFIC}   
	add_fileset_file synopsys/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_stage.sv" {SYNOPSYS_SPECIFIC}   
   }
}

# | Callbacks
# | 

proc validate {} {
  # Calculate the required payload data width for the altera_avalon_st_pipeline_base
  # instance.  (The spec requires <= 256.)
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
  set error_width [ get_parameter_value ERROR_WIDTH ]
  set src_error_width [expr $error_width + 3]
  set status_width 40
  set pauselen_width 16
  set pktinfo_width 23
  


  set_interface_property avalon_st_data_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_st_data_sink symbolsPerBeat $symbols_per_beat
  set_interface_property avalon_st_data_src dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_st_data_src symbolsPerBeat $symbols_per_beat
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property data_sink_data WIDTH $data_width
  set_port_property data_src_data WIDTH $data_width
  
  
  set_interface_property avalon_st_rxstatus_src dataBitsPerSymbol $status_width
  set_port_property rxstatus_src_data WIDTH $status_width

  set_interface_property avalon_st_pauselen_src dataBitsPerSymbol $pauselen_width
  set_port_property pauselen_src_data WIDTH $pauselen_width
  
  set_interface_property avalon_st_pktinfo_src dataBitsPerSymbol $pktinfo_width
  set_port_property pktinfo_src_data WIDTH $pktinfo_width

  set empty_width [ _get_empty_width ]
  set_port_property data_sink_empty WIDTH $empty_width
  set_port_property data_src_empty WIDTH $empty_width

  
  set error_width [ get_parameter_value ERROR_WIDTH ]
  if {$error_width > 0} {
    set_port_property data_sink_error WIDTH $error_width
    set_port_property data_src_error WIDTH $src_error_width
    set_port_property rxstatus_src_error WIDTH $src_error_width
  } else {
    set_port_property data_sink_error WIDTH 1
    set_port_property data_src_error WIDTH 4
    set_port_property rxstatus_src_error WIDTH 4
  }
  set_port_property data_sink_error VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property data_src_error VHDL_TYPE STD_LOGIC_VECTOR
  
  if {[ get_parameter_value ENABLE_DATA_SOURCE ] == 0} {
    set_interface_property avalon_st_data_src ENABLED false
    set_port_property data_src_sop TERMINATION true
	set_port_property data_src_eop TERMINATION true
	set_port_property data_src_valid TERMINATION true
	set_port_property data_src_data TERMINATION true
	set_port_property data_src_empty TERMINATION true
	set_port_property data_src_error TERMINATION true	
    set_port_property data_src_ready TERMINATION_VALUE 1
    set_port_property data_src_ready TERMINATION true
  }
 
  if {[ get_parameter_value ENABLE_PAUSELEN ] == 0} {
    set_interface_property avalon_st_pauselen_src ENABLED false
    set_port_property pauselen_src_valid TERMINATION true
    set_port_property pauselen_src_data TERMINATION true	
  }
  
  if {[ get_parameter_value ENABLE_PFC ] == 0} {
    set_parameter_property PFC_PRIORITY_NUM ENABLED false
    set_parameter_property ENABLE_PFC_PQ ENABLED false
    set_parameter_property ENABLE_PFC_STATUS ENABLED false
    
    set_interface_property avalon_st_pfc_pause_quanta_src ENABLED false
    set_interface_property avalon_st_pfc_status_src ENABLED false
    
    set_port_property pfc_pause_quanta_src_valid TERMINATION true
    set_port_property pfc_pause_quanta_src_data TERMINATION true
    
    set_port_property pfc_status_src_valid TERMINATION true
    set_port_property pfc_status_src_data TERMINATION true
    
  } else {
    set_parameter_property PFC_PRIORITY_NUM ENABLED true
    set_parameter_property ENABLE_PFC_PQ ENABLED true
    set_parameter_property ENABLE_PFC_STATUS ENABLED true
    
    set pfc_priority_num [ get_parameter_value PFC_PRIORITY_NUM ]
    
    if {[ get_parameter_value ENABLE_PFC_PQ ] == 1} {
        set_interface_property avalon_st_pfc_pause_quanta_src dataBitsPerSymbol [ expr 17 * $pfc_priority_num ]
        set_port_property pfc_pause_quanta_src_data WIDTH [ expr 17 * $pfc_priority_num ]
    } else {
        set_interface_property avalon_st_pfc_pause_quanta_src ENABLED false
        
        set_port_property pfc_pause_quanta_src_valid TERMINATION true
        set_port_property pfc_pause_quanta_src_data TERMINATION true
    }
    
    if {[ get_parameter_value ENABLE_PFC_STATUS ] == 1} {
        set_interface_property avalon_st_pfc_status_src dataBitsPerSymbol [ expr 2 * $pfc_priority_num ]
        set_port_property pfc_status_src_data WIDTH [ expr 2 * $pfc_priority_num ]
    } else {
        set_interface_property avalon_st_pfc_status_src ENABLED false
        
        set_port_property pfc_status_src_valid TERMINATION true
        set_port_property pfc_status_src_data TERMINATION true
    }
  }

  if {[ get_parameter_value USE_READY ] == 0} {
    set_port_property data_sink_ready TERMINATION true
    set_port_property data_src_ready TERMINATION_VALUE 1
    set_port_property data_src_ready TERMINATION true
  }

  if {[ get_parameter_value ENABLE_PKTINFO ] == 0} {
    set_interface_property avalon_st_pktinfo_src ENABLED false
    set_port_property pktinfo_src_valid TERMINATION true
    set_port_property pktinfo_src_data TERMINATION true
  }
  
}
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_frame_decoder.v {SYNTHESIS}
add_file altera_eth_frame_decoder.ocp {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv {SYNTHESIS}
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

add_parameter ERROR_WIDTH INTEGER 2
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER true
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32

add_parameter CONTINUOUS_VALID INTEGER 1
set_parameter_property CONTINUOUS_VALID DISPLAY_NAME CONTINUOUS_VALID
set_parameter_property CONTINUOUS_VALID UNITS None
set_parameter_property CONTINUOUS_VALID DISPLAY_HINT "boolean"
set_parameter_property CONTINUOUS_VALID AFFECTS_GENERATION false
set_parameter_property CONTINUOUS_VALID IS_HDL_PARAMETER true

add_parameter ENABLE_SUPP_ADDR INTEGER 1 "If set, include optional support for supplementary addresses"
set_parameter_property ENABLE_SUPP_ADDR DISPLAY_NAME ENABLE_SUPP_ADDR
set_parameter_property ENABLE_SUPP_ADDR UNITS None
set_parameter_property ENABLE_SUPP_ADDR DISPLAY_HINT "boolean"
set_parameter_property ENABLE_SUPP_ADDR AFFECTS_GENERATION false
set_parameter_property ENABLE_SUPP_ADDR IS_HDL_PARAMETER true

add_parameter ENABLE_PFC INTEGER 0 "If set, enable PFC frame detection"
set_parameter_property ENABLE_PFC DISPLAY_NAME ENABLE_PFC
set_parameter_property ENABLE_PFC UNITS None
set_parameter_property ENABLE_PFC DISPLAY_HINT "boolean"
set_parameter_property ENABLE_PFC AFFECTS_GENERATION false
set_parameter_property ENABLE_PFC AFFECTS_ELABORATION true
set_parameter_property ENABLE_PFC IS_HDL_PARAMETER true

add_parameter PFC_PRIORITY_NUM INTEGER 8 "Set the number of PFC priorities to use"
set_parameter_property PFC_PRIORITY_NUM DISPLAY_NAME PFC_PRIORITY_NUM
set_parameter_property PFC_PRIORITY_NUM TYPE INTEGER
set_parameter_property PFC_PRIORITY_NUM ENABLED true
set_parameter_property PFC_PRIORITY_NUM UNITS None
set_parameter_property PFC_PRIORITY_NUM DISPLAY_HINT ""
set_parameter_property PFC_PRIORITY_NUM AFFECTS_GENERATION false
set_parameter_property PFC_PRIORITY_NUM HDL_PARAMETER true

add_parameter ENABLE_PFC_PQ INTEGER 0 "If set, expose PFC Pause Quanta interface"
set_parameter_property ENABLE_PFC_PQ DISPLAY_NAME ENABLE_PFC_PQ
set_parameter_property ENABLE_PFC_PQ UNITS None
set_parameter_property ENABLE_PFC_PQ DISPLAY_HINT "boolean"
set_parameter_property ENABLE_PFC_PQ AFFECTS_GENERATION false
set_parameter_property ENABLE_PFC_PQ AFFECTS_ELABORATION true
set_parameter_property ENABLE_PFC_PQ IS_HDL_PARAMETER false

add_parameter ENABLE_PFC_STATUS INTEGER 0 "If set, expose PFC Status interface"
set_parameter_property ENABLE_PFC_STATUS DISPLAY_NAME ENABLE_PFC_STATUS
set_parameter_property ENABLE_PFC_STATUS UNITS None
set_parameter_property ENABLE_PFC_STATUS DISPLAY_HINT "boolean"
set_parameter_property ENABLE_PFC_STATUS AFFECTS_GENERATION false
set_parameter_property ENABLE_PFC_STATUS AFFECTS_ELABORATION true
set_parameter_property ENABLE_PFC_STATUS IS_HDL_PARAMETER false

add_parameter ENABLE_DATA_SOURCE INTEGER 1 "If set, expose Data Src interface"
set_parameter_property ENABLE_DATA_SOURCE DISPLAY_NAME ENABLE_DATA_SOURCE
set_parameter_property ENABLE_DATA_SOURCE UNITS None
set_parameter_property ENABLE_DATA_SOURCE DISPLAY_HINT "boolean"
set_parameter_property ENABLE_DATA_SOURCE AFFECTS_GENERATION false
set_parameter_property ENABLE_DATA_SOURCE AFFECTS_ELABORATION true
set_parameter_property ENABLE_DATA_SOURCE IS_HDL_PARAMETER false

add_parameter ENABLE_PAUSELEN INTEGER 1 "If set, expose Pauselen interface"
set_parameter_property ENABLE_PAUSELEN DISPLAY_NAME ENABLE_PAUSELEN
set_parameter_property ENABLE_PAUSELEN UNITS None
set_parameter_property ENABLE_PAUSELEN DISPLAY_HINT "boolean"
set_parameter_property ENABLE_PAUSELEN AFFECTS_GENERATION false
set_parameter_property ENABLE_PAUSELEN AFFECTS_ELABORATION true
set_parameter_property ENABLE_PAUSELEN IS_HDL_PARAMETER false

add_parameter ENABLE_PKTINFO INTEGER 1 "If set, expose Pktinfo interface"
set_parameter_property ENABLE_PKTINFO DISPLAY_NAME ENABLE_PKTINFO
set_parameter_property ENABLE_PKTINFO UNITS None
set_parameter_property ENABLE_PKTINFO DISPLAY_HINT "boolean"
set_parameter_property ENABLE_PKTINFO AFFECTS_GENERATION false
set_parameter_property ENABLE_PKTINFO AFFECTS_ELABORATION true
set_parameter_property ENABLE_PKTINFO IS_HDL_PARAMETER false

add_parameter USE_READY INTEGER 0 "If set, supports backpressure"
set_parameter_property USE_READY DISPLAY_NAME USE_READY
set_parameter_property USE_READY UNITS None
set_parameter_property USE_READY DISPLAY_HINT "boolean"
set_parameter_property USE_READY AFFECTS_GENERATION false
set_parameter_property USE_READY AFFECTS_ELABORATION true
set_parameter_property USE_READY IS_HDL_PARAMETER false
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

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
# | connection point avalom_mm_csr
# | 
add_interface avalom_mm_csr avalon end
set_interface_property avalom_mm_csr addressAlignment DYNAMIC
set_interface_property avalom_mm_csr bridgesToMaster ""
set_interface_property avalom_mm_csr burstOnBurstBoundariesOnly false
set_interface_property avalom_mm_csr holdTime 0
set_interface_property avalom_mm_csr isMemoryDevice false
set_interface_property avalom_mm_csr isNonVolatileStorage false
set_interface_property avalom_mm_csr linewrapBursts false
set_interface_property avalom_mm_csr maximumPendingReadTransactions 0
set_interface_property avalom_mm_csr printableDevice false
set_interface_property avalom_mm_csr readLatency 1
set_interface_property avalom_mm_csr readWaitTime 0
set_interface_property avalom_mm_csr setupTime 0
set_interface_property avalom_mm_csr timingUnits Cycles
set_interface_property avalom_mm_csr writeWaitTime 0

set_interface_property avalom_mm_csr ASSOCIATED_CLOCK clock_reset
set_interface_property avalom_mm_csr ENABLED true

add_interface_port avalom_mm_csr csr_readdata readdata Output 32
add_interface_port avalom_mm_csr csr_write write Input 1
add_interface_port avalom_mm_csr csr_read read Input 1
add_interface_port avalom_mm_csr csr_address address Input 5
add_interface_port avalom_mm_csr csr_writedata writedata Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_data_sink
# | 
add_interface avalon_st_data_sink avalon_streaming end
set_interface_property avalon_st_data_sink dataBitsPerSymbol 8
set_interface_property avalon_st_data_sink errorDescriptor ""
set_interface_property avalon_st_data_sink maxChannel 0
set_interface_property avalon_st_data_sink readyLatency 0
set_interface_property avalon_st_data_sink symbolsPerBeat 8

set_interface_property avalon_st_data_sink ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_data_sink ENABLED true

add_interface_port avalon_st_data_sink data_sink_sop startofpacket Input 1
add_interface_port avalon_st_data_sink data_sink_eop endofpacket Input 1
add_interface_port avalon_st_data_sink data_sink_valid valid Input 1
add_interface_port avalon_st_data_sink data_sink_ready ready Output 1
add_interface_port avalon_st_data_sink data_sink_data data Input 1
add_interface_port avalon_st_data_sink data_sink_empty empty Input 1
add_interface_port avalon_st_data_sink data_sink_error error Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_data_src
# | 
add_interface avalon_st_data_src avalon_streaming start
set_interface_property avalon_st_data_src dataBitsPerSymbol 8
set_interface_property avalon_st_data_src errorDescriptor ""
set_interface_property avalon_st_data_src maxChannel 0
set_interface_property avalon_st_data_src readyLatency 0
set_interface_property avalon_st_data_src symbolsPerBeat 8

set_interface_property avalon_st_data_src ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_data_src ENABLED true

add_interface_port avalon_st_data_src data_src_sop startofpacket Output 1
add_interface_port avalon_st_data_src data_src_eop endofpacket Output 1
add_interface_port avalon_st_data_src data_src_valid valid Output 1
add_interface_port avalon_st_data_src data_src_ready ready Input 1
add_interface_port avalon_st_data_src data_src_data data Output 1
add_interface_port avalon_st_data_src data_src_empty empty Output 1
add_interface_port avalon_st_data_src data_src_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_pauselen_src
# | 
add_interface avalon_st_pauselen_src avalon_streaming start
set_interface_property avalon_st_pauselen_src dataBitsPerSymbol 16
set_interface_property avalon_st_pauselen_src errorDescriptor ""
set_interface_property avalon_st_pauselen_src maxChannel 0
set_interface_property avalon_st_pauselen_src readyLatency 0
set_interface_property avalon_st_pauselen_src symbolsPerBeat 1

set_interface_property avalon_st_pauselen_src ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_pauselen_src ENABLED true

add_interface_port avalon_st_pauselen_src pauselen_src_valid valid Output 1
add_interface_port avalon_st_pauselen_src pauselen_src_data data Output 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_pfc_pause_quanta_src
# | 
add_interface avalon_st_pfc_pause_quanta_src avalon_streaming start
set_interface_property avalon_st_pfc_pause_quanta_src dataBitsPerSymbol 136
set_interface_property avalon_st_pfc_pause_quanta_src errorDescriptor ""
set_interface_property avalon_st_pfc_pause_quanta_src maxChannel 0
set_interface_property avalon_st_pfc_pause_quanta_src readyLatency 0
set_interface_property avalon_st_pfc_pause_quanta_src symbolsPerBeat 1

set_interface_property avalon_st_pfc_pause_quanta_src ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_pfc_pause_quanta_src ENABLED true

add_interface_port avalon_st_pfc_pause_quanta_src pfc_pause_quanta_src_valid valid Output 1
add_interface_port avalon_st_pfc_pause_quanta_src pfc_pause_quanta_src_data data Output 136
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_pfc_status_src
# | 
add_interface avalon_st_pfc_status_src avalon_streaming start
set_interface_property avalon_st_pfc_status_src dataBitsPerSymbol 16
set_interface_property avalon_st_pfc_status_src errorDescriptor ""
set_interface_property avalon_st_pfc_status_src maxChannel 0
set_interface_property avalon_st_pfc_status_src readyLatency 0
set_interface_property avalon_st_pfc_status_src symbolsPerBeat 1

set_interface_property avalon_st_pfc_status_src ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_pfc_status_src ENABLED true

add_interface_port avalon_st_pfc_status_src pfc_status_src_valid valid Output 1
add_interface_port avalon_st_pfc_status_src pfc_status_src_data data Output 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_rxstatus_src
# | 
add_interface avalon_st_rxstatus_src avalon_streaming start
set_interface_property avalon_st_rxstatus_src dataBitsPerSymbol 39
set_interface_property avalon_st_rxstatus_src errorDescriptor ""
set_interface_property avalon_st_rxstatus_src maxChannel 0
set_interface_property avalon_st_rxstatus_src readyLatency 0
set_interface_property avalon_st_rxstatus_src symbolsPerBeat 1

set_interface_property avalon_st_rxstatus_src ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_rxstatus_src ENABLED true

add_interface_port avalon_st_rxstatus_src rxstatus_src_valid valid Output 1
add_interface_port avalon_st_rxstatus_src rxstatus_src_data data Output 39
add_interface_port avalon_st_rxstatus_src rxstatus_src_error error Output 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_st_pktinfo_src
# | 
add_interface avalon_st_pktinfo_src avalon_streaming start
set_interface_property avalon_st_pktinfo_src dataBitsPerSymbol 23
set_interface_property avalon_st_pktinfo_src errorDescriptor ""
set_interface_property avalon_st_pktinfo_src maxChannel 0
set_interface_property avalon_st_pktinfo_src readyLatency 0
set_interface_property avalon_st_pktinfo_src symbolsPerBeat 1

set_interface_property avalon_st_pktinfo_src ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_st_pktinfo_src ENABLED true

add_interface_port avalon_st_pktinfo_src pktinfo_src_valid valid Output 1
add_interface_port avalon_st_pktinfo_src pktinfo_src_data data Output 23
# | 
# +-----------------------------------


