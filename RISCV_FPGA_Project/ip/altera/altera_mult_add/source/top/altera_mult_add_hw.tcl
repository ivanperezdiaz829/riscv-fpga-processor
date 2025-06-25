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


# (C) 2001-2010 Altera Corporation. All rights reserved.
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
# | 
# | $Header: //acds/rel/13.1/ip/altera_mult_add/source/top/altera_mult_add_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# |
# | request TCL package from ACDS 12.1
# | 
# +-----------------------------------
package require -exact qsys 12.1

# +-----------------------------------
# |
# | Source files
# | 
# +-----------------------------------
source altera_mult_add_hw_extra.tcl
source altera_mult_add_ui_rules.tcl
source altera_mult_add_proc.tcl

# +-----------------------------------
# | 
# | module Multiply-Adder
# | 
# +-----------------------------------
set_module_property NAME altera_mult_add
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Multiply-Adder"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Multiply Adder"
set_module_property DESCRIPTION "The ALTERA_MULT_ADD megafunction allows you to implement a multiplier-adder"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_lpm_alt_mfug.pdf"
#set "EDITABLE" to true allow user to load the _hw.tcl file into component editor
set_module_property EDITABLE false
set_module_property HIDE_FROM_SOPC true
set_module_property HIDE_FROM_QSYS true

# +-----------------------------------
# |
# | display items
# | 
# +-----------------------------------
add_display_item "" "General" GROUP tab
add_display_item "" "Extra Modes" GROUP tab
#add_display_item "" "Saturation" GROUP tab
#add_display_item "" "Rounding" GROUP tab
add_display_item "" "Multipliers" GROUP tab
add_display_item "" "Preadder" GROUP tab
add_display_item "" "Accumulator " GROUP tab
add_display_item "" "Systolic/Chain Adder" GROUP tab
add_display_item "" "Pipelining" GROUP tab

# +-----------------------------------
# |
# | declare constant
# | 
# +-----------------------------------
set NUMBER_OF_MULT 4

# +-----------------------------------
# |
# | 'General' tab, Multiplier B Representation
# | 
# +-----------------------------------
add_parameter number_of_multipliers INTEGER
set_parameter_property number_of_multipliers DEFAULT_VALUE 1
set_parameter_property number_of_multipliers DISPLAY_NAME "What is the number of multipliers?"
set_parameter_property number_of_multipliers ALLOWED_RANGES {1 2 3 4}
set_parameter_property number_of_multipliers UNITS None
set_parameter_property number_of_multipliers DISPLAY_HINT ""
set_parameter_property number_of_multipliers AFFECTS_GENERATION true
set_parameter_property number_of_multipliers HDL_PARAMETER true
set_parameter_property number_of_multipliers DESCRIPTION "Specifies the number of multipliers for Altera Multiply-Adder"
set_parameter_update_callback number_of_multipliers update_multipliers_restricted_params
add_display_item "General" number_of_multipliers parameter 


add_parameter width_a INTEGER
set_parameter_property width_a DEFAULT_VALUE 16
set_parameter_property width_a DISPLAY_NAME "How wide should the A input buses be?"
set_parameter_property width_a ALLOWED_RANGES {1:256}
set_parameter_property width_a UNITS BITS
set_parameter_property width_a DISPLAY_HINT ""
set_parameter_property width_a AFFECTS_GENERATION true
set_parameter_property width_a HDL_PARAMETER true
set_parameter_property width_a DESCRIPTION "Specifies the A input buses (Range of allowed values: 1 - 256)"
#set_parameter_update_callback width_a update_width_result
add_display_item "General" width_a parameter  

add_parameter width_b INTEGER
set_parameter_property width_b DEFAULT_VALUE 16
set_parameter_property width_b DISPLAY_NAME "How wide should the B input buses be?"
set_parameter_property width_b ALLOWED_RANGES {1:256}
set_parameter_property width_b UNITS BITS
set_parameter_property width_b DISPLAY_HINT ""
set_parameter_property width_b AFFECTS_GENERATION true
set_parameter_property width_b HDL_PARAMETER true
set_parameter_property width_b DESCRIPTION "Specifies the B input buses (Range of allowed values: 1 - 256)"
#set_parameter_update_callback width_b update_width_result
add_display_item "General" width_b parameter  

add_parameter width_result INTEGER
set_parameter_property width_result DEFAULT_VALUE 32
set_parameter_property width_result DISPLAY_NAME "How wide should the 'result' output bus be?"
set_parameter_property width_result ALLOWED_RANGES {1:256}
set_parameter_property width_result UNITS BITS
set_parameter_property width_result DISPLAY_HINT ""
set_parameter_property width_result AFFECTS_GENERATION true
set_parameter_property width_result HDL_PARAMETER true
set_parameter_property width_result DESCRIPTION "Specifies the resultant output buses (Range of allowed values: 1 - 256)"
add_display_item "General" width_result parameter

add_parameter gui_4th_asynchronous_clear boolean 0
set_parameter_property gui_4th_asynchronous_clear DEFAULT_VALUE 0
set_parameter_property gui_4th_asynchronous_clear DISPLAY_NAME "Create a 4th asynchronous clear input option"
set_parameter_property gui_4th_asynchronous_clear UNITS None
set_parameter_property gui_4th_asynchronous_clear DISPLAY_HINT ""
set_parameter_property gui_4th_asynchronous_clear AFFECTS_GENERATION true
set_parameter_property gui_4th_asynchronous_clear HDL_PARAMETER false
set_parameter_property gui_4th_asynchronous_clear DESCRIPTION "This forces all registers to have an associated asynchronous clear input"
set_parameter_property gui_4th_asynchronous_clear ENABLED false
add_display_item "General" gui_4th_asynchronous_clear parameter

add_parameter gui_associated_clock_enable boolean 0
set_parameter_property gui_associated_clock_enable DEFAULT_VALUE 0
set_parameter_property gui_associated_clock_enable DISPLAY_NAME "Create an associated clock enable for each clock"
set_parameter_property gui_associated_clock_enable UNITS None
set_parameter_property gui_associated_clock_enable DISPLAY_HINT ""
set_parameter_property gui_associated_clock_enable AFFECTS_GENERATION true
set_parameter_property gui_associated_clock_enable HDL_PARAMETER false
set_parameter_property gui_associated_clock_enable DESCRIPTION ""
add_display_item "General" gui_associated_clock_enable parameter

# +-----------------------------------
#
# | "Extra Modes" tab, Output Configuration
# | 
# +-----------------------------------
add_display_item "Extra Modes" "Outputs Configuration" GROUP

#add_parameter gui_a_shiftout boolean 0
#set_parameter_property gui_a_shiftout DEFAULT_VALUE 0
#set_parameter_property gui_a_shiftout DISPLAY_NAME "Create a shiftout output from A input of the last multiplier"
#set_parameter_property gui_a_shiftout UNITS None
#set_parameter_property gui_a_shiftout DISPLAY_HINT ""
#set_parameter_property gui_a_shiftout AFFECTS_GENERATION true
#set_parameter_property gui_a_shiftout HDL_PARAMETER false
#set_parameter_property gui_a_shiftout DESCRIPTION "Shiftout A requires WA == 18 and Chainout enabled"
#set_parameter_property gui_a_shiftout ENABLED false
#add_display_item "Outputs Configuration" gui_a_shiftout parameter

#add_parameter gui_b_shiftout boolean 0
#set_parameter_property gui_b_shiftout DEFAULT_VALUE 0
#set_parameter_property gui_b_shiftout DISPLAY_NAME "Create a shiftout output from B input of the last multiplier"
#set_parameter_property gui_b_shiftout UNITS None
#set_parameter_property gui_b_shiftout DISPLAY_HINT ""
#set_parameter_property gui_b_shiftout AFFECTS_GENERATION true
#set_parameter_property gui_b_shiftout HDL_PARAMETER false
#set_parameter_property gui_b_shiftout DESCRIPTION ""
#set_parameter_property gui_b_shiftout ENABLED false
#add_display_item "Outputs Configuration" gui_b_shiftout parameter 

add_parameter gui_output_register boolean 0
set_parameter_property gui_output_register DEFAULT_VALUE 0
set_parameter_property gui_output_register DISPLAY_NAME "Register output of the adder unit"
set_parameter_property gui_output_register UNITS None
set_parameter_property gui_output_register DISPLAY_HINT ""
set_parameter_property gui_output_register AFFECTS_GENERATION true
set_parameter_property gui_output_register HDL_PARAMETER false
set_parameter_property gui_output_register DESCRIPTION ""
add_display_item "Outputs Configuration" gui_output_register parameter

add_parameter output_register STRING "UNREGISTERED"
set_parameter_property output_register DEFAULT_VALUE "UNREGISTERED"
set_parameter_property output_register VISIBLE false
set_parameter_property output_register ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property output_register AFFECTS_GENERATION true
set_parameter_property output_register DERIVED true
set_parameter_property output_register HDL_PARAMETER true

add_parameter gui_output_register_clock STRING "CLOCK0"
set_parameter_property gui_output_register_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_output_register_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_output_register_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_output_register_clock UNITS None
set_parameter_property gui_output_register_clock DISPLAY_HINT ""
set_parameter_property gui_output_register_clock AFFECTS_GENERATION true
set_parameter_property gui_output_register_clock HDL_PARAMETER false
set_parameter_property gui_output_register_clock DESCRIPTION ""
add_display_item "Outputs Configuration" gui_output_register_clock parameter 

add_parameter gui_output_register_aclr STRING "NONE"
set_parameter_property gui_output_register_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_output_register_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_output_register_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_output_register_aclr UNITS None
set_parameter_property gui_output_register_aclr DISPLAY_HINT ""
set_parameter_property gui_output_register_aclr AFFECTS_GENERATION true
set_parameter_property gui_output_register_aclr HDL_PARAMETER false
set_parameter_property gui_output_register_aclr DESCRIPTION ""
add_display_item "Outputs Configuration" gui_output_register_aclr parameter 

