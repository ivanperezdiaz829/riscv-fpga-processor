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


set_module_property DESCRIPTION "UniPHY Simple Avalon-MM Bridge"
set_module_property NAME altera_mem_if_simple_avalon_mm_bridge
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "UniPHY Simple Avalon-MM Bridge"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true 

add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME {Data width}
set_parameter_property DATA_WIDTH TYPE INTEGER
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true
set_parameter_property DATA_WIDTH DESCRIPTION {Bridge data width}

add_parameter SLAVE_DATA_WIDTH INTEGER 32
set_parameter_property SLAVE_DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property SLAVE_DATA_WIDTH DISPLAY_NAME {Data width (slave)}
set_parameter_property SLAVE_DATA_WIDTH TYPE INTEGER
set_parameter_property SLAVE_DATA_WIDTH UNITS None
set_parameter_property SLAVE_DATA_WIDTH DISPLAY_HINT ""
set_parameter_property SLAVE_DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property SLAVE_DATA_WIDTH HDL_PARAMETER true
set_parameter_property SLAVE_DATA_WIDTH DESCRIPTION {Bridge data width}

add_parameter MASTER_DATA_WIDTH INTEGER 32
set_parameter_property MASTER_DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property MASTER_DATA_WIDTH DISPLAY_NAME {Data width (master)}
set_parameter_property MASTER_DATA_WIDTH TYPE INTEGER
set_parameter_property MASTER_DATA_WIDTH UNITS None
set_parameter_property MASTER_DATA_WIDTH DISPLAY_HINT ""
set_parameter_property MASTER_DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property MASTER_DATA_WIDTH HDL_PARAMETER true
set_parameter_property MASTER_DATA_WIDTH DESCRIPTION {Bridge data width}

add_parameter SYMBOL_WIDTH INTEGER 8
set_parameter_property SYMBOL_WIDTH DEFAULT_VALUE 8
set_parameter_property SYMBOL_WIDTH DISPLAY_NAME {Symbol width}
set_parameter_property SYMBOL_WIDTH TYPE INTEGER
set_parameter_property SYMBOL_WIDTH UNITS None
set_parameter_property SYMBOL_WIDTH DISPLAY_HINT ""
set_parameter_property SYMBOL_WIDTH AFFECTS_GENERATION false
set_parameter_property SYMBOL_WIDTH HDL_PARAMETER true
set_parameter_property SYMBOL_WIDTH DESCRIPTION {Symbol (byte) width}

add_parameter ADDRESS_WIDTH INTEGER 10
set_parameter_property ADDRESS_WIDTH DEFAULT_VALUE 10
set_parameter_property ADDRESS_WIDTH DISPLAY_NAME {Address width}
set_parameter_property ADDRESS_WIDTH TYPE INTEGER
set_parameter_property ADDRESS_WIDTH UNITS None
set_parameter_property ADDRESS_WIDTH DISPLAY_HINT ""
set_parameter_property ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property ADDRESS_WIDTH DESCRIPTION {Bridge address width}

add_parameter MASTER_ADDRESS_WIDTH INTEGER 10
set_parameter_property MASTER_ADDRESS_WIDTH DEFAULT_VALUE 10
set_parameter_property MASTER_ADDRESS_WIDTH DISPLAY_NAME {Master Address width}
set_parameter_property MASTER_ADDRESS_WIDTH TYPE INTEGER
set_parameter_property MASTER_ADDRESS_WIDTH UNITS None
set_parameter_property MASTER_ADDRESS_WIDTH DISPLAY_HINT ""
set_parameter_property MASTER_ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property MASTER_ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property MASTER_ADDRESS_WIDTH DESCRIPTION {Bridge master address width}

add_parameter SLAVE_ADDRESS_WIDTH INTEGER 10
set_parameter_property SLAVE_ADDRESS_WIDTH DEFAULT_VALUE 10
set_parameter_property SLAVE_ADDRESS_WIDTH DISPLAY_NAME {Slave Address width}
set_parameter_property SLAVE_ADDRESS_WIDTH TYPE INTEGER
set_parameter_property SLAVE_ADDRESS_WIDTH UNITS None
set_parameter_property SLAVE_ADDRESS_WIDTH DISPLAY_HINT ""
set_parameter_property SLAVE_ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property SLAVE_ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property SLAVE_ADDRESS_WIDTH DESCRIPTION {Bridge slave address width}

