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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_nios2_custom_instr_master_bfm/altera_nios2_custom_instr_master_bfm_hw.tcl#2 $
# $Revision: #2 $
# $Date: 2013/08/15 $
# $Author: saafnan $
#------------------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property DESCRIPTION                    "Altera Nios II Custom Instruction Master BFM"
set_module_property NAME                           altera_nios2_custom_instr_master_bfm
set_module_property VERSION        		            13.1
set_module_property GROUP          		            "Avalon Verification Suite"
set_module_property AUTHOR           	 	         "Altera Corporation"
set_module_property DISPLAY_NAME                   "Altera Nios II Custom Instruction Master BFM"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE   true
set_module_property EDITABLE                       false
set_module_property INTERNAL 			               false
set_module_property ELABORATION_CALLBACK           elaborate
set_module_property ANALYZE_HDL                    false

# ---------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------
# Define file set
add_fileset sim_verilog SIM_VERILOG sim_verilog
set_fileset_property sim_verilog top_level altera_nios2_custom_instr_master_bfm

add_fileset sim_vhdl SIM_VHDL sim_vhdl
set_fileset_property sim_vhdl top_level altera_nios2_custom_instr_master_bfm_vhdl

# SIM_VERILOG generation callback procedure
proc sim_verilog {altera_nios2_custom_instr_master_bfm} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv"
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv"
   add_fileset_file altera_nios2_custom_instr_master_bfm.sv SYSTEM_VERILOG PATH "altera_nios2_custom_instr_master_bfm.sv" 
   
   set_fileset_file_attribute verbosity_pkg.sv           COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv    COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
}

# SIM_VHDL generation callback procedure
proc sim_vhdl {altera_nios2_custom_instr_master_bfm_vhdl} {
   set HDL_LIB_DIR   "../lib"
   set VHDL_DIR      "../[get_module_property NAME]_vhdl";
   
   if {1} {
      add_fileset_file mentor/verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/verbosity_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/avalon_utilities_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_nios2_custom_instr_master_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_nios2_custom_instr_master_bfm.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_nios2_custom_instr_master_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_nios2_custom_instr_master_bfm_vhdl_wrapper.sv" {MENTOR_SPECIFIC}
   
      set_fileset_file_attribute mentor/verbosity_pkg.sv           COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_verbosity_pkg
      set_fileset_file_attribute mentor/avalon_utilities_pkg.sv    COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_avalon_utilities_pkg
   }

   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/verbosity_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_nios2_custom_instr_master_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_nios2_custom_instr_master_bfm.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_nios2_custom_instr_master_bfm_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_nios2_custom_instr_master_bfm_vhdl_wrapper.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   
   set_fileset_file_attribute verbosity_pkg.sv           COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv    COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
   
   add_fileset_file altera_nios2_custom_instr_master_bfm_vhdl_pkg.vhd VHDL path "$VHDL_DIR/altera_nios2_custom_instr_master_bfm_vhdl_pkg.vhd"
   add_fileset_file altera_nios2_custom_instr_master_bfm_vhdl.vhd VHDL path "$VHDL_DIR/altera_nios2_custom_instr_master_bfm_vhdl.vhd"

}

add_documentation_link "User Guide" "http://www.altera.com/literature/ug/ug_avalon_verification_ip.pdf"
#---------------------------------------------------------------------
# Parameters
#---------------------------------------------------------------------
set NUM_OPERANDS        "NUM_OPERANDS"
set USE_RESULT          "USE_RESULT"
set USE_MULTI_CYCLE     "USE_MULTI_CYCLE"
set FIXED_LENGTH        "FIXED_LENGTH"
set USE_START           "USE_START"
set USE_DONE            "USE_DONE"
set USE_EXTENSION       "USE_EXTENSION"
set EXT_WIDTH           "EXT_WIDTH"
set USE_READRA          "USE_READRA"
set USE_READRB          "USE_READRB"
set USE_WRITERC         "USE_WRITERC"
set VHDL_ID             "VHDL_ID"

