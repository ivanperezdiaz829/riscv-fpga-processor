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


#
# This file contains utility procs used by peripheral components in the HPS
#
#package require -exact qsys 12.0

proc hps_utils_add_component_boiler_plate {name display_name} {
	set_module_property NAME ${name}
	set_module_property VERSION 1.0
	set_module_property INTERNAL true
	set_module_property OPAQUE_ADDRESS_MAP true
	set_module_property DISPLAY_NAME "${display_name}"
	set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
	set_module_property EDITABLE true
	set_module_property ANALYZE_HDL AUTO
	set_module_property REPORT_TO_TALKBACK false
	set_module_property ALLOW_GREYBOX_GENERATION false

}
proc hps_utils_add_clock_reset {} {
	add_interface clock_sink clock end
	set_interface_property clock_sink clockRate 0
	set_interface_property clock_sink ENABLED true
	add_interface_port clock_sink clk clk Input 1

	add_interface reset_sink reset end
	set_interface_property reset_sink associatedClock clock_sink
	set_interface_property reset_sink synchronousEdges DEASSERT
	set_interface_property reset_sink ENABLED true
	add_interface_port reset_sink rst reset Input 1
}

proc hps_utils_add_irq_sender {sig_name} {
	add_interface $sig_name interrupt end
	set_interface_property $sig_name associatedAddressablePoint ""
	set_interface_property $sig_name ENABLED true
        add_interface_port $sig_name $sig_name irq Output 1
}

proc hps_utils_add_axi_master {iface_name sig_name clk rst id_width addr_width data_width strb_width} {
	add_interface $iface_name axi start
	set_interface_property $iface_name associatedClock $clk
	set_interface_property $iface_name associatedReset $rst
	set_interface_property $iface_name readIssuingCapability 1
	set_interface_property $iface_name writeIssuingCapability 1
	set_interface_property $iface_name combinedIssuingCapability 1
	set_interface_property $iface_name ENABLED true

	add_interface_port $iface_name ${sig_name} awvalid Output 1
	add_interface_port $iface_name ${sig_name}_1 awready Input 1
	add_interface_port $iface_name ${sig_name}_2 awid Output $id_width
	add_interface_port $iface_name ${sig_name}_3 awaddr Output $addr_width
	add_interface_port $iface_name ${sig_name}_4 awlen Output 4
	add_interface_port $iface_name ${sig_name}_5 awsize Output 3
	add_interface_port $iface_name ${sig_name}_6 awburst Output 2
	add_interface_port $iface_name ${sig_name}_7 awlock Output 2
	add_interface_port $iface_name ${sig_name}_8 awcache Output 4
	add_interface_port $iface_name ${sig_name}_9 awprot Output 3
	add_interface_port $iface_name ${sig_name}_10 awuser Output 1
	add_interface_port $iface_name ${sig_name}_11 arvalid Output 1
	add_interface_port $iface_name ${sig_name}_12 arready Input 1
	add_interface_port $iface_name ${sig_name}_14 araddr Output $addr_width
	add_interface_port $iface_name ${sig_name}_15 arlen Output 4
	add_interface_port $iface_name ${sig_name}_16 arsize Output 3
	add_interface_port $iface_name ${sig_name}_17 arburst Output 2
	add_interface_port $iface_name ${sig_name}_18 arlock Output 2
	add_interface_port $iface_name ${sig_name}_19 arcache Output 4
	add_interface_port $iface_name ${sig_name}_20 arprot Output 3
	add_interface_port $iface_name ${sig_name}_21 aruser Output 1
	add_interface_port $iface_name ${sig_name}_13 arid Output $id_width
	add_interface_port $iface_name ${sig_name}_24 bid Input $id_width
	add_interface_port $iface_name ${sig_name}_25 rid Input 1
	add_interface_port $iface_name ${sig_name}_26 wid Output $id_width
	add_interface_port $iface_name ${sig_name}_27 wvalid Output 1
	add_interface_port $iface_name ${sig_name}_28 wready Input 1
	add_interface_port $iface_name ${sig_name}_29 wlast Output 1
	add_interface_port $iface_name ${sig_name}_30 wdata Output $addr_width
	add_interface_port $iface_name ${sig_name}_31 wstrb Output $strb_width
	add_interface_port $iface_name ${sig_name}_32 rvalid Input 1
	add_interface_port $iface_name ${sig_name}_33 rready Output 1
	add_interface_port $iface_name ${sig_name}_34 rlast Input 1
	add_interface_port $iface_name ${sig_name}_35 rresp Input 2
	add_interface_port $iface_name ${sig_name}_36 rdata Input 32
	add_interface_port $iface_name ${sig_name}_37 bvalid Input 1
	add_interface_port $iface_name ${sig_name}_38 bready Output 1
	add_interface_port $iface_name ${sig_name}_39 bresp Input 2

}

