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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera DDR2 AFI Gasket"
set_module_property NAME altera_mem_if_ddr2_afi_gasket
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_afi_gasket_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera DDR2 AFI Gasket"
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
		DDRX \
		DDR2
	]

	set core_params_list [list]

	
	lappend core_params_list "DDRX"
	lappend core_params_list "DDR2"
	
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
		lappend core_params_list "USE_SHADOW_REGS"
	}

	_dprint 1 "afi_gasket: core_params_list = ${core_params_list}"
	return $core_params_list
	
}


proc generate_verilog_fileset {name tmpdir} {

	
	set core_params_list [solve_core_params]
	_dprint 1 "afi_gasket: core_params_list = ${core_params_list}"

	set inhdl_files_list [list \
		afi_gasket.v \
	]

	set generated_files_list [list]

	foreach ifdef_source_file $inhdl_files_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $ifdef_source_file $core_params_list]
		lappend generated_files_list $generated_file
	}

	_dprint 1 "afi_gasket: Using generated files list of $generated_files_list"

	return $generated_files_list
	
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "afi_gasket.v" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] VERILOG_ENCRYPT PATH [file join ".." common mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file VERILOG PATH [file join ".." common $generated_file] [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "afi_gasket.v" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file VERILOG PATH [file join ".." common $generated_file]

}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "afi_gasket.v" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file VERILOG PATH [file join ".." common $generated_file]

}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for [get_module_property NAME]"

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_ADDR_WIDTH             INTEGER 0
	set_parameter_property AFI_CTLR_ADDR_WIDTH             DERIVED true
	set_parameter_property AFI_CTLR_ADDR_WIDTH             VISIBLE false
	set_parameter_property AFI_CTLR_ADDR_WIDTH             HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_BANKADDR_WIDTH         INTEGER 0
	set_parameter_property AFI_CTLR_BANKADDR_WIDTH         DERIVED true
	set_parameter_property AFI_CTLR_BANKADDR_WIDTH         VISIBLE false
	set_parameter_property AFI_CTLR_BANKADDR_WIDTH         HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_CS_WIDTH               INTEGER 0
	set_parameter_property AFI_CTLR_CS_WIDTH               DERIVED true
	set_parameter_property AFI_CTLR_CS_WIDTH               VISIBLE false
	set_parameter_property AFI_CTLR_CS_WIDTH               HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_ODT_WIDTH              INTEGER 0
	set_parameter_property AFI_CTLR_ODT_WIDTH              DERIVED true
	set_parameter_property AFI_CTLR_ODT_WIDTH              VISIBLE false
	set_parameter_property AFI_CTLR_ODT_WIDTH              HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_WLAT_WIDTH             INTEGER 0
	set_parameter_property AFI_CTLR_WLAT_WIDTH             DERIVED true
	set_parameter_property AFI_CTLR_WLAT_WIDTH             VISIBLE false
	set_parameter_property AFI_CTLR_WLAT_WIDTH             HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_RLAT_WIDTH             INTEGER 0
	set_parameter_property AFI_CTLR_RLAT_WIDTH             DERIVED true
	set_parameter_property AFI_CTLR_RLAT_WIDTH             VISIBLE false
	set_parameter_property AFI_CTLR_RLAT_WIDTH             HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_RRANK_WIDTH            INTEGER 0
	set_parameter_property AFI_CTLR_RRANK_WIDTH            DERIVED true
	set_parameter_property AFI_CTLR_RRANK_WIDTH            VISIBLE false
	set_parameter_property AFI_CTLR_RRANK_WIDTH            HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_WRANK_WIDTH            INTEGER 0
	set_parameter_property AFI_CTLR_WRANK_WIDTH            DERIVED true
	set_parameter_property AFI_CTLR_WRANK_WIDTH            VISIBLE false
	set_parameter_property AFI_CTLR_WRANK_WIDTH            HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_DM_WIDTH               INTEGER 0
	set_parameter_property AFI_CTLR_DM_WIDTH               DERIVED true
	set_parameter_property AFI_CTLR_DM_WIDTH               VISIBLE false
	set_parameter_property AFI_CTLR_DM_WIDTH               HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_CONTROL_WIDTH          INTEGER 0
	set_parameter_property AFI_CTLR_CONTROL_WIDTH          DERIVED true
	set_parameter_property AFI_CTLR_CONTROL_WIDTH          VISIBLE false
	set_parameter_property AFI_CTLR_CONTROL_WIDTH          HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_CLK_EN_WIDTH           INTEGER 0
	set_parameter_property AFI_CTLR_CLK_EN_WIDTH           DERIVED true
	set_parameter_property AFI_CTLR_CLK_EN_WIDTH           VISIBLE false
	set_parameter_property AFI_CTLR_CLK_EN_WIDTH           HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_DQ_WIDTH               INTEGER 0
	set_parameter_property AFI_CTLR_DQ_WIDTH               DERIVED true
	set_parameter_property AFI_CTLR_DQ_WIDTH               VISIBLE false
	set_parameter_property AFI_CTLR_DQ_WIDTH               HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_WRITE_DQS_WIDTH        INTEGER 0
	set_parameter_property AFI_CTLR_WRITE_DQS_WIDTH        DERIVED true
	set_parameter_property AFI_CTLR_WRITE_DQS_WIDTH        VISIBLE false
	set_parameter_property AFI_CTLR_WRITE_DQS_WIDTH        HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_CLK_PAIR_COUNT         INTEGER 0
	set_parameter_property AFI_CTLR_CLK_PAIR_COUNT         DERIVED true
	set_parameter_property AFI_CTLR_CLK_PAIR_COUNT         VISIBLE false
	set_parameter_property AFI_CTLR_CLK_PAIR_COUNT         HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CTLR_RATE_RATIO             INTEGER 0
	set_parameter_property AFI_CTLR_RATE_RATIO             DERIVED true
	set_parameter_property AFI_CTLR_RATE_RATIO             VISIBLE false
	set_parameter_property AFI_CTLR_RATE_RATIO             HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_ADDR_WIDTH              INTEGER 0
	set_parameter_property AFI_MUX_ADDR_WIDTH              DERIVED true
	set_parameter_property AFI_MUX_ADDR_WIDTH              VISIBLE false
	set_parameter_property AFI_MUX_ADDR_WIDTH              HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_BANKADDR_WIDTH          INTEGER 0
	set_parameter_property AFI_MUX_BANKADDR_WIDTH          DERIVED true
	set_parameter_property AFI_MUX_BANKADDR_WIDTH          VISIBLE false
	set_parameter_property AFI_MUX_BANKADDR_WIDTH          HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_CS_WIDTH                INTEGER 0
	set_parameter_property AFI_MUX_CS_WIDTH                DERIVED true
	set_parameter_property AFI_MUX_CS_WIDTH                VISIBLE false
	set_parameter_property AFI_MUX_CS_WIDTH                HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_ODT_WIDTH               INTEGER 0
	set_parameter_property AFI_MUX_ODT_WIDTH               DERIVED true
	set_parameter_property AFI_MUX_ODT_WIDTH               VISIBLE false
	set_parameter_property AFI_MUX_ODT_WIDTH               HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_WLAT_WIDTH              INTEGER 0
	set_parameter_property AFI_MUX_WLAT_WIDTH              DERIVED true
	set_parameter_property AFI_MUX_WLAT_WIDTH              VISIBLE false
	set_parameter_property AFI_MUX_WLAT_WIDTH              HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_RLAT_WIDTH              INTEGER 0
	set_parameter_property AFI_MUX_RLAT_WIDTH              DERIVED true
	set_parameter_property AFI_MUX_RLAT_WIDTH              VISIBLE false
	set_parameter_property AFI_MUX_RLAT_WIDTH              HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_RRANK_WIDTH             INTEGER 0
	set_parameter_property AFI_MUX_RRANK_WIDTH             DERIVED true
	set_parameter_property AFI_MUX_RRANK_WIDTH             VISIBLE false
	set_parameter_property AFI_MUX_RRANK_WIDTH             HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_WRANK_WIDTH             INTEGER 0
	set_parameter_property AFI_MUX_WRANK_WIDTH             DERIVED true
	set_parameter_property AFI_MUX_WRANK_WIDTH             VISIBLE false
	set_parameter_property AFI_MUX_WRANK_WIDTH             HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_DM_WIDTH                INTEGER 0
	set_parameter_property AFI_MUX_DM_WIDTH                DERIVED true
	set_parameter_property AFI_MUX_DM_WIDTH                VISIBLE false
	set_parameter_property AFI_MUX_DM_WIDTH                HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_CONTROL_WIDTH           INTEGER 0
	set_parameter_property AFI_MUX_CONTROL_WIDTH           DERIVED true
	set_parameter_property AFI_MUX_CONTROL_WIDTH           VISIBLE false
	set_parameter_property AFI_MUX_CONTROL_WIDTH           HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_CLK_EN_WIDTH            INTEGER 0
	set_parameter_property AFI_MUX_CLK_EN_WIDTH            DERIVED true
	set_parameter_property AFI_MUX_CLK_EN_WIDTH            VISIBLE false
	set_parameter_property AFI_MUX_CLK_EN_WIDTH            HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_DQ_WIDTH                INTEGER 0
	set_parameter_property AFI_MUX_DQ_WIDTH                DERIVED true
	set_parameter_property AFI_MUX_DQ_WIDTH                VISIBLE false
	set_parameter_property AFI_MUX_DQ_WIDTH                HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_WRITE_DQS_WIDTH         INTEGER 0
	set_parameter_property AFI_MUX_WRITE_DQS_WIDTH         DERIVED true
	set_parameter_property AFI_MUX_WRITE_DQS_WIDTH         VISIBLE false
	set_parameter_property AFI_MUX_WRITE_DQS_WIDTH         HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_CLK_PAIR_COUNT          INTEGER 0
	set_parameter_property AFI_MUX_CLK_PAIR_COUNT          DERIVED true
	set_parameter_property AFI_MUX_CLK_PAIR_COUNT          VISIBLE false
	set_parameter_property AFI_MUX_CLK_PAIR_COUNT          HDL_PARAMETER true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_MUX_RATE_RATIO              INTEGER 0
	set_parameter_property AFI_MUX_RATE_RATIO              DERIVED true
	set_parameter_property AFI_MUX_RATE_RATIO              VISIBLE false
	set_parameter_property AFI_MUX_RATE_RATIO              HDL_PARAMETER true

	::alt_mem_if::util::hwtcl_utils::_add_parameter DDR2_RDIMM                      INTEGER 0
	set_parameter_property DDR2_RDIMM                      DERIVED true
	set_parameter_property DDR2_RDIMM                      VISIBLE false
	set_parameter_property DDR2_RDIMM                      HDL_PARAMETER true

	set_parameter_property MEM_CS_WIDTH                    HDL_PARAMETER true
	set_parameter_property MEM_NUMBER_OF_DIMMS             HDL_PARAMETER true
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM    HDL_PARAMETER true

}


