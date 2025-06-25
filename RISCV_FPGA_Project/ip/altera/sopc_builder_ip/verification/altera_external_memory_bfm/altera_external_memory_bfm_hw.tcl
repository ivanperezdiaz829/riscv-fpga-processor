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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_external_memory_bfm/altera_external_memory_bfm_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
#------------------------------------------------------------------------------
package require -exact sopc 9.1

set_module_property NAME                         altera_external_memory_bfm
set_module_property VERSION                      13.1
set_module_property GROUP                        "Avalon Verification Suite"
set_module_property DISPLAY_NAME                 "Altera External Memory BFM"
set_module_property DESCRIPTION                  "Altera External Memory BFM"
set_module_property AUTHOR                       "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     false   
set_module_property INTERNAL                     false
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property ANALYZE_HDL                  false
set_module_property HIDE_FROM_SOPC               true

# ---------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------
# Define file set
add_fileset sim_verilog SIM_VERILOG sim_verilog
set_fileset_property sim_verilog top_level altera_external_memory_bfm

add_fileset sim_vhdl SIM_VHDL sim_vhdl
set_fileset_property sim_vhdl top_level altera_external_memory_bfm_vhdl

add_fileset quartus_synth QUARTUS_SYNTH sim_verilog
set_fileset_property quartus_synth top_level altera_external_memory_bfm

# SIM_VERILOG generation callback procedure
proc sim_verilog {altera_external_memory_bfm} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file altera_external_memory_bfm.sv SYSTEM_VERILOG PATH "altera_external_memory_bfm.sv" 
}

# SIM_VHDL generation callback procedure
proc sim_vhdl {altera_external_memory_bfm_vhdl} {
   set HDL_LIB_DIR "../lib"
   set VHDL_DIR      "../[get_module_property NAME]_vhdl";
   
   if {1} {      
      add_fileset_file mentor/altera_external_memory_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_external_memory_bfm.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_external_memory_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_external_memory_bfm_vhdl_wrapper.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_external_memory_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_external_memory_bfm.sv" {ALDEC_SPECIFIC}
      add_fileset_file aldec/altera_external_memory_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_external_memory_bfm_vhdl_wrapper.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_external_memory_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_external_memory_bfm.sv" {CADENCE_SPECIFIC}
      add_fileset_file cadence/altera_external_memory_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_external_memory_bfm_vhdl_wrapper.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_external_memory_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_external_memory_bfm.sv" {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altera_external_memory_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_external_memory_bfm_vhdl_wrapper.sv" {SYNOPSYS_SPECIFIC}
   }
   
   add_fileset_file altera_external_memory_bfm_vhdl_pkg.vhd VHDL path "$VHDL_DIR/altera_external_memory_bfm_vhdl_pkg.vhd"
   add_fileset_file altera_external_memory_bfm_vhdl.vhd VHDL path "$VHDL_DIR/altera_external_memory_bfm_vhdl.vhd"

}

add_documentation_link "User Guide" "http://www.altera.com/literature/ug/ug_avalon_verification_ip.pdf"
#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------
set CDT_ADDRESS_W                "CDT_ADDRESS_W"
set CDT_SYMBOL_W                 "CDT_SYMBOL_W" 
set CDT_NUMSYMBOLS               "CDT_NUMSYMBOLS"
set INIT_FILE                    "INIT_FILE"
set SIGNAL_ADDRESS_ROLES         "SIGNAL_ADDRESS_ROLES"
set SIGNAL_DATA_ROLES            "SIGNAL_DATA_ROLES"
set SIGNAL_WRITE_ROLES           "SIGNAL_WRITE_ROLES"
set SIGNAL_READ_ROLES            "SIGNAL_READ_ROLES"
set SIGNAL_BYTEENABLE_ROLES      "SIGNAL_BYTEENABLE_ROLES"
set SIGNAL_CHIPSELECT_ROLES      "SIGNAL_CHIPSELECT_ROLES"
set SIGNAL_OUTPUTENABLE_ROLES    "SIGNAL_OUTPUTENABLE_ROLES"
set SIGNAL_BEGINTRANSFER_ROLES   "SIGNAL_BEGINTRANSFER_ROLES"
set SIGNAL_RESET_ROLES           "SIGNAL_RESET_ROLES"
set USE_BYTEENABLE               "USE_BYTEENABLE"
set USE_CHIPSELECT               "USE_CHIPSELECT"
set USE_WRITE                    "USE_WRITE"
set USE_READ                     "USE_READ"
set USE_OUTPUTENABLE             "USE_OUTPUTENABLE"
set USE_BEGINTRANSFER            "USE_BEGINTRANSFER"
set USE_RESET                    "USE_RESET"
set ACTIVE_LOW_CHIPSELECT        "ACTIVE_LOW_CHIPSELECT"
set ACTIVE_LOW_READ              "ACTIVE_LOW_READ"
set ACTIVE_LOW_WRITE             "ACTIVE_LOW_WRITE"
set ACTIVE_LOW_OUTPUTENABLE      "ACTIVE_LOW_OUTPUTENABLE"
set ACTIVE_LOW_BEGINTRANSFER     "ACTIVE_LOW_BEGINTRANSFER"
set ACTIVE_LOW_BYTEENABLE        "ACTIVE_LOW_BYTEENABLE"
set ACTIVE_LOW_RESET             "ACTIVE_LOW_RESET"
set CDT_READ_LATENCY             "CDT_READ_LATENCY"
set VHDL_ID                      "VHDL_ID"
set CDT                          "conduit"
set CLOCK                        "clk"

