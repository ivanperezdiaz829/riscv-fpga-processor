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
# | module altera_eth_1588_tod_synchronizer
# | 
set_module_property DESCRIPTION "Provide synchronization between 2 TOD with different phase or ppm or freq, eg 1G and 10G."
set_module_property NAME altera_eth_1588_tod_synchronizer
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet IEEE 1588 TOD Synchonizer"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_1588_tod_synchronizer.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_1588_tod_synchronizer
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

# Utility routines

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_1588_tod_synchronizer

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_1588_tod_synchronizer.v VERILOG_ENCRYPT PATH "mentor/altera_eth_1588_tod_synchronizer.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_1588_tod_synchronizer_clock_crosser.v VERILOG_ENCRYPT PATH "mentor/altera_eth_1588_tod_synchronizer_clock_crosser.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_1588_tod_synchronizer_clock_div.v VERILOG_ENCRYPT PATH "mentor/altera_eth_1588_tod_synchronizer_clock_div.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_1588_tod_synchronizer_fifo.v VERILOG_ENCRYPT PATH "mentor/altera_eth_1588_tod_synchronizer_fifo.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_1588_tod_synchronizer_gray_cnt.v VERILOG_ENCRYPT PATH "mentor/altera_eth_1588_tod_synchronizer_gray_cnt.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v VERILOG_ENCRYPT PATH "mentor/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_1588_tod_synchronizer.v VERILOG_ENCRYPT PATH "aldec/altera_eth_1588_tod_synchronizer.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_1588_tod_synchronizer_clock_crosser.v VERILOG_ENCRYPT PATH "aldec/altera_eth_1588_tod_synchronizer_clock_crosser.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_1588_tod_synchronizer_clock_div.v VERILOG_ENCRYPT PATH "aldec/altera_eth_1588_tod_synchronizer_clock_div.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_1588_tod_synchronizer_fifo.v VERILOG_ENCRYPT PATH "aldec/altera_eth_1588_tod_synchronizer_fifo.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_1588_tod_synchronizer_gray_cnt.v VERILOG_ENCRYPT PATH "aldec/altera_eth_1588_tod_synchronizer_gray_cnt.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v VERILOG_ENCRYPT PATH "aldec/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_1588_tod_synchronizer.v VERILOG_ENCRYPT PATH "cadence/altera_eth_1588_tod_synchronizer.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_1588_tod_synchronizer_clock_crosser.v VERILOG_ENCRYPT PATH "cadence/altera_eth_1588_tod_synchronizer_clock_crosser.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_1588_tod_synchronizer_clock_div.v VERILOG_ENCRYPT PATH "cadence/altera_eth_1588_tod_synchronizer_clock_div.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_1588_tod_synchronizer_fifo.v VERILOG_ENCRYPT PATH "cadence/altera_eth_1588_tod_synchronizer_fifo.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_1588_tod_synchronizer_gray_cnt.v VERILOG_ENCRYPT PATH "cadence/altera_eth_1588_tod_synchronizer_gray_cnt.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v VERILOG_ENCRYPT PATH "cadence/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_1588_tod_synchronizer.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_1588_tod_synchronizer.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_1588_tod_synchronizer_clock_crosser.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_1588_tod_synchronizer_clock_crosser.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_1588_tod_synchronizer_clock_div.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_1588_tod_synchronizer_clock_div.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_1588_tod_synchronizer_fifo.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_1588_tod_synchronizer_fifo.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_1588_tod_synchronizer_gray_cnt.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_1588_tod_synchronizer_gray_cnt.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v" {SYNOPSYS_SPECIFIC}
    }
}

# | Callbacks
# | 
proc elaborate {} {
  set tod_mode [get_parameter_value TOD_MODE]
  set sync_mode [get_parameter_value SYNC_MODE]
  
  if {$tod_mode == 1} {
	  set_port_property tod_master_data WIDTH 96
	  set_port_property tod_slave_data WIDTH 96
  } else {
	  set_port_property tod_master_data WIDTH 64
	  set_port_property tod_slave_data WIDTH 64  
  }
  
  if {$sync_mode == 2} {
	set_parameter_property PERIOD_NSEC ENABLED true
	set_parameter_property PERIOD_FNSEC ENABLED true
  } else {
	set_parameter_property PERIOD_NSEC ENABLED false
	set_parameter_property PERIOD_FNSEC ENABLED false
  }

}
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_1588_tod_synchronizer.v {SYNTHESIS}
add_file altera_eth_1588_tod_synchronizer_clock_crosser.v {SYNTHESIS}
add_file altera_eth_1588_tod_synchronizer_clock_div.v {SYNTHESIS}
add_file altera_eth_1588_tod_synchronizer_fifo.v {SYNTHESIS}
add_file altera_eth_1588_tod_synchronizer_gray_cnt.v {SYNTHESIS}
add_file altera_eth_1588_tod_synchronizer_sdpm_altsyncram.v {SYNTHESIS}
# | 
# +-----------------------------------