alt_mem_if::gui::afi::set_protocol "DDR2"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR2"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters


create_hdl_parameters


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
	_dprint 1 "Running IP Validation for [get_module_property NAME]"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
}

proc ip_elaborate {} {

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component

	_dprint 1 "adding phy (input) interface 'afi_ctlr' to gasket"
	::alt_mem_if::gen::uniphy_interfaces::afi "DDR2" "phy" "afi_ctlr" 1 1
	_dprint 1 "adding ctlr (output) interface 'afi' to gasket"
	::alt_mem_if::gen::uniphy_interfaces::afi "DDR2" "controller" "afi" 1 1


	
	set afi_mux_cs_width [expr {[get_parameter_value MEM_CS_WIDTH] * [get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value AFI_RATE_RATIO] }]
	set afi_mux_odt_width [expr {[get_parameter_value MEM_CLK_EN_WIDTH] * [get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value AFI_RATE_RATIO] }]
	set afi_mux_clk_en_width [expr {[get_parameter_value MEM_CLK_EN_WIDTH] * [get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value AFI_RATE_RATIO] }]

	if {[string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0} {
		set afi_mux_cs_width [expr {2 * $afi_mux_cs_width}]
		set afi_mux_odt_width [expr {2 * $afi_mux_odt_width}]
		set afi_mux_clk_en_width [expr {2 * $afi_mux_clk_en_width}]
		_dprint 1 "AFI RDIMM/LRDIMM Gasket (Ping-Pong PHY) - Overriding afi_cs port width to physical mapping of $afi_mux_cs_width = [get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value MEM_CS_WIDTH] * [get_parameter_value AFI_RATE_RATIO] * 2"
	} else {
		_dprint 1 "AFI RDIMM/LRDIMM Gasket - Overriding afi_cs port width to physical mapping of $afi_mux_cs_width = [get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value MEM_CS_WIDTH] * [get_parameter_value AFI_RATE_RATIO]"
	}

	add_interface_port afi afi_cs_n afi_cs_n output $afi_mux_cs_width

	add_interface_port afi_ctlr afi_ctlr_cal_req afi_cal_req input 1
	add_interface_port afi_ctlr afi_ctlr_init_req afi_init_req input 1
	add_interface_port afi_ctlr afi_ctlr_mem_clk_disable afi_mem_clk_disable input [get_parameter_value AFI_CLK_PAIR_COUNT]

	add_interface_port afi afi_cal_req afi_cal_req output 1
	add_interface_port afi afi_init_req afi_init_req output 1
	add_interface_port afi afi_mem_clk_disable afi_mem_clk_disable output [get_parameter_value AFI_CLK_PAIR_COUNT]

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
		add_interface_port afi_ctlr afi_ctlr_seq_busy afi_seq_busy output [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		add_interface_port afi_ctlr afi_ctlr_ctl_refresh_done afi_ctl_refresh_done input [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		add_interface_port afi_ctlr afi_ctlr_ctl_long_idle afi_ctl_long_idle input [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		
		add_interface_port afi afi_seq_busy afi_seq_busy input [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		add_interface_port afi afi_ctl_refresh_done afi_ctl_refresh_done output [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		add_interface_port afi afi_ctl_long_idle afi_ctl_long_idle output [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
	}

	if {[string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0} {
		add_interface_port afi_ctlr afi_ctlr_rdata_en_1t afi_rdata_en_1t input [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi_ctlr afi_ctlr_rdata_en_full_1t afi_rdata_en_full_1t input [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi_ctlr afi_ctlr_rdata_valid_1t afi_rdata_valid_1t output [get_parameter_value AFI_RATE_RATIO]

		add_interface_port afi afi_rdata_en_1t afi_rdata_en_1t output [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi afi_rdata_en_full_1t afi_rdata_en_full_1t output [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi afi_rdata_valid_1t afi_rdata_valid_1t input [get_parameter_value AFI_RATE_RATIO]

	}

	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "afi_gasket.v" [solve_core_params] 1]
	}




	set_parameter_value AFI_CTLR_ADDR_WIDTH            [get_parameter_value AFI_ADDR_WIDTH           ]
	set_parameter_value AFI_CTLR_BANKADDR_WIDTH        [get_parameter_value AFI_BANKADDR_WIDTH       ]
	set_parameter_value AFI_CTLR_WLAT_WIDTH            [get_parameter_value AFI_WLAT_WIDTH           ]
	set_parameter_value AFI_CTLR_RLAT_WIDTH            [get_parameter_value AFI_RLAT_WIDTH           ]
	set_parameter_value AFI_CTLR_RRANK_WIDTH           [get_parameter_value AFI_RRANK_WIDTH          ]
	set_parameter_value AFI_CTLR_WRANK_WIDTH           [get_parameter_value AFI_WRANK_WIDTH          ]
	set_parameter_value AFI_CTLR_DM_WIDTH              [get_parameter_value AFI_DM_WIDTH             ]
	set_parameter_value AFI_CTLR_DQ_WIDTH              [get_parameter_value AFI_DQ_WIDTH             ]
	set_parameter_value AFI_CTLR_WRITE_DQS_WIDTH       [get_parameter_value AFI_WRITE_DQS_WIDTH      ]
	set_parameter_value AFI_CTLR_RATE_RATIO            [get_parameter_value AFI_RATE_RATIO           ]
	set_parameter_value AFI_CTLR_CS_WIDTH              [get_parameter_value AFI_CS_WIDTH             ]
	set_parameter_value AFI_CTLR_ODT_WIDTH             [get_parameter_value AFI_ODT_WIDTH            ]
	set_parameter_value AFI_CTLR_CONTROL_WIDTH         [get_parameter_value AFI_CONTROL_WIDTH        ]
	set_parameter_value AFI_CTLR_CLK_EN_WIDTH          [get_parameter_value AFI_CLK_EN_WIDTH         ]
	set_parameter_value AFI_CTLR_CLK_PAIR_COUNT        [get_parameter_value AFI_CLK_PAIR_COUNT       ]
                                                                                                              
	set_parameter_value AFI_MUX_ADDR_WIDTH             [get_parameter_value AFI_ADDR_WIDTH            ]
	set_parameter_value AFI_MUX_BANKADDR_WIDTH         [get_parameter_value AFI_BANKADDR_WIDTH        ]
	set_parameter_value AFI_MUX_WLAT_WIDTH             [get_parameter_value AFI_WLAT_WIDTH            ]
	set_parameter_value AFI_MUX_RLAT_WIDTH             [get_parameter_value AFI_RLAT_WIDTH            ]
	set_parameter_value AFI_MUX_RRANK_WIDTH            [get_parameter_value AFI_RRANK_WIDTH           ]
	set_parameter_value AFI_MUX_WRANK_WIDTH            [get_parameter_value AFI_WRANK_WIDTH           ]
	set_parameter_value AFI_MUX_DM_WIDTH               [get_parameter_value AFI_DM_WIDTH              ]
	set_parameter_value AFI_MUX_DQ_WIDTH               [get_parameter_value AFI_DQ_WIDTH              ]
	set_parameter_value AFI_MUX_WRITE_DQS_WIDTH        [get_parameter_value AFI_WRITE_DQS_WIDTH       ]
	set_parameter_value AFI_MUX_RATE_RATIO             [get_parameter_value AFI_RATE_RATIO            ]
	set_parameter_value AFI_MUX_CLK_PAIR_COUNT         [get_parameter_value AFI_CLK_PAIR_COUNT        ]



	set_parameter_value AFI_MUX_CS_WIDTH               $afi_mux_cs_width
	set_parameter_value AFI_MUX_ODT_WIDTH              $afi_mux_odt_width
	set_parameter_value AFI_MUX_CLK_EN_WIDTH           $afi_mux_clk_en_width
	set_parameter_value AFI_MUX_CONTROL_WIDTH          [get_parameter_value AFI_CONTROL_WIDTH         ]

	if {([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0)} {
		set_parameter_value DDR2_RDIMM 1
	} else {
		set_parameter_value DDR2_RDIMM 0
	}
}
