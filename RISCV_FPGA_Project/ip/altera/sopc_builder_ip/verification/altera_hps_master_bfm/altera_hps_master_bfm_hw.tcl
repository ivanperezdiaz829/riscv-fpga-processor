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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_hps_master_bfm/altera_hps_master_bfm_hw.tcl#1 $
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
# | module altera_merlin_axi_master_ni
# | 
set_module_property DESCRIPTION "Altera HPS Master BFM"
set_module_property NAME altera_hps_master_bfm
set_module_property VERSION 11.1
set_module_property AUTHOR "Altera Corporation"
# set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Verification/Simulation"
set_module_property DISPLAY_NAME "Altera HPS Master BFM"
set_module_property TOP_LEVEL_HDL_FILE altera_hps_master_bfm.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_hps_master_bfm
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property HIDE_FROM_QSYS true
set_module_property ANALYZE_HDL false
# set_module_property FIX_110_VIP_PATH false
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
add_file altera_hps_master_bfm.sv {SIMULATION}
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

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
add_display_item "AXI Interface " ID_W PARAMETER ""
add_display_item "AXI Interface " ADDR_W PARAMETER ""
add_display_item "AXI Interface " RDATA_W PARAMETER ""
add_display_item "AXI Interface " WDATA_W PARAMETER ""
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
# | connection point altera_axi_master
# | 
add_interface altera_axi_master axi start
set_interface_property altera_axi_master associatedClock clk
set_interface_property altera_axi_master associatedReset clk_reset
set_interface_property altera_axi_master readIssuingCapability 8
set_interface_property altera_axi_master writeIssuingCapability 8
set_interface_property altera_axi_master combinedIssuingCapability 16

set_interface_property altera_axi_master ENABLED true

add_interface_port altera_axi_master AWID awid Output $ID_W
add_interface_port altera_axi_master AWADDR awaddr Output $ADDR_W
add_interface_port altera_axi_master AWLEN awlen Output 4
add_interface_port altera_axi_master AWSIZE awsize Output 3
add_interface_port altera_axi_master AWBURST awburst Output 2
add_interface_port altera_axi_master AWLOCK awlock Output 2
add_interface_port altera_axi_master AWCACHE awcache Output 4
add_interface_port altera_axi_master AWPROT awprot Output 3
add_interface_port altera_axi_master AWVALID awvalid Output 1
add_interface_port altera_axi_master AWREADY awready Input 1
add_interface_port altera_axi_master AWUSER awuser Output 5
add_interface_port altera_axi_master WID wid Output $ID_W
add_interface_port altera_axi_master WDATA wdata Output $WDATA_W
add_interface_port altera_axi_master WSTRB wstrb Output $WSTRB_W
add_interface_port altera_axi_master WLAST wlast Output 1
add_interface_port altera_axi_master WVALID wvalid Output 1
add_interface_port altera_axi_master WREADY wready Input 1
add_interface_port altera_axi_master BID bid Input $ID_W
add_interface_port altera_axi_master BRESP bresp Input 2
add_interface_port altera_axi_master BVALID bvalid Input 1
add_interface_port altera_axi_master BREADY bready Output 1
add_interface_port altera_axi_master ARID arid Output $ID_W
add_interface_port altera_axi_master ARADDR araddr Output $ADDR_W
add_interface_port altera_axi_master ARLEN arlen Output 4
add_interface_port altera_axi_master ARSIZE arsize Output 3
add_interface_port altera_axi_master ARBURST arburst Output 2
add_interface_port altera_axi_master ARLOCK arlock Output 2
add_interface_port altera_axi_master ARCACHE arcache Output 4
add_interface_port altera_axi_master ARPROT arprot Output 3
add_interface_port altera_axi_master ARVALID arvalid Output 1
add_interface_port altera_axi_master ARREADY arready Input 1
add_interface_port altera_axi_master ARUSER aruser Output 5
add_interface_port altera_axi_master RID rid Input $ID_W
add_interface_port altera_axi_master RDATA rdata Input $RDATA_W
add_interface_port altera_axi_master RRESP rresp Input 2
add_interface_port altera_axi_master RLAST rlast Input 1
add_interface_port altera_axi_master RVALID rvalid Input 1
add_interface_port altera_axi_master RREADY rready Output 1
# | 
# +-----------------------------------

}
