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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_axi_bridge/axi_interface.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# contain proc to add AXI3/4 master/slave interface
proc add_axi3_slave_interface { name } {
    add_interface $name axi end
    set_interface_property $name associatedClock clk
    set_interface_property $name associatedReset clk_reset
    set_interface_property $name readAcceptanceCapability 1
    set_interface_property $name writeAcceptanceCapability 1
    set_interface_property $name combinedAcceptanceCapability 1
    set_interface_property $name readDataReorderingDepth 1
    set_interface_property $name ENABLED true

    add_interface_port $name ${name}_awid awid Input 4
    add_interface_port $name ${name}_awaddr awaddr Input 32
    add_interface_port $name ${name}_awlen awlen Input 4
    add_interface_port $name ${name}_awsize awsize Input 3
    add_interface_port $name ${name}_awburst awburst Input 2
    add_interface_port $name ${name}_awlock awlock Input 2
    add_interface_port $name ${name}_awcache awcache Input 4
    add_interface_port $name ${name}_awprot awprot Input 3
    add_interface_port $name ${name}_awuser awuser Input 5
    add_interface_port $name ${name}_awvalid awvalid Input 1
    add_interface_port $name ${name}_awready awready Output 1
    add_interface_port $name ${name}_wid wid Input 4
    add_interface_port $name ${name}_wdata wdata Input 32
    add_interface_port $name ${name}_wstrb wstrb Input 4
    add_interface_port $name ${name}_wlast wlast Input 1
    add_interface_port $name ${name}_wvalid wvalid Input 1
    add_interface_port $name ${name}_wready wready Output 1
    add_interface_port $name ${name}_bid bid Output 4
    add_interface_port $name ${name}_bresp bresp Output 2
    add_interface_port $name ${name}_bvalid bvalid Output 1
    add_interface_port $name ${name}_bready bready Input 1
    add_interface_port $name ${name}_arid arid Input 4
    add_interface_port $name ${name}_araddr araddr Input 32
    add_interface_port $name ${name}_arlen arlen Input 4
    add_interface_port $name ${name}_arsize arsize Input 3
    add_interface_port $name ${name}_arburst arburst Input 2
    add_interface_port $name ${name}_arlock arlock Input 2
    add_interface_port $name ${name}_arcache arcache Input 4
    add_interface_port $name ${name}_arprot arprot Input 3
    add_interface_port $name ${name}_aruser aruser Input 5
    add_interface_port $name ${name}_arvalid arvalid Input 1
    add_interface_port $name ${name}_arready arready Output 1
    add_interface_port $name ${name}_rid rid Output 4
    add_interface_port $name ${name}_rdata rdata Output 32
    add_interface_port $name ${name}_rresp rresp Output 2
    add_interface_port $name ${name}_rlast rlast Output 1
    add_interface_port $name ${name}_rvalid rvalid Output 1
    add_interface_port $name ${name}_rready rready Input 1
}

