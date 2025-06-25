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



set_module_property DESCRIPTION "Altera Avalon-MM Efficiency Monitor and Protocol Checker"
set_module_property NAME altera_avalon_em_pc
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_perf_monitors_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Avalon-MM Efficiency Monitor and Protocol Checker"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false
if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property VALIDATION_CALLBACK ip_validate
	set_module_property COMPOSITION_CALLBACK ip_compose
} else {
	set_module_property COMPOSITION_CALLBACK combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_compose
}

set_module_property HIDE_FROM_SOPC true


set ::EMPC_ADDR_WIDTH 12
set ::EMPC_DATA_WIDTH 32

set ::CSR_TYPE_EXPORT "EXPORT"
set ::CSR_TYPE_SHARED "SHARED"
set ::CSR_TYPE_INTERNAL_JTAG "INTERNAL_JTAG"



add_parameter EMPC_AV_BURSTCOUNT_WIDTH INTEGER 3
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH DEFAULT_VALUE 3
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH DISPLAY_NAME "AV_BURSTCOUNT_WIDTH"
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH UNITS None
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH ALLOWED_RANGES 1:10000
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_BURSTCOUNT_WIDTH DESCRIPTION "Specifies width of Avalon burst count signal."

add_parameter EMPC_AV_DATA_WIDTH INTEGER 64
set_parameter_property EMPC_AV_DATA_WIDTH DEFAULT_VALUE 64
set_parameter_property EMPC_AV_DATA_WIDTH DISPLAY_NAME "AV_DATA_WIDTH"
set_parameter_property EMPC_AV_DATA_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_DATA_WIDTH UNITS None
set_parameter_property EMPC_AV_DATA_WIDTH ALLOWED_RANGES 1:8192
set_parameter_property EMPC_AV_DATA_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_DATA_WIDTH DESCRIPTION "Specifies width of Avalon data signal.  Must be power of 2"

add_parameter EMPC_AV_POW2_DATA_WIDTH INTEGER 64
set_parameter_property EMPC_AV_POW2_DATA_WIDTH DEFAULT_VALUE 64
set_parameter_property EMPC_AV_POW2_DATA_WIDTH DISPLAY_NAME "AV_POW2_DATA_WIDTH"
set_parameter_property EMPC_AV_POW2_DATA_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_POW2_DATA_WIDTH UNITS None
set_parameter_property EMPC_AV_POW2_DATA_WIDTH ALLOWED_RANGES 1:8192
set_parameter_property EMPC_AV_POW2_DATA_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_POW2_DATA_WIDTH DESCRIPTION "Specifies width of Avalon data signal.  Must be power of 2"

add_parameter EMPC_AV_ADDRESS_WIDTH INTEGER 23
set_parameter_property EMPC_AV_ADDRESS_WIDTH DEFAULT_VALUE 23
set_parameter_property EMPC_AV_ADDRESS_WIDTH DISPLAY_NAME "AV_ADDRESS_WIDTH"
set_parameter_property EMPC_AV_ADDRESS_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_ADDRESS_WIDTH UNITS None
set_parameter_property EMPC_AV_ADDRESS_WIDTH ALLOWED_RANGES 1:2147483647
set_parameter_property EMPC_AV_ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_ADDRESS_WIDTH DESCRIPTION "Specifies width of Avalon address signal."


add_parameter EMPC_AV_SYMBOL_WIDTH INTEGER 8
set_parameter_property EMPC_AV_SYMBOL_WIDTH DEFAULT_VALUE 8
set_parameter_property EMPC_AV_SYMBOL_WIDTH DISPLAY_NAME "AV_SYMBOL_WIDTH"
set_parameter_property EMPC_AV_SYMBOL_WIDTH TYPE INTEGER
set_parameter_property EMPC_AV_SYMBOL_WIDTH UNITS None
set_parameter_property EMPC_AV_SYMBOL_WIDTH ALLOWED_RANGES 1:2147483647
set_parameter_property EMPC_AV_SYMBOL_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_AV_SYMBOL_WIDTH DESCRIPTION "Specifies width of Avalon symbol."

add_parameter EMPC_COUNT_WIDTH INTEGER 32
set_parameter_property EMPC_COUNT_WIDTH DEFAULT_VALUE 32
set_parameter_property EMPC_COUNT_WIDTH DISPLAY_NAME "COUNT_WIDTH"
set_parameter_property EMPC_COUNT_WIDTH TYPE INTEGER
set_parameter_property EMPC_COUNT_WIDTH UNITS None
set_parameter_property EMPC_COUNT_WIDTH VISIBLE false
set_parameter_property EMPC_COUNT_WIDTH HDL_PARAMETER true
set_parameter_property EMPC_COUNT_WIDTH DESCRIPTION "Specifies width of counters measuring the statistics."

