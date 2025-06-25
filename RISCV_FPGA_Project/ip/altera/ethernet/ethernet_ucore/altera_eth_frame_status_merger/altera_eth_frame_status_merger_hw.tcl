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
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_frame_status_merger
# | 
set_module_property DESCRIPTION "Altera Ethernet Frame Status Merger"
set_module_property NAME altera_eth_frame_status_merger
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Frame Status Merger"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_frame_status_merger.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_frame_status_merger
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaborate
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_frame_status_merger

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "mentor/altera_eth_frame_status_merger.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "aldec/altera_eth_frame_status_merger.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "cadence/altera_eth_frame_status_merger.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_frame_status_merger.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "mentor/altera_eth_frame_status_merger.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "aldec/altera_eth_frame_status_merger.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "cadence/altera_eth_frame_status_merger.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_frame_status_merger.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_frame_status_merger.v" {SYNOPSYS_SPECIFIC}
   }
}




# +-----------------------------------
# | files
# | 
add_file altera_eth_frame_status_merger.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter ENABLE_PFC INTEGER 0
set_parameter_property ENABLE_PFC DISPLAY_NAME ENABLE_PFC
set_parameter_property ENABLE_PFC UNITS None
set_parameter_property ENABLE_PFC DISPLAY_HINT "boolean"
set_parameter_property ENABLE_PFC AFFECTS_GENERATION false
set_parameter_property ENABLE_PFC AFFECTS_ELABORATION true
set_parameter_property ENABLE_PFC IS_HDL_PARAMETER false

add_parameter PFC_PRIORITY_NUM INTEGER 8
set_parameter_property PFC_PRIORITY_NUM DEFAULT_VALUE 8
set_parameter_property PFC_PRIORITY_NUM DISPLAY_NAME PFC_PRIORITY_NUM
set_parameter_property PFC_PRIORITY_NUM TYPE INTEGER
set_parameter_property PFC_PRIORITY_NUM ENABLED true
set_parameter_property PFC_PRIORITY_NUM UNITS None
set_parameter_property PFC_PRIORITY_NUM DISPLAY_HINT ""
set_parameter_property PFC_PRIORITY_NUM AFFECTS_GENERATION false
set_parameter_property PFC_PRIORITY_NUM HDL_PARAMETER false

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
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
# | connection point frame_decoder_data_sink
# | 
add_interface frame_decoder_data_sink avalon_streaming end
set_interface_property frame_decoder_data_sink associatedClock clock_reset
set_interface_property frame_decoder_data_sink dataBitsPerSymbol 8
set_interface_property frame_decoder_data_sink symbolsPerBeat 8
set_interface_property frame_decoder_data_sink errorDescriptor ""
set_interface_property frame_decoder_data_sink maxChannel 0
set_interface_property frame_decoder_data_sink readyLatency 0

set_interface_property frame_decoder_data_sink ENABLED true

add_interface_port frame_decoder_data_sink frame_decoder_data_sink_sop startofpacket Input 1
add_interface_port frame_decoder_data_sink frame_decoder_data_sink_eop endofpacket Input 1
add_interface_port frame_decoder_data_sink frame_decoder_data_sink_valid valid Input 1
add_interface_port frame_decoder_data_sink frame_decoder_data_sink_data data Input 64
#add_interface_port frame_decoder_data_sink frame_decoder_data_sink_ready ready Output 1
add_interface_port frame_decoder_data_sink frame_decoder_data_sink_empty empty Input 3
add_interface_port frame_decoder_data_sink frame_decoder_data_sink_error error Input 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point crc_checker_data_sink
# | 
add_interface crc_checker_data_sink avalon_streaming end
set_interface_property crc_checker_data_sink associatedClock clock_reset
set_interface_property crc_checker_data_sink dataBitsPerSymbol 8
set_interface_property crc_checker_data_sink symbolsPerBeat 8
set_interface_property crc_checker_data_sink errorDescriptor ""
set_interface_property crc_checker_data_sink maxChannel 0
set_interface_property crc_checker_data_sink readyLatency 0

set_interface_property crc_checker_data_sink ENABLED true

add_interface_port crc_checker_data_sink crc_checker_data_sink_sop startofpacket Input 1
add_interface_port crc_checker_data_sink crc_checker_data_sink_eop endofpacket Input 1
add_interface_port crc_checker_data_sink crc_checker_data_sink_valid valid Input 1
add_interface_port crc_checker_data_sink crc_checker_data_sink_data data Input 64
#add_interface_port crc_checker_data_sink crc_checker_data_sink_ready ready Output 1
add_interface_port crc_checker_data_sink crc_checker_data_sink_empty empty Input 3
add_interface_port crc_checker_data_sink crc_checker_data_sink_error error Input 2
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_src
# | 
add_interface data_src avalon_streaming start
set_interface_property data_src associatedClock clock_reset
set_interface_property data_src dataBitsPerSymbol 8
set_interface_property data_src symbolsPerBeat 8
set_interface_property data_src errorDescriptor ""
set_interface_property data_src maxChannel 0
set_interface_property data_src readyLatency 0

set_interface_property data_src ENABLED true

