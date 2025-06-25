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


#-------------------------------------------------------------------------------
# [1] PARTNER MODULE ATTRIBUTES
#-------------------------------------------------------------------------------
set_module_property NAME "altera_sdram_partner_module"
set_module_property DISPLAY_NAME "Altera SDRAM Memory Model"
set_module_property DESCRIPTION "SDRAM Simulation Memory Model"
set_module_property AUTHOR "Altera Corporation"
set_module_property DATASHEET_URL ""
set_module_property GROUP "Memories and Memory Controllers/External Memory Interfaces/Memory Models"

set_module_property VERSION "11.0"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true

set_module_property EDITABLE true
set_module_property GENERATION_CALLBACK                             generate
set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK   generate
set_module_property _PREVIEW_GENERATE_VHDL_SIMULATION_CALLBACK      generate
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL false

#-------------------------------------------------------------------------------
# [2] PARAMETERS
#-------------------------------------------------------------------------------
add_parameter SDRAM_DATA_WIDTH INTEGER 32 0
set_parameter_property SDRAM_DATA_WIDTH DISPLAY_NAME "Data width"
set_parameter_property SDRAM_DATA_WIDTH UNITS None
set_parameter_property SDRAM_DATA_WIDTH ALLOWED_RANGES "8 16 32 64"
set_parameter_property SDRAM_DATA_WIDTH DESCRIPTION "Bit width of data bus"
set_parameter_property SDRAM_DATA_WIDTH HDL_PARAMETER false
set_parameter_property SDRAM_DATA_WIDTH AFFECTS_ELABORATION true

add_parameter SDRAM_BANK_WIDTH INTEGER 1 0
set_parameter_property SDRAM_BANK_WIDTH DISPLAY_NAME "Bank width"
set_parameter_property SDRAM_BANK_WIDTH UNITS None
set_parameter_property SDRAM_BANK_WIDTH ALLOWED_RANGES "1 2"
set_parameter_property SDRAM_BANK_WIDTH DESCRIPTION "Bit width of memory bank signal"
set_parameter_property SDRAM_BANK_WIDTH HDL_PARAMETER false
set_parameter_property SDRAM_BANK_WIDTH AFFECTS_ELABORATION true

add_parameter SDRAM_NUM_CHIPSELECTS INTEGER 1 0
set_parameter_property SDRAM_NUM_CHIPSELECTS DISPLAY_NAME "Number of chipselects"
set_parameter_property SDRAM_NUM_CHIPSELECTS UNITS None
set_parameter_property SDRAM_NUM_CHIPSELECTS ALLOWED_RANGES "1 2 4 8"
set_parameter_property SDRAM_NUM_CHIPSELECTS DESCRIPTION "Number of chipselects signal"
set_parameter_property SDRAM_NUM_CHIPSELECTS HDL_PARAMETER false
set_parameter_property SDRAM_NUM_CHIPSELECTS AFFECTS_ELABORATION true

add_parameter CAS_LATENCY INTEGER 1 0
set_parameter_property CAS_LATENCY DISPLAY_NAME "CAS latency"
set_parameter_property CAS_LATENCY UNITS None
set_parameter_property CAS_LATENCY ALLOWED_RANGES 1:3
set_parameter_property CAS_LATENCY DESCRIPTION "CAS latency"
set_parameter_property CAS_LATENCY HDL_PARAMETER false
set_parameter_property CAS_LATENCY AFFECTS_ELABORATION true

add_parameter SDRAM_COL_WIDTH INTEGER 19 0
set_parameter_property SDRAM_COL_WIDTH DISPLAY_NAME "Column address width"
set_parameter_property SDRAM_COL_WIDTH UNITS None
set_parameter_property SDRAM_COL_WIDTH ALLOWED_RANGES 1:25
set_parameter_property SDRAM_COL_WIDTH DESCRIPTION "Column address width"
set_parameter_property SDRAM_COL_WIDTH HDL_PARAMETER false
set_parameter_property SDRAM_COL_WIDTH AFFECTS_ELABORATION true

add_parameter SDRAM_ROW_WIDTH INTEGER 19 0
set_parameter_property SDRAM_ROW_WIDTH DISPLAY_NAME "Row address width"
set_parameter_property SDRAM_ROW_WIDTH UNITS None
set_parameter_property SDRAM_ROW_WIDTH ALLOWED_RANGES 1:25
set_parameter_property SDRAM_ROW_WIDTH DESCRIPTION "Row address width"
set_parameter_property SDRAM_ROW_WIDTH HDL_PARAMETER false
set_parameter_property SDRAM_ROW_WIDTH AFFECTS_ELABORATION true

