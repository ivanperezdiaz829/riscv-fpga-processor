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


# +-----------------------------------
# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
# +-----------------------------------


# +-----------------------------------
# | 
package require -exact qsys 12.0

# Require alt_mem_if TCL packages
package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::qini
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::common_ddrx_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::diagnostics

# Function Imports
namespace import ::alt_mem_if::util::messaging::*

# +-----------------------------------
# | 
set_module_property DESCRIPTION "HHP/HPS Sequencer"
set_module_property NAME altera_mem_if_hhp_${LC_PROTOCOL}_qseq
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencers_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "HHP/HPS Sequencer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# Hide the block diagram
add_display_item "" "Block Diagram" GROUP


# +-----------------------------------
# | Fileset Callbacks
# | 
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_mem_if_hhp_qseq_top

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_mem_if_hhp_qseq_top

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL altera_mem_if_hhp_qseq_synth_top


proc generate_vhdl_sim {name} {
	_eprint "VHDL Simulation not supported"
}

proc generate_verilog_sim {name} {
	_iprint "Generating simulation fileset for $name"
	generate_files $name SIM_VERILOG
}

proc generate_synth {name} {
	_iprint "Generating simulation fileset for $name"
	generate_files $name QUARTUS_SYNTH
}

# same files for synth and sim
proc generate_files {name fileset} {

	# for synth, just generate software and return
	if {[string compare -nocase $fileset QUARTUS_SYNTH] == 0} {
		set top_level_file "altera_mem_if_hhp_qseq_synth_top.v"
		add_fileset_file $top_level_file [::alt_mem_if::util::hwtcl_utils::get_file_type $top_level_file 0] PATH $top_level_file
		generate_sw $name $fileset
		return
	}
	
	set rtl_file_list_icd [list \
		seq_altera_avalon_dc_fifo.v \
		seq_altera_avalon_mm_bridge.v \
		seq_altera_avalon_mm_clock_crossing_bridge.v \
		seq_altera_avalon_sc_fifo.v \
		seq_altera_avalon_st_pipeline_base.v \
		seq_altera_hhp_apb2avalon_bridge.v \
		seq_altera_mem_if_simple_avalon_mm_bridge.v \
		seq_altera_merlin_arbitrator.v \
		seq_altera_merlin_burst_uncompressor.v \
		seq_altera_merlin_master_agent.v \
		seq_altera_merlin_master_translator.v \
		seq_altera_merlin_slave_agent.v \
		seq_altera_merlin_slave_translator.v \
		seq_altera_merlin_traffic_limiter.v \
		seq_addr_router.v \
		seq_addr_router_001.v \
		seq_cmd_xbar_demux.v \
		seq_cmd_xbar_demux_001.v \
		seq_cmd_xbar_mux.v \
		seq_id_router.v \
		seq_rsp_xbar_demux.v \
		seq_rsp_xbar_mux.v \
		seq_hhp_decompress_avl_mm_bridge.v \
		seq_reg_file.v \
		seq_scc_hhp_phase_decode.v \
		seq_scc_hhp_wrapper.v \
		seq_scc_mgr.v \
		seq_scc_reg_file.v \
		seq_trk_mgr.v \
		seq_id_router_default_decode.v \
		seq_altera_merlin_arb_adder.v \
		seq_addr_router_default_decode.v \
		seq_addr_router_001_default_decode.v \
		seq.v \
	]

	set rtl_file_list_icd_lib [list \
		alt_mem_ddrx_buffer.v \
		alt_mem_ddrx_fifo.v \
		hmctl_synchronizer.v \
	]

	set rtl_file_list_alt_lib [list \
		altera_dcfifo_synchronizer_bundle.v \
	]
	
	foreach file_name $rtl_file_list_icd {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file seq/$file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH [file join "rtl" "icd" $file_name]
	}

	foreach file_name $rtl_file_list_icd_lib {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file seq_lib/$file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH [file join "rtl" "icd_lib" $file_name]
	}

	# not currently required, since we use the icd_lib versions
	#foreach file_name $rtl_file_list_alt_lib {
	#	_dprint 1 "Preparing to add $file_name"
	#	add_fileset_file seq_lib/$file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH [file join "rtl" "alt_lib" $file_name]
	#}
	
	set top_level_file "altera_mem_if_hhp_qseq_top.v"
	
	add_fileset_file $top_level_file [::alt_mem_if::util::hwtcl_utils::get_file_type $top_level_file 0] PATH $top_level_file

	generate_sw $name $fileset
}

proc generate_sw {name fileset} {

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"
	
	set protocol [get_parameter_value "HPS_PROTOCOL"]

	# doesn't really matter
	set mem_size 32768

	# RDIMM/LRDIMM is not supported on HPS
	set rdimm 0
	set lrdimm 0

	set prefix "hps"
	set return_files_sw [alt_mem_if::gen::uniphy_gen::generate_qsys_sequencer_sw $prefix $protocol $tmpdir $fileset {} $rdimm $lrdimm $mem_size $mem_size \
				 "${prefix}_sequencer_mem.hex" "${prefix}_AC_ROM.hex" "${prefix}_inst_ROM.hex"]

	foreach file_pathname $return_files_sw {
		_dprint 1 "Preparing to add $file_pathname"
		set file_name [file tail $file_pathname]
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_pathname
	}
}

# | 
# +-----------------------------------

