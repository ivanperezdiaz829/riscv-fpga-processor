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
# | request TCL package from ACDS 12.0
# | 
package require -exact qsys 12.0

# Require alt_mem_if TCL packages
package require alt_mem_if::util::messaging
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

# Function Imports
namespace import ::alt_mem_if::util::messaging::*

# +-----------------------------------
# | 
set_module_property DESCRIPTION "Altera Advanced SEU Detection core component"
set_module_property NAME altera_adv_seu_detection_core
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property HIDE_FROM_QSYS true
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Advanced SEU Detection core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

# +-----------------------------------
# | Fileset Callbacks
# | 
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth



proc generate_verilog_fileset {name ifdef_params} {
	
	set ifdef_source_list {}
	
	if { [get_parameter_value use_memory_interface] } {
		lappend ifdef_source_list "altera_adv_seu_detection_proc_int.v"
		
		if { [is_ht_supported] } {
			lappend ifdef_params "REGION_TAG"
		}	 
	} else {
		lappend ifdef_source_list "altera_adv_seu_detection_proc_ext.v"
	}

	foreach file_name $ifdef_source_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $file_name $ifdef_params]
		send_message info "Adding $generated_file as $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $generated_file
	}

	set source_list [list \
		altera_adv_seu_detection_common.v \
	]

	foreach file_name $source_list {
		send_message info "Adding $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}	
}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set ifdef_params_list [list]
	if {[string compare -nocase [get_parameter_value use_external_crcblock_core] "true"] == 0} {
		lappend ifdef_params_list "CORE_INTERFACE"
	}
	
	generate_verilog_fileset $name $ifdef_params_list
}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	set ifdef_params_list [list]
	if {[string compare -nocase [get_parameter_value use_external_crcblock_core] "true"] == 0} {
		lappend ifdef_params_list "CORE_INTERFACE"
	}
	
	# Generate all Verilog files
	generate_verilog_fileset $name $ifdef_params_list
	
	# Generate the SDC if needed
	if {[string compare -nocase [get_parameter_value use_external_crcblock_core] "false"] == 0} {
		set file_list "altera_adv_seu_detection.sdc"
		foreach sdc_file $file_list {
			set file_name [file tail $sdc_file]
			send_message info "Adding $file_name"
			add_fileset_file $file_name SDC PATH $sdc_file
		}
	}	
}


# +-----------------------------------
# | parameters
# | 

# | intended_device_family
add_parameter intended_device_family STRING
set_parameter_property intended_device_family VISIBLE false
set_parameter_property intended_device_family SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property intended_device_family HDL_PARAMETER true
set_parameter_property intended_device_family AFFECTS_GENERATION true

# | emr_data_width
add_parameter emr_data_width Integer
set_parameter_property emr_data_width VISIBLE false
set_parameter_property emr_data_width AFFECTS_GENERATION true
set_parameter_property emr_data_width DERIVED true

# | emr_reg_width
add_parameter emr_reg_width Integer
set_parameter_property emr_reg_width VISIBLE false
set_parameter_property emr_reg_width AFFECTS_GENERATION true
set_parameter_property emr_reg_width HDL_PARAMETER true
set_parameter_property emr_reg_width DERIVED true

# | clock_frequency
add_parameter clock_frequency Integer
set_parameter_property clock_frequency DEFAULT_VALUE 50
set_parameter_property clock_frequency DISPLAY_NAME "Input clock frequency"
set_parameter_property clock_frequency UNITS Megahertz
#set_parameter_property clock_frequency AFFECTS_GENERATION true
set_parameter_property clock_frequency HDL_PARAMETER true
set_parameter_property clock_frequency DESCRIPTION "Specifies the frequency of Altera Advanced SEU Detection core input clock."

# | cache_depth
add_parameter cache_depth Integer
set_parameter_property cache_depth DEFAULT_VALUE 8
set_parameter_property cache_depth ALLOWED_RANGES {1:16}
set_parameter_property cache_depth DISPLAY_NAME "CRC error cache depth"
#set_parameter_property cache_depth AFFECTS_GENERATION true
set_parameter_property cache_depth HDL_PARAMETER true
set_parameter_property cache_depth DESCRIPTION "Specifies how many non-critical CRC error can be ignored."

