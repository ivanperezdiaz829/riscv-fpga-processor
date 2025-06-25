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
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera DDR3 Memory Model for UniPHY"
set_module_property NAME altera_mem_if_ddr3_mem_model
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_models_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera DDR3 Memory Model for UniPHY"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim

add_fileset quartus_synth QUARTUS_SYNTH generate_synth

proc solve_core_params {} {
	set supported_ifdefs_list [list \
		"DDR3" \
		"LPDDR2" \
		"MEM_IF_DQSN_EN"\
		"MEM_IF_DM_PINS_EN"\
		"AC_PARITY"\
		"RDIMM"\
		"LRDIMM"\
		"UDIMM"
	]
	
	set core_params_list [list \
		"DDR3" \
		"MEM_IF_DQSN_EN"\
	]

	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		lappend core_params_list "MEM_IF_DM_PINS_EN"
	}
	
	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
		lappend core_params_list "RDIMM"
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			lappend core_params_list "AC_PARITY"
		}
	} elseif {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
		lappend core_params_list "LRDIMM"
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			lappend core_params_list "AC_PARITY"
		}
	} elseif {[string compare -nocase [get_parameter_value MEM_FORMAT] "UNBUFFERED"] == 0} {
		lappend core_params_list "UDIMM"
	} 

	return $core_params_list
}


proc generate_vhdl_sim {name} {
	_iprint "Preparing to generate VHDL simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_ddr3_mem_model_top.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file $non_encryp_simulators

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_common_ddr_mem_model.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join ".." common mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file SYSTEM_VERILOG PATH [file join ".." common $generated_file] $non_encryp_simulators
}

proc generate_verilog_sim {name} {
	_iprint "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_ddr3_mem_model_top.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_common_ddr_mem_model.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH [file join ".." common $generated_file]
	
}

proc generate_synth {name} {
	_error "[get_module_property DESCRIPTION] does not support the QUARTUS_SYNTH fileset"
}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for alt_mem_if_ddr3_mem_model"	

	set_parameter_property DEVICE_DEPTH HDL_PARAMETER true
	set_parameter_property DEVICE_WIDTH HDL_PARAMETER true

	set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ROW_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_COL_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CK_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CLK_EN_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CONTROL_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ODT_WIDTH HDL_PARAMETER true

	set_parameter_property MEM_MIRROR_ADDRESSING_DEC HDL_PARAMETER true

	set_parameter_property MEM_TRCD HDL_PARAMETER true
	set_parameter_property MEM_TRTP HDL_PARAMETER true
	set_parameter_property MEM_DQS_TO_CLK_CAPTURE_DELAY HDL_PARAMETER true
	set_parameter_property MEM_CLK_TO_DQS_CAPTURE_DELAY HDL_PARAMETER true
	set_parameter_property MEM_GUARANTEED_WRITE_INIT HDL_PARAMETER true

	set_parameter_property MEM_REGDIMM_ENABLED HDL_PARAMETER true
	set_parameter_property MEM_LRDIMM_ENABLED HDL_PARAMETER true
	set_parameter_property MEM_NUMBER_OF_DIMMS HDL_PARAMETER true
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM HDL_PARAMETER true
	set_parameter_property MEM_RANK_MULTIPLICATION_FACTOR HDL_PARAMETER true
	set_parameter_property MEM_INIT_EN HDL_PARAMETER true
	set_parameter_property MEM_INIT_FILE HDL_PARAMETER true
	set_parameter_property DAT_DATA_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_VERBOSE HDL_PARAMETER true

	set_parameter_property REFRESH_BURST_VALIDATION HDL_PARAMETER true

}


alt_mem_if::gui::afi::set_protocol "DDR3"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR3"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters

create_hdl_parameters

alt_mem_if::gui::system_info::create_gui
alt_mem_if::gui::afi::create_gui
alt_mem_if::gui::common_ddr_mem_model::create_gui
alt_mem_if::gui::common_ddr_mem_model::create_diagnostics_gui

set_parameter_property NEXTGEN VISIBLE false
set_parameter_property RATE VISIBLE false
set_parameter_property MEM_CLK_FREQ VISIBLE false
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
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component

	add_interface memory conduit end
	
	set_interface_property memory ENABLED true

        if {[string compare -nocase [get_parameter_value ALTMEMPHY_COMPATIBLE_MODE] "true"] == 0} {
                add_interface_port memory mem_a mem_addr Input [get_parameter_value MEM_IF_ADDR_WIDTH]
        } else {
                add_interface_port memory mem_a mem_a Input [get_parameter_value MEM_IF_ADDR_WIDTH]
        }
	add_interface_port memory mem_ba mem_ba Input [get_parameter_value MEM_IF_BANKADDR_WIDTH]
	if {[string compare -nocase [get_parameter_value ALTMEMPHY_COMPATIBLE_MODE] "true"] == 0} {
		add_interface_port memory mem_ck mem_clk Bidir [get_parameter_value MEM_IF_CK_WIDTH]
		add_interface_port memory mem_ck_n mem_clk_n Bidir [get_parameter_value MEM_IF_CK_WIDTH]
	} else {
		add_interface_port memory mem_ck mem_ck Input [get_parameter_value MEM_IF_CK_WIDTH]
		add_interface_port memory mem_ck_n mem_ck_n Input [get_parameter_value MEM_IF_CK_WIDTH]
	}
	add_interface_port memory mem_cke mem_cke Input [get_parameter_value MEM_IF_CLK_EN_WIDTH]
	add_interface_port memory mem_cs_n mem_cs_n Input [get_parameter_value MEM_IF_CS_WIDTH]
	add_interface_port memory mem_dm mem_dm Input [get_parameter_value MEM_IF_DM_WIDTH]
	set_port_property mem_dm VHDL_TYPE std_logic_vector
	add_interface_port memory mem_ras_n mem_ras_n Input [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_cas_n mem_cas_n Input [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_we_n mem_we_n Input [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_reset_n mem_reset_n Input 1
	add_interface_port memory mem_dq mem_dq Bidir [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port memory mem_dqs mem_dqs Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
        if {[string compare -nocase [get_parameter_value ALTMEMPHY_COMPATIBLE_MODE] "true"] == 0} {
                add_interface_port memory mem_dqs_n mem_dqsn Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
        } else {
                add_interface_port memory mem_dqs_n mem_dqs_n Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
        }
	add_interface_port memory mem_odt mem_odt Input [get_parameter_value MEM_IF_ODT_WIDTH]

	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] != 0} {
		set_port_property mem_dm termination true
		set_port_property mem_dm termination_value 0
	}
	
	if {([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			add_interface_port memory mem_ac_parity mem_ac_parity Input 1
			add_interface_port memory mem_err_out_n mem_err_out_n Output 1
                        if {[string compare -nocase [get_parameter_value ALTMEMPHY_COMPATIBLE_MODE] "true"] == 0} {
                                add_interface_port memory mem_parity_error_n parity_error_n Input 1
                        } else {
                                add_interface_port memory mem_parity_error_n mem_parity_error_n Input 1
                        }

		}
	}

	foreach port_name [get_interface_ports memory] {
		if {[regexp -nocase {mem_ac_parity|mem_err_out_n|mem_parity_error_n|mem_reset_n} $port_name match] == 0} {
			set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
		}
	}

	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_ddr3_mem_model_top.sv" [solve_core_params] 1]
	}

}

