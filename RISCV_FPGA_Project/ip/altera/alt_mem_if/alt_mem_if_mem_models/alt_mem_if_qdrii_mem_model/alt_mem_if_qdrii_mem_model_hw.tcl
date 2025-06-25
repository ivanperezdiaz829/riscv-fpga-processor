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
package require alt_mem_if::gui::system_info
package require alt_mem_if::gui::qdrii_mem_model
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Altera QDR II/II+ Memory Model for UniPHY"
set_module_property NAME altera_mem_if_qdrii_mem_model
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_models_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera QDR II/II+ Memory Model for UniPHY"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL alt_mem_if_qdrii_mem_model_top

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL alt_mem_if_qdrii_mem_model_top

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL alt_mem_if_qdrii_mem_model_top


proc generate_vhdl_sim {name} {
	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	add_fileset_file [file join mentor alt_mem_if_qdrii_mem_model_top.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor alt_mem_if_qdrii_mem_model_top.sv] {MENTOR_SPECIFIC}
	add_fileset_file alt_mem_if_qdrii_mem_model_top.sv SYSTEM_VERILOG PATH alt_mem_if_qdrii_mem_model_top.sv $non_encryp_simulators

	add_fileset_file [file join mentor alt_mem_if_qdrii_mem_model.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor alt_mem_if_qdrii_mem_model.sv] {MENTOR_SPECIFIC}
	add_fileset_file alt_mem_if_qdrii_mem_model.sv SYSTEM_VERILOG PATH alt_mem_if_qdrii_mem_model.sv $non_encryp_simulators
}

proc generate_verilog_sim {name} {
	add_fileset_file alt_mem_if_qdrii_mem_model_top.sv SYSTEM_VERILOG PATH alt_mem_if_qdrii_mem_model_top.sv
	if {[string compare -nocase [get_parameter_value MEM_USE_DENALI_MODEL] "false"] == 0} {
		add_fileset_file alt_mem_if_qdrii_mem_model.sv SYSTEM_VERILOG PATH alt_mem_if_qdrii_mem_model.sv 
	} else {
		if {[string compare -nocase [get_parameter_value QDRII_PLUS_MODE] "false"] == 0} {
			add_fileset_file denali_qdrii_mem_model.sv SYSTEM_VERILOG PATH denali_qdrii_mem_model.sv 
		} else {
			add_fileset_file denali_qdriiplus_mem_model.sv SYSTEM_VERILOG PATH denali_qdriiplus_mem_model.sv
		}
	}
}

proc generate_synth {name} {
	_error "[get_module_property DESCRIPTION] does not support the QUARTUS_SYNTH fileset"
}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for alt_mem_if_qdrii_mem_model"	

	set_parameter_property DEVICE_WIDTH HDL_PARAMETER true
	set_parameter_property DEVICE_DEPTH HDL_PARAMETER true

	set_parameter_property MEM_IF_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DM_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CONTROL_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_READ_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH HDL_PARAMETER true

	set_parameter_property MEM_BURST_LENGTH HDL_PARAMETER true

	set_parameter_property MEM_EMULATED_READ_GROUPS HDL_PARAMETER true

	set_parameter_property MEM_T_WL HDL_PARAMETER true
	set_parameter_property MEM_T_RL HDL_PARAMETER true

	set_parameter_property MEM_USE_DENALI_MODEL HDL_PARAMETER true
	set_parameter_property QDRII_PLUS_MODE HDL_PARAMETER true
	set_parameter_property MEM_DENALI_SOMA_FILE HDL_PARAMETER true
	
	set_parameter_property MEM_SUPPRESS_CMD_TIMING_ERROR HDL_PARAMETER true
	set_parameter_property MEM_VERBOSE HDL_PARAMETER true
	
	return 1
}

alt_mem_if::gui::qdrii_mem_model::create_parameters
alt_mem_if::gui::system_info::create_parameters

create_hdl_parameters

alt_mem_if::gui::system_info::create_gui
alt_mem_if::gui::qdrii_mem_model::create_gui
alt_mem_if::gui::qdrii_mem_model::create_diagnostics_gui

set_parameter_property SPEED_GRADE VISIBLE false
set_parameter_property HARD_EMIF VISIBLE false


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

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::qdrii_mem_model::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::qdrii_mem_model::elaborate_component

	add_interface memory conduit end
	
	set_interface_property memory ENABLED true
	
	add_interface_port memory mem_a mem_a Input [get_parameter_value MEM_IF_ADDR_WIDTH]
	add_interface_port memory mem_bws_n mem_bws_n Input [get_parameter_value MEM_IF_DM_WIDTH]
	add_interface_port memory mem_cq mem_cq Output [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port memory mem_cqn mem_cq_n Output [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	if {[string compare -nocase [get_parameter_value NO_COMPLIMENTARY_STROBE] "true"] == 0} {
		if {[get_parameter_value MEM_T_RL] == 2} {
			set_port_property mem_cq termination true
		} else {
			set_port_property mem_cqn termination true
		}
	}
	add_interface_port memory mem_d mem_d Input [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port memory mem_k mem_k Input [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	add_interface_port memory mem_k_n mem_k_n Input [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	add_interface_port memory mem_q mem_q Output [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port memory mem_wps_n mem_wps_n Input [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_rps_n mem_rps_n Input [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_doff_n mem_doff_n Input [get_parameter_value MEM_IF_CONTROL_WIDTH]

	foreach port_name [get_interface_ports memory] {
		set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
	}

}

