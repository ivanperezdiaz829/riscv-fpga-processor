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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_axi_master_ni/altera_merlin_axi_master_ni_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | request TCL package 
# | 
package require -exact qsys 12.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_merlin_axi_master_ni
# | 
set_module_property DESCRIPTION "Convert AXI transaction to Qsys packet"
set_module_property NAME altera_merlin_axi_master_ni
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Qsys Interconnect/AXI Interface"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "AXI Master Network Interface"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
# | 
# +-----------------------------------
# Read AXI3/AXI4 interfaces type
source axi_interface.tcl
# +-----------------------------------
# | files
# | 
add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_merlin_axi_master_ni 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_merlin_axi_master_ni
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_axi_master_ni

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_merlin_axi_master_ni.sv SYSTEM_VERILOG PATH "altera_merlin_axi_master_ni.sv"
	add_fileset_file altera_merlin_address_alignment.sv SYSTEM_VERILOG PATH "../altera_merlin_axi_master_ni/altera_merlin_address_alignment.sv"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_axi_master_ni.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_axi_master_ni.sv" {MENTOR_SPECIFIC}
	  add_fileset_file mentor/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_address_alignment.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_axi_master_ni.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_axi_master_ni.sv" {ALDEC_SPECIFIC}
	  add_fileset_file aldec/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_address_alignment.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_axi_master_ni.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_axi_master_ni.sv" {CADENCE_SPECIFIC}
	  add_fileset_file cadence/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_address_alignment.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_axi_master_ni.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_axi_master_ni.sv" {SYNOPSYS_SPECIFIC}
	  add_fileset_file synopsys/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_address_alignment.sv" {SYNOPSYS_SPECIFIC}
   }    
}

# | 
# +-----------------------------------

# +-----------------------------------
# | documentation links
# | 
add_documentation_link Documents http:/www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter ID_WIDTH INTEGER 2
set_parameter_property ID_WIDTH DEFAULT_VALUE 2
set_parameter_property ID_WIDTH DISPLAY_NAME "AXI master ID width"
set_parameter_property ID_WIDTH TYPE INTEGER
set_parameter_property ID_WIDTH UNITS None
set_parameter_property ID_WIDTH DESCRIPTION "AXI ID width"
set_parameter_property ID_WIDTH AFFECTS_ELABORATION true
set_parameter_property ID_WIDTH HDL_PARAMETER true
add_parameter ADDR_WIDTH INTEGER 32
set_parameter_property ADDR_WIDTH DEFAULT_VALUE 32
set_parameter_property ADDR_WIDTH DISPLAY_NAME "AXI master address width"
set_parameter_property ADDR_WIDTH TYPE INTEGER
set_parameter_property ADDR_WIDTH UNITS None
set_parameter_property ADDR_WIDTH DESCRIPTION "AXI address width"
set_parameter_property ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ADDR_WIDTH HDL_PARAMETER true
add_parameter RDATA_WIDTH INTEGER 32
set_parameter_property RDATA_WIDTH DEFAULT_VALUE 32
set_parameter_property RDATA_WIDTH DISPLAY_NAME "AXI master read data width"
set_parameter_property RDATA_WIDTH TYPE INTEGER
set_parameter_property RDATA_WIDTH UNITS None
set_parameter_property RDATA_WIDTH DESCRIPTION "AXI read data width"
set_parameter_property RDATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property RDATA_WIDTH HDL_PARAMETER true
add_parameter WDATA_WIDTH INTEGER 32
set_parameter_property WDATA_WIDTH DEFAULT_VALUE 32
set_parameter_property WDATA_WIDTH DISPLAY_NAME "AXI master write data width"
set_parameter_property WDATA_WIDTH TYPE INTEGER
set_parameter_property WDATA_WIDTH UNITS None
set_parameter_property WDATA_WIDTH DESCRIPTION "AXI write data width"
set_parameter_property WDATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property WDATA_WIDTH HDL_PARAMETER true
add_parameter ADDR_USER_WIDTH INTEGER 5
set_parameter_property ADDR_USER_WIDTH DEFAULT_VALUE 5
set_parameter_property ADDR_USER_WIDTH DISPLAY_NAME "AXI master user address width"
set_parameter_property ADDR_USER_WIDTH TYPE INTEGER
set_parameter_property ADDR_USER_WIDTH UNITS None
set_parameter_property ADDR_USER_WIDTH DESCRIPTION "AXI user address width"
set_parameter_property ADDR_USER_WIDTH AFFECTS_ELABORATION true
set_parameter_property ADDR_USER_WIDTH HDL_PARAMETER true
set_parameter_property ADDR_USER_WIDTH ALLOWED_RANGES 1:64
add_parameter DATA_USER_WIDTH INTEGER 8
set_parameter_property DATA_USER_WIDTH DEFAULT_VALUE 8
set_parameter_property DATA_USER_WIDTH DISPLAY_NAME "AXI master user data width"
set_parameter_property DATA_USER_WIDTH TYPE INTEGER
set_parameter_property DATA_USER_WIDTH UNITS None
set_parameter_property DATA_USER_WIDTH DESCRIPTION "AXI user data width"
set_parameter_property DATA_USER_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_USER_WIDTH HDL_PARAMETER true
set_parameter_property DATA_USER_WIDTH ALLOWED_RANGES 1:64

add_parameter AXI_BURST_LENGTH_WIDTH INTEGER 4
set_parameter_property AXI_BURST_LENGTH_WIDTH DISPLAY_NAME "AXI master burst length width"
set_parameter_property AXI_BURST_LENGTH_WIDTH TYPE INTEGER
set_parameter_property AXI_BURST_LENGTH_WIDTH DERIVED true
set_parameter_property AXI_BURST_LENGTH_WIDTH UNITS None
set_parameter_property AXI_BURST_LENGTH_WIDTH ENABLED true
set_parameter_property AXI_BURST_LENGTH_WIDTH DESCRIPTION "AXI burst length width"
set_parameter_property AXI_BURST_LENGTH_WIDTH AFFECTS_ELABORATION true
set_parameter_property AXI_BURST_LENGTH_WIDTH HDL_PARAMETER true
set_parameter_property AXI_BURST_LENGTH_WIDTH ALLOWED_RANGES 4:8

add_parameter AXI_LOCK_WIDTH INTEGER 2
set_parameter_property AXI_LOCK_WIDTH DISPLAY_NAME "AXI master lock width"
set_parameter_property AXI_LOCK_WIDTH TYPE INTEGER
set_parameter_property AXI_LOCK_WIDTH DERIVED true
set_parameter_property AXI_LOCK_WIDTH UNITS None
set_parameter_property AXI_LOCK_WIDTH ENABLED true
set_parameter_property AXI_LOCK_WIDTH DESCRIPTION "AXI lock signals width"
set_parameter_property AXI_LOCK_WIDTH AFFECTS_ELABORATION true
set_parameter_property AXI_LOCK_WIDTH HDL_PARAMETER true
set_parameter_property AXI_LOCK_WIDTH ALLOWED_RANGES 1:2

