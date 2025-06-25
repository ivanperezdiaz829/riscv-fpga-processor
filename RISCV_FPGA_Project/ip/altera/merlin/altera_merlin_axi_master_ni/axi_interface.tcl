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


proc add_axi3_interface { } {
    add_interface altera_axi_slave axi end
    set_interface_property altera_axi_slave associatedClock clk
    set_interface_property altera_axi_slave associatedReset clk_reset
    set_interface_property altera_axi_slave readAcceptanceCapability 1
    set_interface_property altera_axi_slave writeAcceptanceCapability 1
    set_interface_property altera_axi_slave combinedAcceptanceCapability 1
    set_interface_property altera_axi_slave readDataReorderingDepth 1
    set_interface_property altera_axi_slave ENABLED true

    add_interface_port altera_axi_slave awid awid Input 4
    add_interface_port altera_axi_slave awaddr awaddr Input 32
    add_interface_port altera_axi_slave awlen awlen Input 4
    add_interface_port altera_axi_slave awsize awsize Input 3
    add_interface_port altera_axi_slave awburst awburst Input 2
    add_interface_port altera_axi_slave awlock awlock Input 2
    add_interface_port altera_axi_slave awcache awcache Input 4
    add_interface_port altera_axi_slave awprot awprot Input 3
    add_interface_port altera_axi_slave awuser awuser Input 5
    add_interface_port altera_axi_slave awvalid awvalid Input 1
    add_interface_port altera_axi_slave awready awready Output 1
    add_interface_port altera_axi_slave wid wid Input 4
    add_interface_port altera_axi_slave wdata wdata Input 32
    add_interface_port altera_axi_slave wstrb wstrb Input 4
    add_interface_port altera_axi_slave wlast wlast Input 1
    add_interface_port altera_axi_slave wvalid wvalid Input 1
    add_interface_port altera_axi_slave wready wready Output 1
    add_interface_port altera_axi_slave bid bid Output 4
    add_interface_port altera_axi_slave bresp bresp Output 2
    add_interface_port altera_axi_slave bvalid bvalid Output 1
    add_interface_port altera_axi_slave bready bready Input 1
    add_interface_port altera_axi_slave arid arid Input 4
    add_interface_port altera_axi_slave araddr araddr Input 32
    add_interface_port altera_axi_slave arlen arlen Input 4
    add_interface_port altera_axi_slave arsize arsize Input 3
    add_interface_port altera_axi_slave arburst arburst Input 2
    add_interface_port altera_axi_slave arlock arlock Input 2
    add_interface_port altera_axi_slave arcache arcache Input 4
    add_interface_port altera_axi_slave arprot arprot Input 3
    add_interface_port altera_axi_slave aruser aruser Input 5
    add_interface_port altera_axi_slave arvalid arvalid Input 1
    add_interface_port altera_axi_slave arready arready Output 1
    add_interface_port altera_axi_slave rid rid Output 4
    add_interface_port altera_axi_slave rdata rdata Output 32
    add_interface_port altera_axi_slave rresp rresp Output 2
    add_interface_port altera_axi_slave rlast rlast Output 1
    add_interface_port altera_axi_slave rvalid rvalid Output 1
    add_interface_port altera_axi_slave rready rready Input 1
}
proc add_axi4_interface { } {
    add_interface altera_axi_slave axi4 end
    set_interface_property altera_axi_slave associatedClock clk
    set_interface_property altera_axi_slave associatedReset clk_reset
    set_interface_property altera_axi_slave readAcceptanceCapability 1
    set_interface_property altera_axi_slave writeAcceptanceCapability 1
    set_interface_property altera_axi_slave combinedAcceptanceCapability 1
    set_interface_property altera_axi_slave readDataReorderingDepth 1
    set_interface_property altera_axi_slave ENABLED true
    add_interface_port altera_axi_slave awid awid Input 4
    add_interface_port altera_axi_slave awaddr awaddr Input 32
    add_interface_port altera_axi_slave awlen awlen Input 8
    add_interface_port altera_axi_slave awsize awsize Input 3
    add_interface_port altera_axi_slave awburst awburst Input 2
    add_interface_port altera_axi_slave awlock awlock Input 1
    add_interface_port altera_axi_slave awcache awcache Input 4
    add_interface_port altera_axi_slave awprot awprot Input 3
    add_interface_port altera_axi_slave awuser awuser Input 5
    add_interface_port altera_axi_slave awqos awqos   Input 4
    add_interface_port altera_axi_slave awregion awregion Input 4
    add_interface_port altera_axi_slave awvalid awvalid Input 1
    add_interface_port altera_axi_slave awready awready Output 1
    add_interface_port altera_axi_slave wdata wdata Input 32
    add_interface_port altera_axi_slave wstrb wstrb Input 4
    add_interface_port altera_axi_slave wlast wlast Input 1
    add_interface_port altera_axi_slave wvalid wvalid Input 1
    add_interface_port altera_axi_slave wuser wuser Input 8
    add_interface_port altera_axi_slave wready wready Output 1
    add_interface_port altera_axi_slave bid bid Output 4
    add_interface_port altera_axi_slave bresp bresp Output 2
    add_interface_port altera_axi_slave buser buser Output 8
    add_interface_port altera_axi_slave bvalid bvalid Output 1
    add_interface_port altera_axi_slave bready bready Input 1
    add_interface_port altera_axi_slave arid arid Input 4
    add_interface_port altera_axi_slave araddr araddr Input 32
    add_interface_port altera_axi_slave arlen arlen Input 8
    add_interface_port altera_axi_slave arsize arsize Input 3
    add_interface_port altera_axi_slave arburst arburst Input 2
    add_interface_port altera_axi_slave arlock arlock Input 1
    add_interface_port altera_axi_slave arcache arcache Input 4
    add_interface_port altera_axi_slave arprot arprot Input 3
    add_interface_port altera_axi_slave aruser aruser Input 5
    add_interface_port altera_axi_slave arqos arqos   Input 4
    add_interface_port altera_axi_slave arregion arregion Input 4
    add_interface_port altera_axi_slave arvalid arvalid Input 1
    add_interface_port altera_axi_slave arready arready Output 1
    add_interface_port altera_axi_slave rid rid Output 4
    add_interface_port altera_axi_slave rdata rdata Output 32
    add_interface_port altera_axi_slave rresp rresp Output 2
    add_interface_port altera_axi_slave rlast rlast Output 1
    add_interface_port altera_axi_slave rvalid rvalid Output 1
    add_interface_port altera_axi_slave rready rready Input 1
    add_interface_port altera_axi_slave ruser ruser Output 8
}

