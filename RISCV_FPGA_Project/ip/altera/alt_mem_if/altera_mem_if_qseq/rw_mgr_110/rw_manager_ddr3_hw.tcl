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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "RW Manager DDR3 (11.0)"
set_module_property NAME sequencer_rw_mgr_ddr3_110
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY DDR3 Read/Write Manager (11.0 Version)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL rw_manager_ddr3

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL rw_manager_ddr3

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL rw_manager_ddr3


proc generate_verilog_fileset {} {
	set file_list [list \
		rw_manager_ddr3.v \
		rw_manager_ac_ROM_reg.v \
		rw_manager_bitcheck.v \
		rw_manager_core.sv \
		rw_manager_data_broadcast.v \
		rw_manager_data_decoder.v \
		rw_manager_datamux.v \
		rw_manager_di_buffer.v \
		rw_manager_di_buffer_wrap.v \
		rw_manager_dm_decoder.v \
		rw_manager_generic.sv \
		rw_manager_inst_ROM_reg.v \
		rw_manager_jumplogic.v \
		rw_manager_lfsr72.v \
		rw_manager_lfsr36.v \
		rw_manager_lfsr12.v \
		rw_manager_pattern_fifo.v \
		rw_manager_ram.v \
		rw_manager_ram_csr.v \
		rw_manager_read_datapath.v \
		rw_manager_write_decoder.v \
	]

	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] true] == 0} {
		if {[string compare -nocase [get_parameter_value DEVICE_FAMILY] STRATIXIII] == 0} {
			lappend file_list rw_manager_inst_ROM_hcx_compat_mode_stratixiii.v
		} else {
			lappend file_list rw_manager_inst_ROM_hcx_compat_mode.v
		}
		lappend file_list rw_manager_ac_ROM_hcx_compat_mode.v
	} else {
		lappend file_list rw_manager_ac_ROM_no_ifdef_params.v
		lappend file_list rw_manager_inst_ROM_no_ifdef_params.v
	}
	
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

add_parameter RATE STRING "Half"
set_parameter_property RATE DISPLAY_NAME RATE
set_parameter_property RATE HDL_PARAMETER true

add_parameter AVL_DATA_WIDTH INTEGER 32
set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME AVL_DATA_WIDTH
set_parameter_property AVL_DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true
set_parameter_property AVL_DATA_WIDTH ALLOWED_RANGES {1:1024}

add_parameter AVL_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME AVL_ADDR_WIDTH
set_parameter_property AVL_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true
set_parameter_property AVL_ADDR_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_ADDRESS_WIDTH INTEGER 1
set_parameter_property MEM_ADDRESS_WIDTH DISPLAY_NAME MEM_ADDRESS_WIDTH
set_parameter_property MEM_ADDRESS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_ADDRESS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_CONTROL_WIDTH INTEGER 1
set_parameter_property MEM_CONTROL_WIDTH DISPLAY_NAME MEM_CONTROL_WIDTH
set_parameter_property MEM_CONTROL_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_CONTROL_WIDTH HDL_PARAMETER true
set_parameter_property MEM_CONTROL_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_DQ_WIDTH INTEGER 1
set_parameter_property MEM_DQ_WIDTH DISPLAY_NAME MEM_DQ_WIDTH
set_parameter_property MEM_DQ_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_DQ_WIDTH HDL_PARAMETER true
set_parameter_property MEM_DQ_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_DM_WIDTH INTEGER 1
set_parameter_property MEM_DM_WIDTH DISPLAY_NAME MEM_DM_WIDTH
set_parameter_property MEM_DM_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_DM_WIDTH HDL_PARAMETER true
set_parameter_property MEM_DM_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_NUMBER_OF_RANKS INTEGER 1
set_parameter_property MEM_NUMBER_OF_RANKS DISPLAY_NAME MEM_NUMBER_OF_RANKS
set_parameter_property MEM_NUMBER_OF_RANKS AFFECTS_ELABORATION true
set_parameter_property MEM_NUMBER_OF_RANKS HDL_PARAMETER true
set_parameter_property MEM_NUMBER_OF_RANKS ALLOWED_RANGES {1:1024}

