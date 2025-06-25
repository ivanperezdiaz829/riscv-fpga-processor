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


package require -exact sopc 11.0

# +-----------------------------------
# | module altera_eth_gmii_tsu
# | 
set_module_property DESCRIPTION "Altera Ethernet GMII TSU"
set_module_property NAME altera_eth_gmii_tsu
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet GMII TSU"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_gmii_tsu.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_gmii_tsu
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_gmii_tsu

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_tse_tsu.v VERILOG_ENCRYPT PATH "mentor/altera_tse_tsu.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_gmii_tsu.v VERILOG_ENCRYPT PATH "mentor/altera_eth_gmii_tsu.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_tse_tsu.v VERILOG_ENCRYPT PATH "aldec/altera_tse_tsu.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_gmii_tsu.v VERILOG_ENCRYPT PATH "aldec/altera_eth_gmii_tsu.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_tse_tsu.v VERILOG_ENCRYPT PATH "cadence/altera_tse_tsu.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_gmii_tsu.v VERILOG_ENCRYPT PATH "cadence/altera_eth_gmii_tsu.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_tse_tsu.v VERILOG_ENCRYPT PATH "synopsys/altera_tse_tsu.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_gmii_tsu.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_gmii_tsu.v" {SYNOPSYS_SPECIFIC}
    }
}


# | Callbacks
# |  
proc elaborate {} {
  # set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  # set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set symbols_per_beat 1
  set bits_per_symbol 8
  
  set_interface_property gmii_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property gmii_sink symbolsPerBeat $symbols_per_beat
  set_interface_property gmii_src dataBitsPerSymbol $bits_per_symbol
  set_interface_property gmii_src symbolsPerBeat $symbols_per_beat
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property gmii_sink_data WIDTH $data_width
  set_port_property gmii_sink_data WIDTH $data_width

    if {[ get_parameter_value ENABLE_GMII_SRC ] == 0} {
        set_interface_property gmii_src ENABLED false
        set_port_property gmii_src_ready TERMINATION true
        set_port_property gmii_src_ready TERMINATION_VALUE 1
    }
  
  set_port_property gmii_sink_error VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property gmii_sink_empty VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property gmii_src_error VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property gmii_src_empty VHDL_TYPE STD_LOGIC_VECTOR
}


# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_tse_tsu.v {SYNTHESIS}
add_file altera_eth_gmii_tsu.v {SYNTHESIS}
add_file altera_eth_gmii_tsu.ocp {SYNTHESIS}
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


add_parameter SYMBOLSPERBEAT INTEGER 1
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT IS_HDL_PARAMETER true
set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES 1:256

add_parameter INTERNAL_PATH_DELAY_CYCLE_1000 INTEGER 0
set_parameter_property INTERNAL_PATH_DELAY_CYCLE_1000 DISPLAY_NAME INTERNAL_PATH_DELAY_CYCLE_1000
set_parameter_property INTERNAL_PATH_DELAY_CYCLE_1000 UNITS None
set_parameter_property INTERNAL_PATH_DELAY_CYCLE_1000 DISPLAY_HINT ""
set_parameter_property INTERNAL_PATH_DELAY_CYCLE_1000 AFFECTS_GENERATION false
set_parameter_property INTERNAL_PATH_DELAY_CYCLE_1000 IS_HDL_PARAMETER true
set_parameter_property INTERNAL_PATH_DELAY_CYCLE_1000 ALLOWED_RANGES 0:31

add_parameter DELAY_SIGN INTEGER 0
set_parameter_property DELAY_SIGN DISPLAY_NAME DELAY_SIGN
set_parameter_property DELAY_SIGN UNITS None
set_parameter_property DELAY_SIGN DISPLAY_HINT "boolean"
set_parameter_property DELAY_SIGN AFFECTS_GENERATION false
set_parameter_property DELAY_SIGN IS_HDL_PARAMETER true
set_parameter_property DELAY_SIGN ALLOWED_RANGES 0:1

add_parameter ENABLE_GMII_SRC INTEGER 1 "If set, expose GMII Data Src interface"
set_parameter_property ENABLE_GMII_SRC DISPLAY_NAME ENABLE_GMII_SRC
set_parameter_property ENABLE_GMII_SRC UNITS None
set_parameter_property ENABLE_GMII_SRC DISPLAY_HINT "boolean"
set_parameter_property ENABLE_GMII_SRC AFFECTS_GENERATION false
set_parameter_property ENABLE_GMII_SRC AFFECTS_ELABORATION true
set_parameter_property ENABLE_GMII_SRC IS_HDL_PARAMETER false
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end

set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_enable
# | 
add_interface clock_enable avalon_streaming end