add_parameter $NUM_OPERANDS Integer 2
set_parameter_property $NUM_OPERANDS DISPLAY_NAME "Number of Operands to Use"
set_parameter_property $NUM_OPERANDS AFFECTS_ELABORATION true
set_parameter_property $NUM_OPERANDS DESCRIPTION "Include dataa and/or datab port"
set_parameter_property $NUM_OPERANDS HDL_PARAMETER true
set_parameter_property $NUM_OPERANDS ALLOWED_RANGES "0:2"
set_parameter_property $NUM_OPERANDS GROUP "General"

add_parameter $USE_RESULT Integer 1
set_parameter_property $USE_RESULT DISPLAY_NAME "Use Result Port"
set_parameter_property $USE_RESULT AFFECTS_ELABORATION true
set_parameter_property $USE_RESULT DESCRIPTION "Include the result port"
set_parameter_property $USE_RESULT HDL_PARAMETER true
set_parameter_property $USE_RESULT DISPLAY_HINT boolean
set_parameter_property $USE_RESULT GROUP "Port Enables"

add_parameter $USE_MULTI_CYCLE Integer 0
set_parameter_property $USE_MULTI_CYCLE DISPLAY_NAME "Use Multi-cycle Mode"
set_parameter_property $USE_MULTI_CYCLE AFFECTS_ELABORATION true
set_parameter_property $USE_MULTI_CYCLE DESCRIPTION "Include the start and done port"
set_parameter_property $USE_MULTI_CYCLE HDL_PARAMETER true
set_parameter_property $USE_MULTI_CYCLE DISPLAY_HINT boolean
set_parameter_property $USE_MULTI_CYCLE GROUP "Port Enables"

add_parameter $FIXED_LENGTH Integer 2
set_parameter_property $FIXED_LENGTH DISPLAY_NAME "Fixed Length for Multi-cycle Mode"
set_parameter_property $FIXED_LENGTH AFFECTS_ELABORATION true
set_parameter_property $FIXED_LENGTH DESCRIPTION "The fixed length for multi-cycle mode; 1 means variable length"
set_parameter_property $FIXED_LENGTH HDL_PARAMETER true
set_parameter_property $FIXED_LENGTH ALLOWED_RANGES {2:8}
set_parameter_property $FIXED_LENGTH GROUP "General"

add_parameter $USE_START Integer 1
set_parameter_property $USE_START DISPLAY_NAME "Using start port"
set_parameter_property $USE_START AFFECTS_ELABORATION true
set_parameter_property $USE_START DESCRIPTION "Port start enable"
set_parameter_property $USE_START HDL_PARAMETER true
set_parameter_property $USE_START DISPLAY_HINT boolean
set_parameter_property $USE_START GROUP "Port Enables"

add_parameter $USE_DONE Integer 1
set_parameter_property $USE_DONE DISPLAY_NAME "Using done port"
set_parameter_property $USE_DONE AFFECTS_ELABORATION true
set_parameter_property $USE_DONE DESCRIPTION "Port done enable"
set_parameter_property $USE_DONE HDL_PARAMETER true
set_parameter_property $USE_DONE DISPLAY_HINT boolean
set_parameter_property $USE_DONE GROUP "Port Enables"

add_parameter $USE_EXTENSION Integer 0
set_parameter_property $USE_EXTENSION DISPLAY_NAME "Use Extended Port"
set_parameter_property $USE_EXTENSION AFFECTS_ELABORATION true
set_parameter_property $USE_EXTENSION DESCRIPTION "Include the ports n"
set_parameter_property $USE_EXTENSION HDL_PARAMETER true
set_parameter_property $USE_EXTENSION DISPLAY_HINT boolean
set_parameter_property $USE_EXTENSION GROUP "Port Enables"

add_parameter $EXT_WIDTH Integer 1
set_parameter_property $EXT_WIDTH DISPLAY_NAME "Extended Port Width"
set_parameter_property $EXT_WIDTH AFFECTS_ELABORATION true
set_parameter_property $EXT_WIDTH DESCRIPTION "Width of the ports n"
set_parameter_property $EXT_WIDTH HDL_PARAMETER true
set_parameter_property $EXT_WIDTH ALLOWED_RANGES {1:8}
set_parameter_property $EXT_WIDTH GROUP "Port Enables"

