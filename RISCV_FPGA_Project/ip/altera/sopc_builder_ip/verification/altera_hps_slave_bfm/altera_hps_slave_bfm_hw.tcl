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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_hps_slave_bfm/altera_hps_slave_bfm_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | request TCL package 
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | 
set_module_property DESCRIPTION "Altera HPS Slave BFM"
set_module_property NAME altera_hps_slave_bfm
set_module_property VERSION 11.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Simulation"
set_module_property DISPLAY_NAME "Altera HPS Slave BFM"
set_module_property TOP_LEVEL_HDL_FILE altera_hps_slave_bfm.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_hps_slave_bfm
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property HIDE_FROM_QSYS true
set_module_property ANALYZE_HDL false

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
set HDL_LIB_DIR "../lib"

add_file $HDL_LIB_DIR/verbosity_pkg.sv {SIMULATION}
add_file $HDL_LIB_DIR/avalon_utilities_pkg.sv {SIMULATION}
add_file $HDL_LIB_DIR/altera_hps_pkg.sv {SIMULATION}
add_file "../altera_avalon_st_sink_bfm/altera_avalon_st_sink_bfm.sv" {SIMULATION}
add_file "../altera_avalon_st_source_bfm/altera_avalon_st_source_bfm.sv" {SIMULATION}
add_file $HDL_LIB_DIR/altera_hps_monitor_bfm.sv {SIMULATION}
add_file altera_hps_slave_bfm.sv {SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | documentation links
# | 
# add_documentation_link Documents http:/www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

add_parameter ID_W INTEGER 4
set_parameter_property ID_W DEFAULT_VALUE 4
set_parameter_property ID_W DISPLAY_NAME "AXI ID width"
set_parameter_property ID_W TYPE INTEGER
set_parameter_property ID_W UNITS None
set_parameter_property ID_W DESCRIPTION "AXI ID width"
set_parameter_property ID_W AFFECTS_ELABORATION true
set_parameter_property ID_W HDL_PARAMETER true
set_parameter_property ID_W ALLOWED_RANGES {4:32}
add_parameter ADDR_W INTEGER 32
set_parameter_property ADDR_W DEFAULT_VALUE 32
set_parameter_property ADDR_W DISPLAY_NAME "AXI address width"
set_parameter_property ADDR_W TYPE INTEGER
set_parameter_property ADDR_W UNITS None
set_parameter_property ADDR_W DESCRIPTION "AXI address width"
set_parameter_property ADDR_W AFFECTS_ELABORATION true
set_parameter_property ADDR_W HDL_PARAMETER true
# set_parameter_property ADDR_W ALLOWED_RANGES {32:1024}
add_parameter RDATA_W INTEGER 32
set_parameter_property RDATA_W DEFAULT_VALUE 32
set_parameter_property RDATA_W DISPLAY_NAME "AXI read data width"
set_parameter_property RDATA_W TYPE INTEGER
set_parameter_property RDATA_W UNITS None
set_parameter_property RDATA_W DESCRIPTION "AXI read data width"
set_parameter_property RDATA_W AFFECTS_ELABORATION true
set_parameter_property RDATA_W HDL_PARAMETER true
set_parameter_property RDATA_W ALLOWED_RANGES {8 16 32 64 128 256 512 1024}
add_parameter WDATA_W INTEGER 32
set_parameter_property WDATA_W DEFAULT_VALUE 32
set_parameter_property WDATA_W DISPLAY_NAME "AXI write data width"
set_parameter_property WDATA_W TYPE INTEGER
set_parameter_property WDATA_W UNITS None
set_parameter_property WDATA_W DESCRIPTION "AXI write data width"
set_parameter_property WDATA_W AFFECTS_ELABORATION true
set_parameter_property WDATA_W HDL_PARAMETER true
set_parameter_property WDATA_W ALLOWED_RANGES {8 16 32 64 128 256 512 1024}
add_parameter MAX_OUTSTANDING_READS INTEGER 8
set_parameter_property MAX_OUTSTANDING_READS DEFAULT_VALUE 8
set_parameter_property MAX_OUTSTANDING_READS DISPLAY_NAME "Maximum Outstanding Reads"
set_parameter_property MAX_OUTSTANDING_READS TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_READS UNITS None
set_parameter_property MAX_OUTSTANDING_READS DESCRIPTION "Maximum Number of Outstanding Reads"
set_parameter_property MAX_OUTSTANDING_READS AFFECTS_ELABORATION true
set_parameter_property MAX_OUTSTANDING_READS HDL_PARAMETER true
set_parameter_property MAX_OUTSTANDING_READS ALLOWED_RANGES {1:8}
add_parameter MAX_OUTSTANDING_WRITES INTEGER 8
set_parameter_property MAX_OUTSTANDING_WRITES DEFAULT_VALUE 8
set_parameter_property MAX_OUTSTANDING_WRITES DISPLAY_NAME "Maximum Outstanding Writes"
set_parameter_property MAX_OUTSTANDING_WRITES TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_WRITES UNITS None
set_parameter_property MAX_OUTSTANDING_WRITES DESCRIPTION "Maximum Number of Outstanding Writes"
set_parameter_property MAX_OUTSTANDING_WRITES AFFECTS_ELABORATION true
set_parameter_property MAX_OUTSTANDING_WRITES HDL_PARAMETER true
set_parameter_property MAX_OUTSTANDING_WRITES ALLOWED_RANGES {1:8}
add_parameter MAX_OUTSTANDING_TRANSACTIONS INTEGER 16
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS DEFAULT_VALUE 16
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS DISPLAY_NAME "Maximum Outstanding Transactions"
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS UNITS None
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS DESCRIPTION "Maximum Number of Outstanding Transactions"
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS AFFECTS_ELABORATION true
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS HDL_PARAMETER true
set_parameter_property MAX_OUTSTANDING_TRANSACTIONS ALLOWED_RANGES {1:16}
add_parameter ENABLE_AUTO_BACKPRESSURE INTEGER 1
set_parameter_property ENABLE_AUTO_BACKPRESSURE DEFAULT_VALUE 0
set_parameter_property ENABLE_AUTO_BACKPRESSURE DISPLAY_NAME "Enable Auto Backpressure"
set_parameter_property ENABLE_AUTO_BACKPRESSURE DISPLAY_HINT boolean
set_parameter_property ENABLE_AUTO_BACKPRESSURE TYPE INTEGER
set_parameter_property ENABLE_AUTO_BACKPRESSURE UNITS None
set_parameter_property ENABLE_AUTO_BACKPRESSURE DESCRIPTION "Enable Auto Backpressure when Reach Maximum Number of Outstanding Reads/Writes/Transactions"
set_parameter_property ENABLE_AUTO_BACKPRESSURE AFFECTS_ELABORATION true
set_parameter_property ENABLE_AUTO_BACKPRESSURE HDL_PARAMETER true
set_parameter_property ENABLE_AUTO_BACKPRESSURE ALLOWED_RANGES {0:1}

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
add_display_item "AXI Interface " ID_W PARAMETER ""
add_display_item "AXI Interface " ADDR_W PARAMETER ""
add_display_item "AXI Interface " RDATA_W PARAMETER ""
add_display_item "AXI Interface " WDATA_W PARAMETER ""
add_display_item "Miscellaneous " MAX_OUTSTANDING_READS PARAMETER ""
add_display_item "Miscellaneous " MAX_OUTSTANDING_WRITES PARAMETER ""
add_display_item "Miscellaneous " MAX_OUTSTANDING_TRANSACTIONS PARAMETER ""
add_display_item "Miscellaneous " ENABLE_AUTO_BACKPRESSURE PARAMETER ""
# | 
# +-----------------------------------


# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
 proc elaborate {} {

    set ID_W      [ get_parameter_value ID_W ]
    set WDATA_W   [ get_parameter_value WDATA_W ]
    set RDATA_W   [ get_parameter_value RDATA_W ]
    set ADDR_W    [ get_parameter_value ADDR_W ]
    set MAX_OUTSTANDING_READS    [ get_parameter_value MAX_OUTSTANDING_READS ]
    set MAX_OUTSTANDING_WRITES    [ get_parameter_value MAX_OUTSTANDING_WRITES ]
    set MAX_OUTSTANDING_TRANSACTIONS    [ get_parameter_value MAX_OUTSTANDING_TRANSACTIONS ]
    
    if { [expr [get_parameter_value WDATA_W] % 8] == 0 } {
      set WSTRB_W   [ expr [get_parameter_value WDATA_W] >> 3]
    } else {
      set WSTRB_W   [expr [ expr [get_parameter_value WDATA_W] >> 3] + 1]
    }
    
# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
add_interface_port clk ACLK clk Input 1

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_reset
# | 
add_interface clk_reset reset end
set_interface_property clk_reset associatedClock clk
set_interface_property clk_reset ENABLED true
add_interface_port clk_reset ARESETn reset_n Input 1

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point altera_axi_slave
# | 
add_interface altera_axi_slave axi end
set_interface_property altera_axi_slave associatedClock clk
set_interface_property altera_axi_slave associatedReset clk_reset
set_interface_property altera_axi_slave readAcceptanceCapability $MAX_OUTSTANDING_READS
set_interface_property altera_axi_slave writeAcceptanceCapability $MAX_OUTSTANDING_WRITES
set_interface_property altera_axi_slave combinedAcceptanceCapability $MAX_OUTSTANDING_TRANSACTIONS

set_interface_property altera_axi_slave ENABLED true

add_interface_port altera_axi_slave AWID awid Input $ID_W
add_interface_port altera_axi_slave AWADDR awaddr Input $ADDR_W
add_interface_port altera_axi_slave AWLEN awlen Input 4
add_interface_port altera_axi_slave AWSIZE awsize Input 3
add_interface_port altera_axi_slave AWBURST awburst Input 2
add_interface_port altera_axi_slave AWLOCK awlock Input 2
add_interface_port altera_axi_slave AWCACHE awcache Input 4
add_interface_port altera_axi_slave AWPROT awprot Input 3
add_interface_port altera_axi_slave AWVALID awvalid Input 1
add_interface_port altera_axi_slave AWREADY awready Output 1
add_interface_port altera_axi_slave AWUSER awuser Input 5
add_interface_port altera_axi_slave WID wid Input $ID_W
add_interface_port altera_axi_slave WDATA wdata Input $WDATA_W
add_interface_port altera_axi_slave WSTRB wstrb Input $WSTRB_W
add_interface_port altera_axi_slave WLAST wlast Input 1
add_interface_port altera_axi_slave WVALID wvalid Input 1
add_interface_port altera_axi_slave WREADY wready Output 1
add_interface_port altera_axi_slave BID bid Output $ID_W
add_interface_port altera_axi_slave BRESP bresp Output 2
add_interface_port altera_axi_slave BVALID bvalid Output 1
add_interface_port altera_axi_slave BREADY bready Input 1
add_interface_port altera_axi_slave ARID arid Input $ID_W
add_interface_port altera_axi_slave ARADDR araddr Input $ADDR_W
add_interface_port altera_axi_slave ARLEN arlen Input 4
add_interface_port altera_axi_slave ARSIZE arsize Input 3
add_interface_port altera_axi_slave ARBURST arburst Input 2
add_interface_port altera_axi_slave ARLOCK arlock Input 2
add_interface_port altera_axi_slave ARCACHE arcache Input 4
add_interface_port altera_axi_slave ARPROT arprot Input 3
add_interface_port altera_axi_slave ARVALID arvalid Input 1
add_interface_port altera_axi_slave ARREADY arready Output 1
add_interface_port altera_axi_slave ARUSER aruser Input 5
add_interface_port altera_axi_slave RID rid Output $ID_W
add_interface_port altera_axi_slave RDATA rdata Output $RDATA_W
add_interface_port altera_axi_slave RRESP rresp Output 2
add_interface_port altera_axi_slave RLAST rlast Output 1
add_interface_port altera_axi_slave RVALID rvalid Output 1
add_interface_port altera_axi_slave RREADY rready Input 1
# | 
# +-----------------------------------

}