proc add_axi4lite_interface { } {
    add_interface altera_axi_slave axi4lite end
    set_interface_property altera_axi_slave associatedClock clk
    set_interface_property altera_axi_slave associatedReset clk_reset
    set_interface_property altera_axi_slave readAcceptanceCapability 1
    set_interface_property altera_axi_slave writeAcceptanceCapability 1
    set_interface_property altera_axi_slave combinedAcceptanceCapability 1
    set_interface_property altera_axi_slave readDataReorderingDepth 1
    set_interface_property altera_axi_slave ENABLED true

    add_interface_port altera_axi_slave awaddr awaddr Input 32
    add_interface_port altera_axi_slave awprot awprot Input 3
    add_interface_port altera_axi_slave awvalid awvalid Input 1
    add_interface_port altera_axi_slave awready awready Output 1
    add_interface_port altera_axi_slave wdata wdata Input 32
    add_interface_port altera_axi_slave wstrb wstrb Input 4
    add_interface_port altera_axi_slave wvalid wvalid Input 1
    add_interface_port altera_axi_slave wready wready Output 1
    add_interface_port altera_axi_slave bresp bresp Output 2
    add_interface_port altera_axi_slave bvalid bvalid Output 1
    add_interface_port altera_axi_slave bready bready Input 1
    add_interface_port altera_axi_slave araddr araddr Input 32
    add_interface_port altera_axi_slave arprot arprot Input 3
    add_interface_port altera_axi_slave arvalid arvalid Input 1
    add_interface_port altera_axi_slave arready arready Output 1
    add_interface_port altera_axi_slave rdata rdata Output 32
    add_interface_port altera_axi_slave rresp rresp Output 2
    add_interface_port altera_axi_slave rvalid rvalid Output 1
    add_interface_port altera_axi_slave rready rready Input 1
}