add_parameter USE_ADDR_USER INTEGER 1
set_parameter_property USE_ADDR_USER DISPLAY_NAME "Enable AXI address sideband signals"
set_parameter_property USE_ADDR_USER TYPE INTEGER
set_parameter_property USE_ADDR_USER UNITS None
set_parameter_property USE_ADDR_USER DESCRIPTION "Enables AWUSER and ARUSER"
set_parameter_property USE_ADDR_USER AFFECTS_ELABORATION true
set_parameter_property USE_ADDR_USER ALLOWED_RANGES 0:1
set_parameter_property USE_ADDR_USER DISPLAY_HINT "boolean"


# add_parameter USE_DATA_USER INTEGER 0
# set_parameter_property USE_DATA_USER DISPLAY_NAME "Enable AXI data sideband signals"
# set_parameter_property USE_DATA_USER TYPE INTEGER
# set_parameter_property USE_DATA_USER UNITS None
# set_parameter_property USE_DATA_USER DESCRIPTION "Enables BUSER, WUSER and RUSER"
# set_parameter_property USE_DATA_USER AFFECTS_ELABORATION true
# set_parameter_property USE_DATA_USER ALLOWED_RANGES 0:1
# set_parameter_property USE_DATA_USER DISPLAY_HINT "boolean"


add_parameter AXI_VERSION STRING "AXI3"
set_parameter_property AXI_VERSION DISPLAY_NAME "AXI Version"
set_parameter_property AXI_VERSION TYPE STRING
set_parameter_property AXI_VERSION UNITS None
set_parameter_property AXI_VERSION DESCRIPTION "Indicate this is AXI3 master"
set_parameter_property AXI_VERSION AFFECTS_ELABORATION true
set_parameter_property AXI_VERSION ALLOWED_RANGES "AXI3,AXI4,AXI4Lite"
set_parameter_property AXI_VERSION DISPLAY_HINT "boolean"
set_parameter_property AXI_VERSION HDL_PARAMETER true

add_parameter WRITE_ISSUING_CAPABILITY INTEGER 16 "The number of write transaciton that master ni can hold"
set_parameter_property WRITE_ISSUING_CAPABILITY  DEFAULT_VALUE 16
set_parameter_property WRITE_ISSUING_CAPABILITY  DISPLAY_NAME "Master write outstanding transactions"
set_parameter_property WRITE_ISSUING_CAPABILITY  TYPE INTEGER
set_parameter_property WRITE_ISSUING_CAPABILITY  UNITS None
set_parameter_property WRITE_ISSUING_CAPABILITY DESCRIPTION "The number of write transaciton that master ni can hold"
set_parameter_property WRITE_ISSUING_CAPABILITY AFFECTS_ELABORATION true
set_parameter_property WRITE_ISSUING_CAPABILITY HDL_PARAMETER true
add_parameter READ_ISSUING_CAPABILITY INTEGER 16 "The number of read transaciton that master ni can hold"
set_parameter_property READ_ISSUING_CAPABILITY DEFAULT_VALUE 16
set_parameter_property READ_ISSUING_CAPABILITY DISPLAY_NAME "Master read outstanding transactions"
set_parameter_property READ_ISSUING_CAPABILITY TYPE INTEGER
set_parameter_property READ_ISSUING_CAPABILITY UNITS None
set_parameter_property READ_ISSUING_CAPABILITY DESCRIPTION "The number of read transaciton that master ni can hold"
set_parameter_property READ_ISSUING_CAPABILITY AFFECTS_ELABORATION true
set_parameter_property READ_ISSUING_CAPABILITY HDL_PARAMETER true


