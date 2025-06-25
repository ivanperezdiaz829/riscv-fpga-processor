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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_monitor_bfm/altera_avalon_mm_monitor_hw.tcl $
# $Revision: #3 $
# $Date: 2013/08/15 $
# $Author: saafnan $
#---------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property NAME                         altera_avalon_mm_monitor
set_module_property DISPLAY_NAME                 "Altera Avalon MM Monitor"
set_module_property DESCRIPTION                  "Altera Avalon MM Monitor"
set_module_property VERSION                      13.1
set_module_property GROUP                        "Avalon Verification Suite"
set_module_property AUTHOR                       "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     false
set_module_property INTERNAL                     false
set_module_property VALIDATION_CALLBACK          validate
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property ANALYZE_HDL                  false

# ---------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------
# Define file set
add_fileset sim_verilog SIM_VERILOG sim_verilog
set_fileset_property sim_verilog top_level altera_avalon_mm_monitor

add_fileset quartus_synth QUARTUS_SYNTH quartus_synth_proc
set_fileset_property quartus_synth top_level altera_avalon_mm_monitor

add_fileset sim_vhdl SIM_VHDL sim_vhdl
set_fileset_property sim_vhdl top_level altera_avalon_mm_monitor_vhdl

# SIM_VERILOG generation callback procedure
proc sim_verilog {altera_avalon_mm_monitor} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_mm_pkg.sv" 
   add_fileset_file altera_avalon_mm_monitor_assertion.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor_assertion.sv"
   add_fileset_file altera_avalon_mm_monitor_coverage.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor_coverage.sv"
   add_fileset_file altera_avalon_mm_monitor_transactions.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor_transactions.sv"
   add_fileset_file altera_avalon_mm_monitor.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor.sv"
   
   set_fileset_file_attribute verbosity_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_mm_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_mm_pkg
}

proc quartus_synth_proc {altera_avalon_mm_monitor} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_mm_pkg.sv" 
   add_fileset_file altera_avalon_mm_monitor_assertion.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor_assertion.sv"
   add_fileset_file altera_avalon_mm_monitor_coverage.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor_coverage.sv"
   add_fileset_file altera_avalon_mm_monitor_transactions.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor_transactions.sv"
   add_fileset_file altera_avalon_mm_monitor.sv SYSTEM_VERILOG PATH "altera_avalon_mm_monitor.sv"
}

# SIM_VHDL generation callback procedure
proc sim_vhdl {altera_avalon_mm_monitor_vhdl} {
   set HDL_LIB_DIR "../lib"
   set VHDL_DIR      "../altera_avalon_mm_monitor_bfm_vhdl";
   
   if {1} {
      add_fileset_file mentor/verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/verbosity_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/avalon_mm_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/avalon_mm_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_mm_monitor_transactions.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_mm_monitor_transactions.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_mm_monitor_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_mm_monitor_vhdl_wrapper.sv" {MENTOR_SPECIFIC}
      
      set_fileset_file_attribute mentor/verbosity_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_verbosity_pkg
      set_fileset_file_attribute mentor/avalon_mm_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_avalon_mm_pkg
   }

   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/verbosity_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/avalon_mm_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_mm_monitor_transactions.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_mm_monitor_transactions.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_mm_monitor_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_mm_monitor_vhdl_wrapper.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   
   set_fileset_file_attribute verbosity_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_mm_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_mm_pkg
   
   add_fileset_file altera_avalon_mm_monitor_vhdl_pkg.vhd VHDL path "$VHDL_DIR/altera_avalon_mm_monitor_vhdl_pkg.vhd"
   add_fileset_file altera_avalon_mm_monitor_vhdl.vhd VHDL path "$VHDL_DIR/altera_avalon_mm_monitor_vhdl.vhd"

}

add_documentation_link "User Guide" "http://www.altera.com/literature/ug/ug_avalon_verification_ip.pdf"
#---------------------------------------------------------------------
# Parameters
#---------------------------------------------------------------------

set AV_ADDRESS_W                    "AV_ADDRESS_W"
set AV_SYMBOL_W                     "AV_SYMBOL_W" 
set AV_NUMSYMBOLS                   "AV_NUMSYMBOLS"
set AV_BURSTCOUNT_W                 "AV_BURSTCOUNT_W" 

set USE_READ                        "USE_READ"
set USE_WRITE                       "USE_WRITE"
set USE_ADDRESS                     "USE_ADDRESS"
set USE_BYTE_ENABLE                 "USE_BYTE_ENABLE"
set USE_BURSTCOUNT                  "USE_BURSTCOUNT"
set USE_READ_DATA                   "USE_READ_DATA"
set USE_READ_DATA_VALID             "USE_READ_DATA_VALID"
set USE_WRITE_DATA                  "USE_WRITE_DATA"
set USE_BEGIN_TRANSFER              "USE_BEGIN_TRANSFER"
set USE_BEGIN_BURST_TRANSFER        "USE_BEGIN_BURST_TRANSFER"
set USE_WAIT_REQUEST                "USE_WAIT_REQUEST"
#set USE_EXPANSION_INTERFACE        "USE_EXPANSION_INTERFACE"

set AV_CONSTANT_BURST_BEHAVIOR      "AV_CONSTANT_BURST_BEHAVIOR"
set AV_BURST_LINEWRAP               "AV_BURST_LINEWRAP" 
set AV_BURST_BNDR_ONLY              "AV_BURST_BNDR_ONLY"

set AV_READ_TIMEOUT                 "AV_READ_TIMEOUT"
set AV_WRITE_TIMEOUT                "AV_WRITE_TIMEOUT"
set AV_WAITREQUEST_TIMEOUT          "AV_WAITREQUEST_TIMEOUT"
set AV_MAX_PENDING_READS            "AV_MAX_PENDING_READS"
set AV_MAX_PENDING_WRITES           "AV_MAX_PENDING_WRITES"
set AV_FIX_READ_LATENCY             "AV_FIX_READ_LATENCY"
set AV_MAX_READ_LATENCY             "AV_MAX_READ_LATENCY"
set AV_MAX_WAITREQUESTED_READ       "AV_MAX_WAITREQUESTED_READ"
set AV_MAX_WAITREQUESTED_WRITE      "AV_MAX_WAITREQUESTED_WRITE"

set AV_READRESPONSE_W               "AV_READRESPONSE_W"
set AV_WRITERESPONSE_W              "AV_WRITERESPONSE_W"
set USE_ARBITERLOCK                 "USE_ARBITERLOCK"
set USE_LOCK                        "USE_LOCK"
set USE_DEBUGACCESS                 "USE_DEBUGACCESS"
set USE_TRANSACTIONID               "USE_TRANSACTIONID"
set USE_WRITERESPONSE               "USE_WRITERESPONSE"
set USE_READRESPONSE                "USE_READRESPONSE"
set USE_CLKEN                       "USE_CLKEN"

set AV_MAX_CONTINUOUS_READ          "AV_MAX_CONTINUOUS_READ"
set AV_MAX_CONTINUOUS_WRITE         "AV_MAX_CONTINUOUS_WRITE"
set AV_MAX_CONTINUOUS_WAITREQUEST   "AV_MAX_CONTINUOUS_WAITREQUEST"
set AV_MAX_CONTINUOUS_READDATAVALID "AV_MAX_CONTINUOUS_READDATAVALID"
set AV_READ_WAIT_TIME               "AV_READ_WAIT_TIME"
set AV_WRITE_WAIT_TIME              "AV_WRITE_WAIT_TIME"

set REGISTER_WAITREQUEST            "REGISTER_WAITREQUEST"
set AV_REGISTERINCOMINGSIGNALS      "AV_REGISTERINCOMINGSIGNALS"

set MASTER_ADDRESS_TYPE             "MASTER_ADDRESS_TYPE"
set SLAVE_ADDRESS_TYPE              "SLAVE_ADDRESS_TYPE"
set VHDL_ID                         "VHDL_ID"

#---------------------------------------------------------------------
add_parameter $AV_ADDRESS_W Integer 32
set_parameter_property $AV_ADDRESS_W DISPLAY_NAME "Address width"
set_parameter_property $AV_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property $AV_ADDRESS_W DESCRIPTION "The width of the address signal."
set_parameter_property $AV_ADDRESS_W ALLOWED_RANGES {1:64}
set_parameter_property $AV_ADDRESS_W HDL_PARAMETER true
set_parameter_property $AV_ADDRESS_W GROUP "Port Widths"

add_parameter $AV_SYMBOL_W Integer 8
set_parameter_property $AV_SYMBOL_W DISPLAY_NAME "Symbol width"
set_parameter_property $AV_SYMBOL_W AFFECTS_ELABORATION true
set_parameter_property $AV_SYMBOL_W DESCRIPTION "The width of an individual symbol. The default is an 8 bit Byte."
set_parameter_property $AV_SYMBOL_W ALLOWED_RANGES {1:1024}
set_parameter_property $AV_SYMBOL_W HDL_PARAMETER true
set_parameter_property $AV_SYMBOL_W GROUP "Port Widths"