add_parameter BURSTCOUNT_WIDTH INTEGER 3
set_parameter_property BURSTCOUNT_WIDTH DEFAULT_VALUE 3
set_parameter_property BURSTCOUNT_WIDTH DISPLAY_NAME {Burstcount width}
set_parameter_property BURSTCOUNT_WIDTH TYPE INTEGER
set_parameter_property BURSTCOUNT_WIDTH UNITS None
set_parameter_property BURSTCOUNT_WIDTH DISPLAY_HINT ""
set_parameter_property BURSTCOUNT_WIDTH AFFECTS_GENERATION false
set_parameter_property BURSTCOUNT_WIDTH HDL_PARAMETER true
set_parameter_property BURSTCOUNT_WIDTH DESCRIPTION {Burstcount width}

add_parameter ADDRESS_UNITS STRING "SYMBOLS"
set_parameter_property ADDRESS_UNITS DISPLAY_NAME {Address units}
set_parameter_property ADDRESS_UNITS UNITS None
set_parameter_property ADDRESS_UNITS DISPLAY_HINT ""
set_parameter_property ADDRESS_UNITS AFFECTS_GENERATION false
set_parameter_property ADDRESS_UNITS HDL_PARAMETER false
set_parameter_property ADDRESS_UNITS ALLOWED_RANGES "SYMBOLS,WORDS"
set_parameter_property ADDRESS_UNITS DESCRIPTION {Address units (Symbols[bytes]/Words)}

add_parameter USE_BURSTBEGIN INTEGER 0
set_parameter_property USE_BURSTBEGIN DESCRIPTION {Use burstbegin signal.}
set_parameter_property USE_BURSTBEGIN DISPLAY_NAME {Use burstbegin signal.}
set_parameter_property USE_BURSTBEGIN AFFECTS_ELABORATION true
set_parameter_property USE_BURSTBEGIN HDL_PARAMETER false
set_parameter_property USE_BURSTBEGIN DISPLAY_HINT BOOLEAN

add_parameter USE_BURSTCOUNT INTEGER 0
set_parameter_property USE_BURSTCOUNT DESCRIPTION {Use burstcount signal.}
set_parameter_property USE_BURSTCOUNT DISPLAY_NAME {Use burstcount signal.}
set_parameter_property USE_BURSTCOUNT AFFECTS_ELABORATION true
set_parameter_property USE_BURSTCOUNT HDL_PARAMETER false
set_parameter_property USE_BURSTCOUNT DISPLAY_HINT BOOLEAN

add_parameter USE_BYTEENABLE INTEGER 1
set_parameter_property USE_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_BYTEENABLE HDL_PARAMETER false
set_parameter_property USE_BYTEENABLE DISPLAY_HINT BOOLEAN
set_parameter_property USE_BYTEENABLE DESCRIPTION {Enable the byteenable signal}
set_parameter_property USE_BYTEENABLE DISPLAY_NAME {Use byteenable}

add_parameter USE_READDATAVALID INTEGER 1
set_parameter_property USE_READDATAVALID DESCRIPTION {Enable the readdatavalid signal}
set_parameter_property USE_READDATAVALID DISPLAY_NAME {Use readdatavalid}
set_parameter_property USE_READDATAVALID AFFECTS_ELABORATION true
set_parameter_property USE_READDATAVALID HDL_PARAMETER false
set_parameter_property USE_READDATAVALID DISPLAY_HINT BOOLEAN

add_parameter MAX_PENDING_READ_TRANSACTIONS INTEGER 64
set_parameter_property MAX_PENDING_READ_TRANSACTIONS AFFECTS_ELABORATION true
set_parameter_property MAX_PENDING_READ_TRANSACTIONS HDL_PARAMETER false
set_parameter_property MAX_PENDING_READ_TRANSACTIONS ALLOWED_RANGES "0:32000"
set_parameter_property MAX_PENDING_READ_TRANSACTIONS DESCRIPTION {Avalon-MM maxPendingReadTransactions interface property}
set_parameter_property MAX_PENDING_READ_TRANSACTIONS DISPLAY_NAME {maxPendingReadTransactions}

