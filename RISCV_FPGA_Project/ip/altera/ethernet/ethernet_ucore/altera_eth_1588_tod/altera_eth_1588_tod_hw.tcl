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
# | module altera_eth_1588_tod
# | 
set_module_property DESCRIPTION "Provides a stream of timestamps for use timestamping IEEE 1588 packets and other events."
set_module_property NAME altera_eth_1588_tod
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet IEEE 1588 Time of Day Clock"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_1588_tod.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_1588_tod
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

# Utility routines

# | Callbacks
# | 
proc elaborate {} {

  set csr_readdata_width 32
  set csr_writedata_width 32
  set tod_96_width 96
  set tod_64_width 64
  
  set_port_property csr_readdata WIDTH $csr_readdata_width
  set_port_property csr_writedata WIDTH $csr_writedata_width
  set_port_property time_of_day_96b WIDTH $tod_96_width
  set_port_property time_of_day_64b WIDTH $tod_64_width  
  set_port_property time_of_day_96b_load_data WIDTH $tod_96_width
  set_port_property time_of_day_64b_load_data WIDTH $tod_64_width

}
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_1588_tod.v {SYNTHESIS SIMULATION}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v {SYNTHESIS SIMULATION}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------


# +-----------------------------------
# | parameters
# | 
add_parameter DEFAULT_NSEC_PERIOD INTEGER 6
set_parameter_property DEFAULT_NSEC_PERIOD DISPLAY_NAME DEFAULT_NSEC_PERIOD
set_parameter_property DEFAULT_NSEC_PERIOD UNITS None
set_parameter_property DEFAULT_NSEC_PERIOD DISPLAY_HINT ""
set_parameter_property DEFAULT_NSEC_PERIOD AFFECTS_GENERATION false
set_parameter_property DEFAULT_NSEC_PERIOD IS_HDL_PARAMETER true
set_parameter_property DEFAULT_NSEC_PERIOD ALLOWED_RANGES 0:65535
set_parameter_property DEFAULT_NSEC_PERIOD ENABLED true

add_parameter DEFAULT_FNSEC_PERIOD INTEGER 0x6666
set_parameter_property DEFAULT_FNSEC_PERIOD DISPLAY_NAME DEFAULT_FNSEC_PERIOD
set_parameter_property DEFAULT_FNSEC_PERIOD UNITS None
set_parameter_property DEFAULT_FNSEC_PERIOD DISPLAY_HINT "hexadecimal"
set_parameter_property DEFAULT_FNSEC_PERIOD AFFECTS_GENERATION false
set_parameter_property DEFAULT_FNSEC_PERIOD IS_HDL_PARAMETER true
set_parameter_property DEFAULT_FNSEC_PERIOD ALLOWED_RANGES 0:65535
set_parameter_property DEFAULT_FNSEC_PERIOD ENABLED true

add_parameter DEFAULT_NSEC_ADJPERIOD INTEGER 6
set_parameter_property DEFAULT_NSEC_ADJPERIOD DISPLAY_NAME DEFAULT_NSEC_ADJPERIOD
set_parameter_property DEFAULT_NSEC_ADJPERIOD UNITS None
set_parameter_property DEFAULT_NSEC_ADJPERIOD DISPLAY_HINT ""
set_parameter_property DEFAULT_NSEC_ADJPERIOD AFFECTS_GENERATION false
set_parameter_property DEFAULT_NSEC_ADJPERIOD IS_HDL_PARAMETER true
set_parameter_property DEFAULT_NSEC_ADJPERIOD ALLOWED_RANGES 0:65535
set_parameter_property DEFAULT_NSEC_ADJPERIOD ENABLED true

add_parameter DEFAULT_FNSEC_ADJPERIOD INTEGER 0x6666
set_parameter_property DEFAULT_FNSEC_ADJPERIOD DISPLAY_NAME DEFAULT_FNSEC_ADJPERIOD
set_parameter_property DEFAULT_FNSEC_ADJPERIOD UNITS None
set_parameter_property DEFAULT_FNSEC_ADJPERIOD DISPLAY_HINT "hexadecimal"
set_parameter_property DEFAULT_FNSEC_ADJPERIOD AFFECTS_GENERATION false
set_parameter_property DEFAULT_FNSEC_ADJPERIOD IS_HDL_PARAMETER true
set_parameter_property DEFAULT_FNSEC_ADJPERIOD ALLOWED_RANGES 0:65535
set_parameter_property DEFAULT_FNSEC_ADJPERIOD ENABLED true
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_clock
# | 
add_interface csr_clock clock end

set_interface_property csr_clock ENABLED true

add_interface_port csr_clock clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_reset
# | 
add_interface csr_reset reset end
set_interface_property csr_reset associatedClock csr_clock

set_interface_property csr_reset ENABLED true

add_interface_port csr_reset rst_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point period_clock
# | 
add_interface period_clock clock end

set_interface_property period_clock ENABLED true

add_interface_port period_clock period_clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point period_clock_reset
# | 
add_interface period_clock_reset reset end
set_interface_property period_clock_reset associatedClock period_clock

set_interface_property period_clock_reset ENABLED true

add_interface_port period_clock_reset period_rst_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr
# | 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr bridgesToMaster ""
set_interface_property csr burstOnBurstBoundariesOnly false
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

set_interface_property csr associatedClock csr_clock
set_interface_property csr associatedReset csr_reset
set_interface_property csr ENABLED true

add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_address address Input 4
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_waitrequest waitrequest Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_of_day_96b
# | 
add_interface time_of_day_96b conduit start
set_interface_assignment time_of_day_96b "ui.blockdiagram.direction" Output
set_interface_property time_of_day_96b ENABLED true

add_interface_port time_of_day_96b time_of_day_96b data Output 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_of_day_64b
# | 
add_interface time_of_day_64b conduit start
set_interface_assignment time_of_day_64b "ui.blockdiagram.direction" Output
set_interface_property time_of_day_64b ENABLED true

add_interface_port time_of_day_64b time_of_day_64b data Output 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_of_day_96b_load
# | 
add_interface time_of_day_96b_load conduit start
set_interface_assignment time_of_day_96b_load "ui.blockdiagram.direction" Input
set_interface_property time_of_day_96b_load ENABLED true

add_interface_port time_of_day_96b_load time_of_day_96b_load_data data Input 96
add_interface_port time_of_day_96b_load time_of_day_96b_load_valid valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point time_of_day_64b_load
# | 
add_interface time_of_day_64b_load conduit start
set_interface_assignment time_of_day_64b_load "ui.blockdiagram.direction" Input
set_interface_property time_of_day_64b_load ENABLED true

add_interface_port time_of_day_64b_load time_of_day_64b_load_data data Input 64
add_interface_port time_of_day_64b_load time_of_day_64b_load_valid valid Input 1
# | 
# +-----------------------------------