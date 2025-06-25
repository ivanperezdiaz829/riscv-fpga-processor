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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm_hw.tcl $
# $Revision: #3 $
# $Date: 2013/08/15 $
# $Author: saafnan $
#------------------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property NAME                         altera_avalon_mm_master_bfm
set_module_property DISPLAY_NAME                 "Altera Avalon-MM Master BFM"
set_module_property DESCRIPTION                  "Altera Avalon-MM Master BFM"
set_module_property VERSION                      13.1
set_module_property GROUP                        "Avalon Verification Suite"
set_module_property AUTHOR                       "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     false   
set_module_property INTERNAL                     false  
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property ANALYZE_HDL                  false

# ---------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------
# Define file set
add_fileset sim_verilog SIM_VERILOG sim_verilog
set_fileset_property sim_verilog top_level altera_avalon_mm_master_bfm

add_fileset sim_vhdl SIM_VHDL sim_vhdl
set_fileset_property sim_vhdl top_level altera_avalon_mm_master_bfm_vhdl

add_fileset quartus_synth QUARTUS_SYNTH quartus_synth_proc
set_fileset_property quartus_synth top_level altera_avalon_mm_master_bfm

# SIM_VERILOG generation callback procedure
proc sim_verilog {altera_avalon_mm_master_bfm} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_mm_pkg.sv"
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv"
   add_fileset_file altera_avalon_mm_master_bfm.sv SYSTEM_VERILOG PATH "altera_avalon_mm_master_bfm.sv" 
   
   set_fileset_file_attribute verbosity_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_mm_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_mm_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
}

proc quartus_synth_proc {altera_avalon_mm_master_bfm} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_mm_pkg.sv"
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv"
   add_fileset_file altera_avalon_mm_master_bfm.sv SYSTEM_VERILOG PATH "altera_avalon_mm_master_bfm.sv" 
}

# SIM_VHDL generation callback procedure
proc sim_vhdl {altera_avalon_mm_master_bfm_vhdl} {
   set HDL_LIB_DIR "../lib"
   set VHDL_DIR      "../[get_module_property NAME]_vhdl";
   
   if {1} {
      add_fileset_file mentor/verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/verbosity_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/avalon_mm_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/avalon_mm_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/avalon_utilities_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_mm_master_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_mm_master_bfm.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_mm_master_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_mm_master_bfm_vhdl_wrapper.sv" {MENTOR_SPECIFIC}
      
      set_fileset_file_attribute mentor/verbosity_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_verbosity_pkg
      set_fileset_file_attribute mentor/avalon_mm_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_avalon_mm_pkg
      set_fileset_file_attribute mentor/avalon_utilities_pkg.sv COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_avalon_utilities_pkg
   }

   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/verbosity_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/avalon_mm_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_mm_master_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_mm_master_bfm.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_mm_master_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_mm_master_bfm_vhdl_wrapper.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   
   set_fileset_file_attribute verbosity_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_mm_pkg.sv        COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_mm_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
   
   add_fileset_file altera_avalon_mm_master_bfm_vhdl_pkg.vhd VHDL path "$VHDL_DIR/altera_avalon_mm_master_bfm_vhdl_pkg.vhd"
   add_fileset_file altera_avalon_mm_master_bfm_vhdl.vhd VHDL path "$VHDL_DIR/altera_avalon_mm_master_bfm_vhdl.vhd"

}

add_documentation_link "User Guide" "http://www.altera.com/literature/ug/ug_avalon_verification_ip.pdf"
#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------
set AV_ADDRESS_W              "AV_ADDRESS_W"
set AV_SYMBOL_W               "AV_SYMBOL_W" 
set AV_NUMSYMBOLS             "AV_NUMSYMBOLS"
set AV_BURSTCOUNT_W           "AV_BURSTCOUNT_W" 
set AV_WRITERESPONSE_W        "AV_WRITERESPONSE_W"
set AV_READRESPONSE_W         "AV_READRESPONSE_W"

set USE_READ                  "USE_READ"
set USE_WRITE                 "USE_WRITE"
set USE_ADDRESS               "USE_ADDRESS"
set USE_BYTE_ENABLE           "USE_BYTE_ENABLE"
set USE_BURSTCOUNT            "USE_BURSTCOUNT"
set USE_READ_DATA             "USE_READ_DATA"
set USE_READ_DATA_VALID       "USE_READ_DATA_VALID"
set USE_WRITE_DATA            "USE_WRITE_DATA"
set USE_BEGIN_TRANSFER        "USE_BEGIN_TRANSFER"
set USE_BEGIN_BURST_TRANSFER  "USE_BEGIN_BURST_TRANSFER"
set USE_WAIT_REQUEST          "USE_WAIT_REQUEST"
set USE_ARBITERLOCK           "USE_ARBITERLOCK"
set USE_LOCK                  "USE_LOCK"
set USE_DEBUGACCESS           "USE_DEBUGACCESS"
set USE_TRANSACTIONID         "USE_TRANSACTIONID"
set USE_WRITERESPONSE         "USE_WRITERESPONSE"
set USE_READRESPONSE          "USE_READRESPONSE"
set USE_CLKEN                 "USE_CLKEN"

set ASSERT_HIGH_RESET         "ASSERT_HIGH_RESET"
set ASSERT_HIGH_WAITREQUEST   "ASSERT_HIGH_WAITREQUEST"
set ASSERT_HIGH_READ          "ASSERT_HIGH_READ"  
set ASSERT_HIGH_WRITE         "ASSERT_HIGH_WRITE"         
set ASSERT_HIGH_BYTEENABLE    "ASSERT_HIGH_BYTEENABLE"
set ASSERT_HIGH_READDATAVALID "ASSERT_HIGH_READDATAVALID"
set ASSERT_HIGH_ARBITERLOCK   "ASSERT_HIGH_ARBITERLOCK"         
set ASSERT_HIGH_LOCK          "ASSERT_HIGH_LOCK"         

