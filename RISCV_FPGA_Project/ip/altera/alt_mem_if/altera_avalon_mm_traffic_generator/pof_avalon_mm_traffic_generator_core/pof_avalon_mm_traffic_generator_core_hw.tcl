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
package require alt_mem_if::gui::avalon_mm_traffic_gen
package require alt_mem_if::gui::system_info
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::qini
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Traffic Generator and BIST Engine Core for POF Verification"
set_module_property NAME pof_avalon_mm_traffic_generator_core
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_pattern_gen_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Traffic Generator and BIST Engine Core for POF Verification"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property DATASHEET_URL "http://www.altera.com/literature/lit-external-memory-interface.jsp"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP



add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth



proc solve_core_params {} {
	set supported_ifdefs_list [list \
		AVL_USE_BE \
		AVL_USE_BURSTBEGIN \
		QDRII \
		ERROR_DETECTION_PARITY
	]

		
	set core_params_list [list]

	
	if {[string compare -nocase [get_parameter_value TG_BYTE_ENABLE] "true"] == 0} {
		lappend core_params_list "AVL_USE_BE"
	}
	
	if {[string compare -nocase [get_parameter_value TG_BURST_BEGIN] "true"] == 0} {
		lappend core_params_list "AVL_USE_BURSTBEGIN"
	}

	if {[string compare -nocase [get_parameter_value TG_TWO_AVL_INTERFACES] "true"] == 0} {
		lappend core_params_list "QDRII"
	}
	
	return $core_params_list
	
}

proc generate_verilog_fileset {name tmpdir} {

	set qdir $::env(QUARTUS_ROOTDIR)
	set inhdl_dir "${qdir}/../ip/altera/altera_avalon_mm_traffic_generator/pof_avalon_mm_traffic_generator_core"
	
	set core_params_list [solve_core_params]

	set inhdl_files_list [list \
		avalon_traffic_gen.sv \
		block_rw_stage.sv \
		driver.sv \
		driver_fsm.sv \
		read_compare.sv \
		single_rw_stage.sv
	]

        set define_files_list [list \
		driver_definitions.sv
        ]

	set static_files_list [list \
		addr_gen.sv \
		burst_boundary_addr_gen.sv \
		lfsr.sv \
		lfsr_wrapper.sv \
		rand_addr_gen.sv \
		rand_burstcount_gen.sv \
		rand_num_gen.sv \
		rand_seq_addr_gen.sv \
		reset_sync.v \
		scfifo_wrapper.sv \
		seq_addr_gen.sv \
		template_addr_gen.sv \
		template_stage.sv \
		driver_csr.sv \
                user_addr_gen.sv \
                user_input.sv
	]

        set bin_hex_files_list [list \
		user_input_addr.hex
        ]

	set generated_files_list [list]

	foreach define_file $define_files_list {
		lappend generated_files_list $define_file
	}

	foreach static_file $static_files_list {
		lappend generated_files_list $static_file
	}
	
	foreach ifdef_source_file $inhdl_files_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $ifdef_source_file $core_params_list]
		lappend generated_files_list $generated_file
	}

	foreach bin_hex_file $bin_hex_files_list {
		lappend generated_files_list $bin_hex_file
	}

	_dprint 1 "Using generated files list of $generated_files_list"

	return $generated_files_list	
	
}

proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach fname [generate_verilog_fileset $name $tmpdir] {
		_dprint 1 "Preparing to add $fname"
		add_fileset_file [file join mentor $fname] [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 1 1] PATH [file join mentor $fname] {MENTOR_SPECIFIC}
		add_fileset_file $fname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 0] PATH $fname $non_encryp_simulators
	}
}



proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	foreach fname [generate_verilog_fileset $name $tmpdir] {
		_dprint 1 "Preparing to add $fname"
		add_fileset_file $fname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 0] PATH $fname
	}
}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	foreach fname [generate_verilog_fileset $name $tmpdir] {
		_dprint 1 "Preparing to add $fname"
		add_fileset_file $fname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 0] PATH $fname
	}
}



alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::avalon_mm_traffic_gen::create_parameters

