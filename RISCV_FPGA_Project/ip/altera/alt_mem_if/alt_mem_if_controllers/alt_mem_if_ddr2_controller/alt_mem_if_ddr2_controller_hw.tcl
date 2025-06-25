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
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils


namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Altera DDR2 Memory Controller"
set_module_property NAME altera_mem_if_ddr2_controller
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_controller_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera DDR2 Memory Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL alt_mem_if_ddr2_controller_top

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL alt_mem_if_ddr2_controller_top

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL alt_mem_if_ddr2_controller_top


proc generate_verilog_fileset {} {


	set source_files_list [list \
		alt_ddrx_addr_cmd.v \
		alt_ddrx_afi_block.v \
		alt_ddrx_avalon_if.v \
		alt_ddrx_bank_timer.v \
		alt_ddrx_bank_timer_info.v \
		alt_ddrx_bank_timer_wrapper.v \
		alt_ddrx_bypass.v \
		alt_ddrx_cache.v \
		alt_ddrx_clock_and_reset.v \
		alt_ddrx_cmd_gen.v \
		alt_ddrx_cmd_queue.v \
		alt_ddrx_controller.v \
		alt_ddrx_csr.v \
		alt_ddrx_ddr2_odt_gen.v \
		alt_ddrx_ddr3_odt_gen.v \
		alt_ddrx_decoder.v \
		alt_ddrx_decoder_40.v \
		alt_ddrx_decoder_72.v \
		alt_ddrx_ecc.v \
		alt_ddrx_encoder.v \
		alt_ddrx_encoder_40.v \
		alt_ddrx_encoder_72.v \
		alt_ddrx_input_if.v \
		alt_ddrx_odt_gen.v \
		alt_ddrx_rank_monitor.v \
		alt_ddrx_state_machine.v \
		alt_ddrx_timing_param.v \
		alt_ddrx_wdata_fifo.v \
		alt_mem_if_ddr2_controller_top.sv \
	]



	if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
		lappend source_files_list "altera_avalon_half_rate_bridge.v"
	}

	return $source_files_list
}
	
proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate Verilog simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name $non_encryp_simulators
		
		add_fileset_file [file join mentor $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 1 1] PATH [file join mentor $file_name] {MENTOR_SPECIFIC}
	}
}
	
proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate Verilog simulation fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}

}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}

	if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
		set file_name "altera_avalon_half_rate_bridge_constraints.sdc"
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name SDC PATH $file_name
	}
}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for DDR2 controller"	


	set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_SIZE_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_BE_WIDTH HDL_PARAMETER true
	set_parameter_property BYTE_ENABLE HDL_PARAMETER true

	set_parameter_property AFI_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_CONTROL_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_CS_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_CLK_EN_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_ODT_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_DM_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_WRITE_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_RATE_RATIO HDL_PARAMETER true
	set_parameter_property AFI_WLAT_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_RLAT_WIDTH HDL_PARAMETER true

	set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CHIP_BITS HDL_PARAMETER true
	set_parameter_property MEM_IF_ODT_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CLK_EN_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_ROW_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_COL_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_BANKADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_DM_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_IF_CLK_PAIR_COUNT HDL_PARAMETER true
	set_parameter_property MEM_IF_CS_PER_DIMM HDL_PARAMETER true


	set_parameter_property DWIDTH_RATIO HDL_PARAMETER true
	set_parameter_property CTL_LOOK_AHEAD_DEPTH HDL_PARAMETER true
	set_parameter_property CTL_CMD_QUEUE_DEPTH HDL_PARAMETER true
	set_parameter_property CTL_HRB_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_ECC_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_ECC_CSR_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_ECC_MULTIPLES_40_72 HDL_PARAMETER true
	set_parameter_property CTL_CSR_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_CSR_READ_ONLY HDL_PARAMETER true
	set_parameter_property CTL_ODT_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_REGDIMM_ENABLED HDL_PARAMETER true
	set_parameter_property CSR_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property CSR_DATA_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_OUTPUT_REGD HDL_PARAMETER true
	set_parameter_property CTL_USR_REFRESH HDL_PARAMETER true
	set_parameter_property CTL_SELF_REFRESH HDL_PARAMETER true
	set_parameter_property MEM_WTCL_INT HDL_PARAMETER true
	set_parameter_property MEM_TCL HDL_PARAMETER true
	set_parameter_property MEM_TRRD HDL_PARAMETER true
	set_parameter_property MEM_TFAW HDL_PARAMETER true
	set_parameter_property MEM_TRFC HDL_PARAMETER true
	set_parameter_property MEM_TREFI HDL_PARAMETER true
	set_parameter_property MEM_TRCD HDL_PARAMETER true
	set_parameter_property MEM_TRP HDL_PARAMETER true
	set_parameter_property MEM_TWR HDL_PARAMETER true
	set_parameter_property MEM_TWTR HDL_PARAMETER true
	set_parameter_property MEM_TRTP HDL_PARAMETER true
	set_parameter_property MEM_TRAS HDL_PARAMETER true
	set_parameter_property MEM_TRC HDL_PARAMETER true
	set_parameter_property MEM_AUTO_PD_CYCLES HDL_PARAMETER true
	set_parameter_property MEM_IF_RD_TO_WR_TURNAROUND_OCT HDL_PARAMETER true
	set_parameter_property MEM_IF_WR_TO_RD_TURNAROUND_OCT HDL_PARAMETER true
	set_parameter_property ADDR_ORDER HDL_PARAMETER true
	set_parameter_property LOW_LATENCY HDL_PARAMETER true
	set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION HDL_PARAMETER true
	set_parameter_property CTL_DYNAMIC_BANK_NUM HDL_PARAMETER true
	set_parameter_property ENABLE_BURST_MERGE HDL_PARAMETER true
        set_parameter_property MULTICAST_EN HDL_PARAMETER true
	set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED HDL_PARAMETER true
	set_parameter_property MEM_ADD_LAT HDL_PARAMETER true

}