set AV_CONSTANT_BURST_BEHAVIOR "AV_CONSTANT_BURST_BEHAVIOR"
set AV_BURST_LINEWRAP         "AV_BURST_LINEWRAP" 
set AV_BURST_BNDR_ONLY        "AV_BURST_BNDR_ONLY"
set AV_MAX_PENDING_READS      "AV_MAX_PENDING_READS"
set AV_MAX_PENDING_WRITES     "AV_MAX_PENDING_WRITES"
set AV_FIX_READ_LATENCY       "AV_FIX_READ_LATENCY"
set AV_READ_WAIT_TIME         "AV_READ_WAIT_TIME"
set AV_WRITE_WAIT_TIME        "AV_WRITE_WAIT_TIME"
set REGISTER_WAITREQUEST      "REGISTER_WAITREQUEST"

set ADDRESS_UNITS                "ADDRESS_UNITS"
set AV_REGISTERINCOMINGSIGNALS   "AV_REGISTERINCOMINGSIGNALS"
set VHDL_ID                      "VHDL_ID"

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
set_parameter_property $AV_SYMBOL_W DESCRIPTION "The width of an indidual symbol. The default is an 8 bit Byte."
set_parameter_property $AV_SYMBOL_W ALLOWED_RANGES {1:1024}
set_parameter_property $AV_SYMBOL_W HDL_PARAMETER true
set_parameter_property $AV_SYMBOL_W GROUP "Port Widths"

add_parameter $AV_NUMSYMBOLS Integer 4
set_parameter_property $AV_NUMSYMBOLS DISPLAY_NAME "Number of Symbols"
set_parameter_property $AV_NUMSYMBOLS AFFECTS_ELABORATION true
set_parameter_property $AV_NUMSYMBOLS DESCRIPTION "The number of symbols in a word. The default is 4 bytes per word."
set_parameter_property $AV_NUMSYMBOLS ALLOWED_RANGES {1,2,4,8,16,32,64,128}
set_parameter_property $AV_NUMSYMBOLS HDL_PARAMETER true
set_parameter_property $AV_SYMBOL_W GROUP "Port Widths"

add_parameter $AV_BURSTCOUNT_W Integer 3
set_parameter_property $AV_BURSTCOUNT_W DISPLAY_NAME "Burstcount width"
set_parameter_property $AV_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property $AV_BURSTCOUNT_W DESCRIPTION "The width of the Burstcount port determines the maximum burst length that can be specified for a transaction."
set_parameter_property $AV_BURSTCOUNT_W ALLOWED_RANGES {1:32}
set_parameter_property $AV_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property $AV_SYMBOL_W GROUP "Port Widths"

add_parameter $AV_READRESPONSE_W Integer 8
set_parameter_property $AV_READRESPONSE_W DISPLAY_NAME "Read Response width"
set_parameter_property $AV_READRESPONSE_W AFFECTS_ELABORATION true
set_parameter_property $AV_READRESPONSE_W DESCRIPTION "This is the word length in bits of the read response port."
set_parameter_property $AV_READRESPONSE_W ALLOWED_RANGES {1:1024}
set_parameter_property $AV_READRESPONSE_W HDL_PARAMETER true
set_parameter_property $AV_READRESPONSE_W GROUP "Port Widths"
set_parameter_property $AV_READRESPONSE_W VISIBLE false

add_parameter $AV_WRITERESPONSE_W Integer 8
set_parameter_property $AV_WRITERESPONSE_W DISPLAY_NAME "Write Response width"
set_parameter_property $AV_WRITERESPONSE_W AFFECTS_ELABORATION true
set_parameter_property $AV_WRITERESPONSE_W DESCRIPTION "This is the word length in bits of the read response port."
set_parameter_property $AV_WRITERESPONSE_W ALLOWED_RANGES {1:1024}
set_parameter_property $AV_WRITERESPONSE_W HDL_PARAMETER true
set_parameter_property $AV_WRITERESPONSE_W GROUP "Port Widths"
set_parameter_property $AV_WRITERESPONSE_W VISIBLE false

add_parameter $USE_READ Integer 1 
set_parameter_property $USE_READ DISPLAY_NAME "Use the read signal"
set_parameter_property $USE_READ AFFECTS_ELABORATION true
set_parameter_property $USE_READ DESCRIPTION "Use the read signal"
set_parameter_property $USE_READ DISPLAY_HINT boolean
set_parameter_property $USE_READ HDL_PARAMETER true
set_parameter_property $USE_READ GROUP "Port Enables"

add_parameter $USE_WRITE Integer 1 
set_parameter_property $USE_WRITE DISPLAY_NAME "Use the write signal"
set_parameter_property $USE_WRITE AFFECTS_ELABORATION true
set_parameter_property $USE_WRITE DESCRIPTION "Use the write signal"
set_parameter_property $USE_WRITE DISPLAY_HINT boolean
set_parameter_property $USE_WRITE HDL_PARAMETER true
set_parameter_property $USE_WRITE GROUP "Port Enables"

add_parameter $USE_ADDRESS Integer 1 
set_parameter_property $USE_ADDRESS DISPLAY_NAME "Use the address signal"
set_parameter_property $USE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property $USE_ADDRESS DESCRIPTION "Use the address signal"
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
set_parameter_property $USE_BURSTCOUNT DESCRIPTION "Use the burstcount signal"
set_parameter_property $USE_BURSTCOUNT DISPLAY_HINT boolean
set_parameter_property $USE_BURSTCOUNT HDL_PARAMETER true
set_parameter_property $USE_BURSTCOUNT GROUP "Port Enables"