add_parameter $USE_READRA Integer 0
set_parameter_property $USE_READRA DISPLAY_NAME "Use Internal Register a"
set_parameter_property $USE_READRA AFFECTS_ELABORATION true
set_parameter_property $USE_READRA DESCRIPTION "Include the ports readra and a"
set_parameter_property $USE_READRA HDL_PARAMETER true
set_parameter_property $USE_READRA DISPLAY_HINT boolean
set_parameter_property $USE_READRA GROUP "Port Enables"

add_parameter $USE_READRB Integer 0
set_parameter_property $USE_READRB DISPLAY_NAME "Use Internal Register b"
set_parameter_property $USE_READRB AFFECTS_ELABORATION true
set_parameter_property $USE_READRB DESCRIPTION "Include the ports readrb and b"
set_parameter_property $USE_READRB HDL_PARAMETER true
set_parameter_property $USE_READRB DISPLAY_HINT boolean
set_parameter_property $USE_READRB GROUP "Port Enables"

add_parameter $USE_WRITERC Integer 0
set_parameter_property $USE_WRITERC DISPLAY_NAME "Use Internal Register c"
set_parameter_property $USE_WRITERC AFFECTS_ELABORATION true
set_parameter_property $USE_WRITERC DESCRIPTION "Include the ports writerc and c"
set_parameter_property $USE_WRITERC HDL_PARAMETER true
set_parameter_property $USE_WRITERC DISPLAY_HINT boolean
set_parameter_property $USE_WRITERC GROUP "Port Enables"

add_parameter $VHDL_ID Integer 0
set_parameter_property $VHDL_ID DISPLAY_NAME "VHDL BFM ID"
set_parameter_property $VHDL_ID DESCRIPTION "BFM ID number for VHDL"
set_parameter_property $VHDL_ID HDL_PARAMETER true
set_parameter_property $VHDL_ID ALLOWED_RANGES {0:1023}
set_parameter_property $VHDL_ID GROUP "VHDL BFM"

