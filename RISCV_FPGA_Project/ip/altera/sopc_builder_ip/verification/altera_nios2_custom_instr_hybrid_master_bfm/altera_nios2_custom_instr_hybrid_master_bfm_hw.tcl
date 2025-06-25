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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_nios2_custom_instr_hybrid_master_bfm/altera_nios2_custom_instr_hybrid_master_bfm_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
#------------------------------------------------------------------------------
package require -exact sopc 9.1

set_module_property DESCRIPTION                    "Altera Nios II Custom Instruction Hybrid Master BFM"
set_module_property NAME                           altera_nios2_custom_instr_hybrid_master_bfm
set_module_property VERSION        		            13.1
set_module_property GROUP          		            "Avalon Verification Suite"
set_module_property AUTHOR           	 	         "Altera Corporation"
set_module_property DISPLAY_NAME                   "Altera Nios II Custom Instruction Hybrid Master BFM"
set_module_property TOP_LEVEL_HDL_FILE             altera_nios2_custom_instr_hybrid_master_bfm.sv
set_module_property TOP_LEVEL_HDL_MODULE           altera_nios2_custom_instr_hybrid_master_bfm
set_module_property INSTANTIATE_IN_SYSTEM_MODULE   true
set_module_property EDITABLE                       false
set_module_property INTERNAL 			               true
set_module_property ELABORATION_CALLBACK           elaborate
set_module_property ANALYZE_HDL                    false

#---------------------------------------------------------------------
# Files
#---------------------------------------------------------------------
set HDL_LIB_DIR "../lib"
set CI_MST_DIR "../altera_nios2_custom_instr_master_bfm"

add_file $HDL_LIB_DIR/verbosity_pkg.sv                         {SIMULATION}
add_file $CI_MST_DIR/altera_nios2_custom_instr_master_bfm.sv   {SIMULATION}
add_file altera_nios2_custom_instr_hybrid_master_bfm.sv        {SIMULATION}

#---------------------------------------------------------------------
# Parameters
#---------------------------------------------------------------------
set NUM_OPERANDS_MULTI     "NUM_OPERANDS_MULTI"
set USE_RESULT_MULTI       "USE_RESULT_MULTI"
set USE_READRA_MULTI       "USE_READRA_MULTI"
set USE_READRB_MULTI       "USE_READRB_MULTI"
set USE_WRITERC_MULTI      "USE_WRITERC_MULTI"
set NUM_OPERANDS_COMBO     "NUM_OPERANDS_COMBO"
set USE_RESULT_COMBO       "USE_RESULT_COMBO"
set USE_READRA_COMBO       "USE_READRA_COMBO"
set USE_READRB_COMBO       "USE_READRB_COMBO"
set USE_WRITERC_COMBO      "USE_WRITERC_COMBO"
set EXT_WIDTH              "EXT_WIDTH"

add_parameter $NUM_OPERANDS_MULTI Integer 2
set_parameter_property $NUM_OPERANDS_MULTI DISPLAY_NAME "Number of Operands (Multi-cycle)"
set_parameter_property $NUM_OPERANDS_MULTI AFFECTS_ELABORATION true
set_parameter_property $NUM_OPERANDS_MULTI DESCRIPTION "Include dataa and/or datab port for Multi Cycles Master"
set_parameter_property $NUM_OPERANDS_MULTI HDL_PARAMETER true
set_parameter_property $NUM_OPERANDS_MULTI ALLOWED_RANGES "0:2"
set_parameter_property $NUM_OPERANDS_MULTI GROUP "General"

add_parameter $USE_RESULT_MULTI Integer 1
set_parameter_property $USE_RESULT_MULTI DISPLAY_NAME "Use Result Port (Multi-cycle)"
set_parameter_property $USE_RESULT_MULTI AFFECTS_ELABORATION true
set_parameter_property $USE_RESULT_MULTI DESCRIPTION "Include the result port for Multi Cycles Master"
set_parameter_property $USE_RESULT_MULTI HDL_PARAMETER true
set_parameter_property $USE_RESULT_MULTI DISPLAY_HINT boolean
set_parameter_property $USE_RESULT_MULTI GROUP "Port Enables"

