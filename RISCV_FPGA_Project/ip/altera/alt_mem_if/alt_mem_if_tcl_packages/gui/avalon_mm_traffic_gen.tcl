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


package provide alt_mem_if::gui::avalon_mm_traffic_gen 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::avalon_mm_traffic_gen:: {

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::create_parameters {} {
	
	_dprint 1 "Preparing tocreate parameters for avalon_mm_traffic_gen"
	
	
	_create_derived_parameters
	
	_create_general_parameters
		
	_create_traffic_parameters

	return 1
}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::create_gui {} {

	_create_general_gui
	
	_create_traffic_parameters_gui

	return 1
}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::validate_component {} {

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

proc ::alt_mem_if::gui::avalon_mm_traffic_gen::elaborate_component {} {

	set data_width_mod_symbol_width [expr {[get_parameter_value TG_AVL_DATA_WIDTH] % [get_parameter_value TG_AVL_SYMBOL_WIDTH]}]
	if { $data_width_mod_symbol_width == 0 && [get_parameter_value TG_AVL_DATA_WIDTH] > [get_parameter_value TG_AVL_SYMBOL_WIDTH]} {
		set_parameter_property TG_BYTE_ENABLE ENABLED TRUE
	} else {
		set_parameter_property TG_BYTE_ENABLE ENABLED FALSE
	}

	return 1
}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_init {} {
	

}

proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_create_derived_parameters {} {
		
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
	set_parameter_property TG_AVL_NUM_SYMBOLS VISIBLE false
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

proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_create_general_parameters {} {
		
	_dprint 1 "Preparing to create general parameters in avalon_mm_traffic_gen"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_DATA_WIDTH_IN integer 32
	set_parameter_property TG_AVL_DATA_WIDTH_IN DISPLAY_NAME "Avalon Data Width"
	set_parameter_property TG_AVL_DATA_WIDTH_IN DESCRIPTION "Avalon data-bus width"
	set_parameter_property TG_AVL_DATA_WIDTH_IN ALLOWED_RANGES {1:2048}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_POWER_OF_TWO_BUS boolean false
	set_parameter_property TG_POWER_OF_TWO_BUS DISPLAY_NAME "Generate power-of-2 data bus widths for Qsys or SOPC Builder"
	set_parameter_property TG_POWER_OF_TWO_BUS DESCRIPTION "This option must be enabled if this core is to be used in a Qsys or SOPC Builder system.  When turned on, the Avalon-MM side data bus width is rounded down to the nearest power of 2."

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_SOPC_COMPAT_RESET boolean false
	set_parameter_property TG_SOPC_COMPAT_RESET DISPLAY_NAME "Generate SOPC Builder compatible resets"
	set_parameter_property TG_SOPC_COMPAT_RESET DESCRIPTION "This option must be enabled if this core is to be used in an SOPC Builder system.  When turned on, the reset inputs become associated with the PLL reference clock and the paths must be cut."

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_AVL_ADDR_WIDTH_IN integer 25
	set_parameter_property TG_AVL_ADDR_WIDTH_IN DISPLAY_NAME "Avalon Address Width"
	set_parameter_property TG_AVL_ADDR_WIDTH_IN DESCRIPTION "Avalon address-bus width."
	set_parameter_property TG_AVL_ADDR_WIDTH_IN ALLOWED_RANGES {1:32}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_GEN_BYTE_ADDR boolean true
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

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_TWO_AVL_INTERFACES boolean false
	set_parameter_property TG_TWO_AVL_INTERFACES DISPLAY_NAME "Generate 2 Avalon interfaces"
	set_parameter_property TG_TWO_AVL_INTERFACES DESCRIPTION "For QDRII interfaces, separate Avalon interfaces are used for read and write operations."

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BYTE_ENABLE boolean false
	set_parameter_property TG_BYTE_ENABLE DISPLAY_NAME "Generate Avalon-MM byte-enable signal"
	set_parameter_property TG_BYTE_ENABLE DESCRIPTION "When turned on, the driver will generate the byte-enable signal for the Avalon-MM bus"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
	set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_CTRL_AVALON_INTERFACE boolean true
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE DISPLAY_NAME "Enable Avalon interface"
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE false
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BURST_BEGIN boolean false
	set_parameter_property TG_BURST_BEGIN DISPLAY_NAME "Generate Avalon-MM begin burst transfer signal"
	set_parameter_property TG_BURST_BEGIN DESCRIPTION "When turned on, the driver will generate the begin burst transfer signal for the Avalon-MM bus"
	set_parameter_property TG_BURST_BEGIN VISIBLE true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_ENABLE_UNIX_ID boolean false
	set_parameter_property TG_ENABLE_UNIX_ID DISPLAY_NAME "Enable Unix ID"
	set_parameter_property TG_ENABLE_UNIX_ID DESCRIPTION "This option must be enabled if this core is being instantiated twice and connected to same slave. When turned on, the driver will generate an address with the specified unix id so address overlapping between master can be avoided."
	set_parameter_property TG_ENABLE_UNIX_ID HDL_PARAMETER true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USE_UNIX_ID integer 0
	set_parameter_property TG_USE_UNIX_ID DISPLAY_NAME "Unix ID"
	set_parameter_property TG_USE_UNIX_ID DESCRIPTION "Specifies the unix id for this instance. The id will be use at the MSB bit of the generated address."
	set_parameter_property TG_USE_UNIX_ID ALLOWED_RANGES {0 1 2 3 4 5 6 7}
	set_parameter_property TG_USE_UNIX_ID HDL_PARAMETER true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USE_LITE_DRIVER boolean false
	set_parameter_property TG_USE_LITE_DRIVER DISPLAY_NAME "Enables the use of the internal lite driver"
	set_parameter_property TG_USE_LITE_DRIVER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_ENABLE_DRIVER_CSR_MASTER boolean false
	set_parameter_property TG_ENABLE_DRIVER_CSR_MASTER DISPLAY_NAME "Enables the driver CSR port"
	set_parameter_property TG_ENABLE_DRIVER_CSR_MASTER VISIBLE false

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USE_SYNC_READY boolean false
                set_parameter_property TG_USE_SYNC_READY DISPLAY_NAME "Enable synchronize ready"
                set_parameter_property TG_USE_SYNC_READY DESCRIPTION "Instead of using individual ready signal, use the synchronize ready from each particpate port to issue simultaneous request."
                set_parameter_property TG_USE_SYNC_READY HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_ADDR_ENABLED boolean false
                set_parameter_property TG_USER_ADDR_ENABLED DISPLAY_NAME "Enable user input address"
                set_parameter_property TG_USER_ADDR_ENABLED DESCRIPTION "Instead of using lfsr, use user input address specified in User input address file."
                set_parameter_property TG_USER_ADDR_ENABLED HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_ADDR_BINARY boolean false
                set_parameter_property TG_USER_ADDR_BINARY DISPLAY_NAME "User input address is in binary"
                set_parameter_property TG_USER_ADDR_BINARY DESCRIPTION "Instead of using readmemh, use readmemb for loading user input address."
                set_parameter_property TG_USER_ADDR_BINARY HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_ADDR_DEPTH integer 300
	        set_parameter_property TG_USER_ADDR_DEPTH DISPLAY_NAME "The depth of user input address"
	        set_parameter_property TG_USER_ADDR_DEPTH DESCRIPTION "Specifies the total number of lines that content the user input address in file specify by User input address file."
	        set_parameter_property TG_USER_ADDR_DEPTH HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_ADDR_FILE string "user_input_addr.hex";
                set_parameter_property TG_USER_ADDR_FILE DISPLAY_NAME "User input address file"
                set_parameter_property TG_USER_ADDR_FILE DESCRIPTION "Specifies the file name that contain the user input address."
                set_parameter_property TG_USER_ADDR_FILE HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_DATA_ENABLED boolean false
                set_parameter_property TG_USER_DATA_ENABLED DISPLAY_NAME "Enable user input data"
                set_parameter_property TG_USER_DATA_ENABLED DESCRIPTION "Instead of using lfsr, use user input data specified in User input data file."
                set_parameter_property TG_USER_DATA_ENABLED HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_DATA_BINARY boolean false
                set_parameter_property TG_USER_DATA_BINARY DISPLAY_NAME "User input data is in binary"
                set_parameter_property TG_USER_DATA_BINARY DESCRIPTION "Instead of using readmemh, use readmemb for loading user input data."
                set_parameter_property TG_USER_DATA_BINARY HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_DATA_DEPTH integer 300
	        set_parameter_property TG_USER_DATA_DEPTH DISPLAY_NAME "The depth of user input data"
	        set_parameter_property TG_USER_DATA_DEPTH DESCRIPTION "Specifies the total number of lines that content the user input data in file specify by User input data file."
	        set_parameter_property TG_USER_DATA_DEPTH HDL_PARAMETER true
                
                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USER_DATA_FILE string "user_input_data.hex";
                set_parameter_property TG_USER_DATA_FILE DISPLAY_NAME "User input data file"
                set_parameter_property TG_USER_DATA_FILE DESCRIPTION "Specifies the file name that contain the user input data."
                set_parameter_property TG_USER_DATA_FILE HDL_PARAMETER true
                
	        ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_ENABLE_READ_ONLY_COMPARE boolean false
	        set_parameter_property TG_ENABLE_READ_ONLY_COMPARE HDL_PARAMETER true
	        set_parameter_property TG_ENABLE_READ_ONLY_COMPARE DISPLAY_NAME "Enable data comparison for Read-Only Port"
	        set_parameter_property TG_ENABLE_READ_ONLY_COMPARE DESCRIPTION "Enable comparison of read data and expected data. Disabling this disables any checking in the traffic generator."
                
	        ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_COORDINATOR_IS_ENABLED boolean false
	        set_parameter_property TG_COORDINATOR_IS_ENABLED HDL_PARAMETER true
	        set_parameter_property TG_COORDINATOR_IS_ENABLED DISPLAY_NAME "Coordinator is enabled"
	        set_parameter_property TG_COORDINATOR_IS_ENABLED DESCRIPTION "When coordinator is enabled, driver will used ready from coordinator instead of from avalon to issue transaction."

        }

	return 1
}



proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_create_traffic_parameters {} {
		
	_dprint 1 "Preparing to create general parameters in avalon_mm_traffic_gen"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_RANDOM_BYTE_ENABLE boolean false
	set_parameter_property TG_RANDOM_BYTE_ENABLE HDL_PARAMETER true
	set_parameter_property TG_RANDOM_BYTE_ENABLE DISPLAY_NAME "Enable Random byteenable"
	set_parameter_property TG_RANDOM_BYTE_ENABLE DESCRIPTION "Enable random byteenable patterns when generating traffic."

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_ENABLE_READ_COMPARE boolean true
	set_parameter_property TG_ENABLE_READ_COMPARE HDL_PARAMETER true
	set_parameter_property TG_ENABLE_READ_COMPARE DISPLAY_NAME "Enable data comparison"
	set_parameter_property TG_ENABLE_READ_COMPARE DESCRIPTION "Enable comparison of read data and expected data. Disabling this disables any checking in the traffic generator."

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_POWER_OF_TWO_BURSTS_ONLY boolean false
	set_parameter_property TG_POWER_OF_TWO_BURSTS_ONLY HDL_PARAMETER true
	set_parameter_property TG_POWER_OF_TWO_BURSTS_ONLY DISPLAY_NAME "Power-of-2 Bursts Only"
	set_parameter_property TG_POWER_OF_TWO_BURSTS_ONLY DESCRIPTION "Specifies that only power of 2 burst counts should be used when generating traffic."
	set_parameter_property TG_POWER_OF_TWO_BURSTS_ONLY VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BURST_ON_BURST_BOUNDARY boolean false
	set_parameter_property TG_BURST_ON_BURST_BOUNDARY HDL_PARAMETER true
	set_parameter_property TG_BURST_ON_BURST_BOUNDARY DISPLAY_NAME "Address only on burst boundry"
	set_parameter_property TG_BURST_ON_BURST_BOUNDARY DESCRIPTION "Specifies that only address on burst boundries should be generated."
	set_parameter_property TG_BURST_ON_BURST_BOUNDARY VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_DO_NOT_CROSS_4KB_BOUNDARY boolean false
	set_parameter_property TG_DO_NOT_CROSS_4KB_BOUNDARY HDL_PARAMETER true
	set_parameter_property TG_DO_NOT_CROSS_4KB_BOUNDARY DISPLAY_NAME "Ensure requests do not cross a 4K byte-address boundary"
	set_parameter_property TG_DO_NOT_CROSS_4KB_BOUNDARY DESCRIPTION "Ensures that read/write requests do not cross a 4K byte-address boundary.  Required when slave is an AXI slave."
	set_parameter_property TG_DO_NOT_CROSS_4KB_BOUNDARY VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_TIMEOUT_COUNTER_WIDTH integer 32
	set_parameter_property TG_TIMEOUT_COUNTER_WIDTH HDL_PARAMETER true
	set_parameter_property TG_TIMEOUT_COUNTER_WIDTH DISPLAY_NAME "Timeout counter width"
	set_parameter_property TG_TIMEOUT_COUNTER_WIDTH DESCRIPTION "Specifies the width of the timeout counter. When the counter expires the test is deemed to have failed."
	set_parameter_property TG_TIMEOUT_COUNTER_WIDTH ALLOWED_RANGES {1:64}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_MAX_READ_LATENCY integer 20
	set_parameter_property TG_MAX_READ_LATENCY HDL_PARAMETER true
	set_parameter_property TG_MAX_READ_LATENCY DISPLAY_NAME "Maximum slave read latency"
	set_parameter_property TG_MAX_READ_LATENCY DESCRIPTION "Specifies maximum read latency of the slave connected to the traffic generator. This is used to size internal FIFOs."
	set_parameter_property TG_MAX_READ_LATENCY ALLOWED_RANGES {1:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_SINGLE_RW_SEQ_ADDR_COUNT integer 32
	set_parameter_property TG_SINGLE_RW_SEQ_ADDR_COUNT HDL_PARAMETER true
	set_parameter_property TG_SINGLE_RW_SEQ_ADDR_COUNT DISPLAY_NAME "Single read/write sequential addressing count"
	set_parameter_property TG_SINGLE_RW_SEQ_ADDR_COUNT DESCRIPTION "Specifies the number of sequential address to generate when generating single read/write traffic."
	set_parameter_property TG_SINGLE_RW_SEQ_ADDR_COUNT ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_SINGLE_RW_RAND_ADDR_COUNT integer 32
	set_parameter_property TG_SINGLE_RW_RAND_ADDR_COUNT HDL_PARAMETER true
	set_parameter_property TG_SINGLE_RW_RAND_ADDR_COUNT DISPLAY_NAME "Single read/write random addressing count"
	set_parameter_property TG_SINGLE_RW_RAND_ADDR_COUNT DESCRIPTION "Specifies the number of random address to generate when generating single read/write traffic."
	set_parameter_property TG_SINGLE_RW_RAND_ADDR_COUNT ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT integer 32
	set_parameter_property TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT HDL_PARAMETER true
	set_parameter_property TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT DISPLAY_NAME "Single read/write interleaved sequential/random addressing count"
	set_parameter_property TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT DESCRIPTION "Specifies the number of interleaved sequential and random address to generate when generating single read/write traffic."
	set_parameter_property TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BLOCK_RW_SEQ_ADDR_COUNT integer 8
	set_parameter_property TG_BLOCK_RW_SEQ_ADDR_COUNT HDL_PARAMETER true
	set_parameter_property TG_BLOCK_RW_SEQ_ADDR_COUNT DISPLAY_NAME "Block read/write sequential addressing count"
	set_parameter_property TG_BLOCK_RW_SEQ_ADDR_COUNT DESCRIPTION "Specifies the number of sequential address to generate when generating block read/write traffic."
	set_parameter_property TG_BLOCK_RW_SEQ_ADDR_COUNT ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BLOCK_RW_RAND_ADDR_COUNT integer 8
	set_parameter_property TG_BLOCK_RW_RAND_ADDR_COUNT HDL_PARAMETER true
	set_parameter_property TG_BLOCK_RW_RAND_ADDR_COUNT DISPLAY_NAME "Block read/write random addressing count"
	set_parameter_property TG_BLOCK_RW_RAND_ADDR_COUNT DESCRIPTION "Specifies the number of random address to generate when generating block read/write traffic."
	set_parameter_property TG_BLOCK_RW_RAND_ADDR_COUNT ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT integer 8
	set_parameter_property TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT HDL_PARAMETER true
	set_parameter_property TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT DISPLAY_NAME "Block read/write interleaved sequential/random addressing count"
	set_parameter_property TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT DESCRIPTION "Specifies the number of interleaved sequential and random address to generate when generating block read/write traffic."
	set_parameter_property TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_BLOCK_RW_BLOCK_SIZE integer 8
	set_parameter_property TG_BLOCK_RW_BLOCK_SIZE HDL_PARAMETER true
	set_parameter_property TG_BLOCK_RW_BLOCK_SIZE DISPLAY_NAME "Block read/write size"
	set_parameter_property TG_BLOCK_RW_BLOCK_SIZE DESCRIPTION "Specifies the number of read/write operations to occur in when generating block read/write traffic."
	set_parameter_property TG_BLOCK_RW_BLOCK_SIZE ALLOWED_RANGES {0:1024}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_TEMPLATE_STAGE_COUNT integer 4
	set_parameter_property TG_TEMPLATE_STAGE_COUNT HDL_PARAMETER true
	set_parameter_property TG_TEMPLATE_STAGE_COUNT DISPLAY_NAME "Template stage count"
	set_parameter_property TG_TEMPLATE_STAGE_COUNT DESCRIPTION "Specifies the number of template stages to generate traffic for."

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT integer 1
	set_parameter_property TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT HDL_PARAMETER true
	set_parameter_property TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT integer 2
	set_parameter_property TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT HDL_PARAMETER true
	set_parameter_property TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT VISIBLE false
	set_parameter_property TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_RAND_ADDR_GEN_MIN_BURSTCOUNT integer 1
	set_parameter_property TG_RAND_ADDR_GEN_MIN_BURSTCOUNT HDL_PARAMETER true
	set_parameter_property TG_RAND_ADDR_GEN_MIN_BURSTCOUNT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_RAND_ADDR_GEN_MAX_BURSTCOUNT integer 2
	set_parameter_property TG_RAND_ADDR_GEN_MAX_BURSTCOUNT HDL_PARAMETER true
	set_parameter_property TG_RAND_ADDR_GEN_MAX_BURSTCOUNT VISIBLE false
	set_parameter_property TG_RAND_ADDR_GEN_MAX_BURSTCOUNT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT integer 1
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT HDL_PARAMETER true
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT integer 2
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT HDL_PARAMETER true
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT VISIBLE false
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT integer 50
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT HDL_PARAMETER true
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT DISPLAY_NAME "Random addressing percent"
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT DESCRIPTION "Specifies the percentage of random address to generate in the interleaved sequential/random address generation."
	set_parameter_property TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT ALLOWED_RANGES {0:100}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

		::alt_mem_if::util::hwtcl_utils::_add_parameter TG_CPORT_TYPE_PORT integer 3
		set_parameter_property TG_CPORT_TYPE_PORT HDL_PARAMETER true
		set_parameter_property TG_CPORT_TYPE_PORT DISPLAY_NAME "Slave Type"
		set_parameter_property TG_CPORT_TYPE_PORT DESCRIPTION "Specifies whether the Avalon-MM Slave port is a read only port, write only port or Bidirectional port"
        	set_parameter_property TG_CPORT_TYPE_PORT ALLOWED_RANGES {"1:Write-only" "2:Read-only" "3:Bidirectional"}

	}

}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_create_general_gui {} {
	
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
	add_display_item "Avalon-MM Settings" TG_TWO_AVL_INTERFACES PARAMETER
	add_display_item "Avalon-MM Settings" TG_BYTE_ENABLE PARAMETER
	add_display_item "Avalon-MM Settings" TG_PNF_ENABLE PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		add_display_item "" "Avalon-MM Interface" GROUP
		set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE true
		add_display_item "Avalon-MM Interface" ENABLE_CTRL_AVALON_INTERFACE PARAMETER
	}

	add_display_item "" "Traffic Settings" GROUP "tab"

	add_display_item "Traffic Settings" "Traffic Generation Settings" GROUP
	add_display_item "Traffic Generation Settings" TG_NUM_DRIVER_LOOP PARAMETER 
	add_display_item "Traffic Generation Settings" TG_TIMEOUT_COUNTER_WIDTH PARAMETER
	add_display_item "Traffic Generation Settings" TG_RANDOM_BYTE_ENABLE PARAMETER

	add_display_item "Traffic Generation Settings" TG_ENABLE_READ_COMPARE PARAMETER
	add_display_item "Traffic Generation Settings" TG_POWER_OF_TWO_BURSTS_ONLY PARAMETER
	add_display_item "Traffic Generation Settings" TG_BURST_ON_BURST_BOUNDARY PARAMETER
	add_display_item "Traffic Generation Settings" TG_DO_NOT_CROSS_4KB_BOUNDARY PARAMETER
	add_display_item "Traffic Generation Settings" TG_MAX_READ_LATENCY PARAMETER
        add_display_item "Traffic Generation Settings" TG_ENABLE_UNIX_ID PARAMETER
        add_display_item "Traffic Generation Settings" TG_USE_UNIX_ID PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

        	add_display_item "Traffic Generation Settings" TG_CPORT_TYPE_PORT PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USE_SYNC_READY PARAMETER
        	add_display_item "Traffic Generation Settings" TG_USER_ADDR_ENABLED PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_ADDR_BINARY PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_ADDR_DEPTH PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_ADDR_FILE PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_DATA_ENABLED PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_DATA_BINARY PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_DATA_DEPTH PARAMETER
	        add_display_item "Traffic Generation Settings" TG_USER_DATA_FILE PARAMETER

	}

	add_display_item "Traffic Settings" "Traffic Pattern Settings" GROUP
	add_display_item "Traffic Pattern Settings" TG_SINGLE_RW_SEQ_ADDR_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_SINGLE_RW_RAND_ADDR_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_BLOCK_RW_BLOCK_SIZE PARAMETER
	add_display_item "Traffic Pattern Settings" TG_BLOCK_RW_SEQ_ADDR_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_BLOCK_RW_RAND_ADDR_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_TEMPLATE_STAGE_COUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_RAND_ADDR_GEN_MIN_BURSTCOUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_RAND_ADDR_GEN_MAX_BURSTCOUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT PARAMETER
	add_display_item "Traffic Pattern Settings" TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT PARAMETER

}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_create_traffic_parameters_gui {} {

	_dprint 1 "Preparing to create the traffic parameters GUI in avalon_mm_traffic_gen"

}