add_parameter output_aclr STRING "NONE"
set_parameter_property output_aclr DEFAULT_VALUE "NONE"
set_parameter_property output_aclr VISIBLE false
set_parameter_property output_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property output_aclr AFFECTS_GENERATION true
set_parameter_property output_aclr DERIVED true
set_parameter_property output_aclr HDL_PARAMETER true

#add_display_item "Extra Modes" "Implementation" GROUP

#add_parameter gui_implementation_mode STRING "Default implementation"
#set_parameter_property gui_implementation_mode DEFAULT_VALUE "Default implementation"
#set_parameter_property gui_implementation_mode DISPLAY_NAME "Multiplier-adder implementation"
#set_parameter_property gui_implementation_mode ALLOWED_RANGES {"Default implementation" "Dedicated multiplier circuitry" "Logic elements"}
#set_parameter_property gui_implementation_mode UNITS None
#set_parameter_property gui_implementation_mode DISPLAY_HINT "radio"
#set_parameter_property gui_implementation_mode AFFECTS_GENERATION false
#set_parameter_property gui_implementation_mode HDL_PARAMETER false
#set_parameter_property gui_implementation_mode DESCRIPTION "Which multiplier-adder implementation should be used?"
#set_parameter_property gui_implementation_mode ENABLED false
#add_display_item "Implementation" gui_implementation_mode parameter

# +-----------------------------------
#
# | "Extra Modes" tab, Adder Operation
# | 
# +-----------------------------------
add_display_item "Extra Modes" "Adder Operation" GROUP

add_parameter gui_multiplier1_direction STRING "ADD"
set_parameter_property gui_multiplier1_direction DEFAULT_VALUE ADD
set_parameter_property gui_multiplier1_direction DISPLAY_NAME "What operation should be perfomed on outputs of the first pair of multipliers"
set_parameter_property gui_multiplier1_direction ALLOWED_RANGES {"ADD" "SUB" "VARIABLE"}
set_parameter_property gui_multiplier1_direction UNITS None
set_parameter_property gui_multiplier1_direction DISPLAY_HINT ""
set_parameter_property gui_multiplier1_direction AFFECTS_GENERATION true
set_parameter_property gui_multiplier1_direction HDL_PARAMETER false
set_parameter_property gui_multiplier1_direction DESCRIPTION ""
add_display_item "Adder Operation" gui_multiplier1_direction parameter

add_parameter multiplier1_direction STRING "ADD"
set_parameter_property multiplier1_direction DEFAULT_VALUE "ADD"
set_parameter_property multiplier1_direction VISIBLE false
set_parameter_property multiplier1_direction ALLOWED_RANGES {"ADD" "SUB"}
set_parameter_property multiplier1_direction AFFECTS_GENERATION true
set_parameter_property multiplier1_direction DERIVED true
set_parameter_property multiplier1_direction HDL_PARAMETER true

add_parameter port_addnsub1 STRING "PORT_UNUSED"
set_parameter_property port_addnsub1 DEFAULT_VALUE "PORT_UNUSED"
set_parameter_property port_addnsub1 VISIBLE false
set_parameter_property port_addnsub1 ALLOWED_RANGES {"PORT_UNUSED" "PORT_USED"}
set_parameter_property port_addnsub1 AFFECTS_GENERATION true
set_parameter_property port_addnsub1 DERIVED true
set_parameter_property port_addnsub1 HDL_PARAMETER true

add_parameter gui_addnsub_multiplier_register1 boolean 0
set_parameter_property gui_addnsub_multiplier_register1 DEFAULT_VALUE 0
set_parameter_property gui_addnsub_multiplier_register1 DISPLAY_NAME "Register 'addnsub1' input"
set_parameter_property gui_addnsub_multiplier_register1 UNITS None
set_parameter_property gui_addnsub_multiplier_register1 DISPLAY_HINT ""
set_parameter_property gui_addnsub_multiplier_register1 AFFECTS_GENERATION true
set_parameter_property gui_addnsub_multiplier_register1 HDL_PARAMETER false
set_parameter_property gui_addnsub_multiplier_register1 DESCRIPTION "'addnsub1' input controls the operation (1 add/0 sub)"
add_display_item "Adder Operation" gui_addnsub_multiplier_register1 parameter 

add_parameter addnsub_multiplier_register1 STRING "UNREGISTERED"
set_parameter_property addnsub_multiplier_register1 DEFAULT_VALUE "UNREGISTERED"
set_parameter_property addnsub_multiplier_register1 VISIBLE false
set_parameter_property addnsub_multiplier_register1 ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property addnsub_multiplier_register1 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_register1 DERIVED true
set_parameter_property addnsub_multiplier_register1 HDL_PARAMETER true 

add_parameter gui_addnsub_multiplier_register1_clock STRING "CLOCK0"
set_parameter_property gui_addnsub_multiplier_register1_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_addnsub_multiplier_register1_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_addnsub_multiplier_register1_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_addnsub_multiplier_register1_clock UNITS None
set_parameter_property gui_addnsub_multiplier_register1_clock DISPLAY_HINT ""
set_parameter_property gui_addnsub_multiplier_register1_clock AFFECTS_GENERATION true
set_parameter_property gui_addnsub_multiplier_register1_clock HDL_PARAMETER false
set_parameter_property gui_addnsub_multiplier_register1_clock DESCRIPTION ""
add_display_item "Adder Operation" gui_addnsub_multiplier_register1_clock parameter 

add_parameter gui_addnsub_multiplier_aclr1 STRING "NONE"
set_parameter_property gui_addnsub_multiplier_aclr1 DEFAULT_VALUE "NONE"
set_parameter_property gui_addnsub_multiplier_aclr1 DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_addnsub_multiplier_aclr1 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_addnsub_multiplier_aclr1 UNITS None
set_parameter_property gui_addnsub_multiplier_aclr1 DISPLAY_HINT ""
set_parameter_property gui_addnsub_multiplier_aclr1 AFFECTS_GENERATION true
set_parameter_property gui_addnsub_multiplier_aclr1 HDL_PARAMETER false
set_parameter_property gui_addnsub_multiplier_aclr1 DESCRIPTION ""
add_display_item "Adder Operation" gui_addnsub_multiplier_aclr1 parameter

add_parameter addnsub_multiplier_aclr1 STRING "NONE"
set_parameter_property addnsub_multiplier_aclr1 DEFAULT_VALUE "NONE"
set_parameter_property addnsub_multiplier_aclr1 VISIBLE false
set_parameter_property addnsub_multiplier_aclr1 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property addnsub_multiplier_aclr1 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_aclr1 DERIVED true
set_parameter_property addnsub_multiplier_aclr1 HDL_PARAMETER true

add_parameter gui_multiplier3_direction STRING "ADD"
set_parameter_property gui_multiplier3_direction DEFAULT_VALUE ADD
set_parameter_property gui_multiplier3_direction DISPLAY_NAME "What operation should be perfomed on outputs of the second pair of multipliers"
set_parameter_property gui_multiplier3_direction ALLOWED_RANGES {"ADD" "SUB" "VARIABLE"}
set_parameter_property gui_multiplier3_direction UNITS None
set_parameter_property gui_multiplier3_direction DISPLAY_HINT ""
set_parameter_property gui_multiplier3_direction AFFECTS_GENERATION true
set_parameter_property gui_multiplier3_direction HDL_PARAMETER false
set_parameter_property gui_multiplier3_direction DESCRIPTION ""
add_display_item "Adder Operation" gui_multiplier3_direction parameter

add_parameter multiplier3_direction STRING "ADD"
set_parameter_property multiplier3_direction DEFAULT_VALUE "ADD"
set_parameter_property multiplier3_direction VISIBLE false
set_parameter_property multiplier3_direction ALLOWED_RANGES {"ADD" "SUB"}
set_parameter_property multiplier3_direction AFFECTS_GENERATION true
set_parameter_property multiplier3_direction DERIVED true
set_parameter_property multiplier3_direction HDL_PARAMETER true

add_parameter port_addnsub3 STRING "PORT_UNUSED"
set_parameter_property port_addnsub3 DEFAULT_VALUE "PORT_UNUSED"
set_parameter_property port_addnsub3 VISIBLE false
set_parameter_property port_addnsub3 ALLOWED_RANGES {"PORT_UNUSED" "PORT_USED"}
set_parameter_property port_addnsub3 AFFECTS_GENERATION true
set_parameter_property port_addnsub3 DERIVED true
set_parameter_property port_addnsub3 HDL_PARAMETER true

add_parameter gui_addnsub_multiplier_register3 boolean 0
set_parameter_property gui_addnsub_multiplier_register3 DEFAULT_VALUE 0
set_parameter_property gui_addnsub_multiplier_register3 DISPLAY_NAME "Register 'addnsub3' input"
set_parameter_property gui_addnsub_multiplier_register3 UNITS None
set_parameter_property gui_addnsub_multiplier_register3 DISPLAY_HINT ""
set_parameter_property gui_addnsub_multiplier_register3 AFFECTS_GENERATION true
set_parameter_property gui_addnsub_multiplier_register3 HDL_PARAMETER false
set_parameter_property gui_addnsub_multiplier_register3 DESCRIPTION "'addnsub3' input controls the operation (1 add/0 sub)"
add_display_item "Adder Operation" gui_addnsub_multiplier_register3 parameter 

add_parameter addnsub_multiplier_register3 STRING "UNREGISTERED"
set_parameter_property addnsub_multiplier_register3 DEFAULT_VALUE "UNREGISTERED"
set_parameter_property addnsub_multiplier_register3 VISIBLE false
set_parameter_property addnsub_multiplier_register3 ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property addnsub_multiplier_register3 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_register3 DERIVED true
set_parameter_property addnsub_multiplier_register3 HDL_PARAMETER true 

