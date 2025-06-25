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

package require -exact sopc 11.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera LPDDR2 Board Delay Model"
set_module_property NAME altera_lpddr2_board_delay_model
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Board Delay Models"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera LPDDR2 Board Delay Model"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_verilog SIM_VERILOG generate_verilog_sim

proc solve_core_params {} {
	set supported_ifdefs_list [list \
		"MEM_IF_DM_PINS_EN"\
		"AC_PARITY"\
	]
	
	set core_params_list [list]

	
	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		lappend core_params_list "MEM_IF_DM_PINS_EN"
	}
	
	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {

		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			lappend core_params_list "AC_PARITY"
		}
	}

	return $core_params_list

}


proc generate_verilog_sim {name} {
	_iprint "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_lpddr2_board_delay_model_top.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

	set common_files [list "bidir_delay.sv" "unidir_delay.sv" "altera_board_delay_util.sv"]
	set common_dir "../common"
	
	foreach file $common_files {
		add_fileset_file $file SYSTEM_VERILOG PATH [file join $common_dir $file]
	}
}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for altera_lpddr2_board_delay_model"	

	set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CK_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CLK_EN_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true

	set_parameter_property MEM_IF_BOARD_BASE_DELAY HDL_PARAMETER true
	set_parameter_property USE_DQS_TRACKING HDL_PARAMETER true
}




alt_mem_if::gui::afi::set_protocol "LPDDR2"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "LPDDR2"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters

create_hdl_parameters

alt_mem_if::gui::system_info::create_gui
alt_mem_if::gui::afi::create_gui
alt_mem_if::gui::common_ddr_mem_model::create_gui
set_parameter_property NEXTGEN VISIBLE false
set_parameter_property RATE VISIBLE false
set_parameter_property MEM_CLK_FREQ VISIBLE false
set_parameter_property SPEED_GRADE VISIBLE false

set_module_property Validation_Callback ip_validate
set_module_property elaboration_Callback ip_elaborate

proc ip_validate {} {
	_dprint 1 "Running IP Validation"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component

	
	add_interface board_to_phy conduit end
	
	set_interface_property board_to_phy ENABLED true

	add_interface_port board_to_phy tophy_mem_ca mem_ca Input [get_parameter_value MEM_IF_ADDR_WIDTH]
        add_interface_port board_to_phy tophy_mem_ck mem_ck Input [get_parameter_value MEM_IF_CK_WIDTH]
	add_interface_port board_to_phy tophy_mem_ck_n mem_ck_n Input [get_parameter_value MEM_IF_CK_WIDTH]
	add_interface_port board_to_phy tophy_mem_cke mem_cke Input [get_parameter_value MEM_IF_CLK_EN_WIDTH]
	add_interface_port board_to_phy tophy_mem_cs_n mem_cs_n Input [get_parameter_value MEM_IF_CS_WIDTH]
	add_interface_port board_to_phy tophy_mem_dm mem_dm Input [get_parameter_value MEM_IF_DM_WIDTH]
	add_interface_port board_to_phy tophy_mem_dq mem_dq Bidir [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port board_to_phy tophy_mem_dqs mem_dqs Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
	add_interface_port board_to_phy tophy_mem_dqs_n mem_dqs_n Bidir [get_parameter_value MEM_IF_DQS_WIDTH]

	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] != 0} {
		set_port_property tophy_mem_dm termination true
		set_port_property tophy_mem_dm termination_value 0
	}
	
	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			add_interface_port board_to_phy tophy_mem_ac_parity mem_ac_parity Input 1
			add_interface_port board_to_phy tophy_mem_err_out_n mem_err_out_n Output 1
			add_interface_port board_to_phy tophy_mem_parity_error_n mem_parity_error_n Input 1

		}
	}

	
	add_interface board_to_mem conduit end
	
	set_interface_property board_to_mem ENABLED true
	
	add_interface_port board_to_mem tomem_mem_ca mem_ca Output [get_parameter_value MEM_IF_ADDR_WIDTH]
	add_interface_port board_to_mem tomem_mem_ck mem_ck Output [get_parameter_value MEM_IF_CK_WIDTH]
	add_interface_port board_to_mem tomem_mem_ck_n mem_ck_n Output [get_parameter_value MEM_IF_CK_WIDTH]
	add_interface_port board_to_mem tomem_mem_cke mem_cke Output [get_parameter_value MEM_IF_CLK_EN_WIDTH]
	add_interface_port board_to_mem tomem_mem_cs_n mem_cs_n Output [get_parameter_value MEM_IF_CS_WIDTH]
	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		add_interface_port board_to_mem tomem_mem_dm mem_dm Output [get_parameter_value MEM_IF_DM_WIDTH]
	}
	add_interface_port board_to_mem tomem_mem_dq mem_dq Bidir [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port board_to_mem tomem_mem_dqs mem_dqs Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
	add_interface_port board_to_mem tomem_mem_dqs_n mem_dqs_n Bidir [get_parameter_value MEM_IF_DQS_WIDTH]

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			add_interface_port board_to_mem tomem_mem_ac_parity mem_ac_parity Output 1
			add_interface_port board_to_mem tomem_mem_err_out_n mem_err_out_n Input 1
			add_interface_port board_to_mem tomem_mem_parity_error_n mem_parity_error_n Output 1

		}
	}

	set_fileset_property [string tolower SIM_VERILOG] TOP_LEVEL \
	    [alt_mem_if::util::iptclgen::generate_outfile_name "altera_lpddr2_board_delay_model_top.sv" [solve_core_params] 1]
	
}

