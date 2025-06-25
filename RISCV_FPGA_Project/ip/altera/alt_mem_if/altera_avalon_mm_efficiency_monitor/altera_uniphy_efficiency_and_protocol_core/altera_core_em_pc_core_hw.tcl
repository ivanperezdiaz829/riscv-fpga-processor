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


set_module_property DESCRIPTION "Altera Avalon-MM Efficiency Monitor and Protocol Checker Core"
set_module_property NAME altera_avalon_em_pc_core
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_perf_monitor_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Avalon-MM Efficiency Monitor and Protcol Checker Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL em_top_ms
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL em_top_ms
add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL em_top_ms


proc generate_verilog_fileset {} {
	set file_list [list \
		em_top_ms.v \
		em_count_fsm.v \
		em_protocol_fsm.v \
		em_rdlat_fsm.v \
		em_reset_sync.v \
	]
	
	return $file_list
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"

		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name $non_encryp_simulators

		add_fileset_file [file join mentor $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 1 1] PATH [file join mentor $file_name] {MENTOR_SPECIFIC}
	}
}

proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}
}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}
}

add_parameter EMPC_AV_BURSTCOUNT_WIDTH INTEGER 3 
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH DEFAULT_VALUE 3
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH DISPLAY_NAME "AV_BURSTCOUNT_WIDTH"
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH UNITS None
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH DESCRIPTION "Specifies width of Avalon burst count signal."

add_parameter EMPC_AV_DATA_WIDTH INTEGER 64
set_parameter_property EMPC_AV_DATA_WIDTH DEFAULT_VALUE 64
set_parameter_property EMPC_AV_DATA_WIDTH DISPLAY_NAME "AV_DATA_WIDTH"
set_parameter_property EMPC_AV_DATA_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_DATA_WIDTH UNITS None
set_parameter_property EMPC_AV_DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AV_DATA_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_DATA_WIDTH DESCRIPTION "Specifies width of Avalon data signal."

add_parameter EMPC_AV_POW2_DATA_WIDTH INTEGER 64
set_parameter_property EMPC_AV_POW2_DATA_WIDTH DEFAULT_VALUE 64
set_parameter_property EMPC_AV_POW2_DATA_WIDTH DISPLAY_NAME "AV_POW2_DATA_WIDTH"
set_parameter_property EMPC_AV_POW2_DATA_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_POW2_DATA_WIDTH UNITS None
set_parameter_property EMPC_AV_POW2_DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AV_POW2_DATA_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_POW2_DATA_WIDTH DESCRIPTION "Specifies width of Avalon data signal."

add_parameter EMPC_AV_SYMBOL_WIDTH INTEGER 8
set_parameter_property EMPC_AV_SYMBOL_WIDTH DEFAULT_VALUE 8
set_parameter_property EMPC_AV_SYMBOL_WIDTH DISPLAY_NAME "AV_SYMBOL_WIDTH"
set_parameter_property EMPC_AV_SYMBOL_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_SYMBOL_WIDTH UNITS None
set_parameter_property EMPC_AV_SYMBOL_WIDTH ALLOWED_RANGES 1:2147483647
set_parameter_property EMPC_AV_SYMBOL_WIDTH DESCRIPTION "Specifies width of Avalon symbol."

add_parameter EMPC_AVM_ADDRESS_WIDTH INTEGER 23
set_parameter_property EMPC_AVM_ADDRESS_WIDTH DEFAULT_VALUE 23
set_parameter_property EMPC_AVM_ADDRESS_WIDTH DISPLAY_NAME "AVM_ADDRESS_WIDTH"
set_parameter_property EMPC_AVM_ADDRESS_WIDTH TYPE INTEGER
set_parameter_property EMPC_AVM_ADDRESS_WIDTH UNITS None
set_parameter_property EMPC_AVM_ADDRESS_WIDTH ALLOWED_RANGES 1:2147483647
set_parameter_property EMPC_AVM_ADDRESS_WIDTH DESCRIPTION ""
set_parameter_property EMPC_AVM_ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AVM_ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AVM_ADDRESS_WIDTH DESCRIPTION "Specifies width of Avalon address signal of the interface to the master."