# +-----------------------------------
# | parameters
# | 
add_parameter TOD_MODE INTEGER 1
set_parameter_property TOD_MODE DISPLAY_NAME TOD_MODE
set_parameter_property TOD_MODE UNITS None
set_parameter_property TOD_MODE DISPLAY_HINT ""
set_parameter_property TOD_MODE AFFECTS_GENERATION false
set_parameter_property TOD_MODE IS_HDL_PARAMETER true
set_parameter_property TOD_MODE ALLOWED_RANGES {0 1}
set_parameter_property TOD_MODE ENABLED true

add_parameter SYNC_MODE INTEGER 2
set_parameter_property SYNC_MODE DISPLAY_NAME SYNC_MODE
set_parameter_property SYNC_MODE UNITS None
set_parameter_property SYNC_MODE DISPLAY_HINT ""
set_parameter_property SYNC_MODE AFFECTS_GENERATION false
set_parameter_property SYNC_MODE IS_HDL_PARAMETER true
set_parameter_property SYNC_MODE ALLOWED_RANGES {0 1 2}
set_parameter_property SYNC_MODE ENABLED true

add_parameter PERIOD_NSEC INTEGER 6
set_parameter_property PERIOD_NSEC DISPLAY_NAME PERIOD_NSEC
set_parameter_property PERIOD_NSEC UNITS None
set_parameter_property PERIOD_NSEC DISPLAY_HINT ""
set_parameter_property PERIOD_NSEC AFFECTS_GENERATION false
set_parameter_property PERIOD_NSEC IS_HDL_PARAMETER true
set_parameter_property PERIOD_NSEC ALLOWED_RANGES 0:65535
set_parameter_property PERIOD_NSEC ENABLED true

add_parameter PERIOD_FNSEC INTEGER 0x6666
set_parameter_property PERIOD_FNSEC DISPLAY_NAME PERIOD_FNSEC
set_parameter_property PERIOD_FNSEC UNITS None
set_parameter_property PERIOD_FNSEC DISPLAY_HINT "hexadecimal"
set_parameter_property PERIOD_FNSEC AFFECTS_GENERATION false
set_parameter_property PERIOD_FNSEC IS_HDL_PARAMETER true
set_parameter_property PERIOD_FNSEC ALLOWED_RANGES 0:65535
set_parameter_property PERIOD_FNSEC ENABLED true
# | 
# +-----------------------------------



# +-----------------------------------
# | connection point clk_master
# | 
add_interface clk_master clock end

set_interface_property clk_master ENABLED true

add_interface_port clk_master clk_master clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset_master
# | 
add_interface reset_master reset end
set_interface_property reset_master associatedClock clk_master

set_interface_property reset_master ENABLED true

add_interface_port reset_master reset_master reset Input 1
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point clk_slave
# | 
add_interface clk_slave clock end

set_interface_property clk_slave ENABLED true

add_interface_port clk_slave clk_slave clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset_slave
# | 
add_interface reset_slave reset end
set_interface_property reset_slave associatedClock clk_slave

set_interface_property reset_slave ENABLED true

add_interface_port reset_slave reset_slave reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_sampling
# | 
add_interface clk_sampling clock end

set_interface_property clk_sampling ENABLED true

add_interface_port clk_sampling clk_sampling clk Input 1


# +-----------------------------------
# | connection point start_tod_sync
# | 
add_interface start_tod_sync conduit end
set_interface_assignment start_tod_sync "ui.blockdiagram.direction" Input
set_interface_property start_tod_sync ENABLED true

add_interface_port start_tod_sync start_tod_sync data Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tod_master_data
# | 
add_interface tod_master_data conduit end
set_interface_assignment tod_master_data "ui.blockdiagram.direction" Input
set_interface_property tod_master_data ENABLED true

add_interface_port tod_master_data tod_master_data data Input 96
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point tod_slave_data
# | 
add_interface tod_slave_data conduit start
set_interface_assignment tod_slave_data "ui.blockdiagram.direction" Output
set_interface_property tod_slave_data ENABLED true

add_interface_port tod_slave_data tod_slave_data data Output 96
add_interface_port tod_slave_data tod_slave_valid valid Output 1
# | 
# +-----------------------------------