add_parameter $USE_READRA_MULTI Integer 0
set_parameter_property $USE_READRA_MULTI DISPLAY_NAME "Use Internal Register a (Multi-cycle)"
set_parameter_property $USE_READRA_MULTI AFFECTS_ELABORATION true
set_parameter_property $USE_READRA_MULTI DESCRIPTION "Include the ports readra and a for Multi Cycles Master"
set_parameter_property $USE_READRA_MULTI HDL_PARAMETER true
set_parameter_property $USE_READRA_MULTI DISPLAY_HINT boolean
set_parameter_property $USE_READRA_MULTI GROUP "Port Enables"

add_parameter $USE_READRB_MULTI Integer 0
set_parameter_property $USE_READRB_MULTI DISPLAY_NAME "Use Internal Register b (Multi-cycle)"
set_parameter_property $USE_READRB_MULTI AFFECTS_ELABORATION true
set_parameter_property $USE_READRB_MULTI DESCRIPTION "Include the ports readrb and b for Multi Cycles Master"
set_parameter_property $USE_READRB_MULTI HDL_PARAMETER true
set_parameter_property $USE_READRB_MULTI DISPLAY_HINT boolean
set_parameter_property $USE_READRB_MULTI GROUP "Port Enables"

add_parameter $USE_WRITERC_MULTI Integer 0
set_parameter_property $USE_WRITERC_MULTI DISPLAY_NAME "Use Internal Register c (Multi-cycle)"
set_parameter_property $USE_WRITERC_MULTI AFFECTS_ELABORATION true
set_parameter_property $USE_WRITERC_MULTI DESCRIPTION "Include the ports writerc and c for Multi Cycles Master"
set_parameter_property $USE_WRITERC_MULTI HDL_PARAMETER true
set_parameter_property $USE_WRITERC_MULTI DISPLAY_HINT boolean
set_parameter_property $USE_WRITERC_MULTI GROUP "Port Enables"

add_parameter $NUM_OPERANDS_COMBO Integer 2
set_parameter_property $NUM_OPERANDS_COMBO DISPLAY_NAME "Number of Operands (Combinatorial)"
set_parameter_property $NUM_OPERANDS_COMBO AFFECTS_ELABORATION true
set_parameter_property $NUM_OPERANDS_COMBO DESCRIPTION "Include dataa and/or datab port for Combinatorial Master"
set_parameter_property $NUM_OPERANDS_COMBO HDL_PARAMETER true
set_parameter_property $NUM_OPERANDS_COMBO ALLOWED_RANGES "0:2"
set_parameter_property $NUM_OPERANDS_COMBO GROUP "General"

add_parameter $USE_RESULT_COMBO Integer 1
set_parameter_property $USE_RESULT_COMBO DISPLAY_NAME "Use Result Port (Combinatorial)"
set_parameter_property $USE_RESULT_COMBO AFFECTS_ELABORATION true
set_parameter_property $USE_RESULT_COMBO DESCRIPTION "Include the result port for Combinatorial Master"
set_parameter_property $USE_RESULT_COMBO HDL_PARAMETER true
set_parameter_property $USE_RESULT_COMBO DISPLAY_HINT boolean
set_parameter_property $USE_RESULT_COMBO GROUP "Port Enables"

add_parameter $USE_READRA_COMBO Integer 0
set_parameter_property $USE_READRA_COMBO DISPLAY_NAME "Use Internal Register a (Combinatorial)"
set_parameter_property $USE_READRA_COMBO AFFECTS_ELABORATION true
set_parameter_property $USE_READRA_COMBO DESCRIPTION "Include the ports readra and a for Combinatorial Master"
set_parameter_property $USE_READRA_COMBO HDL_PARAMETER true
set_parameter_property $USE_READRA_COMBO DISPLAY_HINT boolean
set_parameter_property $USE_READRA_COMBO GROUP "Port Enables"