add_parameter CONTR_NAME STRING "" ""
set_parameter_property CONTR_NAME DISPLAY_NAME "Controller instance name"
set_parameter_property CONTR_NAME UNITS None
#set_parameter_property CONTR_NAME ALLOWED_RANGES 1:25
set_parameter_property CONTR_NAME DESCRIPTION "Connected controller instance module name"
set_parameter_property CONTR_NAME HDL_PARAMETER false
set_parameter_property CONTR_NAME AFFECTS_ELABORATION true

#-------------------------------------------------------------------------------
# [3] INTERFACES
#-------------------------------------------------------------------------------
add_interface clk clock end
add_interface_port clk clk clk Input 1
#add_interface_port clk reset reset Input 1

#-------------------------------------------------------------------------------
# [4] ELABORATION
#-------------------------------------------------------------------------------
proc elaborate {} {

	set sdram_data_width [ get_parameter_value SDRAM_DATA_WIDTH ]
	set sdram_bank_width [ get_parameter_value SDRAM_BANK_WIDTH ]
	set sdram_col_width [ get_parameter_value SDRAM_COL_WIDTH]
	set sdram_row_width [ get_parameter_value SDRAM_ROW_WIDTH]
	set sdram_num_chipselects [ get_parameter_value SDRAM_NUM_CHIPSELECTS ]
	set cas_latency [ get_parameter_value CAS_LATENCY ]

	if {$sdram_num_chipselects > 1} {
		set num_chipselect_address_bits [ expr int(ceil((log($sdram_num_chipselects)) / (log(2)))) ]
	} else {
		set num_chipselect_address_bits 1
	}
	
	set controller_addr_width [ expr $num_chipselect_address_bits + $sdram_col_width + $sdram_row_width + $sdram_bank_width]
	set dqm_width [ expr $sdram_data_width/8 ]

	add_interface conduit conduit end
	add_interface_port conduit zs_dq dq bidir $sdram_data_width
	add_interface_port conduit zs_addr addr input $sdram_row_width
	add_interface_port conduit zs_ba ba input $sdram_bank_width
	add_interface_port conduit zs_cas_n cas_n input 1
	add_interface_port conduit zs_cke cke input 1
	add_interface_port conduit zs_cs_n cs_n input $sdram_num_chipselects
	add_interface_port conduit zs_dqm dqm input $dqm_width
	add_interface_port conduit zs_ras_n ras_n input 1
	add_interface_port conduit zs_we_n we_n input 1

}

#-------------------------------------------------------------------------------
# [5] VALIDATION
#-------------------------------------------------------------------------------
proc validate {} {

	set sdram_data_width [ get_parameter_value SDRAM_DATA_WIDTH ]
	set sdram_bank_width [ get_parameter_value SDRAM_BANK_WIDTH ]
	set sdram_col_width [ get_parameter_value SDRAM_COL_WIDTH]
	set sdram_row_width [ get_parameter_value SDRAM_ROW_WIDTH]
	set sdram_num_chipselects [ get_parameter_value SDRAM_NUM_CHIPSELECTS ]
	set cas_latency [ get_parameter_value CAS_LATENCY ]

	if {$sdram_num_chipselects > 1} {
		set num_chipselect_address_bits [ expr int(ceil((log($sdram_num_chipselects)) / (log(2)))) ]
	} else {
		set num_chipselect_address_bits 1
	}

	set controller_addr_width [ expr $num_chipselect_address_bits + $sdram_col_width + $sdram_row_width + $sdram_bank_width]
	set dqm_width [ expr $sdram_data_width/8 ]

	if {$cas_latency > 3} {
		send_message error "CAS latency of $cas_latency not supported for this memory model"
	}


}