add_parameter PKT_BEGIN_BURST INTEGER 104
set_parameter_property PKT_BEGIN_BURST DEFAULT_VALUE 104
set_parameter_property PKT_BEGIN_BURST DISPLAY_NAME "Packet begin burst field index"
set_parameter_property PKT_BEGIN_BURST TYPE INTEGER
set_parameter_property PKT_BEGIN_BURST UNITS None
set_parameter_property PKT_BEGIN_BURST DESCRIPTION "Packet begin burst field index"
set_parameter_property PKT_BEGIN_BURST AFFECTS_ELABORATION true
set_parameter_property PKT_BEGIN_BURST HDL_PARAMETER true
add_parameter PKT_CACHE_H INTEGER 103
set_parameter_property PKT_CACHE_H DEFAULT_VALUE 103
set_parameter_property PKT_CACHE_H DISPLAY_NAME "Packet AXI cache field index - high"
set_parameter_property PKT_CACHE_H TYPE INTEGER
set_parameter_property PKT_CACHE_H UNITS None
set_parameter_property PKT_CACHE_H DESCRIPTION "MSB of the Packet AXI cache field index"
set_parameter_property PKT_CACHE_H AFFECTS_ELABORATION true
set_parameter_property PKT_CACHE_H HDL_PARAMETER true
add_parameter PKT_CACHE_L INTEGER 100
set_parameter_property PKT_CACHE_L DEFAULT_VALUE 100
set_parameter_property PKT_CACHE_L DISPLAY_NAME "Packet AXI cache field index - low"
set_parameter_property PKT_CACHE_L TYPE INTEGER
set_parameter_property PKT_CACHE_L UNITS None
set_parameter_property PKT_CACHE_L DESCRIPTION "LSB of the Packet AXI cache field index"
set_parameter_property PKT_CACHE_L AFFECTS_ELABORATION true
set_parameter_property PKT_CACHE_L HDL_PARAMETER true
add_parameter PKT_ADDR_SIDEBAND_H INTEGER 99
set_parameter_property PKT_ADDR_SIDEBAND_H DEFAULT_VALUE 99
set_parameter_property PKT_ADDR_SIDEBAND_H DISPLAY_NAME "Packet AXI address sideband field index - high"
set_parameter_property PKT_ADDR_SIDEBAND_H TYPE INTEGER
set_parameter_property PKT_ADDR_SIDEBAND_H UNITS None
set_parameter_property PKT_ADDR_SIDEBAND_H DESCRIPTION "MSB of the Packet AXI address sideband field index"
set_parameter_property PKT_ADDR_SIDEBAND_H AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_SIDEBAND_H HDL_PARAMETER true
add_parameter PKT_ADDR_SIDEBAND_L INTEGER 92
set_parameter_property PKT_ADDR_SIDEBAND_L DEFAULT_VALUE 92
set_parameter_property PKT_ADDR_SIDEBAND_L DISPLAY_NAME "Packet AXI address sideband field index - low"
set_parameter_property PKT_ADDR_SIDEBAND_L TYPE INTEGER
set_parameter_property PKT_ADDR_SIDEBAND_L UNITS None
set_parameter_property PKT_ADDR_SIDEBAND_L DESCRIPTION "LSB of the Packet AXI address sideband field index"
set_parameter_property PKT_ADDR_SIDEBAND_L AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_SIDEBAND_L HDL_PARAMETER true
add_parameter PKT_PROTECTION_H INTEGER 89
set_parameter_property PKT_PROTECTION_H DEFAULT_VALUE 89
set_parameter_property PKT_PROTECTION_H DISPLAY_NAME "Packet AXI protection field index - high"
set_parameter_property PKT_PROTECTION_H TYPE INTEGER
set_parameter_property PKT_PROTECTION_H UNITS None
set_parameter_property PKT_PROTECTION_H DESCRIPTION "MSB of the Packet AXI protection field index "
set_parameter_property PKT_PROTECTION_H AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_H HDL_PARAMETER true
add_parameter PKT_PROTECTION_L INTEGER 87
set_parameter_property PKT_PROTECTION_L DEFAULT_VALUE 87
set_parameter_property PKT_PROTECTION_L DISPLAY_NAME "Packet AXI protection field index - low"
set_parameter_property PKT_PROTECTION_L TYPE INTEGER
set_parameter_property PKT_PROTECTION_L UNITS None
set_parameter_property PKT_PROTECTION_L DESCRIPTION "LSB of the Packet AXI protection field index "
set_parameter_property PKT_PROTECTION_L AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_L HDL_PARAMETER true
add_parameter PKT_BURST_SIZE_H INTEGER 84
set_parameter_property PKT_BURST_SIZE_H DEFAULT_VALUE 84
set_parameter_property PKT_BURST_SIZE_H DISPLAY_NAME "Packet AXI burst size field index - high"
set_parameter_property PKT_BURST_SIZE_H TYPE INTEGER
set_parameter_property PKT_BURST_SIZE_H UNITS None
set_parameter_property PKT_BURST_SIZE_H DESCRIPTION "MSB of the Packet AXI burst size field index"
set_parameter_property PKT_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_SIZE_H HDL_PARAMETER true
add_parameter PKT_BURST_SIZE_L INTEGER 82
set_parameter_property PKT_BURST_SIZE_L DEFAULT_VALUE 82
set_parameter_property PKT_BURST_SIZE_L DISPLAY_NAME "Packet AXI burst size field index - low"
set_parameter_property PKT_BURST_SIZE_L TYPE INTEGER
set_parameter_property PKT_BURST_SIZE_L UNITS None
set_parameter_property PKT_BURST_SIZE_L DESCRIPTION "LSB of the Packet AXI burst size field index"
set_parameter_property PKT_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_SIZE_L HDL_PARAMETER true
add_parameter PKT_BURST_TYPE_H INTEGER 86
set_parameter_property PKT_BURST_TYPE_H DEFAULT_VALUE 86
set_parameter_property PKT_BURST_TYPE_H DISPLAY_NAME "Packet AXI burst type field index - high"
set_parameter_property PKT_BURST_TYPE_H TYPE INTEGER
set_parameter_property PKT_BURST_TYPE_H UNITS None
set_parameter_property PKT_BURST_TYPE_H DESCRIPTION "MSB of the Packet AXI burst type field index"
set_parameter_property PKT_BURST_TYPE_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_TYPE_H HDL_PARAMETER true
add_parameter PKT_BURST_TYPE_L INTEGER 85
set_parameter_property PKT_BURST_TYPE_L DEFAULT_VALUE 85
set_parameter_property PKT_BURST_TYPE_L DISPLAY_NAME "Packet AXI burst type field index - low"
set_parameter_property PKT_BURST_TYPE_L TYPE INTEGER
set_parameter_property PKT_BURST_TYPE_L UNITS None
set_parameter_property PKT_BURST_TYPE_L DESCRIPTION "LSB of the Packet AXI burst type field index"
set_parameter_property PKT_BURST_TYPE_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_TYPE_L HDL_PARAMETER true 
add_parameter PKT_RESPONSE_STATUS_L INTEGER 106
add_parameter PKT_RESPONSE_STATUS_H INTEGER 107
set_parameter_property PKT_RESPONSE_STATUS_H DEFAULT_VALUE 107
set_parameter_property PKT_RESPONSE_STATUS_H DISPLAY_NAME "Packet response field index - high"
set_parameter_property PKT_RESPONSE_STATUS_H TYPE INTEGER
set_parameter_property PKT_RESPONSE_STATUS_H UNITS None
set_parameter_property PKT_RESPONSE_STATUS_H DESCRIPTION "MSB of the packet response field index"
set_parameter_property PKT_RESPONSE_STATUS_H AFFECTS_ELABORATION true
set_parameter_property PKT_RESPONSE_STATUS_H HDL_PARAMETER true
set_parameter_property PKT_RESPONSE_STATUS_L DEFAULT_VALUE 106
set_parameter_property PKT_RESPONSE_STATUS_L DISPLAY_NAME "Packet response field index - low"
set_parameter_property PKT_RESPONSE_STATUS_L TYPE INTEGER
set_parameter_property PKT_RESPONSE_STATUS_L UNITS None
set_parameter_property PKT_RESPONSE_STATUS_L DESCRIPTION "LSB of the packet response field index"
set_parameter_property PKT_RESPONSE_STATUS_L AFFECTS_ELABORATION true
set_parameter_property PKT_RESPONSE_STATUS_L HDL_PARAMETER true