add_parameter gui_addnsub_multiplier_register3_clock STRING "CLOCK0"
set_parameter_property gui_addnsub_multiplier_register3_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_addnsub_multiplier_register3_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_addnsub_multiplier_register3_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_addnsub_multiplier_register3_clock UNITS None
set_parameter_property gui_addnsub_multiplier_register3_clock DISPLAY_HINT ""
set_parameter_property gui_addnsub_multiplier_register3_clock AFFECTS_GENERATION true
set_parameter_property gui_addnsub_multiplier_register3_clock HDL_PARAMETER false
set_parameter_property gui_addnsub_multiplier_register3_clock DESCRIPTION ""
add_display_item "Adder Operation" gui_addnsub_multiplier_register3_clock parameter 

add_parameter gui_addnsub_multiplier_aclr3 STRING "NONE"
set_parameter_property gui_addnsub_multiplier_aclr3 DEFAULT_VALUE "NONE"
set_parameter_property gui_addnsub_multiplier_aclr3 DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_addnsub_multiplier_aclr3 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_addnsub_multiplier_aclr3 UNITS None
set_parameter_property gui_addnsub_multiplier_aclr3 DISPLAY_HINT ""
set_parameter_property gui_addnsub_multiplier_aclr3 AFFECTS_GENERATION true
set_parameter_property gui_addnsub_multiplier_aclr3 HDL_PARAMETER false
set_parameter_property gui_addnsub_multiplier_aclr3 DESCRIPTION ""
add_display_item "Adder Operation" gui_addnsub_multiplier_aclr3 parameter

add_parameter addnsub_multiplier_aclr3 STRING "NONE"
set_parameter_property addnsub_multiplier_aclr3 DEFAULT_VALUE "NONE"
set_parameter_property addnsub_multiplier_aclr3 VISIBLE false
set_parameter_property addnsub_multiplier_aclr3 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property addnsub_multiplier_aclr3 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_aclr3 DERIVED true
set_parameter_property addnsub_multiplier_aclr3 HDL_PARAMETER true

# +-----------------------------------
#
# | 'Multipliers' tab, Multiplier A Representation
# | 
# +-----------------------------------
add_display_item "Multipliers" "Multiplier Representation" GROUP

add_parameter gui_representation_a STRING "UNSIGNED"
set_parameter_property gui_representation_a DEFAULT_VALUE "UNSIGNED"
set_parameter_property gui_representation_a DISPLAY_NAME "What is the representation format for Multipliers A inputs?"
set_parameter_property gui_representation_a ALLOWED_RANGES {"SIGNED" "UNSIGNED" "VARIABLE"}
set_parameter_property gui_representation_a UNITS None
set_parameter_property gui_representation_a DISPLAY_HINT ""
set_parameter_property gui_representation_a AFFECTS_GENERATION true
set_parameter_property gui_representation_a HDL_PARAMETER false
set_parameter_property gui_representation_a DESCRIPTION ""
add_display_item "Multiplier Representation" gui_representation_a parameter

add_parameter representation_a STRING "UNSIGNED"
set_parameter_property representation_a DEFAULT_VALUE "UNSIGNED"
set_parameter_property representation_a VISIBLE false
set_parameter_property representation_a ALLOWED_RANGES {"SIGNED" "UNSIGNED"}
set_parameter_property representation_a AFFECTS_GENERATION true
set_parameter_property representation_a DERIVED true
set_parameter_property representation_a HDL_PARAMETER true

add_parameter gui_register_signa boolean 0
set_parameter_property gui_register_signa DEFAULT_VALUE 0
set_parameter_property gui_register_signa DISPLAY_NAME "Register 'signa' input"
set_parameter_property gui_register_signa UNITS None
set_parameter_property gui_register_signa DISPLAY_HINT ""
set_parameter_property gui_register_signa AFFECTS_GENERATION true
set_parameter_property gui_register_signa HDL_PARAMETER false
set_parameter_property gui_register_signa DESCRIPTION "'signa' input controls the sign (1 SIGNED/0 UNSIGNED)"
add_display_item "Multiplier Representation" gui_register_signa parameter 

add_parameter port_signa STRING "PORT_UNUSED"
set_parameter_property port_signa DEFAULT_VALUE "PORT_UNUSED"
set_parameter_property port_signa VISIBLE false
set_parameter_property port_signa ALLOWED_RANGES {"PORT_UNUSED" "PORT_USED"}
set_parameter_property port_signa AFFECTS_GENERATION true
set_parameter_property port_signa DERIVED true
set_parameter_property port_signa HDL_PARAMETER true

add_parameter signed_register_a STRING "UNREGISTERED"
set_parameter_property signed_register_a DEFAULT_VALUE "UNREGISTERED"
set_parameter_property signed_register_a VISIBLE false
set_parameter_property signed_register_a ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property signed_register_a AFFECTS_GENERATION true
set_parameter_property signed_register_a DERIVED true
set_parameter_property signed_register_a HDL_PARAMETER true

add_parameter gui_register_signa_clock STRING "CLOCK0"
set_parameter_property gui_register_signa_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_register_signa_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_register_signa_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_register_signa_clock UNITS None
set_parameter_property gui_register_signa_clock DISPLAY_HINT ""
set_parameter_property gui_register_signa_clock AFFECTS_GENERATION true
set_parameter_property gui_register_signa_clock HDL_PARAMETER false
set_parameter_property gui_register_signa_clock DESCRIPTION ""
add_display_item "Multiplier Representation" gui_register_signa_clock parameter 

add_parameter gui_register_signa_aclr STRING "NONE"
set_parameter_property gui_register_signa_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_register_signa_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_register_signa_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_register_signa_aclr UNITS None
set_parameter_property gui_register_signa_aclr DISPLAY_HINT ""
set_parameter_property gui_register_signa_aclr AFFECTS_GENERATION true
set_parameter_property gui_register_signa_aclr HDL_PARAMETER false
set_parameter_property gui_register_signa_aclr DESCRIPTION ""
add_display_item "Multiplier Representation" gui_register_signa_aclr parameter  

add_parameter signed_aclr_a STRING "NONE"
set_parameter_property signed_aclr_a DEFAULT_VALUE "NONE"
set_parameter_property signed_aclr_a VISIBLE false
set_parameter_property signed_aclr_a ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property signed_aclr_a AFFECTS_GENERATION true
set_parameter_property signed_aclr_a DERIVED true
set_parameter_property signed_aclr_a HDL_PARAMETER true

add_parameter gui_representation_b STRING "UNSIGNED"
set_parameter_property gui_representation_b DEFAULT_VALUE "UNSIGNED"
set_parameter_property gui_representation_b DISPLAY_NAME "What is the representation format for Multipliers B inputs?"
set_parameter_property gui_representation_b ALLOWED_RANGES {"SIGNED" "UNSIGNED" "VARIABLE"}
set_parameter_property gui_representation_b UNITS None
set_parameter_property gui_representation_b DISPLAY_HINT ""
set_parameter_property gui_representation_b AFFECTS_GENERATION true
set_parameter_property gui_representation_b HDL_PARAMETER false
set_parameter_property gui_representation_b DESCRIPTION ""
add_display_item "Multiplier Representation" gui_representation_b parameter

add_parameter port_signb STRING "PORT_UNUSED"
set_parameter_property port_signb DEFAULT_VALUE "PORT_UNUSED"
set_parameter_property port_signb VISIBLE false
set_parameter_property port_signb ALLOWED_RANGES {"PORT_UNUSED" "PORT_USED"}
set_parameter_property port_signb AFFECTS_GENERATION true
set_parameter_property port_signb DERIVED true
set_parameter_property port_signb HDL_PARAMETER true

add_parameter representation_b STRING "UNSIGNED"
set_parameter_property representation_b DEFAULT_VALUE "UNSIGNED"
set_parameter_property representation_b VISIBLE false
set_parameter_property representation_b ALLOWED_RANGES {"SIGNED" "UNSIGNED"}
set_parameter_property representation_b AFFECTS_GENERATION true
set_parameter_property representation_b DERIVED true
set_parameter_property representation_b HDL_PARAMETER true

add_parameter gui_register_signb boolean 0
set_parameter_property gui_register_signb DEFAULT_VALUE 0
set_parameter_property gui_register_signb DISPLAY_NAME "Register 'signb' input"
set_parameter_property gui_register_signb UNITS None
set_parameter_property gui_register_signb DISPLAY_HINT ""
set_parameter_property gui_register_signb AFFECTS_GENERATION true
set_parameter_property gui_register_signb HDL_PARAMETER false
set_parameter_property gui_register_signb DESCRIPTION "'signb' input controls the sign (1 SIGNED/0 UNSIGNED)"
add_display_item "Multiplier Representation" gui_register_signb parameter 

add_parameter signed_register_b STRING "UNREGISTERED"
set_parameter_property signed_register_b DEFAULT_VALUE "UNREGISTERED"
set_parameter_property signed_register_b VISIBLE false
set_parameter_property signed_register_b ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property signed_register_b AFFECTS_GENERATION true
set_parameter_property signed_register_b DERIVED true
set_parameter_property signed_register_b HDL_PARAMETER true

add_parameter gui_register_signb_clock STRING "CLOCK0"
set_parameter_property gui_register_signb_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_register_signb_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_register_signb_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_register_signb_clock UNITS None
set_parameter_property gui_register_signb_clock DISPLAY_HINT ""
set_parameter_property gui_register_signb_clock AFFECTS_GENERATION true
set_parameter_property gui_register_signb_clock HDL_PARAMETER false
set_parameter_property gui_register_signb_clock DESCRIPTION ""
add_display_item "Multiplier Representation" gui_register_signb_clock parameter 


add_parameter gui_register_signb_aclr STRING "NONE"
set_parameter_property gui_register_signb_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_register_signb_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_register_signb_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_register_signb_aclr UNITS None
set_parameter_property gui_register_signb_aclr DISPLAY_HINT ""
set_parameter_property gui_register_signb_aclr AFFECTS_GENERATION true
set_parameter_property gui_register_signb_aclr HDL_PARAMETER false
set_parameter_property gui_register_signb_aclr DESCRIPTION ""
add_display_item "Multiplier Representation" gui_register_signb_aclr parameter