alt_mem_if::gui::avalon_mm_traffic_gen::create_gui

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
	alt_mem_if::gui::avalon_mm_traffic_gen::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::avalon_mm_traffic_gen::elaborate_component


	add_interface status conduit end
	
	set_interface_property status ENABLED true
	
	add_interface_port status pass pass Output 1
	add_interface_port status fail fail Output 1
	add_interface_port status test_complete test_complete Output 1
	

	add_interface unique_done conduit start
        set_interface_property unique_done ENABLED true
	add_interface_port unique_done unique_done unique_done Output 1

	add_interface unique_ready conduit start
        set_interface_property unique_ready ENABLED true
	add_interface_port unique_ready unique_ready unique_ready Output 1
	
	add_interface coordinator_ready conduit end
        set_interface_property coordinator_ready ENABLED true
	add_interface_port coordinator_ready coordinator_ready coordinator_ready Input 1

	add_interface pnf conduit end
	
	set_interface_property pnf ENABLED true

	add_interface_port pnf pnf_per_bit pnf_per_bit Output [get_parameter_value TG_AVL_DATA_WIDTH]
	add_interface_port pnf pnf_per_bit_persist pnf_per_bit_persist Output [get_parameter_value TG_AVL_DATA_WIDTH]
	if {[string compare -nocase [get_parameter_value TG_PNF_ENABLE] "false"] == 0} {
		foreach port_name [get_interface_ports pnf] {
			set_port_property $port_name termination true
		}
	}
	
	add_interface avl_clock clock end
	set_interface_property avl_clock ENABLED true
	add_interface_port avl_clock clk clk Input 1

	add_interface avl_reset reset end
	set_interface_property avl_reset ENABLED true
	set_interface_property avl_reset synchronousEdges none
	add_interface_port avl_reset reset_n reset_n Input 1

	
	if {[string compare -nocase [get_parameter_value TG_TWO_AVL_INTERFACES] "false"] == 0} {
		
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl avalon start
		
			set_interface_property avl associatedClock avl_clock 
			set_interface_property avl associatedReset avl_reset 
			set_interface_property avl ENABLED true
			set_interface_property avl bitsPerSymbol [get_parameter_value TG_AVL_SYMBOL_WIDTH]
		} else {
			add_interface avl conduit end
		}
	
		add_interface_port avl avl_ready waitrequest_n Input 1
		add_interface_port avl avl_addr address Output [get_parameter_value TG_AVL_ADDR_WIDTH]
		add_interface_port avl avl_size burstcount Output [get_parameter_value TG_AVL_SIZE_WIDTH]
		add_interface_port avl avl_wdata writedata Output [get_parameter_value TG_AVL_DATA_WIDTH]
		add_interface_port avl avl_rdata readdata Input [get_parameter_value TG_AVL_DATA_WIDTH]
		add_interface_port avl avl_write_req write Output 1
		add_interface_port avl avl_read_req read Output 1
		add_interface_port avl avl_rdata_valid readdatavalid Input 1

		
		if {[string compare -nocase [get_parameter_value TG_BYTE_ENABLE] "true"] == 0} {
			add_interface_port avl avl_be byteenable Output [get_parameter_value TG_AVL_BE_WIDTH]
		}

		if {[string compare -nocase [get_parameter_value TG_BURST_BEGIN] "true"] == 0} {
			add_interface_port avl avl_burstbegin beginbursttransfer Output 1
		}

	} else {
		

		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl_w avalon start
		
			set_interface_property avl_w associatedClock avl_clock 
			set_interface_property avl_w associatedReset avl_reset 
			set_interface_property avl_w ENABLED true
			set_interface_property avl_w bitsPerSymbol [get_parameter_value TG_AVL_SYMBOL_WIDTH]
		} else {
			add_interface avl_w conduit end
		}
	
		add_interface_port avl_w avl_write_req write Output 1
		add_interface_port avl_w avl_ready_w waitrequest_n Input 1
		add_interface_port avl_w avl_addr_w address Output [get_parameter_value TG_AVL_ADDR_WIDTH]
		add_interface_port avl_w avl_size_w burstcount Output [get_parameter_value TG_AVL_SIZE_WIDTH]
		add_interface_port avl_w avl_wdata writedata Output [get_parameter_value TG_AVL_DATA_WIDTH]
	
		if {[string compare -nocase [get_parameter_value TG_BYTE_ENABLE] "true"] == 0} {
			add_interface_port avl_w avl_be byteenable Output [get_parameter_value TG_AVL_BE_WIDTH]
		}

	

		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl_r avalon start
		
			set_interface_property avl_r associatedClock avl_clock 
			set_interface_property avl_r associatedReset avl_reset 
			set_interface_property avl_r ENABLED true
			set_interface_property avl_r bitsPerSymbol [get_parameter_value TG_AVL_SYMBOL_WIDTH]
		} else {
			add_interface avl_r conduit end
		}
	
		add_interface_port avl_r avl_read_req read Output 1
		add_interface_port avl_r avl_ready waitrequest_n Input 1
		add_interface_port avl_r avl_addr address Output [get_parameter_value TG_AVL_ADDR_WIDTH]
		add_interface_port avl_r avl_size burstcount Output [get_parameter_value TG_AVL_SIZE_WIDTH]
		add_interface_port avl_r avl_rdata_valid readdatavalid Input 1
		add_interface_port avl_r avl_rdata readdata Input [get_parameter_value TG_AVL_DATA_WIDTH]
	
	}



	add_interface csr avalon slave
	set_interface_property csr addressUnits WORDS
	set_interface_property csr associatedClock avl_clock
	set_interface_property csr associatedReset avl_reset
	set_interface_property csr bitsPerSymbol 8
	set_interface_property csr burstOnBurstBoundariesOnly false
	set_interface_property csr burstcountUnits WORDS
	set_interface_property csr constantBurstBehavior true
	
	set_interface_property csr ENABLED true
	
	add_interface_port csr csr_address address input 13

	add_interface_port csr csr_write write input 1
	add_interface_port csr csr_writedata writedata input 32
	add_interface_port csr csr_read read input 1
	add_interface_port csr csr_readdata readdata output 32
	add_interface_port csr csr_waitrequest waitrequest output 1
	add_interface_port csr csr_be byteenable input 4

	if {[string compare -nocase [get_parameter_value TG_ENABLE_DRIVER_CSR_MASTER] "true"] == 0 &&
	    ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination csr 0
	}


	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "driver.sv" [solve_core_params] 1]
	}

}