add_parameter $USE_READ_DATA Integer 1 
set_parameter_property $USE_READ_DATA DISPLAY_NAME "Use the readdata signal"
set_parameter_property $USE_READ_DATA AFFECTS_ELABORATION true
set_parameter_property $USE_READ_DATA DESCRIPTION "Use the readdata signal"
set_parameter_property $USE_READ_DATA DISPLAY_HINT boolean
set_parameter_property $USE_READ_DATA HDL_PARAMETER true
set_parameter_property $USE_READ_DATA GROUP "Port Enables"

add_parameter $USE_READ_DATA_VALID Integer 1 
set_parameter_property $USE_READ_DATA_VALID DISPLAY_NAME "Use the readdatavalid signal"
set_parameter_property $USE_READ_DATA_VALID AFFECTS_ELABORATION true
set_parameter_property $USE_READ_DATA_VALID DESCRIPTION "Use the readdatavalid signal"
set_parameter_property $USE_READ_DATA_VALID DISPLAY_HINT boolean
set_parameter_property $USE_READ_DATA_VALID HDL_PARAMETER true
set_parameter_property $USE_READ_DATA_VALID GROUP "Port Enables"

add_parameter $USE_WRITE_DATA Integer 1 
set_parameter_property $USE_WRITE_DATA DISPLAY_NAME "Use the writedata signal"
set_parameter_property $USE_WRITE_DATA AFFECTS_ELABORATION true
set_parameter_property $USE_WRITE_DATA DESCRIPTION "Use writedata signal"
set_parameter_property $USE_WRITE_DATA DISPLAY_HINT boolean
set_parameter_property $USE_WRITE_DATA HDL_PARAMETER true
set_parameter_property $USE_WRITE_DATA GROUP "Port Enables"

add_parameter $USE_BEGIN_TRANSFER Integer 0
set_parameter_property $USE_BEGIN_TRANSFER DISPLAY_NAME "Use the begintransfer signal"
set_parameter_property $USE_BEGIN_TRANSFER AFFECTS_ELABORATION true
set_parameter_property $USE_BEGIN_TRANSFER DESCRIPTION "Use the begintransfer signal"
set_parameter_property $USE_BEGIN_TRANSFER DISPLAY_HINT boolean
set_parameter_property $USE_BEGIN_TRANSFER HDL_PARAMETER true
set_parameter_property $USE_BEGIN_TRANSFER GROUP "Port Enables"

add_parameter $USE_BEGIN_BURST_TRANSFER Integer 0
set_parameter_property $USE_BEGIN_BURST_TRANSFER DISPLAY_NAME "Use beginbursttransfer signal"
set_parameter_property $USE_BEGIN_BURST_TRANSFER AFFECTS_ELABORATION true
set_parameter_property $USE_BEGIN_BURST_TRANSFER DESCRIPTION "Use beginbursttransfer signal"
set_parameter_property $USE_BEGIN_BURST_TRANSFER DISPLAY_HINT boolean
set_parameter_property $USE_BEGIN_BURST_TRANSFER HDL_PARAMETER true
set_parameter_property $USE_BEGIN_BURST_TRANSFER GROUP "Port Enables"

add_parameter $USE_ARBITERLOCK Integer 0 
set_parameter_property $USE_ARBITERLOCK DISPLAY_NAME "Use the arbiterlock signal"
set_parameter_property $USE_ARBITERLOCK AFFECTS_ELABORATION true
set_parameter_property $USE_ARBITERLOCK DESCRIPTION "Use the arbiterlock signal"
set_parameter_property $USE_ARBITERLOCK DISPLAY_HINT boolean
set_parameter_property $USE_ARBITERLOCK HDL_PARAMETER false
set_parameter_property $USE_ARBITERLOCK GROUP "Port Enables"

add_parameter $USE_LOCK Integer 0 
set_parameter_property $USE_LOCK DISPLAY_NAME "Use the lock signal"
set_parameter_property $USE_LOCK AFFECTS_ELABORATION true
set_parameter_property $USE_LOCK DESCRIPTION "Use the lock signal"
set_parameter_property $USE_LOCK DISPLAY_HINT boolean
set_parameter_property $USE_LOCK HDL_PARAMETER false
set_parameter_property $USE_LOCK GROUP "Port Enables"

add_parameter $USE_DEBUGACCESS Integer 0 
set_parameter_property $USE_DEBUGACCESS DISPLAY_NAME "Use the debugaccess signal"
set_parameter_property $USE_DEBUGACCESS AFFECTS_ELABORATION true
set_parameter_property $USE_DEBUGACCESS DESCRIPTION "Use the debugaccess signal"
set_parameter_property $USE_DEBUGACCESS DISPLAY_HINT boolean
set_parameter_property $USE_DEBUGACCESS HDL_PARAMETER false
set_parameter_property $USE_DEBUGACCESS GROUP "Port Enables"

add_parameter $USE_WAIT_REQUEST Integer 1 
set_parameter_property $USE_WAIT_REQUEST DISPLAY_NAME "Use the waitrequest signal"
set_parameter_property $USE_WAIT_REQUEST AFFECTS_ELABORATION true
set_parameter_property $USE_WAIT_REQUEST DESCRIPTION "Use the waitrequest signal"
set_parameter_property $USE_WAIT_REQUEST DISPLAY_HINT boolean
set_parameter_property $USE_WAIT_REQUEST HDL_PARAMETER true
set_parameter_property $USE_WAIT_REQUEST GROUP "Port Enables"

add_parameter $USE_TRANSACTIONID Integer 0 
set_parameter_property $USE_TRANSACTIONID DISPLAY_NAME "Use the transaction id signals"
set_parameter_property $USE_TRANSACTIONID AFFECTS_ELABORATION true
set_parameter_property $USE_TRANSACTIONID DESCRIPTION "Use the transaction id signals"
set_parameter_property $USE_TRANSACTIONID DISPLAY_HINT boolean
set_parameter_property $USE_TRANSACTIONID HDL_PARAMETER true
set_parameter_property $USE_TRANSACTIONID GROUP "Port Enables"
set_parameter_property $USE_TRANSACTIONID VISIBLE false

