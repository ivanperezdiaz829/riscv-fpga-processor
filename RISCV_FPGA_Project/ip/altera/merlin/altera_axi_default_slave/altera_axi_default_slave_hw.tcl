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
# | request TCL package 
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_axi_default_slave
# | 
set_module_property DESCRIPTION "AXI Default Slave"
set_module_property NAME altera_axi_default_slave
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Qsys Interconnect/AXI Interface"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "AXI Default Slave"
set_module_property TOP_LEVEL_HDL_FILE altera_axi_default_slave.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_axi_default_slave
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property FIX_110_VIP_PATH false
# | 
# +-----------------------------------
# +-----------------------------------
# | files
# | 
add_file altera_axi_default_slave.sv {SYNTHESIS SIMULATION}
add_file altera_axi_default_slave_resp_logic.sv {SYNTHESIS SIMULATION}
add_file altera_axi_default_slave_reg_fifo.sv {SYNTHESIS SIMULATION}
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
add_parameter AXI_ID_W INTEGER 4
set_parameter_property AXI_ID_W DEFAULT_VALUE 1
set_parameter_property AXI_ID_W DISPLAY_NAME "AXI master ID width"
set_parameter_property AXI_ID_W TYPE INTEGER
set_parameter_property AXI_ID_W UNITS None
set_parameter_property AXI_ID_W DESCRIPTION "AXI ID width that is logged if CSR is enabled"
set_parameter_property AXI_ID_W AFFECTS_ELABORATION true
set_parameter_property AXI_ID_W HDL_PARAMETER true

add_parameter AXI_ADDR_W INTEGER 32
set_parameter_property AXI_ADDR_W DEFAULT_VALUE 8
set_parameter_property AXI_ADDR_W DISPLAY_NAME "AXI address width"
set_parameter_property AXI_ADDR_W TYPE INTEGER
set_parameter_property AXI_ADDR_W UNITS None
set_parameter_property AXI_ADDR_W DESCRIPTION "AXI address width that is logged if CSR is enabled"
set_parameter_property AXI_ADDR_W AFFECTS_ELABORATION true
set_parameter_property AXI_ADDR_W HDL_PARAMETER true
set_parameter_property AXI_ADDR_W ALLOWED_RANGES { 8:64 }

add_parameter AXI_DATA_W INTEGER 32
set_parameter_property AXI_DATA_W DEFAULT_VALUE 32
set_parameter_property AXI_DATA_W DISPLAY_NAME "AXI data width"
set_parameter_property AXI_DATA_W TYPE INTEGER
set_parameter_property AXI_DATA_W UNITS None
set_parameter_property AXI_DATA_W DESCRIPTION "AXI data width that is logged if CSR is enabled. Set this to match system data width to avoid unncessary width adaption in the system"
set_parameter_property AXI_DATA_W AFFECTS_ELABORATION true
set_parameter_property AXI_DATA_W HDL_PARAMETER true
set_parameter_property AXI_DATA_W ALLOWED_RANGES { 32 64 128 }

add_parameter SUPPORT_CSR INTEGER 1
set_parameter_property SUPPORT_CSR DEFAULT_VALUE 0
set_parameter_property SUPPORT_CSR DISPLAY_NAME "Enable CSR Support (for error logging)"
set_parameter_property SUPPORT_CSR TYPE INTEGER
set_parameter_property SUPPORT_CSR UNITS None
set_parameter_property SUPPORT_CSR DESCRIPTION "Controls whether a CSR register will be instantiated with this block"
set_parameter_property SUPPORT_CSR AFFECTS_ELABORATION true
set_parameter_property SUPPORT_CSR HDL_PARAMETER true
set_parameter_property SUPPORT_CSR DISPLAY_HINT "boolean"