add_interface_port data_src data_src_sop startofpacket Output 1
add_interface_port data_src data_src_eop endofpacket Output 1
add_interface_port data_src data_src_valid valid Output 1
add_interface_port data_src data_src_data data Output 64
#add_interface_port data_src data_src_ready ready Input 1
add_interface_port data_src data_src_empty empty Output 3
add_interface_port data_src data_src_error error Output 5
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pauselen_sink
# | 
add_interface pauselen_sink avalon_streaming end
set_interface_property pauselen_sink associatedClock clock_reset
set_interface_property pauselen_sink dataBitsPerSymbol 16
set_interface_property pauselen_sink errorDescriptor ""
set_interface_property pauselen_sink maxChannel 0
set_interface_property pauselen_sink readyLatency 0

set_interface_property pauselen_sink ENABLED true

add_interface_port pauselen_sink pauselen_sink_valid valid Input 1
add_interface_port pauselen_sink pauselen_sink_data data Input 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pauselen_src
# | 
add_interface pauselen_src avalon_streaming start
set_interface_property pauselen_src associatedClock clock_reset
set_interface_property pauselen_src dataBitsPerSymbol 16
set_interface_property pauselen_src errorDescriptor ""
set_interface_property pauselen_src maxChannel 0
set_interface_property pauselen_src readyLatency 0

set_interface_property pauselen_src ENABLED true

add_interface_port pauselen_src pauselen_src_valid valid Output 1
add_interface_port pauselen_src pauselen_src_data data Output 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_pause_quanta_sink
# | 
add_interface pfc_pause_quanta_sink avalon_streaming end
set_interface_property pfc_pause_quanta_sink associatedClock clock_reset
set_interface_property pfc_pause_quanta_sink dataBitsPerSymbol 136
set_interface_property pfc_pause_quanta_sink errorDescriptor ""
set_interface_property pfc_pause_quanta_sink maxChannel 0
set_interface_property pfc_pause_quanta_sink readyLatency 0

set_interface_property pfc_pause_quanta_sink ENABLED true

add_interface_port pfc_pause_quanta_sink pfc_pause_quanta_sink_valid valid Input 1
add_interface_port pfc_pause_quanta_sink pfc_pause_quanta_sink_data data Input 136
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_pause_quanta_src
# | 
add_interface pfc_pause_quanta_src avalon_streaming start
set_interface_property pfc_pause_quanta_src associatedClock clock_reset
set_interface_property pfc_pause_quanta_src dataBitsPerSymbol 136
set_interface_property pfc_pause_quanta_src errorDescriptor ""
set_interface_property pfc_pause_quanta_src maxChannel 0
set_interface_property pfc_pause_quanta_src readyLatency 0

set_interface_property pfc_pause_quanta_src ENABLED true

add_interface_port pfc_pause_quanta_src pfc_pause_quanta_src_valid valid Output 1
add_interface_port pfc_pause_quanta_src pfc_pause_quanta_src_data data Output 136
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rxstatus_sink
# | 
add_interface rxstatus_sink avalon_streaming end
set_interface_property rxstatus_sink associatedClock clock_reset
set_interface_property rxstatus_sink dataBitsPerSymbol 40
set_interface_property rxstatus_sink errorDescriptor ""
set_interface_property rxstatus_sink maxChannel 0
set_interface_property rxstatus_sink readyLatency 0

set_interface_property rxstatus_sink ENABLED true

add_interface_port rxstatus_sink rxstatus_sink_valid valid Input 1
add_interface_port rxstatus_sink rxstatus_sink_data data Input 40
add_interface_port rxstatus_sink rxstatus_sink_error error Input 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rxstatus_src
# | 
add_interface rxstatus_src avalon_streaming start
set_interface_property rxstatus_src associatedClock clock_reset
set_interface_property rxstatus_src dataBitsPerSymbol 40
set_interface_property rxstatus_src errorDescriptor ""
set_interface_property rxstatus_src maxChannel 0
set_interface_property rxstatus_src readyLatency 0

set_interface_property rxstatus_src ENABLED true

add_interface_port rxstatus_src rxstatus_src_valid valid Output 1
add_interface_port rxstatus_src rxstatus_src_data data Output 40
add_interface_port rxstatus_src rxstatus_src_error error Output 5
# | 
# +-----------------------------------

proc elaborate {} {
    set enable_pfc [ get_parameter_value ENABLE_PFC ]
    set pfc_priority_num [ get_parameter_value PFC_PRIORITY_NUM ]
    
    if {$enable_pfc == 1} {
        set_interface_property pfc_pause_quanta_sink ENABLED true
        set_interface_property pfc_pause_quanta_src ENABLED true
        
        set_interface_property pfc_pause_quanta_sink dataBitsPerSymbol [ expr 17 * $pfc_priority_num ]
        set_interface_property pfc_pause_quanta_src dataBitsPerSymbol [ expr 17 * $pfc_priority_num ]
        
        set_port_property pfc_pause_quanta_sink_data WIDTH [ expr 17 * $pfc_priority_num ]
        set_port_property pfc_pause_quanta_src_data WIDTH [ expr 17 * $pfc_priority_num ]
        
    } else {
        set_interface_property pfc_pause_quanta_sink ENABLED false
        set_interface_property pfc_pause_quanta_src ENABLED false
    }
}