alt_mem_if::gui::afi::set_protocol "DDR2"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR2"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode "DDR2"
alt_mem_if::gui::ddrx_controller::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters

create_hdl_parameters

alt_mem_if::gui::ddrx_controller::create_gui 1
alt_mem_if::gui::common_ddr_mem_model::create_gui

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
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::ddrx_controller::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_controller_phy::elaborate_component
	alt_mem_if::gui::ddrx_controller::elaborate_component


	add_interface afi_reset reset end
	set_interface_property afi_reset synchronousEdges NONE
	set_interface_property afi_reset ENABLED true
	
	add_interface_port afi_reset afi_reset_n reset_n Input 1

	add_interface afi_half_clk clock end
	set_interface_property afi_half_clk ENABLED true
	add_interface_port afi_half_clk afi_half_clk clk Input 1
	
	add_interface afi_clk clock end
	set_interface_property afi_clk ENABLED true

	add_interface_port afi_clk afi_clk clk Input 1

	add_interface status conduit end
	set_interface_property status ENABLED true
	
	add_interface_port status local_init_done local_init_done Output 1
	add_interface_port status local_cal_success local_cal_success Output 1
	add_interface_port status local_cal_fail local_cal_fail Output 1

	if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
		add_interface avl avalon end
		set_interface_property avl ENABLED true
		set_interface_property avl addressUnits WORDS
		if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
			set_interface_property avl associatedClock afi_half_clk
		} else {
			set_interface_property avl associatedClock afi_clk
		}
		set_interface_property avl associatedReset afi_reset
		set_interface_property avl bitsPerSymbol [get_parameter_value AVL_SYMBOL_WIDTH]
		set_interface_property avl addressAlignment DYNAMIC
		set_interface_property avl isMemoryDevice 1

		if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
			set_interface_property avl maximumPendingReadTransactions 48
		} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
			set_interface_property avl maximumPendingReadTransactions 32
		} elseif {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
			set_interface_property avl maximumPendingReadTransactions 32
		}

		set_interface_property avl constantBurstBehavior false
	
	} else {
		add_interface avl conduit end
	}

	add_interface_port avl avl_ready waitrequest_n Output 1
	add_interface_port avl avl_addr address Input [get_parameter_value AVL_ADDR_WIDTH]
	add_interface_port avl avl_size burstcount Input [get_parameter_value AVL_SIZE_WIDTH]
	add_interface_port avl avl_burstbegin beginbursttransfer Input 1
	add_interface_port avl avl_be byteenable Input [get_parameter_value AVL_BE_WIDTH]
	set_port_property avl_be VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port avl avl_wdata writedata Input [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port avl avl_rdata readdata Output [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port avl avl_write_req write Input 1
	add_interface_port avl avl_read_req read Input 1
	add_interface_port avl avl_rdata_valid readdatavalid Output 1
	if {[string compare -nocase [get_parameter_value BYTE_ENABLE] "true"] == 0} {
		set_port_property avl_be termination false
	} else {
		set_port_property avl_be termination true
		set_port_property avl_be termination_value "[get_parameter_value AVL_BE_WIDTH]\'b[string repeat 1 [get_parameter_value AVL_BE_WIDTH]]"
	}

	::alt_mem_if::gen::uniphy_interfaces::csr_slave "controller"

	::alt_mem_if::gen::uniphy_interfaces::afi "DDR2" "controller" "afi" 1 1 1

	::alt_mem_if::gen::uniphy_interfaces::ddrx_hpcii_sideband_signals

}