proc hps_utils_add_axi_slave {int_name sig_name bits} {
	add_interface $int_name axi end
	set_interface_property $int_name associatedClock clock_sink
	set_interface_property $int_name associatedReset reset_sink
	set_interface_property $int_name readAcceptanceCapability 1
	set_interface_property $int_name writeAcceptanceCapability 1
	set_interface_property $int_name combinedAcceptanceCapability 1
	set_interface_property $int_name readDataReorderingDepth 1
	set_interface_property $int_name ENABLED true
	set_interface_assignment $int_name addressSpan [expr {1 << $bits}]

	set id_width 12

	add_interface_port $int_name "${sig_name}_40" awvalid Input 1
	add_interface_port $int_name "${sig_name}_41" awready Output 1
	add_interface_port $int_name "${sig_name}_42" awid Input $id_width
	add_interface_port $int_name "${sig_name}_43" awaddr Input $bits
	add_interface_port $int_name "${sig_name}_44" awlen Input 4
	add_interface_port $int_name "${sig_name}_45" awsize Input 3
	add_interface_port $int_name "${sig_name}_46" awburst Input 2
	add_interface_port $int_name "${sig_name}_47" awlock Input 2
	add_interface_port $int_name "${sig_name}_48" awcache Input 4
	add_interface_port $int_name "${sig_name}_49" awprot Input 3
	add_interface_port $int_name "${sig_name}_50" awuser Input 1
	add_interface_port $int_name "${sig_name}_51" arvalid Input 1
	add_interface_port $int_name "${sig_name}_52" arready Output 1
	add_interface_port $int_name "${sig_name}_53" arid Input $id_width
	add_interface_port $int_name "${sig_name}_54" araddr Input $bits
	add_interface_port $int_name "${sig_name}_55" arlen Input 4
	add_interface_port $int_name "${sig_name}_56" arsize Input 3
	add_interface_port $int_name "${sig_name}_57" arburst Input 2
	add_interface_port $int_name "${sig_name}_58" arlock Input 2
	add_interface_port $int_name "${sig_name}_59" arcache Input 4
	add_interface_port $int_name "${sig_name}_60" arprot Input 3
	add_interface_port $int_name "${sig_name}_61" aruser Input 1
	add_interface_port $int_name "${sig_name}_62" wvalid Input 1
	add_interface_port $int_name "${sig_name}_63" wready Output 1
	add_interface_port $int_name "${sig_name}_64" wid Input $id_width
	add_interface_port $int_name "${sig_name}_65" wlast Input 1
	add_interface_port $int_name "${sig_name}_66" wdata Input 32
	add_interface_port $int_name "${sig_name}_67" wstrb Input 4
	add_interface_port $int_name "${sig_name}_68" rvalid Output 1
	add_interface_port $int_name "${sig_name}_69" rready Input 1
	add_interface_port $int_name "${sig_name}_70" rid Output $id_width
	add_interface_port $int_name "${sig_name}_71" rlast Output 1
	add_interface_port $int_name "${sig_name}_72" rresp Output 2
	add_interface_port $int_name "${sig_name}_73" rdata Output 32
	add_interface_port $int_name "${sig_name}_74" bvalid Output 1
	add_interface_port $int_name "${sig_name}_75" bready Input 1
	add_interface_port $int_name "${sig_name}_76" bid Output $id_width
	add_interface_port $int_name "${sig_name}_77" bresp Output 2
}


proc hps_utils_add_slave_interface {master slave baseAddress} {
	add_connection $master $slave avalon
	set_connection_parameter_value "${master}/${slave}" arbitrationPriority {1}
	set_connection_parameter_value "${master}/${slave}" baseAddress $baseAddress
}

#
# add and irq connection from a slave to the GIC and to the FPGA
# deprecated
#
proc hps_utils_add_irq_connection {gic_sig_name irq_name exp_name offset} {
	set bridge_name "${exp_name}_bridge"

	#create the connection between the peripheral irq and the GIC
	add_connection $gic_sig_name $irq_name
	set_connection_parameter_value "${gic_sig_name}/${irq_name}" irqNumber $offset

#    Now setup an external interface, and then the interrupt to the external interface. This allows a NIOS II in 
#    the FPGA to use the hardened peripherals.  In order to export the irq and connect it to gic,
#    we need to put a bridge in between the irq signal and the exported signal
	
	add_instance $bridge_name matts_irq_bridge
	set_instance_parameter $bridge_name IRQ_WIDTH 1

	add_connection "${bridge_name}.receiver_irq" $irq_name

	add_interface $exp_name interrupt end
	set_interface_property $exp_name EXPORT_OF "${bridge_name}.sender0_irq"
}

proc hps_utils_add_gic_irq_connection {gic_sig_name irq_name offset} {
	#create the connection between the peripheral irq and the GIC
	add_connection $gic_sig_name $irq_name
	set_connection_parameter_value "${gic_sig_name}/${irq_name}" irqNumber $offset
}

proc hps_utils_add_fpga_irq_connection {irq_name exp_name} {

	add_interface $exp_name interrupt end
	set_interface_property $exp_name EXPORT_OF $irq_name
}

proc hps_utils_add_instance_clk_reset {clk name type} {
	add_instance $name $type 1.0
	add_connection "${clk}.clk" "${name}.clock_sink"
	add_connection "${clk}.clk_reset" "${name}.reset_sink"
}
