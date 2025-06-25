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
# | module altera_eth_valid_timestamp_detector
# | 
set_module_property DESCRIPTION "Altera Ethernet Valid Timestamp Detector"
set_module_property NAME altera_eth_valid_timestamp_detector
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Valid Timestamp Detector"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_valid_timestamp_detector.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_valid_timestamp_detector
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_valid_timestamp_detector

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "mentor/altera_eth_valid_timestamp_detector.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "aldec/altera_eth_valid_timestamp_detector.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "cadence/altera_eth_valid_timestamp_detector.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_valid_timestamp_detector.v" {SYNOPSYS_SPECIFIC}
    }
    add_fileset_file altera_avalon_st_clock_crosser.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v"
    add_fileset_file altera_avalon_st_pipeline_base.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v"
}

proc sim_vhd {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "mentor/altera_eth_valid_timestamp_detector.v" {MENTOR_SPECIFIC}
	add_fileset_file mentor/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "aldec/altera_eth_valid_timestamp_detector.v" {ALDEC_SPECIFIC}
	add_fileset_file aldec/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_base.v" {ALDEC__SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "cadence/altera_eth_valid_timestamp_detector.v" {CADENCE_SPECIFIC}
	add_fileset_file cadence/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_valid_timestamp_detector.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_valid_timestamp_detector.v" {SYNOPSYS_SPECIFIC}
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



proc elaborate {} {

  # set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  # set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set symbols_per_beat 8
  set bits_per_symbol  8
  set_interface_property data_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property data_sink symbolsPerBeat $symbols_per_beat
  set enable_1g10g_mac [ get_parameter_value ENABLE_1G10G_MAC ]


  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property data_sink_data WIDTH $data_width

  set empty_width [ _get_empty_width ]
  set_port_property data_sink_empty WIDTH $empty_width
  
  set error_width 1
  set_port_property data_sink_error WIDTH $error_width
  
  set_port_property data_sink_error VHDL_TYPE STD_LOGIC_VECTOR
  
    if {$enable_1g10g_mac == 0} {
        set_interface_property timestamp_96b_1g_in ENABLED false
        set_interface_property timestamp_64b_1g_in ENABLED false
        
        set_port_property timestamp_96b_1g_valid_in TERMINATION true
        set_port_property timestamp_96b_1g_data_in TERMINATION true
        
        set_port_property timestamp_64b_1g_valid_in TERMINATION true
        set_port_property timestamp_64b_1g_data_in TERMINATION true
        
        set_port_property timestamp_96b_1g_valid_in TERMINATION_VALUE 0
        set_port_property timestamp_96b_1g_data_in TERMINATION_VALUE 0
        
        set_port_property timestamp_64b_1g_valid_in TERMINATION_VALUE 0
        set_port_property timestamp_64b_1g_data_in TERMINATION_VALUE 0
    }
    
    if {$enable_1g10g_mac == 0} {
        set_interface_property clk_1g ENABLED false
        set_interface_property reset_1g ENABLED false
        
        set_port_property clk_1g TERMINATION true
        set_port_property reset_1g TERMINATION true
        
        set_port_property clk_1g TERMINATION_VALUE 0
        set_port_property reset_1g TERMINATION_VALUE 1
        
        set_interface_property speed_select ENABLED false
        set_port_property speed_select TERMINATION true
        set_port_property speed_select TERMINATION_VALUE 0
    }
}


# +-----------------------------------
# | files
# | 
add_file altera_eth_valid_timestamp_detector.v {SYNTHESIS}
add_file altera_eth_valid_timestamp_detector.ocp {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS}
# | 
# +-----------------------------------



# +-----------------------------------
# | parameters
# | 
# add_parameter BITSPERSYMBOL INTEGER 8 
# set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
# set_parameter_property BITSPERSYMBOL UNITS None
# set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
# set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
# set_parameter_property BITSPERSYMBOL IS_HDL_PARAMETER true
# set_parameter_property BITSPERSYMBOL ALLOWED_RANGES 1:256
# set_parameter_property BITSPERSYMBOL ENABLED false

# add_parameter SYMBOLSPERBEAT INTEGER 8 
# set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
# set_parameter_property SYMBOLSPERBEAT UNITS None
# set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
# set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
# set_parameter_property SYMBOLSPERBEAT IS_HDL_PARAMETER true
# set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES 1:256
# set_parameter_property SYMBOLSPERBEAT ENABLED false

# add_parameter ERROR_WIDTH INTEGER 1
# set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
# set_parameter_property ERROR_WIDTH UNITS None
# set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
# set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
# set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER true
# set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32

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
# | connection point data_sink
# | 
add_interface data_sink avalon_streaming end
set_interface_property data_sink dataBitsPerSymbol 8
set_interface_property data_sink errorDescriptor ""
set_interface_property data_sink maxChannel 0
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
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_96b_10g_in
# | 
add_interface timestamp_96b_10g_in avalon_streaming end
set_interface_property timestamp_96b_10g_in dataBitsPerSymbol 96
set_interface_property timestamp_96b_10g_in errorDescriptor ""
set_interface_property timestamp_96b_10g_in maxChannel 0
set_interface_property timestamp_96b_10g_in readyLatency 0
set_interface_property timestamp_96b_10g_in symbolsPerBeat 1

set_interface_property timestamp_96b_10g_in associatedClock clk_10g
set_interface_property timestamp_96b_10g_in associatedReset reset_10g
set_interface_property timestamp_96b_10g_in ENABLED true

add_interface_port timestamp_96b_10g_in timestamp_96b_10g_valid_in valid Input 1
add_interface_port timestamp_96b_10g_in timestamp_96b_10g_data_in data Input 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_64b_10g_in
# | 
add_interface timestamp_64b_10g_in avalon_streaming end
set_interface_property timestamp_64b_10g_in dataBitsPerSymbol 64
set_interface_property timestamp_64b_10g_in errorDescriptor ""
set_interface_property timestamp_64b_10g_in maxChannel 0
set_interface_property timestamp_64b_10g_in readyLatency 0
set_interface_property timestamp_64b_10g_in symbolsPerBeat 1

set_interface_property timestamp_64b_10g_in associatedClock clk_10g
set_interface_property timestamp_64b_10g_in associatedReset reset_10g
set_interface_property timestamp_64b_10g_in ENABLED true

add_interface_port timestamp_64b_10g_in timestamp_64b_10g_valid_in valid Input 1
add_interface_port timestamp_64b_10g_in timestamp_64b_10g_data_in data Input 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_96b_1g_in
# | 
add_interface timestamp_96b_1g_in avalon_streaming end
set_interface_property timestamp_96b_1g_in dataBitsPerSymbol 96
set_interface_property timestamp_96b_1g_in errorDescriptor ""
set_interface_property timestamp_96b_1g_in maxChannel 0
set_interface_property timestamp_96b_1g_in readyLatency 0
set_interface_property timestamp_96b_1g_in symbolsPerBeat 1

set_interface_property timestamp_96b_1g_in associatedClock clk_1g
set_interface_property timestamp_96b_1g_in associatedReset reset_1g
set_interface_property timestamp_96b_1g_in ENABLED true

add_interface_port timestamp_96b_1g_in timestamp_96b_1g_valid_in valid Input 1
add_interface_port timestamp_96b_1g_in timestamp_96b_1g_data_in data Input 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_64b_1g_in
# | 
add_interface timestamp_64b_1g_in avalon_streaming end
set_interface_property timestamp_64b_1g_in dataBitsPerSymbol 64
set_interface_property timestamp_64b_1g_in errorDescriptor ""
set_interface_property timestamp_64b_1g_in maxChannel 0
set_interface_property timestamp_64b_1g_in readyLatency 0
set_interface_property timestamp_64b_1g_in symbolsPerBeat 1

set_interface_property timestamp_64b_1g_in associatedClock clk_1g
set_interface_property timestamp_64b_1g_in associatedReset reset_1g
set_interface_property timestamp_64b_1g_in ENABLED true

add_interface_port timestamp_64b_1g_in timestamp_64b_1g_valid_in valid Input 1
add_interface_port timestamp_64b_1g_in timestamp_64b_1g_data_in data Input 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_96b_out
# | 
add_interface timestamp_96b_out avalon_streaming start
set_interface_property timestamp_96b_out dataBitsPerSymbol 96
set_interface_property timestamp_96b_out errorDescriptor ""
set_interface_property timestamp_96b_out maxChannel 0
set_interface_property timestamp_96b_out readyLatency 0
set_interface_property timestamp_96b_out symbolsPerBeat 1

set_interface_property timestamp_96b_out associatedClock clk_10g
set_interface_property timestamp_96b_out associatedReset reset_10g
set_interface_property timestamp_96b_out ENABLED true

add_interface_port timestamp_96b_out timestamp_96b_valid_out valid Output 1
add_interface_port timestamp_96b_out timestamp_96b_data_out data Output 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_64b_out
# | 
add_interface timestamp_64b_out avalon_streaming start
set_interface_property timestamp_64b_out dataBitsPerSymbol 64
set_interface_property timestamp_64b_out errorDescriptor ""
set_interface_property timestamp_64b_out maxChannel 0
set_interface_property timestamp_64b_out readyLatency 0
set_interface_property timestamp_64b_out symbolsPerBeat 1

set_interface_property timestamp_64b_out associatedClock clk_10g
set_interface_property timestamp_64b_out associatedReset reset_10g
set_interface_property timestamp_64b_out ENABLED true

add_interface_port timestamp_64b_out timestamp_64b_valid_out valid Output 1
add_interface_port timestamp_64b_out timestamp_64b_data_out data Output 64
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
