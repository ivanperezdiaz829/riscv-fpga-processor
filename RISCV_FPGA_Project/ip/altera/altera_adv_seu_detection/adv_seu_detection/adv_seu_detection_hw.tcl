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

package require alt_mem_if::util::hwtcl_utils

set_module_property NAME altera_adv_seu_detection
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property HIDE_FROM_QSYS true
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Adv SEU Detection"
set_module_property DESCRIPTION "Altera Advanced SEU Detection"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_alt_adv_seu_detection.pdf"



set_module_property COMPOSITION_CALLBACK composition_callback


add_parameter intended_device_family STRING
set_parameter_property intended_device_family ALLOWED_RANGES {"Stratix III" "Stratix IV" "Arria II GZ" "Arria II GX" "Stratix V" "Arria V" "Arria V GZ" "Cyclone V"}
set_parameter_property intended_device_family VISIBLE false
set_parameter_property intended_device_family SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property intended_device_family HDL_PARAMETER true
set_parameter_property intended_device_family AFFECTS_GENERATION true

add_parameter skip_crcerror_verify boolean false
set_parameter_property skip_crcerror_verify VISIBLE false
set_parameter_property skip_crcerror_verify HDL_PARAMETER false
set_parameter_property skip_crcerror_verify DESCRIPTION "Hidden option to skip mandatory altera_crc_error_verify instantiation for Stratix IV and Arria II only"

add_parameter clock_frequency Integer
set_parameter_property clock_frequency DEFAULT_VALUE 50
set_parameter_property clock_frequency DISPLAY_NAME "Input clock frequency"
set_parameter_property clock_frequency UNITS Megahertz
set_parameter_property clock_frequency DESCRIPTION "Specifies the frequency of Altera Advanced SEU Detection core input clock."

add_parameter cache_depth Integer
set_parameter_property cache_depth DEFAULT_VALUE 8
set_parameter_property cache_depth ALLOWED_RANGES {1:16}
set_parameter_property cache_depth DISPLAY_NAME "CRC error cache depth"
set_parameter_property cache_depth AFFECTS_GENERATION true
set_parameter_property cache_depth DESCRIPTION "Specifies how many non-critical CRC error can be ignored."

add_parameter regions_mask_width Integer 1
set_parameter_property regions_mask_width DISPLAY_NAME "Largest ASD region ID used"
set_parameter_property regions_mask_width DESCRIPTION "Indicates the largest ASD region ID used in design. Used to specify width of critical_region port reporting IDs of regions affected by SEU."

add_parameter enable_virtual_jtag Integer 1
set_parameter_property enable_virtual_jtag DISPLAY_HINT BOOLEAN
set_parameter_property enable_virtual_jtag DISPLAY_NAME "Enable Virtual JTAG CRC error injection"
set_parameter_property enable_virtual_jtag DESCRIPTION "Enables Virtual JTAG CRC error injection."

add_display_item "" "Error Detection CRC Block Usage Options" GROUP 
add_display_item "Error Detection CRC Block Usage Options" external_crcblock_core PARAMETER
add_display_item "Error Detection CRC Block Usage Options" error_clock_divisor PARAMETER
add_display_item "Error Detection CRC Block Usage Options" error_delay_cycles PARAMETER

add_parameter external_crcblock_core boolean false
set_parameter_property external_crcblock_core DISPLAY_NAME "Use shared crcblock core"
set_parameter_property external_crcblock_core AFFECTS_GENERATION true
set_parameter_property external_crcblock_core HDL_PARAMETER false
set_parameter_property external_crcblock_core DESCRIPTION "Specifies that Altera Advanced SEU Detection core should use separately instantiated crcblock_atom."

add_parameter error_clock_divisor Integer
set_parameter_property error_clock_divisor DEFAULT_VALUE 2
set_parameter_property error_clock_divisor ALLOWED_RANGES {2 4 8 16 32 64 128 256}
set_parameter_property error_clock_divisor DISPLAY_NAME "CRC error check clock divisor"
set_parameter_property error_clock_divisor UNITS None
set_parameter_property error_clock_divisor DESCRIPTION "Specifies the divide value of the internal clock, which determines the frequency of the CRC. Should match the Quartus II CRC settings."

add_parameter error_delay_cycles Integer
set_parameter_property error_delay_cycles DEFAULT_VALUE 0
set_parameter_property error_delay_cycles DISPLAY_NAME "CRC error reporting delay"
set_parameter_property error_delay_cycles UNITS Cycles
set_parameter_property error_delay_cycles DESCRIPTION "Specifies how many CRC error computation cycle-time units to delay when a CRC error is detected. The INI is required to apply non-zero delay."