add_parameter $USE_WRITERESPONSE Integer 0 
set_parameter_property $USE_WRITERESPONSE DISPLAY_NAME "Use the write response signals"
set_parameter_property $USE_WRITERESPONSE AFFECTS_ELABORATION true
set_parameter_property $USE_WRITERESPONSE DESCRIPTION "Use the write response signals"
set_parameter_property $USE_WRITERESPONSE DISPLAY_HINT boolean
set_parameter_property $USE_WRITERESPONSE HDL_PARAMETER true
set_parameter_property $USE_WRITERESPONSE GROUP "Port Enables"
set_parameter_property $USE_WRITERESPONSE VISIBLE false

add_parameter $USE_READRESPONSE Integer 0 
set_parameter_property $USE_READRESPONSE DISPLAY_NAME "Use the read response signals"
set_parameter_property $USE_READRESPONSE AFFECTS_ELABORATION true
set_parameter_property $USE_READRESPONSE DESCRIPTION "Use the read response signals"
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

add_parameter $ASSERT_HIGH_RESET Integer 1 
set_parameter_property $ASSERT_HIGH_RESET DISPLAY_NAME "Assert reset high"
set_parameter_property $ASSERT_HIGH_RESET AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_RESET DESCRIPTION "Assert high reset"
set_parameter_property $ASSERT_HIGH_RESET DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_RESET GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_WAITREQUEST Integer 1 
set_parameter_property $ASSERT_HIGH_WAITREQUEST DISPLAY_NAME "Assert waitrequest high"
set_parameter_property $ASSERT_HIGH_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_WAITREQUEST DESCRIPTION "Assert waitrequest high"
set_parameter_property $ASSERT_HIGH_WAITREQUEST DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_WAITREQUEST GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_READ Integer 1 
set_parameter_property $ASSERT_HIGH_READ DISPLAY_NAME "Assert read high"
set_parameter_property $ASSERT_HIGH_READ AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_READ DESCRIPTION "Assert read high"
set_parameter_property $ASSERT_HIGH_READ DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_READ GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_WRITE Integer 1 
set_parameter_property $ASSERT_HIGH_WRITE DISPLAY_NAME "Assert write high"
set_parameter_property $ASSERT_HIGH_WRITE AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_WRITE DESCRIPTION "Assert write high"
set_parameter_property $ASSERT_HIGH_WRITE DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_WRITE GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_BYTEENABLE Integer 1 
set_parameter_property $ASSERT_HIGH_BYTEENABLE DISPLAY_NAME "Assert byteenable high"
set_parameter_property $ASSERT_HIGH_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_BYTEENABLE DESCRIPTION "Assert byteenable high"
set_parameter_property $ASSERT_HIGH_BYTEENABLE DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_BYTEENABLE GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_READDATAVALID Integer 1 
set_parameter_property $ASSERT_HIGH_READDATAVALID DISPLAY_NAME "Assert readdatavalid high"
set_parameter_property $ASSERT_HIGH_READDATAVALID AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_READDATAVALID DESCRIPTION "Assert readdatavalid high"
set_parameter_property $ASSERT_HIGH_READDATAVALID DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_READDATAVALID GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_ARBITERLOCK Integer 1 
set_parameter_property $ASSERT_HIGH_ARBITERLOCK DISPLAY_NAME "Assert arbiterlock high"
set_parameter_property $ASSERT_HIGH_ARBITERLOCK AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_ARBITERLOCK DESCRIPTION "Assert arbiterlock high"
set_parameter_property $ASSERT_HIGH_ARBITERLOCK DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_ARBITERLOCK GROUP "Port Polarity"

add_parameter $ASSERT_HIGH_LOCK Integer 1 
set_parameter_property $ASSERT_HIGH_LOCK DISPLAY_NAME "Assert lock high"
set_parameter_property $ASSERT_HIGH_LOCK AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_LOCK DESCRIPTION "Assert lock high"
set_parameter_property $ASSERT_HIGH_LOCK DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_LOCK GROUP "Port Polarity"

add_parameter $AV_CONSTANT_BURST_BEHAVIOR Integer 1 
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR DISPLAY_NAME "Constant burst behavior"
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR AFFECTS_ELABORATION true
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR DESCRIPTION "Constant burst behavior"
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR DISPLAY_HINT boolean
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR HDL_PARAMETER true
set_parameter_property $AV_CONSTANT_BURST_BEHAVIOR GROUP "Burst Attributes"

add_parameter $AV_BURST_LINEWRAP Integer 1 
set_parameter_property $AV_BURST_LINEWRAP DISPLAY_NAME "Linewrap bursts"
set_parameter_property $AV_BURST_LINEWRAP AFFECTS_ELABORATION true
set_parameter_property $AV_BURST_LINEWRAP DESCRIPTION "Linewrap bursts"
set_parameter_property $AV_BURST_LINEWRAP DISPLAY_HINT boolean
set_parameter_property $AV_BURST_LINEWRAP HDL_PARAMETER true
set_parameter_property $AV_BURST_LINEWRAP GROUP "Burst Attributes"

add_parameter $AV_BURST_BNDR_ONLY Integer 1 
set_parameter_property $AV_BURST_BNDR_ONLY DISPLAY_NAME "Burst on Burst Boundaries only"
set_parameter_property $AV_BURST_BNDR_ONLY AFFECTS_ELABORATION true
set_parameter_property $AV_BURST_BNDR_ONLY HDL_PARAMETER true
set_parameter_property $AV_BURST_BNDR_ONLY DESCRIPTION "Burst on boundaries only"
set_parameter_property $AV_BURST_BNDR_ONLY DISPLAY_HINT boolean
set_parameter_property $AV_BURST_BNDR_ONLY GROUP "Burst Attributes"