add_parameter WORKAROUND_HARD_PHY_ISSUE INTEGER 0
set_parameter_property WORKAROUND_HARD_PHY_ISSUE AFFECTS_GENERATION false
set_parameter_property WORKAROUND_HARD_PHY_ISSUE HDL_PARAMETER true
set_parameter_property WORKAROUND_HARD_PHY_ISSUE DISPLAY_HINT BOOLEAN
set_parameter_property WORKAROUND_HARD_PHY_ISSUE DESCRIPTION {Adds extra wait-state on read to workaround Hard PHY Avalon issue}
set_parameter_property WORKAROUND_HARD_PHY_ISSUE DISPLAY_NAME {Workaround Hard PHY Issue}

add_parameter SLAVE_USE_WAITREQUEST_N INTEGER 0
set_parameter_property SLAVE_USE_WAITREQUEST_N DESCRIPTION {Use waitrequest_n instead of waitrequest on the slave side.}
set_parameter_property SLAVE_USE_WAITREQUEST_N DISPLAY_NAME {Use waitrequest_n on slave}
set_parameter_property SLAVE_USE_WAITREQUEST_N AFFECTS_ELABORATION true
set_parameter_property SLAVE_USE_WAITREQUEST_N HDL_PARAMETER false
set_parameter_property SLAVE_USE_WAITREQUEST_N DISPLAY_HINT BOOLEAN


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_mem_if_simple_avalon_mm_bridge

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_mem_if_simple_avalon_mm_bridge

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL altera_mem_if_simple_avalon_mm_bridge

proc generate_vhdl_sim {name} {
	add_fileset_file [file join mentor altera_mem_if_simple_avalon_mm_bridge.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor altera_mem_if_simple_avalon_mm_bridge.sv] {MENTOR_SPECIFIC}

	add_fileset_file altera_mem_if_simple_avalon_mm_bridge.sv SYSTEM_VERILOG PATH altera_mem_if_simple_avalon_mm_bridge.sv [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
}

proc generate_verilog_sim {name} {
	add_fileset_file altera_mem_if_simple_avalon_mm_bridge.sv SYSTEM_VERILOG PATH altera_mem_if_simple_avalon_mm_bridge.sv
}

proc generate_synth {name} {
	add_fileset_file altera_mem_if_simple_avalon_mm_bridge.sv SYSTEM_VERILOG PATH altera_mem_if_simple_avalon_mm_bridge.sv
}


if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
	set_module_property elaboration_Callback ip_elaborate
} else {
	set_module_property elaboration_Callback combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_elaborate
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation"
}