set_interface_property clock_enable associatedClock clock
set_interface_property clock_enable ENABLED false

add_interface_port clock_enable clk_ena data Input 1
set_port_property clk_ena TERMINATION true
set_port_property clk_ena TERMINATION_VALUE 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point gmii_sink
# | 
add_interface gmii_sink avalon_streaming end
set_interface_property gmii_sink dataBitsPerSymbol 8
set_interface_property gmii_sink errorDescriptor ""
set_interface_property gmii_sink maxChannel 0
set_interface_property gmii_sink readyLatency 0
set_interface_property gmii_sink symbolsPerBeat 1

set_interface_property gmii_sink associatedClock clock
set_interface_property gmii_sink associatedReset reset
set_interface_property gmii_sink ENABLED true

add_interface_port gmii_sink gmii_sink_sop startofpacket Input 1
add_interface_port gmii_sink gmii_sink_eop endofpacket Input 1
add_interface_port gmii_sink gmii_sink_valid valid Input 1
add_interface_port gmii_sink gmii_sink_ready ready Output 1
add_interface_port gmii_sink gmii_sink_data data Input 8
add_interface_port gmii_sink gmii_sink_empty empty Input 1
add_interface_port gmii_sink gmii_sink_error error Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point gmii_src
# | 
add_interface gmii_src avalon_streaming start
set_interface_property gmii_src dataBitsPerSymbol 8
set_interface_property gmii_src errorDescriptor ""
set_interface_property gmii_src maxChannel 0
set_interface_property gmii_src readyLatency 0
set_interface_property gmii_src symbolsPerBeat 1

set_interface_property gmii_src associatedClock clock
set_interface_property gmii_src associatedReset reset
set_interface_property gmii_src ENABLED true

add_interface_port gmii_src gmii_src_sop startofpacket Output 1
add_interface_port gmii_src gmii_src_eop endofpacket Output 1
add_interface_port gmii_src gmii_src_valid valid Output 1
add_interface_port gmii_src gmii_src_ready ready Input 1
add_interface_port gmii_src gmii_src_data data Output 8
add_interface_port gmii_src gmii_src_empty empty Output 1
add_interface_port gmii_src gmii_src_error error Output 1
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

add_interface_port path_delay path_delay_data data Input 12
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

set_interface_property timestamp_96b associatedClock clock
set_interface_property timestamp_96b associatedReset reset
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

set_interface_property timestamp_64b associatedClock clock
set_interface_property timestamp_64b associatedReset reset
set_interface_property timestamp_64b ENABLED true

add_interface_port timestamp_64b timestamp_64b_valid valid Output 1
add_interface_port timestamp_64b timestamp_64b_data data Output 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point period_ns_fns
# | 
add_interface period_ns_fns avalon_streaming end
set_interface_property period_ns_fns dataBitsPerSymbol 20
set_interface_property period_ns_fns errorDescriptor ""
set_interface_property period_ns_fns maxChannel 0
set_interface_property period_ns_fns readyLatency 0
set_interface_property period_ns_fns symbolsPerBeat 1

set_interface_property period_ns_fns associatedClock clock
set_interface_property period_ns_fns associatedReset reset
set_interface_property period_ns_fns ENABLED true

add_interface_port period_ns_fns csr_period data Input 20
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point adjust_ns_fns
# | 
add_interface adjust_ns_fns avalon_streaming end
set_interface_property adjust_ns_fns dataBitsPerSymbol 32
set_interface_property adjust_ns_fns errorDescriptor ""
set_interface_property adjust_ns_fns maxChannel 0
set_interface_property adjust_ns_fns readyLatency 0
set_interface_property adjust_ns_fns symbolsPerBeat 1

set_interface_property adjust_ns_fns associatedClock clock
set_interface_property adjust_ns_fns associatedReset reset
set_interface_property adjust_ns_fns ENABLED true

add_interface_port adjust_ns_fns csr_adjust data Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point speed
# | 
add_interface speed conduit end

set_interface_property speed associatedClock clock
set_interface_property speed associatedReset reset
set_interface_property speed ENABLED false

add_interface_port speed speed data Input 2
set_port_property speed TERMINATION true
set_port_property speed TERMINATION_VALUE 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point mii_alignment_status
# | 
add_interface mii_alignment_status conduit end

set_interface_property mii_alignment_status associatedClock clock
set_interface_property mii_alignment_status associatedReset reset
set_interface_property mii_alignment_status ENABLED false

add_interface_port mii_alignment_status mii_alignment_status data Input 1
set_port_property mii_alignment_status TERMINATION true
set_port_property mii_alignment_status TERMINATION_VALUE 0

# | 
# +-----------------------------------