add_parameter signed_aclr_b STRING "NONE"
set_parameter_property signed_aclr_b DEFAULT_VALUE "NONE"
set_parameter_property signed_aclr_b VISIBLE false
set_parameter_property signed_aclr_b ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property signed_aclr_b AFFECTS_GENERATION true
set_parameter_property signed_aclr_b DERIVED true
set_parameter_property signed_aclr_b HDL_PARAMETER true

# +-----------------------------------
#
# | "Multipliers" tab, Input Configuration
# | 
# +-----------------------------------
add_display_item "Multipliers" "Input Configuration" GROUP

add_parameter gui_input_register_a boolean 0
set_parameter_property gui_input_register_a DEFAULT_VALUE 0
set_parameter_property gui_input_register_a DISPLAY_NAME "Register input A of the multiplier"
set_parameter_property gui_input_register_a UNITS None
set_parameter_property gui_input_register_a DISPLAY_HINT ""
set_parameter_property gui_input_register_a AFFECTS_GENERATION true
set_parameter_property gui_input_register_a HDL_PARAMETER false
set_parameter_property gui_input_register_a DESCRIPTION ""
add_display_item "Input Configuration" gui_input_register_a parameter 

add_parameter gui_input_register_a_clock STRING "CLOCK0"
set_parameter_property gui_input_register_a_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_input_register_a_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_input_register_a_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_input_register_a_clock UNITS None
set_parameter_property gui_input_register_a_clock DISPLAY_HINT ""
set_parameter_property gui_input_register_a_clock AFFECTS_GENERATION true
set_parameter_property gui_input_register_a_clock HDL_PARAMETER false
set_parameter_property gui_input_register_a_clock DESCRIPTION ""
add_display_item "Input Configuration" gui_input_register_a_clock parameter 

add_parameter gui_input_register_a_aclr STRING "NONE"
set_parameter_property gui_input_register_a_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_input_register_a_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_input_register_a_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_input_register_a_aclr UNITS None
set_parameter_property gui_input_register_a_aclr DISPLAY_HINT ""
set_parameter_property gui_input_register_a_aclr AFFECTS_GENERATION true
set_parameter_property gui_input_register_a_aclr HDL_PARAMETER false
set_parameter_property gui_input_register_a_aclr DESCRIPTION ""
add_display_item "Input Configuration" gui_input_register_a_aclr parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_register_a$i STRING "UNREGISTERED"
set_parameter_property input_register_a$i DEFAULT_VALUE "UNREGISTERED"
set_parameter_property input_register_a$i VISIBLE false
set_parameter_property input_register_a$i ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property input_register_a$i AFFECTS_GENERATION true
set_parameter_property input_register_a$i DERIVED true
set_parameter_property input_register_a$i HDL_PARAMETER true
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_aclr_a$i STRING "NONE"
set_parameter_property input_aclr_a$i DEFAULT_VALUE "NONE"
set_parameter_property input_aclr_a$i VISIBLE false
set_parameter_property input_aclr_a$i ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property input_aclr_a$i AFFECTS_GENERATION true
set_parameter_property input_aclr_a$i DERIVED true
set_parameter_property input_aclr_a$i HDL_PARAMETER true
}

add_parameter gui_input_register_b boolean 0
set_parameter_property gui_input_register_b DEFAULT_VALUE 0
set_parameter_property gui_input_register_b DISPLAY_NAME "Register input B of the multiplier"
set_parameter_property gui_input_register_b UNITS None
set_parameter_property gui_input_register_b DISPLAY_HINT ""
set_parameter_property gui_input_register_b AFFECTS_GENERATION true
set_parameter_property gui_input_register_b HDL_PARAMETER false
set_parameter_property gui_input_register_b DESCRIPTION ""
add_display_item "Input Configuration" gui_input_register_b parameter 

add_parameter gui_input_register_b_clock STRING "CLOCK0"
set_parameter_property gui_input_register_b_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_input_register_b_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_input_register_b_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_input_register_b_clock UNITS None
set_parameter_property gui_input_register_b_clock DISPLAY_HINT ""
set_parameter_property gui_input_register_b_clock AFFECTS_GENERATION true
set_parameter_property gui_input_register_b_clock HDL_PARAMETER false
set_parameter_property gui_input_register_b_clock DESCRIPTION ""
add_display_item "Input Configuration" gui_input_register_b_clock parameter 

add_parameter gui_input_register_b_aclr STRING "NONE"
set_parameter_property gui_input_register_b_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_input_register_b_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_input_register_b_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_input_register_b_aclr UNITS None
set_parameter_property gui_input_register_b_aclr DISPLAY_HINT ""
set_parameter_property gui_input_register_b_aclr AFFECTS_GENERATION true
set_parameter_property gui_input_register_b_aclr HDL_PARAMETER false
set_parameter_property gui_input_register_b_aclr DESCRIPTION ""
add_display_item "Input Configuration" gui_input_register_b_aclr parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_register_b$i STRING "UNREGISTERED"
set_parameter_property input_register_b$i DEFAULT_VALUE "UNREGISTERED"
set_parameter_property input_register_b$i VISIBLE false
set_parameter_property input_register_b$i ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property input_register_b$i AFFECTS_GENERATION true
set_parameter_property input_register_b$i DERIVED true
set_parameter_property input_register_b$i HDL_PARAMETER true
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_aclr_b$i STRING "NONE"
set_parameter_property input_aclr_b$i DEFAULT_VALUE "NONE"
set_parameter_property input_aclr_b$i VISIBLE false
set_parameter_property input_aclr_b$i ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property input_aclr_b$i AFFECTS_GENERATION true
set_parameter_property input_aclr_b$i DERIVED true
set_parameter_property input_aclr_b$i HDL_PARAMETER true
}

add_parameter gui_multiplier_a_input STRING "Multiplier input"
set_parameter_property gui_multiplier_a_input DEFAULT_VALUE "Multiplier input"
set_parameter_property gui_multiplier_a_input DISPLAY_NAME "What is the input A of the multiplier connected to?"
set_parameter_property gui_multiplier_a_input ALLOWED_RANGES {"Multiplier input" "Scan chain input"}
set_parameter_property gui_multiplier_a_input UNITS None
set_parameter_property gui_multiplier_a_input DISPLAY_HINT ""
set_parameter_property gui_multiplier_a_input AFFECTS_GENERATION true
set_parameter_property gui_multiplier_a_input HDL_PARAMETER false
set_parameter_property gui_multiplier_a_input DESCRIPTION ""
add_display_item "Input Configuration" gui_multiplier_a_input parameter 

add_display_item "Input Configuration" "Scanout A Register Configuration" GROUP

add_parameter gui_scanouta_register boolean 0
set_parameter_property gui_scanouta_register DEFAULT_VALUE 0
set_parameter_property gui_scanouta_register DISPLAY_NAME "Register output of the scan chain"
set_parameter_property gui_scanouta_register UNITS None
set_parameter_property gui_scanouta_register DISPLAY_HINT ""
set_parameter_property gui_scanouta_register AFFECTS_GENERATION true
set_parameter_property gui_scanouta_register HDL_PARAMETER false
set_parameter_property gui_scanouta_register DESCRIPTION ""
add_display_item "Scanout A Register Configuration" gui_scanouta_register parameter 

add_parameter gui_scanouta_register_clock STRING "CLOCK0"
set_parameter_property gui_scanouta_register_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_scanouta_register_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_scanouta_register_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_scanouta_register_clock UNITS None
set_parameter_property gui_scanouta_register_clock DISPLAY_HINT ""
set_parameter_property gui_scanouta_register_clock AFFECTS_GENERATION true
set_parameter_property gui_scanouta_register_clock HDL_PARAMETER false
set_parameter_property gui_scanouta_register_clock DESCRIPTION ""
add_display_item "Scanout A Register Configuration" gui_scanouta_register_clock parameter 

add_parameter gui_scanouta_register_aclr STRING "NONE"
set_parameter_property gui_scanouta_register_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_scanouta_register_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_scanouta_register_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_scanouta_register_aclr UNITS None
set_parameter_property gui_scanouta_register_aclr DISPLAY_HINT ""
set_parameter_property gui_scanouta_register_aclr AFFECTS_GENERATION true
set_parameter_property gui_scanouta_register_aclr HDL_PARAMETER false
set_parameter_property gui_scanouta_register_aclr DESCRIPTION ""
add_display_item "Scanout A Register Configuration" gui_scanouta_register_aclr parameter 

add_parameter scanouta_register STRING "UNREGISTERED"
set_parameter_property scanouta_register DEFAULT_VALUE "UNREGISTERED"
set_parameter_property scanouta_register VISIBLE false
set_parameter_property scanouta_register ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property scanouta_register AFFECTS_GENERATION true
set_parameter_property scanouta_register DERIVED true
set_parameter_property scanouta_register HDL_PARAMETER true 

add_parameter scanouta_aclr STRING "NONE"
set_parameter_property scanouta_aclr DEFAULT_VALUE "NONE"
set_parameter_property scanouta_aclr VISIBLE false
set_parameter_property scanouta_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property scanouta_aclr AFFECTS_GENERATION true
set_parameter_property scanouta_aclr DERIVED true
set_parameter_property scanouta_aclr HDL_PARAMETER true

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_source_a$i STRING "DATAA"
set_parameter_property input_source_a$i DEFAULT_VALUE "DATAA"
set_parameter_property input_source_a$i VISIBLE false
set_parameter_property input_source_a$i ALLOWED_RANGES {"DATAA" "SCANA" "VARIABLE" "PREADDER"}
set_parameter_property input_source_a$i AFFECTS_GENERATION true
set_parameter_property input_source_a$i DERIVED true
set_parameter_property input_source_a$i HDL_PARAMETER true 
}

