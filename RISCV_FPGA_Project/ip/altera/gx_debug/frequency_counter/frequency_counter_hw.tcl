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
# | module altera_avalon_data_pattern_checker
# | 
set_module_property DESCRIPTION "Frequency Counter"
set_module_property NAME frequency_counter 
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Peripherals/Debug and Performance"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Frequency Counter"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_embedded_ip.pdf
set_module_property TOP_LEVEL_HDL_FILE frequency_counter.v
set_module_property TOP_LEVEL_HDL_MODULE frequency_counter 
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file frequency_counter.v {SYNTHESIS SIMULATION}
add_file ../../merlin/altera_reset_controller/altera_reset_controller.v {SYNTHESIS SIMULATION}
add_file ../../merlin/altera_reset_controller/altera_reset_synchronizer.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter CROSS_CLK_SYNC_DEPTH INTEGER 2
set_parameter_property CROSS_CLK_SYNC_DEPTH ALLOWED_RANGES {2,3,4}
set_parameter_property CROSS_CLK_SYNC_DEPTH DISPLAY_NAME CROSS_CLK_SYNC_DEPTH
set_parameter_property CROSS_CLK_SYNC_DEPTH UNITS None
set_parameter_property CROSS_CLK_SYNC_DEPTH DISPLAY_HINT ""
set_parameter_property CROSS_CLK_SYNC_DEPTH AFFECTS_GENERATION true
set_parameter_property CROSS_CLK_SYNC_DEPTH IS_HDL_PARAMETER true

add_parameter REF_CLK_AVALON_ENABLED boolean 1 
set_parameter_property REF_CLK_AVALON_ENABLED DEFAULT_VALUE 1
set_parameter_property REF_CLK_AVALON_ENABLED DISPLAY_NAME REF_CLK_AVALON_ENABLED
set_parameter_property REF_CLK_AVALON_ENABLED UNITS None
set_parameter_property REF_CLK_AVALON_ENABLED DISPLAY_HINT ""
set_parameter_property REF_CLK_AVALON_ENABLED AFFECTS_GENERATION true
set_parameter_property REF_CLK_AVALON_ENABLED IS_HDL_PARAMETER false 

add_parameter DES_CLK_AVALON_ENABLED boolean 1 
set_parameter_property DES_CLK_AVALON_ENABLED DEFAULT_VALUE 1
set_parameter_property DES_CLK_AVALON_ENABLED DISPLAY_NAME DES_CLK_AVALON_ENABLED
set_parameter_property DES_CLK_AVALON_ENABLED UNITS None
set_parameter_property DES_CLK_AVALON_ENABLED DISPLAY_HINT ""
set_parameter_property DES_CLK_AVALON_ENABLED AFFECTS_GENERATION true
set_parameter_property DES_CLK_AVALON_ENABLED IS_HDL_PARAMETER false 

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_clk
# | 
add_interface csr_clk clock end
set_interface_property csr_clk ENABLED true
add_interface_port csr_clk avs_clk clk Input 1
add_interface_port csr_clk reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_slave
# | 
add_interface csr_slave avalon end
set_interface_property csr_slave addressAlignment DYNAMIC
set_interface_property csr_slave burstOnBurstBoundariesOnly false
set_interface_property csr_slave explicitAddressSpan 0
set_interface_property csr_slave holdTime 0
set_interface_property csr_slave isMemoryDevice false
set_interface_property csr_slave isNonVolatileStorage false
set_interface_property csr_slave linewrapBursts false
set_interface_property csr_slave maximumPendingReadTransactions 0
set_interface_property csr_slave printableDevice false
set_interface_property csr_slave readLatency 1
set_interface_property csr_slave readWaitTime 0
set_interface_property csr_slave setupTime 0
set_interface_property csr_slave timingUnits Cycles
set_interface_property csr_slave writeWaitTime 0
set_interface_property csr_slave ASSOCIATED_CLOCK csr_clk
set_interface_property csr_slave ENABLED true

add_interface_port csr_slave avs_address address Input 3
add_interface_port csr_slave avs_write write Input 1
add_interface_port csr_slave avs_read read Input 1
add_interface_port csr_slave avs_byteenable byteenable Input 4
add_interface_port csr_slave avs_writedata writedata Input 32
add_interface_port csr_slave avs_readdata readdata Output 32

# +-----------------------------------
# | elaboration callback
# | 
proc elaborate { } {

    set ref_avalon [get_parameter_value REF_CLK_AVALON_ENABLED]
    set des_avalon [get_parameter_value DES_CLK_AVALON_ENABLED]

    if { $ref_avalon == "true" } {
        add_interface avalon_ref_clk clock end
        set_interface_property avalon_ref_clk ENABLED $ref_avalon
        add_interface_port avalon_ref_clk ref_clk clk Input 1
    } else {
        add_interface conduit_ref_clk conduit end
        set_interface_property conduit_ref_clk ENABLED !$ref_avalon 
        add_interface_port conduit_ref_clk ref_clk export Input 1
    }

    if { $des_avalon == "true" } {
        add_interface avalon_des_clk clock end
        set_interface_property avalon_des_clk ENABLED $des_avalon
        add_interface_port avalon_des_clk des_clk clk Input 1
    } else {
        add_interface conduit_des_clk conduit end
        set_interface_property conduit_des_clk ENABLED !$des_avalon 
        add_interface_port conduit_des_clk des_clk export Input 1
    }
}
