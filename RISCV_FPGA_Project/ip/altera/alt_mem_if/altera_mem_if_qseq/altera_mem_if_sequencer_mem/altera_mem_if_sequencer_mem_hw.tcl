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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "UniPHY Sequencer Memory"
set_module_property NAME altera_mem_if_sequencer_mem
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY Sequencer Memory"
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
		USE_DUAL_PORT \
	]

	set core_params_list [list]

	
	if {[string compare -nocase [get_parameter_value USE_DUAL_PORT] "true"] == 0} {
		lappend core_params_list "USE_DUAL_PORT"
	}
	
	return $core_params_list
	
}


proc generate_verilog_fileset {name tmpdir} {

	set core_params_list [solve_core_params]

	set inhdl_files_list [list \
		altera_mem_if_sequencer_mem.sv \
	]

	set generated_files_list [list]

	foreach ifdef_source_file $inhdl_files_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $ifdef_source_file $core_params_list]
		lappend generated_files_list $generated_file
	}

	_dprint 1 "Using generated files list of $generated_files_list"

	return $generated_files_list
	
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_sequencer_mem.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
	add_fileset_file [file join mentor $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor $generated_file] {MENTOR_SPECIFIC}

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_sequencer_mem.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_sequencer_mem.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}


add_parameter AVL_DATA_WIDTH INTEGER 32
set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME AVL_DATA_WIDTH
set_parameter_property AVL_DATA_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property AVL_DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true

add_parameter AVL_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME AVL_ADDR_WIDTH
set_parameter_property AVL_ADDR_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property AVL_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true

add_parameter AVL_NUM_SYMBOLS INTEGER 4
set_parameter_property AVL_NUM_SYMBOLS DISPLAY_NAME AVL_NUM_SYMBOLS
set_parameter_property AVL_NUM_SYMBOLS AFFECTS_ELABORATION true
set_parameter_property AVL_NUM_SYMBOLS HDL_PARAMETER true
set_parameter_property AVL_NUM_SYMBOLS DERIVED true

add_parameter AVL_SYMBOL_WIDTH INTEGER 8
set_parameter_property AVL_SYMBOL_WIDTH DISPLAY_NAME AVL_SYMBOL_WIDTH
set_parameter_property AVL_SYMBOL_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property AVL_SYMBOL_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_SYMBOL_WIDTH HDL_PARAMETER true

add_parameter MEM_SIZE INTEGER 1024
set_parameter_property MEM_SIZE DISPLAY_NAME MEM_SIZE
set_parameter_property MEM_SIZE HDL_PARAMETER true
set_parameter_property MEM_SIZE AFFECTS_ELABORATION true

add_parameter INIT_FILE string ""
set_parameter_property INIT_FILE DISPLAY_NAME INIT_FILE
set_parameter_property INIT_FILE HDL_PARAMETER true

add_parameter RAM_BLOCK_TYPE string "AUTO"
set_parameter_property RAM_BLOCK_TYPE DISPLAY_NAME RAM_BLOCK_TYPE
set_parameter_property RAM_BLOCK_TYPE ALLOWED_RANGES {"AUTO:Auto" "MLAB:MLAB"}
set_parameter_property RAM_BLOCK_TYPE HDL_PARAMETER true

add_parameter USE_DUAL_PORT boolean false
set_parameter_property USE_DUAL_PORT DISPLAY_NAME USE_DUAL_PORT
set_parameter_property USE_DUAL_PORT AFFECTS_ELABORATION true




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
	
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	set ii_list [list "1"]
	if {[string compare -nocase [get_parameter_value USE_DUAL_PORT] "true"] == 0} {
		lappend ii_list "2"
	}


	foreach ii $ii_list {
		add_interface clk${ii} clock end
		set_interface_property clk${ii} ENABLED true
		add_interface_port clk${ii} clk${ii} clk Input 1

		add_interface reset${ii} reset end
		set_interface_property reset${ii} associatedClock clk${ii}
		set_interface_property reset${ii} synchronousEdges DEASSERT
		set_interface_property reset${ii} ENABLED true
		add_interface_port reset${ii} reset${ii} reset Input 1

		if {$ii == 1} {
			add_interface clken${ii} conduit end
			set_interface_property clken${ii} associatedClock clk${ii}
			set_interface_property clken${ii} associatedReset "rst"
			set_interface_property clken${ii} ENABLED true
			add_interface_port clken${ii} clken${ii} clken Input 1
		}         

		add_interface s${ii} avalon end
		set_interface_property s${ii} addressUnits WORDS
		set_interface_property s${ii} associatedClock clk${ii}
		set_interface_property s${ii} associatedReset reset${ii}
		set_interface_property s${ii} bitsPerSymbol 8
		set_interface_property s${ii} burstOnBurstBoundariesOnly false
		set_interface_property s${ii} burstcountUnits WORDS
		set_interface_property s${ii} constantBurstBehavior true
		set_interface_property s${ii} ENABLED true
		set_interface_property s${ii} isMemoryDevice true
		set_interface_property s${ii} readLatency 1
		set_interface_property s${ii} readWaitTime 0
		set_interface_property s${ii} explicitAddressSpan [get_parameter_value MEM_SIZE]
		
		add_interface_port s${ii} s${ii}_address address input [get_parameter_value AVL_ADDR_WIDTH]
		add_interface_port s${ii} s${ii}_write write input 1
		add_interface_port s${ii} s${ii}_writedata writedata input [get_parameter_value AVL_DATA_WIDTH]
		add_interface_port s${ii} s${ii}_readdata readdata output [get_parameter_value AVL_DATA_WIDTH]
		add_interface_port s${ii} s${ii}_be byteenable input [get_parameter_value AVL_NUM_SYMBOLS]
		add_interface_port s${ii} s${ii}_chipselect chipselect input 1
		if {$ii == 2} {
			add_interface_port s${ii} s${ii}_clken clken input 1
		}
	}

	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_sequencer_mem.sv" [solve_core_params] 1]
	}

}