add_parameter gui_multiplier_b_input STRING "Multiplier input"
set_parameter_property gui_multiplier_b_input DEFAULT_VALUE "Multiplier input"
set_parameter_property gui_multiplier_b_input DISPLAY_NAME "What is the input B of the multiplier connected to?"
set_parameter_property gui_multiplier_b_input ALLOWED_RANGES {"Multiplier input" "Scan chain input"}
set_parameter_property gui_multiplier_b_input UNITS None
set_parameter_property gui_multiplier_b_input DISPLAY_HINT ""
set_parameter_property gui_multiplier_b_input AFFECTS_GENERATION true
set_parameter_property gui_multiplier_b_input HDL_PARAMETER false
set_parameter_property gui_multiplier_b_input DESCRIPTION ""
set_parameter_property gui_multiplier_b_input ENABLED false
add_display_item "Input Configuration" gui_multiplier_b_input parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_source_b$i STRING "DATAB"
set_parameter_property input_source_b$i DEFAULT_VALUE "DATAB"
set_parameter_property input_source_b$i VISIBLE false
set_parameter_property input_source_b$i ALLOWED_RANGES {"DATAB" "SCANB" "VARIABLE" "PREADDER" "COEF" "DATAC"}
set_parameter_property input_source_b$i AFFECTS_GENERATION true
set_parameter_property input_source_b$i DERIVED true
set_parameter_property input_source_b$i HDL_PARAMETER true 
}

# +-----------------------------------
#
# | "Multipliers" tab, Multiplier Output Configuration
# | 
# +-----------------------------------
add_display_item "Multipliers" "Output Configuration" GROUP


add_parameter gui_multiplier_register boolean 0
set_parameter_property gui_multiplier_register DEFAULT_VALUE 0
set_parameter_property gui_multiplier_register DISPLAY_NAME "Register output of the multiplier"
set_parameter_property gui_multiplier_register UNITS None
set_parameter_property gui_multiplier_register DISPLAY_HINT ""
set_parameter_property gui_multiplier_register AFFECTS_GENERATION true
set_parameter_property gui_multiplier_register HDL_PARAMETER false
set_parameter_property gui_multiplier_register DESCRIPTION ""
add_display_item "Output Configuration" gui_multiplier_register parameter 

add_parameter gui_multiplier_register_clock STRING "CLOCK0"
set_parameter_property gui_multiplier_register_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_multiplier_register_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_multiplier_register_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_multiplier_register_clock UNITS None
set_parameter_property gui_multiplier_register_clock DISPLAY_HINT ""
set_parameter_property gui_multiplier_register_clock AFFECTS_GENERATION true
set_parameter_property gui_multiplier_register_clock HDL_PARAMETER false
set_parameter_property gui_multiplier_register_clock DESCRIPTION ""
add_display_item "Output Configuration" gui_multiplier_register_clock parameter 

add_parameter gui_multiplier_register_aclr STRING "NONE"
set_parameter_property gui_multiplier_register_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_multiplier_register_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_multiplier_register_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_multiplier_register_aclr UNITS None
set_parameter_property gui_multiplier_register_aclr DISPLAY_HINT ""
set_parameter_property gui_multiplier_register_aclr AFFECTS_GENERATION true
set_parameter_property gui_multiplier_register_aclr HDL_PARAMETER false
set_parameter_property gui_multiplier_register_aclr DESCRIPTION ""
add_display_item "Output Configuration" gui_multiplier_register_aclr parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter multiplier_register$i STRING "UNREGISTERED"
set_parameter_property multiplier_register$i DEFAULT_VALUE "UNREGISTERED"
set_parameter_property multiplier_register$i VISIBLE false
set_parameter_property multiplier_register$i ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property multiplier_register$i AFFECTS_GENERATION true
set_parameter_property multiplier_register$i DERIVED true
set_parameter_property multiplier_register$i HDL_PARAMETER true 
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter multiplier_aclr$i  STRING "NONE"
set_parameter_property multiplier_aclr$i DEFAULT_VALUE "NONE"
set_parameter_property multiplier_aclr$i VISIBLE false
set_parameter_property multiplier_aclr$i ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property multiplier_aclr$i AFFECTS_GENERATION true
set_parameter_property multiplier_aclr$i DERIVED true
set_parameter_property multiplier_aclr$i HDL_PARAMETER true
}

# +-----------------------------------
#
# | "Preadder" tab
# | 
# +-----------------------------------

add_parameter preadder_mode STRING "SIMPLE"
set_parameter_property preadder_mode DEFAULT_VALUE "SIMPLE"
set_parameter_property preadder_mode DISPLAY_NAME "Select preadder mode"
set_parameter_property preadder_mode ALLOWED_RANGES {"SIMPLE" "COEF" "INPUT" "SQUARE" "CONSTANT"}
set_parameter_property preadder_mode UNITS None
set_parameter_property preadder_mode DISPLAY_HINT ""
set_parameter_property preadder_mode AFFECTS_GENERATION true
set_parameter_property preadder_mode HDL_PARAMETER true
set_parameter_property preadder_mode DESCRIPTION ""
set_parameter_update_callback preadder_mode update_preadder_reg
add_display_item "Preadder" preadder_mode parameter 

add_parameter gui_preadder_direction STRING "ADD"
set_parameter_property gui_preadder_direction DEFAULT_VALUE "ADD"
set_parameter_property gui_preadder_direction DISPLAY_NAME "Select preadder direction"
set_parameter_property gui_preadder_direction ALLOWED_RANGES {"ADD" "SUB"}
set_parameter_property gui_preadder_direction UNITS None
set_parameter_property gui_preadder_direction DISPLAY_HINT ""
set_parameter_property gui_preadder_direction AFFECTS_GENERATION true
set_parameter_property gui_preadder_direction HDL_PARAMETER false
set_parameter_property gui_preadder_direction DESCRIPTION ""
add_display_item "Preadder" gui_preadder_direction parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {	
add_parameter preadder_direction_$i STRING "ADD"
set_parameter_property preadder_direction_$i DEFAULT_VALUE "ADD"
set_parameter_property preadder_direction_$i VISIBLE false
set_parameter_property preadder_direction_$i ALLOWED_RANGES {"ADD" "SUB"}
set_parameter_property preadder_direction_$i AFFECTS_GENERATION true
set_parameter_property preadder_direction_$i DERIVED true
set_parameter_property preadder_direction_$i HDL_PARAMETER true
}

add_parameter width_c INTEGER 16
set_parameter_property width_c DEFAULT_VALUE 16
set_parameter_property width_c DISPLAY_NAME "How wide should the C input buses be?"
set_parameter_property width_c ALLOWED_RANGES {1:256}
set_parameter_property width_c UNITS BITS
set_parameter_property width_c DISPLAY_HINT ""
set_parameter_property width_c AFFECTS_GENERATION true
set_parameter_property width_c HDL_PARAMETER true
set_parameter_property width_c DESCRIPTION "Specifies the C input buses (Range of allowed values: 1 - 256)"
add_display_item "Preadder" width_c parameter  

add_display_item "Preadder" "Data C Input Register Configuration" GROUP

add_parameter gui_datac_input_register boolean 0
set_parameter_property gui_datac_input_register DEFAULT_VALUE 0
set_parameter_property gui_datac_input_register DISPLAY_NAME "Register datac input"
set_parameter_property gui_datac_input_register UNITS None
set_parameter_property gui_datac_input_register DISPLAY_HINT ""
set_parameter_property gui_datac_input_register AFFECTS_GENERATION true
set_parameter_property gui_datac_input_register HDL_PARAMETER false
set_parameter_property gui_datac_input_register DESCRIPTION ""
add_display_item "Data C Input Register Configuration" gui_datac_input_register parameter 

add_parameter gui_datac_input_register_clock STRING "CLOCK0"
set_parameter_property gui_datac_input_register_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_datac_input_register_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_datac_input_register_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_datac_input_register_clock UNITS None
set_parameter_property gui_datac_input_register_clock DISPLAY_HINT ""
set_parameter_property gui_datac_input_register_clock AFFECTS_GENERATION true
set_parameter_property gui_datac_input_register_clock HDL_PARAMETER false
set_parameter_property gui_datac_input_register_clock DESCRIPTION ""
add_display_item "Data C Input Register Configuration" gui_datac_input_register_clock parameter 

add_parameter gui_datac_input_register_aclr STRING "NONE"
set_parameter_property gui_datac_input_register_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_datac_input_register_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_datac_input_register_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_datac_input_register_aclr UNITS None
set_parameter_property gui_datac_input_register_aclr DISPLAY_HINT ""
set_parameter_property gui_datac_input_register_aclr AFFECTS_GENERATION true
set_parameter_property gui_datac_input_register_aclr HDL_PARAMETER false
set_parameter_property gui_datac_input_register_aclr DESCRIPTION ""
add_display_item "Data C Input Register Configuration" gui_datac_input_register_aclr parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_register_c$i STRING "UNREGISTERED"
set_parameter_property input_register_c$i DEFAULT_VALUE "UNREGISTERED"
set_parameter_property input_register_c$i VISIBLE false
set_parameter_property input_register_c$i ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property input_register_c$i AFFECTS_GENERATION true
set_parameter_property input_register_c$i DERIVED true
set_parameter_property input_register_c$i HDL_PARAMETER true 
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_aclr_c$i  STRING "NONE"
set_parameter_property input_aclr_c$i DEFAULT_VALUE "NONE"
set_parameter_property input_aclr_c$i VISIBLE false
set_parameter_property input_aclr_c$i ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property input_aclr_c$i AFFECTS_GENERATION true
set_parameter_property input_aclr_c$i DERIVED truek
set_parameter_property input_aclr_c$i HDL_PARAMETER true
}

add_display_item "Preadder" "Coefficients" GROUP

add_parameter width_coef INTEGER 18
set_parameter_property width_coef DEFAULT_VALUE 18
set_parameter_property width_coef DISPLAY_NAME "How wide should the coef width be?"
set_parameter_property width_coef ALLOWED_RANGES {1:27}
set_parameter_property width_coef UNITS BITS
set_parameter_property width_coef DISPLAY_HINT ""
set_parameter_property width_coef AFFECTS_GENERATION true
set_parameter_property width_coef HDL_PARAMETER true
set_parameter_property width_coef DESCRIPTION ""
add_display_item "Coefficients" width_coef parameter 

add_display_item "Coefficients" "Coef Register Configuration" GROUP