set HDL_PARAMETER_LIST        [list $CDT_ADDRESS_W $CDT_NUMSYMBOLS $CDT_SYMBOL_W $CDT_READ_LATENCY]
lappend HDL_PARAMETER_LIST     $INIT_FILE $USE_CHIPSELECT $USE_READ $USE_WRITE $USE_OUTPUTENABLE
lappend HDL_PARAMETER_LIST     $USE_BEGINTRANSFER $ACTIVE_LOW_CHIPSELECT $ACTIVE_LOW_READ
lappend HDL_PARAMETER_LIST     $ACTIVE_LOW_WRITE $ACTIVE_LOW_BYTEENABLE $ACTIVE_LOW_OUTPUTENABLE
lappend HDL_PARAMETER_LIST     $ACTIVE_LOW_BEGINTRANSFER $ACTIVE_LOW_RESET $VHDL_ID 

add_parameter $USE_BYTEENABLE Integer 1 
set_parameter_property $USE_BYTEENABLE DISPLAY_NAME "Use the byteenable signal"
set_parameter_property $USE_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property $USE_BYTEENABLE DESCRIPTION "Use the byteenable signal"
set_parameter_property $USE_BYTEENABLE DISPLAY_HINT boolean
set_parameter_property $USE_BYTEENABLE GROUP "Port Enables"

add_parameter $USE_CHIPSELECT Integer 1
set_parameter_property $USE_CHIPSELECT DISPLAY_NAME "Use the chipselect signal"
set_parameter_property $USE_CHIPSELECT AFFECTS_ELABORATION true
set_parameter_property $USE_CHIPSELECT DESCRIPTION "Use the chipselect signal"
set_parameter_property $USE_CHIPSELECT DISPLAY_HINT boolean
set_parameter_property $USE_CHIPSELECT GROUP "Port Enables"
set_parameter_property $USE_CHIPSELECT HDL_PARAMETER true

add_parameter $USE_WRITE Integer 1 
set_parameter_property $USE_WRITE DISPLAY_NAME "Use the write signal"
set_parameter_property $USE_WRITE AFFECTS_ELABORATION true
set_parameter_property $USE_WRITE DESCRIPTION "Use the write signal"
set_parameter_property $USE_WRITE DISPLAY_HINT boolean
set_parameter_property $USE_WRITE GROUP "Port Enables"
set_parameter_property $USE_WRITE HDL_PARAMETER true

add_parameter $USE_READ Integer 1
set_parameter_property $USE_READ DISPLAY_NAME "Use the read signal"
set_parameter_property $USE_READ AFFECTS_ELABORATION true
set_parameter_property $USE_READ DESCRIPTION "Use the read signal"
set_parameter_property $USE_READ DISPLAY_HINT boolean
set_parameter_property $USE_READ GROUP "Port Enables"
set_parameter_property $USE_READ HDL_PARAMETER true

add_parameter $USE_OUTPUTENABLE Integer 1 
set_parameter_property $USE_OUTPUTENABLE DISPLAY_NAME "Use the output enable signal"
set_parameter_property $USE_OUTPUTENABLE AFFECTS_ELABORATION true
set_parameter_property $USE_OUTPUTENABLE DESCRIPTION "Use the output enable signal"
set_parameter_property $USE_OUTPUTENABLE DISPLAY_HINT boolean
set_parameter_property $USE_OUTPUTENABLE GROUP "Port Enables"
set_parameter_property $USE_OUTPUTENABLE HDL_PARAMETER true