add_parameter $AV_NUMSYMBOLS Integer 4
set_parameter_property $AV_NUMSYMBOLS DISPLAY_NAME "Number of Symbols"
set_parameter_property $AV_NUMSYMBOLS AFFECTS_ELABORATION true
set_parameter_property $AV_NUMSYMBOLS DESCRIPTION "The number of symbols in a word. The default is 4 bytes per word."
set_parameter_property $AV_NUMSYMBOLS ALLOWED_RANGES {1,2,4,8,16,32,64,128}
set_parameter_property $AV_NUMSYMBOLS HDL_PARAMETER true
set_parameter_property $AV_NUMSYMBOLS GROUP "Port Widths"

add_parameter $AV_BURSTCOUNT_W Integer 3
set_parameter_property $AV_BURSTCOUNT_W DISPLAY_NAME "Burstcount width"
set_parameter_property $AV_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property $AV_BURSTCOUNT_W DESCRIPTION "The width of the Burstcount port determines the maximum burst length that can be specified for a transaction."
set_parameter_property $AV_BURSTCOUNT_W ALLOWED_RANGES {1:32}
set_parameter_property $AV_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property $AV_BURSTCOUNT_W GROUP "Port Widths"

add_parameter $USE_READ Integer 1
set_parameter_property $USE_READ DISPLAY_NAME "Use the read signal"
set_parameter_property $USE_READ AFFECTS_ELABORATION true
set_parameter_property $USE_READ DESCRIPTION "Use read port"
set_parameter_property $USE_READ DISPLAY_HINT boolean
set_parameter_property $USE_READ HDL_PARAMETER true
set_parameter_property $USE_READ GROUP "Port Enables"

add_parameter $USE_WRITE Integer 1
set_parameter_property $USE_WRITE DISPLAY_NAME "Use the write signal"
set_parameter_property $USE_WRITE AFFECTS_ELABORATION true
set_parameter_property $USE_WRITE DESCRIPTION "Use write port"
set_parameter_property $USE_WRITE DISPLAY_HINT boolean
set_parameter_property $USE_WRITE HDL_PARAMETER true
set_parameter_property $USE_WRITE GROUP "Port Enables"

add_parameter $USE_ADDRESS Integer 1
set_parameter_property $USE_ADDRESS DISPLAY_NAME "Use the address signal"
set_parameter_property $USE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property $USE_ADDRESS DESCRIPTION "Use address port"
set_parameter_property $USE_ADDRESS DISPLAY_HINT boolean
set_parameter_property $USE_ADDRESS HDL_PARAMETER true
set_parameter_property $USE_ADDRESS GROUP "Port Enables"

add_parameter $USE_BYTE_ENABLE Integer 1
set_parameter_property $USE_BYTE_ENABLE DISPLAY_NAME "Use the byteenable signal"
set_parameter_property $USE_BYTE_ENABLE AFFECTS_ELABORATION true
set_parameter_property $USE_BYTE_ENABLE DESCRIPTION "Use the byteenable signal"
set_parameter_property $USE_BYTE_ENABLE DISPLAY_HINT boolean
set_parameter_property $USE_BYTE_ENABLE HDL_PARAMETER true
set_parameter_property $USE_BYTE_ENABLE GROUP "Port Enables"

add_parameter $USE_BURSTCOUNT Integer 1
set_parameter_property $USE_BURSTCOUNT DISPLAY_NAME "Use the burstcount signal"
set_parameter_property $USE_BURSTCOUNT AFFECTS_ELABORATION true
set_parameter_property $USE_BURSTCOUNT DESCRIPTION "Use burstcount port"
set_parameter_property $USE_BURSTCOUNT DISPLAY_HINT boolean
set_parameter_property $USE_BURSTCOUNT HDL_PARAMETER true
set_parameter_property $USE_BURSTCOUNT GROUP "Port Enables"

add_parameter $USE_READ_DATA Integer 1
set_parameter_property $USE_READ_DATA DISPLAY_NAME "Use the readdata signal"
set_parameter_property $USE_READ_DATA AFFECTS_ELABORATION true
set_parameter_property $USE_READ_DATA DESCRIPTION "Use readdata port"
set_parameter_property $USE_READ_DATA DISPLAY_HINT boolean
set_parameter_property $USE_READ_DATA HDL_PARAMETER true
set_parameter_property $USE_READ_DATA GROUP "Port Enables"

add_parameter $USE_READ_DATA_VALID Integer 1
set_parameter_property $USE_READ_DATA_VALID DISPLAY_NAME "Use the readdatavalid signal"
set_parameter_property $USE_READ_DATA_VALID AFFECTS_ELABORATION true
set_parameter_property $USE_READ_DATA_VALID DESCRIPTION "Use readdatavalid port"
set_parameter_property $USE_READ_DATA_VALID DISPLAY_HINT boolean
set_parameter_property $USE_READ_DATA_VALID HDL_PARAMETER true
set_parameter_property $USE_READ_DATA_VALID GROUP "Port Enables"

add_parameter $USE_WRITE_DATA Integer 1
set_parameter_property $USE_WRITE_DATA DISPLAY_NAME "Use the writedata signal"
set_parameter_property $USE_WRITE_DATA AFFECTS_ELABORATION true
set_parameter_property $USE_WRITE_DATA DESCRIPTION "Use writedata port"
set_parameter_property $USE_WRITE_DATA DISPLAY_HINT boolean
set_parameter_property $USE_WRITE_DATA HDL_PARAMETER true
set_parameter_property $USE_WRITE_DATA GROUP "Port Enables"

add_parameter $USE_BEGIN_TRANSFER Integer 0
set_parameter_property $USE_BEGIN_TRANSFER DISPLAY_NAME "Use the begintransfer signal"
set_parameter_property $USE_BEGIN_TRANSFER AFFECTS_ELABORATION true
set_parameter_property $USE_BEGIN_TRANSFER DESCRIPTION "Use begintransfer port"
set_parameter_property $USE_BEGIN_TRANSFER DISPLAY_HINT boolean
set_parameter_property $USE_BEGIN_TRANSFER HDL_PARAMETER true
set_parameter_property $USE_BEGIN_TRANSFER GROUP "Port Enables"

add_parameter $USE_BEGIN_BURST_TRANSFER Integer 0
set_parameter_property $USE_BEGIN_BURST_TRANSFER DISPLAY_NAME "Use beginbursttransfer signal"
set_parameter_property $USE_BEGIN_BURST_TRANSFER AFFECTS_ELABORATION true
set_parameter_property $USE_BEGIN_BURST_TRANSFER DESCRIPTION "Use beginbursttransfer port"
set_parameter_property $USE_BEGIN_BURST_TRANSFER DISPLAY_HINT boolean
set_parameter_property $USE_BEGIN_BURST_TRANSFER HDL_PARAMETER true
set_parameter_property $USE_BEGIN_BURST_TRANSFER GROUP "Port Enables"

add_parameter $USE_WAIT_REQUEST Integer 1
set_parameter_property $USE_WAIT_REQUEST DISPLAY_NAME "Use the waitrequest signal"
set_parameter_property $USE_WAIT_REQUEST AFFECTS_ELABORATION true
set_parameter_property $USE_WAIT_REQUEST DESCRIPTION "Use waitrequest port"
set_parameter_property $USE_WAIT_REQUEST DISPLAY_HINT boolean
set_parameter_property $USE_WAIT_REQUEST HDL_PARAMETER true
set_parameter_property $USE_WAIT_REQUEST GROUP "Port Enables"

#add_parameter $USE_EXPANSION_INTERFACE Integer 0
#set_parameter_property $USE_EXPANSION_INTERFACE DISPLAY_NAME USE_EXPANSION_INTERFACE
#set_parameter_property $USE_EXPANSION_INTERFACE AFFECTS_ELABORATION true
#set_parameter_property $USE_EXPANSION_INTERFACE DESCRIPTION "Use the expansion port for custom monitors"
#set_parameter_property $USE_EXPANSION_INTERFACE DISPLAY_HINT boolean
#set_parameter_property $USE_EXPANSION_INTERFACE HDL_PARAMETER true
#set_parameter_property $USE_EXPANSION_INTERFACE GROUP "Interface Enables"

add_parameter $AV_CONSTANT_BURST_BEHAVIOR Integer 1 
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR DISPLAY_NAME "Constant burst behavior"
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR AFFECTS_ELABORATION true
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR DESCRIPTION "Constant burst behavior"
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR DISPLAY_HINT boolean
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR HDL_PARAMETER true
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR GROUP "Burst Attributes"


add_parameter $AV_BURST_LINEWRAP Integer 0
set_parameter_property $AV_BURST_LINEWRAP DISPLAY_NAME "Linewrap bursts"
set_parameter_property $AV_BURST_LINEWRAP AFFECTS_ELABORATION true
set_parameter_property $AV_BURST_LINEWRAP DESCRIPTION "Linewrap bursts"
set_parameter_property $AV_BURST_LINEWRAP DISPLAY_HINT boolean
set_parameter_property $AV_BURST_LINEWRAP HDL_PARAMETER true
set_parameter_property $AV_BURST_LINEWRAP GROUP "Burst Attributes"