add_parameter gui_coef_register boolean 0
set_parameter_property gui_coef_register DEFAULT_VALUE 0
set_parameter_property gui_coef_register DISPLAY_NAME "Register the coefsel inputs"
set_parameter_property gui_coef_register UNITS None
set_parameter_property gui_coef_register DISPLAY_HINT ""
set_parameter_property gui_coef_register AFFECTS_GENERATION true
set_parameter_property gui_coef_register HDL_PARAMETER false
set_parameter_property gui_coef_register DESCRIPTION ""
add_display_item "Coef Register Configuration" gui_coef_register parameter 

add_parameter gui_coef_register_clock STRING "CLOCK0"
set_parameter_property gui_coef_register_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_coef_register_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_coef_register_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_coef_register_clock UNITS None
set_parameter_property gui_coef_register_clock DISPLAY_HINT ""
set_parameter_property gui_coef_register_clock AFFECTS_GENERATION true
set_parameter_property gui_coef_register_clock HDL_PARAMETER false
set_parameter_property gui_coef_register_clock DESCRIPTION ""
add_display_item "Coef Register Configuration" gui_coef_register_clock parameter 

add_parameter gui_coef_register_aclr STRING "NONE"
set_parameter_property gui_coef_register_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_coef_register_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_coef_register_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_coef_register_aclr UNITS None
set_parameter_property gui_coef_register_aclr DISPLAY_HINT ""
set_parameter_property gui_coef_register_aclr AFFECTS_GENERATION true
set_parameter_property gui_coef_register_aclr HDL_PARAMETER false
set_parameter_property gui_coef_register_aclr DESCRIPTION ""
add_display_item "Coef Register Configuration" gui_coef_register_aclr parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter coefsel${i}_register STRING "UNREGISTERED"
set_parameter_property coefsel${i}_register DEFAULT_VALUE "UNREGISTERED"
set_parameter_property coefsel${i}_register VISIBLE false
set_parameter_property coefsel${i}_register ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property coefsel${i}_register AFFECTS_GENERATION true
set_parameter_property coefsel${i}_register DERIVED true
set_parameter_property coefsel${i}_register HDL_PARAMETER true 
}

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter  coefsel${i}_aclr STRING "NONE"
set_parameter_property coefsel${i}_aclr DEFAULT_VALUE "NONE"
set_parameter_property coefsel${i}_aclr VISIBLE false
set_parameter_property coefsel${i}_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property coefsel${i}_aclr AFFECTS_GENERATION true
set_parameter_property coefsel${i}_aclr DERIVED true
set_parameter_property coefsel${i}_aclr HDL_PARAMETER true
}

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {	

	add_display_item "Coefficients" "Coefficient_$i Configuration" GROUP tab

	for { set j 0 } {$j < 8} {incr j} {
		add_parameter coef${i}_${j} INTEGER 0
		set_parameter_property coef${i}_${j} DEFAULT_VALUE 0
		set_parameter_property coef${i}_${j} DISPLAY_NAME "Coef${i}_$j"
		set_parameter_property coef${i}_${j} ALLOWED_RANGES {0:268435455}
		set_parameter_property coef${i}_${j} UNITS None
		set_parameter_property coef${i}_${j} DISPLAY_HINT hexadecimal
		set_parameter_property coef${i}_${j} AFFECTS_GENERATION true
		set_parameter_property coef${i}_${j} HDL_PARAMETER true
		set_parameter_property coef${i}_${j} DESCRIPTION "Only take HEX value (Range of allowed values: 0x00000 - 0xFFFFFFF)"
		add_display_item "Coefficient_$i Configuration" coef${i}_${j} parameter
	}
}

# +-----------------------------------
#
# | "Accumulator " tab
# | 
# +-----------------------------------

add_parameter accumulator STRING "NO"
set_parameter_property accumulator DEFAULT_VALUE "NO"
set_parameter_property accumulator DISPLAY_NAME "Enable accumulator?"
set_parameter_property accumulator ALLOWED_RANGES {"NO" "YES"}
set_parameter_property accumulator UNITS None
set_parameter_property accumulator DISPLAY_HINT ""
set_parameter_property accumulator AFFECTS_GENERATION true
set_parameter_property accumulator HDL_PARAMETER true
set_parameter_property accumulator DESCRIPTION ""
set_parameter_update_callback accumulator update_accum_conf
add_display_item "Accumulator " accumulator parameter

add_parameter accum_direction STRING "ADD"
set_parameter_property accum_direction DEFAULT_VALUE "ADD"
set_parameter_property accum_direction DISPLAY_NAME "What is the accumulator operation type?"
set_parameter_property accum_direction ALLOWED_RANGES {"ADD" "SUB"}
set_parameter_property accum_direction UNITS None
set_parameter_property accum_direction DISPLAY_HINT ""
set_parameter_property accum_direction AFFECTS_GENERATION true
set_parameter_property accum_direction HDL_PARAMETER true
set_parameter_property accum_direction DESCRIPTION ""
add_display_item "Accumulator " accum_direction parameter

add_display_item "Accumulator " "Preload constant" GROUP

add_parameter gui_ena_preload_const boolean 0
set_parameter_property gui_ena_preload_const DEFAULT_VALUE 0
set_parameter_property gui_ena_preload_const DISPLAY_NAME "Enable preload constant"
set_parameter_property gui_ena_preload_const UNITS None
set_parameter_property gui_ena_preload_const DISPLAY_HINT ""
set_parameter_property gui_ena_preload_const AFFECTS_GENERATION true
set_parameter_property gui_ena_preload_const HDL_PARAMETER false
set_parameter_property gui_ena_preload_const DESCRIPTION ""
set_parameter_update_callback gui_ena_preload_const update_accmulate_port_select
add_display_item "Preload constant"  gui_ena_preload_const parameter


add_parameter gui_accumulate_port_select INTEGER 0
set_parameter_property gui_accumulate_port_select DEFAULT_VALUE 0
set_parameter_property gui_accumulate_port_select DISPLAY_NAME "What is the input of accumulate port connected to?"
set_parameter_property gui_accumulate_port_select ALLOWED_RANGES {0:ACCUM_SLOAD 1:SLOAD_ACCUM}
set_parameter_property gui_accumulate_port_select UNITS None
set_parameter_property gui_accumulate_port_select DISPLAY_HINT ""
set_parameter_property gui_accumulate_port_select AFFECTS_GENERATION true
set_parameter_property gui_accumulate_port_select HDL_PARAMETER false
set_parameter_property gui_accumulate_port_select DESCRIPTION "ACCUM_SLOAD PORT: The multiplier output is loaded into the accumulator when accum_sload port is high. 
SLOAD_ACCUM port: The multiplier output is loaded into the accumulator when sload_accum port is low."
add_display_item "Preload constant"  gui_accumulate_port_select parameter

add_parameter use_sload_accum_port STRING "NO"
set_parameter_property use_sload_accum_port DEFAULT_VALUE "NO"
set_parameter_property use_sload_accum_port VISIBLE false
set_parameter_property use_sload_accum_port ALLOWED_RANGES {"NO" "YES"}
set_parameter_property use_sload_accum_port AFFECTS_GENERATION true
set_parameter_property use_sload_accum_port DERIVED true
set_parameter_property use_sload_accum_port HDL_PARAMETER true

add_parameter loadconst_value INTEGER 64
set_parameter_property loadconst_value DEFAULT_VALUE 64
set_parameter_property loadconst_value DISPLAY_NAME "Select value for preload constant"
set_parameter_property loadconst_value ALLOWED_RANGES {0:64}
set_parameter_property loadconst_value UNITS None
set_parameter_property loadconst_value DISPLAY_HINT ""
set_parameter_property loadconst_value AFFECTS_GENERATION true
set_parameter_property loadconst_value HDL_PARAMETER true
set_parameter_property loadconst_value DESCRIPTION "Note: Default value of 64 will make constant value equal to 0 (Range of allowed values: 0 - 64)"
add_display_item "Preload constant" loadconst_value parameter

add_parameter gui_accum_sload_register boolean 0
set_parameter_property gui_accum_sload_register DEFAULT_VALUE 0
set_parameter_property gui_accum_sload_register DISPLAY_NAME "Register input of accum_sload"
set_parameter_property gui_accum_sload_register UNITS None
set_parameter_property gui_accum_sload_register DISPLAY_HINT ""
set_parameter_property gui_accum_sload_register AFFECTS_GENERATION true
set_parameter_property gui_accum_sload_register HDL_PARAMETER false
set_parameter_property gui_accum_sload_register DESCRIPTION ""
set_parameter_property gui_accum_sload_register DERIVED true
add_display_item "Preload constant"  gui_accum_sload_register parameter

add_parameter gui_accum_sload_register_clock STRING "CLOCK0"
set_parameter_property gui_accum_sload_register_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_accum_sload_register_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_accum_sload_register_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_accum_sload_register_clock UNITS None
set_parameter_property gui_accum_sload_register_clock DISPLAY_HINT ""
set_parameter_property gui_accum_sload_register_clock AFFECTS_GENERATION true
set_parameter_property gui_accum_sload_register_clock HDL_PARAMETER false
set_parameter_property gui_accum_sload_register_clock DESCRIPTION ""
add_display_item "Preload constant" gui_accum_sload_register_clock parameter 

add_parameter gui_accum_sload_register_aclr STRING "NONE"
set_parameter_property gui_accum_sload_register_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_accum_sload_register_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_accum_sload_register_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_accum_sload_register_aclr UNITS None
set_parameter_property gui_accum_sload_register_aclr DISPLAY_HINT ""
set_parameter_property gui_accum_sload_register_aclr AFFECTS_GENERATION true
set_parameter_property gui_accum_sload_register_aclr HDL_PARAMETER false
set_parameter_property gui_accum_sload_register_aclr DESCRIPTION ""
add_display_item "Preload constant" gui_accum_sload_register_aclr parameter 

add_parameter accum_sload_register STRING "UNREGISTERED"
set_parameter_property accum_sload_register DEFAULT_VALUE "UNREGISTERED"
set_parameter_property accum_sload_register VISIBLE false
set_parameter_property accum_sload_register ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property accum_sload_register AFFECTS_GENERATION true
set_parameter_property accum_sload_register DERIVED true
set_parameter_property accum_sload_register HDL_PARAMETER true 

