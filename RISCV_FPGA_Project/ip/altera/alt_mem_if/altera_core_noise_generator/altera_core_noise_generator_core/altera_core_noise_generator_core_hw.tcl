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
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::system_info
package require alt_mem_if::util::iptclgen

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Altera Uncorrelated Core Noise Generator (uCore)"
set_module_property NAME altera_core_noise_generator_core
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_perf_monitor_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY Core Noise Generator Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL FALSE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL noise
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL noise
add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL noise


proc generate_verilog_fileset {} {
	set file_list [list \
		noise.v \
		noise_gray.v \
		noise_lfsr.v \
		noise_sr.v \
		reset_sync.v \
		iss_probe.v \
		noise_csr.sv \
	]
	
	return $file_list
}

proc generate_clken_block {tmpdir} {

	_iprint "Generating clock pair generator" 1
	
	set params_list [list "CBX_FILE=noise_clken.v" \
			"CBX_OUTPUT_DIRECTORY=$tmpdir" \
			"CBX_AUTO_BLACKBOX=ALL" \
			"CLOCK_TYPE=AUTO" \
			"DEVICE_FAMILY=[get_parameter_value DEVICE_FAMILY]" \
			"ENA_REGISTER_MODE=falling edge" \
			"USE_GLITCH_FREE_SWITCH_OVER_IMPLEMENTATION=OFF" \
			ena inclk outclk]
	
	alt_mem_if::util::iptclgen::generate_ip_clearbox altclkctrl $params_list

	add_fileset_file "noise_clken.v" [::alt_mem_if::util::hwtcl_utils::get_file_type "noise_clken.v"] PATH [file join $tmpdir "noise_clken.v"]
}

proc generate_vhdl_sim {name} {
	_error "VHDL fileset is not supported"
}

proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}
	
	generate_clken_block $tmpdir
}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}

	add_fileset_file noise.sdc SDC PATH noise.sdc

	generate_clken_block $tmpdir
}

::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ float 125
set_parameter_property REF_CLK_FREQ DISPLAY_NAME "PLL reference clock frequency"
set_parameter_property REF_CLK_FREQ UNITS Megahertz
set_parameter_property REF_CLK_FREQ DESCRIPTION "The frequency of the input clock that feeds the PLL.  Up to 4 decimal places of precision can be used."
set_parameter_property REF_CLK_FREQ DISPLAY_HINT columns:10

add_parameter NUM_BLOCKS INTEGER 10 "Specifies number of blocks to instantiate."
set_parameter_property NUM_BLOCKS DISPLAY_NAME "Number of Blocks"
set_parameter_property NUM_BLOCKS ALLOWED_RANGES 1:10000
set_parameter_property NUM_BLOCKS DESCRIPTION "Specifies number of blocks to instantiate."
set_parameter_property NUM_BLOCKS AFFECTS_GENERATION false
set_parameter_property NUM_BLOCKS HDL_PARAMETER true

add_parameter AVL_ADDR_WIDTH INTEGER 8
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME "CSR Address Width"
set_parameter_property AVL_ADDR_WIDTH DESCRIPTION "CSR Address Width"
set_parameter_property AVL_ADDR_WIDTH VISIBLE false
set_parameter_property AVL_ADDR_WIDTH ENABLED false
set_parameter_property AVL_ADDR_WIDTH ALLOWED_RANGES 1:32
set_parameter_property AVL_ADDR_WIDTH AFFECTS_GENERATION false
set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true

add_parameter AVL_DATA_WIDTH INTEGER 32
set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME "CSR Data Width"
set_parameter_property AVL_DATA_WIDTH DESCRIPTION "CSR Data Width"
set_parameter_property AVL_DATA_WIDTH VISIBLE false
set_parameter_property AVL_DATA_WIDTH ENABLED false
set_parameter_property AVL_DATA_WIDTH ALLOWED_RANGES 32
set_parameter_property AVL_DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true