add_parameter EMPC_AVS_ADDRESS_WIDTH INTEGER 23
set_parameter_property EMPC_AVS_ADDRESS_WIDTH DEFAULT_VALUE 23
set_parameter_property EMPC_AVS_ADDRESS_WIDTH DISPLAY_NAME "AVS_ADDRESS_WIDTH"
set_parameter_property EMPC_AVS_ADDRESS_WIDTH TYPE INTEGER
set_parameter_property EMPC_AVS_ADDRESS_WIDTH UNITS None
set_parameter_property EMPC_AVS_ADDRESS_WIDTH ALLOWED_RANGES 1:2147483647
set_parameter_property EMPC_AVS_ADDRESS_WIDTH DESCRIPTION ""
set_parameter_property EMPC_AVS_ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AVS_ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AVS_ADDRESS_WIDTH DESCRIPTION "Specifies width of Avalon address signal of the interface to the slave."

add_parameter EMPC_AV_BE_WIDTH INTEGER 8
set_parameter_property EMPC_AV_BE_WIDTH DEFAULT_VALUE 8
set_parameter_property EMPC_AV_BE_WIDTH DISPLAY_NAME "AV_BE_WIDTH"
set_parameter_property EMPC_AV_BE_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_BE_WIDTH UNITS None
set_parameter_property EMPC_AV_BE_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AV_BE_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_BE_WIDTH DESCRIPTION "Specifies width of Avalon byte enable signal."

add_parameter EMPC_AV_POW2_BE_WIDTH INTEGER 8
set_parameter_property EMPC_AV_POW2_BE_WIDTH DEFAULT_VALUE 8
set_parameter_property EMPC_AV_POW2_BE_WIDTH DISPLAY_NAME "AV_POW2_BE_WIDTH"
set_parameter_property EMPC_AV_POW2_BE_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_POW2_BE_WIDTH UNITS None
set_parameter_property EMPC_AV_POW2_BE_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_AV_POW2_BE_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_POW2_BE_WIDTH DESCRIPTION "Specifies width of Avalon byte enable signal."

add_parameter EMPC_COUNT_WIDTH INTEGER 32
set_parameter_property EMPC_COUNT_WIDTH DEFAULT_VALUE 32
set_parameter_property EMPC_COUNT_WIDTH DISPLAY_NAME "COUNT_WIDTH"
set_parameter_property EMPC_COUNT_WIDTH TYPE INTEGER
set_parameter_property EMPC_COUNT_WIDTH UNITS None
set_parameter_property EMPC_COUNT_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_COUNT_WIDTH VISIBLE false
set_parameter_property EMPC_COUNT_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_COUNT_WIDTH DESCRIPTION "Specifies width of counters measuring the statistics."

add_parameter EMPC_CSR_ADDR_WIDTH INTEGER 12
set_parameter_property EMPC_CSR_ADDR_WIDTH DEFAULT_VALUE 12
set_parameter_property EMPC_CSR_ADDR_WIDTH DISPLAY_NAME "CSR Address Width"
set_parameter_property EMPC_CSR_ADDR_WIDTH DESCRIPTION "CSR Address Width"
set_parameter_property EMPC_CSR_ADDR_WIDTH TYPE INTEGER
set_parameter_property EMPC_CSR_ADDR_WIDTH VISIBLE false
set_parameter_property EMPC_CSR_ADDR_WIDTH ENABLED false
set_parameter_property EMPC_CSR_ADDR_WIDTH UNITS None
set_parameter_property EMPC_CSR_ADDR_WIDTH ALLOWED_RANGES 1:32
set_parameter_property EMPC_CSR_ADDR_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_CSR_ADDR_WIDTH HDL_PARAMETER true