add_parameter accum_sload_aclr STRING "NONE"
set_parameter_property accum_sload_aclr DEFAULT_VALUE "NONE"
set_parameter_property accum_sload_aclr VISIBLE false
set_parameter_property accum_sload_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property accum_sload_aclr AFFECTS_GENERATION true
set_parameter_property accum_sload_aclr DERIVED true
set_parameter_property accum_sload_aclr HDL_PARAMETER true

add_parameter gui_double_accum boolean 0
set_parameter_property gui_double_accum DEFAULT_VALUE 0
set_parameter_property gui_double_accum DISPLAY_NAME "Enable double accumulator"
set_parameter_property gui_double_accum UNITS None
set_parameter_property gui_double_accum DISPLAY_HINT ""
set_parameter_property gui_double_accum AFFECTS_GENERATION true
set_parameter_property gui_double_accum HDL_PARAMETER false
set_parameter_property gui_double_accum DESCRIPTION ""
add_display_item "Preload constant"  gui_double_accum parameter 


add_parameter double_accum STRING "NO"
set_parameter_property double_accum DEFAULT_VALUE "NO"
set_parameter_property double_accum VISIBLE false
set_parameter_property double_accum ALLOWED_RANGES {"NO" "YES"}
set_parameter_property double_accum AFFECTS_GENERATION true
set_parameter_property double_accum DERIVED true
set_parameter_property double_accum HDL_PARAMETER true

# +-----------------------------------
#
# | "Systolic/Chain Adder " tab
# | 
# +-----------------------------------
add_display_item "Systolic/Chain Adder" "Chain Adder" GROUP

add_parameter width_chainin INTEGER 1
set_parameter_property width_chainin DEFAULT_VALUE 1
set_parameter_property width_chainin VISIBLE false
set_parameter_property width_chainin ALLOWED_RANGES {1:256}
set_parameter_property width_chainin DERIVED true
set_parameter_property width_chainin AFFECTS_GENERATION true
set_parameter_property width_chainin HDL_PARAMETER true

add_parameter gui_chainout_adder boolean 0
set_parameter_property gui_chainout_adder DEFAULT_VALUE 0
set_parameter_property gui_chainout_adder DISPLAY_NAME "Enable chainout adder"
set_parameter_property gui_chainout_adder VISIBLE false
set_parameter_property gui_chainout_adder UNITS None
set_parameter_property gui_chainout_adder DISPLAY_HINT ""
set_parameter_property gui_chainout_adder AFFECTS_GENERATION true
set_parameter_property gui_chainout_adder HDL_PARAMETER false
set_parameter_property gui_chainout_adder DESCRIPTION ""
add_display_item "Chain Adder"  gui_chainout_adder parameter

add_parameter chainout_adder STRING "NO"
set_parameter_property chainout_adder DEFAULT_VALUE "NO"
set_parameter_property chainout_adder ALLOWED_RANGES {"NO" "YES"}
set_parameter_property chainout_adder VISIBLE false
set_parameter_property chainout_adder UNITS None
set_parameter_property chainout_adder AFFECTS_GENERATION true
set_parameter_property chainout_adder HDL_PARAMETER true
set_parameter_property chainout_adder DESCRIPTION ""

add_display_item "Systolic/Chain Adder" "Systolic Delay" GROUP

add_parameter gui_systolic_delay boolean 0
set_parameter_property gui_systolic_delay DEFAULT_VALUE 0
set_parameter_property gui_systolic_delay DISPLAY_NAME "Enable systolic delay registers"
set_parameter_property gui_systolic_delay UNITS None
set_parameter_property gui_systolic_delay DISPLAY_HINT ""
set_parameter_property gui_systolic_delay AFFECTS_GENERATION true
set_parameter_property gui_systolic_delay HDL_PARAMETER false
set_parameter_property gui_systolic_delay DESCRIPTION ""
add_display_item "Systolic Delay"  gui_systolic_delay parameter

add_parameter gui_systolic_delay_clock STRING "CLOCK0"
set_parameter_property gui_systolic_delay_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_systolic_delay_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_systolic_delay_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_systolic_delay_clock UNITS None
set_parameter_property gui_systolic_delay_clock DISPLAY_HINT ""
set_parameter_property gui_systolic_delay_clock AFFECTS_GENERATION true
set_parameter_property gui_systolic_delay_clock HDL_PARAMETER false
set_parameter_property gui_systolic_delay_clock DESCRIPTION ""
add_display_item "Systolic Delay" gui_systolic_delay_clock parameter 

add_parameter gui_systolic_delay_aclr STRING "NONE"
set_parameter_property gui_systolic_delay_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_systolic_delay_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_systolic_delay_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_systolic_delay_aclr UNITS None
set_parameter_property gui_systolic_delay_aclr DISPLAY_HINT ""
set_parameter_property gui_systolic_delay_aclr AFFECTS_GENERATION true
set_parameter_property gui_systolic_delay_aclr HDL_PARAMETER false
set_parameter_property gui_systolic_delay_aclr DESCRIPTION ""
add_display_item "Systolic Delay" gui_systolic_delay_aclr parameter 

add_parameter systolic_delay1 STRING "UNREGISTERED"
set_parameter_property systolic_delay1 DEFAULT_VALUE "UNREGISTERED"
set_parameter_property systolic_delay1 VISIBLE false
set_parameter_property systolic_delay1 ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property systolic_delay1 AFFECTS_GENERATION true
set_parameter_property systolic_delay1 DERIVED true
set_parameter_property systolic_delay1 HDL_PARAMETER true 

add_parameter systolic_aclr1 STRING "NONE"
set_parameter_property systolic_aclr1 DEFAULT_VALUE "NONE"
set_parameter_property systolic_aclr1 VISIBLE false
set_parameter_property systolic_aclr1 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property systolic_aclr1 AFFECTS_GENERATION true
set_parameter_property systolic_aclr1 DERIVED true
set_parameter_property systolic_aclr1 HDL_PARAMETER true

add_parameter systolic_delay3 STRING "UNREGISTERED"
set_parameter_property systolic_delay3 DEFAULT_VALUE "UNREGISTERED"
set_parameter_property systolic_delay3 VISIBLE false
set_parameter_property systolic_delay3 ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property systolic_delay3 AFFECTS_GENERATION true
set_parameter_property systolic_delay3 DERIVED true
set_parameter_property systolic_delay3 HDL_PARAMETER true 

add_parameter systolic_aclr3 STRING "NONE"
set_parameter_property systolic_aclr3 DEFAULT_VALUE "NONE"
set_parameter_property systolic_aclr3 VISIBLE false
set_parameter_property systolic_aclr3 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property systolic_aclr3 AFFECTS_GENERATION true
set_parameter_property systolic_aclr3 DERIVED true
set_parameter_property systolic_aclr3 HDL_PARAMETER true

# +-----------------------------------
#
# | "Pipelining" tab, Pipelining
# | 
# +-----------------------------------
add_display_item "Pipelining" "Pipelining Configuration" GROUP

add_parameter gui_pipelining INTEGER 0
set_parameter_property gui_pipelining DEFAULT_VALUE 0
set_parameter_property gui_pipelining DISPLAY_NAME "Do you want to add pipeline register to the input?"
set_parameter_property gui_pipelining ALLOWED_RANGES {0:No 1:Yes}
set_parameter_property gui_pipelining UNITS None
set_parameter_property gui_pipelining DISPLAY_HINT ""
set_parameter_property gui_pipelining AFFECTS_GENERATION true
set_parameter_property gui_pipelining HDL_PARAMETER false
set_parameter_property gui_pipelining DESCRIPTION ""
set_parameter_update_callback gui_pipelining update_pipelining_update
add_display_item "Pipelining Configuration" gui_pipelining parameter

add_parameter latency INTEGER 0
set_parameter_property latency DEFAULT_VALUE 0
set_parameter_property latency DISPLAY_NAME "Please specify the number of latency clock cycles"
set_parameter_property latency ALLOWED_RANGES {0:999999}
set_parameter_property latency UNITS None
set_parameter_property latency DISPLAY_HINT ""
set_parameter_property latency AFFECTS_GENERATION true
set_parameter_property latency HDL_PARAMETER true
set_parameter_property latency DESCRIPTION ""
set_parameter_property latency ENABLED true
add_display_item "Pipelining Configuration" latency parameter

add_parameter gui_input_latency_clock STRING "CLOCK0"
set_parameter_property gui_input_latency_clock DEFAULT_VALUE "CLOCK0"
set_parameter_property gui_input_latency_clock DISPLAY_NAME "What is the source for clock input?"
set_parameter_property gui_input_latency_clock ALLOWED_RANGES {"CLOCK0" "CLOCK1" "CLOCK2"}
set_parameter_property gui_input_latency_clock UNITS None
set_parameter_property gui_input_latency_clock DISPLAY_HINT ""
set_parameter_property gui_input_latency_clock AFFECTS_GENERATION true
set_parameter_property gui_input_latency_clock HDL_PARAMETER false
set_parameter_property gui_input_latency_clock DESCRIPTION ""
add_display_item "Pipelining Configuration" gui_input_latency_clock parameter 