add_parameter $AV_BURST_BNDR_ONLY Integer 0
set_parameter_property $AV_BURST_BNDR_ONLY DISPLAY_NAME "Burst on Burst Boundaries only"
set_parameter_property $AV_BURST_BNDR_ONLY AFFECTS_ELABORATION true
set_parameter_property $AV_BURST_BNDR_ONLY DESCRIPTION "Burst on boundaries only"
set_parameter_property $AV_BURST_BNDR_ONLY DISPLAY_HINT boolean
set_parameter_property $AV_BURST_BNDR_ONLY HDL_PARAMETER true
set_parameter_property $AV_BURST_BNDR_ONLY GROUP "Burst Attributes"

add_parameter $AV_READ_TIMEOUT Integer 100
set_parameter_property $AV_READ_TIMEOUT DISPLAY_NAME "Read response timeout (cycles)"
set_parameter_property $AV_READ_TIMEOUT AFFECTS_ELABORATION true
set_parameter_property $AV_READ_TIMEOUT DESCRIPTION "Read response timeout (cycles)"
set_parameter_property $AV_READ_TIMEOUT HDL_PARAMETER true
set_parameter_property $AV_READ_TIMEOUT GROUP "Miscellaneous"

add_parameter $AV_WRITE_TIMEOUT Integer 100
set_parameter_property $AV_WRITE_TIMEOUT DISPLAY_NAME "Write burst timeout (cycles)"
set_parameter_property $AV_WRITE_TIMEOUT AFFECTS_ELABORATION true
set_parameter_property $AV_WRITE_TIMEOUT DESCRIPTION "Write burst command timeout cycles"
set_parameter_property $AV_WRITE_TIMEOUT HDL_PARAMETER true
set_parameter_property $AV_WRITE_TIMEOUT GROUP "Miscellaneous"

add_parameter $AV_WAITREQUEST_TIMEOUT Integer 1024
set_parameter_property $AV_WAITREQUEST_TIMEOUT DISPLAY_NAME "Waitrequest timeout (cycles)"
set_parameter_property $AV_WAITREQUEST_TIMEOUT AFFECTS_ELABORATION true
set_parameter_property $AV_WAITREQUEST_TIMEOUT DESCRIPTION "Waitrequest timeout (cycles)"
set_parameter_property $AV_WAITREQUEST_TIMEOUT HDL_PARAMETER true
set_parameter_property $AV_WAITREQUEST_TIMEOUT GROUP "Miscellaneous"

add_parameter $AV_MAX_PENDING_READS Integer 1
set_parameter_property $AV_MAX_PENDING_READS DISPLAY_NAME "Maximum pending reads"
set_parameter_property $AV_MAX_PENDING_READS AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_PENDING_READS DESCRIPTION "Maximum pending read transactions"
set_parameter_property $AV_MAX_PENDING_READS HDL_PARAMETER true
set_parameter_property $AV_MAX_PENDING_READS GROUP "Miscellaneous"

add_parameter $AV_MAX_PENDING_WRITES Integer 0
set_parameter_property $AV_MAX_PENDING_WRITES DISPLAY_NAME "Maximum pending writes"
set_parameter_property $AV_MAX_PENDING_WRITES AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_PENDING_WRITES DESCRIPTION "Maximum pending write transactions"
set_parameter_property $AV_MAX_PENDING_WRITES HDL_PARAMETER true
set_parameter_property $AV_MAX_PENDING_WRITES GROUP "Miscellaneous"
set_parameter_property $AV_MAX_PENDING_WRITES VISIBLE false

add_parameter $AV_FIX_READ_LATENCY Integer 0
set_parameter_property $AV_FIX_READ_LATENCY DISPLAY_NAME "Fixed read latency (cycles)"
set_parameter_property $AV_FIX_READ_LATENCY AFFECTS_ELABORATION true
set_parameter_property $AV_FIX_READ_LATENCY DESCRIPTION "Fixed read latency in cycles"
set_parameter_property $AV_FIX_READ_LATENCY ALLOWED_RANGES {0:63}
set_parameter_property $AV_FIX_READ_LATENCY HDL_PARAMETER true
set_parameter_property $AV_FIX_READ_LATENCY GROUP "Miscellaneous"

add_parameter $AV_MAX_READ_LATENCY Integer 100
set_parameter_property $AV_MAX_READ_LATENCY DISPLAY_NAME "Maximum read latency (cycles)"
set_parameter_property $AV_MAX_READ_LATENCY AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_READ_LATENCY DESCRIPTION "Maximum read latency for coverage (cycles) "
set_parameter_property $AV_MAX_READ_LATENCY HDL_PARAMETER true
set_parameter_property $AV_MAX_READ_LATENCY GROUP "Miscellaneous"

add_parameter $AV_MAX_WAITREQUESTED_READ Integer 100
set_parameter_property $AV_MAX_WAITREQUESTED_READ DISPLAY_NAME "Maximum waitrequest read cycles (for coverage)"
set_parameter_property $AV_MAX_WAITREQUESTED_READ AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_WAITREQUESTED_READ DESCRIPTION "Maximum waitrequest read cycles (for coverage)"
set_parameter_property $AV_MAX_WAITREQUESTED_READ HDL_PARAMETER true
set_parameter_property $AV_MAX_WAITREQUESTED_READ GROUP "Miscellaneous"

add_parameter $AV_MAX_WAITREQUESTED_WRITE Integer 100
set_parameter_property $AV_MAX_WAITREQUESTED_WRITE DISPLAY_NAME "Maximum waitrequest write cycles (for coverage)"
set_parameter_property $AV_MAX_WAITREQUESTED_WRITE AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_WAITREQUESTED_WRITE DESCRIPTION "Maximum waitrequest write cycles (for coverage)"
set_parameter_property $AV_MAX_WAITREQUESTED_WRITE HDL_PARAMETER true
set_parameter_property $AV_MAX_WAITREQUESTED_WRITE GROUP "Miscellaneous"

add_parameter $MASTER_ADDRESS_TYPE String "SYMBOLS"
set_parameter_property $MASTER_ADDRESS_TYPE DISPLAY_NAME "Set master interface address type to symbols or words"
set_parameter_property $MASTER_ADDRESS_TYPE AFFECTS_ELABORATION true
set_parameter_property $MASTER_ADDRESS_TYPE DESCRIPTION "Set master interface address type to symbols or words"
set_parameter_property $MASTER_ADDRESS_TYPE ALLOWED_RANGES {"SYMBOLS" "WORDS"}
set_parameter_property $MASTER_ADDRESS_TYPE HDL_PARAMETER true
set_parameter_property $MASTER_ADDRESS_TYPE VISIBLE false
set_parameter_property $MASTER_ADDRESS_TYPE GROUP "Interface Address Type"

add_parameter $SLAVE_ADDRESS_TYPE String "WORDS"
set_parameter_property $SLAVE_ADDRESS_TYPE DISPLAY_NAME "Set slave interface address type"
set_parameter_property $SLAVE_ADDRESS_TYPE AFFECTS_ELABORATION true
set_parameter_property $SLAVE_ADDRESS_TYPE DESCRIPTION "Set slave interface address type"
set_parameter_property $SLAVE_ADDRESS_TYPE ALLOWED_RANGES {"SYMBOLS" "WORDS"}
set_parameter_property $SLAVE_ADDRESS_TYPE HDL_PARAMETER true
set_parameter_property $SLAVE_ADDRESS_TYPE VISIBLE false
set_parameter_property $SLAVE_ADDRESS_TYPE GROUP "Interface Address Type"

add_parameter $VHDL_ID Integer 0
set_parameter_property $VHDL_ID DISPLAY_NAME "VHDL BFM ID"
set_parameter_property $VHDL_ID DESCRIPTION "BFM ID number for VHDL"
set_parameter_property $VHDL_ID HDL_PARAMETER true
set_parameter_property $VHDL_ID ALLOWED_RANGES {0:1023}
set_parameter_property $VHDL_ID GROUP "VHDL BFM"

add_parameter $AV_READRESPONSE_W Integer 8
set_parameter_property $AV_READRESPONSE_W DISPLAY_NAME "readresponse width"
set_parameter_property $AV_READRESPONSE_W AFFECTS_ELABORATION true
set_parameter_property $AV_READRESPONSE_W DESCRIPTION "The width of the readresponse signal."
set_parameter_property $AV_READRESPONSE_W HDL_PARAMETER true
set_parameter_property $AV_READRESPONSE_W GROUP "Port Widths"
set_parameter_property $AV_READRESPONSE_W VISIBLE false

add_parameter $AV_WRITERESPONSE_W Integer 8
set_parameter_property $AV_WRITERESPONSE_W DISPLAY_NAME "writeresponse width"
set_parameter_property $AV_WRITERESPONSE_W AFFECTS_ELABORATION true
set_parameter_property $AV_WRITERESPONSE_W DESCRIPTION "The width of the writeresponse signal."
set_parameter_property $AV_WRITERESPONSE_W HDL_PARAMETER true
set_parameter_property $AV_WRITERESPONSE_W GROUP "Port Widths"
set_parameter_property $AV_WRITERESPONSE_W VISIBLE false