add_parameter $USE_BEGINTRANSFER Integer 1 
set_parameter_property $USE_BEGINTRANSFER DISPLAY_NAME "Use the begintransfer signal"
set_parameter_property $USE_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property $USE_BEGINTRANSFER DESCRIPTION "Use the begintransfer signal"
set_parameter_property $USE_BEGINTRANSFER DISPLAY_HINT boolean
set_parameter_property $USE_BEGINTRANSFER GROUP "Port Enables"
set_parameter_property $USE_BEGINTRANSFER HDL_PARAMETER true

add_parameter $USE_RESET Integer 0 
set_parameter_property $USE_RESET DISPLAY_NAME "Use a reset input signal"
set_parameter_property $USE_RESET AFFECTS_ELABORATION true
set_parameter_property $USE_RESET DESCRIPTION "Use a reset input signal"
set_parameter_property $USE_RESET DISPLAY_HINT boolean
set_parameter_property $USE_RESET GROUP "Port Enables"
set_parameter_property $USE_RESET HDL_PARAMETER false

add_parameter $ACTIVE_LOW_BYTEENABLE Integer 0
set_parameter_property $ACTIVE_LOW_BYTEENABLE DISPLAY_NAME "Use active low byteenable signal"
set_parameter_property $ACTIVE_LOW_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_BYTEENABLE DESCRIPTION "Use active low byteenable signal"
set_parameter_property $ACTIVE_LOW_BYTEENABLE DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_BYTEENABLE GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_BYTEENABLE HDL_PARAMETER true

add_parameter $ACTIVE_LOW_CHIPSELECT Integer 0 
set_parameter_property $ACTIVE_LOW_CHIPSELECT DISPLAY_NAME "Use active low chipselect signal"
set_parameter_property $ACTIVE_LOW_CHIPSELECT AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_CHIPSELECT DESCRIPTION "Use active low chipselect signal"
set_parameter_property $ACTIVE_LOW_CHIPSELECT DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_CHIPSELECT GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_CHIPSELECT HDL_PARAMETER true

add_parameter $ACTIVE_LOW_WRITE Integer 0 
set_parameter_property $ACTIVE_LOW_WRITE DISPLAY_NAME "Use active low write signal"
set_parameter_property $ACTIVE_LOW_WRITE AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_WRITE DESCRIPTION "Use active low write signal"
set_parameter_property $ACTIVE_LOW_WRITE DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_WRITE GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_WRITE HDL_PARAMETER true

add_parameter $ACTIVE_LOW_READ Integer 0
set_parameter_property $ACTIVE_LOW_READ DISPLAY_NAME "Use active low read signal"
set_parameter_property $ACTIVE_LOW_READ AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_READ DESCRIPTION "Use active low read signal"
set_parameter_property $ACTIVE_LOW_READ DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_READ GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_READ HDL_PARAMETER true

add_parameter $ACTIVE_LOW_OUTPUTENABLE Integer 0
set_parameter_property $ACTIVE_LOW_OUTPUTENABLE DISPLAY_NAME "Use active low outputenable signal"
set_parameter_property $ACTIVE_LOW_OUTPUTENABLE AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_OUTPUTENABLE DESCRIPTION "Use active low outputenable signal"
set_parameter_property $ACTIVE_LOW_OUTPUTENABLE DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_OUTPUTENABLE GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_OUTPUTENABLE HDL_PARAMETER true

add_parameter $ACTIVE_LOW_BEGINTRANSFER Integer 0
set_parameter_property $ACTIVE_LOW_BEGINTRANSFER DISPLAY_NAME "Use active low begintransfer signal"
set_parameter_property $ACTIVE_LOW_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_BEGINTRANSFER DESCRIPTION "Use active low begintransfer signal"
set_parameter_property $ACTIVE_LOW_BEGINTRANSFER DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_BEGINTRANSFER GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_BEGINTRANSFER HDL_PARAMETER true

