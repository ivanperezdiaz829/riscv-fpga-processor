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
# | module altera_eth_ptp_timestamp_inserter
# | 
set_module_property DESCRIPTION "Altera Ethernet XGMII PTP Inserter"
set_module_property NAME altera_eth_xgmii_ptp_inserter
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII PTP Inserter"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_xgmii_ptp_inserter.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_xgmii_ptp_inserter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false


# | Callbacks
# | 


proc elaborate {} {
  set symbols_per_beat 8
  set bits_per_symbol 9
  
  set_interface_property xgmii_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property xgmii_sink symbolsPerBeat $symbols_per_beat
  set_interface_property xgmii_source dataBitsPerSymbol $bits_per_symbol
  set_interface_property xgmii_source symbolsPerBeat $symbols_per_beat
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property xgmii_sink_data WIDTH $data_width
  set_port_property xgmii_src_data WIDTH $data_width
  
}
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_xgmii_ptp_inserter.v {SYNTHESIS}
add_file altera_eth_xgmii_ptp_inserter.ocp {SYNTHESIS}

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_xgmii_ptp_inserter

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_xgmii_ptp_inserter.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_ptp_inserter.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_xgmii_ptp_inserter.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_ptp_inserter.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_xgmii_ptp_inserter.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_ptp_inserter.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_xgmii_ptp_inserter.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_ptp_inserter.v" {SYNOPSYS_SPECIFIC}
    }
}


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
# | connection point packet_modified 
# | 
add_interface packet_modified avalon_streaming start
set_interface_property packet_modified dataBitsPerSymbol 1
set_interface_property packet_modified errorDescriptor ""
set_interface_property packet_modified maxChannel 0
set_interface_property packet_modified readyLatency 0
set_interface_property packet_modified symbolsPerBeat 1

set_interface_property packet_modified ASSOCIATED_CLOCK clock_reset
set_interface_property packet_modified ENABLED true

add_interface_port packet_modified packet_modified_data data Output 1
add_interface_port packet_modified packet_modified_valid valid Output 1
# | 
# +-----------------------------------



# +-----------------------------------
# | connection point xgmii_sink
# | 
add_interface xgmii_sink avalon_streaming end
set_interface_property xgmii_sink dataBitsPerSymbol 9
set_interface_property xgmii_sink errorDescriptor ""
set_interface_property xgmii_sink maxChannel 0
set_interface_property xgmii_sink readyLatency 0
set_interface_property xgmii_sink symbolsPerBeat 8

set_interface_property xgmii_sink ASSOCIATED_CLOCK clock_reset
set_interface_property xgmii_sink ENABLED true

add_interface_port xgmii_sink xgmii_sink_data data Input 72
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point xgmii_source
# | 
add_interface xgmii_source avalon_streaming start
set_interface_property xgmii_source dataBitsPerSymbol 9
set_interface_property xgmii_source errorDescriptor ""
set_interface_property xgmii_source maxChannel 0
set_interface_property xgmii_source readyLatency 0
set_interface_property xgmii_source symbolsPerBeat 8

set_interface_property xgmii_source ASSOCIATED_CLOCK clock_reset
set_interface_property xgmii_source ENABLED true

add_interface_port xgmii_source xgmii_src_data data Output 72
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point req_ctrl_valid
# | 
add_interface req_ctrl_valid conduit end
set_interface_property req_ctrl_valid ASSOCIATED_CLOCK clock_reset
set_interface_property req_ctrl_valid ENABLED true

add_interface_port req_ctrl_valid req_ctrl_signal_valid req_ctrl_valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_stamp_data
# | 
add_interface time_stamp_data conduit end
set_interface_property time_stamp_data ASSOCIATED_CLOCK clock_reset
set_interface_property time_stamp_data ENABLED true

add_interface_port time_stamp_data egress_timestamp_96_data egress_timestamp_96b  Input 96
add_interface_port time_stamp_data ingress_timestamp_96_data ingress_timestamp_96b  Input 96
add_interface_port time_stamp_data egress_timestamp_64_data egress_timestamp_64b Input 64
add_interface_port time_stamp_data ingress_timestamp_64_data ingress_timestamp_64b Input 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point ctrl_signal
# | 
add_interface ctrl_signal conduit end
set_interface_property ctrl_signal ASSOCIATED_CLOCK clock_reset
set_interface_property ctrl_signal ENABLED true

add_interface_port ctrl_signal timestamp_insert timestamp_insert Input 1
add_interface_port ctrl_signal corr_insert residence_time_update Input 1
add_interface_port ctrl_signal is_ipv4_udp_ptp checksum_zero Input 1
add_interface_port ctrl_signal is_ipv6_udp_ptp checksum_correct Input 1
add_interface_port ctrl_signal is_64_bit residence_time_calc_format Input 1
add_interface_port ctrl_signal is_ieee1588v1 timestamp_format Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point octet_location
# | 
add_interface octet_location conduit end
set_interface_property octet_location ASSOCIATED_CLOCK clock_reset
set_interface_property octet_location ENABLED true

add_interface_port octet_location timestamp_offset offset_timestamp Input 16
add_interface_port octet_location correction_offset offset_correction_field Input 16
add_interface_port octet_location udp_checksum_offset offset_checksum_field Input 16
add_interface_port octet_location extended_2bytes_offset offset_checksum_correction Input 16
# | 
# +-----------------------------------

