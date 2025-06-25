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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::afi
package require alt_mem_if::util::iptclgen

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera Ping Pong PHY Memory Model Bridge"
set_module_property NAME altera_mem_if_pp_mem_model_bridge
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Ping Pong PHY Memory Model Bridge"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP


add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim

proc solve_core_params {} {
        set supported_ifdefs_list [list \
                "DDR3" \
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

        set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_pp_mem_model_bridge_top.sv" [solve_core_params]]
        _dprint 1 "Preparing to deploy file $generated_file"
        add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}

proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_pp_mem_model_bridge_top.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

}


proc create_hdl_parameters {} {

        _dprint 1 "Defining HDL parameters for [get_module_property NAME]"

        set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_DQS_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_BANKADDR_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_ADDR_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_CK_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_CLK_EN_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_DM_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_CONTROL_WIDTH HDL_PARAMETER true
        set_parameter_property MEM_IF_ODT_WIDTH HDL_PARAMETER true

        set_parameter_property USE_DQS_TRACKING HDL_PARAMETER true

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
set_parameter_property NEXTGEN VISIBLE false
set_parameter_property RATE VISIBLE false
set_parameter_property MEM_CLK_FREQ VISIBLE false
set_parameter_property SPEED_GRADE VISIBLE false




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
	_dprint 1 "Running IP Validation for [get_module_property NAME]"

        alt_mem_if::gui::system_info::validate_component
        alt_mem_if::gui::common_ddr_mem_model::validate_component
        alt_mem_if::gui::afi::validate_component
}

proc create_memory_interface {type {suffix {}}} {
    
	add_interface mem_${suffix} conduit end
	set_interface_property mem_${suffix} ENABLED true
	
	if {[string compare -nocase $type "output"] == 0} {
		set denom 2
	} else {
		set denom 1
	}

	add_interface_port mem_${suffix} mem_${suffix}_mem_a mem_a $type [get_parameter_value MEM_IF_ADDR_WIDTH]
    add_interface_port mem_${suffix} mem_${suffix}_mem_ba mem_ba $type [get_parameter_value MEM_IF_BANKADDR_WIDTH]
    add_interface_port mem_${suffix} mem_${suffix}_mem_ck mem_ck $type [get_parameter_value MEM_IF_CK_WIDTH]
    add_interface_port mem_${suffix} mem_${suffix}_mem_ck_n mem_ck_n $type [get_parameter_value MEM_IF_CK_WIDTH]
    add_interface_port mem_${suffix} mem_${suffix}_mem_cke mem_cke $type [expr [get_parameter_value MEM_IF_CLK_EN_WIDTH] / $denom]
	add_interface_port mem_${suffix} mem_${suffix}_mem_cs_n mem_cs_n $type [expr [get_parameter_value MEM_IF_CS_WIDTH] / $denom]
	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		add_interface_port mem_${suffix} mem_${suffix}_mem_dm mem_dm $type [expr [get_parameter_value MEM_IF_DM_WIDTH] / $denom]
	}
	add_interface_port mem_${suffix} mem_${suffix}_mem_ras_n mem_ras_n $type [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port mem_${suffix} mem_${suffix}_mem_cas_n mem_cas_n $type [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port mem_${suffix} mem_${suffix}_mem_we_n mem_we_n $type [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port mem_${suffix} mem_${suffix}_mem_reset_n mem_reset_n $type 1
	add_interface_port mem_${suffix} mem_${suffix}_mem_dq mem_dq Bidir [expr [get_parameter_value MEM_IF_DQ_WIDTH] / $denom]
	add_interface_port mem_${suffix} mem_${suffix}_mem_dqs mem_dqs Bidir [expr [get_parameter_value MEM_IF_DQS_WIDTH] / $denom]
	add_interface_port mem_${suffix} mem_${suffix}_mem_dqs_n mem_dqs_n Bidir [expr [get_parameter_value MEM_IF_DQS_WIDTH] / $denom]
	add_interface_port mem_${suffix} mem_${suffix}_mem_odt mem_odt $type [expr [get_parameter_value MEM_IF_ODT_WIDTH] / $denom]

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			add_interface_port mem_${suffix} mem_${suffix}_mem_ac_parity mem_ac_parity $type 1
			add_interface_port mem_${suffix} mem_${suffix}_mem_err_out_n mem_err_out_n [expr {[string compare -nocase $type "input"] == 0 ? "Output" : "Input"}] 1 
			add_interface_port mem_${suffix} mem_${suffix}_mem_parity_error_n mem_parity_error_n $type 1
		}
	}
}


proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"

        alt_mem_if::gui::system_info::elaborate_component
        alt_mem_if::gui::common_ddr_mem_model::elaborate_component
        alt_mem_if::gui::afi::elaborate_component

	create_memory_interface "Input" "in"

	create_memory_interface "Output" "lhs"
	create_memory_interface "Output" "rhs"

	foreach fset_name [list SIM_VERILOG SIM_VHDL] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_pp_mem_model_bridge_top.sv" [solve_core_params] 1]
	}

}
