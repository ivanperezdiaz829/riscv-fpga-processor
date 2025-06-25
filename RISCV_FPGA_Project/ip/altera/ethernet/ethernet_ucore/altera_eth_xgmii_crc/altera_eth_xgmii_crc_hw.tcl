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
# | module altera_eth_xgmii_crc
# | 
set_module_property DESCRIPTION "Altera Ethernet XGMII CRC"
set_module_property NAME altera_eth_xgmii_crc
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII CRC"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_xgmii_crc.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_xgmii_crc
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_xgmii_crc.v {SYNTHESIS}
add_file altera_eth_xgmii_crc.ocp {SYNTHESIS}
add_file altera_eth_xgmii_crc32.v {SYNTHESIS}
add_file altera_eth_xgmii_crc_gf_mult32_kc.v {SYNTHESIS}
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_xgmii_crc

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_crc.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_crc32.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_crc_gf_mult32_kc.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_crc.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_crc32.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_crc_gf_mult32_kc.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_crc.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_crc32.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_crc_gf_mult32_kc.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_crc.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_crc32.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_crc_gf_mult32_kc.v" {SYNOPSYS_SPECIFIC}
    }
}

# proc sim_vhd {name} {
   # if {1} {
        # add_fileset_file mentor/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_crc.v" {MENTOR_SPECIFIC}
        # add_fileset_file mentor/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_crc32.v" {MENTOR_SPECIFIC}
        # add_fileset_file mentor/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_crc_gf_mult32_kc.v" {MENTOR_SPECIFIC}
    # }
    # if {1} {
        # add_fileset_file aldec/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_crc.v" {ALDEC_SPECIFIC}
        # add_fileset_file aldec/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_crc32.v" {ALDEC_SPECIFIC}
        # add_fileset_file aldec/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_crc_gf_mult32_kc.v" {ALDEC_SPECIFIC}
    # }
    # if {0} {
        # add_fileset_file cadence/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_crc.v" {CADENCE_SPECIFIC}
        # add_fileset_file cadence/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_crc32.v" {CADENCE_SPECIFIC}
        # add_fileset_file cadence/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_crc_gf_mult32_kc.v" {CADENCE_SPECIFIC}
    # }
    # if {0} {
        # add_fileset_file synopsys/altera_eth_xgmii_crc.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_crc.v" {SYNOPSYS_SPECIFIC}
        # add_fileset_file synopsys/altera_eth_xgmii_crc32.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_crc32.v" {SYNOPSYS_SPECIFIC}
        # add_fileset_file synopsys/altera_eth_xgmii_crc_gf_mult32_kc.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_crc_gf_mult32_kc.v" {SYNOPSYS_SPECIFIC}
    # }
# }


# +-----------------------------------
# | parameters
# | 
# add_parameter BITSPERSYMBOL INTEGER 9 "Ethernet is a byte oriented."
# set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
# set_parameter_property BITSPERSYMBOL ENABLED false
# set_parameter_property BITSPERSYMBOL UNITS None
# set_parameter_property BITSPERSYMBOL ALLOWED_RANGES -2147483648:2147483647
# set_parameter_property BITSPERSYMBOL DESCRIPTION "Ethernet is a byte oriented."
# set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
# set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
# set_parameter_property BITSPERSYMBOL HDL_PARAMETER true

# add_parameter SYMBOLSPERBEAT INTEGER 8 "Ethernet 10G width is 72 bits."
# set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
# set_parameter_property SYMBOLSPERBEAT ENABLED false
# set_parameter_property SYMBOLSPERBEAT UNITS None
# set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES -2147483648:2147483647
# set_parameter_property SYMBOLSPERBEAT DESCRIPTION "Ethernet 10G width is 72 bits."
# set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
# set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
# set_parameter_property SYMBOLSPERBEAT HDL_PARAMETER true

add_parameter USE_FRAME_MODIFIED INTEGER 0
set_parameter_property USE_FRAME_MODIFIED DISPLAY_NAME "Use frame modified interface"
set_parameter_property USE_FRAME_MODIFIED DISPLAY_HINT boolean
set_parameter_property USE_FRAME_MODIFIED VISIBLE true
set_parameter_property USE_FRAME_MODIFIED DESCRIPTION "Enable frame_modified_sink interface"
set_parameter_property USE_FRAME_MODIFIED HDL_PARAMETER false
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
# | connection point crc_insert_sink
# | 
add_interface crc_insert_sink avalon_streaming end
set_interface_property crc_insert_sink dataBitsPerSymbol 1
set_interface_property crc_insert_sink errorDescriptor ""
set_interface_property crc_insert_sink maxChannel 0
set_interface_property crc_insert_sink readyLatency 0
set_interface_property crc_insert_sink symbolsPerBeat 1

set_interface_property crc_insert_sink ASSOCIATED_CLOCK clock_reset
set_interface_property crc_insert_sink ENABLED true

add_interface_port crc_insert_sink crc_insert_sink_data data Input 1
add_interface_port crc_insert_sink crc_insert_sink_valid valid Input 1
add_interface_port crc_insert_sink crc_insert_sink_ready ready Output 1

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point frame_modified_sink
# | 
add_interface frame_modified_sink avalon_streaming end
set_interface_property frame_modified_sink dataBitsPerSymbol 1
set_interface_property frame_modified_sink errorDescriptor ""
set_interface_property frame_modified_sink maxChannel 0
set_interface_property frame_modified_sink readyLatency 0
set_interface_property frame_modified_sink symbolsPerBeat 1

set_interface_property frame_modified_sink ASSOCIATED_CLOCK clock_reset
set_interface_property frame_modified_sink ENABLED true

add_interface_port frame_modified_sink frame_modified_valid valid Input 1
add_interface_port frame_modified_sink frame_modified_data data Input 1

# | 
# +-----------------------------------

proc elaborate {} {

  #set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  #set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set symbols_per_beat 8
  set bits_per_symbol 9

  set_interface_property xgmii_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property xgmii_sink symbolsPerBeat $symbols_per_beat
  set_interface_property xgmii_source dataBitsPerSymbol $bits_per_symbol
  set_interface_property xgmii_source symbolsPerBeat $symbols_per_beat

  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property xgmii_sink_data WIDTH $data_width
  set_port_property xgmii_src_data WIDTH $data_width
  
  if {[ get_parameter_value USE_FRAME_MODIFIED ] == 0} {
        set_interface_property frame_modified_sink ENABLED false
        
        set_port_property frame_modified_valid TERMINATION true
        set_port_property frame_modified_data TERMINATION true
        
        set_port_property frame_modified_valid TERMINATION_VALUE 0
        set_port_property frame_modified_data TERMINATION_VALUE 0
    }
}
