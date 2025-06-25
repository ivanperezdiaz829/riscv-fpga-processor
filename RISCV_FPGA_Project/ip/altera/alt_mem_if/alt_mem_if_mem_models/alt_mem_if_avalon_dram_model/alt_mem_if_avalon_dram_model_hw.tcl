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



# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact qsys 12.0

# Require alt_mem_if TCL packages
package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils

# Function Imports
namespace import ::alt_mem_if::util::messaging::*

# | 
# +-----------------------------------

# +-----------------------------------
# | module avalon_dram_model
# | 
set_module_property DESCRIPTION "Abstract DRAM Memory Model"
set_module_property NAME altera_mem_if_avalon_dram_model
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::mem_if_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Abstract DRAM Memory Model"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

set_module_assignment postgeneration.simulation.init_file.param_name "MEM_INIT_FILE"
set_module_assignment postgeneration.simulation.init_file.type "MEM_INIT"
set_module_assignment embeddedsw.memoryInfo.GENERATE_DAT_SYM 1

# | 
# +-----------------------------------


# +-----------------------------------
# | parameters
# | 
add_parameter AV_ADDRESS_W INTEGER 32
set_parameter_property AV_ADDRESS_W DISPLAY_NAME "Avalon-MM Address Width"
set_parameter_property AV_ADDRESS_W HDL_PARAMETER true

add_parameter AV_SYMBOL_W INTEGER 8
set_parameter_property AV_SYMBOL_W DISPLAY_NAME "Avalon-MM Symbol Width"
set_parameter_property AV_SYMBOL_W HDL_PARAMETER true

add_parameter AV_NUMSYMBOLS INTEGER 4
set_parameter_property AV_NUMSYMBOLS DISPLAY_NAME "Avalon-MM Num Symbols"
set_parameter_property AV_NUMSYMBOLS HDL_PARAMETER true
set_parameter_property AV_NUMSYMBOLS DERIVED true
set_parameter_property AV_NUMSYMBOLS VISIBLE true

add_parameter AV_BURSTCOUNT_W INTEGER 3
set_parameter_property AV_BURSTCOUNT_W DISPLAY_NAME "Avalon-MM Burst Count"
set_parameter_property AV_BURSTCOUNT_W HDL_PARAMETER true

add_parameter USE_BYTE_ENABLE BOOLEAN true
set_parameter_property USE_BYTE_ENABLE DISPLAY_NAME "Use Byte Enables"
set_parameter_property USE_BYTE_ENABLE HDL_PARAMETER true

add_parameter USE_BURST_BEGIN BOOLEAN true
set_parameter_property USE_BURST_BEGIN DISPLAY_NAME "Use Burst Begin"

add_parameter MEM_INIT_FILE STRING ""
set_parameter_property MEM_INIT_FILE DISPLAY_NAME "Memory Initialization File"
set_parameter_property MEM_INIT_FILE HDL_PARAMETER true

add_parameter AV_DATA_W INTEGER 32
set_parameter_property AV_DATA_W DISPLAY_NAME "Avalon-MM Data Width"

add_parameter AV_MASTER_ADDRESS_W INTEGER 0
set_parameter_property AV_MASTER_ADDRESS_W DERIVED true

add_parameter AV_SLAVE_ADDRESS_W INTEGER 0
set_parameter_property AV_SLAVE_ADDRESS_W DERIVED true

add_parameter MAX_READ_TRANSACTIONS INTEGER 16
set_parameter_property MAX_READ_TRANSACTIONS DISPLAY_NAME "Avalon-MM Max Pending Read Transactions"


# | 
# +-----------------------------------

# +-----------------------------------
# | Fileset Callbacks
# | 
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL alt_mem_if_avalon_dram_model

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL alt_mem_if_avalon_dram_model

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL alt_mem_if_avalon_dram_model


