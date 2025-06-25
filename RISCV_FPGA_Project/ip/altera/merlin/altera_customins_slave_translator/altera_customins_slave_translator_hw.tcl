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
# | Custom instruction slave translator
# +-----------------------------------

package require -exact sopc 10.0

# +-----------------------------------
# | 
set_module_property NAME altera_customins_slave_translator
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Custom Instruction Slave Translator"
set_module_property TOP_LEVEL_HDL_MODULE altera_customins_slave_translator
set_module_property TOP_LEVEL_HDL_FILE altera_customins_slave_translator.sv
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

add_file altera_customins_slave_translator.sv { SYNTHESIS SIMULATION }

# +-----------------------------------
# | Parameters
# |

add_parameter USE_DATAA INTEGER 1 
set_parameter_property USE_DATAA AFFECTS_ELABORATION true
set_parameter_property USE_DATAA ALLOWED_RANGES "0:1"
set_parameter_property USE_DATAA DISPLAY_HINT "boolean"

add_parameter USE_DATAB INTEGER 1 
set_parameter_property USE_DATAB AFFECTS_ELABORATION true
set_parameter_property USE_DATAB ALLOWED_RANGES "0:1"
set_parameter_property USE_DATAB DISPLAY_HINT "boolean"

add_parameter USE_N INTEGER 1 
set_parameter_property USE_N AFFECTS_ELABORATION true
set_parameter_property USE_N ALLOWED_RANGES "0:1"
set_parameter_property USE_N DISPLAY_HINT "boolean"

add_parameter N_WIDTH INTEGER 8 
set_parameter_property N_WIDTH AFFECTS_ELABORATION true
set_parameter_property N_WIDTH ALLOWED_RANGES "1:8"
set_parameter_property N_WIDTH HDL_PARAMETER true

add_parameter USE_READRA INTEGER 1 
set_parameter_property USE_READRA AFFECTS_ELABORATION true
set_parameter_property USE_READRA ALLOWED_RANGES "0:1"
set_parameter_property USE_READRA DISPLAY_HINT "boolean"

add_parameter USE_READRB INTEGER 1 
set_parameter_property USE_READRB AFFECTS_ELABORATION true
set_parameter_property USE_READRB ALLOWED_RANGES "0:1"
set_parameter_property USE_READRB DISPLAY_HINT "boolean"

add_parameter USE_WRITERC INTEGER 1 
set_parameter_property USE_WRITERC AFFECTS_ELABORATION true
set_parameter_property USE_WRITERC ALLOWED_RANGES "0:1"
set_parameter_property USE_WRITERC DISPLAY_HINT "boolean"

add_parameter USE_IPENDING INTEGER 1 
set_parameter_property USE_IPENDING AFFECTS_ELABORATION true
set_parameter_property USE_IPENDING ALLOWED_RANGES "0:1"
set_parameter_property USE_IPENDING DISPLAY_HINT "boolean"

add_parameter USE_ESTATUS INTEGER 1 
set_parameter_property USE_ESTATUS AFFECTS_ELABORATION true
set_parameter_property USE_ESTATUS ALLOWED_RANGES "0:1"
set_parameter_property USE_ESTATUS DISPLAY_HINT "boolean"

add_parameter USE_RESET_REQUEST INTEGER 0
set_parameter_property USE_RESET_REQUEST AFFECTS_ELABORATION true
set_parameter_property USE_RESET_REQUEST ALLOWED_RANGES "0:1"
set_parameter_property USE_RESET_REQUEST DISPLAY_HINT "boolean"

add_parameter ENABLE_MULTICYCLE INTEGER 0
set_parameter_property ENABLE_MULTICYCLE AFFECTS_ELABORATION true
set_parameter_property ENABLE_MULTICYCLE ALLOWED_RANGES "0:1"
set_parameter_property ENABLE_MULTICYCLE DISPLAY_HINT "boolean"

add_parameter USE_START INTEGER 1
set_parameter_property USE_START AFFECTS_ELABORATION true
set_parameter_property USE_START ALLOWED_RANGES "0:1"
set_parameter_property USE_START DISPLAY_HINT "boolean"

add_parameter USE_DONE INTEGER 1
set_parameter_property USE_DONE AFFECTS_ELABORATION true
set_parameter_property USE_DONE ALLOWED_RANGES "0:1"
set_parameter_property USE_DONE DISPLAY_HINT "boolean"
set_parameter_property USE_DONE HDL_PARAMETER true

add_parameter NUM_FIXED_CYCLES INTEGER 2
set_parameter_property NUM_FIXED_CYCLES AFFECTS_ELABORATION true
set_parameter_property NUM_FIXED_CYCLES ALLOWED_RANGES "0:128"
set_parameter_property NUM_FIXED_CYCLES HDL_PARAMETER true
# | 
# +-----------------------------------


add_interface ci_slave nios_custom_instruction slave
add_interface ci_master nios_custom_instruction master