add_parameter $USE_ARBITERLOCK Integer 0
set_parameter_property $USE_ARBITERLOCK DISPLAY_NAME "Use the arbiterlock signal"
set_parameter_property $USE_ARBITERLOCK AFFECTS_ELABORATION true
set_parameter_property $USE_ARBITERLOCK DESCRIPTION "Use arbiterlock port"
set_parameter_property $USE_ARBITERLOCK DISPLAY_HINT boolean
set_parameter_property $USE_ARBITERLOCK HDL_PARAMETER true
set_parameter_property $USE_ARBITERLOCK GROUP "Port Enables"

add_parameter $USE_LOCK Integer 0 
set_parameter_property $USE_LOCK DISPLAY_NAME "Use the lock signal"
set_parameter_property $USE_LOCK AFFECTS_ELABORATION true
set_parameter_property $USE_LOCK DESCRIPTION "Use the lock signal"
set_parameter_property $USE_LOCK DISPLAY_HINT boolean
set_parameter_property $USE_LOCK HDL_PARAMETER true
set_parameter_property $USE_LOCK GROUP "Port Enables"

add_parameter $USE_DEBUGACCESS Integer 0
set_parameter_property $USE_DEBUGACCESS DISPLAY_NAME "Use the debugaccess signal"
set_parameter_property $USE_DEBUGACCESS AFFECTS_ELABORATION true
set_parameter_property $USE_DEBUGACCESS DESCRIPTION "Use debugaccess port"
set_parameter_property $USE_DEBUGACCESS DISPLAY_HINT boolean
set_parameter_property $USE_DEBUGACCESS HDL_PARAMETER true
set_parameter_property $USE_DEBUGACCESS GROUP "Port Enables"

add_parameter $USE_TRANSACTIONID Integer 0
set_parameter_property $USE_TRANSACTIONID DISPLAY_NAME "Use the transactionid signal"
set_parameter_property $USE_TRANSACTIONID AFFECTS_ELABORATION true
set_parameter_property $USE_TRANSACTIONID DESCRIPTION "Use transactionid port"
set_parameter_property $USE_TRANSACTIONID DISPLAY_HINT boolean
set_parameter_property $USE_TRANSACTIONID HDL_PARAMETER true
set_parameter_property $USE_TRANSACTIONID GROUP "Port Enables"
set_parameter_property $USE_TRANSACTIONID VISIBLE false

add_parameter $USE_WRITERESPONSE Integer 0
set_parameter_property $USE_WRITERESPONSE DISPLAY_NAME "Use the writeresponse signal"
set_parameter_property $USE_WRITERESPONSE AFFECTS_ELABORATION true
set_parameter_property $USE_WRITERESPONSE DESCRIPTION "Use writeresponse port"
set_parameter_property $USE_WRITERESPONSE DISPLAY_HINT boolean
set_parameter_property $USE_WRITERESPONSE HDL_PARAMETER true
set_parameter_property $USE_WRITERESPONSE GROUP "Port Enables"
set_parameter_property $USE_WRITERESPONSE VISIBLE false

add_parameter $USE_READRESPONSE Integer 0
set_parameter_property $USE_READRESPONSE DISPLAY_NAME "Use the readresponse signal"
set_parameter_property $USE_READRESPONSE AFFECTS_ELABORATION true
set_parameter_property $USE_READRESPONSE DESCRIPTION "Use readresponse port"
set_parameter_property $USE_READRESPONSE DISPLAY_HINT boolean
set_parameter_property $USE_READRESPONSE HDL_PARAMETER true
set_parameter_property $USE_READRESPONSE GROUP "Port Enables"
set_parameter_property $USE_READRESPONSE VISIBLE false

add_parameter $USE_CLKEN Integer 0 
set_parameter_property $USE_CLKEN DISPLAY_NAME "Use the clken signals"
set_parameter_property $USE_CLKEN AFFECTS_ELABORATION true
set_parameter_property $USE_CLKEN DESCRIPTION "Use the tightly coupled memory signals"
set_parameter_property $USE_CLKEN DISPLAY_HINT boolean
set_parameter_property $USE_CLKEN HDL_PARAMETER true
set_parameter_property $USE_CLKEN GROUP "Port Enables"

add_parameter $AV_MAX_CONTINUOUS_READ Integer 5
set_parameter_property $AV_MAX_CONTINUOUS_READ DISPLAY_NAME "Maximum continuous read (cycles)"
set_parameter_property $AV_MAX_CONTINUOUS_READ AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_CONTINUOUS_READ DESCRIPTION "Maximum continuous read for coverage (cycles) "
set_parameter_property $AV_MAX_CONTINUOUS_READ HDL_PARAMETER true
set_parameter_property $AV_MAX_CONTINUOUS_READ GROUP "Miscellaneous"

add_parameter $AV_MAX_CONTINUOUS_WRITE Integer 5
set_parameter_property $AV_MAX_CONTINUOUS_WRITE DISPLAY_NAME "Maximum continuous write (cycles)"
set_parameter_property $AV_MAX_CONTINUOUS_WRITE AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_CONTINUOUS_WRITE DESCRIPTION "Maximum continuous write for coverage (cycles) "
set_parameter_property $AV_MAX_CONTINUOUS_WRITE HDL_PARAMETER true
set_parameter_property $AV_MAX_CONTINUOUS_WRITE GROUP "Miscellaneous"

add_parameter $AV_MAX_CONTINUOUS_WAITREQUEST Integer 5
set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST DISPLAY_NAME "Maximum continuous waitrequest (cycles)"
set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST DESCRIPTION "Maximum continuous waitrequest for coverage (cycles) "
set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST HDL_PARAMETER true
set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST GROUP "Miscellaneous"

add_parameter $AV_MAX_CONTINUOUS_READDATAVALID Integer 5
set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID DISPLAY_NAME "Maximum continuous readdatavalid (cycles)"
set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID DESCRIPTION "Maximum continuous readdatavalid for coverage (cycles) "
set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID HDL_PARAMETER true
set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID GROUP "Miscellaneous"

add_parameter $AV_READ_WAIT_TIME Integer 1 
set_parameter_property $AV_READ_WAIT_TIME DISPLAY_NAME "Fixed read wait time (cycles)"
set_parameter_property $AV_READ_WAIT_TIME AFFECTS_ELABORATION true
set_parameter_property $AV_READ_WAIT_TIME HDL_PARAMETER true
set_parameter_property $AV_READ_WAIT_TIME DESCRIPTION "Fixed read wait time (cycles)"
set_parameter_property $AV_READ_WAIT_TIME GROUP "Timing" 

add_parameter $AV_WRITE_WAIT_TIME Integer 0 
set_parameter_property $AV_WRITE_WAIT_TIME DISPLAY_NAME "Fixed write wait time (cycles)"
set_parameter_property $AV_WRITE_WAIT_TIME AFFECTS_ELABORATION true
set_parameter_property $AV_WRITE_WAIT_TIME HDL_PARAMETER true
set_parameter_property $AV_WRITE_WAIT_TIME DESCRIPTION "Fixed write wait time (cycles)"
set_parameter_property $AV_WRITE_WAIT_TIME GROUP "Timing" 

add_parameter $REGISTER_WAITREQUEST Integer 0 
set_parameter_property $REGISTER_WAITREQUEST DISPLAY_NAME "Registered waitrequest"
set_parameter_property $REGISTER_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property $REGISTER_WAITREQUEST HDL_PARAMETER true
set_parameter_property $REGISTER_WAITREQUEST DESCRIPTION "Add one pipeline stage to the waitrequest to improve timing."
set_parameter_property $REGISTER_WAITREQUEST DISPLAY_HINT boolean
set_parameter_property $REGISTER_WAITREQUEST GROUP "Timing" 

add_parameter $AV_REGISTERINCOMINGSIGNALS Integer 0 
set_parameter_property $AV_REGISTERINCOMINGSIGNALS DISPLAY_NAME "Registered Incoming Signals"
set_parameter_property $AV_REGISTERINCOMINGSIGNALS AFFECTS_ELABORATION true
set_parameter_property $AV_REGISTERINCOMINGSIGNALS HDL_PARAMETER true
set_parameter_property $AV_REGISTERINCOMINGSIGNALS DESCRIPTION "Indicate that incoming signals come from register."
set_parameter_property $AV_REGISTERINCOMINGSIGNALS DISPLAY_HINT boolean
set_parameter_property $AV_REGISTERINCOMINGSIGNALS GROUP "Timing" 

#---------------------------------------------------------------------
proc log2 {value} {
      set value [expr $value-1]
      for {set log2 0} {$value>0} {incr log2} {
         set value  [expr $value>>1]
      }
      return $log2;
}

