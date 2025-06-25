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

set_module_property NAME sequencer_phy_mgr_100
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property DISPLAY_NAME "UniPHY PHY Manager (10.0 Version)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL sequencer_phy_mgr

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL sequencer_phy_mgr

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL sequencer_phy_mgr


proc generate_verilog_fileset {} {
	set file_list [list \
		sequencer_phy_mgr.sv \
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

add_parameter MAX_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property MAX_LATENCY_COUNT_WIDTH DISPLAY_NAME MAX_LATENCY_COUNT_WIDTH
set_parameter_property MAX_LATENCY_COUNT_WIDTH AFFECTS_ELABORATION true
set_parameter_property MAX_LATENCY_COUNT_WIDTH HDL_PARAMETER true
set_parameter_property MAX_LATENCY_COUNT_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_IF_READ_DQS_WIDTH INTEGER 1
set_parameter_property MEM_IF_READ_DQS_WIDTH DISPLAY_NAME MEM_IF_READ_DQS_WIDTH
set_parameter_property MEM_IF_READ_DQS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_IF_READ_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_READ_DQS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_IF_WRITE_DQS_WIDTH INTEGER 1
set_parameter_property MEM_IF_WRITE_DQS_WIDTH DISPLAY_NAME MEM_IF_WRITE_DQS_WIDTH
set_parameter_property MEM_IF_WRITE_DQS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_IF_WRITE_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_WRITE_DQS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter AFI_DQ_WIDTH INTEGER 64
set_parameter_property AFI_DQ_WIDTH DISPLAY_NAME AFI_DQ_WIDTH
set_parameter_property AFI_DQ_WIDTH AFFECTS_ELABORATION true
set_parameter_property AFI_DQ_WIDTH HDL_PARAMETER true
set_parameter_property AFI_DQ_WIDTH ALLOWED_RANGES {1:1152}

add_parameter AFI_DEBUG_INFO_WIDTH INTEGER 32
set_parameter_property AFI_DEBUG_INFO_WIDTH DISPLAY_NAME AFI_DEBUG_INFO_WIDTH
set_parameter_property AFI_DEBUG_INFO_WIDTH AFFECTS_ELABORATION true
set_parameter_property AFI_DEBUG_INFO_WIDTH HDL_PARAMETER true
set_parameter_property AFI_DEBUG_INFO_WIDTH ALLOWED_RANGES {1:1024}

add_parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH DISPLAY_NAME AFI_MAX_WRITE_LATENCY_COUNT_WIDTH
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH AFFECTS_ELABORATION true
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH HDL_PARAMETER true
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH ALLOWED_RANGES {1:1024}

add_parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH DISPLAY_NAME AFI_MAX_READ_LATENCY_COUNT_WIDTH
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH AFFECTS_ELABORATION true
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH HDL_PARAMETER true
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH ALLOWED_RANGES {1:1024}

add_parameter CALIB_VFIFO_OFFSET INTEGER 14
set_parameter_property CALIB_VFIFO_OFFSET DISPLAY_NAME CALIB_VFIFO_OFFSET
set_parameter_property CALIB_VFIFO_OFFSET HDL_PARAMETER true
set_parameter_property CALIB_VFIFO_OFFSET ALLOWED_RANGES {1:1024}

add_parameter CALIB_LFIFO_OFFSET INTEGER 5
set_parameter_property CALIB_LFIFO_OFFSET DISPLAY_NAME CALIB_LFIFO_OFFSET
set_parameter_property CALIB_LFIFO_OFFSET HDL_PARAMETER true
set_parameter_property CALIB_LFIFO_OFFSET ALLOWED_RANGES {1:1024}

add_parameter CALIB_REG_WIDTH INTEGER 8
set_parameter_property CALIB_REG_WIDTH DISPLAY_NAME CALIB_REG_WIDTH
set_parameter_property CALIB_REG_WIDTH AFFECTS_ELABORATION true
set_parameter_property CALIB_REG_WIDTH HDL_PARAMETER true
set_parameter_property CALIB_REG_WIDTH ALLOWED_RANGES {1:1024}

add_parameter READ_VALID_FIFO_SIZE INTEGER 16
set_parameter_property READ_VALID_FIFO_SIZE DISPLAY_NAME READ_VALID_FIFO_SIZE
set_parameter_property READ_VALID_FIFO_SIZE HDL_PARAMETER true
set_parameter_property READ_VALID_FIFO_SIZE ALLOWED_RANGES {1:1024}

add_parameter MEM_T_WL INTEGER 5
set_parameter_property MEM_T_WL DISPLAY_NAME MEM_T_WL
set_parameter_property MEM_T_WL HDL_PARAMETER true
set_parameter_property MEM_T_WL ALLOWED_RANGES {0:1024}

add_parameter MEM_T_RL INTEGER 7
set_parameter_property MEM_T_RL DISPLAY_NAME MEM_T_RL
set_parameter_property MEM_T_RL WIDTH 1
set_parameter_property MEM_T_RL HDL_PARAMETER true
set_parameter_property MEM_T_RL ALLOWED_RANGES {1:1024}

add_parameter CTL_REGDIMM_ENABLED boolean false
set_parameter_property CTL_REGDIMM_ENABLED DISPLAY_NAME CTL_REGDIMM_ENABLED
set_parameter_property CTL_REGDIMM_ENABLED HDL_PARAMETER true

add_parameter NUM_WRITE_FR_CYCLE_SHIFTS INTEGER 0
set_parameter_property NUM_WRITE_FR_CYCLE_SHIFTS DISPLAY_NAME MNUM_WRITE_FR_CYCLE_SHIFTS
set_parameter_property NUM_WRITE_FR_CYCLE_SHIFTS HDL_PARAMETER true
set_parameter_property NUM_WRITE_FR_CYCLE_SHIFTS ALLOWED_RANGES {-1:3}

add_parameter VFIFO_CONTROL_WIDTH_PER_DQS INTEGER 1
set_parameter_property VFIFO_CONTROL_WIDTH_PER_DQS DISPLAY_NAME VFIFO_CONTROL_WIDTH_PER_DQS
set_parameter_property VFIFO_CONTROL_WIDTH_PER_DQS AFFECTS_ELABORATION true
set_parameter_property VFIFO_CONTROL_WIDTH_PER_DQS HDL_PARAMETER true
set_parameter_property VFIFO_CONTROL_WIDTH_PER_DQS ALLOWED_RANGES {1:1024}

add_parameter DEVICE_FAMILY string ""
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

add_parameter HPS_PROTOCOL string "DDR3"
set_parameter_property HPS_PROTOCOL DISPLAY_NAME HPS_PROTOCOL
set_parameter_property HPS_PROTOCOL ALLOWED_RANGES {DDR2 DDR3 LPDDR2 LPDDR1 QDRII RLDRAMII RLDRAM3}

add_parameter HARD_PHY boolean false
set_parameter_property HARD_PHY DISPLAY_NAME "Enable hard PHY support"



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
	_dprint 1 "Running IP Elaboration"

	::alt_mem_if::gen::uniphy_interfaces::basic_sequencer_manager_interfaces

	::alt_mem_if::gen::uniphy_interfaces::phy_manager [get_parameter_value HPS_PROTOCOL] "sequencer"

	::alt_mem_if::gen::uniphy_interfaces::mux_selector "sequencer"

}