add_parameter PKT_BURSTWRAP_H INTEGER 79
set_parameter_property PKT_BURSTWRAP_H DEFAULT_VALUE 79
set_parameter_property PKT_BURSTWRAP_H DISPLAY_NAME "Packet AXI burstwrap field index - high"
set_parameter_property PKT_BURSTWRAP_H TYPE INTEGER
set_parameter_property PKT_BURSTWRAP_H UNITS None
set_parameter_property PKT_BURSTWRAP_H DESCRIPTION "MSB of the Packet AXI burstwrap field index"
set_parameter_property PKT_BURSTWRAP_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURSTWRAP_H HDL_PARAMETER true
add_parameter PKT_BURSTWRAP_L INTEGER 77
set_parameter_property PKT_BURSTWRAP_L DEFAULT_VALUE 77
set_parameter_property PKT_BURSTWRAP_L DISPLAY_NAME "Packet AXI burstwrap field index - low"
set_parameter_property PKT_BURSTWRAP_L TYPE INTEGER
set_parameter_property PKT_BURSTWRAP_L UNITS None
set_parameter_property PKT_BURSTWRAP_L DESCRIPTION "LSB of the Packet AXI burstwrap field index"
set_parameter_property PKT_BURSTWRAP_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURSTWRAP_L HDL_PARAMETER true
add_parameter PKT_BYTE_CNT_H INTEGER 76
set_parameter_property PKT_BYTE_CNT_H DEFAULT_VALUE 76
set_parameter_property PKT_BYTE_CNT_H DISPLAY_NAME "Packet byte count field index - high"
set_parameter_property PKT_BYTE_CNT_H TYPE INTEGER
set_parameter_property PKT_BYTE_CNT_H UNITS None
set_parameter_property PKT_BYTE_CNT_H DESCRIPTION "MSB of the Packet byte count field index"
set_parameter_property PKT_BYTE_CNT_H AFFECTS_ELABORATION true
set_parameter_property PKT_BYTE_CNT_H HDL_PARAMETER true
add_parameter PKT_BYTE_CNT_L INTEGER 74
set_parameter_property PKT_BYTE_CNT_L DEFAULT_VALUE 74
set_parameter_property PKT_BYTE_CNT_L DISPLAY_NAME "Packet byte count field index - low"
set_parameter_property PKT_BYTE_CNT_L TYPE INTEGER
set_parameter_property PKT_BYTE_CNT_L UNITS None
set_parameter_property PKT_BYTE_CNT_L DESCRIPTION "LSB of the Packet byte count field index"
set_parameter_property PKT_BYTE_CNT_L AFFECTS_ELABORATION true
set_parameter_property PKT_BYTE_CNT_L HDL_PARAMETER true
add_parameter PKT_ADDR_H INTEGER 73
set_parameter_property PKT_ADDR_H DEFAULT_VALUE 73
set_parameter_property PKT_ADDR_H DISPLAY_NAME "Packet AXI address field index - high"
set_parameter_property PKT_ADDR_H TYPE INTEGER
set_parameter_property PKT_ADDR_H UNITS None
set_parameter_property PKT_ADDR_H DESCRIPTION "MSB of Packet AXI address field index"
set_parameter_property PKT_ADDR_H AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_H HDL_PARAMETER true
add_parameter PKT_ADDR_L INTEGER 42
set_parameter_property PKT_ADDR_L DEFAULT_VALUE 42
set_parameter_property PKT_ADDR_L DISPLAY_NAME "Packet AXI address field index - high"
set_parameter_property PKT_ADDR_L TYPE INTEGER
set_parameter_property PKT_ADDR_L UNITS None
set_parameter_property PKT_ADDR_L DESCRIPTION "LSB of the Packet AXI address field index"
set_parameter_property PKT_ADDR_L AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_L HDL_PARAMETER true

add_parameter PKT_TRANS_EXCLUSIVE INTEGER 81
set_parameter_property PKT_TRANS_EXCLUSIVE DEFAULT_VALUE 81
set_parameter_property PKT_TRANS_EXCLUSIVE DISPLAY_NAME "Packet exclusive transaction field index"
set_parameter_property PKT_TRANS_EXCLUSIVE TYPE INTEGER
set_parameter_property PKT_TRANS_EXCLUSIVE UNITS None
set_parameter_property PKT_TRANS_EXCLUSIVE DESCRIPTION "Packet exclusive transaction field index"
set_parameter_property PKT_TRANS_EXCLUSIVE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_EXCLUSIVE HDL_PARAMETER true
add_parameter PKT_TRANS_LOCK INTEGER 105
set_parameter_property PKT_TRANS_LOCK DEFAULT_VALUE 105
set_parameter_property PKT_TRANS_LOCK DISPLAY_NAME "Packet lock transaction field index"
set_parameter_property PKT_TRANS_LOCK TYPE INTEGER
set_parameter_property PKT_TRANS_LOCK UNITS None
set_parameter_property PKT_TRANS_LOCK DESCRIPTION "Packet lock transaction field index"
set_parameter_property PKT_TRANS_LOCK AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_LOCK HDL_PARAMETER true

add_parameter PKT_TRANS_COMPRESSED_READ INTEGER 41
set_parameter_property PKT_TRANS_COMPRESSED_READ DEFAULT_VALUE 41
set_parameter_property PKT_TRANS_COMPRESSED_READ DISPLAY_NAME "Packet compressed read transaction field index"
set_parameter_property PKT_TRANS_COMPRESSED_READ TYPE INTEGER
set_parameter_property PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property PKT_TRANS_COMPRESSED_READ DESCRIPTION "Packet compressed read transaction field index"
set_parameter_property PKT_TRANS_COMPRESSED_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
add_parameter PKT_TRANS_POSTED INTEGER 40
set_parameter_property PKT_TRANS_POSTED DEFAULT_VALUE 40
set_parameter_property PKT_TRANS_POSTED DISPLAY_NAME "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED TYPE INTEGER
set_parameter_property PKT_TRANS_POSTED UNITS None
set_parameter_property PKT_TRANS_POSTED DESCRIPTION "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_POSTED HDL_PARAMETER true
add_parameter PKT_TRANS_WRITE INTEGER 39
set_parameter_property PKT_TRANS_WRITE DEFAULT_VALUE 39
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE TYPE INTEGER
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE DESCRIPTION "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true
add_parameter PKT_TRANS_READ INTEGER 38
set_parameter_property PKT_TRANS_READ DEFAULT_VALUE 38
set_parameter_property PKT_TRANS_READ DISPLAY_NAME "Packet read transaction field index"
set_parameter_property PKT_TRANS_READ TYPE INTEGER
set_parameter_property PKT_TRANS_READ UNITS None
set_parameter_property PKT_TRANS_READ DESCRIPTION "Packet read transaction field index"
set_parameter_property PKT_TRANS_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_READ HDL_PARAMETER true
add_parameter PKT_DATA_H INTEGER 37
set_parameter_property PKT_DATA_H DEFAULT_VALUE 37
set_parameter_property PKT_DATA_H DISPLAY_NAME "Packet AXI data field index - high"
set_parameter_property PKT_DATA_H TYPE INTEGER
set_parameter_property PKT_DATA_H UNITS None
set_parameter_property PKT_DATA_H DESCRIPTION "MSB of the Packet AXI data field index"
set_parameter_property PKT_DATA_H AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_H HDL_PARAMETER true
add_parameter PKT_DATA_L INTEGER 6
set_parameter_property PKT_DATA_L DEFAULT_VALUE 6
set_parameter_property PKT_DATA_L DISPLAY_NAME "Packet AXI data field index - low"
set_parameter_property PKT_DATA_L TYPE INTEGER
set_parameter_property PKT_DATA_L UNITS None
set_parameter_property PKT_DATA_L DESCRIPTION "LSB of the Packet AXI data field index"
set_parameter_property PKT_DATA_L AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_L HDL_PARAMETER true
add_parameter PKT_BYTEEN_H INTEGER 5
set_parameter_property PKT_BYTEEN_H DEFAULT_VALUE 5
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME "Packet byteenabke field index - high"
set_parameter_property PKT_BYTEEN_H TYPE INTEGER
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H DESCRIPTION "MSB of the Packet byteenabke field index"
set_parameter_property PKT_BYTEEN_H AFFECTS_ELABORATION true
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
add_parameter PKT_BYTEEN_L INTEGER 2
set_parameter_property PKT_BYTEEN_L DEFAULT_VALUE 2
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME "Packet byteenabke field index - low"
set_parameter_property PKT_BYTEEN_L TYPE INTEGER
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L DESCRIPTION "LSB of the Packet byteenabke field index"
set_parameter_property PKT_BYTEEN_L AFFECTS_ELABORATION true
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
add_parameter PKT_SRC_ID_H INTEGER 1
set_parameter_property PKT_SRC_ID_H DEFAULT_VALUE 1
set_parameter_property PKT_SRC_ID_H DISPLAY_NAME "Packet source id field index - high"
set_parameter_property PKT_SRC_ID_H TYPE INTEGER
set_parameter_property PKT_SRC_ID_H UNITS None
set_parameter_property PKT_SRC_ID_H DESCRIPTION "MSB of the Packet source id field index "
set_parameter_property PKT_SRC_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_H HDL_PARAMETER true
add_parameter PKT_SRC_ID_L INTEGER 1
set_parameter_property PKT_SRC_ID_L DEFAULT_VALUE 1
set_parameter_property PKT_SRC_ID_L DISPLAY_NAME "Packet source id field index - low"
set_parameter_property PKT_SRC_ID_L TYPE INTEGER
set_parameter_property PKT_SRC_ID_L UNITS None
set_parameter_property PKT_SRC_ID_L DESCRIPTION "LSB of the Packet source id field index "
set_parameter_property PKT_SRC_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_L HDL_PARAMETER true
add_parameter PKT_DEST_ID_H INTEGER 0
set_parameter_property PKT_DEST_ID_H DEFAULT_VALUE 0
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME "Packet destination id field index - high"
set_parameter_property PKT_DEST_ID_H TYPE INTEGER
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H DESCRIPTION "MSB of the Packet destination id field index"
set_parameter_property PKT_DEST_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER true
add_parameter PKT_DEST_ID_L INTEGER 0
set_parameter_property PKT_DEST_ID_L DEFAULT_VALUE 0
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME "Packet destination id field index - low"
set_parameter_property PKT_DEST_ID_L TYPE INTEGER
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L DESCRIPTION "LSB of the Packet destination id field index"
set_parameter_property PKT_DEST_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_L HDL_PARAMETER true

