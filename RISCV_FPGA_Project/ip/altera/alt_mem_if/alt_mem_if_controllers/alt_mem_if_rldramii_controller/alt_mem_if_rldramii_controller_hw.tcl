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
package require alt_mem_if::util::qini
package require alt_mem_if::gui::common_rldram_mem_model
package require alt_mem_if::gui::common_rldram_controller_phy
package require alt_mem_if::gui::common_rldram_controller
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera RLDRAM II Memory Controller"
set_module_property NAME altera_mem_if_rldramii_controller
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_controller_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera RLDRAM II Memory Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc solve_core_params {} {

	set core_params_list [list]

	if {[get_parameter_value CTL_BURST_LENGTH] == 1} {
		lappend core_params_list "CTL_BL_IS_ONE"
	}

	if {[get_parameter_value CTL_LATENCY] == 1} {
		lappend core_params_list "DEC_LAT"
	}
	
	if {[string compare -nocase [get_parameter_value ERROR_DETECTION_PARITY] "true"] == 0} {
		lappend core_params_list "ERR_DET_PAR"
	}

	if {[string compare -nocase [get_parameter_value USER_REFRESH] "true"] == 0} {
		lappend core_params_list "URFSH"
	}

	return $core_params_list
	
}


proc generate_verilog_fileset {name} {

	set core_params_list [solve_core_params]

	set inhdl_files_list [list \
		alt_rld_controller.sv \
		alt_rld_controller_top.sv \
	]

	set generated_files_list [list]

	foreach ifdef_source_file $inhdl_files_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $ifdef_source_file $core_params_list]
		lappend generated_files_list $generated_file
	}

	set inhdl_files_list [list \
		alt_rld_afi.sv \
		alt_rld_fsm.sv \
	]

	set core_params_list [list]
	if {[get_parameter_value CTL_BURST_LENGTH] == 1} {
		lappend core_params_list "CTL_BL_IS_ONE"
	}
	foreach ifdef_source_file $inhdl_files_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $ifdef_source_file $core_params_list]
		lappend generated_files_list $generated_file
	}

	lappend generated_files_list "alt_rld_bank_timer.sv"
	lappend generated_files_list "alt_rld_timers.sv"
	if {[string compare -nocase [get_parameter_value USER_REFRESH] "false"] == 0} {
		lappend generated_files_list "alt_rld_refresh.sv"
	}

	lappend generated_files_list "../common/memctl_beat_valid_fifo.sv"
	lappend generated_files_list "../common/memctl_parity.sv"
	lappend generated_files_list "../common/memctl_reset_sync.v"
	lappend generated_files_list "../common/memctl_wdata_fifo.sv"
	lappend generated_files_list "../common/memctl_wdata_rdata_logic.sv"

	set core_params_list [list]
	if {[get_parameter_value CTL_BURST_LENGTH] == 1} {
		lappend core_params_list "CTL_BL_IS_ONE"
	}
	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name ../common/memctl_burst_latency_shifter.sv $core_params_list]
	lappend generated_files_list $generated_file

	set core_params_list [list]
	lappend core_params_list "RLDRAMII"
	if {[get_parameter_value CTL_BURST_LENGTH] == 1} {
		lappend core_params_list "CTL_BL_IS_ONE"
	}
	if {[get_parameter_value CTL_LATENCY] == 1} {
		lappend core_params_list "DEC_LAT"
	}
	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name ../common/memctl_data_if.sv $core_params_list]
	lappend generated_files_list $generated_file

	_dprint 1 "Using generated files list of $generated_files_list"

	return $generated_files_list

}

proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach fname [generate_verilog_fileset $name] {
		set dirname [file dirname $fname]
		set tailname [file tail $fname]
		_dprint 1 "Preparing to add [file join $dirname mentor $tailname] as [file join mentor $tailname]"
		add_fileset_file [file join mentor $tailname] [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 1 1] PATH [file join $dirname mentor $tailname] {MENTOR_SPECIFIC}
		_dprint 1 "Preparing to add $fname as $tailname"
		add_fileset_file $tailname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname] PATH $fname $non_encryp_simulators
	}
}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	foreach fname [generate_verilog_fileset $name] {
		set tailname [file tail $fname]
		_dprint 1 "Preparing to add $fname as $tailname"
		add_fileset_file $tailname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname] PATH $fname
	}
}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	foreach fname [generate_verilog_fileset $name] {
		set tailname [file tail $fname]
		_dprint 1 "Preparing to add $fname as $tailname"
		add_fileset_file $tailname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 0] PATH $fname
	}
}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for alt_mem_if_rldramii_controller"	

	set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

	set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_T_RC HDL_PARAMETER true
	set_parameter_property MEM_T_WL HDL_PARAMETER true
	set_parameter_property MEM_T_REFI HDL_PARAMETER true
	set_parameter_property CTL_T_REFI HDL_PARAMETER true

	set_parameter_property MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR HDL_PARAMETER true
	set_parameter_property MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD HDL_PARAMETER true

	set_parameter_property AFI_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_CONTROL_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_CS_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_DM_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_WRITE_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_RATE_RATIO HDL_PARAMETER true

	set_parameter_property CTL_BURST_LENGTH HDL_PARAMETER true
	set_parameter_property CTL_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_CHIPADDR_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_BEATADDR_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_CONTROL_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_CS_WIDTH HDL_PARAMETER true

	set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_SIZE_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_NUM_SYMBOLS HDL_PARAMETER true

	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS HDL_PARAMETER true

}


alt_mem_if::gui::afi::set_protocol "RLDRAMII"
alt_mem_if::gui::common_rldram_mem_model::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_mem_model::create_parameters
alt_mem_if::gui::common_rldram_controller_phy::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_controller_phy::create_parameters
alt_mem_if::gui::common_rldram_controller::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_controller::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters

create_hdl_parameters

alt_mem_if::gui::common_rldram_controller::create_gui 1
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

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_rldram_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::common_rldram_controller_phy::validate_component
	alt_mem_if::gui::common_rldram_controller::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_rldram_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::common_rldram_controller::elaborate_component

	add_interface afi_reset reset end
	set_interface_property afi_reset synchronousEdges NONE
	set_interface_property afi_reset ENABLED true
	
	add_interface_port afi_reset afi_reset_n reset_n Input 1

	add_interface afi_clk clock end
	set_interface_property afi_clk ENABLED true
	
	add_interface_port afi_clk afi_clk clk Input 1

	if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
		add_interface avl avalon end
		set_interface_property avl ENABLED true
		set_interface_property avl addressUnits WORDS
		set_interface_property avl associatedClock afi_clk
		set_interface_property avl associatedReset afi_reset
		set_interface_property avl isMemoryDevice 1
		set_interface_property avl bitsPerSymbol [get_parameter_value AVL_SYMBOL_WIDTH]
		set_interface_property avl addressAlignment dynamic

		set_interface_property avl maximumPendingReadTransactions 24

		set_interface_property avl constantBurstBehavior false
	
	} else {
		add_interface avl conduit end
	}

	add_interface_port avl avl_size burstcount Input [get_parameter_value AVL_SIZE_WIDTH]
	add_interface_port avl avl_wdata writedata Input [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port avl avl_rdata_valid readdatavalid Output 1
	add_interface_port avl avl_rdata readdata Output [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port avl avl_ready waitrequest_n Output 1
	add_interface_port avl avl_write_req write Input 1
	add_interface_port avl avl_read_req read Input 1
	add_interface_port avl avl_addr address Input [get_parameter_value AVL_ADDR_WIDTH]


	::alt_mem_if::gen::uniphy_interfaces::afi "RLDRAMII" "controller"


	add_interface status conduit end
	set_interface_property status ENABLED true
	
	add_interface_port status local_init_done local_init_done Output 1
	add_interface_port status local_cal_success local_cal_success Output 1
	add_interface_port status local_cal_fail local_cal_fail Output 1
	
	if {[string compare -nocase [get_parameter_value ERROR_DETECTION_PARITY] "true"] == 0} {
		add_interface parity_error_interrupt conduit end
		set_interface_property parity_error_interrupt ENABLED true

		add_interface_port parity_error_interrupt parity_error parity_error Output [get_parameter_value AVL_NUM_SYMBOLS]
	}

	if {[string compare -nocase [get_parameter_value USER_REFRESH] "true"] == 0} {
		add_interface user_refresh conduit end
		set_interface_property user_refresh ENABLED true

		add_interface_port user_refresh ref_req ref_req Input 1
		add_interface_port user_refresh ref_ba ref_ba Input [get_parameter_value CTL_BANKADDR_WIDTH]
		add_interface_port user_refresh ref_ack ref_ack Output 1

	}

	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "alt_rld_controller_top.sv" [solve_core_params] 1]
	}

}