add_display_item "" "Error Detection CRC Verification Options" GROUP 
add_display_item "Error Detection CRC Verification Options" crcerror_clk_frequency PARAMETER

add_parameter crcerror_clk_frequency Integer
set_parameter_property crcerror_clk_frequency DEFAULT_VALUE 50
set_parameter_property crcerror_clk_frequency DISPLAY_NAME "CRC error verify Input clock frequency"
set_parameter_property crcerror_clk_frequency UNITS Megahertz
set_parameter_property crcerror_clk_frequency AFFECTS_GENERATION true
set_parameter_property crcerror_clk_frequency DESCRIPTION "Specifies the frequency of ALTERA_CRCERROR_VERIFY block input clock, must be withing 10-50 MHz range."


add_display_item "" "Sensitivity Data Access" GROUP 
add_display_item "Sensitivity Data Access" use_memory_interface PARAMETER
add_display_item "Sensitivity Data Access" mem_addr_width PARAMETER
add_display_item "Sensitivity Data Access" start_address PARAMETER

add_parameter use_memory_interface boolean true
set_parameter_property use_memory_interface DISPLAY_NAME "Use on-chip sensitivity processing"
set_parameter_property use_memory_interface AFFECTS_GENERATION true
set_parameter_property use_memory_interface AFFECTS_ELABORATION true
set_parameter_property use_memory_interface DESCRIPTION "Enables using external memory interface to access Sensitivity Data and perform SEU location lookup by the FPGA."

add_parameter mem_addr_width Integer
set_parameter_property mem_addr_width DEFAULT_VALUE 32
set_parameter_property mem_addr_width AFFECTS_GENERATION true
set_parameter_property mem_addr_width DISPLAY_NAME "Memory interface address width"
set_parameter_property mem_addr_width UNITS Bits
set_parameter_property mem_addr_width AFFECTS_GENERATION true
set_parameter_property mem_addr_width DESCRIPTION "Specifies width of the address bus connected to the external memory interface."

add_parameter start_address Integer
set_parameter_property start_address DEFAULT_VALUE 0
set_parameter_property start_address AFFECTS_GENERATION true
set_parameter_property start_address DISPLAY_NAME "Sensitivity Data start address"
set_parameter_property start_address AFFECTS_GENERATION true
set_parameter_property start_address DISPLAY_HINT hexadecimal
set_parameter_property start_address DESCRIPTION "Specifies a constant offset to be added to all addresses generated by the external memory interface."


proc is_ht_supported {} {
    set family [get_parameter_value intended_device_family]
    
    if { [expr {$family == "Stratix V"}] ||
         [expr {$family == "Cyclone V"}] ||
	 [expr {$family == "Arria V"}] ||
	 [expr {$family == "Arria V GZ"}]
	   } {
		return true
	}	
    
	return false
}

proc use_crcerror_verify_core {} {
	if { [get_parameter_value skip_crcerror_verify] } {
		return 0
	}    

	set family [get_parameter_value intended_device_family]
    	if { [expr {$family == "Stratix IV"}] ||
         [expr {$family == "Arria II GZ"}] || 
         [expr {$family == "Arria II GX"}]
       	} {
		return true
	} 

	return false
}

proc use_external_crcblock_core {use_crcerror_verify} {
	if { [get_parameter_value external_crcblock_core] } {
		set family [get_parameter_value intended_device_family]
        
		if { $use_crcerror_verify || [expr {$family == "Stratix III"}] } {
			return false
		} else {
			return true
		}
	}

	return false;	
}