#-------------------------------------------------------------------------------
# [6] GENERATION
#-------------------------------------------------------------------------------
proc generate {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    #set quartus_dir   $::env(QUARTUS_ROOTDIR)
	set QUARTUS_ROOTDIR [ get_project_property QUARTUS_ROOTDIR ]
    set COMPONENT_DIR   [ get_module_property MODULE_DIRECTORY ]
	set MODULE_NAME     [ get_module_property NAME ]
#send_message Info "During generation, get module property name '$MODULE_NAME' !!!"
	set sdram_name [ get_parameter_value CONTR_NAME ]
#send_message Info "During generation, get module property ctrl_name '$sdram_name' !!!"

	set SOPC_BUILDER_BIN_DIR    "$QUARTUS_ROOTDIR/sopc_builder/bin"
	set EUROPA_DIR              "$SOPC_BUILDER_BIN_DIR/europa"
    set PERLLIB_DIR             "$SOPC_BUILDER_BIN_DIR/perl_lib"
	set SDRAM_PARTNER_MODULE_DIR "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_sdram_partner_module"
	
    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
#send_message Info "During generation, get gen property output name '$output_name' !!!"

	set language    [ string tolower [ get_generation_property HDL_LANGUAGE ] ]

	# parameters
	set sdram_data_width [ get_parameter_value SDRAM_DATA_WIDTH ]
	set sdram_bank_width [ get_parameter_value SDRAM_BANK_WIDTH ]
	set sdram_col_width [ get_parameter_value SDRAM_COL_WIDTH]
	set sdram_row_width [ get_parameter_value SDRAM_ROW_WIDTH]
	set sdram_num_chipselects [ get_parameter_value SDRAM_NUM_CHIPSELECTS ]
	set cas_latency [ get_parameter_value CAS_LATENCY ]

	# derived parameters
	if {$sdram_num_chipselects > 1} {
		set num_chipselect_address_bits [ expr int(ceil((log($sdram_num_chipselects)) / (log(2)))) ]
	} else {
		set num_chipselect_address_bits 1
	}
	set controller_addr_width [ expr $num_chipselect_address_bits + $sdram_col_width + $sdram_row_width + $sdram_bank_width ]
	set dqm_width [ expr $sdram_data_width/8 ]

	set perl_script "$COMPONENT_DIR/em_altera_sodimm.pl"

    set PLATFORM $::tcl_platform(platform)
    if { $PLATFORM == "java" } {
        set PLATFORM $::tcl_platform(host_platform)
    }

    # Case:136864 Use quartus(binpath) if its set
    if { [catch {set QUARTUS_BINDIR $::quartus(binpath)} errmsg] } {
        if { $PLATFORM == "windows" } {
            set BINDIRNAME "bin"
        } else {
            set BINDIRNAME "linux"
        }

        # Only the native tcl interpreter has 'tcl_platform(wordSize)'
        # In Jacl however 'tcl_platform(machine)' is set to the JVM bitness, not the OS bitness
        if { [catch {set WORDSIZE $::tcl_platform(wordSize)} errmsg] } {
            if {[string match "*64" $::tcl_platform(machine)]} {
                set WORDSIZE 8
            } else {
                set WORDSIZE 4
            }
        }
        if { $WORDSIZE == 8 } {
            set BINDIRNAME "${BINDIRNAME}64"
        }

        set QUARTUS_BINDIR "$QUARTUS_ROOTDIR/$BINDIRNAME"
    }

    set perl_bin "$QUARTUS_BINDIR/perl/bin/perl"
    if { $PLATFORM == "windows" } {
        set perl_bin "$perl_bin.exe"
    }
    if { ! [ file executable $perl_bin ] } {
        send_message error "Can't find path executable $perl_bin shipped with Quartus"
        return
    }

    # Unfortunately perl doesn't know about the path to the standard Perl include directories.
    set perl_std_libs $QUARTUS_BINDIR/perl/lib
    if { ! [ file isdirectory $perl_std_libs ] } {
        send_message error "Can't find Perl standard libraries $perl_std_libs shipped with Quartus"
        return
    }

	set exec_list [ list \
		exec $perl_bin \
			-I $perl_std_libs \
			-I $EUROPA_DIR \
			-I $PERLLIB_DIR \
			-I $SOPC_BUILDER_BIN_DIR \
			-I $COMPONENT_DIR \
			-I $SDRAM_PARTNER_MODULE_DIR \
			"--" \
			$perl_script \
			--output_dir=$output_dir \
			--quartus_dir=$QUARTUS_ROOTDIR \
			--language=$language \
			--sdram_data_width=$sdram_data_width \
			--sdram_bank_width=$sdram_bank_width \
			--sdram_col_width=$sdram_col_width \
			--sdram_row_width=$sdram_row_width \
			--sdram_num_chipselects=$sdram_num_chipselects \
			--module_name=$output_name \
			--cas_latency=$cas_latency
		]

	send_message Info "Starting RTL generation for partner module '$output_name'"
    send_message Info "  Generation command is \[$exec_list\]"
    set gen_output [ eval $exec_list ]

    foreach output_string [ split $gen_output "\n" ] {
        send_message Info $output_string
    }
    send_message Info "Done RTL generation for module '$output_name'"

    if { $language == "vhdl" } {
        set rtl_ext "vhd"
        set rtl_sim_ext "vho"
    } else {
        set rtl_ext "v"
        set rtl_sim_ext "vo"
    }

    set output_file     [ file join $output_dir ${output_name}.${rtl_ext} ]

    #add_file ${output_file} {SYNTHESIS SIMULATION}
	set gen_files [ glob ${output_dir}/${output_name}* ]
	foreach my_file $gen_files {
		add_file $my_file { SYNTHESIS SIMULATION }
		}

}

#-------------------------------------------------------------------------------
# [7] OTHER PROCEDURES
#-------------------------------------------------------------------------------
proc log2 x {expr {log($x) / log(2)}}