proc add_axi3_master_interface { name } {
    add_interface $name axi start
    set_interface_property $name associatedClock clk
    set_interface_property $name associatedReset clk_reset
    set_interface_property $name readIssuingCapability 1
    set_interface_property $name writeIssuingCapability 1
    set_interface_property $name combinedIssuingCapability 1
    set_interface_property $name ENABLED true

    add_interface_port $name ${name}_awid awid Output 4
    add_interface_port $name ${name}_awaddr awaddr Output 32
    add_interface_port $name ${name}_awlen awlen Output 4
    add_interface_port $name ${name}_awsize awsize Output 3
    add_interface_port $name ${name}_awburst awburst Output 2
    add_interface_port $name ${name}_awlock awlock Output 2
    add_interface_port $name ${name}_awcache awcache Output 4
    add_interface_port $name ${name}_awprot awprot Output 3
    add_interface_port $name ${name}_awuser awuser Output 5
    add_interface_port $name ${name}_awvalid awvalid Output 1
    add_interface_port $name ${name}_awready awready Input 1
    add_interface_port $name ${name}_wid wid Output 4
    add_interface_port $name ${name}_wdata wdata Output 32
    add_interface_port $name ${name}_wstrb wstrb Output 4
    add_interface_port $name ${name}_wlast wlast Output 1
    add_interface_port $name ${name}_wvalid wvalid Output 1
    add_interface_port $name ${name}_wready wready Input 1
    add_interface_port $name ${name}_bid bid Input 4
    add_interface_port $name ${name}_bresp bresp Input 2
    add_interface_port $name ${name}_bvalid bvalid Input 1
    add_interface_port $name ${name}_bready bready Output 1
    add_interface_port $name ${name}_arid arid Output 4
    add_interface_port $name ${name}_araddr araddr Output 32
    add_interface_port $name ${name}_arlen arlen Output 4
    add_interface_port $name ${name}_arsize arsize Output 3
    add_interface_port $name ${name}_arburst arburst Output 2
    add_interface_port $name ${name}_arlock arlock Output 2
    add_interface_port $name ${name}_arcache arcache Output 4
    add_interface_port $name ${name}_arprot arprot Output 3
    add_interface_port $name ${name}_aruser aruser Output 5
    add_interface_port $name ${name}_arvalid arvalid Output 1
    add_interface_port $name ${name}_arready arready Input 1
    add_interface_port $name ${name}_rid rid Input 4
    add_interface_port $name ${name}_rdata rdata Input 32
    add_interface_port $name ${name}_rresp rresp Input 2
    add_interface_port $name ${name}_rlast rlast Input 1
    add_interface_port $name ${name}_rvalid rvalid Input 1
    add_interface_port $name ${name}_rready rready Output 1
}

proc add_axi4_slave_interface { name } {
    add_interface $name axi4 end
    set_interface_property $name associatedClock clk
    set_interface_property $name associatedReset clk_reset
    set_interface_property $name readAcceptanceCapability 1
    set_interface_property $name writeAcceptanceCapability 1
    set_interface_property $name combinedAcceptanceCapability 1
    set_interface_property $name readDataReorderingDepth 1
    set_interface_property $name ENABLED true
    add_interface_port $name ${name}_awid awid Input 4
    add_interface_port $name ${name}_awaddr awaddr Input 32
    add_interface_port $name ${name}_awlen awlen Input 8
    add_interface_port $name ${name}_awsize awsize Input 3
    add_interface_port $name ${name}_awburst awburst Input 2
    add_interface_port $name ${name}_awlock awlock Input 1
    add_interface_port $name ${name}_awcache awcache Input 4
    add_interface_port $name ${name}_awprot awprot Input 3
    add_interface_port $name ${name}_awuser awuser Input 5
    add_interface_port $name ${name}_awqos awqos   Input 4
    add_interface_port $name ${name}_awregion awregion Input 4
    add_interface_port $name ${name}_awvalid awvalid Input 1
    add_interface_port $name ${name}_awready awready Output 1
    add_interface_port $name ${name}_wdata wdata Input 32
    add_interface_port $name ${name}_wstrb wstrb Input 4
    add_interface_port $name ${name}_wlast wlast Input 1
    add_interface_port $name ${name}_wvalid wvalid Input 1
    add_interface_port $name ${name}_wuser wuser Input 8
    add_interface_port $name ${name}_wready wready Output 1
    add_interface_port $name ${name}_bid bid Output 4
    add_interface_port $name ${name}_bresp bresp Output 2
    add_interface_port $name ${name}_buser buser Output 8
    add_interface_port $name ${name}_bvalid bvalid Output 1
    add_interface_port $name ${name}_bready bready Input 1
    add_interface_port $name ${name}_arid arid Input 4
    add_interface_port $name ${name}_araddr araddr Input 32
    add_interface_port $name ${name}_arlen arlen Input 8
    add_interface_port $name ${name}_arsize arsize Input 3
    add_interface_port $name ${name}_arburst arburst Input 2
    add_interface_port $name ${name}_arlock arlock Input 1
    add_interface_port $name ${name}_arcache arcache Input 4
    add_interface_port $name ${name}_arprot arprot Input 3
    add_interface_port $name ${name}_aruser aruser Input 5
    add_interface_port $name ${name}_arqos arqos   Input 4
    add_interface_port $name ${name}_arregion arregion Input 4
    add_interface_port $name ${name}_arvalid arvalid Input 1
    add_interface_port $name ${name}_arready arready Output 1
    add_interface_port $name ${name}_rid rid Output 4
    add_interface_port $name ${name}_rdata rdata Output 32
    add_interface_port $name ${name}_rresp rresp Output 2
    add_interface_port $name ${name}_rlast rlast Output 1
    add_interface_port $name ${name}_rvalid rvalid Output 1
    add_interface_port $name ${name}_rready rready Input 1
    add_interface_port $name ${name}_ruser ruser Output 8
}