add_parameter EMPC_CSR_DATA_WIDTH INTEGER 32
set_parameter_property EMPC_CSR_DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property EMPC_CSR_DATA_WIDTH DISPLAY_NAME "CSR Data Width"
set_parameter_property EMPC_CSR_DATA_WIDTH DESCRIPTION "CSR Data Width"
set_parameter_property EMPC_CSR_DATA_WIDTH TYPE INTEGER
set_parameter_property EMPC_CSR_DATA_WIDTH VISIBLE false
set_parameter_property EMPC_CSR_DATA_WIDTH ENABLED false
set_parameter_property EMPC_CSR_DATA_WIDTH UNITS None
set_parameter_property EMPC_CSR_DATA_WIDTH ALLOWED_RANGES 32
set_parameter_property EMPC_CSR_DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPC_CSR_DATA_WIDTH HDL_PARAMETER true

add_parameter EMPC_MAX_READ_TRANSACTIONS INTEGER 16
set_parameter_property EMPC_MAX_READ_TRANSACTIONS DESCRIPTION "Avalon-MM Max Pending Read Transactions"
set_parameter_property EMPC_MAX_READ_TRANSACTIONS DISPLAY_NAME "AV Max Pending Read Transactions"
set_parameter_property EMPC_MAX_READ_TRANSACTIONS DEFAULT_VALUE 16
set_parameter_property EMPC_MAX_READ_TRANSACTIONS TYPE INTEGER
set_parameter_property EMPC_MAX_READ_TRANSACTIONS UNITS None
set_parameter_property EMPC_MAX_READ_TRANSACTIONS AFFECTS_ELABORATION true

add_parameter EMPC_VERSION INTEGER 110
set_parameter_property EMPC_VERSION VISIBLE false
set_parameter_property EMPC_VERSION DERIVED true
set_parameter_property EMPC_VERSION HDL_PARAMETER true





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
	
	set effmon_version 13.1
	set effmon_version [expr {int($effmon_version * 10.0)}]
	set_parameter_value EMPC_VERSION $effmon_version

}