add_parameter $USE_READRB_COMBO Integer 0
set_parameter_property $USE_READRB_COMBO DISPLAY_NAME "Use Internal Register b (Combinatorial)"
set_parameter_property $USE_READRB_COMBO AFFECTS_ELABORATION true
set_parameter_property $USE_READRB_COMBO DESCRIPTION "Include the ports readrb and b for Combinatorial Master"
set_parameter_property $USE_READRB_COMBO HDL_PARAMETER true
set_parameter_property $USE_READRB_COMBO DISPLAY_HINT boolean
set_parameter_property $USE_READRB_COMBO GROUP "Port Enables"

add_parameter $USE_WRITERC_COMBO Integer 0
set_parameter_property $USE_WRITERC_COMBO DISPLAY_NAME "Use Internal Register c (Combinatorial)"
set_parameter_property $USE_WRITERC_COMBO AFFECTS_ELABORATION true
set_parameter_property $USE_WRITERC_COMBO DESCRIPTION "Include the ports writerc and c for Combinatorial Master"
set_parameter_property $USE_WRITERC_COMBO HDL_PARAMETER true
set_parameter_property $USE_WRITERC_COMBO DISPLAY_HINT boolean
set_parameter_property $USE_WRITERC_COMBO GROUP "Port Enables"

add_parameter $EXT_WIDTH Integer 1
set_parameter_property $EXT_WIDTH DISPLAY_NAME "Extended Port Width"
set_parameter_property $EXT_WIDTH AFFECTS_ELABORATION true
set_parameter_property $EXT_WIDTH DESCRIPTION "Width of the ports n for both masters"
set_parameter_property $EXT_WIDTH HDL_PARAMETER true
set_parameter_property $EXT_WIDTH ALLOWED_RANGES {1:8}
set_parameter_property $EXT_WIDTH GROUP "Port Enables"

