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
# | module altera_eth_xgmii_tsu
# | 
set_module_property DESCRIPTION "Altera Ethernet XGMII TSU"
set_module_property NAME altera_eth_xgmii_tsu
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII TSU"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_xgmii_tsu.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_xgmii_tsu
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false


# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_xgmii_tsu

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_xgmii_tsu.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_tsu.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_xgmii_tsu.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_tsu.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_xgmii_tsu.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_tsu.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_xgmii_tsu.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_tsu.v" {SYNOPSYS_SPECIFIC}
    }
}


# | Callbacks
# |  
proc elaborate {} {
  # set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  # set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set symbols_per_beat 8
  set bits_per_symbol 9
  
  set_interface_property data_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property data_sink symbolsPerBeat $symbols_per_beat
  set_interface_property data_src dataBitsPerSymbol $bits_per_symbol
  set_interface_property data_src symbolsPerBeat $symbols_per_beat
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property xgmii_sink_data WIDTH $data_width
  set_port_property xgmii_src_data WIDTH $data_width

    if {[ get_parameter_value ENABLE_DATA_SRC ] == 0} {
        set_interface_property data_src ENABLED false
        set_port_property xgmii_src_data TERMINATION true
        set_port_property xgmii_src_data TERMINATION true
    }
  }


# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_xgmii_tsu.v {SYNTHESIS}
add_file altera_eth_xgmii_tsu.ocp {SYNTHESIS}
# | 
# +-----------------------------------


# +-----------------------------------
# | parameters
# | 
add_parameter XGMII_BITSPERSYMBOL INTEGER 9
set_parameter_property XGMII_BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property XGMII_BITSPERSYMBOL UNITS None
set_parameter_property XGMII_BITSPERSYMBOL DISPLAY_HINT ""
set_parameter_property XGMII_BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property XGMII_BITSPERSYMBOL IS_HDL_PARAMETER true
set_parameter_property XGMII_BITSPERSYMBOL ALLOWED_RANGES 1:256


add_parameter XGMII_SYMBOLSPERBEAT INTEGER 8
set_parameter_property XGMII_SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property XGMII_SYMBOLSPERBEAT UNITS None
set_parameter_property XGMII_SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property XGMII_SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property XGMII_SYMBOLSPERBEAT IS_HDL_PARAMETER true
set_parameter_property XGMII_SYMBOLSPERBEAT ALLOWED_RANGES 1:256

add_parameter INTERNAL_PATH_DELAY_CYCLE INTEGER 0
set_parameter_property INTERNAL_PATH_DELAY_CYCLE DISPLAY_NAME INTERNAL_PATH_DELAY_CYCLE
set_parameter_property INTERNAL_PATH_DELAY_CYCLE UNITS None
set_parameter_property INTERNAL_PATH_DELAY_CYCLE DISPLAY_HINT ""
set_parameter_property INTERNAL_PATH_DELAY_CYCLE AFFECTS_GENERATION false
set_parameter_property INTERNAL_PATH_DELAY_CYCLE IS_HDL_PARAMETER true
set_parameter_property INTERNAL_PATH_DELAY_CYCLE ALLOWED_RANGES 0:15

add_parameter DELAY_SIGN INTEGER 0
set_parameter_property DELAY_SIGN DISPLAY_NAME DELAY_SIGN
set_parameter_property DELAY_SIGN UNITS None
set_parameter_property DELAY_SIGN DISPLAY_HINT "boolean"
set_parameter_property DELAY_SIGN AFFECTS_GENERATION false
set_parameter_property DELAY_SIGN IS_HDL_PARAMETER true
set_parameter_property DELAY_SIGN ALLOWED_RANGES 0:1

add_parameter ENABLE_DATA_SRC INTEGER 1 "If set, expose Data Src interface"
set_parameter_property ENABLE_DATA_SRC DISPLAY_NAME ENABLE_DATA_SRC
set_parameter_property ENABLE_DATA_SRC UNITS None
set_parameter_property ENABLE_DATA_SRC DISPLAY_HINT "boolean"
set_parameter_property ENABLE_DATA_SRC AFFECTS_GENERATION false
set_parameter_property ENABLE_DATA_SRC AFFECTS_ELABORATION true
set_parameter_property ENABLE_DATA_SRC IS_HDL_PARAMETER false
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
# | connection point period_sink
# | 
add_interface csr_period_sink avalon_streaming end
set_interface_property csr_period_sink dataBitsPerSymbol 20
set_interface_property csr_period_sink errorDescriptor ""
set_interface_property csr_period_sink maxChannel 0
set_interface_property csr_period_sink readyLatency 0
set_interface_property csr_period_sink symbolsPerBeat 1

set_interface_property csr_period_sink ASSOCIATED_CLOCK clock_reset
set_interface_property csr_period_sink ENABLED true