proc ip_elaborate {} {
  add_interface avalon_clk clock end
  set_interface_property avalon_clk ENABLED true
  add_interface_port avalon_clk avm_clk clk Input 1

  add_interface reset_sink reset end
  set_interface_property reset_sink synchronousEdges none
  set_interface_property reset_sink ENABLED true
  add_interface_port reset_sink ctl_reset_n reset_n Input 1


  add_interface avalon_slave_0 avalon end
  set_interface_property avalon_slave_0 addressAlignment DYNAMIC
  set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
  set_interface_property avalon_slave_0 holdTime 0
  set_interface_property avalon_slave_0 isMemoryDevice 1
  set_interface_property avalon_slave_0 isNonVolatileStorage false
  set_interface_property avalon_slave_0 linewrapBursts false
  set_interface_property avalon_slave_0 maximumPendingReadTransactions [get_parameter_value EMPC_MAX_READ_TRANSACTIONS]
  set_interface_property avalon_slave_0 printableDevice false
  set_interface_property avalon_slave_0 readLatency 0
  set_interface_property avalon_slave_0 readWaitTime 1
  set_interface_property avalon_slave_0 setupTime 0
  set_interface_property avalon_slave_0 timingUnits Cycles
  set_interface_property avalon_slave_0 writeWaitTime 0
  set_interface_property avalon_slave_0 bitsPerSymbol [get_parameter_value EMPC_AV_SYMBOL_WIDTH]

  set_interface_property avalon_slave_0 associatedClock avalon_clk
  set_interface_property avalon_slave_0 associatedReset reset_sink
  set_interface_property avalon_slave_0 ENABLED true

  add_interface_port avalon_slave_0 avm_address address Input [get_parameter_value EMPC_AVM_ADDRESS_WIDTH]
  add_interface_port avalon_slave_0 avm_be byteenable Input [get_parameter_value EMPC_AV_POW2_BE_WIDTH]
  add_interface_port avalon_slave_0 avm_burstcount burstcount Input [get_parameter_value EMPC_AV_BURSTCOUNT_WIDTH]
  add_interface_port avalon_slave_0 avm_beginbursttransfer beginbursttransfer Input 1
  add_interface_port avalon_slave_0 avm_waitrequest waitrequest Output 1
  add_interface_port avalon_slave_0 avm_write write Input 1
  add_interface_port avalon_slave_0 avm_read read Input 1
  add_interface_port avalon_slave_0 avm_readvalid readdatavalid Output 1
  add_interface_port avalon_slave_0 avm_wdata writedata Input [get_parameter_value EMPC_AV_POW2_DATA_WIDTH]
  add_interface_port avalon_slave_0 avm_rdata readdata Output [get_parameter_value EMPC_AV_POW2_DATA_WIDTH]


  add_interface avalon_master_0 avalon start
  set_interface_property avalon_master_0 burstOnBurstBoundariesOnly false
  set_interface_property avalon_master_0 doStreamReads false
  set_interface_property avalon_master_0 doStreamWrites false
  set_interface_property avalon_master_0 linewrapBursts false
  set_interface_property avalon_master_0 bitsPerSymbol [get_parameter_value EMPC_AV_SYMBOL_WIDTH]

  set_interface_property avalon_master_0 associatedClock avalon_clk
  set_interface_property avalon_master_0 associatedReset reset_sink
  set_interface_property avalon_master_0 ENABLED true

  add_interface_port avalon_master_0 avs_address address Output [get_parameter_value EMPC_AVS_ADDRESS_WIDTH]
  add_interface_port avalon_master_0 avs_be byteenable Output [get_parameter_value EMPC_AV_BE_WIDTH]
  add_interface_port avalon_master_0 avs_burstcount burstcount Output [get_parameter_value EMPC_AV_BURSTCOUNT_WIDTH]
  add_interface_port avalon_master_0 avs_beginbursttransfer beginbursttransfer Output 1
  add_interface_port avalon_master_0 avs_waitrequest waitrequest Input 1
  add_interface_port avalon_master_0 avs_write write Output 1
  add_interface_port avalon_master_0 avs_read read Output 1
  add_interface_port avalon_master_0 avs_readvalid readdatavalid Input 1
  add_interface_port avalon_master_0 avs_wdata writedata Output [get_parameter_value EMPC_AV_DATA_WIDTH]
  add_interface_port avalon_master_0 avs_rdata readdata Input [get_parameter_value EMPC_AV_DATA_WIDTH]


  add_interface csr avalon end
  set_interface_property csr addressAlignment DYNAMIC
  set_interface_property csr associatedClock avalon_clk
  set_interface_property csr associatedReset reset_sink
  set_interface_property csr burstOnBurstBoundariesOnly false
  set_interface_property csr explicitAddressSpan 0
  set_interface_property csr holdTime 0
  set_interface_property csr isMemoryDevice false
  set_interface_property csr isNonVolatileStorage false
  set_interface_property csr linewrapBursts false
  set_interface_property csr maximumPendingReadTransactions 1
  set_interface_property csr printableDevice false
  set_interface_property csr readLatency 0
  set_interface_property csr readWaitTime 1
  set_interface_property csr setupTime 0
  set_interface_property csr timingUnits Cycles
  set_interface_property csr writeWaitTime 0

  set_interface_property csr ENABLED true

  set_interface_assignment csr debug.visible true

  add_interface_port csr csr_addr address Input [get_parameter_value EMPC_CSR_ADDR_WIDTH]
  add_interface_port csr csr_be byteenable Input [expr [get_parameter_value EMPC_CSR_DATA_WIDTH]/8]
  add_interface_port csr csr_write_req write Input 1
  add_interface_port csr csr_wdata writedata Input [get_parameter_value EMPC_CSR_DATA_WIDTH]
  add_interface_port csr csr_read_req read Input 1
  add_interface_port csr csr_rdata readdata Output [get_parameter_value EMPC_CSR_DATA_WIDTH]
  add_interface_port csr csr_rdata_valid readdatavalid Output 1
  add_interface_port csr csr_waitrequest waitrequest Output 1


}