add_interface_port ci_master ci_master_dataa dataa Output 32
add_interface_port ci_master ci_master_datab datab Output 32
add_interface_port ci_master ci_master_result result Input 32
add_interface_port ci_master ci_master_n n Output 8
add_interface_port ci_master ci_master_readra readra Output 1
add_interface_port ci_master ci_master_readrb readrb Output 1
add_interface_port ci_master ci_master_writerc writerc Output 1
add_interface_port ci_master ci_master_a a Output 5
add_interface_port ci_master ci_master_b b Output 5
add_interface_port ci_master ci_master_c c Output 5
add_interface_port ci_master ci_master_ipending ipending Output 32
add_interface_port ci_master ci_master_estatus estatus Output 1
add_interface_port ci_master ci_master_clk clk Output 1
add_interface_port ci_master ci_master_clken clk_en Output 1
add_interface_port ci_master ci_master_reset_req reset_req Output 1
add_interface_port ci_master ci_master_reset reset Output 1
add_interface_port ci_master ci_master_start start Output 1
add_interface_port ci_master ci_master_done done Input 1

add_interface_port ci_slave ci_slave_dataa dataa Input 32
add_interface_port ci_slave ci_slave_datab datab Input 32
add_interface_port ci_slave ci_slave_result result Output 32
add_interface_port ci_slave ci_slave_n n Input 8
add_interface_port ci_slave ci_slave_readra readra Input 1
add_interface_port ci_slave ci_slave_readrb readrb Input 1
add_interface_port ci_slave ci_slave_writerc writerc Input 1
add_interface_port ci_slave ci_slave_a a Input 5
add_interface_port ci_slave ci_slave_b b Input 5
add_interface_port ci_slave ci_slave_c c Input 5
add_interface_port ci_slave ci_slave_ipending ipending Input 32
add_interface_port ci_slave ci_slave_estatus estatus Input 1
add_interface_port ci_slave ci_slave_clk clk Input 1
add_interface_port ci_slave ci_slave_clken clk_en Input 1
add_interface_port ci_slave ci_slave_reset_req reset_req Input 1
add_interface_port ci_slave ci_slave_reset reset Input 1
add_interface_port ci_slave ci_slave_start start Input 1
add_interface_port ci_slave ci_slave_done done Output 1

proc elaborate {} {

    set use_dataa   [ get_parameter_value USE_DATAA ]
    set use_datab   [ get_parameter_value USE_DATAB ]
    set use_n       [ get_parameter_value USE_N ]
    set n_width     [ get_parameter_value N_WIDTH ]
    set use_readra  [ get_parameter_value USE_READRA ]
    set use_readrb  [ get_parameter_value USE_READRB ]
    set use_writerc [ get_parameter_value USE_WRITERC ]
    set en_multcy   [ get_parameter_value ENABLE_MULTICYCLE ]
    set use_start   [ get_parameter_value USE_START ]
    set use_done    [ get_parameter_value USE_DONE ]
    set use_ipend   [ get_parameter_value USE_IPENDING ]
    set use_estatus [ get_parameter_value USE_ESTATUS ]
    set use_reset_req [ get_parameter_value USE_RESET_REQUEST ]

    if { $use_dataa == 0 } {
        set_port_property ci_master_dataa TERMINATION true
    }

    if { $use_datab == 0 } {
        set_port_property ci_master_datab TERMINATION true
    }

    set_port_property ci_master_n WIDTH $n_width
    if { $use_n == 0 } {
        set_port_property ci_master_n TERMINATION true
    }

    if { $use_readra == 0 } {
        set_port_property ci_master_readra TERMINATION true
        set_port_property ci_master_a TERMINATION true
    }

    if { $use_readrb == 0 } {
        set_port_property ci_master_readrb TERMINATION true
        set_port_property ci_master_b TERMINATION true
    }

    if { $use_writerc == 0 } {
        set_port_property ci_master_writerc TERMINATION true
        set_port_property ci_master_c TERMINATION true
    }

    if { $use_ipend == 0 } {
        set_port_property ci_master_ipending TERMINATION true
    }

    if { $use_estatus == 0 } {
        set_port_property ci_master_estatus TERMINATION true
    }

    if { $en_multcy == 0 } {
        set_port_property ci_slave_clk TERMINATION true
        set_port_property ci_slave_clken TERMINATION true
        set_port_property ci_slave_reset TERMINATION true
        set_port_property ci_slave_reset_req TERMINATION true
        set_port_property ci_slave_start TERMINATION true
        set_port_property ci_slave_done TERMINATION true

        set_port_property ci_master_clk TERMINATION true
        set_port_property ci_master_clken TERMINATION true
        set_port_property ci_master_reset TERMINATION true
        set_port_property ci_master_reset_req TERMINATION true
        set_port_property ci_master_start TERMINATION true
        set_port_property ci_master_done TERMINATION true
    } else {
        if { $use_start == 0 } {
            set_port_property ci_master_start TERMINATION true
        }
        if { $use_done == 0 } {
            set_port_property ci_master_done TERMINATION true
        }
        if { $use_reset_req == 0 } {
            set_port_property ci_master_reset_req TERMINATION true
        }
    }
}