add_parameter AVL_NUM_SYMBOLS INTEGER 4
set_parameter_property AVL_NUM_SYMBOLS VISIBLE false
set_parameter_property AVL_NUM_SYMBOLS ENABLED false
set_parameter_property AVL_NUM_SYMBOLS HDL_PARAMETER true

add_parameter AVL_SYMBOL_WIDTH INTEGER 4
set_parameter_property AVL_SYMBOL_WIDTH VISIBLE false
set_parameter_property AVL_SYMBOL_WIDTH ENABLED false
set_parameter_property AVL_SYMBOL_WIDTH HDL_PARAMETER true

add_parameter NOISEGEN_VERSION INTEGER 110
set_parameter_property NOISEGEN_VERSION VISIBLE false
set_parameter_property NOISEGEN_VERSION HDL_PARAMETER true
set_parameter_property NOISEGEN_VERSION DERIVED true

add_parameter EXPORT_SOFT_RESET BOOLEAN true
set_parameter_property EXPORT_SOFT_RESET VISIBLE false

alt_mem_if::gui::system_info::create_generic_parameters



add_display_item "" "General Settings" GROUP ""
add_display_item "General Settings" NUM_BLOCKS PARAMETER ""



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
	
	set noisegen_version 13.1
	set noisegen_version [expr {int($noisegen_version * 10.0)}]
	set_parameter_value NOISEGEN_VERSION $noisegen_version

	alt_mem_if::gui::system_info::validate_generic_component	

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"


	add_interface pll_clk clock end
	set_interface_property pll_clk ENABLED true
	add_interface_port pll_clk pll_clk clk Input 1

	add_interface csr_clk clock start
	set_interface_property csr_clk ENABLED true
	add_interface_port csr_clk csr_clk clk Output 1

	add_interface global_reset_n reset end
	set_interface_property global_reset_n synchronousEdges NONE
	set_interface_property global_reset_n ENABLED true
	
	add_interface_port global_reset_n global_reset_n reset_n input 1

	add_interface soft_reset_n reset end
	set_interface_property soft_reset_n synchronousEdges NONE
	set_interface_property soft_reset_n ENABLED true
	
	add_interface_port soft_reset_n soft_reset_n reset_n input 1
	if {[string compare -nocase [get_parameter_value EXPORT_SOFT_RESET] "false"] == 0} {
		set_port_property "soft_reset_n" termination true
		set_port_property "soft_reset_n" termination_value 1
	}
	
	

	add_interface csr_reset reset start
	set_interface_property csr_reset associatedClock csr_clk
	if {[string compare -nocase [get_parameter_value EXPORT_SOFT_RESET] "false"] == 0} {
		set_interface_property csr_reset associatedResetSinks [list global_reset_n]
	} else {
		set_interface_property csr_reset associatedResetSinks [list global_reset_n soft_reset_n]
	}
	set_interface_property csr_reset ENABLED true
	add_interface_port csr_reset csr_reset_n reset_n Output 1
	
	add_interface csr avalon end
	set_interface_property csr associatedClock csr_clk
	set_interface_property csr associatedReset csr_reset
	set_interface_property csr maximumPendingReadTransactions 0
	
	set_interface_property csr ENABLED true
	
	add_interface_port csr csr_addr address Input [get_parameter_value AVL_ADDR_WIDTH]
	add_interface_port csr csr_be byteenable Input [get_parameter_value AVL_NUM_SYMBOLS]
	add_interface_port csr csr_write_req write Input 1
	add_interface_port csr csr_wdata writedata Input [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port csr csr_read_req read Input 1
	add_interface_port csr csr_rdata readdata Output [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port csr csr_waitrequest waitrequest Output 1
	
	
	add_interface pll_locked conduit end
	set_interface_property pll_locked ENABLED true
	
	add_interface_port pll_locked pll_locked pll_locked input 1

	

}