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
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini


namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Altera DDR3 Nextgen Memory Controller Core"
set_module_property NAME altera_mem_if_nextgen_ddr3_controller_core
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_controller_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera DDR3 Nextgen Memory Controller Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL alt_mem_if_nextgen_ddr3_controller_core

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL alt_mem_if_nextgen_ddr3_controller_core

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL alt_mem_if_nextgen_ddr3_controller_core

proc generate_verilog_fileset {} {

	set source_files_list [list \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_addr_cmd.v \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_addr_cmd_wrap.v \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_ddr2_odt_gen.v \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_ddr3_odt_gen.v \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_lpddr2_addr_cmd.v \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_odt_gen.v \
		alt_mem_ddrx_afi_if/alt_mem_ddrx_rdwr_data_tmg.v \
		alt_mem_ddrx_arbiter/alt_mem_ddrx_arbiter.v \
		alt_mem_ddrx_burst_gen/alt_mem_ddrx_burst_gen.v \
		alt_mem_ddrx_cmd_gen/alt_mem_ddrx_cmd_gen.v \
		alt_mem_ddrx_csr/alt_mem_ddrx_csr.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_buffer.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_buffer_manager.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_burst_tracking.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_dataid_manager.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_fifo.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_list.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_rdata_path.v \
		alt_mem_ddrx_data_path/alt_mem_ddrx_wdata_path.v \
		alt_mem_ddrx_define/alt_mem_ddrx_define.iv \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_decoder.v \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_decoder_32_syn.v \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_decoder_64_syn.v \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_encoder.v \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_encoder_32_syn.v \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_encoder_64_syn.v \
		alt_mem_ddrx_ecc/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v \
		alt_mem_ddrx_axi_st_converter/alt_mem_ddrx_axi_st_converter.v \
		alt_mem_ddrx_input_if/alt_mem_ddrx_input_if.v \
		alt_mem_ddrx_rank_timer/alt_mem_ddrx_rank_timer.v \
		alt_mem_ddrx_sideband/alt_mem_ddrx_sideband.v \
		alt_mem_ddrx_tbp/alt_mem_ddrx_tbp.v \
		alt_mem_ddrx_timing_param/alt_mem_ddrx_timing_param.v \
		alt_mem_ddrx_top_sip/alt_mem_ddrx_controller.v \
		alt_mem_ddrx_top_sip/alt_mem_ddrx_controller_st_top.v \
	]

	return $source_files_list
}
	

proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate Verilog simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach file_name [generate_verilog_fileset] {

		add_fileset_file [file tail $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH [file join .. alt_mem_if_nextgen_ddr_controller_110 rtl $file_name] $non_encryp_simulators

		if {[regexp -nocase {alt_mem_ddrx_define\.iv} $file_name match] == 1 &&
			[alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_inline_files] == 0} {
				_dprint 1 "Ignoring $file_name"
		} else {
			_dprint 1 "Preparing to add $file_name"
			add_fileset_file [file join mentor [file tail $file_name]] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 1 1] PATH [file join .. alt_mem_if_nextgen_ddr_controller_110 mentor rtl $file_name] {MENTOR_SPECIFIC}
		}
	}
	
	add_fileset_file [file join mentor alt_mem_if_nextgen_ddr3_controller_core.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor alt_mem_if_nextgen_ddr3_controller_core.sv] {MENTOR_SPECIFIC}
	add_fileset_file alt_mem_if_nextgen_ddr3_controller_core.sv SYSTEM_VERILOG PATH alt_mem_if_nextgen_ddr3_controller_core.sv $non_encryp_simulators


}
	
proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate Verilog simulation fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file [file tail $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH [file join .. alt_mem_if_nextgen_ddr_controller_110 rtl $file_name]
	}

	add_fileset_file alt_mem_if_nextgen_ddr3_controller_core.sv SYSTEM_VERILOG PATH alt_mem_if_nextgen_ddr3_controller_core.sv


}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file [file tail $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH [file join .. alt_mem_if_nextgen_ddr_controller_110 rtl $file_name]
	}

	add_fileset_file alt_mem_if_nextgen_ddr3_controller_core.sv SYSTEM_VERILOG PATH alt_mem_if_nextgen_ddr3_controller_core.sv

}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for DDR3 Nextgen controller"	

	set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_SIZE_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true
	set_parameter_property AVL_BE_WIDTH HDL_PARAMETER true

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
	set_parameter_property AFI_RRANK_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_WRANK_WIDTH HDL_PARAMETER true
	set_parameter_property USE_SHADOW_REGS HDL_PARAMETER true

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
        set_parameter_property MEM_ADD_LAT HDL_PARAMETER true

	set_parameter_property DWIDTH_RATIO HDL_PARAMETER true
	set_parameter_property CTL_ECC_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_ECC_MULTIPLES_16_24_40_72 HDL_PARAMETER true
	set_parameter_property CTL_ODT_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_REGDIMM_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_CSR_ENABLED HDL_PARAMETER true
	set_parameter_property CTL_ENABLE_BURST_INTERRUPT_INT HDL_PARAMETER true
	set_parameter_property CTL_ENABLE_BURST_TERMINATE_INT HDL_PARAMETER true
	set_parameter_property CTL_ENABLE_WDATA_PATH_LATENCY HDL_PARAMETER true
	set_parameter_property CSR_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property CSR_DATA_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_OUTPUT_REGD HDL_PARAMETER true
	set_parameter_property CTL_USR_REFRESH HDL_PARAMETER true
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
	set_parameter_property CTL_RD_TO_PCH_EXTRA_CLK HDL_PARAMETER true
	set_parameter_property CTL_RD_TO_RD_EXTRA_CLK HDL_PARAMETER true
	set_parameter_property CTL_WR_TO_WR_EXTRA_CLK HDL_PARAMETER true
	set_parameter_property CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK HDL_PARAMETER true
	set_parameter_property CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK HDL_PARAMETER true

	set_parameter_property LOCAL_ID_WIDTH HDL_PARAMETER true
	set_parameter_property LOCAL_CS_WIDTH HDL_PARAMETER true
	set_parameter_property CTL_TBP_NUM HDL_PARAMETER true
	set_parameter_property WRBUFFER_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property RDBUFFER_ADDR_WIDTH HDL_PARAMETER true
	set_parameter_property MEM_TMRD_CK HDL_PARAMETER true
	set_parameter_property CFG_TYPE HDL_PARAMETER true
	set_parameter_property CFG_INTERFACE_WIDTH HDL_PARAMETER true
	set_parameter_property CFG_BURST_LENGTH HDL_PARAMETER true
	set_parameter_property CFG_REORDER_DATA HDL_PARAMETER true
	set_parameter_property CFG_DATA_REORDERING_TYPE HDL_PARAMETER true
	set_parameter_property CFG_STARVE_LIMIT HDL_PARAMETER true
	set_parameter_property CFG_ADDR_ORDER HDL_PARAMETER true
	set_parameter_property CFG_PDN_EXIT_CYCLES HDL_PARAMETER true
	set_parameter_property CFG_POWER_SAVING_EXIT_CYCLES HDL_PARAMETER true
	set_parameter_property CFG_MEM_CLK_ENTRY_CYCLES HDL_PARAMETER true
	set_parameter_property CFG_SELF_RFSH_EXIT_CYCLES HDL_PARAMETER true
	set_parameter_property CFG_PORT_WIDTH_WRITE_ODT_CHIP HDL_PARAMETER true
	set_parameter_property CFG_PORT_WIDTH_READ_ODT_CHIP HDL_PARAMETER true
	set_parameter_property CFG_WRITE_ODT_CHIP HDL_PARAMETER true
	set_parameter_property CFG_READ_ODT_CHIP HDL_PARAMETER true
	set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED HDL_PARAMETER true
	set_parameter_property CFG_CLR_INTR HDL_PARAMETER true
	set_parameter_property CFG_ENABLE_NO_DM HDL_PARAMETER true
	set_parameter_property CSR_BE_WIDTH HDL_PARAMETER true
	set_parameter_property CFG_ERRCMD_FIFO_REG HDL_PARAMETER true
	set_parameter_property CFG_ECC_DECODER_REG HDL_PARAMETER true

	set_parameter_property MAX_PENDING_RD_CMD HDL_PARAMETER true
	set_parameter_property MAX_PENDING_WR_CMD HDL_PARAMETER true

	set_parameter_property CTL_CS_WIDTH HDL_PARAMETER true
	set_parameter_property USE_DQS_TRACKING HDL_PARAMETER true
	set_parameter_property ENABLE_BURST_MERGE HDL_PARAMETER true
}

alt_mem_if::gui::afi::set_protocol "DDR3"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR3"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode "DDR3"
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

	if {[string compare -nocase [get_parameter_value NEXTGEN] "false"] == 0} {
		_eprint "Parameter NEXTGEN must be true for the Nextgen controller!"
	}

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

	::alt_mem_if::gen::uniphy_interfaces::create_nextgen_st_interface 1

	
	::alt_mem_if::gen::uniphy_interfaces::csr_slave "controller"


	::alt_mem_if::gen::uniphy_interfaces::afi "DDR3" "controller" "afi" 1 1 1

	::alt_mem_if::gen::uniphy_interfaces::ddrx_nextgen_sideband_signals

	::alt_mem_if::gen::uniphy_interfaces::refctrl_interface

	::alt_mem_if::gen::uniphy_interfaces::zqcal_interface
}
