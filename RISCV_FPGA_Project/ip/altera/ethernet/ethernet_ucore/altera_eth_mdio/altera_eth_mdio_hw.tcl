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
# | module mdio
# | 
set_module_property DESCRIPTION "Altera Ethernet MDIO"
set_module_property NAME altera_eth_mdio
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DISPLAY_NAME "Ethernet MDIO"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_mdio.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_mdio
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property VALIDATION_CALLBACK validate
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_mdio.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter MDC_DIVISOR INTEGER 32 ""
set_parameter_property MDC_DIVISOR DISPLAY_NAME MDC_DIVISOR
set_parameter_property MDC_DIVISOR ENABLED true
set_parameter_property MDC_DIVISOR UNITS None
set_parameter_property MDC_DIVISOR ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MDC_DIVISOR DESCRIPTION "Host Clock Divisor"
set_parameter_property MDC_DIVISOR DISPLAY_HINT ""
set_parameter_property MDC_DIVISOR AFFECTS_GENERATION false
set_parameter_property MDC_DIVISOR HDL_PARAMETER true

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end
set_interface_property clock ptfSchematicName ""

set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1
add_interface_port clock reset reset Input 1
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
set_interface_property csr readLatency 0
set_interface_property csr readWaitTime 1
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr ASSOCIATED_CLOCK clock
set_interface_property csr ENABLED true

add_interface_port csr csr_write write Input 1
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_address address Input 6
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_waitrequest waitrequest Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point MDIO out
# | 
add_interface "mdio" conduit end

set_interface_property "mdio" ENABLED true

add_interface_port "mdio" mdc export Output 1
add_interface_port "mdio" mdio_in export Input 1
add_interface_port "mdio" mdio_out export Output 1
add_interface_port "mdio" mdio_oen export Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Validate
# | 
proc validate {} {
    
    #  Parameters
    #---------------------------------------------------------------------
    set MDC_DIVISOR [ get_parameter_value MDC_DIVISOR ]
    
    #  Validation
    #---------------------------------------------------------------------
    if { $MDC_DIVISOR < 8 } {
        send_message error "MDC_DIVISOR must be greater than 8"
    }

}
# | 
# +-----------------------------------