proc composition_callback {} {

	set use_ext_memory [get_parameter_value use_memory_interface]
	set_parameter_property mem_addr_width VISIBLE $use_ext_memory
	set_parameter_property start_address VISIBLE $use_ext_memory
	
	if { $use_ext_memory } {
		set_parameter_property regions_mask_width VISIBLE [is_ht_supported]
	} else {
		set_parameter_property regions_mask_width VISIBLE false
	}

	set use_crcblock_wrapper [use_crcerror_verify_core]
	if { $use_crcblock_wrapper } {
		set_display_item_property "Error Detection CRC Verification Options" VISIBLE true
		set_parameter_property crcerror_clk_frequency VISIBLE true
		set_parameter_property external_crcblock_core VISIBLE false
	} else {
		set_display_item_property "Error Detection CRC Verification Options" VISIBLE false
		set_parameter_property crcerror_clk_frequency VISIBLE false
		set_parameter_property external_crcblock_core VISIBLE true
	}

	set use_external_crcblock [use_external_crcblock_core $use_crcblock_wrapper]
	if { $use_external_crcblock } {
		set_parameter_property error_clock_divisor VISIBLE false
		set_parameter_property error_delay_cycles VISIBLE false
	} else {
		set_parameter_property error_clock_divisor VISIBLE true
		set_parameter_property error_delay_cycles VISIBLE true
	}
	
	add_instance asd_core_component altera_adv_seu_detection_core
	set_instance_parameter asd_core_component use_external_crcblock_core [expr {$use_crcblock_wrapper || $use_external_crcblock}]
	set_instance_parameter asd_core_component error_clock_divisor [get_parameter_value error_clock_divisor]
	set_instance_parameter asd_core_component error_delay_cycles [get_parameter_value error_delay_cycles]
	set_instance_parameter asd_core_component clock_frequency [get_parameter_value clock_frequency]
	set_instance_parameter asd_core_component cache_depth [get_parameter_value cache_depth]
	set_instance_parameter asd_core_component regions_mask_width [get_parameter_value regions_mask_width]
	set_instance_parameter asd_core_component enable_virtual_jtag [get_parameter_value enable_virtual_jtag]

	set_instance_parameter asd_core_component use_memory_interface $use_ext_memory
	set_instance_parameter asd_core_component mem_addr_width [get_parameter_value mem_addr_width]
	set_instance_parameter asd_core_component start_address [get_parameter_value start_address]
	

	add_interface in_clk clock sink
	set_interface_property in_clk export_of asd_core_component.in_clk
	set_interface_property in_clk PORT_NAME_MAP {clk clk}
    
	add_interface           nreset reset sink
	set_interface_property  nreset export_of asd_core_component.nreset
	set_interface_property  nreset PORT_NAME_MAP {nreset nreset}
    
	add_interface cache_comparison_off conduit end
	set_interface_property cache_comparison_off export_of asd_core_component.cache_comparison_off
	set_interface_property cache_comparison_off PORT_NAME_MAP {cache_comparison_off cache_comparison_off}

	add_interface crcerror_status conduit end
	set_interface_property crcerror_status export_of asd_core_component.crcerror_status
	alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports asd_core_component crcerror_status crcerror_status

	if { $use_ext_memory } {
		add_interface ext_memory conduit end
		set_interface_property ext_memory export_of asd_core_component.ext_memory
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports asd_core_component ext_memory ext_memory
	} else {
		add_interface emr_cache conduit end
		set_interface_property emr_cache export_of asd_core_component.emr_cache
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports asd_core_component emr_cache emr_cache
	}
	
	if { $use_crcblock_wrapper } {

		add_instance block_wrapper altera_crcerror_verify

		set_instance_parameter block_wrapper in_clk_frequency [get_parameter_value crcerror_clk_frequency]
		set_instance_parameter block_wrapper error_check_frequency_divisor [get_parameter_value error_clock_divisor]
		set_instance_parameter block_wrapper add_core_interface true
		set_instance_parameter block_wrapper change_pin_assignment false

		add_interface crcerror_clk clock sink
		set_interface_property  crcerror_clk export_of block_wrapper.err_verify_in_clk
		set_interface_property  crcerror_clk PORT_NAME_MAP {crcerror_clk err_verify_in_clk}
	    
		add_interface           crcerror_reset reset sink
		set_interface_property  crcerror_reset export_of block_wrapper.reset
		set_interface_property  crcerror_reset PORT_NAME_MAP {crcerror_reset reset}
	    
		add_connection asd_core_component.crcerror_core_cp block_wrapper.crcerror_core conduit crcerror_core_connection_point

		add_interface crcerror_pin conduit end 
		set_interface_property crcerror_pin export_of block_wrapper.crc_error
		set_interface_property crcerror_pin PORT_NAME_MAP {crcerror_pin crc_error}
	} else {
		if { $use_external_crcblock } {
			add_interface crcerror_core conduit end 
			set_interface_property crcerror_core export_of asd_core_component.crcerror_core_cp
			set_interface_property crcerror_core PORT_NAME_MAP {crcerror_core crcerror_core_cp}
		} else {
			add_interface crcerror_pin conduit end 
			set_interface_property crcerror_pin export_of asd_core_component.crcerror_pin
			set_interface_property crcerror_pin PORT_NAME_MAP {crcerror_pin crcerror_pin}
		}

	}

}