add_interface_port csr_period_sink csr_period data Input 20
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point adjust_sink
# | 
add_interface csr_adjust_sink avalon_streaming end
set_interface_property csr_adjust_sink dataBitsPerSymbol 32
set_interface_property csr_adjust_sink errorDescriptor ""
set_interface_property csr_adjust_sink maxChannel 0
set_interface_property csr_adjust_sink readyLatency 0
set_interface_property csr_adjust_sink symbolsPerBeat 1

set_interface_property csr_adjust_sink ASSOCIATED_CLOCK clock_reset
set_interface_property csr_adjust_sink ENABLED true

add_interface_port csr_adjust_sink csr_adjust data Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_sink
# | 
add_interface data_sink avalon_streaming end
set_interface_property data_sink dataBitsPerSymbol 9
set_interface_property data_sink errorDescriptor ""
set_interface_property data_sink maxChannel 0
set_interface_property data_sink readyLatency 0
set_interface_property data_sink symbolsPerBeat 8

set_interface_property data_sink ASSOCIATED_CLOCK clock_reset
set_interface_property data_sink ENABLED true

add_interface_port data_sink xgmii_sink_data data Input 72
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_src
# | 
add_interface data_src avalon_streaming start
set_interface_property data_src dataBitsPerSymbol 9
set_interface_property data_src errorDescriptor ""
set_interface_property data_src maxChannel 0
set_interface_property data_src readyLatency 0
set_interface_property data_src symbolsPerBeat 8

set_interface_property data_src ASSOCIATED_CLOCK clock_reset
set_interface_property data_src ENABLED true

add_interface_port data_src xgmii_src_data data Output 72
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point path_delay
# | 
add_interface path_delay conduit end
set_interface_assignment path_delay "ui.blockdiagram.direction" Input
# set_interface_property path_delay dataBitsPerSymbol 12
# set_interface_property path_delay errorDescriptor ""
# set_interface_property path_delay maxChannel 0
# set_interface_property path_delay readyLatency 0
# set_interface_property path_delay symbolsPerBeat 1

set_interface_property path_delay ENABLED true

add_interface_port path_delay path_delay_data data Input 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_of_day_96b
# | role: time_of_day_96b
add_interface time_of_day_96b conduit end
set_interface_assignment time_of_day_96b "ui.blockdiagram.direction" Input
# set_interface_property time_of_day_96b dataBitsPerSymbol 96
# set_interface_property time_of_day_96b errorDescriptor ""
# set_interface_property time_of_day_96b maxChannel 0
# set_interface_property time_of_day_96b readyLatency 0
# set_interface_property time_of_day_96b symbolsPerBeat 1

set_interface_property time_of_day_96b ENABLED true

add_interface_port time_of_day_96b time_of_day_96b_data data Input 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_of_day_64b
# | role: time_of_day_64b
add_interface time_of_day_64b conduit end
set_interface_assignment time_of_day_64b "ui.blockdiagram.direction" Input
# set_interface_property time_of_day_64b dataBitsPerSymbol 64
# set_interface_property time_of_day_64b errorDescriptor ""
# set_interface_property time_of_day_64b maxChannel 0
# set_interface_property time_of_day_64b readyLatency 0
# set_interface_property time_of_day_64b symbolsPerBeat 1

set_interface_property time_of_day_64b ENABLED true

add_interface_port time_of_day_64b time_of_day_64b_data data Input 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_96b
# | 
add_interface timestamp_96b avalon_streaming start
set_interface_property timestamp_96b dataBitsPerSymbol 96
set_interface_property timestamp_96b errorDescriptor ""
set_interface_property timestamp_96b maxChannel 0
set_interface_property timestamp_96b readyLatency 0
set_interface_property timestamp_96b symbolsPerBeat 1

set_interface_property timestamp_96b ASSOCIATED_CLOCK clock_reset
set_interface_property timestamp_96b ENABLED true

add_interface_port timestamp_96b timestamp_96b_valid valid Output 1
add_interface_port timestamp_96b timestamp_96b_data data Output 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_64b
# | 
add_interface timestamp_64b avalon_streaming start
set_interface_property timestamp_64b dataBitsPerSymbol 64
set_interface_property timestamp_64b errorDescriptor ""
set_interface_property timestamp_64b maxChannel 0
set_interface_property timestamp_64b readyLatency 0
set_interface_property timestamp_64b symbolsPerBeat 1

set_interface_property timestamp_64b ASSOCIATED_CLOCK clock_reset
set_interface_property timestamp_64b ENABLED true

add_interface_port timestamp_64b timestamp_64b_valid valid Output 1
add_interface_port timestamp_64b timestamp_64b_data data Output 64
# | 
# +-----------------------------------
