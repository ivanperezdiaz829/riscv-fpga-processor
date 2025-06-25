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
package require alt_mem_if::gui::common_rldram_mem_model
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Altera RLDRAM II Board Memory Model"
set_module_property NAME altera_rldramii_board_delay_model
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Board Delay Models"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera RLDRAM II Board Delay Model"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_rldramii_board_delay_model_top

proc generate_verilog_sim {name} {
	add_fileset_file altera_rldramii_board_delay_model_top.sv SYSTEM_VERILOG PATH altera_rldramii_board_delay_model_top.sv {SIMULATION}

	set common_files [list "unidir_delay.sv" "bidir_delay.sv" "altera_board_delay_util.sv"]
	set common_dir "../common"
	
	foreach file $common_files {
		add_fileset_file $file SYSTEM_VERILOG PATH [file join $common_dir $file]
	}
}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for altera_rldramii_board_delay_model"	

	set_parameter_property MEM_IF_WRITE_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DM_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_READ_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true

	set_parameter_property MEM_IF_BOARD_BASE_DELAY HDL_PARAMETER true

	return 1
}


alt_mem_if::gui::common_rldram_mem_model::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_mem_model::create_parameters
create_hdl_parameters
alt_mem_if::gui::common_rldram_mem_model::create_gui

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

	alt_mem_if::gui::common_rldram_mem_model::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::common_rldram_mem_model::elaborate_component


	add_interface board_to_phy conduit end
	
	set_interface_property board_to_phy ENABLED true
	
	add_interface_port board_to_phy tophy_mem_a mem_a Input [get_parameter_value MEM_IF_ADDR_WIDTH]
	add_interface_port board_to_phy tophy_mem_ba mem_ba Input [get_parameter_value MEM_IF_BANKADDR_WIDTH]
	add_interface_port board_to_phy tophy_mem_ck mem_ck Input 1
	add_interface_port board_to_phy tophy_mem_ck_n mem_ck_n Input 1
	add_interface_port board_to_phy tophy_mem_cs_n mem_cs_n Input [get_parameter_value MEM_IF_CS_WIDTH]
	add_interface_port board_to_phy tophy_mem_dk mem_dk Input [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	add_interface_port board_to_phy tophy_mem_dk_n mem_dk_n Input [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	add_interface_port board_to_phy tophy_mem_dm mem_dm Input [get_parameter_value MEM_IF_DM_WIDTH]
	add_interface_port board_to_phy tophy_mem_dq mem_dq Bidir [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port board_to_phy tophy_mem_qk mem_qk Output [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port board_to_phy tophy_mem_qk_n mem_qk_n Output [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port board_to_phy tophy_mem_ref_n mem_ref_n Input 1
	add_interface_port board_to_phy tophy_mem_we_n mem_we_n Input 1


	add_interface board_to_mem conduit end
	
	set_interface_property board_to_mem ENABLED true
	
	add_interface_port board_to_mem tomem_mem_a mem_a Output [get_parameter_value MEM_IF_ADDR_WIDTH]
	add_interface_port board_to_mem tomem_mem_ba mem_ba Output [get_parameter_value MEM_IF_BANKADDR_WIDTH]
	add_interface_port board_to_mem tomem_mem_ck mem_ck Output 1
	add_interface_port board_to_mem tomem_mem_ck_n mem_ck_n Output 1
	add_interface_port board_to_mem tomem_mem_cs_n mem_cs_n Output [get_parameter_value MEM_IF_CS_WIDTH]
	add_interface_port board_to_mem tomem_mem_dk mem_dk Output [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	add_interface_port board_to_mem tomem_mem_dk_n mem_dk_n Output [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	add_interface_port board_to_mem tomem_mem_dm mem_dm Output [get_parameter_value MEM_IF_DM_WIDTH]
	add_interface_port board_to_mem tomem_mem_dq mem_dq Bidir [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port board_to_mem tomem_mem_qk mem_qk Input [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port board_to_mem tomem_mem_qk_n mem_qk_n Input [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port board_to_mem tomem_mem_ref_n mem_ref_n Output 1
	add_interface_port board_to_mem tomem_mem_we_n mem_we_n Output 1
}