proc add_axi4_master_interface { name } {
    add_interface $name axi4 start
    set_interface_property $name associatedClock clk
    set_interface_property $name associatedReset clk_reset
    set_interface_property $name readIssuingCapability 1
    set_interface_property $name writeIssuingCapability 1
    set_interface_property $name combinedIssuingCapability 1
    set_interface_property $name ENABLED true

    add_interface_port $name ${name}_awid awid Output 4
    add_interface_port $name ${name}_awaddr awaddr Output 32
    add_interface_port $name ${name}_awlen awlen Output 8
    add_interface_port $name ${name}_awsize awsize Output 3
    add_interface_port $name ${name}_awburst awburst Output 2
    add_interface_port $name ${name}_awlock awlock Output 1
    add_interface_port $name ${name}_awcache awcache Output 4
    add_interface_port $name ${name}_awprot awprot Output 3
    add_interface_port $name ${name}_awuser awuser Output 5
    add_interface_port $name ${name}_awqos awqos   Output 4
    add_interface_port $name ${name}_awregion awregion Output 4
    add_interface_port $name ${name}_awvalid awvalid Output 1
    add_interface_port $name ${name}_awready awready Input 1
    add_interface_port $name ${name}_wdata wdata Output 32
    add_interface_port $name ${name}_wstrb wstrb Output 4
    add_interface_port $name ${name}_wlast wlast Output 1
    add_interface_port $name ${name}_wvalid wvalid Output 1
    add_interface_port $name ${name}_wuser wuser Output 8
    add_interface_port $name ${name}_wready wready Input 1
    add_interface_port $name ${name}_bid bid Input 4
    add_interface_port $name ${name}_bresp bresp Input 2
    add_interface_port $name ${name}_buser buser Input 8
    add_interface_port $name ${name}_bvalid bvalid Input 1
    add_interface_port $name ${name}_bready bready Output 1
    add_interface_port $name ${name}_arid arid Output 4
    add_interface_port $name ${name}_araddr araddr Output 32
    add_interface_port $name ${name}_arlen arlen Output 8
    add_interface_port $name ${name}_arsize arsize Output 3
    add_interface_port $name ${name}_arburst arburst Output 2
    add_interface_port $name ${name}_arlock arlock Output 1
    add_interface_port $name ${name}_arcache arcache Output 4
    add_interface_port $name ${name}_arprot arprot Output 3
    add_interface_port $name ${name}_aruser aruser Output 5
    add_interface_port $name ${name}_arqos arqos   Output 4
    add_interface_port $name ${name}_arregion arregion Output 4
    add_interface_port $name ${name}_arvalid arvalid Output 1
    add_interface_port $name ${name}_arready arready Input 1
    add_interface_port $name ${name}_rid rid Input 4
    add_interface_port $name ${name}_rdata rdata Input 32
    add_interface_port $name ${name}_rresp rresp Input 2
    add_interface_port $name ${name}_rlast rlast Input 1
    add_interface_port $name ${name}_rvalid rvalid Input 1
    add_interface_port $name ${name}_rready rready Output 1
    add_interface_port $name ${name}_ruser ruser Input 8
}