add_parameter EMPC_CSR_CONNECTION STRING ""
set_parameter_property EMPC_CSR_CONNECTION Description "Specifies the connection type to CSR port. The port can be exported, internally connected to a JTAG Avalon Master, or both"
set_parameter_property EMPC_CSR_CONNECTION Display_Name "CSR port host interface"
set_parameter_property EMPC_CSR_CONNECTION UNITS None
set_parameter_property EMPC_CSR_CONNECTION DEFAULT_VALUE $::CSR_TYPE_INTERNAL_JTAG
set_parameter_property EMPC_CSR_CONNECTION ALLOWED_RANGES [list $::CSR_TYPE_EXPORT $::CSR_TYPE_SHARED $::CSR_TYPE_INTERNAL_JTAG]

add_parameter EMPC_MAX_READ_TRANSACTIONS INTEGER 16
set_parameter_property EMPC_MAX_READ_TRANSACTIONS DESCRIPTION "Avalon-MM Max Pending Read Transactions"
set_parameter_property EMPC_MAX_READ_TRANSACTIONS DISPLAY_NAME "AV Max Pending Read Transactions"
set_parameter_property EMPC_MAX_READ_TRANSACTIONS AFFECTS_ELABORATION true



add_display_item "" "General Settings" GROUP ""
add_display_item "General Settings" EMPC_AV_BURSTCOUNT_WIDTH PARAMETER ""
add_display_item "General Settings" EMPC_AV_DATA_WIDTH PARAMETER ""
add_display_item "General Settings" EMPC_AV_ADDRESS_WIDTH PARAMETER ""
add_display_item "General Settings" EMPC_AV_SYMBOL_WIDTH PARAMETER ""
add_display_item "General Settings" EMPC_CSR_CONNECTION PARAMETER ""
add_display_item "General Settings" EMPC_MAX_READ_TRANSACTIONS PARAMETER ""

sopc::preview_add_transform "my_monitor" "PREVIEW_AVALON_MM_TRANSFORM"

proc ip_validate {} {
  set csr_type [get_parameter_value EMPC_CSR_CONNECTION]

  if {[string compare -nocase $csr_type $::CSR_TYPE_EXPORT] == 0} {
    send_message warning "UniPHY Efficiency Monitor and Protocol Checker can only be connected to debug GUI when using a CSR port connection with an internally connected JTAG Avalon Master"
  }
	


}