# | regions_mask_width
add_parameter regions_mask_width Integer 1
set_parameter_property regions_mask_width DISPLAY_NAME "Largest ASD region ID used"
set_parameter_property regions_mask_width ALLOWED_RANGES {0:255}
set_parameter_property regions_mask_width AFFECTS_GENERATION true
set_parameter_property regions_mask_width DESCRIPTION "Specifies the largest ASD region ID used in design. Used to specify width of the SEU affected regions mask."

# | use_external_crcblock_core
add_parameter use_external_crcblock_core boolean false
set_parameter_property use_external_crcblock_core DISPLAY_NAME "Use crcblock core interface"
set_parameter_property use_external_crcblock_core AFFECTS_GENERATION true
set_parameter_property use_external_crcblock_core DESCRIPTION "Specifies that Altera Advanced SEU Detection core should use separately instantiated crcblock_atom."

# | error_clock_divisor
add_parameter error_clock_divisor Integer
set_parameter_property error_clock_divisor DEFAULT_VALUE 2
set_parameter_property error_clock_divisor ALLOWED_RANGES {2 4 8 16 32 64 128 256}
set_parameter_property error_clock_divisor DISPLAY_NAME "CRC error check clock divisor"
set_parameter_property error_clock_divisor UNITS None
#set_parameter_property error_clock_divisor AFFECTS_GENERATION true
set_parameter_property error_clock_divisor HDL_PARAMETER true
set_parameter_property error_clock_divisor DESCRIPTION "Specifies the divide value of the internal clock, which determines the frequency of the CRC. Should match the Quartus II CRC settings."

# | error_delay_cycles
add_parameter error_delay_cycles Integer
set_parameter_property error_delay_cycles DEFAULT_VALUE 0
set_parameter_property error_delay_cycles ALLOWED_RANGES {0:7}
set_parameter_property error_delay_cycles DISPLAY_NAME "CRC error reporting delay"
set_parameter_property error_delay_cycles UNITS Cycles
#set_parameter_property error_delay_cycles AFFECTS_GENERATION true
set_parameter_property error_delay_cycles HDL_PARAMETER true
set_parameter_property error_delay_cycles DESCRIPTION "Specifies how many CRC error computation cycle-time units to delay when a CRC error is detected. INI is required to apply non-zero delay"

# | enable_virtual_jtag
add_parameter enable_virtual_jtag Integer 1
#set_parameter_property enable_virtual_jtag ALLOWED_RANGES 0:1
set_parameter_property enable_virtual_jtag DISPLAY_HINT BOOLEAN
set_parameter_property enable_virtual_jtag DISPLAY_NAME "Enable Virtual JTAG CRC error injection"
set_parameter_property enable_virtual_jtag HDL_PARAMETER true
set_parameter_property enable_virtual_jtag DESCRIPTION "Enables Virtual JTAG CRC error injection."

add_display_item "" "Sensitivity Data Access" GROUP 
add_display_item "Sensitivity Data Access" use_memory_interface PARAMETER
add_display_item "Sensitivity Data Access" mem_addr_width PARAMETER
add_display_item "Sensitivity Data Access" start_address PARAMETER

# | use_memory_interface
add_parameter use_memory_interface boolean true
set_parameter_property use_memory_interface DISPLAY_NAME "Use on-chip sensitivity processing"
set_parameter_property use_memory_interface AFFECTS_GENERATION true
set_parameter_property use_memory_interface AFFECTS_ELABORATION true
set_parameter_property use_memory_interface DESCRIPTION "Enables using external memory interface to access Sensitivity Data and perform SEU location lookup by the FPGA."