add_parameter MEM_CLK_EN_WIDTH INTEGER 1
set_parameter_property MEM_CLK_EN_WIDTH DISPLAY_NAME MEM_CLK_EN_WIDTH
set_parameter_property MEM_CLK_EN_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_CLK_EN_WIDTH HDL_PARAMETER true
set_parameter_property MEM_CLK_EN_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_BANK_WIDTH INTEGER 1
set_parameter_property MEM_BANK_WIDTH DISPLAY_NAME MEM_BANK_WIDTH
set_parameter_property MEM_BANK_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_BANK_WIDTH HDL_PARAMETER true
set_parameter_property MEM_BANK_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_ODT_WIDTH INTEGER 1
set_parameter_property MEM_ODT_WIDTH DISPLAY_NAME MEM_ODT_WIDTH
set_parameter_property MEM_ODT_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_ODT_WIDTH HDL_PARAMETER true
set_parameter_property MEM_ODT_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_CHIP_SELECT_WIDTH INTEGER 1
set_parameter_property MEM_CHIP_SELECT_WIDTH DISPLAY_NAME MEM_CHIP_SELECT_WIDTH
set_parameter_property MEM_CHIP_SELECT_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_CHIP_SELECT_WIDTH HDL_PARAMETER true
set_parameter_property MEM_CHIP_SELECT_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_READ_DQS_WIDTH INTEGER 1
set_parameter_property MEM_READ_DQS_WIDTH DISPLAY_NAME MEM_READ_DQS_WIDTH
set_parameter_property MEM_READ_DQS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_READ_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_READ_DQS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_WRITE_DQS_WIDTH INTEGER 1
set_parameter_property MEM_WRITE_DQS_WIDTH DISPLAY_NAME MEM_WRITE_DQS_WIDTH
set_parameter_property MEM_WRITE_DQS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_WRITE_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_WRITE_DQS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter AFI_RATIO INTEGER 2
set_parameter_property AFI_RATIO DISPLAY_NAME AFI_RATIO
set_parameter_property AFI_RATIO AFFECTS_ELABORATION true
set_parameter_property AFI_RATIO HDL_PARAMETER true
set_parameter_property AFI_RATIO ALLOWED_RANGES {1:4}

add_parameter AC_BUS_WIDTH INTEGER 27
set_parameter_property AC_BUS_WIDTH DISPLAY_NAME AC_BUS_WIDTH
set_parameter_property AC_BUS_WIDTH AFFECTS_ELABORATION true
set_parameter_property AC_BUS_WIDTH HDL_PARAMETER true
set_parameter_property AC_BUS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter HCX_COMPAT_MODE boolean "FALSE"
set_parameter_property HCX_COMPAT_MODE DISPLAY_NAME HCX_COMPAT_MODE
set_parameter_property HCX_COMPAT_MODE HDL_PARAMETER true

add_parameter DEVICE_FAMILY string "STRATIXIII"
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

add_parameter AC_ROM_INIT_FILE_NAME string "AC_ROM.hex"
set_parameter_property AC_ROM_INIT_FILE_NAME HDL_PARAMETER true

add_parameter INST_ROM_INIT_FILE_NAME string "inst_ROM.hex"
set_parameter_property INST_ROM_INIT_FILE_NAME HDL_PARAMETER true

add_parameter DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT integer 0
set_parameter_property DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT HDL_PARAMETER true
set_parameter_property DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT DERIVED true

add_parameter DEBUG_WRITE_TO_READ_RATIO integer 0
set_parameter_property DEBUG_WRITE_TO_READ_RATIO HDL_PARAMETER true
set_parameter_property DEBUG_WRITE_TO_READ_RATIO DERIVED true

add_parameter MAX_DI_BUFFER_WORDS integer 4

add_parameter MAX_DI_BUFFER_WORDS_LOG_2 integer 2
set_parameter_property MAX_DI_BUFFER_WORDS_LOG_2 HDL_PARAMETER true
set_parameter_property MAX_DI_BUFFER_WORDS_LOG_2 DERIVED true

add_parameter USE_SHADOW_REGS BOOLEAN "FALSE"
set_parameter_property USE_SHADOW_REGS DISPLAY_NAME USE_SHADOW_REGS
set_parameter_property USE_SHADOW_REGS AFFECTS_ELABORATION true