proc ip_compose {} {

  set av_burstcount_width [get_parameter_value EMPC_AV_BURSTCOUNT_WIDTH]
  set av_data_width [get_parameter_value EMPC_AV_DATA_WIDTH]
  set av_pow2_data_width [get_parameter_value EMPC_AV_POW2_DATA_WIDTH]
  set av_address_width [get_parameter_value EMPC_AV_ADDRESS_WIDTH]
  set av_symbol_width [get_parameter_value EMPC_AV_SYMBOL_WIDTH]
  set count_width [get_parameter_value EMPC_COUNT_WIDTH]
  set csr_type [get_parameter_value EMPC_CSR_CONNECTION]
  set max_read_transactions [get_parameter_value EMPC_MAX_READ_TRANSACTIONS]

  set AV_NUM_SYMBOLS [expr {$av_data_width / $av_symbol_width}]
  set AV_NUM_POW2_SYMBOLS [expr {$av_pow2_data_width / $av_symbol_width}]

  set av_master_address_width $av_address_width
  set av_slave_address_width  [expr { $av_address_width + int(ceil(log($AV_NUM_SYMBOLS)/log(2))) }]

  add_instance em_pc_core_0 altera_avalon_em_pc_core
  set_instance_parameter em_pc_core_0 EMPC_AV_BURSTCOUNT_WIDTH $av_burstcount_width
  set_instance_parameter em_pc_core_0 EMPC_AV_DATA_WIDTH $av_data_width
  set_instance_parameter em_pc_core_0 EMPC_AV_POW2_DATA_WIDTH $av_pow2_data_width
  set_instance_parameter em_pc_core_0 EMPC_AV_SYMBOL_WIDTH $av_symbol_width
  set_instance_parameter em_pc_core_0 EMPC_AVM_ADDRESS_WIDTH $av_master_address_width
  set_instance_parameter em_pc_core_0 EMPC_AVS_ADDRESS_WIDTH $av_slave_address_width
  set_instance_parameter em_pc_core_0 EMPC_AV_BE_WIDTH $AV_NUM_SYMBOLS
  set_instance_parameter em_pc_core_0 EMPC_AV_POW2_BE_WIDTH $AV_NUM_POW2_SYMBOLS
  set_instance_parameter em_pc_core_0 EMPC_COUNT_WIDTH $count_width
  set_instance_parameter em_pc_core_0 EMPC_CSR_ADDR_WIDTH $::EMPC_ADDR_WIDTH
  set_instance_parameter em_pc_core_0 EMPC_CSR_DATA_WIDTH $::EMPC_DATA_WIDTH
  set_instance_parameter em_pc_core_0 EMPC_MAX_READ_TRANSACTIONS $max_read_transactions

  add_interface avl_in avalon end
  set_interface_property avl_in export_of em_pc_core_0.avalon_slave_0

  add_interface avl_out avalon start
  set_interface_property avl_out export_of em_pc_core_0.avalon_master_0
	
  add_interface avl_clk clock end
  add_instance avl_clk altera_clock_bridge
  set_interface_property avl_clk export_of avl_clk.in_clk		
  add_connection avl_clk.out_clk/em_pc_core_0.avalon_clk
  set_interface_property avl_clk PORT_NAME_MAP {avl_clk in_clk}
	
  add_interface avl_reset_n reset end
  add_instance avl_reset_n altera_reset_bridge
  set_interface_property avl_reset_n export_of avl_reset_n.in_reset
  set_instance_parameter avl_reset_n SYNCHRONOUS_EDGES none
  set_instance_parameter avl_reset_n ACTIVE_LOW_RESET 1
  add_connection avl_reset_n.out_reset/em_pc_core_0.reset_sink
  set_interface_property avl_reset_n PORT_NAME_MAP {avl_reset_n in_reset_n}

  set use_bridge 0
  set use_jtag_master 0
  if {[string compare -nocase $csr_type $::CSR_TYPE_EXPORT] == 0} {
    set use_bridge 1
  } elseif {[string compare -nocase $csr_type $::CSR_TYPE_SHARED] == 0} {
    set use_bridge 1
    set use_jtag_master 1
  } elseif {[string compare -nocase $csr_type $::CSR_TYPE_INTERNAL_JTAG] == 0} {
    set use_jtag_master 1
  } else {
    send_message error "Unknown CSR port type $csr_type"
  }

  if {$use_jtag_master} {
	set CSR_MASTER em_csr_m0
    add_instance $CSR_MASTER altera_jtag_avalon_master 

    set_instance_parameter $CSR_MASTER USE_PLI "0"
    set_instance_parameter $CSR_MASTER PLI_PORT "50000"

    add_connection "${CSR_MASTER}.master/em_pc_core_0.csr"
    add_connection "avl_clk.out_clk/${CSR_MASTER}.clk"
    add_connection "avl_reset_n.out_reset/${CSR_MASTER}.clk_reset"

    set_connection_parameter_value "${CSR_MASTER}.master/em_pc_core_0.csr" arbitrationPriority "1"
    set_connection_parameter_value "${CSR_MASTER}.master/em_pc_core_0.csr" baseAddress "0x0000"
  }

  if {$use_bridge} {
    add_instance bridge_0 altera_avalon_mm_bridge 

    set_instance_parameter bridge_0 DATA_WIDTH $::EMPC_DATA_WIDTH
    set_instance_parameter bridge_0 SYMBOL_WIDTH 8
    set_instance_parameter bridge_0 ADDRESS_WIDTH [expr {$::EMPC_ADDR_WIDTH + 2}]
    set_instance_parameter bridge_0 MAX_BURST_SIZE 1

    add_connection bridge_0.m0/em_pc_core_0.csr
    add_connection avl_clk.out_clk/bridge_0.clk
    add_connection avl_reset_n.out_reset/bridge_0.reset

    set_connection_parameter_value bridge_0.m0/em_pc_core_0.csr arbitrationPriority "1"
    set_connection_parameter_value bridge_0.m0/em_pc_core_0.csr baseAddress "0x0000"
		
    add_interface em_csr avalon end
    set_interface_property em_csr export_of bridge_0.s0

  }
	
}