add_parameter $ACTIVE_LOW_RESET Integer 0
set_parameter_property $ACTIVE_LOW_RESET DISPLAY_NAME "Use active low reset signal"
set_parameter_property $ACTIVE_LOW_RESET AFFECTS_ELABORATION true
set_parameter_property $ACTIVE_LOW_RESET DESCRIPTION "Use active low reset signal"
set_parameter_property $ACTIVE_LOW_RESET DISPLAY_HINT boolean
set_parameter_property $ACTIVE_LOW_RESET GROUP "Port Polarity"
set_parameter_property $ACTIVE_LOW_RESET HDL_PARAMETER true

add_parameter $SIGNAL_ADDRESS_ROLES STRING "cdt_address"
set_parameter_property $SIGNAL_ADDRESS_ROLES DISPLAY_NAME "Address Role"
set_parameter_property $SIGNAL_ADDRESS_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_ADDRESS_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_DATA_ROLES STRING "cdt_data_io"
set_parameter_property $SIGNAL_DATA_ROLES DISPLAY_NAME "Data Role"
set_parameter_property $SIGNAL_DATA_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_DATA_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_WRITE_ROLES STRING "cdt_write"
set_parameter_property $SIGNAL_WRITE_ROLES DISPLAY_NAME "Write Role"
set_parameter_property $SIGNAL_WRITE_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_WRITE_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_READ_ROLES STRING "cdt_read"
set_parameter_property $SIGNAL_READ_ROLES DISPLAY_NAME "Read Role"
set_parameter_property $SIGNAL_READ_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_READ_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_BYTEENABLE_ROLES STRING "cdt_byteenable"
set_parameter_property $SIGNAL_BYTEENABLE_ROLES DISPLAY_NAME "Byteenable Role"
set_parameter_property $SIGNAL_BYTEENABLE_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_BYTEENABLE_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_CHIPSELECT_ROLES STRING "cdt_chipselect"
set_parameter_property $SIGNAL_CHIPSELECT_ROLES DISPLAY_NAME "Chip Select Role"
set_parameter_property $SIGNAL_CHIPSELECT_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_CHIPSELECT_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_OUTPUTENABLE_ROLES STRING "cdt_outputenable"
set_parameter_property $SIGNAL_OUTPUTENABLE_ROLES DISPLAY_NAME "Outputenable Role"
set_parameter_property $SIGNAL_OUTPUTENABLE_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_OUTPUTENABLE_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_BEGINTRANSFER_ROLES STRING "cdt_begintransfer"
set_parameter_property $SIGNAL_BEGINTRANSFER_ROLES DISPLAY_NAME "Begintransfer Role"
set_parameter_property $SIGNAL_BEGINTRANSFER_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_BEGINTRANSFER_ROLES GROUP "Interface Signals Name"

add_parameter $SIGNAL_RESET_ROLES STRING "cdt_reset"
set_parameter_property $SIGNAL_RESET_ROLES DISPLAY_NAME "Reset Role"
set_parameter_property $SIGNAL_RESET_ROLES AFFECTS_ELABORATION true
set_parameter_property $SIGNAL_RESET_ROLES GROUP "Interface Signals Name"

add_parameter $CDT_ADDRESS_W Integer 8
set_parameter_property $CDT_ADDRESS_W DISPLAY_NAME "Address width"
set_parameter_property $CDT_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property $CDT_ADDRESS_W DESCRIPTION "The width of the address signal."
set_parameter_property $CDT_ADDRESS_W ALLOWED_RANGES {1:32}
set_parameter_property $CDT_ADDRESS_W HDL_PARAMETER true
set_parameter_property $CDT_ADDRESS_W GROUP "Port Widths"

add_parameter $CDT_SYMBOL_W Integer 8
set_parameter_property $CDT_SYMBOL_W DISPLAY_NAME "Symbol width"
set_parameter_property $CDT_SYMBOL_W AFFECTS_ELABORATION true
set_parameter_property $CDT_SYMBOL_W DESCRIPTION "The width of an indidual symbol."
set_parameter_property $CDT_SYMBOL_W ALLOWED_RANGES {1:1024}
set_parameter_property $CDT_SYMBOL_W HDL_PARAMETER true
set_parameter_property $CDT_SYMBOL_W GROUP "Port Widths"

add_parameter $CDT_NUMSYMBOLS Integer 4
set_parameter_property $CDT_NUMSYMBOLS DISPLAY_NAME "Number of Symbols"
set_parameter_property $CDT_NUMSYMBOLS AFFECTS_ELABORATION true
set_parameter_property $CDT_NUMSYMBOLS DESCRIPTION "The number of symbols in a word."
set_parameter_property $CDT_NUMSYMBOLS ALLOWED_RANGES {1,2,4,8,16,32,64,128}
set_parameter_property $CDT_NUMSYMBOLS HDL_PARAMETER true
set_parameter_property $CDT_NUMSYMBOLS GROUP "Port Widths"