# | mem_addr_width
add_parameter mem_addr_width Integer
set_parameter_property mem_addr_width DEFAULT_VALUE 32
set_parameter_property mem_addr_width AFFECTS_GENERATION true
set_parameter_property mem_addr_width DISPLAY_NAME "Memory interface address width"
set_parameter_property mem_addr_width UNITS Bits
set_parameter_property mem_addr_width AFFECTS_GENERATION true
set_parameter_property mem_addr_width HDL_PARAMETER true
set_parameter_property mem_addr_width DESCRIPTION "Specifies width of the address bus connected to the external memory interface."

# | start_address
add_parameter start_address Integer
set_parameter_property start_address DEFAULT_VALUE 0
set_parameter_property start_address AFFECTS_GENERATION true
set_parameter_property start_address DISPLAY_NAME "Sensitivity Data start address"
set_parameter_property start_address AFFECTS_GENERATION true
set_parameter_property start_address HDL_PARAMETER true
set_parameter_property start_address DISPLAY_HINT hexadecimal
set_parameter_property start_address DESCRIPTION "Specifies a constant offset to be added to all addresses generated by the external memory interface."
# | 
# +-----------------------------------

# +-----------------------------------
# | Is CRC is 32 bits?
# | 
proc is_32bits_crc {} {
    set family [get_parameter_value intended_device_family]
    
    if { [expr {$family == "Stratix III"}] ||
	 [expr {$family == "Stratix IV"}] ||
	 [expr {$family == "Arria II GZ"}] ||
	 [expr {$family == "Arria II GX"}]
    } {
	 return false
    }	
    
    return true
}

# +-----------------------------------
# | Is Hierarchy Tagging is supported?
# | 
proc is_ht_supported {} {
    set family [get_parameter_value intended_device_family]
    
    if { [expr {$family == "Stratix V"}] ||
	 [expr {$family == "Arria V GZ"}] ||
	 [expr {$family == "Arria V"}] ||
	 [expr {$family == "Cyclone V"}]
    } {
	 return true
    }	
    
    return false
}

# +-----------------------------------
# | Parameters validation
# | 
proc crc_parameter_validation {} {
	set alt_adv_seu_detection_16bit_crc_data_width 30
	set alt_adv_seu_detection_16bit_crc_reg_width 46

	set alt_adv_seu_detection_32bit_crc_data_width 35
	set alt_adv_seu_detection_32bit_crc_reg_width 67

	if { [is_32bits_crc] } {
		set_parameter_value emr_data_width $alt_adv_seu_detection_32bit_crc_data_width
		set_parameter_value emr_reg_width $alt_adv_seu_detection_32bit_crc_reg_width
		set_parameter_property error_delay_cycles ALLOWED_RANGES {0:63}
	} else {
		set_parameter_value emr_data_width $alt_adv_seu_detection_16bit_crc_data_width
		set_parameter_value emr_reg_width $alt_adv_seu_detection_16bit_crc_reg_width
		set_parameter_property error_delay_cycles ALLOWED_RANGES {0:7}
	}	
}

proc external_crcerror_parameter_validation {} {
	if { [get_parameter_value use_external_crcblock_core] } {
		set family [get_parameter_value intended_device_family]

	        if { [expr {$family == "Stratix III"}] } {
			set_parameter_value use_external_crcblock_core false
		}	
	}	
}

# +-----------------------------------
# | Elaboration/validation callbacks
# | 
set_module_property ELABORATION_CALLBACK core_elaborate