add_parameter PKT_THREAD_ID_H INTEGER 109
set_parameter_property PKT_THREAD_ID_H DISPLAY_NAME "Packet thread id index - high"
set_parameter_property PKT_THREAD_ID_H TYPE INTEGER
set_parameter_property PKT_THREAD_ID_H UNITS None
set_parameter_property PKT_THREAD_ID_H DESCRIPTION "MSB of the packet thread id field index"
set_parameter_property PKT_THREAD_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_THREAD_ID_H HDL_PARAMETER true

add_parameter PKT_THREAD_ID_L INTEGER 108
set_parameter_property PKT_THREAD_ID_L DISPLAY_NAME "Packet thread id index - low"
set_parameter_property PKT_THREAD_ID_L TYPE INTEGER
set_parameter_property PKT_THREAD_ID_L UNITS None
set_parameter_property PKT_THREAD_ID_L DESCRIPTION "LSB of the packet thread id field index"
set_parameter_property PKT_THREAD_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_THREAD_ID_L HDL_PARAMETER true

add_parameter PKT_QOS_L INTEGER 110
set_parameter_property PKT_QOS_L DISPLAY_NAME "Packet QoS index - low"
set_parameter_property PKT_QOS_L TYPE INTEGER
set_parameter_property PKT_QOS_L UNITS None
set_parameter_property PKT_QOS_L DESCRIPTION "LSB of the packet QoS field index"
set_parameter_property PKT_QOS_L AFFECTS_ELABORATION true
set_parameter_property PKT_QOS_L HDL_PARAMETER true
add_parameter PKT_QOS_H INTEGER 113
set_parameter_property PKT_QOS_H DISPLAY_NAME "Packet QoS index - high"
set_parameter_property PKT_QOS_H TYPE INTEGER
set_parameter_property PKT_QOS_H UNITS None
set_parameter_property PKT_QOS_H DESCRIPTION "MSB of the packet Qos field index"
set_parameter_property PKT_QOS_H AFFECTS_ELABORATION true
set_parameter_property PKT_QOS_H HDL_PARAMETER true

add_parameter PKT_ORI_BURST_SIZE_L INTEGER 125
set_parameter_property PKT_ORI_BURST_SIZE_L DISPLAY_NAME "Packet original burst size index - low"
set_parameter_property PKT_ORI_BURST_SIZE_L TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_L UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_L DESCRIPTION "LSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_L HDL_PARAMETER true
add_parameter PKT_ORI_BURST_SIZE_H INTEGER 127
set_parameter_property PKT_ORI_BURST_SIZE_H DISPLAY_NAME "Packet original burst size index - high"
set_parameter_property PKT_ORI_BURST_SIZE_H TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_H UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_H DESCRIPTION "MSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_H HDL_PARAMETER true

# add_parameter PKT_REGION_L INTEGER 114
# set_parameter_property PKT_REGION_L DISPLAY_NAME "Packet Region index - low"
# set_parameter_property PKT_REGION_L TYPE INTEGER
# set_parameter_property PKT_REGION_L UNITS None
# set_parameter_property PKT_REGION_L DESCRIPTION "LSB of the packet Region field index"
# set_parameter_property PKT_REGION_L AFFECTS_ELABORATION true
# set_parameter_property PKT_REGION_L HDL_PARAMETER true
# add_parameter PKT_REGION_H INTEGER 117
# set_parameter_property PKT_REGION_H DISPLAY_NAME "Packet Region index - high"
# set_parameter_property PKT_REGION_H TYPE INTEGER
# set_parameter_property PKT_REGION_H UNITS None
# set_parameter_property PKT_REGION_H DESCRIPTION "MSB of the packet Region field index"
# set_parameter_property PKT_REGION_H AFFECTS_ELABORATION true
# set_parameter_property PKT_REGION_H HDL_PARAMETER true