proc ::alt_mem_if::gui::avalon_mm_traffic_gen::_derive_parameters {} {

	_dprint 1 "Preparing to derive parameters in avalon_mm_traffic_gen"

	if {[string compare -nocase [get_parameter_value TG_POWER_OF_TWO_BUS] "true"] == 0} {
		set_parameter_value TG_AVL_DATA_WIDTH [expr {int(pow(2,(int(floor(log([get_parameter_value TG_AVL_DATA_WIDTH_IN])/log(2))))))}]
	} else {
		set_parameter_value TG_AVL_DATA_WIDTH [get_parameter_value TG_AVL_DATA_WIDTH_IN]
	}

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

	set_parameter_value TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT [expr {1 << ([get_parameter_value TG_AVL_SIZE_WIDTH] - 1)}]
	set_parameter_value TG_RAND_ADDR_GEN_MAX_BURSTCOUNT [expr {1 << ([get_parameter_value TG_AVL_SIZE_WIDTH] - 1)}]
	set_parameter_value TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT [expr {1 << ([get_parameter_value TG_AVL_SIZE_WIDTH] - 1)}]

	if {[string compare -nocase [get_parameter_value TG_ENABLE_UNIX_ID] "true"] == 0} {
			set_parameter_property TG_USE_UNIX_ID ENABLED true
	} else {
			set_parameter_property TG_USE_UNIX_ID ENABLED false
	}
	
	set driver_version 13.1
	set driver_version_str [expr {$driver_version * 10}]
	set driver_version_int [expr {int($driver_version_str)}]
	if {$driver_version_int != $driver_version_str } {
		_error "Fatal Error: Could not format driver version ($driver_version => $driver_version_str : $driver_version_int"
	}
	set driver_signature [expr {0x55550000 | $driver_version_int}]
	set_parameter_value DRIVER_SIGNATURE $driver_signature

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

		if {[string compare -nocase [get_parameter_value TG_USER_ADDR_ENABLED] "true"] == 0} {
        	        set_parameter_property TG_USER_ADDR_BINARY ENABLED true
                	set_parameter_property TG_USER_ADDR_DEPTH ENABLED true
	                set_parameter_property TG_USER_ADDR_FILE ENABLED true
		} else {
                	set_parameter_property TG_USER_ADDR_BINARY ENABLED false
	                set_parameter_property TG_USER_ADDR_DEPTH ENABLED false
        	        set_parameter_property TG_USER_ADDR_FILE ENABLED false
		}

	}
}

::alt_mem_if::gui::avalon_mm_traffic_gen::_init