add_parameter LOG_CSR_DEPTH INTEGER 8
set_parameter_property LOG_CSR_DEPTH DEFAULT_VALUE 1
set_parameter_property LOG_CSR_DEPTH DISPLAY_NAME "CSR Error Log Depth"
set_parameter_property LOG_CSR_DEPTH TYPE INTEGER
set_parameter_property LOG_CSR_DEPTH UNITS None
set_parameter_property LOG_CSR_DEPTH DESCRIPTION "Control the number of transactions logged in the CSR"
set_parameter_property LOG_CSR_DEPTH AFFECTS_ELABORATION true
set_parameter_property LOG_CSR_DEPTH HDL_PARAMETER true
set_parameter_property LOG_CSR_DEPTH ALLOWED_RANGES { 1:64 }

add_parameter REGISTER_AV_INPUTS INTEGER 1
set_parameter_property REGISTER_AV_INPUTS DEFAULT_VALUE 0
set_parameter_property REGISTER_AV_INPUTS DISPLAY_NAME "Register Avalon CSR inputs"
set_parameter_property REGISTER_AV_INPUTS TYPE INTEGER
set_parameter_property REGISTER_AV_INPUTS UNITS None
set_parameter_property REGISTER_AV_INPUTS DESCRIPTION "Controls if Avalon CSR input signals are registered directly"
set_parameter_property REGISTER_AV_INPUTS AFFECTS_ELABORATION true
set_parameter_property REGISTER_AV_INPUTS HDL_PARAMETER true
set_parameter_property REGISTER_AV_INPUTS DISPLAY_HINT "boolean"

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 

add_display_item "AXI Interface " AXI_ID_W PARAMETER ""
add_display_item "AXI Interface " AXI_ADDR_W PARAMETER ""
add_display_item "AXI Interface " AXI_DATA_W PARAMETER ""
add_display_item "Default Slave Capability" SUPPORT_CSR PARAMETER ""
add_display_item "CSR Settings" LOG_CSR_DEPTH PARAMETER ""
add_display_item "CSR Settings" REGISTER_AV_INPUTS PARAMETER ""
add_display_item "Default Slave Capability" "CSR Settings" group

set_display_item_property "CSR Settings" VISIBLE 0


# | 
# +-----------------------------------


# +-----------------------------------
# | connection point clk
# | 
add_interface           clk clock end
set_interface_property  clk clockRate 0

set_interface_property clk ENABLED true

add_interface_port clk aclk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_reset
# | 
add_interface           clk_reset reset end
set_interface_property  clk_reset associatedClock clk
set_interface_property  clk_reset synchronousEdges DEASSERT

set_interface_property clk_reset ENABLED true