add_parameter PKT_DATA_SIDEBAND_H INTEGER 121
set_parameter_property PKT_DATA_SIDEBAND_H DEFAULT_VALUE 121
set_parameter_property PKT_DATA_SIDEBAND_H DISPLAY_NAME "Packet AXI data sideband field index - high"
set_parameter_property PKT_DATA_SIDEBAND_H TYPE INTEGER
set_parameter_property PKT_DATA_SIDEBAND_H UNITS None
set_parameter_property PKT_DATA_SIDEBAND_H DESCRIPTION "MSB of the Packet AXI data sideband field index"
set_parameter_property PKT_DATA_SIDEBAND_H AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_SIDEBAND_H HDL_PARAMETER true
add_parameter PKT_DATA_SIDEBAND_L INTEGER 114
set_parameter_property PKT_DATA_SIDEBAND_L DEFAULT_VALUE 114
set_parameter_property PKT_DATA_SIDEBAND_L DISPLAY_NAME "Packet AXI data sideband field index - low"
set_parameter_property PKT_DATA_SIDEBAND_L TYPE INTEGER
set_parameter_property PKT_DATA_SIDEBAND_L UNITS None
set_parameter_property PKT_DATA_SIDEBAND_L DESCRIPTION "LSB of the Packet AXI data sideband field index"
set_parameter_property PKT_DATA_SIDEBAND_L AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_SIDEBAND_L HDL_PARAMETER true

add_parameter ST_DATA_W INTEGER 128
set_parameter_property ST_DATA_W DEFAULT_VALUE 122
set_parameter_property ST_DATA_W DISPLAY_NAME "Streaming data width"
set_parameter_property ST_DATA_W TYPE INTEGER
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W DESCRIPTION "Streaming data width"
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER true
add_parameter ST_CHANNEL_W INTEGER 1
set_parameter_property ST_CHANNEL_W DEFAULT_VALUE 1
set_parameter_property ST_CHANNEL_W DISPLAY_NAME "Streaming channel width"
set_parameter_property ST_CHANNEL_W TYPE INTEGER
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W DESCRIPTION "Streaming channel width"
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true

add_parameter ID INTEGER 1
set_parameter_property ID DEFAULT_VALUE 1
set_parameter_property ID DISPLAY_NAME "Master ID"
set_parameter_property ID TYPE INTEGER
set_parameter_property ID UNITS None
set_parameter_property ID DESCRIPTION "Network-domain-unique Master ID"
set_parameter_property ID AFFECTS_ELABORATION true
set_parameter_property ID HDL_PARAMETER true

add_parameter ADDR_MAP STRING ""
set_parameter_property ADDR_MAP DISPLAY_NAME "Address map"
set_parameter_property ADDR_MAP UNITS None
set_parameter_property ADDR_MAP DESCRIPTION "Address map"
set_parameter_property ADDR_MAP AFFECTS_ELABORATION true
set_parameter_property ADDR_MAP HDL_PARAMETER false

add_parameter MERLIN_PACKET_FORMAT STRING ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME "Merlin packet format"
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION "Merlin packet format"
set_parameter_property MERLIN_PACKET_FORMAT AFFECTS_ELABORATION true
set_parameter_property MERLIN_PACKET_FORMAT HDL_PARAMETER false

# +-----------------------------------
# | Set all parameters to AFFECTS_GENERATION false
# | 
foreach parameter [get_parameters] { 
	set_parameter_property $parameter AFFECTS_GENERATION false 
 }
# | 
# +-----------------------------------

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
add_display_item "AXI Master Interface " ID_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " ADDR_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " RDATA_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " WDATA_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " ADDR_USER_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " DATA_USER_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " AXI_BURST_LENGTH_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " AXI_LOCK_WIDTH PARAMETER ""
add_display_item "AXI Master Interface " USE_ADDR_USER PARAMETER ""
#add_display_item "AXI Master Interface " USE_DATA_USER PARAMETER ""
add_display_item "AXI Master Interface " AXI_VERSION PARAMETER ""

add_display_item "Transaction Issuing Capability" WRITE_ISSUING_CAPABILITY PARAMETER ""
add_display_item "Transaction Issuing Capability" READ_ISSUING_CAPABILITY PARAMETER ""
add_display_item "Qsys Packet Format" PKT_ADDR_SIDEBAND_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_ADDR_SIDEBAND_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_DATA_SIDEBAND_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_DATA_SIDEBAND_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_RESPONSE_STATUS_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_RESPONSE_STATUS_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_QOS_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_QOS_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_ORI_BURST_SIZE_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_ORI_BURST_SIZE_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_THREAD_ID_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_THREAD_ID_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BEGIN_BURST PARAMETER ""
add_display_item "Qsys Packet Format" PKT_CACHE_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_CACHE_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_PROTECTION_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_PROTECTION_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BURST_SIZE_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BURST_SIZE_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BURST_TYPE_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BURST_TYPE_L PARAMETER ""  
add_display_item "Qsys Packet Format" PKT_TRANS_EXCLUSIVE PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BURSTWRAP_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BURSTWRAP_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BYTE_CNT_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BYTE_CNT_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_ADDR_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_ADDR_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_TRANS_LOCK PARAMETER ""
add_display_item "Qsys Packet Format" PKT_TRANS_COMPRESSED_READ PARAMETER ""
add_display_item "Qsys Packet Format" PKT_TRANS_POSTED PARAMETER ""
add_display_item "Qsys Packet Format" PKT_TRANS_WRITE PARAMETER ""
add_display_item "Qsys Packet Format" PKT_TRANS_READ PARAMETER ""
add_display_item "Qsys Packet Format" PKT_DATA_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_DATA_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BYTEEN_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_BYTEEN_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_SRC_ID_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_SRC_ID_L PARAMETER ""
add_display_item "Qsys Packet Format" PKT_DEST_ID_H PARAMETER ""
add_display_item "Qsys Packet Format" PKT_DEST_ID_L PARAMETER ""
add_display_item "Qsys Packet Format" ST_DATA_W PARAMETER ""
add_display_item "Qsys Packet Format" ST_CHANNEL_W PARAMETER ""
add_display_item "Qsys Packet Format" AV_BURSTCOUNT_W PARAMETER ""
add_display_item "Qsys Packet Format" ID PARAMETER ""
add_display_item "Qsys Packet Format" SUPPRESS_0_BYTEEN_RSP PARAMETER ""
add_display_item "Qsys Packet Format" BURSTWRAP_VALUE PARAMETER ""
add_display_item "Qsys Packet Format" ADDR_MAP PARAMETER ""
add_display_item "Qsys Packet Format" MERLIN_PACKET_FORMAT PARAMETER ""
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk clockRate 0

set_interface_property clk ENABLED true

add_interface_port clk aclk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_reset
# | 
add_interface clk_reset reset end
set_interface_property clk_reset associatedClock clk
set_interface_property clk_reset synchronousEdges DEASSERT

set_interface_property clk_reset ENABLED true