proc ip_elaborate {} {


	add_interface clk clock end
	set_interface_property clk clockRate 0

	set_interface_property clk ENABLED true

	add_interface_port clk clk clk Input 1
	
	add_interface reset reset end
	set_interface_property reset associatedClock clk
	set_interface_property reset synchronousEdges DEASSERT
	
	set_interface_property reset ENABLED true
	
	add_interface_port reset reset_n reset_n Input 1

	set data_width [get_parameter_value DATA_WIDTH]
    set sym_width [get_parameter_value SYMBOL_WIDTH]
	set aunits [get_parameter_value ADDRESS_UNITS]

	if {[get_parameter_value MASTER_DATA_WIDTH] != [get_parameter_value SLAVE_DATA_WIDTH]} {
		set slave_data_width [get_parameter_value SLAVE_DATA_WIDTH]
		set master_data_width [get_parameter_value MASTER_DATA_WIDTH]
	} else {
		set slave_data_width [get_parameter_value DATA_WIDTH]
		set master_data_width [get_parameter_value DATA_WIDTH]
	}
	set slave_byteen_width [expr {$slave_data_width / $sym_width}]
	set master_byteen_width [expr {$master_data_width / $sym_width}]

	add_interface s0 avalon end
	set_interface_property s0 addressAlignment DYNAMIC
	set_interface_property s0 associatedClock clk
	set_interface_property s0 associatedReset reset
	set_interface_property s0 ENABLED true
	set_interface_property s0 burstOnBurstBoundariesOnly false
	set_interface_property s0 explicitAddressSpan 0
	set_interface_property s0 holdTime 0
	set_interface_property s0 isMemoryDevice false
	set_interface_property s0 isNonVolatileStorage false
	set_interface_property s0 linewrapBursts false
    set_interface_property s0 maximumPendingReadTransactions [expr {[get_parameter_value MAX_PENDING_READ_TRANSACTIONS] * [get_parameter_value USE_READDATAVALID]}]
	set_interface_property s0 printableDevice false
	set_interface_property s0 readLatency 0
	set_interface_property s0 readWaitTime 0
	set_interface_property s0 setupTime 0
	set_interface_property s0 timingUnits Cycles
	set_interface_property s0 writeWaitTime 0
	set_interface_property s0 addressUnits $aunits
	set_interface_property s0 bitsPerSymbol $sym_width
	
	if {[get_parameter_value MASTER_ADDRESS_WIDTH] != [get_parameter_value SLAVE_ADDRESS_WIDTH]} {
		add_interface_port s0 s0_address address Input [get_parameter_value SLAVE_ADDRESS_WIDTH]
	} else {
	add_interface_port s0 s0_address address Input [get_parameter_value ADDRESS_WIDTH]
	}

	add_interface_port s0 s0_read read Input 1
	add_interface_port s0 s0_readdata readdata Output $slave_data_width
	add_interface_port s0 s0_write write Input 1
	add_interface_port s0 s0_writedata writedata Input $slave_data_width

	add_interface_port s0 s0_waitrequest waitrequest Output 1
	add_interface_port s0 s0_waitrequest_n waitrequest_n Output 1
	if {[get_parameter_value SLAVE_USE_WAITREQUEST_N] == 0} {
		set_port_property s0_waitrequest_n termination true
	} else {
		set_port_property s0_waitrequest termination true
	}

	add_interface_port s0 s0_beginbursttransfer beginbursttransfer Input 1
	add_interface_port s0 s0_burstcount burstcount Input [get_parameter_value BURSTCOUNT_WIDTH]
	if {[get_parameter_value USE_BURSTBEGIN] == 0} {
		set_port_property s0_beginbursttransfer termination true
	}
	if {[get_parameter_value USE_BURSTCOUNT] == 0} {
		set_port_property s0_burstcount termination true
	}
	add_interface_port s0 s0_byteenable byteenable Input $slave_byteen_width
    if {[get_parameter_value USE_BYTEENABLE] == 0} {
		set_port_property s0_byteenable termination true
		set_port_property s0_byteenable termination_value 0xFFFFFFFFFFFFFFFF
    }
	add_interface_port s0 s0_readdatavalid readdatavalid Output 1
    if {[get_parameter_value USE_READDATAVALID] == 0} {
		set_port_property s0_readdatavalid termination true
    }
	
	add_interface m0 avalon start
	set_interface_property m0 associatedClock clk
	set_interface_property m0 associatedReset reset
	set_interface_property m0 ENABLED true
	set_interface_property m0 burstOnBurstBoundariesOnly false
	set_interface_property m0 doStreamReads false
	set_interface_property m0 doStreamWrites false
	set_interface_property m0 linewrapBursts false
	set_interface_property m0 addressUnits $aunits
	set_interface_property m0 bitsPerSymbol $sym_width

	if {[get_parameter_value MASTER_ADDRESS_WIDTH] != [get_parameter_value SLAVE_ADDRESS_WIDTH]} {
		add_interface_port m0 m0_address address Output [get_parameter_value MASTER_ADDRESS_WIDTH]
	} else {
		add_interface_port m0 m0_address address Output [get_parameter_value ADDRESS_WIDTH]
	}

	add_interface_port m0 m0_read read Output 1
	add_interface_port m0 m0_readdata readdata Input $master_data_width
	add_interface_port m0 m0_write write Output 1
	add_interface_port m0 m0_writedata writedata Output $master_data_width
	add_interface_port m0 m0_waitrequest waitrequest Input 1
	add_interface_port m0 m0_beginbursttransfer beginbursttransfer Output 1
	add_interface_port m0 m0_burstcount burstcount Output [get_parameter_value BURSTCOUNT_WIDTH]
	if {[get_parameter_value USE_BURSTBEGIN] == 0} {
		set_port_property m0_beginbursttransfer termination true
	}
	if {[get_parameter_value USE_BURSTCOUNT] == 0} {
		set_port_property m0_burstcount termination true
	}
	add_interface_port m0 m0_byteenable byteenable Output $master_byteen_width
    if {[get_parameter_value USE_BYTEENABLE] == 0} {
		set_port_property m0_byteenable termination true
    }
	add_interface_port m0 m0_readdatavalid readdatavalid Input 1
    if {[get_parameter_value USE_READDATAVALID] == 0} {
		set_port_property m0_readdatavalid termination true
		set_port_property m0_readdatavalid termination_value 0
    }
	
}