add_interface_port  clk_reset aresetn reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set addr_width  [ get_parameter_value AXI_ADDR_W ]
    set id_width    [ get_parameter_value AXI_ID_W ]
    set data_width  [ get_parameter_value AXI_DATA_W ]
    set support_csr [ get_parameter_value SUPPORT_CSR ]
    set register_av_inputs [ get_parameter_value REGISTER_AV_INPUTS ]

    # AXI Slave Interface
    add_interface axi_error_if axi slave
    set_interface_property axi_error_if associatedClock                 clk
    set_interface_property axi_error_if associatedReset                 clk_reset
    set_interface_property axi_error_if readAcceptanceCapability        1
    set_interface_property axi_error_if writeAcceptanceCapability       1
    set_interface_property axi_error_if combinedAcceptanceCapability    1
    set_interface_property axi_error_if readDataReorderingDepth         1
    set_interface_property axi_error_if ENABLED                         true

    add_interface_port axi_error_if awid    awid    Input   $id_width
    add_interface_port axi_error_if awaddr  awaddr  Input   $addr_width
    add_interface_port axi_error_if awlen   awlen   Input   4
    add_interface_port axi_error_if awsize  awsize  Input   3
    add_interface_port axi_error_if awburst awburst Input   2
    add_interface_port axi_error_if awlock  awlock  Input   2
    add_interface_port axi_error_if awcache awcache Input   4
    add_interface_port axi_error_if awprot  awprot  Input   3
    add_interface_port axi_error_if awvalid awvalid Input   1
    add_interface_port axi_error_if awready awready Output  1
    add_interface_port axi_error_if wid     wid     Input   $id_width
    add_interface_port axi_error_if wdata   wdata   Input   $data_width
    add_interface_port axi_error_if wstrb   wstrb   Input   ($data_width/8)
    add_interface_port axi_error_if wlast   wlast   Input   1
    add_interface_port axi_error_if wvalid  wvalid  Input   1
    add_interface_port axi_error_if wready  wready  Output  1
    add_interface_port axi_error_if bid     bid     Output  $id_width
    add_interface_port axi_error_if bresp   bresp   Output  2
    add_interface_port axi_error_if bvalid  bvalid  Output  1
    add_interface_port axi_error_if bready  bready  Input   1
    add_interface_port axi_error_if arid    arid    Input   $id_width
    add_interface_port axi_error_if araddr  araddr  Input   $addr_width
    add_interface_port axi_error_if arlen   arlen   Input   4
    add_interface_port axi_error_if arsize  arsize  Input   3
    add_interface_port axi_error_if arburst arburst Input   2
    add_interface_port axi_error_if arlock  arlock  Input   2
    add_interface_port axi_error_if arcache arcache Input   4
    add_interface_port axi_error_if arprot  arprot  Input   3
    add_interface_port axi_error_if arvalid arvalid Input   1
    add_interface_port axi_error_if arready arready Output  1
    add_interface_port axi_error_if rid     rid     Output  $id_width
    add_interface_port axi_error_if rdata   rdata   Output  $data_width
    add_interface_port axi_error_if rresp   rresp   Output  2
    add_interface_port axi_error_if rlast   rlast   Output  1
    add_interface_port axi_error_if rvalid  rvalid  Output  1
    add_interface_port axi_error_if rready  rready  Input   1

    if { $support_csr == 1 } {

    # Avalon CSR Slave Interface
    set read_latency [ expr $register_av_inputs + 1 ]
    add_interface debug_csr avalon end
    set_interface_property debug_csr addressAlignment DYNAMIC
    set_interface_property debug_csr bridgesToMaster ""
    set_interface_property debug_csr burstOnBurstBoundariesOnly false
    set_interface_property debug_csr holdTime 0
    set_interface_property debug_csr isMemoryDevice false
    set_interface_property debug_csr isNonVolatileStorage false
    set_interface_property debug_csr linewrapBursts false
    set_interface_property debug_csr maximumPendingReadTransactions 0
    set_interface_property debug_csr minimumUninterruptedRunLength 1
    set_interface_property debug_csr printableDevice false
    set_interface_property debug_csr readLatency $read_latency
    set_interface_property debug_csr readWaitTime 0
    set_interface_property debug_csr setupTime 0
    set_interface_property debug_csr timingUnits Cycles
    set_interface_property debug_csr writeWaitTime 0
    set_interface_property debug_csr constantBurstBehavior false
    set_interface_property debug_csr burstcountUnits SYMBOLS
    set_interface_property debug_csr addressUnits SYMBOLS

    set_interface_property debug_csr associatedClock                 clk
    set_interface_property debug_csr associatedReset                 clk_reset

    add_interface_port debug_csr av_address       address     Input   12
    add_interface_port debug_csr av_debugaccess   debugaccess Input   1
    add_interface_port debug_csr av_readdata      readdata    Output  32
    add_interface_port debug_csr av_read          read        Input   1
    add_interface_port debug_csr av_writedata     writedata   Input   32
    add_interface_port debug_csr av_write         write       Input   1

    }

    ## IRQ sender
    if { $support_csr == 1 } {
                add_interface           debug_csr_irq interrupt sender clk
                set_interface_property  debug_csr_irq associatedAddressablePoint av
                set_interface_property  debug_csr_irq associatedClock clk
                set_interface_property  debug_csr_irq associatedReset clk_reset
                add_interface_port      debug_csr_irq irq irq output 1
    }

    set_display_item_property "CSR Settings" VISIBLE $support_csr

    set_flow_assignments
}

proc set_flow_assignments { } {
	set_interface_assignment axi_error_if   merlin.flow.altera_axi_slave altera_axi_slave 
    set_interface_assignment debug_csr      merlin.flow.av      av
}