add_interface_port clk_reset aresetn reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point write_cp
# | 
add_interface write_cp avalon_streaming start
set_interface_property write_cp associatedClock clk
set_interface_property write_cp associatedReset clk_reset
set_interface_property write_cp dataBitsPerSymbol 108
set_interface_property write_cp errorDescriptor ""
set_interface_property write_cp firstSymbolInHighOrderBits true
set_interface_property write_cp maxChannel 0
set_interface_property write_cp readyLatency 0

set_interface_property write_cp ENABLED true

add_interface_port write_cp write_cp_valid valid Output 1
add_interface_port write_cp write_cp_data data Output 108
add_interface_port write_cp write_cp_startofpacket startofpacket Output 1
add_interface_port write_cp write_cp_endofpacket endofpacket Output 1
add_interface_port write_cp write_cp_ready ready Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point write_rp
# | 
add_interface write_rp avalon_streaming end
set_interface_property write_rp associatedClock clk
set_interface_property write_rp associatedReset clk_reset
set_interface_property write_rp dataBitsPerSymbol 108
set_interface_property write_rp errorDescriptor ""
set_interface_property write_rp firstSymbolInHighOrderBits true
set_interface_property write_rp maxChannel 0
set_interface_property write_rp readyLatency 0

set_interface_property write_rp ENABLED true

add_interface_port write_rp write_rp_valid valid Input 1
add_interface_port write_rp write_rp_data data Input 108
add_interface_port write_rp write_rp_channel channel Input 1
add_interface_port write_rp write_rp_startofpacket startofpacket Input 1
add_interface_port write_rp write_rp_endofpacket endofpacket Input 1
add_interface_port write_rp write_rp_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point read_cp
# | 
add_interface read_cp avalon_streaming start
set_interface_property read_cp associatedClock clk
set_interface_property read_cp associatedReset clk_reset
set_interface_property read_cp dataBitsPerSymbol 108
set_interface_property read_cp errorDescriptor ""
set_interface_property read_cp firstSymbolInHighOrderBits true
set_interface_property read_cp maxChannel 0
set_interface_property read_cp readyLatency 0

set_interface_property read_cp ENABLED true

add_interface_port read_cp read_cp_valid valid Output 1
add_interface_port read_cp read_cp_data data Output 108
add_interface_port read_cp read_cp_startofpacket startofpacket Output 1
add_interface_port read_cp read_cp_endofpacket endofpacket Output 1
add_interface_port read_cp read_cp_ready ready Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point read_rp
# | 
add_interface read_rp avalon_streaming end
set_interface_property read_rp associatedClock clk
set_interface_property read_rp associatedReset clk_reset
set_interface_property read_rp dataBitsPerSymbol 108
set_interface_property read_rp errorDescriptor ""
set_interface_property read_rp firstSymbolInHighOrderBits true
set_interface_property read_rp maxChannel 0
set_interface_property read_rp readyLatency 0

set_interface_property read_rp ENABLED true