#---------------------------------------------------------------------
proc validate {} {
    global USE_READ
    global USE_WRITE
    global USE_BYTE_ENABLE
    global USE_BURSTCOUNT
    global USE_READ_DATA
    global USE_READ_DATA_VALID
    global USE_WRITE_DATA
    global USE_BEGIN_BURST_TRANSFER
    global USE_WAIT_REQUEST

    global AV_READ_TIMEOUT
    global AV_WRITE_TIMEOUT
    global AV_WAITREQUEST_TIMEOUT
    global AV_MAX_PENDING_READS
    global AV_FIX_READ_LATENCY
    global AV_MAX_READ_LATENCY
    global AV_MAX_WAITREQUESTED_READ
    global AV_MAX_WAITREQUESTED_WRITE
    
    global MASTER_ADDRESS_TYPE
    global SLAVE_ADDRESS_TYPE
    
    global AV_READRESPONSE_W
    global AV_WRITERESPONSE_W
    global USE_ARBITERLOCK
    global USE_LOCK
    global USE_DEBUGACCESS
    global USE_TRANSACTIONID
    global USE_WRITERESPONSE
    global USE_READRESPONSE
    global AV_MAX_CONTINUOUS_READ
    global AV_MAX_CONTINUOUS_WRITE
    global AV_MAX_CONTINUOUS_WAITREQUEST
    global AV_MAX_CONTINUOUS_READDATAVALID
    
    global AV_READ_WAIT_TIME   
    global AV_WRITE_WAIT_TIME  
    
    global REGISTER_WAITREQUEST
    global AV_REGISTERINCOMINGSIGNALS
   
   if {[get_parameter $AV_READRESPONSE_W] != 8} {
      send_message warning "This parameter is no longer supported."
   }
   
   if {[get_parameter $AV_WRITERESPONSE_W] != 8} {
      send_message warning "This parameter is no longer supported."
   }
   
    if { [get_parameter $USE_READ] == 0 } {
        if { [get_parameter $USE_READ_DATA] == 1 } {
        send_message error "The readdata port can only be used with read port."
        }
        if { [get_parameter $USE_READRESPONSE] == 1 } {
        send_message error "The read response can only be enabled with read port."
        }
        if { [get_parameter $USE_READ_DATA_VALID] == 1 } {
        send_message error "The readdatavalid port can only be used with read port."
        }
        if { [get_parameter $AV_READ_TIMEOUT] > 0 } {
        send_message Info "AV_READ_TIMEOUT parameter can only be used with read port."
        }
        if { [get_parameter $AV_MAX_PENDING_READS] > 0 } {
        send_message Info "AV_MAX_PENDING_READS parameter can only be used with read port."
        }
        if { [get_parameter $AV_MAX_READ_LATENCY] > 0 } {
        send_message Info "AV_MAX_READ_LATENCY parameter can only be used with read port."
        }
        if { [get_parameter $AV_MAX_WAITREQUESTED_READ] > 0 } {
        send_message Info "AV_MAX_WAITREQUESTED_READ parameter can only be used with read port."
        }
    }

    if { [get_parameter $USE_WRITE] == 0 } {
        if { [get_parameter $USE_WRITE_DATA] == 1 } {
        send_message error "The writedata port can only be used with write port."
        }
        if { [get_parameter $USE_WRITERESPONSE] == 1 } {
        send_message error "The write response can only be enabled with write port."
        }
        if { [get_parameter $AV_WRITE_TIMEOUT] > 0 } {
        send_message Info "AV_WRITE_TIMEOUT parameter can only be used with write port."
        }
        if { [get_parameter $AV_MAX_WAITREQUESTED_WRITE] > 0 } {
        send_message Info "AV_MAX_WAITREQUESTED_WRITE parameter can only be used with write port."
        }
        if { [get_parameter $AV_MAX_PENDING_WRITES] > 0 } {
        send_message Info "AV_MAX_PENDING_WRITES parameter can only be used with write port."
        }
    }

    if { [get_parameter $USE_BURSTCOUNT] == 0 } {
        if { [get_parameter $USE_BEGIN_BURST_TRANSFER] == 1 } {
        send_message error "The beginbursttransfer port can only be used with burst transfer."
        }
        if { [get_parameter $AV_WRITE_TIMEOUT] > 0 } {
        send_message Info "AV_WRITE_TIMEOUT parameter can only be used with burst transfer."
        }
    }

    if { [get_parameter $USE_READ_DATA] == 0 } {
        if { [get_parameter $USE_READ] == 1 } {
        send_message error "The read port can only be used with readdata port."
        }
    }

    if {[get_parameter $USE_READ_DATA_VALID] == 0 } {
        if { [get_parameter $USE_READ] == 1 && [get_parameter $USE_BURSTCOUNT] == 1 } {
        send_message error "The read and burstcount port can only be used with readdatavalid port."
        }
        if { [get_parameter $AV_READ_TIMEOUT] > 0 } {
        send_message Info "AV_READ_TIMEOUT can only be used with readdatavalid port."
        }
        if { [get_parameter $AV_MAX_READ_LATENCY] > 0 } {
        send_message Info "AV_MAX_READ_LATENCY parameter can only be used with readdatavalid port."
        }
    }

    if { [get_parameter $USE_WRITE_DATA] == 0 } {
        if { [get_parameter $USE_WRITE] == 1 } {
        send_message error "The write port can only be used with writedata port."
        }
    }

    if {[get_parameter $USE_WAIT_REQUEST] == 0 } {
        if { [get_parameter $AV_WAITREQUEST_TIMEOUT] > 0 } {
        send_message Info "AV_WAITREQUEST_TIMEOUT parameter can only be used with waitrequest port."
        }
        if { [get_parameter $AV_MAX_WAITREQUESTED_READ] > 0 } {
        send_message Info "AV_MAX_WAITREQUESTED_READ parameter can only be used with waitrequest port."
        }
        if { [get_parameter $AV_MAX_WAITREQUESTED_WRITE] > 0 } {
        send_message Info "AV_MAX_WAITREQUESTED_WRITE parameter can only be used with waitrequest port."
        }
    }

    if {[get_parameter $AV_READ_TIMEOUT] <= 0 && [get_parameter $USE_READ] == 1 } {
    send_message error "AV_READ_TIMEOUT must be greater than 0."
    }

    if { [get_parameter $AV_WRITE_TIMEOUT] <= 0 && [get_parameter $USE_WRITE] == 1} {
    send_message error "AV_WRITE_TIMEOUT must be greater than 0"
    }

    if { [get_parameter $AV_WAITREQUEST_TIMEOUT] < 0 } {
    send_message error "AV_WAITREQUEST_TIMEOUT must be equal or greater than 0"
    }

    if { [get_parameter $AV_FIX_READ_LATENCY] < 0 } {
    send_message error "AV_FIX_READ_LATENCY must be equal or greater than 0"
    }

    if { [get_parameter $AV_MAX_WAITREQUESTED_READ] < 0 } {
    send_message error "AV_MAX_WAITREQUESTED_READ must be equal or greater than 0"
    }

    if { [get_parameter $AV_MAX_WAITREQUESTED_WRITE] < 0 } {
    send_message error "AV_MAX_WAITREQUESTED_WRITE must be equal or greater than 0"
    }
    
    if { [get_parameter $AV_MAX_CONTINUOUS_READ] < 2 } {
    send_message error "AV_MAX_CONTINUOUS_READ must be equal or greater than 2"
    }
    
    if { [get_parameter $AV_MAX_CONTINUOUS_WRITE] < 2 } {
    send_message error "AV_MAX_CONTINUOUS_WRITE must be equal or greater than 2"
    }
    
    if { [get_parameter $AV_MAX_CONTINUOUS_WAITREQUEST] < 2 } {
    send_message error "AV_MAX_CONTINUOUS_WAITREQUEST must be equal or greater than 2"
    }
    
    if { [get_parameter $AV_MAX_CONTINUOUS_READDATAVALID] < 2 } {
    send_message error "AV_MAX_CONTINUOUS_READDATAVALID must be equal or greater than 2"
    }
    
    if { [get_parameter $AV_REGISTERINCOMINGSIGNALS] == 1 } {
        if { [get_parameter $USE_READ_DATA_VALID] == 1 } {
        send_message error "readdatavalid signal must not be present when AV_REGISTERINCOMINGSIGNALS is true."
        }
        if { [get_parameter $USE_WAIT_REQUEST] == 0 } {
        send_message error "waitrequest signal must be present when AV_REGISTERINCOMINGSIGNALS is true."
        }
    }
}
#---------------------------------------------------------------------
proc elaborate {} {
    global AV_ADDRESS_W
    global AV_SYMBOL_W
    global AV_NUMSYMBOLS
    global AV_BURSTCOUNT_W

    global USE_READ
    global USE_WRITE
    global USE_ADDRESS
    global USE_BYTE_ENABLE
    global USE_BURSTCOUNT
    global USE_READ_DATA
    global USE_READ_DATA_VALID
    global USE_WRITE_DATA
    global USE_BEGIN_TRANSFER
    global USE_BEGIN_BURST_TRANSFER
    global USE_WAIT_REQUEST

    global AV_CONSTANT_BURST_BEHAVIOR
    global AV_BURST_LINEWRAP
    global AV_BURST_BNDR_ONLY

    global AV_READ_TIMEOUT
    global AV_WRITE_TIMEOUT
    global AV_WAITREQUEST_TIMEOUT  
    global AV_MAX_PENDING_READS
    global AV_MAX_PENDING_WRITES
    global AV_FIX_READ_LATENCY
    global AV_MAX_READ_LATENCY
    global AV_MAX_WAITREQUESTED_READ
    global AV_MAX_WAITREQUESTED_WRITE
    
    global MASTER_ADDRESS_TYPE
    global SLAVE_ADDRESS_TYPE
    
    global AV_READRESPONSE_W
    global AV_WRITERESPONSE_W
    global USE_ARBITERLOCK
    global USE_LOCK
    global USE_DEBUGACCESS
    global USE_TRANSACTIONID
    global USE_WRITERESPONSE
    global USE_READRESPONSE
    global USE_CLKEN 
    
    global AV_MAX_CONTINUOUS_READ
    global AV_MAX_CONTINUOUS_WRITE
    global AV_MAX_CONTINUOUS_WAITREQUEST
    global AV_MAX_CONTINUOUS_READDATAVALID
    
    global AV_READ_WAIT_TIME   
    global AV_WRITE_WAIT_TIME 
    
    global REGISTER_WAITREQUEST
    global AV_REGISTERINCOMINGSIGNALS

    set AV_ADDRESS_W_VALUE                     [ get_parameter $AV_ADDRESS_W ]
    set AV_SYMBOL_W_VALUE                      [ get_parameter $AV_SYMBOL_W ]
    set AV_NUMSYMBOLS_VALUE                    [ get_parameter $AV_NUMSYMBOLS ]
    set AV_BURSTCOUNT_W_VALUE                  [ get_parameter $AV_BURSTCOUNT_W ]

    set USE_READ_VALUE                         [ get_parameter $USE_READ ]
    set USE_WRITE_VALUE                        [ get_parameter $USE_WRITE ]
    set USE_ADDRESS_VALUE                      [ get_parameter $USE_ADDRESS ]
    set USE_BYTE_ENABLE_VALUE                  [ get_parameter $USE_BYTE_ENABLE ]
    set USE_BURSTCOUNT_VALUE                   [ get_parameter $USE_BURSTCOUNT ]
    set USE_READ_DATA_VALUE                    [ get_parameter $USE_READ_DATA ]
    set USE_READ_DATA_VALID_VALUE              [ get_parameter $USE_READ_DATA_VALID ]
    set USE_WRITE_DATA_VALUE                   [ get_parameter $USE_WRITE_DATA ]
    set USE_BEGIN_TRANSFER_VALUE               [ get_parameter $USE_BEGIN_TRANSFER ]
    set USE_BEGIN_BURST_TRANSFER_VALUE         [ get_parameter $USE_BEGIN_BURST_TRANSFER ]
    set USE_WAIT_REQUEST_VALUE                 [ get_parameter $USE_WAIT_REQUEST ]

    set AV_CONSTANT_BURST_BEHAVIOR_VALUE       [ get_parameter $AV_CONSTANT_BURST_BEHAVIOR ] 
    set AV_BURST_LINEWRAP_VALUE                [ get_parameter $AV_BURST_LINEWRAP ]
    set AV_BURST_BNDR_ONLY_VALUE               [ get_parameter $AV_BURST_BNDR_ONLY ]

    set AV_READ_TIMEOUT_VALUE                  [ get_parameter $AV_READ_TIMEOUT ]
    set AV_WRITE_TIMEOUT_VALUE                 [ get_parameter $AV_WRITE_TIMEOUT ]
    set AV_WAITREQUEST_TIMEOUT_VALUE           [ get_parameter $AV_WAITREQUEST_TIMEOUT ]
    set AV_MAX_PENDING_READS_VALUE             [ get_parameter $AV_MAX_PENDING_READS ]
    set AV_MAX_PENDING_WRITES_VALUE            [ get_parameter $AV_MAX_PENDING_WRITES ]
    set AV_FIX_READ_LATENCY_VALUE              [ get_parameter $AV_FIX_READ_LATENCY ]
    set AV_MAX_READ_LATENCY_VALUE              [ get_parameter $AV_MAX_READ_LATENCY ]
    set AV_MAX_WAITREQUESTED_READ_VALUE        [ get_parameter $AV_MAX_WAITREQUESTED_READ ]
    set AV_MAX_WAITREQUESTED_WRITE_VALUE       [ get_parameter $AV_MAX_WAITREQUESTED_WRITE ]
    
    set MASTER_ADDRESS_TYPE_VALUE              [ get_parameter $MASTER_ADDRESS_TYPE ]
    set SLAVE_ADDRESS_TYPE_VALUE               [ get_parameter $SLAVE_ADDRESS_TYPE ]

    set AV_READRESPONSE_W_VALUE                [ get_parameter $AV_READRESPONSE_W ]
    set AV_WRITERESPONSE_W_VALUE               [ get_parameter $AV_WRITERESPONSE_W ]
    set USE_ARBITERLOCK_VALUE                  [ get_parameter $USE_ARBITERLOCK ]
    set USE_LOCK_VALUE                         [ get_parameter $USE_LOCK ] 
    set USE_DEBUGACCESS_VALUE                  [ get_parameter $USE_DEBUGACCESS ]
    set USE_TRANSACTIONID_VALUE                [ get_parameter $USE_TRANSACTIONID ]
    set USE_WRITERESPONSE_VALUE                [ get_parameter $USE_WRITERESPONSE ]
    set USE_READRESPONSE_VALUE                 [ get_parameter $USE_READRESPONSE ]
    set USE_CLKEN_VALUE                        [ get_parameter $USE_CLKEN ] 
    
    set AV_MAX_CONTINUOUS_READ_VALUE           [ get_parameter $AV_MAX_CONTINUOUS_READ ]
    set AV_MAX_CONTINUOUS_WRITE_VALUE          [ get_parameter $AV_MAX_CONTINUOUS_WRITE ]
    set AV_MAX_CONTINUOUS_WAITREQUEST_VALUE    [ get_parameter $AV_MAX_CONTINUOUS_WAITREQUEST ]
    set AV_MAX_CONTINUOUS_READDATAVALID_VALUE  [ get_parameter $AV_MAX_CONTINUOUS_READDATAVALID ]
    
    set AV_READ_WAIT_TIME_VALUE                [ get_parameter $AV_READ_WAIT_TIME ]  
    set AV_WRITE_WAIT_TIME_VALUE               [ get_parameter $AV_WRITE_WAIT_TIME ]   
    
    set REGISTER_WAITREQUEST_VALUE             [ get_parameter $REGISTER_WAITREQUEST ] 
    set AV_REGISTERINCOMINGSIGNALS_VALUE       [ get_parameter $AV_REGISTERINCOMINGSIGNALS ] 
    set AV_TRANSACTIONID_W_VALUE               8
    set AV_DATA_W_VALUE                        [ expr {$AV_SYMBOL_W_VALUE * $AV_NUMSYMBOLS_VALUE}]

    # Interface Names
    #---------------------------------------------------------------------
    set CLOCK_INTERFACE   "clk"
    set SLAVE_INTERFACE   "s0"
    set MASTER_INTERFACE  "m0"

    # Clock connection point
    #---------------------------------------------------------------------
    add_interface $CLOCK_INTERFACE clock end
    set_interface_property $CLOCK_INTERFACE ptfSchematicName ""
    set_interface_property $CLOCK_INTERFACE ENABLED true
    add_interface_port $CLOCK_INTERFACE clk clk Input 1
    add_interface_port $CLOCK_INTERFACE reset reset Input 1

    # Avalon Slave connection point
    #---------------------------------------------------------------------
    add_interface $SLAVE_INTERFACE avalon end
    set_interface_property $SLAVE_INTERFACE ENABLED true
    set_interface_property $SLAVE_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $SLAVE_INTERFACE addressAlignment DYNAMIC
    set_interface_property $SLAVE_INTERFACE holdTime 0
    set_interface_property $SLAVE_INTERFACE isMemoryDevice false
    set_interface_property $SLAVE_INTERFACE isNonVolatileStorage false
    set_interface_property $SLAVE_INTERFACE minimumUninterruptedRunLength 1
    set_interface_property $SLAVE_INTERFACE printableDevice false
    set_interface_property $SLAVE_INTERFACE readWaitTime $AV_READ_WAIT_TIME_VALUE
    set_interface_property $SLAVE_INTERFACE setupTime 0
    set_interface_property $SLAVE_INTERFACE timingUnits Cycles
    set_interface_property $SLAVE_INTERFACE writeWaitTime $AV_WRITE_WAIT_TIME_VALUE
    set_interface_property $SLAVE_INTERFACE addressUnits $SLAVE_ADDRESS_TYPE_VALUE
    
    set_interface_property $SLAVE_INTERFACE bridgesToMaster $MASTER_INTERFACE

    # Avalon Master connection point 
    #---------------------------------------------------------------------
    add_interface $MASTER_INTERFACE avalon start
    set_interface_property $MASTER_INTERFACE ENABLED true
    set_interface_property $MASTER_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $MASTER_INTERFACE doStreamReads false
    set_interface_property $MASTER_INTERFACE doStreamWrites false
    set_interface_property $MASTER_INTERFACE addressUnits $MASTER_ADDRESS_TYPE_VALUE
    set_interface_property $MASTER_INTERFACE writeWaitTime $AV_WRITE_WAIT_TIME_VALUE
    set_interface_property $MASTER_INTERFACE readWaitTime $AV_READ_WAIT_TIME_VALUE
    
    # More Interface Properties
    #---------------------------------------------------------------------
    if { $AV_BURST_LINEWRAP_VALUE > 0 } {
   set_interface_property $SLAVE_INTERFACE linewrapBursts true
   set_interface_property $MASTER_INTERFACE linewrapBursts true
    } else {
   set_interface_property $SLAVE_INTERFACE linewrapBursts false
   set_interface_property $MASTER_INTERFACE linewrapBursts false
    }
    if { $AV_BURST_BNDR_ONLY_VALUE > 0 } {
   set_interface_property $SLAVE_INTERFACE burstOnBurstBoundariesOnly true
   set_interface_property $MASTER_INTERFACE burstOnBurstBoundariesOnly true
    } else {
   set_interface_property $SLAVE_INTERFACE burstOnBurstBoundariesOnly false
   set_interface_property $MASTER_INTERFACE burstOnBurstBoundariesOnly false
    }
    
    if { $AV_REGISTERINCOMINGSIGNALS_VALUE == 0 } {
      set_interface_property $SLAVE_INTERFACE registerIncomingSignals false
      set_interface_property $MASTER_INTERFACE registerIncomingSignals false
   } else {
      set_interface_property $SLAVE_INTERFACE registerIncomingSignals true
      set_interface_property $MASTER_INTERFACE registerIncomingSignals false
   }
   
    # Grey out unused parameters
    #---------------------------------------------------------------------
    if {$USE_WAIT_REQUEST_VALUE == 0} {
        set_parameter_property $AV_READ_WAIT_TIME ENABLED true
        set_parameter_property $AV_WRITE_WAIT_TIME ENABLED true
        set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST ENABLED false
    } else {
        set_parameter_property $AV_READ_WAIT_TIME ENABLED false
        set_parameter_property $AV_WRITE_WAIT_TIME ENABLED false
        set_parameter_property $AV_MAX_CONTINUOUS_WAITREQUEST ENABLED true
    }
    
    if {$USE_READ_VALUE == 0} {
        set_interface_property $SLAVE_INTERFACE maximumPendingReadTransactions 0
        set_interface_property $MASTER_INTERFACE maximumPendingReadTransactions 0
        set_parameter_property $AV_MAX_PENDING_READS ENABLED false
        set_parameter_property $AV_MAX_CONTINUOUS_READ ENABLED false
        set_parameter_property $AV_MAX_WAITREQUESTED_READ ENABLED false
    } else {
        set_interface_property $SLAVE_INTERFACE maximumPendingReadTransactions $AV_MAX_PENDING_READS_VALUE
        set_interface_property $MASTER_INTERFACE maximumPendingReadTransactions $AV_MAX_PENDING_READS_VALUE
        set_parameter_property $AV_MAX_PENDING_READS ENABLED true
        set_parameter_property $AV_MAX_CONTINUOUS_READ ENABLED true
        
        if {$USE_WAIT_REQUEST_VALUE == 0} {
            set_parameter_property $AV_MAX_WAITREQUESTED_READ ENABLED false
        } else {
            set_parameter_property $AV_MAX_WAITREQUESTED_READ ENABLED true
        }
    }
    
    if {$USE_READ_DATA_VALID_VALUE > 0} {
        set_interface_property $SLAVE_INTERFACE readLatency 0
        set_interface_property $MASTER_INTERFACE readLatency 0
        set_parameter_property $AV_FIX_READ_LATENCY ENABLED false
        set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID ENABLED true
        set_parameter_property $AV_MAX_READ_LATENCY ENABLED true
        set_parameter_property $AV_READ_TIMEOUT ENABLED true
    } else {
        set_interface_property $SLAVE_INTERFACE readLatency $AV_FIX_READ_LATENCY_VALUE
        set_interface_property $MASTER_INTERFACE readLatency $AV_FIX_READ_LATENCY_VALUE
        set_parameter_property $AV_FIX_READ_LATENCY ENABLED true
        set_parameter_property $AV_MAX_CONTINUOUS_READDATAVALID ENABLED false
        set_parameter_property $AV_MAX_READ_LATENCY ENABLED false
        set_parameter_property $AV_READ_TIMEOUT ENABLED false
    }

    if {$USE_WRITE_VALUE == 0} {
        set_parameter_property $AV_MAX_PENDING_WRITES ENABLED false
        set_interface_property $SLAVE_INTERFACE maximumPendingWriteTransactions 0
        set_parameter_property $AV_MAX_CONTINUOUS_WRITE ENABLED false
        set_parameter_property $AV_WRITE_TIMEOUT ENABLED false
        set_parameter_property $AV_MAX_WAITREQUESTED_WRITE ENABLED false
    } else {
        set_parameter_property $AV_MAX_PENDING_WRITES ENABLED true
        set_interface_property $SLAVE_INTERFACE maximumPendingWriteTransactions $AV_MAX_PENDING_WRITES_VALUE
        set_parameter_property $AV_MAX_CONTINUOUS_WRITE ENABLED true
        set_parameter_property $AV_WRITE_TIMEOUT ENABLED true
        
        if {$USE_WAIT_REQUEST_VALUE == 0} {
            set_parameter_property $AV_MAX_WAITREQUESTED_WRITE ENABLED false
        } else {
            set_parameter_property $AV_MAX_WAITREQUESTED_WRITE ENABLED true
        }
    }

    # Ports
    #---------------------------------------------------------------------
    add_interface_port $SLAVE_INTERFACE  avs_waitrequest waitrequest Output 1
    add_interface_port $MASTER_INTERFACE avm_waitrequest waitrequest Input 1

    add_interface_port $SLAVE_INTERFACE  avs_write write Input 1
    add_interface_port $MASTER_INTERFACE avm_write write Output 1

    add_interface_port $SLAVE_INTERFACE  avs_read read Input 1
    add_interface_port $MASTER_INTERFACE avm_read read Output 1

    if { [string match [ get_parameter_value $SLAVE_ADDRESS_TYPE ] [ get_parameter_value $MASTER_ADDRESS_TYPE ] ] } { 
      add_interface_port $SLAVE_INTERFACE  avs_address address Input $AV_ADDRESS_W_VALUE 
    } else { 
      add_interface_port $SLAVE_INTERFACE  avs_address address Input [expr {$AV_ADDRESS_W_VALUE - [log2 $AV_NUMSYMBOLS_VALUE]}] 
    } 
    set_port_property avs_address VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_address address Output $AV_ADDRESS_W_VALUE
    set_port_property avm_address VHDL_TYPE STD_LOGIC_VECTOR
    
    add_interface_port $SLAVE_INTERFACE  avs_byteenable byteenable Input $AV_NUMSYMBOLS_VALUE
    set_port_property avs_byteenable VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_byteenable byteenable Output $AV_NUMSYMBOLS_VALUE
    set_port_property avm_byteenable VHDL_TYPE STD_LOGIC_VECTOR

    add_interface_port $SLAVE_INTERFACE  avs_burstcount burstcount Input $AV_BURSTCOUNT_W_VALUE
    set_port_property avs_burstcount VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_burstcount burstcount Output $AV_BURSTCOUNT_W_VALUE
    set_port_property avm_burstcount VHDL_TYPE STD_LOGIC_VECTOR

    add_interface_port $SLAVE_INTERFACE  avs_readdata readdata Output  $AV_DATA_W_VALUE
    set_port_property avs_readdata VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_readdata readdata Input $AV_DATA_W_VALUE
    set_port_property avm_readdata VHDL_TYPE STD_LOGIC_VECTOR

    add_interface_port $SLAVE_INTERFACE  avs_readdatavalid readdatavalid Output 1
    add_interface_port $MASTER_INTERFACE avm_readdatavalid readdatavalid Input 1

    add_interface_port $SLAVE_INTERFACE  avs_writedata writedata Input $AV_DATA_W_VALUE
    set_port_property avs_writedata VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_writedata writedata Output $AV_DATA_W_VALUE
    set_port_property avm_writedata VHDL_TYPE STD_LOGIC_VECTOR

    add_interface_port $SLAVE_INTERFACE  avs_begintransfer begintransfer Input 1
    add_interface_port $MASTER_INTERFACE avm_begintransfer begintransfer Output 1
    
    add_interface_port $SLAVE_INTERFACE  avs_beginbursttransfer beginbursttransfer Input 1
    add_interface_port $MASTER_INTERFACE avm_beginbursttransfer beginbursttransfer Output 1

    add_interface_port $SLAVE_INTERFACE  avs_transactionid transactionid Input $AV_TRANSACTIONID_W_VALUE
    set_port_property avs_transactionid VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_transactionid transactionid Output $AV_TRANSACTIONID_W_VALUE
    set_port_property avm_transactionid VHDL_TYPE STD_LOGIC_VECTOR
    
    add_interface_port $SLAVE_INTERFACE  avs_response response Output 2
    add_interface_port $MASTER_INTERFACE avm_response response Input  2
    
    add_interface_port $SLAVE_INTERFACE  avs_readid readid Output $AV_TRANSACTIONID_W_VALUE
    set_port_property avs_readid VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_readid readid Input $AV_TRANSACTIONID_W_VALUE
    set_port_property avm_readid VHDL_TYPE STD_LOGIC_VECTOR
    
    add_interface_port $SLAVE_INTERFACE  avs_writeresponserequest writeresponserequest Input 1
    add_interface_port $MASTER_INTERFACE avm_writeresponserequest writeresponserequest Output 1
    
    add_interface_port $SLAVE_INTERFACE  avs_writeresponsevalid writeresponsevalid Output 1
    add_interface_port $MASTER_INTERFACE avm_writeresponsevalid writeresponsevalid Input 1
    
    add_interface_port $SLAVE_INTERFACE  avs_writeid writeid Output $AV_TRANSACTIONID_W_VALUE
    set_port_property avs_writeid VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_writeid writeid Input $AV_TRANSACTIONID_W_VALUE
    set_port_property avm_writeid VHDL_TYPE STD_LOGIC_VECTOR

    add_interface_port $SLAVE_INTERFACE  avs_arbiterlock arbiterlock Input 1
    add_interface_port $MASTER_INTERFACE avm_arbiterlock arbiterlock Output 1
    
    add_interface_port $SLAVE_INTERFACE  avs_lock lock Input 1
    add_interface_port $MASTER_INTERFACE avm_lock lock Output 1
    
    add_interface_port $SLAVE_INTERFACE  avs_debugaccess debugaccess Input 1
    add_interface_port $MASTER_INTERFACE avm_debugaccess debugaccess Output 1
    
    add_interface_port $SLAVE_INTERFACE  avs_clken clken Input 1
    add_interface_port $MASTER_INTERFACE avm_clken clken Output 1
    
    # deprecated signals
   add_interface_port $MASTER_INTERFACE avm_readresponse          readresponse         input    $AV_READRESPONSE_W_VALUE
   add_interface_port $SLAVE_INTERFACE  avs_readresponse          readresponse         output   $AV_READRESPONSE_W_VALUE
   add_interface_port $MASTER_INTERFACE avm_writeresponse         writeresponse        input    $AV_WRITERESPONSE_W_VALUE
   add_interface_port $SLAVE_INTERFACE  avs_writeresponse         writeresponse        output   $AV_WRITERESPONSE_W_VALUE
   
   set_port_property avm_readresponse  VHDL_TYPE         STD_LOGIC_VECTOR
   set_port_property avm_readresponse  TERMINATION       1
   set_port_property avm_readresponse  TERMINATION_VALUE 0
  
   set_port_property avs_readresponse  VHDL_TYPE         STD_LOGIC_VECTOR
   set_port_property avs_readresponse  TERMINATION       1
   
   set_port_property avm_writeresponse VHDL_TYPE         STD_LOGIC_VECTOR
   set_port_property avm_writeresponse TERMINATION       1
   set_port_property avm_writeresponse TERMINATION_VALUE 0
   
   set_port_property avs_writeresponse VHDL_TYPE         STD_LOGIC_VECTOR
   set_port_property avs_writeresponse TERMINATION       1
    
    # Terminate unused ports 
    #---------------------------------------------------------------------    
    if {$USE_WAIT_REQUEST_VALUE == 0} {
   set_port_property avm_waitrequest TERMINATION 1
   set_port_property avm_waitrequest TERMINATION_VALUE 0
   set_port_property avs_waitrequest TERMINATION 1
    }
    if {$USE_WRITE_VALUE == 0} {
   set_port_property avm_write TERMINATION 1
   set_port_property avs_write TERMINATION 1
   set_port_property avs_write TERMINATION_VALUE 0
    }
    if {$USE_READ_VALUE == 0} {
   set_port_property avm_read TERMINATION 1
   set_port_property avs_read TERMINATION 1
   set_port_property avs_read TERMINATION_VALUE 0
    }
    if {$USE_ADDRESS_VALUE == 0} {
   set_port_property avm_address TERMINATION 1
   set_port_property avs_address TERMINATION 1
   set_port_property avs_address TERMINATION_VALUE 0
   set_parameter_property $AV_ADDRESS_W ENABLED false
    } else {
   set_parameter_property $AV_ADDRESS_W ENABLED true
    }
    if {$USE_BYTE_ENABLE_VALUE == 0} {
   set_port_property avm_byteenable TERMINATION 1
   set_port_property avs_byteenable TERMINATION 1
   set_port_property avs_byteenable TERMINATION_VALUE 0xffffffff
    }
    if {$USE_BURSTCOUNT_VALUE == 0} {
   set_port_property avm_burstcount TERMINATION 1
   set_port_property avs_burstcount TERMINATION 1
   set_port_property avs_burstcount TERMINATION_VALUE 1
   set_parameter_property $AV_BURSTCOUNT_W ENABLED false
    } else {
   set_parameter_property $AV_BURSTCOUNT_W ENABLED true
    }
    if {$USE_READ_VALUE == 0 || $USE_READ_DATA_VALUE == 0 } {
   set_port_property avm_readdata TERMINATION 1
   set_port_property avm_readdata TERMINATION_VALUE 0
   set_port_property avs_readdata TERMINATION 1
    }
    if {$USE_READ_VALUE == 0 || $USE_READ_DATA_VALID_VALUE == 0} {
   set_port_property avm_readdatavalid TERMINATION 1
   set_port_property avm_readdatavalid TERMINATION_VALUE 0
   set_port_property avs_readdatavalid TERMINATION 1
    }
    if {$USE_WRITE_VALUE == 0 || $USE_WRITE_DATA_VALUE == 0 } {
   set_port_property avm_writedata TERMINATION 1
   set_port_property avs_writedata TERMINATION 1
   set_port_property avs_writedata TERMINATION_VALUE 0
    }
    if {$USE_BEGIN_TRANSFER_VALUE == 0 } {
   set_port_property avm_begintransfer TERMINATION 1
   set_port_property avs_begintransfer TERMINATION 1
   set_port_property avs_begintransfer TERMINATION_VALUE 0
    }
    if {$USE_BURSTCOUNT_VALUE == 0 || $USE_BEGIN_BURST_TRANSFER_VALUE == 0 } {
   set_port_property avm_beginbursttransfer TERMINATION 1
   set_port_property avs_beginbursttransfer TERMINATION 1
   set_port_property avs_beginbursttransfer TERMINATION_VALUE 0
    }
    if {$USE_ARBITERLOCK_VALUE == 0 } {
   set_port_property avm_arbiterlock TERMINATION 1
   set_port_property avs_arbiterlock TERMINATION 1
   set_port_property avs_arbiterlock TERMINATION_VALUE 0
    }
    if {$USE_LOCK_VALUE == 0} {
   set_port_property avm_lock TERMINATION 1
   set_port_property avs_lock TERMINATION 1
   set_port_property avs_lock TERMINATION_VALUE 0
    }
    if {$USE_DEBUGACCESS_VALUE == 0 } {
   set_port_property avm_debugaccess TERMINATION 1
   set_port_property avs_debugaccess TERMINATION 1
   set_port_property avs_debugaccess TERMINATION_VALUE 0
    }
   if {$USE_TRANSACTIONID_VALUE == 0 } {
      set_port_property avm_transactionid TERMINATION       1
      set_port_property avs_transactionid TERMINATION       1
      set_port_property avs_transactionid TERMINATION_VALUE 0
      set_port_property avm_writeid       TERMINATION       1
      set_port_property avs_writeid       TERMINATION       1
      set_port_property avs_writeid       TERMINATION_VALUE 0
      set_port_property avm_readid        TERMINATION       1
      set_port_property avs_readid        TERMINATION       1
      set_port_property avs_readid        TERMINATION_VALUE 0
   } else {
      set_port_property avm_transactionid TERMINATION       0
      set_port_property avs_transactionid TERMINATION       0      
      set_port_property avm_writeid       TERMINATION       0
      set_port_property avs_writeid       TERMINATION       0
      set_port_property avm_readid        TERMINATION       0
      set_port_property avs_readid        TERMINATION       0
   }
   if {$USE_WRITERESPONSE_VALUE == 0} {
      set_port_property avm_writeresponsevalid     TERMINATION       1
      set_port_property avm_writeresponsevalid     TERMINATION_VALUE 0
      set_port_property avs_writeresponsevalid     TERMINATION       1
      set_port_property avs_writeresponsevalid     TERMINATION_VALUE 0
      set_port_property avm_writeresponserequest   TERMINATION       1
      set_port_property avm_writeresponserequest   TERMINATION_VALUE 0
      set_port_property avs_writeresponserequest   TERMINATION       1
      set_port_property avs_writeresponserequest   TERMINATION_VALUE 0
   } else {
      set_port_property avm_writeresponsevalid     TERMINATION       0
      set_port_property avs_writeresponsevalid     TERMINATION       0
      set_port_property avm_writeresponserequest   TERMINATION       0
      set_port_property avs_writeresponserequest   TERMINATION       0
   }
   
   if {$USE_READRESPONSE_VALUE == 0 && $USE_WRITERESPONSE_VALUE == 0} {
      set_port_property avm_response TERMINATION 1
      set_port_property avs_response TERMINATION 1
      set_port_property avs_response TERMINATION_VALUE 0
    } else {
      set_port_property avm_response TERMINATION 0
      set_port_property avs_response TERMINATION 0
    }
    
   if { $USE_CLKEN_VALUE == 0 } {
   set_port_property avs_clken TERMINATION 1
   set_port_property avm_clken TERMINATION 1
   set_port_property avs_clken TERMINATION_VALUE 1
    }
    
}