add_parameter gui_input_latency_aclr STRING "NONE"
set_parameter_property gui_input_latency_aclr DEFAULT_VALUE "NONE"
set_parameter_property gui_input_latency_aclr DISPLAY_NAME "What is the source for asynchronous clear input?"
set_parameter_property gui_input_latency_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1"}
set_parameter_property gui_input_latency_aclr UNITS None
set_parameter_property gui_input_latency_aclr DISPLAY_HINT ""
set_parameter_property gui_input_latency_aclr AFFECTS_GENERATION true
set_parameter_property gui_input_latency_aclr HDL_PARAMETER false
set_parameter_property gui_input_latency_aclr DESCRIPTION ""
add_display_item "Pipelining Configuration" gui_input_latency_aclr parameter 

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_a${i}_latency_clock STRING "UNREGISTERED"
set_parameter_property input_a${i}_latency_clock DEFAULT_VALUE "UNREGISTERED"
set_parameter_property input_a${i}_latency_clock VISIBLE false
set_parameter_property input_a${i}_latency_clock ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property input_a${i}_latency_clock AFFECTS_GENERATION true
set_parameter_property input_a${i}_latency_clock DERIVED true
set_parameter_property input_a${i}_latency_clock HDL_PARAMETER true
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_a${i}_latency_aclr STRING "NONE"
set_parameter_property input_a${i}_latency_aclr DEFAULT_VALUE "NONE"
set_parameter_property input_a${i}_latency_aclr VISIBLE false
set_parameter_property input_a${i}_latency_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property input_a${i}_latency_aclr AFFECTS_GENERATION true
set_parameter_property input_a${i}_latency_aclr DERIVED true
set_parameter_property input_a${i}_latency_aclr HDL_PARAMETER true
}

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_b${i}_latency_clock STRING "UNREGISTERED"
set_parameter_property input_b${i}_latency_clock DEFAULT_VALUE "UNREGISTERED"
set_parameter_property input_b${i}_latency_clock VISIBLE false
set_parameter_property input_b${i}_latency_clock ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property input_b${i}_latency_clock AFFECTS_GENERATION true
set_parameter_property input_b${i}_latency_clock DERIVED true
set_parameter_property input_b${i}_latency_clock HDL_PARAMETER true
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_b${i}_latency_aclr STRING "NONE"
set_parameter_property input_b${i}_latency_aclr DEFAULT_VALUE "NONE"
set_parameter_property input_b${i}_latency_aclr VISIBLE false
set_parameter_property input_b${i}_latency_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property input_b${i}_latency_aclr AFFECTS_GENERATION true
set_parameter_property input_b${i}_latency_aclr DERIVED true
set_parameter_property input_b${i}_latency_aclr HDL_PARAMETER true
}

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_c${i}_latency_clock STRING "UNREGISTERED"
set_parameter_property input_c${i}_latency_clock DEFAULT_VALUE "UNREGISTERED"
set_parameter_property input_c${i}_latency_clock VISIBLE false
set_parameter_property input_c${i}_latency_clock ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property input_c${i}_latency_clock AFFECTS_GENERATION true
set_parameter_property input_c${i}_latency_clock DERIVED true
set_parameter_property input_c${i}_latency_clock HDL_PARAMETER true
}
for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter input_c${i}_latency_aclr STRING "NONE"
set_parameter_property input_c${i}_latency_aclr DEFAULT_VALUE "NONE"
set_parameter_property input_c${i}_latency_aclr VISIBLE false
set_parameter_property input_c${i}_latency_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property input_c${i}_latency_aclr AFFECTS_GENERATION true
set_parameter_property input_c${i}_latency_aclr DERIVED true
set_parameter_property input_c${i}_latency_aclr HDL_PARAMETER true
}

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter coefsel${i}_latency_clock STRING "UNREGISTERED"
set_parameter_property coefsel${i}_latency_clock DEFAULT_VALUE "UNREGISTERED"
set_parameter_property coefsel${i}_latency_clock VISIBLE false
set_parameter_property coefsel${i}_latency_clock ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property coefsel${i}_latency_clock AFFECTS_GENERATION true
set_parameter_property coefsel${i}_latency_clock DERIVED true
set_parameter_property coefsel${i}_latency_clock HDL_PARAMETER true 
}

for { set i 0 } {$i < $NUMBER_OF_MULT} {incr i} {
add_parameter  coefsel${i}_latency_aclr STRING "NONE"
set_parameter_property coefsel${i}_latency_aclr DEFAULT_VALUE "NONE"
set_parameter_property coefsel${i}_latency_aclr VISIBLE false
set_parameter_property coefsel${i}_latency_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property coefsel${i}_latency_aclr AFFECTS_GENERATION true
set_parameter_property coefsel${i}_latency_aclr DERIVED true
set_parameter_property coefsel${i}_latency_aclr HDL_PARAMETER true
}

add_parameter signed_latency_clock_a STRING "UNREGISTERED"
set_parameter_property signed_latency_clock_a DEFAULT_VALUE "UNREGISTERED"
set_parameter_property signed_latency_clock_a VISIBLE false
set_parameter_property signed_latency_clock_a ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property signed_latency_clock_a AFFECTS_GENERATION true
set_parameter_property signed_latency_clock_a DERIVED true
set_parameter_property signed_latency_clock_a HDL_PARAMETER true

add_parameter signed_latency_aclr_a STRING "NONE"
set_parameter_property signed_latency_aclr_a DEFAULT_VALUE "NONE"
set_parameter_property signed_latency_aclr_a VISIBLE false
set_parameter_property signed_latency_aclr_a ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property signed_latency_aclr_a AFFECTS_GENERATION true
set_parameter_property signed_latency_aclr_a DERIVED true
set_parameter_property signed_latency_aclr_a HDL_PARAMETER true

add_parameter signed_latency_clock_b STRING "UNREGISTERED"
set_parameter_property signed_latency_clock_b DEFAULT_VALUE "UNREGISTERED"
set_parameter_property signed_latency_clock_b VISIBLE false
set_parameter_property signed_latency_clock_b ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property signed_latency_clock_b AFFECTS_GENERATION true
set_parameter_property signed_latency_clock_b DERIVED true
set_parameter_property signed_latency_clock_b HDL_PARAMETER true

add_parameter signed_latency_aclr_b STRING "NONE"
set_parameter_property signed_latency_aclr_b DEFAULT_VALUE "NONE"
set_parameter_property signed_latency_aclr_b VISIBLE false
set_parameter_property signed_latency_aclr_b ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property signed_latency_aclr_b AFFECTS_GENERATION true
set_parameter_property signed_latency_aclr_b DERIVED true
set_parameter_property signed_latency_aclr_b HDL_PARAMETER true

add_parameter addnsub_multiplier_latency_clock1 STRING "UNREGISTERED"
set_parameter_property addnsub_multiplier_latency_clock1 DEFAULT_VALUE "UNREGISTERED"
set_parameter_property addnsub_multiplier_latency_clock1 VISIBLE false
set_parameter_property addnsub_multiplier_latency_clock1 ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property addnsub_multiplier_latency_clock1 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_latency_clock1 DERIVED true
set_parameter_property addnsub_multiplier_latency_clock1 HDL_PARAMETER true

add_parameter addnsub_multiplier_latency_aclr1 STRING "NONE"
set_parameter_property addnsub_multiplier_latency_aclr1 DEFAULT_VALUE "NONE"
set_parameter_property addnsub_multiplier_latency_aclr1 VISIBLE false
set_parameter_property addnsub_multiplier_latency_aclr1 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property addnsub_multiplier_latency_aclr1 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_latency_aclr1 DERIVED true
set_parameter_property addnsub_multiplier_latency_aclr1 HDL_PARAMETER true

add_parameter addnsub_multiplier_latency_clock3 STRING "UNREGISTERED"
set_parameter_property addnsub_multiplier_latency_clock3 DEFAULT_VALUE "UNREGISTERED"
set_parameter_property addnsub_multiplier_latency_clock3 VISIBLE false
set_parameter_property addnsub_multiplier_latency_clock3 ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property addnsub_multiplier_latency_clock3 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_latency_clock3 DERIVED true
set_parameter_property addnsub_multiplier_latency_clock3 HDL_PARAMETER true

add_parameter addnsub_multiplier_latency_aclr3 STRING "NONE"
set_parameter_property addnsub_multiplier_latency_aclr3 DEFAULT_VALUE "NONE"
set_parameter_property addnsub_multiplier_latency_aclr3 VISIBLE false
set_parameter_property addnsub_multiplier_latency_aclr3 ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property addnsub_multiplier_latency_aclr3 AFFECTS_GENERATION true
set_parameter_property addnsub_multiplier_latency_aclr3 DERIVED true
set_parameter_property addnsub_multiplier_latency_aclr3 HDL_PARAMETER true

add_parameter accum_sload_latency_clock STRING "UNREGISTERED"
set_parameter_property accum_sload_latency_clock DEFAULT_VALUE "UNREGISTERED"
set_parameter_property accum_sload_latency_clock VISIBLE false
set_parameter_property accum_sload_latency_clock ALLOWED_RANGES {"UNREGISTERED" "CLOCK0" "CLOCK1" "CLOCK2" "CLOCK3"}
set_parameter_property accum_sload_latency_clock AFFECTS_GENERATION true
set_parameter_property accum_sload_latency_clock DERIVED true
set_parameter_property accum_sload_latency_clock HDL_PARAMETER true

add_parameter accum_sload_latency_aclr STRING "NONE"
set_parameter_property accum_sload_latency_aclr DEFAULT_VALUE "NONE"
set_parameter_property accum_sload_latency_aclr VISIBLE false
set_parameter_property accum_sload_latency_aclr ALLOWED_RANGES {"NONE" "ACLR0" "ACLR1" "ACLR2" "ACLR3"}
set_parameter_property accum_sload_latency_aclr AFFECTS_GENERATION true
set_parameter_property accum_sload_latency_aclr DERIVED true
set_parameter_property accum_sload_latency_aclr HDL_PARAMETER true

# +-----------------------------------
# | device family parameter
# |
add_parameter selected_device_family STRING
set_parameter_property selected_device_family HDL_PARAMETER true
set_parameter_property selected_device_family VISIBLE false
set_parameter_property selected_device_family SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property selected_device_family AFFECTS_GENERATION false

# +-----------------------------------
# | Internal use verification & validation parameter
# |
add_parameter reg_autovec_sim boolean 0
set_parameter_property reg_autovec_sim DEFAULT_VALUE 0
set_parameter_property reg_autovec_sim VISIBLE false
set_parameter_property reg_autovec_sim AFFECTS_GENERATION true
set_parameter_property reg_autovec_sim DERIVED false
set_parameter_property reg_autovec_sim HDL_PARAMETER false