#------------------------------------------------------------------------------
proc elaborate {} {
    global NUM_OPERANDS
    global USE_RESULT
    global USE_MULTI_CYCLE
    global FIXED_LENGTH
    global USE_START
    global USE_DONE
    global USE_EXTENSION
    global EXT_WIDTH
    global USE_READRA
    global USE_READRB
    global USE_WRITERC

    set NUM_OPERANDS_VALUE    [ get_parameter $NUM_OPERANDS ]
    set USE_RESULT_VALUE      [ get_parameter $USE_RESULT ]
    set USE_MULTI_CYCLE_VALUE [ get_parameter $USE_MULTI_CYCLE ]
    set FIXED_LENGTH_VALUE    [ get_parameter $FIXED_LENGTH ]
    set USE_START_VALUE       [ get_parameter $USE_START ]
    set USE_DONE_VALUE        [ get_parameter $USE_DONE ]
    set USE_EXTENSION_VALUE   [ get_parameter $USE_EXTENSION ]
    set EXT_WIDTH_VALUE       [ get_parameter $EXT_WIDTH ]
    set USE_READRA_VALUE      [ get_parameter $USE_READRA ]
    set USE_READRB_VALUE      [ get_parameter $USE_READRB ]
    set USE_WRITERC_VALUE     [ get_parameter $USE_WRITERC ]

    #---------------------------------------------------------------------
    # Clock connection point
    #---------------------------------------------------------------------
    set CLOCK_INTERFACE  "clock"
    add_interface $CLOCK_INTERFACE clock end

    set_interface_property $CLOCK_INTERFACE ENABLED true
    add_interface_port $CLOCK_INTERFACE clk clk Input 1

    #---------------------------------------------------------------------
    # Reset connection point
    #---------------------------------------------------------------------
    set RESET_INTERFACE  "reset"
    add_interface $RESET_INTERFACE reset end

    set_interface_property $RESET_INTERFACE ENABLED true
    set_interface_property $RESET_INTERFACE associatedClock "clock"
    add_interface_port $RESET_INTERFACE reset reset Input 1

    #---------------------------------------------------------------------
    #  NiosII combinatorial custom instruction master connection point
    #---------------------------------------------------------------------
    set CUSTOM_INSTR_INTERFACE "master"
    add_interface $CUSTOM_INSTR_INTERFACE nios_custom_instruction master

    set_interface_property $CUSTOM_INSTR_INTERFACE enabled true
    set_interface_property $CUSTOM_INSTR_INTERFACE opcodeExtension   $USE_EXTENSION_VALUE
    if { $USE_MULTI_CYCLE_VALUE == 0 } {
      set_interface_property $CUSTOM_INSTR_INTERFACE clockCycle      0
    } elseif { $USE_DONE_VALUE == 1 } {
      set_interface_property $CUSTOM_INSTR_INTERFACE clockCycle      0
    } else {
      set_interface_property $CUSTOM_INSTR_INTERFACE clockCycle      $FIXED_LENGTH_VALUE
    }
    
    #---------------------------------------------------------------------
    # add ports to interface
    #---------------------------------------------------------------------

    add_interface_port $CUSTOM_INSTR_INTERFACE ci_dataa     dataa       Output 32
    set_port_property ci_dataa VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_datab     datab       Output 32
    set_port_property ci_datab VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_result    result      Input  32
    set_port_property ci_result VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_clk       clk         Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_reset     reset       Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_clk_en    clk_en      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_start     start       Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_done      done        Input  1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_n         n           Output $EXT_WIDTH_VALUE
    set_port_property ci_n VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_a         a           Output 5
    set_port_property ci_a VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_b         b           Output 5
    set_port_property ci_b VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_c         c           Output 5
    set_port_property ci_c VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_readra    readra      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_readrb    readrb      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE ci_writerc   writerc     Output 1

    #---------------------------------------------------------------------
    # Terminate unused ports
    #---------------------------------------------------------------------
    if { $USE_MULTI_CYCLE_VALUE == 0 } {
      send_message Info "Combinatorial mode - terminating port ci_clk_en"
    	set_port_property ci_clk      TERMINATION 1
    	set_port_property ci_reset    TERMINATION 1
    	set_port_property ci_clk_en   TERMINATION 1
    }
    if { $NUM_OPERANDS_VALUE == 1 } {
      send_message Info "Custom Instruction has only one operand - terminating port ci_datab"
    	set_port_property ci_datab    TERMINATION 1
    } elseif { $NUM_OPERANDS_VALUE == 0 } {
      send_message Info "Custom Instruction has no operands - terminating ports ci_dataa and ci_datab"
    	set_port_property ci_dataa    TERMINATION 1
    	set_port_property ci_datab    TERMINATION 1
    }
    if { $USE_RESULT_VALUE == 0 } {
      send_message Info "Custom Instruction does not use result - terminating port ci_result"
    	set_port_property ci_result   TERMINATION 1
    }
    if { ($USE_MULTI_CYCLE_VALUE == 0) || (($USE_MULTI_CYCLE_VALUE == 1) && ($USE_DONE_VALUE == 0) && ($USE_START_VALUE == 0)) } {
      send_message Info "Use multi cycle set to zero or using fixed length - terminating port ci_start"
    	set_port_property ci_start    TERMINATION 1
    }
    if { ($USE_MULTI_CYCLE_VALUE == 0) || (($USE_MULTI_CYCLE_VALUE == 1) && ($USE_DONE_VALUE == 0)) } {
      send_message Info "Use multi cycle set to zero or using fixed length - terminating port ci_done"
    	set_port_property ci_done     TERMINATION 1
    }
    if { $USE_EXTENSION_VALUE == 0 } {
      send_message Info "Use Extension set to zero - terminating port ci_n"
    	set_port_property ci_n        TERMINATION 1
      set_parameter_property $EXT_WIDTH ENABLED false
    } else {
      set_parameter_property $EXT_WIDTH ENABLED true
    }
    if { $USE_READRA_VALUE == 0 } {
      send_message Info "Use Register a set to zero - terminating port ci_a and ci_readra ports"
    	set_port_property ci_a        TERMINATION 1
    	set_port_property ci_readra   TERMINATION 1
    }
    if { $USE_READRB_VALUE == 0 } {
      send_message Info "Use Register b set to zero - terminating port ci_b and ci_readrb ports"
    	set_port_property ci_b        TERMINATION 1
    	set_port_property ci_readrb   TERMINATION 1
    }
    if { $USE_WRITERC_VALUE == 0 } {
      send_message Info "Use Register c set to zero - terminating port ci_c and ci_writerc ports"
    	set_port_property ci_c        TERMINATION 1
    	set_port_property ci_writerc  TERMINATION 1
    }

}