#------------------------------------------------------------------------------
proc elaborate {} {
    global NUM_OPERANDS_MULTI
    global USE_RESULT_MULTI
    global USE_READRA_MULTI
    global USE_READRB_MULTI
    global USE_WRITERC_MULTI
    global NUM_OPERANDS_COMBO
    global USE_RESULT_COMBO
    global USE_READRA_COMBO
    global USE_READRB_COMBO
    global USE_WRITERC_COMBO
    global EXT_WIDTH

    set NUM_OPERANDS_MULTI_VALUE    [ get_parameter $NUM_OPERANDS_MULTI ]
    set USE_RESULT_MULTI_VALUE      [ get_parameter $USE_RESULT_MULTI ]
    set USE_READRA_MULTI_VALUE      [ get_parameter $USE_READRA_MULTI ]
    set USE_READRB_MULTI_VALUE      [ get_parameter $USE_READRB_MULTI ]
    set USE_WRITERC_MULTI_VALUE     [ get_parameter $USE_WRITERC_MULTI ]
    set NUM_OPERANDS_COMBO_VALUE    [ get_parameter $NUM_OPERANDS_COMBO ]
    set USE_RESULT_COMBO_VALUE      [ get_parameter $USE_RESULT_COMBO ]
    set USE_READRA_COMBO_VALUE      [ get_parameter $USE_READRA_COMBO ]
    set USE_READRB_COMBO_VALUE      [ get_parameter $USE_READRB_COMBO ]
    set USE_WRITERC_COMBO_VALUE     [ get_parameter $USE_WRITERC_COMBO ]
    set EXT_WIDTH_VALUE             [ get_parameter $EXT_WIDTH ]

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
    set_interface_property $CUSTOM_INSTR_INTERFACE opcodeExtension   1
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

    add_interface_port $CUSTOM_INSTR_INTERFACE multi_clk       clk               Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_reset     reset             Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_clk_en    clk_en            Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_start     start       Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_done      done        Input  1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_dataa     multi_dataa       Output 32
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_datab     multi_datab       Output 32
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_result    multi_result      Input  32
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_n         multi_n           Output $EXT_WIDTH_VALUE
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_a         multi_a           Output 5
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_b         multi_b           Output 5
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_c         multi_c           Output 5
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_readra    multi_readra      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_readrb    multi_readrb      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE multi_writerc   multi_writerc     Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_dataa     dataa       Output 32
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_datab     datab       Output 32
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_result    result      Input  32
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_n         n           Output $EXT_WIDTH_VALUE
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_a         a           Output 5
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_b         b           Output 5
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_c         c           Output 5
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_readra    readra      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_readrb    readrb      Output 1
    add_interface_port $CUSTOM_INSTR_INTERFACE combo_writerc   writerc     Output 1

    #---------------------------------------------------------------------
    # Terminate unused ports
    #---------------------------------------------------------------------
    if { $NUM_OPERANDS_MULTI_VALUE == 1 } {
      send_message Info "Multi-cycle master has only one operand - terminating port multi_datab"
    	set_port_property multi_datab    TERMINATION 1
    } elseif { $NUM_OPERANDS_MULTI_VALUE == 0 } {
      send_message Info "Multi-cycle master has no operands - terminating ports multi_dataa and multi_datab"
    	set_port_property multi_dataa    TERMINATION 1
    	set_port_property multi_datab    TERMINATION 1
    }
    if { $USE_RESULT_MULTI_VALUE == 0 } {
      send_message Info "Multi-cycle master does not use result - terminating port multi_result"
    	set_port_property multi_result   TERMINATION 1
    }
    if { $USE_READRA_MULTI_VALUE == 0 } {
      send_message Info "Multi-cycle master Use Register a set to zero - terminating port multi_a and multi_readra ports"
    	set_port_property multi_a        TERMINATION 1
    	set_port_property multi_readra   TERMINATION 1
    }
    if { $USE_READRB_MULTI_VALUE == 0 } {
      send_message Info "Multi-cycle master Use Register b set to zero - terminating port multi_b and multi_readrb ports"
    	set_port_property multi_b        TERMINATION 1
    	set_port_property multi_readrb   TERMINATION 1
    }
    if { $USE_WRITERC_MULTI_VALUE == 0 } {
      send_message Info "Multi-cycle master Use Register c set to zero - terminating port multi_c and multi_writerc ports"
    	set_port_property multi_c        TERMINATION 1
    	set_port_property multi_writerc  TERMINATION 1
    }
    if { $NUM_OPERANDS_COMBO_VALUE == 1 } {
      send_message Info "Combinatorial master has only one operand - terminating port combo_datab"
    	set_port_property combo_datab    TERMINATION 1
    } elseif { $NUM_OPERANDS_COMBO_VALUE == 0 } {
      send_message Info "Combinatorial master has no operands - terminating ports combo_dataa and combo_datab"
    	set_port_property combo_dataa    TERMINATION 1
    	set_port_property combo_datab    TERMINATION 1
    }
    if { $USE_RESULT_COMBO_VALUE == 0 } {
      send_message Info "Combinatorial master does not use result - terminating port combo_result"
    	set_port_property combo_result   TERMINATION 1
    }
    if { $USE_READRA_COMBO_VALUE == 0 } {
      send_message Info "Combinatorial master Use Register a set to zero - terminating port combo_a and combo_readra ports"
    	set_port_property combo_a        TERMINATION 1
    	set_port_property combo_readra   TERMINATION 1
    }
    if { $USE_READRB_COMBO_VALUE == 0 } {
      send_message Info "Combinatorial master Use Register b set to zero - terminating port combo_b and combo_readrb ports"
    	set_port_property combo_b        TERMINATION 1
    	set_port_property combo_readrb   TERMINATION 1
    }
    if { $USE_WRITERC_COMBO_VALUE == 0 } {
      send_message Info "Combinatorial master Use Register c set to zero - terminating port combo_c and combo_writerc ports"
    	set_port_property combo_c        TERMINATION 1
    	set_port_property combo_writerc  TERMINATION 1
    }

}