add_parameter $AV_MAX_PENDING_READS Integer 0
set_parameter_property $AV_MAX_PENDING_READS DISPLAY_NAME "Maximum pending reads"
set_parameter_property $AV_MAX_PENDING_READS AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_PENDING_READS HDL_PARAMETER true
set_parameter_property $AV_MAX_PENDING_READS DESCRIPTION "Maximum pending read transactions"
set_parameter_property $AV_MAX_PENDING_READS GROUP "Miscellaneous" 

add_parameter $AV_MAX_PENDING_WRITES Integer 0 
set_parameter_property $AV_MAX_PENDING_WRITES DISPLAY_NAME "Maximum pending writes"
set_parameter_property $AV_MAX_PENDING_WRITES AFFECTS_ELABORATION true
set_parameter_property $AV_MAX_PENDING_WRITES HDL_PARAMETER true
set_parameter_property $AV_MAX_PENDING_WRITES DESCRIPTION "Maximum pending write transactions"
set_parameter_property $AV_MAX_PENDING_WRITES GROUP "Miscellaneous"
set_parameter_property $AV_MAX_PENDING_WRITES VISIBLE false

add_parameter $AV_FIX_READ_LATENCY Integer 1 
set_parameter_property $AV_FIX_READ_LATENCY DISPLAY_NAME "Fixed read latency (cycles)"
set_parameter_property $AV_FIX_READ_LATENCY AFFECTS_ELABORATION true
set_parameter_property $AV_FIX_READ_LATENCY HDL_PARAMETER true
set_parameter_property $AV_FIX_READ_LATENCY DESCRIPTION "Cycles of fixed read latency"
set_parameter_property $AV_FIX_READ_LATENCY GROUP "Miscellaneous" 

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

add_parameter $ADDRESS_UNITS String "SYMBOLS"
set_parameter_property $ADDRESS_UNITS DISPLAY_NAME "Set master interface address type to symbols or words"
set_parameter_property $ADDRESS_UNITS AFFECTS_ELABORATION true
set_parameter_property $ADDRESS_UNITS DESCRIPTION "Set master interface address type to symbols or words. Default value is 'SYMBOLS'"
set_parameter_property $ADDRESS_UNITS ALLOWED_RANGES {"SYMBOLS" "WORDS"}
set_parameter_property $ADDRESS_UNITS HDL_PARAMETER false
set_parameter_property $ADDRESS_UNITS GROUP "Interface Address Type"

add_parameter $VHDL_ID Integer 0
set_parameter_property $VHDL_ID DISPLAY_NAME "VHDL BFM ID"
set_parameter_property $VHDL_ID DESCRIPTION "BFM ID number for VHDL"
set_parameter_property $VHDL_ID HDL_PARAMETER true
set_parameter_property $VHDL_ID ALLOWED_RANGES {0:1023}
set_parameter_property $VHDL_ID GROUP "VHDL BFM"