add_parameter $INIT_FILE String "altera_external_memory_bfm.hex"
set_parameter_property $INIT_FILE DISPLAY_NAME "Memory Initialization"
set_parameter_property $INIT_FILE AFFECTS_ELABORATION true
set_parameter_property $INIT_FILE DESCRIPTION "The file specifies the initial memory contents"
set_parameter_property $INIT_FILE HDL_PARAMETER true
set_parameter_property $INIT_FILE GROUP "Memory Contents"

add_parameter $CDT_READ_LATENCY integer 0
set_parameter_property $CDT_READ_LATENCY AFFECTS_ELABORATION true
set_parameter_property $CDT_READ_LATENCY DESCRIPTION "The Read Latency of the interface"
set_parameter_property $CDT_READ_LATENCY ALLOWED_RANGES {0:32000}
set_parameter_property $CDT_READ_LATENCY HDL_PARAMETER true
set_parameter_property $CDT_READ_LATENCY Display_Name "Read Latency of Interface"
set_parameter_property $CDT_READ_LATENCY GROUP "Interface Timing"

add_parameter $VHDL_ID Integer 0
set_parameter_property $VHDL_ID DISPLAY_NAME "VHDL BFM ID"
set_parameter_property $VHDL_ID DESCRIPTION "BFM ID number for VHDL"
set_parameter_property $VHDL_ID HDL_PARAMETER true
set_parameter_property $VHDL_ID ALLOWED_RANGES {0:1023}
set_parameter_property $VHDL_ID GROUP "VHDL BFM"

foreach HDL_PARAMETER $HDL_PARAMETER_LIST {
   set_parameter_property $HDL_PARAMETER AFFECTS_GENERATION false
}

#------------------------------------------------------------------------------

# Add constant assignments
add_interface $CLOCK clock end
add_interface_port $CLOCK clk clk input 1

add_interface $CDT conduit end

