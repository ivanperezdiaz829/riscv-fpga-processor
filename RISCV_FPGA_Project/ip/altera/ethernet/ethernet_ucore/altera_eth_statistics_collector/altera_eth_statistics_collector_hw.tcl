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
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_statistics_collector
# | 
set_module_property NAME altera_eth_statistics_collector
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Statistics Collector"
set_module_property DESCRIPTION "Altera Ethernet Statistics Collector"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_statistics_collector.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_statistics_collector
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
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_statistics_collector

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "mentor/altera_eth_statistics_collector.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "aldec/altera_eth_statistics_collector.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "cadence/altera_eth_statistics_collector.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_statistics_collector.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "mentor/altera_eth_statistics_collector.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "aldec/altera_eth_statistics_collector.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "cadence/altera_eth_statistics_collector.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_statistics_collector.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_statistics_collector.v" {SYNOPSYS_SPECIFIC}
   }
}



proc elaborate {} {

  set pfc_enable [get_parameter_value ENABLE_PFC]
  set status_width [get_parameter_value STATUS_WIDTH]
  
  
  if {$pfc_enable == 1} {
     set status_width 40
  } else {
     #set status_width 40
  }
    
  set error_width 7

  set csr_datapath_width 32
  set csr_address_width 6

  set_port_property stat_sink_data WIDTH $status_width
  set_port_property stat_sink_error WIDTH $error_width

  set_port_property csr_address WIDTH $csr_address_width 
  set_port_property csr_readdata WIDTH $csr_datapath_width
  
  #set_parameter_value STATUS_WIDTH $status_width
  
  set_interface_property avalon_st_sink_data dataBitsPerSymbol $status_width
       
}

# +-----------------------------------
# | files
# | 
add_file altera_eth_statistics_collector.v {SYNTHESIS}
add_file altera_eth_statistics_collector.ocp {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# STATUS_WIDTH is disabled. User cannot modify this parameter. However it is still visible in the GUI.
add_parameter STATUS_WIDTH INTEGER 40
set_parameter_property STATUS_WIDTH DEFAULT_VALUE 40
set_parameter_property STATUS_WIDTH DISPLAY_NAME STATUS_WIDTH
set_parameter_property STATUS_WIDTH UNITS None
set_parameter_property STATUS_WIDTH DISPLAY_HINT ""
set_parameter_property STATUS_WIDTH AFFECTS_GENERATION false
set_parameter_property STATUS_WIDTH IS_HDL_PARAMETER false
set_parameter_property STATUS_WIDTH ENABLED false
#set_parameter_property STATUS_WIDTH DERIVED true

add_parameter ENABLE_PFC INTEGER 0
set_parameter_property ENABLE_PFC DEFAULT_VALUE 0
set_parameter_property ENABLE_PFC DISPLAY_NAME ENABLE_PFC
set_parameter_property ENABLE_PFC UNITS None
set_parameter_property ENABLE_PFC DISPLAY_HINT boolean
set_parameter_property ENABLE_PFC AFFECTS_GENERATION false
set_parameter_property ENABLE_PFC IS_HDL_PARAMETER true
set_parameter_property ENABLE_PFC ENABLED true

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
# | connection point csr_reset
# |
add_interface csr_reset reset end
set_interface_property csr_reset associatedClock clock
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

set_interface_property csr ASSOCIATED_CLOCK clock
set_interface_property csr ENABLED true

add_interface_port csr csr_read read Input 1
add_interface_port csr csr_address address Input 6
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_writedata writedata Input 32
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point avalon_st_sink_data
# | 
add_interface avalon_st_sink_data avalon_streaming end
set_interface_property avalon_st_sink_data dataBitsPerSymbol 39
set_interface_property avalon_st_sink_data errorDescriptor ""
set_interface_property avalon_st_sink_data maxChannel 0
set_interface_property avalon_st_sink_data readyLatency 0
set_interface_property avalon_st_sink_data symbolsPerBeat 1

set_interface_property avalon_st_sink_data ASSOCIATED_CLOCK clock
set_interface_property avalon_st_sink_data ENABLED true

add_interface_port avalon_st_sink_data stat_sink_valid valid Input 1
add_interface_port avalon_st_sink_data stat_sink_data data Input 39
add_interface_port avalon_st_sink_data stat_sink_error error Input 7
# | 
# +-----------------------------------


