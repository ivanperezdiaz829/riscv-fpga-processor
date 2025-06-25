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

package require -exact sopc 10.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::gui::system_info
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::qini
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Simple 1-Port Traffic Generator and BIST Engine Core"
set_module_property NAME simple_1mm_traffic_gen_core
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_pattern_gen_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Simple 1-Port Traffic Generator and BIST Engine Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property DATASHEET_URL "http://www.altera.com/literature/lit-external-memory-interface.jsp"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP



add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth



proc generate_verilog_fileset {name tmpdir} {

	set static_files_list [list \
		driver_top.sv \
		counter_gen.sv \
		reg_delay.sv \
		reset_sync.v \
	]

	return $static_files_list	
	
}

proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach fname [generate_verilog_fileset $name $tmpdir] {
		_dprint 1 "Preparing to add $fname"
		add_fileset_file [file join mentor $fname] [::alt_mem_if::util::hwtcl_utils::get_file_type $fname 1 1] PATH [file join mentor $fname] {MENTOR_SPECIFIC}
		add_fileset_file $fname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname] PATH $fname $non_encryp_simulators
	}
}



proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	foreach fname [generate_verilog_fileset $name $tmpdir] {
		_dprint 1 "Preparing to add $fname"
		add_fileset_file $fname [::alt_mem_if::util::hwtcl_utils::get_file_type $fname] PATH $fname
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




proc _create_derived_parameters {} {
		
	_dprint 1 "Preparing to create derived parameters in avalon_mm_traffic_gen"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_DATA_WIDTH integer 32
	set_parameter_property TG_AVL_DATA_WIDTH DERIVED TRUE
	set_parameter_property TG_AVL_DATA_WIDTH VISIBLE TRUE
	set_parameter_property TG_AVL_DATA_WIDTH HDL_PARAMETER TRUE
	set_parameter_property TG_AVL_DATA_WIDTH DISPLAY_NAME "Actual Avalon Data Width"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_ADDR_WIDTH integer 25
	set_parameter_property TG_AVL_ADDR_WIDTH DERIVED TRUE
	set_parameter_property TG_AVL_ADDR_WIDTH VISIBLE TRUE
	set_parameter_property TG_AVL_ADDR_WIDTH HDL_PARAMETER TRUE
	set_parameter_property TG_AVL_ADDR_WIDTH DISPLAY_NAME "Actual Avalon Address Width"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_WORD_ADDR_WIDTH integer 25
	set_parameter_property TG_AVL_WORD_ADDR_WIDTH DERIVED TRUE
	set_parameter_property TG_AVL_WORD_ADDR_WIDTH VISIBLE false
	set_parameter_property TG_AVL_WORD_ADDR_WIDTH HDL_PARAMETER TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_SIZE_WIDTH integer 2
	set_parameter_property TG_AVL_SIZE_WIDTH DERIVED TRUE
	set_parameter_property TG_AVL_SIZE_WIDTH VISIBLE FALSE
	set_parameter_property TG_AVL_SIZE_WIDTH HDL_PARAMETER TRUE

	set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_SYMBOL_WIDTH INTEGER 8
	set_parameter_property TG_AVL_SYMBOL_WIDTH VISIBLE TRUE
	set_parameter_property TG_AVL_SYMBOL_WIDTH DISPLAY_NAME "Avalon Symbol Width"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_BE_WIDTH integer 2
	set_parameter_property TG_AVL_BE_WIDTH DERIVED TRUE
	set_parameter_property TG_AVL_BE_WIDTH VISIBLE FALSE
	set_parameter_property TG_AVL_BE_WIDTH HDL_PARAMETER TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_NUM_SYMBOLS integer 2
	set_parameter_property TG_AVL_NUM_SYMBOLS DERIVED TRUE
	set_parameter_property TG_AVL_NUM_SYMBOLS VISIBLE TRUE
	set_parameter_property TG_AVL_NUM_SYMBOLS DISPLAY_NAME "Symbols per Word"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_EMIT_BFM_MASTER boolean false
	set_parameter_property ENABLE_EMIT_BFM_MASTER VISIBLE false
	set_parameter_property ENABLE_EMIT_BFM_MASTER DISPLAY_NAME "Enable BFM master for CSR"

	::alt_mem_if::util::hwtcl_utils::_add_parameter DRIVER_SIGNATURE integer 0
	set_parameter_property DRIVER_SIGNATURE DERIVED TRUE
	set_parameter_property DRIVER_SIGNATURE VISIBLE false
	set_parameter_property DRIVER_SIGNATURE DISPLAY_NAME "Driver signature"
	set_parameter_property DRIVER_SIGNATURE HDL_PARAMETER true
	
}

proc _create_general_parameters {} {
		
	_dprint 1 "Preparing to create general parameters in avalon_mm_traffic_gen"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_DATA_WIDTH_IN integer 32
	set_parameter_property TG_AVL_DATA_WIDTH_IN DISPLAY_NAME "Avalon Data Width"
	set_parameter_property TG_AVL_DATA_WIDTH_IN DESCRIPTION "Avalon data-bus width"
	set_parameter_property TG_AVL_DATA_WIDTH_IN ALLOWED_RANGES {1:2048}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_ADDR_WIDTH_IN integer 25
	set_parameter_property TG_AVL_ADDR_WIDTH_IN DISPLAY_NAME "Avalon Address Width"
	set_parameter_property TG_AVL_ADDR_WIDTH_IN DESCRIPTION "Avalon address-bus width."
	set_parameter_property TG_AVL_ADDR_WIDTH_IN ALLOWED_RANGES {1:32}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_GEN_BYTE_ADDR boolean false
	set_parameter_property TG_GEN_BYTE_ADDR DISPLAY_NAME "Generate per byte address"
	set_parameter_property TG_GEN_BYTE_ADDR DESCRIPTION "This option must be enabled if this core is to be used in an SOPC Builder system.  When turned on, the driver will generate per byte address instead per word address"
	set_parameter_property TG_GEN_BYTE_ADDR HDL_PARAMETER true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_MAX_SIZE integer 4
	set_parameter_property TG_AVL_MAX_SIZE DISPLAY_NAME "Maximum Avalon-MM burst length"
	set_parameter_property TG_AVL_MAX_SIZE DESCRIPTION "Specifies the maximum burst length on the Avalon-MM bus.  Affects the TG_AVL_SIZE_WIDTH parameter."
	set_parameter_property TG_AVL_MAX_SIZE ALLOWED_RANGES {1 2 4 8 16 32 64 128 256 512 1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_NUM_DRIVER_LOOP integer 1000
	set_parameter_property TG_NUM_DRIVER_LOOP DISPLAY_NAME "Number of loops through patterns (0 for infinite)"
	set_parameter_property TG_NUM_DRIVER_LOOP DESCRIPTION "Specifies the number of times the driver will loop through all patterns before asserting test complete.<br>
	A value of 0 specifies that the driver should infinitely loop."
	set_parameter_property TG_NUM_DRIVER_LOOP ALLOWED_RANGES {0:1000000}
	set_parameter_property TG_NUM_DRIVER_LOOP HDL_PARAMETER true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BYTE_ENABLE boolean false
	set_parameter_property TG_BYTE_ENABLE DISPLAY_NAME "Generate Avalon-MM byte-enable signal"
	set_parameter_property TG_BYTE_ENABLE DESCRIPTION "When turned on, the driver will generate the byte-enable signal for the Avalon-MM bus"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
	set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_CTRL_AVALON_INTERFACE boolean true
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE DISPLAY_NAME "Enable Avalon interface"
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE false
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE AFFECTS_ELABORATION true

	return 1
}

proc _derive_parameters {} {

	_dprint 1 "Preparing to derive parameters in avalon_mm_traffic_gen"

	set_parameter_value TG_AVL_DATA_WIDTH [get_parameter_value TG_AVL_DATA_WIDTH_IN]

	set_parameter_value TG_AVL_NUM_SYMBOLS [expr {[get_parameter_value TG_AVL_DATA_WIDTH] / [get_parameter_value TG_AVL_SYMBOL_WIDTH]}]
	set data_mod_symbols [expr {[get_parameter_value TG_AVL_DATA_WIDTH] % [get_parameter_value TG_AVL_SYMBOL_WIDTH]}]
	set symbols_log_2 [expr {int(ceil(log([get_parameter_value TG_AVL_NUM_SYMBOLS])/log(2)))}]
	set symbols_log_2_pow_2 [expr {pow(2,$symbols_log_2)}]

	set_parameter_value TG_AVL_WORD_ADDR_WIDTH [get_parameter_value TG_AVL_ADDR_WIDTH_IN]
	if {[string compare -nocase [get_parameter_value TG_GEN_BYTE_ADDR] "true"] == 0 && $data_mod_symbols == 0} {
		set updated_TG_AVL_ADDR_WIDTH [expr {[get_parameter_value TG_AVL_ADDR_WIDTH_IN] + $symbols_log_2}]
		set_parameter_value TG_AVL_ADDR_WIDTH $updated_TG_AVL_ADDR_WIDTH
	} else {
		set_parameter_value TG_AVL_ADDR_WIDTH [get_parameter_value TG_AVL_ADDR_WIDTH_IN]
	}

	set_parameter_value TG_AVL_BE_WIDTH [get_parameter_value TG_AVL_NUM_SYMBOLS]

	set_parameter_value TG_AVL_SIZE_WIDTH [expr {int(ceil(log([get_parameter_value TG_AVL_MAX_SIZE]+1)/log(2)))}]

	
	set driver_version 13.1
	set driver_version_str [expr {$driver_version * 10}]
	set driver_version_int [expr {int($driver_version_str)}]
	if {$driver_version_int != $driver_version_str } {
		_error "Fatal Error: Could not format driver version ($driver_version => $driver_version_str : $driver_version_int"
	}
	set driver_signature [expr {0x55550000 | $driver_version_int}]
	set_parameter_value DRIVER_SIGNATURE $driver_signature
}


proc validate_component {} {

	_derive_parameters

	set validation_pass 1

	set data_width_mod_symbol_width [expr {[get_parameter_value TG_AVL_DATA_WIDTH] % [get_parameter_value TG_AVL_SYMBOL_WIDTH]}]
	set symbols_log_2 [expr {int(ceil(log([get_parameter_value TG_AVL_NUM_SYMBOLS])/log(2)))}]
	set symbols_log_2_pow_2 [expr {pow(2,$symbols_log_2)}]
	set num_symbols_log_2_pow_2_symbols_with [expr {$symbols_log_2_pow_2 * [get_parameter_value TG_AVL_SYMBOL_WIDTH]} ]

	if {[string compare -nocase [get_parameter_value TG_BYTE_ENABLE] "true"] == 0} {

		if { $data_width_mod_symbol_width != 0 || [get_parameter_value TG_AVL_DATA_WIDTH] < [get_parameter_value TG_AVL_SYMBOL_WIDTH]} {
			_eprint "Use of Byte Enable is not possible with the specified data width"
			set validation_pass 0
		}
	}
	
	if {[string compare -nocase [get_parameter_value TG_GEN_BYTE_ADDR] "true"] == 0} {
		if { $data_width_mod_symbol_width != 0} {
			_eprint "Byte addressing is not possible with when the data width is not a multiple of the symbol width"
			set validation_pass 0
		}
	}
	
	return $validation_pass

}

proc elaborate_component {} {

	set data_width_mod_symbol_width [expr {[get_parameter_value TG_AVL_DATA_WIDTH] % [get_parameter_value TG_AVL_SYMBOL_WIDTH]}]
	if { $data_width_mod_symbol_width == 0 && [get_parameter_value TG_AVL_DATA_WIDTH] > [get_parameter_value TG_AVL_SYMBOL_WIDTH]} {
		set_parameter_property TG_BYTE_ENABLE ENABLED TRUE
	} else {
		set_parameter_property TG_BYTE_ENABLE ENABLED FALSE
	}

	return 1
}

proc create_parameters {} {
	_create_derived_parameters
	
	_create_general_parameters
}

proc create_gui {} {
	_dprint 1 "Preparing to create the general GUI in avalon_mm_traffic_gen"
	
	add_display_item "" "Interface Settings" GROUP "tab"
	add_display_item "Interface Settings" "Avalon-MM Settings" GROUP

	add_display_item "Avalon-MM Settings" TG_AVL_DATA_WIDTH_IN PARAMETER
	add_display_item "Avalon-MM Settings" TG_AVL_DATA_WIDTH PARAMETER
	add_display_item "Avalon-MM Settings" TG_AVL_SYMBOL_WIDTH PARAMETER
	add_display_item "Avalon-MM Settings" TG_AVL_NUM_SYMBOLS PARAMETER
	add_display_item "Avalon-MM Settings" TG_POWER_OF_TWO_BUS PARAMETER
	add_display_item "Avalon-MM Settings" TG_SOPC_COMPAT_RESET PARAMETER
	add_display_item "Avalon-MM Settings" TG_AVL_ADDR_WIDTH_IN PARAMETER
	add_display_item "Avalon-MM Settings" TG_AVL_ADDR_WIDTH PARAMETER
	add_display_item "Avalon-MM Settings" TG_GEN_BYTE_ADDR PARAMETER
	add_display_item "Avalon-MM Settings" TG_BURST_BEGIN PARAMETER
	add_display_item "Avalon-MM Settings" TG_AVL_MAX_SIZE PARAMETER
	add_display_item "Avalon-MM Settings" TG_BYTE_ENABLE PARAMETER
	add_display_item "Avalon-MM Settings" TG_PNF_ENABLE PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		add_display_item "" "Avalon-MM Interface" GROUP
	}

	add_display_item "" "Traffic Settings" GROUP "tab"

	add_display_item "Traffic Settings" "Traffic Generation Settings" GROUP
	add_display_item "Traffic Generation Settings" TG_NUM_DRIVER_LOOP PARAMETER 
}


alt_mem_if::gui::system_info::create_parameters
set_parameter_property SPEED_GRADE VISIBLE false
set_parameter_property HARD_EMIF VISIBLE false

create_parameters

create_gui

set_module_property Validation_Callback ip_validate
set_module_property elaboration_Callback ip_elaborate

proc ip_validate {} {
	_dprint 1 "Running IP Validation"

	alt_mem_if::gui::system_info::validate_component
	validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	elaborate_component


	add_interface status conduit end
	
	set_interface_property status ENABLED true
	
	add_interface_port status pass pass Output 1
	add_interface_port status fail fail Output 1
	add_interface_port status test_complete test_complete Output 1
	

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
	add_interface_port avl_clock avl_clk clk Input 1

	add_interface avl_reset reset end
	set_interface_property avl_reset ENABLED true
	set_interface_property avl_reset synchronousEdges none
	add_interface_port avl_reset avl_reset_n reset_n Input 1

	
	
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
	add_interface_port avl avl_burstbegin beginbursttransfer Output 1

	
	if {[string compare -nocase [get_parameter_value TG_BYTE_ENABLE] "true"] == 0} {
		add_interface_port avl avl_be byteenable Output [get_parameter_value TG_AVL_BE_WIDTH]
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



	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL "driver_top"
	}

}