# +-----------------------------------
# | Build the GUI
# | 
alt_mem_if::gui::afi::set_protocol $UC_PROTOCOL
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode $UC_PROTOCOL
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode $UC_PROTOCOL
alt_mem_if::gui::ddrx_controller::create_parameters
alt_mem_if::gui::common_ddrx_phy::set_ddr_mode $UC_PROTOCOL
alt_mem_if::gui::common_ddrx_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::diagnostics::create_parameters

add_parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH DERIVED true

add_parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH DERIVED true

add_parameter HPS_PROTOCOL STRING $UC_PROTOCOL
set_parameter_property HPS_PROTOCOL DISPLAY_NAME HPS_PROTOCOL

set_parameter_property MEM_IF_DQS_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_DQ_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_DM_WIDTH HDL_PARAMETER true
set_parameter_property MEM_IF_CS_WIDTH HDL_PARAMETER true

# +-----------------------------------
# | Elaboration/validation callbacks
# | 

set_module_property Validation_Callback ip_validate
set_module_property elaboration_Callback ip_elaborate

proc ip_validate {} {
	_iprint "Running IP Validation for [get_module_property NAME]"

	# Validation order matters. It must be system_info, memory model, AFI, then controller/phy
	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::ddrx_controller::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_ddrx_phy::validate_component
}

proc ip_elaborate {} {
	_iprint "Running IP Elaboration for [get_module_property NAME]"

	# Elaboration order matters. It must be system_info, memory model, AFI, then controller/phy
	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component
	alt_mem_if::gui::uniphy_controller_phy::elaborate_component
	alt_mem_if::gui::ddrx_controller::elaborate_component
	alt_mem_if::gui::uniphy_phy::elaborate_component
	alt_mem_if::gui::common_ddrx_phy::elaborate_component

	set verification [expr [string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] == 0]
	set simulation [expr [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] == 0]
	set synthesis [expr !$verification && !$simulation]

	if {$synthesis} {
		# nothing to do for synthesis version
		return
	}
	

	# +-----------------------------------
	# | avl_clk interface
	# | 
	add_interface avl_clk clock end
	set_interface_property avl_clk ENABLED true
	add_interface_port avl_clk avl_clk clk Input 1
	# | 
	# +-----------------------------------
	

	# +-----------------------------------
	# | avl_reset interface
	# | 
	add_interface avl_reset reset end
	set_interface_property avl_reset ENABLED true
	set_interface_property avl_reset synchronousEdges NONE
	add_interface_port avl_reset avl_reset_n reset_n Input 1
	# | 
	# +-----------------------------------
	

	# +-----------------------------------
	# | SCC manager interfaces 
	# |

	# Create the SCC clock interface
	add_interface scc_clk clock end
	set_interface_property scc_clk ENABLED true
	add_interface_port scc_clk scc_clk clk Input 1

	# Create the SCC reset interface
	add_interface scc_reset reset end
	set_interface_property scc_reset ENABLED true
	set_interface_property scc_reset synchronousEdges NONE
	# MarkW: TODO
	#add_interface_port scc_reset scc_reset_n reset_n Input 1
	add_interface_port scc_reset reset_n_scc_clk reset_n Input 1

	# Create the SCC interface
	::alt_mem_if::gen::uniphy_interfaces::scc_manager "sequencer"

	# Create the AFI init/cal request interface
	::alt_mem_if::gen::uniphy_interfaces::afi_init_cal_req "sequencer"

	# | 
	# +-----------------------------------


	# Create the Avalon-MM interface
	# ::alt_mem_if::gen::uniphy_interfaces::qsys_sequencer_avl "master"
	# dependencies on parameters that we don't control
	add_interface avl avalon start
	set_interface_property avl addressUnits WORDS
	set_interface_property avl associatedClock avl_clk
	set_interface_property avl associatedReset avl_reset
	set_interface_property avl bitsPerSymbol 8
	set_interface_property avl burstOnBurstBoundariesOnly false
	set_interface_property avl burstcountUnits WORDS
	set_interface_property avl constantBurstBehavior true
	set_interface_property avl ENABLED true
	add_interface_port avl avl_address address output 16
	add_interface_port avl avl_write write output 1
	add_interface_port avl avl_writedata writedata output 32
	add_interface_port avl avl_read read output 1
	add_interface_port avl avl_readdata readdata input 32
	add_interface_port avl avl_waitrequest waitrequest input 1

	# Create the APB clock interface
	add_interface apb_clk clock end
	set_interface_property apb_clk ENABLED true
	add_interface_port apb_clk apb_clk clk Input 1

	# Create the APB reset interface
	add_interface apb_reset reset end
	set_interface_property apb_reset ENABLED true
	set_interface_property apb_reset synchronousEdges NONE
	add_interface_port apb_reset apb_reset_n reset_n Input 1

	# Create APB bus interface (need to put this into utils)
	add_interface apb_slave conduit end
	set_interface_property apb_slave ENABLED true
	add_interface_port apb_slave prdata prdata Output 32
	add_interface_port apb_slave pready pready Output 1
	add_interface_port apb_slave pslverr pslverr Output 1
	add_interface_port apb_slave pwdata pwdata Input 32
	add_interface_port apb_slave pwrite pwrite Input 1
	add_interface_port apb_slave penable penable Input 1
	add_interface_port apb_slave psel psel Input 1
	add_interface_port apb_slave paddr paddr Input 32
	
	::alt_mem_if::gen::uniphy_interfaces::qsys_sequencer_mmr "master" 
	
	# Add tracking interface
	::alt_mem_if::gen::uniphy_interfaces::tracking_interface "phy" 1

}