add_parameter MRS_MIRROR_PING_PONG_ATSO BOOLEAN "FALSE"
set_parameter_property MRS_MIRROR_PING_PONG_ATSO HDL_PARAMETER false
set_parameter_property MRS_MIRROR_PING_PONG_ATSO AFFECTS_ELABORATION true

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
	
	set dq_per_read_dqs [expr {[get_parameter_value MEM_DQ_WIDTH] / [get_parameter_value MEM_READ_DQS_WIDTH]}]

	set write_to_debug_read_ratio [expr { ceil ($dq_per_read_dqs * 2 * [get_parameter_value AFI_RATIO] / 32.0)}]
	if {$write_to_debug_read_ratio < 1} {
		set write_to_debug_read_ratio 0
		set write_to_debug_read_ratio_log_2 0
	} else {
		set write_to_debug_read_ratio_log_2 [expr {ceil ( [::alt_mem_if::util::hwtcl_utils::log2 $write_to_debug_read_ratio] ) } ]
	}
	set_parameter_value DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT $write_to_debug_read_ratio_log_2
	set_parameter_value DEBUG_WRITE_TO_READ_RATIO $write_to_debug_read_ratio

	set max_di_buffer_words_log_2 [expr {ceil ( [::alt_mem_if::util::hwtcl_utils::log2 [get_parameter_value MAX_DI_BUFFER_WORDS]] ) } ]

	if {$max_di_buffer_words_log_2 <= $write_to_debug_read_ratio_log_2} {
		set max_di_buffer_words_log_2 [expr {$write_to_debug_read_ratio_log_2 + 1}]
	}

	set_parameter_value MAX_DI_BUFFER_WORDS_LOG_2 $max_di_buffer_words_log_2

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	::alt_mem_if::gen::uniphy_interfaces::basic_sequencer_manager_interfaces

	add_interface afi_clk clock end
	set_interface_property afi_clk ENABLED true
	add_interface_port afi_clk afi_clk clk Input 1

	add_interface afi_reset reset end
	set_interface_property afi_reset ENABLED true
	set_interface_property afi_reset synchronousEdges NONE
	add_interface_port afi_reset afi_reset_n reset_n Input 1

	add_interface afi conduit end
	
	set_interface_property afi ENABLED true
	
	add_interface_port afi afi_addr afi_addr Output [expr {[get_parameter_value MEM_ADDRESS_WIDTH] * [get_parameter_value AFI_RATIO]} ]
	add_interface_port afi afi_ba afi_ba Output [expr {[get_parameter_value MEM_BANK_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_cs_n afi_cs_n Output [expr {[get_parameter_value MEM_CHIP_SELECT_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_cke afi_cke Output  [expr {[get_parameter_value MEM_CLK_EN_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_odt afi_odt Output [expr {[get_parameter_value MEM_ODT_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_ras_n afi_ras_n Output [expr {[get_parameter_value MEM_CONTROL_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_cas_n afi_cas_n Output [expr {[get_parameter_value MEM_CONTROL_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_we_n afi_we_n Output [expr {[get_parameter_value MEM_CONTROL_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_dqs_burst afi_dqs_burst Output [expr {[get_parameter_value MEM_WRITE_DQS_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_rst_n afi_rst_n Output [expr {[get_parameter_value MEM_CONTROL_WIDTH] * [get_parameter_value AFI_RATIO]}]
	add_interface_port afi afi_wdata afi_wdata Output [expr {[get_parameter_value MEM_DQ_WIDTH] * 2 * [get_parameter_value AFI_RATIO]} ]
	add_interface_port afi afi_wdata_valid afi_wdata_valid Output [expr {[get_parameter_value MEM_WRITE_DQS_WIDTH] * [get_parameter_value AFI_RATIO]} ]
	add_interface_port afi afi_dm afi_dm Output [expr {[get_parameter_value MEM_DM_WIDTH] * 2 * [get_parameter_value AFI_RATIO]} ]
	add_interface_port afi afi_rdata_en afi_rdata_en Output [get_parameter_value AFI_RATIO]
	add_interface_port afi afi_rdata_en_full afi_rdata_en_full Output [get_parameter_value AFI_RATIO]
	add_interface_port afi afi_rdata afi_rdata Input [expr {[get_parameter_value MEM_DQ_WIDTH] * 2 * [get_parameter_value AFI_RATIO]} ]
	add_interface_port afi afi_rdata_valid afi_rdata_valid Input [get_parameter_value AFI_RATIO]

	add_interface_port afi afi_rrank afi_rrank Output [expr {[get_parameter_value MEM_READ_DQS_WIDTH] * [get_parameter_value MEM_NUMBER_OF_RANKS] * [get_parameter_value AFI_RATIO]} ]
	add_interface_port afi afi_wrank afi_wrank Output [expr {[get_parameter_value MEM_WRITE_DQS_WIDTH] * [get_parameter_value MEM_NUMBER_OF_RANKS] * [get_parameter_value AFI_RATIO]} ]
	
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
		set_port_property afi_rrank termination false
		set_port_property afi_wrank termination false
	} else {
		set_port_property afi_rrank termination true
		set_port_property afi_rrank termination_value 0
		set_port_property afi_wrank termination true
		set_port_property afi_wrank termination_value 0
	}
		
	foreach port_name [get_interface_ports afi] {
		set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
	}
	
	add_interface csr conduit end
	
	set_interface_property csr ENABLED true
	
	add_interface_port csr csr_clk csr_clk Input 1
	add_interface_port csr csr_ena csr_ena Input 1
	add_interface_port csr csr_dout_phy csr_dout_phy Input 1
	add_interface_port csr csr_dout csr_dout Output 1
}