proc generate_vhdl_sim {name} {
	# Return the normal verilog file for dual language simulators
	add_fileset_file alt_mem_if_avalon_dram_model.sv SYSTEM_VERILOG PATH alt_mem_if_avalon_dram_model.sv [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	# Return the mentor encrypted files
	add_fileset_file [file join mentor alt_mem_if_avalon_dram_model.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor alt_mem_if_avalon_dram_model.sv] {MENTOR_SPECIFIC}
}

proc generate_verilog_sim {name} {
	# Return the abstract model
	add_fileset_file alt_mem_if_avalon_dram_model.sv SYSTEM_VERILOG PATH alt_mem_if_avalon_dram_model.sv	
}

proc generate_synth {name} {
	# Return the abstract model
	add_fileset_file alt_mem_if_avalon_dram_model.sv SYSTEM_VERILOG PATH alt_mem_if_avalon_dram_model.sv	
}

# | 
# +-----------------------------------


# +-----------------------------------
# | Elaboration/validation callbacks
# | 
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

	# Derive parameters

	# The data width of the interface
	set_parameter_value AV_NUMSYMBOLS [expr {[get_parameter_value AV_DATA_W] / [get_parameter_value AV_SYMBOL_W]}]
	set symbol_w_mult_num_sumbols [expr {[get_parameter_value AV_SYMBOL_W] * [get_parameter_value AV_NUMSYMBOLS]}]
	if {$symbol_w_mult_num_sumbols != [get_parameter_value AV_DATA_W]} {
		_error "Data width is not an integer multiple of the number of symbols"
	}
	
	# The master and slave address widths
	set_parameter_value AV_MASTER_ADDRESS_W  [expr { [get_parameter_value AV_ADDRESS_W] + int(ceil(log([get_parameter_value AV_NUMSYMBOLS])/log(2))) }]
	set_parameter_value AV_SLAVE_ADDRESS_W [get_parameter_value AV_ADDRESS_W]

	# Validate the parameters
	if {[regexp {^[ ]*$} [get_parameter_value MEM_INIT_FILE] match] == 1} {
		_wprint "No memory initialization file specified"
	}
	
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	# +-----------------------------------
	# | connection point avl_clock
	# | 
	add_interface avl_clock clock end
	set_interface_property avl_clock ENABLED true
	add_interface_port avl_clock avl_clock clk Input 1
	# | 
	# +-----------------------------------
	
	# +-----------------------------------
	# | connection point avl_reset
	# | 
	add_interface avl_reset reset end
	set_interface_property avl_reset synchronousEdges NONE
	set_interface_property avl_reset ENABLED true
	add_interface_port avl_reset avl_reset_n reset_n Input 1
	# | 
	# +-----------------------------------


	# +-----------------------------------
	# | connection point avl_s
	# | 
	add_interface avl_s avalon end
	set_interface_property avl_s addressUnits WORDS
	set_interface_property avl_s associatedClock avl_clock
	set_interface_property avl_s associatedReset avl_reset
	set_interface_property avl_s bitsPerSymbol [get_parameter_value AV_SYMBOL_W]
	set_interface_property avl_s burstcountUnits WORDS
	# KALEN: Magic setting. Should be a better value
	set_interface_property avl_s maximumPendingReadTransactions [get_parameter_value MAX_READ_TRANSACTIONS]
	
	# Specify that the Avalon-MM interface is a memory device for use
	# with NIOS. The value must be "1"
	set_interface_property avl_s isMemoryDevice 1
	
	set_interface_property avl_s ENABLED true
	add_interface_port avl_s avs_waitrequest_n waitrequest_n Output 1
	add_interface_port avl_s avs_read read Input 1
	add_interface_port avl_s avs_write write Input 1
	add_interface_port avl_s avs_address address Input [get_parameter_value AV_SLAVE_ADDRESS_W]
	add_interface_port avl_s avs_byteenable byteenable Input [get_parameter_value AV_NUMSYMBOLS]
	add_interface_port avl_s avs_writedata writedata Input [get_parameter_value AV_DATA_W]
	add_interface_port avl_s avs_burstcount burstcount Input [get_parameter_value AV_BURSTCOUNT_W]
	add_interface_port avl_s avs_readdata readdata Output [get_parameter_value AV_DATA_W]
	add_interface_port avl_s avs_readdatavalid readdatavalid Output 1
	add_interface_port avl_s avs_burstbegin beginbursttransfer Input 1
	
	# Terminate unneeded interfaces
	if {[string compare -nocase [get_parameter_value USE_BYTE_ENABLE] "true"] != 0} {
		set_port_property avs_byteenable termination true
	}
	if {[string compare -nocase [get_parameter_value USE_BURST_BEGIN] "true"] != 0} {
		set_port_property avs_burstbegin termination true
		set_port_property avs_burstbegin termination_value 0
	}
	
	# | 
	# +-----------------------------------
	
	# +-----------------------------------
	# | connection point avl_m
	# | 
	add_interface avl_m avalon start
	set_interface_property avl_m addressUnits SYMBOLS
	set_interface_property avl_m associatedClock avl_clock
	set_interface_property avl_m associatedReset avl_reset
	set_interface_property avl_m bitsPerSymbol [get_parameter_value AV_SYMBOL_W]
	
	set_interface_property avl_m ENABLED true
	
	add_interface_port avl_m avm_waitrequest_n waitrequest_n Input 1
	add_interface_port avl_m avm_write write Output 1
	add_interface_port avl_m avm_read read Output 1
	add_interface_port avl_m avm_address address Output [get_parameter_value AV_MASTER_ADDRESS_W]
	add_interface_port avl_m avm_byteenable byteenable Output [get_parameter_value AV_NUMSYMBOLS]
	add_interface_port avl_m avm_burstcount burstcount Output [get_parameter_value AV_BURSTCOUNT_W]
	add_interface_port avl_m avm_writedata writedata Output [get_parameter_value AV_DATA_W]
	add_interface_port avl_m avm_readdata readdata Input [get_parameter_value AV_DATA_W]
	add_interface_port avl_m avm_readdatavalid readdatavalid Input 1
	add_interface_port avl_m avm_burstbegin beginbursttransfer Output 1

	# Terminate unneeded interfaces
	if {[string compare -nocase [get_parameter_value USE_BYTE_ENABLE] "true"] != 0} {
		set_port_property avm_byteenable termination true
		set_port_property avm_byteenable termination_value 0
	}
	if {[string compare -nocase [get_parameter_value USE_BURST_BEGIN] "true"] != 0} {
		set_port_property avm_burstbegin termination true
	}

	# | 
	# +-----------------------------------

	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH [get_parameter_value AV_DATA_W]
	set_module_assignment embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR SIM_DIR	

}
# | 
# +-----------------------------------