proc core_elaborate {} {
	_dprint 1 "Running IP Elaboration"
	
	crc_parameter_validation
	#external_crcerror_parameter_validation

	set use_ext_memory [get_parameter_value use_memory_interface]
	set_parameter_property mem_addr_width VISIBLE $use_ext_memory
	set_parameter_property start_address VISIBLE $use_ext_memory

	set use_ext_crcblock [get_parameter_value use_external_crcblock_core]
	set_parameter_property error_clock_divisor VISIBLE {!$use_ext_crcblock}
	set_parameter_property error_delay_cycles VISIBLE {!$use_ext_crcblock}

	if { $use_ext_memory } {
		set_parameter_property regions_mask_width HDL_PARAMETER [is_ht_supported]

		set alt_adv_seu_detection_mem_data_width 32
		
		set top_level_module_name "altera_adv_seu_detection_proc_int"
		set_fileset_property sim_verilog TOP_LEVEL $top_level_module_name
		set_fileset_property quartus_synth TOP_LEVEL $top_level_module_name
		
		# +-----------------------------------
		# | internal processing interfaces
		# | 

		# | ext_memory
		add_interface ext_memory conduit end in_clk
		add_interface_port ext_memory mem_addr mem_addr output [get_parameter_value mem_addr_width]
		add_interface_port ext_memory mem_rd mem_rd output 1
		add_interface_port ext_memory mem_bytesel mem_bytesel output 4
		add_interface_port ext_memory mem_wait mem_wait input 1
		add_interface_port ext_memory mem_data mem_data input $alt_adv_seu_detection_mem_data_width
		add_interface_port ext_memory mem_critical mem_critical input 1
		set_interface_assignment ext_memory "ui.blockdiagram.direction" OUTPUT

		# | crcerror_status
		add_interface crcerror_status conduit end
		add_interface_port crcerror_status crcerror_core crcerror_core output 1
		add_interface_port crcerror_status noncritical_error noncritical_error output 1
		add_interface_port crcerror_status critical_error critical_error output 1
		
		if { [is_ht_supported] } {
			add_interface_port crcerror_status critical_regions critical_regions output [get_parameter_value regions_mask_width]
		}	
		
		set_interface_assignment crcerror_status "ui.blockdiagram.direction" OUTPUT
		} else {
		set_parameter_property regions_mask_width HDL_PARAMETER false

		set top_level_module_name "altera_adv_seu_detection_proc_ext"
		set_fileset_property sim_verilog TOP_LEVEL $top_level_module_name
		set_fileset_property quartus_synth TOP_LEVEL $top_level_module_name

		# +-----------------------------------
		# | external processing interfaces
		# | 

		# | emr_cache
		add_interface emr_cache conduit end in_clk
		add_interface_port emr_cache emr_data emr_data output [get_parameter_value emr_data_width]
		add_interface_port emr_cache emr_cache_int emr_cache_int output 1
		add_interface_port emr_cache emr_cache_ack emr_cache_ack input 1
		add_interface_port emr_cache cache_fill_level cache_fill_level output 4
		add_interface_port emr_cache cache_full cache_full output 1
		set_interface_assignment emr_cache "ui.blockdiagram.direction" OUTPUT

		# | crcerror_status
		add_interface crcerror_status conduit end
		add_interface_port crcerror_status crcerror_core crcerror_core output 1
		add_interface_port crcerror_status critical_error critical_error output 1
		set_interface_assignment crcerror_status "ui.blockdiagram.direction" OUTPUT
		
		# | disable the STA warning 332060 for non-clock nodes
		set_qip_strings { "set_instance_assignment -name MESSAGE_DISABLE 332060 -entity cache" }
	}

	if { $use_ext_crcblock } {
		# +-----------------------------------
		# | crcerror_core_cp
		# | 
		add_interface crcerror_core_cp conduit end
		add_interface_port crcerror_core_cp clk_cp clk output 1
		add_interface_port crcerror_core_cp shiftnld_cp shiftnld output 1
		add_interface_port crcerror_core_cp crcerror_cp crcerror input 1
		add_interface_port crcerror_core_cp regout_cp regout input 1
	} else {
		# +-----------------------------------
		# | crcerror_pin
		# | 
		add_interface crcerror_pin conduit end
		add_interface_port crcerror_pin crcerror_pin crcerror_pin output 1
		set_interface_assignment crcerror_pin "ui.blockdiagram.direction" OUTPUT
	}
}

# +-----------------------------------
# | common interfaces
# | 
# | in_clk
add_interface in_clk clock sink
add_interface_port in_clk clk clk input 1

# | nreset
add_interface nreset reset sink in_clk
add_interface_port nreset nreset reset_n input 1

# | cache_comparison_off
add_interface cache_comparison_off conduit end in_clk
add_interface_port cache_comparison_off cache_comparison_off cache_comparison_off input 1