add_interface_port read_rp read_rp_valid valid Input 1
add_interface_port read_rp read_rp_data data Input 108
add_interface_port read_rp read_rp_channel channel Input 1
add_interface_port read_rp read_rp_startofpacket startofpacket Input 1
add_interface_port read_rp read_rp_endofpacket endofpacket Input 1
add_interface_port read_rp read_rp_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {
    set axi_version   [ get_parameter_value AXI_VERSION ]
    set id_width      [ get_parameter_value ID_WIDTH ]
    set st_data_width [ get_parameter_value ST_DATA_W ]
    set channel_width [ get_parameter_value ST_CHANNEL_W ]
    set data_high     [ get_parameter_value PKT_DATA_H ]
    set data_low      [ get_parameter_value PKT_DATA_L ]
    set data_width    [ expr ($data_high - $data_low + 1) ]
    set addr_high     [ get_parameter_value PKT_ADDR_H ]
    set addr_low      [ get_parameter_value PKT_ADDR_L ]
    set addr_width    [ get_parameter_value ADDR_WIDTH ]
    set wstrb_width   [ expr [get_parameter_value PKT_BYTEEN_H] - [get_parameter_value PKT_BYTEEN_L] + 1]
    set addr_user     [ get_parameter_value ADDR_USER_WIDTH ]
    set data_user     [ get_parameter_value DATA_USER_WIDTH ]
    set lock_width    [ get_parameter_value AXI_LOCK_WIDTH ]
	set burst_size	  [ expr [terplog2 $wstrb_width ]]
	
    if { $axi_version == "AXI4" } {
        set burst_length 8
        set lock_width   1
    } else {
        set burst_length 4
        set lock_width   2
    }
    set_parameter_value AXI_BURST_LENGTH_WIDTH $burst_length
    set_parameter_value AXI_LOCK_WIDTH         $lock_width
    # +-----------------------------------
    # | Base on parameter to add correct interface
    # | AXI3 or AXI4
    # +-----------------------------------    
    if { $axi_version == "AXI4" } {
        add_axi4_interface
        # set AXI4 only ports
        set_port_property wuser     WIDTH_EXPR $data_user
		set_port_property  wuser vhdl_type std_logic_vector
        set_port_property buser     WIDTH_EXPR $data_user
		set_port_property  buser vhdl_type std_logic_vector
        set_port_property ruser     WIDTH_EXPR $data_user
		set_port_property  ruser vhdl_type std_logic_vector
		# VHDL support
		add_interface my_export_axi4 conduit end
		add_interface_port my_export_axi4 wid wid input 4 
		set_port_property wid       WIDTH_EXPR $id_width
		set_port_property  wid vhdl_type std_logic_vector
		set_port_property wid TERMINATION true
    } elseif { $axi_version == "AXI3" } {
        add_axi3_interface
        #set AXI3 only port
        set_port_property wid       WIDTH_EXPR $id_width
		set_port_property  wid vhdl_type std_logic_vector
		# This is crazy stuff to make VHDL simulation
		# VHDL need all ports of entity must be avaiable in the top level
		# but for AXI3, some signals are not avaiable in Qsys but they are
		# always exist in HDL (qos, region ...)
		add_interface my_export conduit end
		add_interface_port my_export awqos awqos input 4 
		set_port_property  awqos vhdl_type std_logic_vector
		set_port_property awqos TERMINATION true
		add_interface_port my_export arqos arqos input 4
		set_port_property  arqos vhdl_type std_logic_vector
		set_port_property arqos TERMINATION true
		add_interface_port my_export awregion awregion input 4
		set_port_property  awregion vhdl_type std_logic_vector
		set_port_property awregion TERMINATION true
		add_interface_port my_export arregion arregion input 4
		set_port_property  arregion vhdl_type std_logic_vector
		set_port_property arregion TERMINATION true
		add_interface_port my_export wuser wuser input 8
		set_port_property  wuser vhdl_type std_logic_vector
		set_port_property wuser TERMINATION true
		add_interface_port my_export ruser ruser output 8
		set_port_property  ruser vhdl_type std_logic_vector
		set_port_property ruser TERMINATION true
		add_interface_port my_export buser buser output 8
		set_port_property  buser vhdl_type std_logic_vector
		set_port_property buser TERMINATION true
    } else {
		add_axi4lite_interface
		add_interface my_export conduit end
		#add_export_port { intf name width termination_value input}
		# write address 
		add_export_port my_export awid $id_width 0 1
		add_export_port my_export awlen 4 0 1
		add_export_port my_export awsize 3 $burst_size 1
		add_export_port my_export awburst 2 1 1
		add_export_port my_export awlock 2 0 1
		add_export_port my_export awcache 4 0 1
		add_export_port my_export awqos 4 0 1
		add_export_port my_export awregion 4 0 1
		add_export_port my_export awuser $addr_user 0 1
		add_export_port my_export wuser $data_user 0 1
		# read address 
		add_export_port my_export arid $id_width 0 1
		add_export_port my_export arlen 4 0 1
		add_export_port my_export arsize 3 $burst_size 1
		add_export_port my_export arburst 2 1 1
		add_export_port my_export arlock 2 0 1
		add_export_port my_export arcache 4 0 1
		add_export_port my_export arqos 4 0 1
		add_export_port my_export arregion 4 0 1
		add_export_port my_export aruser $addr_user 0 1
		add_export_port my_export ruser $data_user 0 1
		#write
		add_export_port my_export wid $id_width 0 1
		add_export_port my_export wlast 1 1 1
		add_export_port my_export wuser $data_user 0 1
		#write response
		add_export_port my_export bid $id_width 0 0
		add_export_port my_export buser $data_user 0 0
		#read response
		add_export_port my_export rid $id_width 0 0
		add_export_port my_export rlast 1 0 0
		add_export_port my_export ruser $data_user 0 0
	}
    # +-----------------------------------
    # | Set correct width for each signals
    # +-----------------------------------    
	if { $axi_version == "AXI4" || $axi_version == "AXI3"} {
    set_port_property awid              WIDTH_EXPR $id_width
	set_port_property  awid vhdl_type std_logic_vector
    set_port_property arid              WIDTH_EXPR $id_width
	set_port_property  arid vhdl_type std_logic_vector
    set_port_property rid               WIDTH_EXPR $id_width
	set_port_property  rid vhdl_type std_logic_vector
    set_port_property bid               WIDTH_EXPR $id_width
	set_port_property  bid vhdl_type std_logic_vector
    set_port_property awuser            WIDTH_EXPR $addr_user
	set_port_property  awuser vhdl_type std_logic_vector
    set_port_property aruser            WIDTH_EXPR $addr_user
	set_port_property  aruser vhdl_type std_logic_vector
	 set enable_user_signals      [ get_parameter USE_ADDR_USER ]
    #set enable_user_data_signals [ get_parameter USE_DATA_USER ]

    # +-----------------------------------
    # | Terminate all ports that dont need
    # +-----------------------------------    
    if { $enable_user_signals == 0 } {
        set_port_property awuser TERMINATION true
        set_port_property aruser TERMINATION true
    }
	set_port_property  awlock vhdl_type std_logic_vector
	set_port_property  arlock vhdl_type std_logic_vector
	}
	set_port_property awaddr            WIDTH_EXPR $addr_width
	set_port_property  awaddr vhdl_type std_logic_vector
    set_port_property araddr            WIDTH_EXPR $addr_width
	set_port_property  araddr vhdl_type std_logic_vector
    set_port_property wdata             WIDTH_EXPR $data_width
	set_port_property  wdata vhdl_type std_logic_vector
    set_port_property rdata             WIDTH_EXPR $data_width
	set_port_property  rdata vhdl_type std_logic_vector
    set_port_property wstrb             WIDTH_EXPR $wstrb_width
	set_port_property  wstrb vhdl_type std_logic_vector
    set_port_property write_cp_data     WIDTH_EXPR $st_data_width
	set_port_property  write_cp_data vhdl_type std_logic_vector
    set_port_property read_cp_data      WIDTH_EXPR $st_data_width
	set_port_property  read_cp_data vhdl_type std_logic_vector
    set_port_property write_rp_data     WIDTH_EXPR $st_data_width
	set_port_property  write_rp_data vhdl_type std_logic_vector
    set_port_property read_rp_data      WIDTH_EXPR $st_data_width
	set_port_property  read_rp_data vhdl_type std_logic_vector
    set_port_property write_rp_channel  WIDTH_EXPR $channel_width
	set_port_property  write_rp_channel vhdl_type std_logic_vector
    set_port_property read_rp_channel   WIDTH_EXPR $channel_width
	set_port_property  read_rp_channel vhdl_type std_logic_vector
	


   
    # if { $axi_version == "AXI4" } {
        # if { $enable_user_data_signals == 0 } {
            # set_port_property wuser TERMINATION true
            # set_port_property ruser TERMINATION true
            # set_port_property buser TERMINATION true
        # }
    # }

    set_interface_property write_cp dataBitsPerSymbol $st_data_width
    set_interface_property read_cp  dataBitsPerSymbol $st_data_width
    set_interface_property write_rp dataBitsPerSymbol $st_data_width
    set_interface_property read_rp  dataBitsPerSymbol $st_data_width
    
    set_packet_format write_cp
    set_packet_format write_rp
    set_packet_format read_cp
    set_packet_format read_rp

    set_flow_assignments
}

proc terplog2 { x } {
    set i 1
	set log2ceil 0
		set decimal_x [expr $x]
		while {$i < $decimal_x} {
			set log2ceil  [expr $log2ceil + 1]
			set i [expr $i*2]
		}
	return $log2ceil
}    

proc set_packet_format { intf } {
    set_interface_assignment $intf merlin.packet_format [ get_parameter_value MERLIN_PACKET_FORMAT ]
}

proc set_flow_assignments { } {
	set_interface_assignment altera_axi_slave merlin.flow.read_cp read_cp
    set_interface_assignment altera_axi_slave merlin.flow.write_cp write_cp
    set_interface_assignment read_rp merlin.flow.altera_axi_slave altera_axi_slave
    set_interface_assignment write_rp merlin.flow.altera_axi_slave altera_axi_slave
    
}

proc add_export_port { intf name width termination_value input} {
	if {$input == 1} {
		add_interface_port $intf $name $name input $width 
	} else {
		add_interface_port $intf $name $name output $width 
	}
	set_port_property $name vhdl_type std_logic_vector
	set_port_property $name TERMINATION true
	if {$input == 1} {
		set_port_property $name TERMINATION_VALUE $termination_value
	}
}