#------------------------------------------------------------------------------
proc elaborate {} {
    global AV_ADDRESS_W          
    global AV_SYMBOL_W           
    global AV_NUMSYMBOLS         
    global AV_BURSTCOUNT_W            
    global AV_READRESPONSE_W 
    global AV_WRITERESPONSE_W

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
    global USE_ARBITERLOCK
    global USE_LOCK
    global USE_DEBUGACCESS
    global USE_TRANSACTIONID
    global USE_WRITERESPONSE
    global USE_READRESPONSE 
    global USE_CLKEN 

    global ASSERT_HIGH_RESET        
    global ASSERT_HIGH_WAITREQUEST  
    global ASSERT_HIGH_READ         
    global ASSERT_HIGH_WRITE        
    global ASSERT_HIGH_BYTEENABLE   
    global ASSERT_HIGH_READDATAVALID
    global ASSERT_HIGH_ARBITERLOCK
    global ASSERT_HIGH_LOCK

    global AV_CONSTANT_BURST_BEHAVIOR
    global AV_BURST_LINEWRAP     
    global AV_BURST_BNDR_ONLY 
    global AV_MAX_PENDING_READS
    global AV_MAX_PENDING_WRITES
    global AV_FIX_READ_LATENCY
    global AV_READ_WAIT_TIME   
    global AV_WRITE_WAIT_TIME 
    global REGISTER_WAITREQUEST
    global AV_REGISTERINCOMINGSIGNALS
    
    global ADDRESS_UNITS

    set AV_ADDRESS_W_VALUE                [ get_parameter $AV_ADDRESS_W ]
    set AV_SYMBOL_W_VALUE                 [ get_parameter $AV_SYMBOL_W ] 
    set AV_NUMSYMBOLS_VALUE               [ get_parameter $AV_NUMSYMBOLS ]
    set AV_BURSTCOUNT_W_VALUE             [ get_parameter $AV_BURSTCOUNT_W ]
    set AV_READRESPONSE_W_VALUE           [ get_parameter $AV_READRESPONSE_W ]
    set AV_WRITERESPONSE_W_VALUE          [ get_parameter $AV_WRITERESPONSE_W ]
   
    set USE_READ_VALUE                    [ get_parameter $USE_READ ] 
    set USE_WRITE_VALUE                   [ get_parameter $USE_WRITE ] 
    set USE_ADDRESS_VALUE                 [ get_parameter $USE_ADDRESS ] 
    set USE_BYTE_ENABLE_VALUE             [ get_parameter $USE_BYTE_ENABLE ]
    set USE_BURSTCOUNT_VALUE              [ get_parameter $USE_BURSTCOUNT ] 
    set USE_READ_DATA_VALUE               [ get_parameter $USE_READ_DATA ]
    set USE_READ_DATA_VALID_VALUE         [ get_parameter $USE_READ_DATA_VALID ]
    set USE_WRITE_DATA_VALUE              [ get_parameter $USE_WRITE_DATA ]       
    set USE_BEGIN_TRANSFER_VALUE          [ get_parameter $USE_BEGIN_TRANSFER ]
    set USE_BEGIN_BURST_TRANSFER_VALUE    [ get_parameter $USE_BEGIN_BURST_TRANSFER ]
    set USE_WAIT_REQUEST_VALUE            [ get_parameter $USE_WAIT_REQUEST ]
    set USE_ARBITERLOCK_VALUE             [ get_parameter $USE_ARBITERLOCK ] 
    set USE_LOCK_VALUE                    [ get_parameter $USE_LOCK ] 
    set USE_DEBUGACCESS_VALUE             [ get_parameter $USE_DEBUGACCESS ] 
    set USE_TRANSACTIONID_VALUE           [ get_parameter $USE_TRANSACTIONID ] 
    set USE_WRITERESPONSE_VALUE           [ get_parameter $USE_WRITERESPONSE ] 
    set USE_READRESPONSE_VALUE            [ get_parameter $USE_READRESPONSE ] 
    set USE_CLKEN_VALUE                   [ get_parameter $USE_CLKEN ] 
   
    set ASSERT_HIGH_RESET_VALUE           [ get_parameter $ASSERT_HIGH_RESET ]
    set ASSERT_HIGH_WAITREQUEST_VALUE     [ get_parameter $ASSERT_HIGH_WAITREQUEST]
    set ASSERT_HIGH_READ_VALUE            [ get_parameter $ASSERT_HIGH_READ ]   
    set ASSERT_HIGH_WRITE_VALUE           [ get_parameter $ASSERT_HIGH_WRITE ] 
    set ASSERT_HIGH_BYTEENABLE_VALUE      [ get_parameter $ASSERT_HIGH_BYTEENABLE ]
    set ASSERT_HIGH_READDATAVALID_VALUE   [ get_parameter $ASSERT_HIGH_READDATAVALID]
    set ASSERT_HIGH_ARBITERLOCK_VALUE     [ get_parameter $ASSERT_HIGH_ARBITERLOCK ] 
    set ASSERT_HIGH_LOCK_VALUE            [ get_parameter $ASSERT_HIGH_LOCK ] 
   
    set AV_CONSTANT_BURST_BEHAVIOR_VALUE  [ get_parameter $AV_CONSTANT_BURST_BEHAVIOR ] 
    set AV_BURST_LINEWRAP_VALUE           [ get_parameter $AV_BURST_LINEWRAP ] 
    set AV_BURST_BNDR_ONLY_VALUE          [ get_parameter $AV_BURST_BNDR_ONLY ] 
    set AV_MAX_PENDING_READS_VALUE        [ get_parameter $AV_MAX_PENDING_READS ]  
    set AV_MAX_PENDING_WRITES_VALUE       [ get_parameter $AV_MAX_PENDING_WRITES ]
    set AV_FIX_READ_LATENCY_VALUE         [ get_parameter $AV_FIX_READ_LATENCY ] 
    set AV_READ_WAIT_TIME_VALUE           [ get_parameter $AV_READ_WAIT_TIME ]  
    set AV_WRITE_WAIT_TIME_VALUE          [ get_parameter $AV_WRITE_WAIT_TIME ]  
    set REGISTER_WAITREQUEST_VALUE        [ get_parameter $REGISTER_WAITREQUEST ] 
    set AV_REGISTERINCOMINGSIGNALS_VALUE  [ get_parameter $AV_REGISTERINCOMINGSIGNALS ] 

    set AV_DATA_W_VALUE                   [ expr {$AV_SYMBOL_W_VALUE * $AV_NUMSYMBOLS_VALUE}]
    set AV_TRANSACTIONID_W_VALUE          8
    
    set ADDRESS_UNITS_VALUE               [ get_parameter $ADDRESS_UNITS ]

    # Interface Names
    #---------------------------------------------------------------------
    set CLOCK_INTERFACE   "clk"
    set MASTER_INTERFACE  "m0"

    #---------------------------------------------------------------------
    # Clock-Reset connection point
    #---------------------------------------------------------------------
    add_interface $CLOCK_INTERFACE clock end

    add_interface_port $CLOCK_INTERFACE clk clk Input 1
    if {$ASSERT_HIGH_RESET_VALUE > 0 } {
        add_interface_port $CLOCK_INTERFACE reset reset Input 1
    } else {
        add_interface_port $CLOCK_INTERFACE reset reset_n Input 1
    }

    #---------------------------------------------------------------------
    # Avalon Master connection point 
    #---------------------------------------------------------------------
    add_interface $MASTER_INTERFACE avalon start

    # Interface Properties
    #---------------------------------------------------------------------
    set_interface_property $MASTER_INTERFACE ENABLED true
    set_interface_property $MASTER_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $MASTER_INTERFACE doStreamReads false
    set_interface_property $MASTER_INTERFACE doStreamWrites false
    set_interface_property $MASTER_INTERFACE readWaitTime $AV_READ_WAIT_TIME_VALUE
    set_interface_property $MASTER_INTERFACE writeWaitTime $AV_WRITE_WAIT_TIME_VALUE
    set_interface_property $MASTER_INTERFACE readWaitTime $AV_READ_WAIT_TIME_VALUE
    set_interface_property $MASTER_INTERFACE writeWaitTime $AV_WRITE_WAIT_TIME_VALUE
        
    if {$USE_WAIT_REQUEST_VALUE == 0} {
        set_parameter_property $AV_READ_WAIT_TIME ENABLED true
        set_parameter_property $AV_WRITE_WAIT_TIME ENABLED true
    } else {
        set_parameter_property $AV_READ_WAIT_TIME ENABLED false
        set_parameter_property $AV_WRITE_WAIT_TIME ENABLED false
    }
    
    if {$USE_READ_VALUE == 0} {
        set_interface_property $MASTER_INTERFACE maximumPendingReadTransactions 0
        set_parameter_property $AV_MAX_PENDING_READS ENABLED false
    } else {
        set_interface_property $MASTER_INTERFACE maximumPendingReadTransactions $AV_MAX_PENDING_READS_VALUE
        set_parameter_property $AV_MAX_PENDING_READS ENABLED true
    }
    
    if {$USE_WRITE_VALUE == 0} {
        set_interface_property $MASTER_INTERFACE maximumPendingWriteTransactions 0
        set_parameter_property $AV_MAX_PENDING_WRITES ENABLED false
    } else {
        set_interface_property $MASTER_INTERFACE maximumPendingWriteTransactions $AV_MAX_PENDING_WRITES_VALUE
        set_parameter_property $AV_MAX_PENDING_WRITES ENABLED true
    }
    
    if {$USE_READ_DATA_VALID_VALUE > 0} {
        set_interface_property $MASTER_INTERFACE readLatency 0
        set_parameter_property $AV_FIX_READ_LATENCY ENABLED false
    } else {
        set_interface_property $MASTER_INTERFACE readLatency $AV_FIX_READ_LATENCY_VALUE
        set_parameter_property $AV_FIX_READ_LATENCY ENABLED true
    }

    set_interface_property $MASTER_INTERFACE addressUnits $ADDRESS_UNITS_VALUE

    if { $AV_BURST_LINEWRAP_VALUE > 0 } {
        set_interface_property $MASTER_INTERFACE linewrapBursts true
    } else {
        set_interface_property $MASTER_INTERFACE linewrapBursts false
    }
    if { $AV_BURST_BNDR_ONLY_VALUE > 0 } {
        set_interface_property $MASTER_INTERFACE burstOnBurstBoundariesOnly true
    } else {
        set_interface_property $MASTER_INTERFACE burstOnBurstBoundariesOnly false
    }
    
   if { $AV_REGISTERINCOMINGSIGNALS_VALUE == 0 } {
      set_interface_property $MASTER_INTERFACE registerIncomingSignals false
   } else {
      set_interface_property $MASTER_INTERFACE registerIncomingSignals true
   }
    
###TODO - fix this - registeredWaitrequest not recognized
#    if { $REGISTER_WAITREQUEST == 0 } {
#	set_interface_property $MASTER_INTERFACE registeredWaitrequest false
#    } else {
#	set_interface_property $MASTER_INTERFACE registeredWaitrequest true
#    }

    # Interface Ports
    #---------------------------------------------------------------------
    add_interface_port $MASTER_INTERFACE avm_address address Output $AV_ADDRESS_W_VALUE
    set_port_property avm_address VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_burstcount burstcount Output $AV_BURSTCOUNT_W_VALUE
    set_port_property avm_burstcount VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_readdata readdata Input $AV_DATA_W_VALUE
    set_port_property avm_readdata VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_writedata writedata Output $AV_DATA_W_VALUE
    set_port_property avm_writedata VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $MASTER_INTERFACE avm_begintransfer begintransfer Output 1
    add_interface_port $MASTER_INTERFACE avm_beginbursttransfer beginbursttransfer Output 1

    if {$ASSERT_HIGH_WAITREQUEST_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_waitrequest waitrequest Input 1
    } else {
        add_interface_port $MASTER_INTERFACE avm_waitrequest waitrequest_n Input 1
    }
    if {$ASSERT_HIGH_WRITE_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_write write Output 1
    } else {
        add_interface_port $MASTER_INTERFACE avm_write write_n Output 1
    }
    if {$ASSERT_HIGH_READ_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_read read Output 1
    } else {
        add_interface_port $MASTER_INTERFACE avm_read read_n Output 1
    }
    if {$ASSERT_HIGH_BYTEENABLE_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_byteenable byteenable Output $AV_NUMSYMBOLS_VALUE
        set_port_property avm_byteenable VHDL_TYPE STD_LOGIC_VECTOR
    } else {
        add_interface_port $MASTER_INTERFACE avm_byteenable byteenable_n Output $AV_NUMSYMBOLS_VALUE
        set_port_property avm_byteenable VHDL_TYPE STD_LOGIC_VECTOR
    }
    if {$ASSERT_HIGH_READDATAVALID_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_readdatavalid readdatavalid Input 1
    } else {
        add_interface_port $MASTER_INTERFACE avm_readdatavalid readdatavalid_n Input 1
    }
    if {$ASSERT_HIGH_ARBITERLOCK_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_arbiterlock arbiterlock Output 1
    } else {
        add_interface_port $MASTER_INTERFACE avm_arbiterlock arbiterlock_n Output 1
    }
    if {$ASSERT_HIGH_LOCK_VALUE > 0} {
        add_interface_port $MASTER_INTERFACE avm_lock lock Output 1
    } else {
        add_interface_port $MASTER_INTERFACE avm_lock lock_n Output 1
    }
    add_interface_port $MASTER_INTERFACE avm_debugaccess debugaccess Output 1

    add_interface_port $MASTER_INTERFACE avm_transactionid  transactionid Output $AV_TRANSACTIONID_W_VALUE
    add_interface_port $MASTER_INTERFACE avm_readid         readid        Input  $AV_TRANSACTIONID_W_VALUE
    add_interface_port $MASTER_INTERFACE avm_writeid        writeid       Input  $AV_TRANSACTIONID_W_VALUE
    add_interface_port $MASTER_INTERFACE avm_clken          clken         Output 1
    
    set_port_property avm_transactionid   VHDL_TYPE STD_LOGIC_VECTOR    
    set_port_property avm_readid          VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property avm_writeid         VHDL_TYPE STD_LOGIC_VECTOR
    
   # add transaction response related signals
   add_interface_port $MASTER_INTERFACE avm_response              response             input    2
   add_interface_port $MASTER_INTERFACE avm_writeresponserequest  writeresponserequest output   1
   add_interface_port $MASTER_INTERFACE avm_writeresponsevalid    writeresponsevalid   input    1
   
   # deprecated signals
   add_interface_port $MASTER_INTERFACE avm_readresponse          readresponse         input    $AV_READRESPONSE_W_VALUE
   add_interface_port $MASTER_INTERFACE avm_writeresponse         writeresponse        input    $AV_WRITERESPONSE_W_VALUE
   
   set_port_property avm_readresponse  VHDL_TYPE         STD_LOGIC_VECTOR
   set_port_property avm_readresponse  TERMINATION       1
   set_port_property avm_readresponse  TERMINATION_VALUE 0
   
   set_port_property avm_writeresponse VHDL_TYPE         STD_LOGIC_VECTOR
   set_port_property avm_writeresponse TERMINATION       1
   set_port_property avm_writeresponse TERMINATION_VALUE 0
    
    # Terminate unused ports 
    #---------------------------------------------------------------------    
   
   # port termination for writeresponserequest and writeresponsevalid signal
   if {$USE_WRITERESPONSE_VALUE == 0} {
      set_port_property avm_writeresponserequest   TERMINATION 1
      set_port_property avm_writeresponsevalid     TERMINATION 1
      set_port_property avm_writeresponsevalid     TERMINATION_VALUE 0
   } else {
      set_port_property avm_writeresponserequest   TERMINATION 0
      set_port_property avm_writeresponsevalid     TERMINATION 0
   }
   
   # port termination for response signal
   if {$USE_WRITERESPONSE_VALUE == 0 && $USE_READRESPONSE_VALUE == 0} {
      set_port_property avm_response               TERMINATION 1
      set_port_property avm_response               TERMINATION_VALUE 0
   } else {
      set_port_property avm_response               TERMINATION 0
   }
   
   # port termination for transactionid, writeid and readid signal
   if {$USE_TRANSACTIONID_VALUE == 0} {
      set_port_property avm_transactionid          TERMINATION 1
      set_port_property avm_writeid                TERMINATION 1
      set_port_property avm_writeid                TERMINATION_VALUE 0
      set_port_property avm_readid                 TERMINATION 1
      set_port_property avm_readid                 TERMINATION_VALUE 0
   } else {
      set_port_property avm_transactionid          TERMINATION 0
      if {$USE_WRITE_VALUE == 0} {
         set_port_property avm_writeid             TERMINATION 1
         set_port_property avm_writeid             TERMINATION_VALUE 0
      } else {
         set_port_property avm_writeid             TERMINATION 0
      }
      if {$USE_READ_VALUE == 0} {
         set_port_property avm_readid              TERMINATION 1
         set_port_property avm_readid              TERMINATION_VALUE 0
      } else {
         set_port_property avm_readid              TERMINATION 0
      }
   }
   
    if {$USE_ARBITERLOCK_VALUE == 0} {
        set_port_property avm_arbiterlock          TERMINATION 1
    }
    if {$USE_LOCK_VALUE == 0} {
        set_port_property avm_lock                 TERMINATION 1
    }
    if {$USE_DEBUGACCESS_VALUE == 0} {
        set_port_property avm_debugaccess          TERMINATION 1
    }
    if {$USE_WAIT_REQUEST_VALUE == 0} {
        set_port_property avm_waitrequest          TERMINATION 1
        set_port_property avm_waitrequest          TERMINATION_VALUE 0
    }
    if {$USE_WRITE_VALUE == 0} {
        set_port_property avm_write                TERMINATION 1
    }
    if {$USE_READ_VALUE == 0} {
        set_port_property avm_read                 TERMINATION 1
    }
    if {$USE_ADDRESS_VALUE == 0} {
        set_port_property avm_address              TERMINATION 1
        set_parameter_property $AV_ADDRESS_W ENABLED false
    } else {
        set_parameter_property $AV_ADDRESS_W ENABLED true
    }
    
    if {$USE_BYTE_ENABLE_VALUE == 0} {
        set_port_property avm_byteenable           TERMINATION 1
    }
    if {$USE_BURSTCOUNT_VALUE == 0} {
        set_port_property avm_burstcount           TERMINATION 1
        set_parameter_property $AV_BURSTCOUNT_W ENABLED false
    } else {
        set_parameter_property $AV_BURSTCOUNT_W ENABLED true
    }
    if {$USE_READ_DATA_VALUE == 0 } {
        set_port_property avm_readdata             TERMINATION 1
        set_port_property avm_readdata             TERMINATION_VALUE 0
    }
    if {$USE_READ_DATA_VALID_VALUE == 0} {
        set_port_property avm_readdatavalid        TERMINATION 1
        set_port_property avm_readdatavalid        TERMINATION_VALUE 0
    }
    if {$USE_WRITE_DATA_VALUE == 0 } {
        set_port_property avm_writedata            TERMINATION 1
    }
    if {$USE_BEGIN_TRANSFER_VALUE == 0 } {
        set_port_property avm_begintransfer        TERMINATION 1
    }
    if { $USE_BEGIN_BURST_TRANSFER_VALUE == 0 } {
        set_port_property avm_beginbursttransfer   TERMINATION 1
    }
    if { $USE_CLKEN_VALUE == 0 } {
        set_port_property avm_clken                    TERMINATION 1
    }
    
    #---------------------------------------------------------------------    

}
