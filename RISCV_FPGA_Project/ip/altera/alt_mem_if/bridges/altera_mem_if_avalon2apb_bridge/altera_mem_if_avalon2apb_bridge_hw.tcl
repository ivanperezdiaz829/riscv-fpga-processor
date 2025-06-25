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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}




package require -exact qsys 12.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "UniPHY Avalon-MM-to-APB Bridge"
set_module_property NAME altera_mem_if_avalon2apb_bridge
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "UniPHY Avalon-MM-to-APB Bridge"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true 


add_parameter DWIDTH INTEGER 32
set_parameter_property DWIDTH DEFAULT_VALUE 32
set_parameter_property DWIDTH DISPLAY_NAME DWIDTH
set_parameter_property DWIDTH DESCRIPTION {Data width}
set_parameter_property DWIDTH TYPE INTEGER
set_parameter_property DWIDTH UNITS None
set_parameter_property DWIDTH ALLOWED_RANGES 1:128
set_parameter_property DWIDTH AFFECTS_GENERATION false
set_parameter_property DWIDTH HDL_PARAMETER true

add_parameter AWIDTH INTEGER 10
set_parameter_property AWIDTH DEFAULT_VALUE 10
set_parameter_property AWIDTH DISPLAY_NAME AWIDTH
set_parameter_property AWIDTH DESCRIPTION {Address width}
set_parameter_property AWIDTH TYPE INTEGER
set_parameter_property AWIDTH UNITS None
set_parameter_property AWIDTH ALLOWED_RANGES 1:128
set_parameter_property AWIDTH AFFECTS_GENERATION false
set_parameter_property AWIDTH HDL_PARAMETER true

add_parameter BYTEENABLE_WIDTH INTEGER 4
set_parameter_property BYTEENABLE_WIDTH DEFAULT_VALUE 4
set_parameter_property BYTEENABLE_WIDTH DISPLAY_NAME BYTEENABLE_WIDTH
set_parameter_property BYTEENABLE_WIDTH DESCRIPTION {Byte enable width}
set_parameter_property BYTEENABLE_WIDTH TYPE INTEGER
set_parameter_property BYTEENABLE_WIDTH UNITS None
set_parameter_property BYTEENABLE_WIDTH ALLOWED_RANGES 1:128
set_parameter_property BYTEENABLE_WIDTH AFFECTS_GENERATION false
set_parameter_property BYTEENABLE_WIDTH HDL_PARAMETER true

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_mem_if_avalon2apb_bridge

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_mem_if_avalon2apb_bridge

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL altera_mem_if_avalon2apb_bridge_synth

proc generate_vhdl_sim {name} {
	add_fileset_file [file join mentor altera_mem_if_avalon2apb_bridge.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor altera_mem_if_avalon2apb_bridge.sv] {MENTOR_SPECIFIC}

	add_fileset_file altera_mem_if_avalon2apb_bridge.sv SYSTEM_VERILOG PATH altera_mem_if_avalon2apb_bridge.sv [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
}

proc generate_verilog_sim {name} {
	add_fileset_file altera_mem_if_avalon2apb_bridge.sv SYSTEM_VERILOG PATH altera_mem_if_avalon2apb_bridge.sv
}

proc generate_synth {name} {
}


set_module_property elaboration_Callback ip_elaborate

proc ip_elaborate {} {
	add_interface avalon_slave avalon end
	set_interface_property avalon_slave addressUnits SYMBOLS
	set_interface_property avalon_slave associatedClock pclk
	set_interface_property avalon_slave associatedReset sp_reset_n
	set_interface_property avalon_slave bitsPerSymbol 8
	set_interface_property avalon_slave explicitAddressSpan 0
	set_interface_property avalon_slave burstOnBurstBoundariesOnly false
	set_interface_property avalon_slave burstcountUnits SYMBOLS
	set_interface_property avalon_slave holdTime 0
	set_interface_property avalon_slave isMemoryDevice false
	set_interface_property avalon_slave isNonVolatileStorage false
	set_interface_property avalon_slave linewrapBursts false
	set_interface_property avalon_slave maximumPendingReadTransactions 0
	set_interface_property avalon_slave readLatency 0
	set_interface_property avalon_slave readWaitTime 0
	set_interface_property avalon_slave setupTime 0
	set_interface_property avalon_slave timingUnits Cycles
	set_interface_property avalon_slave writeWaitTime 0

	set_interface_property avalon_slave ENABLED true

	add_interface_port avalon_slave av_addr address Input AWIDTH
	add_interface_port avalon_slave av_write write Input 1
	add_interface_port avalon_slave av_read read Input 1
	add_interface_port avalon_slave av_writedata writedata Input DWIDTH
	add_interface_port avalon_slave av_readdata readdata Output DWIDTH
	add_interface_port avalon_slave av_byteenable byteenable Input BYTEENABLE_WIDTH
	add_interface_port avalon_slave av_waitrequest waitrequest Output 1

	add_interface apb_master conduit start

	set_interface_property apb_master ENABLED true

	add_interface_port apb_master prdata prdata Input 32
	add_interface_port apb_master pready pready Input 1
	add_interface_port apb_master pslverr pslverr Input 1
	add_interface_port apb_master pwdata pwdata Output 32
	add_interface_port apb_master pwrite pwrite Output 1
	add_interface_port apb_master penable penable Output 1
	add_interface_port apb_master psel psel Output 1
	add_interface_port apb_master paddr paddr Output 32

	add_interface pclk clock end
	add_interface sp_reset_n reset end

	set_interface_property pclk ENABLED true
	set_interface_property sp_reset_n associatedClock pclk

	add_interface_port pclk pclk clk Input 1
	add_interface_port sp_reset_n sp_reset_n reset_n Input 1

}