proc elaborate {} {
    global CDT_ADDRESS_W          
    global CDT_SYMBOL_W           
    global CDT_NUMSYMBOLS         
    global SIGNAL_ADDRESS_ROLES
    global SIGNAL_DATA_ROLES
    global SIGNAL_WRITE_ROLES
    global SIGNAL_READ_ROLES
    global SIGNAL_BYTEENABLE_ROLES
    global SIGNAL_CHIPSELECT_ROLES
    global SIGNAL_OUTPUTENABLE_ROLES
    global SIGNAL_BEGINTRANSFER_ROLES
    global SIGNAL_RESET_ROLES
    global USE_BYTEENABLE
    global USE_CHIPSELECT
    global USE_WRITE
    global USE_READ
    global USE_OUTPUTENABLE
    global USE_BEGINTRANSFER
    global USE_RESET
    global ACTIVE_LOW_CHIPSELECT
    global ACTIVE_LOW_WRITE
    global ACTIVE_LOW_READ
    global ACTIVE_LOW_OUTPUTENABLE
    global ACTIVE_LOW_BEGINTRANSFER
    global ACTIVE_LOW_BYTEENABLE
    global ACTIVE_LOW_RESET
    global CDT
   
    set CDT_ADDRESS_W_VALUE               [ get_parameter $CDT_ADDRESS_W ]
    set CDT_SYMBOL_W_VALUE                [ get_parameter $CDT_SYMBOL_W ] 
    set CDT_NUMSYMBOLS_VALUE              [ get_parameter $CDT_NUMSYMBOLS ]
    set CDT_DATA_W_VALUE                  [ expr {$CDT_SYMBOL_W_VALUE * $CDT_NUMSYMBOLS_VALUE}]
    set SIGNAL_ADDRESS_ROLES_VALUE        [ get_parameter $SIGNAL_ADDRESS_ROLES ]
    set SIGNAL_DATA_ROLES_VALUE           [ get_parameter $SIGNAL_DATA_ROLES ]
    set SIGNAL_WRITE_ROLES_VALUE          [ get_parameter $SIGNAL_WRITE_ROLES ]
    set SIGNAL_READ_ROLES_VALUE           [ get_parameter $SIGNAL_READ_ROLES ]
    set SIGNAL_BYTEENABLE_ROLES_VALUE     [ get_parameter $SIGNAL_BYTEENABLE_ROLES ]
    set SIGNAL_CHIPSELECT_ROLES_VALUE     [ get_parameter $SIGNAL_CHIPSELECT_ROLES ]
    set SIGNAL_OUTPUTENABLE_ROLES_VALUE   [ get_parameter $SIGNAL_OUTPUTENABLE_ROLES ]
    set SIGNAL_BEGINTRANSFER_ROLES_VALUE  [ get_parameter $SIGNAL_BEGINTRANSFER_ROLES ]
    set SIGNAL_RESET_ROLES_VALUE          [ get_parameter $SIGNAL_RESET_ROLES ] 
    set USE_BYTEENABLE_VALUE              [ get_parameter $USE_BYTEENABLE ]
    set USE_CHIPSELECT_VALUE              [ get_parameter $USE_CHIPSELECT ] 
    set USE_READ_VALUE                    [ get_parameter $USE_READ ]
    set USE_WRITE_VALUE                   [ get_parameter $USE_WRITE ] 
    set USE_OUTPUTENABLE_VALUE            [ get_parameter $USE_OUTPUTENABLE ] 
    set USE_BEGINTRANSFER_VALUE           [ get_parameter $USE_BEGINTRANSFER ] 
    set USE_RESET_VALUE                   [ get_parameter $USE_RESET]
    set ACTIVE_LOW_CHIPSELECT_VALUE       [ get_parameter $ACTIVE_LOW_CHIPSELECT]
    set ACTIVE_LOW_WRITE_VALUE            [ get_parameter $ACTIVE_LOW_WRITE]
    set ACTIVE_LOW_READ_VALUE             [ get_parameter $ACTIVE_LOW_READ]
    set ACTIVE_LOW_OUTPUTENABLE_VALUE     [ get_parameter $ACTIVE_LOW_OUTPUTENABLE]
    set ACTIVE_LOW_BEGINTRANSFER_VALUE    [ get_parameter $ACTIVE_LOW_BEGINTRANSFER]
    set ACTIVE_LOW_BYTEENABLE_VALUE       [ get_parameter $ACTIVE_LOW_BYTEENABLE]
    set ACTIVE_LOW_RESET_VALUE            [ get_parameter $ACTIVE_LOW_RESET]
    
    #---------------------------------------------------------------------
    # Conduit connection point 
    #---------------------------------------------------------------------
    add_interface_port $CDT cdt_write         $SIGNAL_WRITE_ROLES_VALUE         input 1
    add_interface_port $CDT cdt_read          $SIGNAL_READ_ROLES_VALUE          input 1
    add_interface_port $CDT cdt_chipselect    $SIGNAL_CHIPSELECT_ROLES_VALUE    input 1
    add_interface_port $CDT cdt_outputenable  $SIGNAL_OUTPUTENABLE_ROLES_VALUE  input 1
    add_interface_port $CDT cdt_begintransfer $SIGNAL_BEGINTRANSFER_ROLES_VALUE input 1
    add_interface_port $CDT cdt_address       $SIGNAL_ADDRESS_ROLES_VALUE       input $CDT_ADDRESS_W_VALUE
    set_port_property cdt_address VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CDT cdt_data_io       $SIGNAL_DATA_ROLES_VALUE          bidir $CDT_DATA_W_VALUE
    set_port_property cdt_data_io VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CDT cdt_byteenable    $SIGNAL_BYTEENABLE_ROLES_VALUE    input $CDT_NUMSYMBOLS_VALUE
    set_port_property cdt_byteenable VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CDT cdt_reset         $SIGNAL_RESET_ROLES_VALUE         input 1

    if {$USE_CHIPSELECT_VALUE == 0} {
        set_parameter_property SIGNAL_CHIPSELECT_ROLES ENABLED false
        set_parameter_property ACTIVE_LOW_CHIPSELECT ENABLED false
        set_port_property cdt_chipselect        TERMINATION 1
	if {$ACTIVE_LOW_CHIPSELECT_VALUE} {
	    set_port_property cdt_chipselect       TERMINATION_VALUE 1
	} else {
	    set_port_property cdt_chipselect       TERMINATION_VALUE 0
	}
    } else {
        set_parameter_property SIGNAL_CHIPSELECT_ROLES ENABLED true
        set_parameter_property ACTIVE_LOW_CHIPSELECT ENABLED true
    }
    
    if {$USE_WRITE_VALUE == 0} {
        set_parameter_property SIGNAL_WRITE_ROLES ENABLED false
        set_parameter_property ACTIVE_LOW_WRITE ENABLED false
        set_port_property cdt_write        TERMINATION 1
        if {$ACTIVE_LOW_WRITE_VALUE } {
	    set_port_property cdt_write        TERMINATION_VALUE 1
	} else {
	    set_port_property cdt_write        TERMINATION_VALUE 0
	}
    } else {
        set_parameter_property SIGNAL_WRITE_ROLES ENABLED true
        set_parameter_property ACTIVE_LOW_WRITE ENABLED true
    }

    if {$USE_READ_VALUE == 0} {
        set_parameter_property SIGNAL_READ_ROLES ENABLED false
        set_parameter_property ACTIVE_LOW_READ ENABLED false
        set_port_property cdt_read        TERMINATION 1
	if {$ACTIVE_LOW_READ_VALUE} {
	    set_port_property cdt_read    TERMINATION_VALUE 1
	} else {
	    set_port_property cdt_read    TERMINATION_VALUE 0
	}
    } else {
        set_parameter_property SIGNAL_READ_ROLES ENABLED true
        set_parameter_property ACTIVE_LOW_READ ENABLED true
    }
    
    if {$USE_OUTPUTENABLE_VALUE == 0} {
        set_parameter_property SIGNAL_OUTPUTENABLE_ROLES ENABLED false
        set_parameter_property ACTIVE_LOW_OUTPUTENABLE ENABLED false
        set_port_property cdt_outputenable        TERMINATION 1
	if {$ACTIVE_LOW_OUTPUTENABLE_VALUE} {
	    set_port_property cdt_outputenable        TERMINATION_VALUE 1
	} else {
	    set_port_property cdt_outputenable        TERMINATION_VALUE 0
	}
    } else {
        set_parameter_property SIGNAL_OUTPUTENABLE_ROLES ENABLED true
        set_parameter_property ACTIVE_LOW_OUTPUTENABLE ENABLED true
    }

    if {$USE_BEGINTRANSFER_VALUE == 0} {
        set_parameter_property $SIGNAL_BEGINTRANSFER_ROLES ENABLED false
        set_parameter_property $ACTIVE_LOW_BEGINTRANSFER ENABLED false
        set_port_property cdt_begintransfer        TERMINATION 1
	if {$ACTIVE_LOW_BEGINTRANSFER_VALUE} {
	    set_port_property cdt_begintransfer        TERMINATION_VALUE 1
	} else {
	    set_port_property cdt_begintransfer        TERMINATION_VALUE 0
	}
    } else {
        set_parameter_property $SIGNAL_BEGINTRANSFER_ROLES ENABLED true
        set_parameter_property $ACTIVE_LOW_BEGINTRANSFER ENABLED true
    }

    if {$USE_BYTEENABLE_VALUE == 0} {
        set_parameter_property ACTIVE_LOW_BYTEENABLE ENABLED false
        set_parameter_property SIGNAL_BYTEENABLE_ROLES ENABLED false
        set_port_property cdt_byteenable        TERMINATION 1
	if {$ACTIVE_LOW_BYTEENABLE_VALUE} {
	    set_port_property cdt_byteenable    TERMINATION_VALUE 0
	} else {
	    set_port_property cdt_byteenable        TERMINATION_VALUE 0xFFFFFFFFFFFFFF
	}
    } else {
        set_parameter_property SIGNAL_BYTEENABLE_ROLES ENABLED true
        set_parameter_property ACTIVE_LOW_BYTEENABLE ENABLED true
    }
    
    if { $USE_RESET_VALUE == 0 } {
	set_parameter_property SIGNAL_RESET_ROLES ENABLED false
	set_parameter_property ACTIVE_LOW_RESET ENABLED false
	set_port_property cdt_reset TERMINATION 1
	if { $ACTIVE_LOW_RESET_VALUE } {
	    set_port_property cdt_reset TERMINATION_VALUE 1
	} else {
	    set_port_property cdt_reset TERMINATION_VALUE 0
	}
    } else {
	set_parameter_property SIGNAL_RESET_ROLES ENABLED true
	set_parameter_property ACTIVE_LOW_RESET ENABLED true
    }
    
}
