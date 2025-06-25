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

set_module_property NAME sequencer_scc_mgr_110
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property DISPLAY_NAME "UniPHY Scan Chain Manager (10.0 Version)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL sequencer_scc_mgr
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL sequencer_scc_mgr
add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL sequencer_scc_mgr


proc generate_verilog_fileset {} {
	set file_list [list \
		sequencer_scc_mgr.sv \
		sequencer_scc_siii_wrapper.sv \
		sequencer_scc_siii_phase_decode.v \
		sequencer_scc_sv_wrapper.sv \
		sequencer_scc_sv_phase_decode.v \
		sequencer_scc_acv_wrapper.sv \
		sequencer_scc_acv_phase_decode.v \
		sequencer_scc_reg_file.v \
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

add_parameter MEM_IF_READ_DQS_WIDTH INTEGER 8
set_parameter_property MEM_IF_READ_DQS_WIDTH DISPLAY_NAME MEM_IF_READ_DQS_WIDTH
set_parameter_property MEM_IF_READ_DQS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_IF_READ_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_READ_DQS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_IF_WRITE_DQS_WIDTH INTEGER 8
set_parameter_property MEM_IF_WRITE_DQS_WIDTH DISPLAY_NAME MEM_IF_WRITE_DQS_WIDTH
set_parameter_property MEM_IF_WRITE_DQS_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_IF_WRITE_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_WRITE_DQS_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_IF_DQ_WIDTH INTEGER 64
set_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME MEM_IF_DQ_WIDTH
set_parameter_property MEM_IF_DQ_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_DQ_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_IF_DM_WIDTH INTEGER 8
set_parameter_property MEM_IF_DM_WIDTH DISPLAY_NAME MEM_IF_DM_WIDTH
set_parameter_property MEM_IF_DM_WIDTH AFFECTS_ELABORATION true
set_parameter_property MEM_IF_DM_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_DM_WIDTH ALLOWED_RANGES {1:1024}

add_parameter MEM_NUMBER_OF_RANKS INTEGER 1
set_parameter_property MEM_NUMBER_OF_RANKS DISPLAY_NAME MEM_NUMBER_OF_RANKS
set_parameter_property MEM_NUMBER_OF_RANKS AFFECTS_ELABORATION true
set_parameter_property MEM_NUMBER_OF_RANKS HDL_PARAMETER true
set_parameter_property MEM_NUMBER_OF_RANKS ALLOWED_RANGES {1:1024}

add_parameter DLL_DELAY_CHAIN_LENGTH INTEGER 6
set_parameter_property DLL_DELAY_CHAIN_LENGTH DISPLAY_NAME DLL_DELAY_CHAIN_LENGTH
set_parameter_property DLL_DELAY_CHAIN_LENGTH AFFECTS_ELABORATION true
set_parameter_property DLL_DELAY_CHAIN_LENGTH HDL_PARAMETER true
set_parameter_property DLL_DELAY_CHAIN_LENGTH ALLOWED_RANGES {1:1024}

add_parameter FAMILY STRING STRATIXIII
set_parameter_property FAMILY DEFAULT_VALUE STRATIXIII
set_parameter_property FAMILY DISPLAY_NAME FAMILY
set_parameter_property FAMILY TYPE STRING
set_parameter_property FAMILY UNITS None
set_parameter_property FAMILY AFFECTS_GENERATION false
set_parameter_property FAMILY HDL_PARAMETER true
set_parameter_property FAMILY ALLOWED_RANGES {"STRATIXIII" "STRATIXIV" "STRATIXV" "ARRIAIIGX" "ARRIAIIGZ" "ARRIAV" "CYCLONEV" "ARRIAVGZ"}

add_parameter USE_2X_DLL STRING "false"
set_parameter_property USE_2X_DLL DEFAULT_VALUE "false"
set_parameter_property USE_2X_DLL DISPLAY_NAME USE_2X_DLL
set_parameter_property USE_2X_DLL TYPE STRING
set_parameter_property USE_2X_DLL UNITS None
set_parameter_property USE_2X_DLL AFFECTS_GENERATION false
set_parameter_property USE_2X_DLL HDL_PARAMETER true
set_parameter_property USE_2X_DLL ALLOWED_RANGES {"false" "true"}

add_parameter USE_SHADOW_REGS BOOLEAN "FALSE"
set_parameter_property USE_SHADOW_REGS DISPLAY_NAME USE_SHADOW_REGS
set_parameter_property USE_SHADOW_REGS AFFECTS_ELABORATION true
set_parameter_property USE_SHADOW_REGS HDL_PARAMETER true

add_parameter USE_DQS_TRACKING INTEGER 0
set_parameter_property USE_DQS_TRACKING DISPLAY_NAME USE_DQS_TRACKING
set_parameter_property USE_DQS_TRACKING AFFECTS_ELABORATION true
set_parameter_property USE_DQS_TRACKING HDL_PARAMETER true
set_parameter_property USE_DQS_TRACKING ALLOWED_RANGES {0:1}

add_parameter DUAL_WRITE_CLOCK INTEGER 0
set_parameter_property DUAL_WRITE_CLOCK DISPLAY_NAME DUAL_WRITE_CLOCK
set_parameter_property DUAL_WRITE_CLOCK AFFECTS_ELABORATION true
set_parameter_property DUAL_WRITE_CLOCK HDL_PARAMETER true
set_parameter_property DUAL_WRITE_CLOCK ALLOWED_RANGES {0:1}

add_parameter SCC_DATA_WIDTH INTEGER 8
set_parameter_property SCC_DATA_WIDTH DISPLAY_NAME SCC_DATA_WIDTH
set_parameter_property SCC_DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property SCC_DATA_WIDTH HDL_PARAMETER true
set_parameter_property SCC_DATA_WIDTH ALLOWED_RANGES {1:1024}

add_parameter TRK_PARALLEL_SCC_LOAD BOOLEAN "FALSE"
set_parameter_property TRK_PARALLEL_SCC_LOAD DISPLAY_NAME TRK_PARALLEL_SCC_LOAD
set_parameter_property TRK_PARALLEL_SCC_LOAD AFFECTS_ELABORATION true
set_parameter_property TRK_PARALLEL_SCC_LOAD HDL_PARAMETER true

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

	add_interface scc_clk clock end
	set_interface_property scc_clk ENABLED true
	add_interface_port scc_clk scc_clk clk Input 1

	add_interface scc_reset reset end
	set_interface_property scc_reset ENABLED true
	set_interface_property scc_reset synchronousEdges NONE
	add_interface_port scc_reset scc_reset_n reset_n Input 1

	::alt_mem_if::gen::uniphy_interfaces::scc_manager "scc"

	::alt_mem_if::gen::uniphy_interfaces::afi_init_cal_req "sequencer"

}



