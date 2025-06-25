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


for { set i 0 } {$i < 2} {incr i} {
#add_display_item "Output Clocks" "outclk$i" GROUP
add_parameter gui_output_clock_frequency$i FLOAT "100.0"
set_parameter_property gui_output_clock_frequency$i DEFAULT_VALUE "100.0"
set_parameter_property gui_output_clock_frequency$i DISPLAY_NAME "Desired Frequency"
set_parameter_property gui_output_clock_frequency$i UNITS "megahertz"
set_parameter_property gui_output_clock_frequency$i VISIBLE false
set_parameter_property gui_output_clock_frequency$i AFFECTS_GENERATION true
set_parameter_property gui_output_clock_frequency$i HDL_PARAMETER false
set_parameter_property gui_output_clock_frequency$i DERIVED true
set_parameter_property gui_output_clock_frequency$i DESCRIPTION "Specifies requested value for output clock frequency"
add_display_item "outclk$i" gui_output_clock_frequency$i parameter 

add_parameter gui_divide_factor_c$i INTEGER "1"
set_parameter_property gui_divide_factor_c$i DEFAULT_VALUE "1"
set_parameter_property gui_divide_factor_c$i DISPLAY_NAME "Divide Factor (C-Counter)"
set_parameter_property gui_divide_factor_c$i UNITS ""
set_parameter_property gui_divide_factor_c$i ALLOWED_RANGES {1:512}
set_parameter_property gui_divide_factor_c$i VISIBLE false
set_parameter_property gui_divide_factor_c$i AFFECTS_GENERATION true
set_parameter_property gui_divide_factor_c$i HDL_PARAMETER false
set_parameter_property gui_divide_factor_c$i DESCRIPTION "Specifies requested value for the divide factor for the output clock"
add_display_item "outclk$i" gui_divide_factor_c$i parameter

add_parameter gui_actual_multiply_factor$i INTEGER "1"
set_parameter_property gui_actual_multiply_factor$i DEFAULT_VALUE "1"
set_parameter_property gui_actual_multiply_factor$i DISPLAY_NAME "Actual Multiply Factor"
set_parameter_property gui_actual_multiply_factor$i UNITS ""
set_parameter_property gui_actual_multiply_factor$i VISIBLE false
set_parameter_property gui_actual_multiply_factor$i DERIVED true
set_parameter_property gui_actual_multiply_factor$i AFFECTS_GENERATION true
set_parameter_property gui_actual_multiply_factor$i HDL_PARAMETER false
set_parameter_property gui_actual_multiply_factor$i DESCRIPTION "Specifies actual value for the multiply factor for the output clock"
add_display_item "outclk$i" gui_actual_multiply_factor$i parameter

add_parameter gui_actual_frac_multiply_factor$i LONG "1"
set_parameter_property gui_actual_frac_multiply_factor$i DEFAULT_VALUE "1"
set_parameter_property gui_actual_frac_multiply_factor$i DISPLAY_NAME "Actual Fractional Multiply Factor (K)"
set_parameter_property gui_actual_frac_multiply_factor$i UNITS ""
set_parameter_property gui_actual_frac_multiply_factor$i VISIBLE false
set_parameter_property gui_actual_frac_multiply_factor$i DERIVED true
set_parameter_property gui_actual_frac_multiply_factor$i AFFECTS_GENERATION true
set_parameter_property gui_actual_frac_multiply_factor$i HDL_PARAMETER false
set_parameter_property gui_actual_frac_multiply_factor$i DESCRIPTION "Specifies actual value for the fractional multiply factor for the output clock"
add_display_item "outclk$i" gui_actual_frac_multiply_factor$i parameter

add_parameter gui_actual_divide_factor$i INTEGER "1"
set_parameter_property gui_actual_divide_factor$i DEFAULT_VALUE "1"
set_parameter_property gui_actual_divide_factor$i DISPLAY_NAME "Actual Divide Factor"
set_parameter_property gui_actual_divide_factor$i UNITS ""
set_parameter_property gui_actual_divide_factor$i VISIBLE false
set_parameter_property gui_actual_divide_factor$i DERIVED true
set_parameter_property gui_actual_divide_factor$i AFFECTS_GENERATION true
set_parameter_property gui_actual_divide_factor$i HDL_PARAMETER false
set_parameter_property gui_actual_divide_factor$i DESCRIPTION "Specifies actual value for the divide factor for the output clock"
add_display_item "outclk$i" gui_actual_divide_factor$i parameter

add_parameter gui_actual_output_clock_frequency$i STRING ""
#set_parameter_property gui_actual_output_clock_frequency$i DEFAULT_VALUE "0 MHz"
set_parameter_property gui_actual_output_clock_frequency$i DISPLAY_NAME "Actual Frequency"
set_parameter_property gui_actual_output_clock_frequency$i VISIBLE false
set_parameter_property gui_actual_output_clock_frequency$i AFFECTS_GENERATION true
set_parameter_property gui_actual_output_clock_frequency$i HDL_PARAMETER false
set_parameter_property gui_actual_output_clock_frequency$i DESCRIPTION "Specifies actual value for output clock frequency"
add_display_item "outclk$i" gui_actual_output_clock_frequency$i parameter 

add_parameter gui_ps_units$i STRING "ps"
set_parameter_property gui_ps_units$i DEFAULT_VALUE "ps"
set_parameter_property gui_ps_units$i DISPLAY_NAME "Phase Shift units"
set_parameter_property gui_ps_units$i VISIBLE false 
set_parameter_property gui_ps_units$i UNITS None
set_parameter_property gui_ps_units$i ALLOWED_RANGES {"ps" "degrees"}
set_parameter_property gui_ps_units$i AFFECTS_GENERATION true
set_parameter_property gui_ps_units$i HDL_PARAMETER false
set_parameter_property gui_ps_units$i DESCRIPTION "Enter phase shift in degrees or picoseconds."
add_display_item "outclk$i" gui_ps_units$i parameter 

add_parameter gui_phase_shift$i INTEGER "0"
set_parameter_property gui_phase_shift$i DEFAULT_VALUE "0"
set_parameter_property gui_phase_shift$i DISPLAY_NAME "Phase Shift"
set_parameter_property gui_phase_shift$i UNITS "picoseconds"
set_parameter_property gui_phase_shift$i VISIBLE false
set_parameter_property gui_phase_shift$i AFFECTS_GENERATION true
set_parameter_property gui_phase_shift$i HDL_PARAMETER false
set_parameter_property gui_phase_shift$i DESCRIPTION "Specifies requested value for phase shift"
add_display_item "outclk$i" gui_phase_shift$i parameter

add_parameter gui_phase_shift_deg$i INTEGER "0"
set_parameter_property gui_phase_shift_deg$i DEFAULT_VALUE "0"
set_parameter_property gui_phase_shift_deg$i DISPLAY_NAME "Phase Shift"
set_parameter_property gui_phase_shift_deg$i DISPLAY_UNITS "degrees"
set_parameter_property gui_phase_shift_deg$i ALLOWED_RANGES {-360:360}
set_parameter_property gui_phase_shift_deg$i VISIBLE false
set_parameter_property gui_phase_shift_deg$i AFFECTS_GENERATION true
set_parameter_property gui_phase_shift_deg$i HDL_PARAMETER false
set_parameter_property gui_phase_shift_deg$i DESCRIPTION "Specifies requested value for phase shift"
add_display_item "outclk$i" gui_phase_shift_deg$i parameter

add_parameter gui_actual_phase_shift$i STRING "0"
set_parameter_property gui_actual_phase_shift$i DEFAULT_VALUE "0"
set_parameter_property gui_actual_phase_shift$i DISPLAY_NAME "Actual Phase Shift"
set_parameter_property gui_actual_phase_shift$i VISIBLE false
set_parameter_property gui_actual_phase_shift$i AFFECTS_GENERATION true
set_parameter_property gui_actual_phase_shift$i HDL_PARAMETER false
set_parameter_property gui_actual_phase_shift$i DESCRIPTION "Specifies actual value for phase shift"
add_display_item "outclk$i" gui_actual_phase_shift$i parameter 

add_parameter gui_duty_cycle$i INTEGER 50
set_parameter_property gui_duty_cycle$i DEFAULT_VALUE 50
set_parameter_property gui_duty_cycle$i DISPLAY_NAME "Duty Cycle"
set_parameter_property gui_duty_cycle$i UNITS "percent"
set_parameter_property gui_duty_cycle$i ALLOWED_RANGES {1:99}
set_parameter_property gui_duty_cycle$i VISIBLE false
set_parameter_property gui_duty_cycle$i AFFECTS_GENERATION true
set_parameter_property gui_duty_cycle$i HDL_PARAMETER false
set_parameter_property gui_duty_cycle$i DESCRIPTION "Specifies requested value for duty cycle"
add_display_item "outclk$i" gui_duty_cycle$i parameter
}

for { set i 0 } {$i < 18} {incr i} {
add_parameter output_clock_frequency$i STRING "0 MHz"
set_parameter_property output_clock_frequency$i DEFAULT_VALUE "0 MHz"
set_parameter_property output_clock_frequency$i VISIBLE false
set_parameter_property output_clock_frequency$i AFFECTS_GENERATION true
set_parameter_property output_clock_frequency$i DERIVED true
set_parameter_property output_clock_frequency$i HDL_PARAMETER false
#add_display_item "Output Clocks" output_clock_frequency$i parameter

add_parameter phase_shift$i STRING "0 ps"
set_parameter_property phase_shift$i DEFAULT_VALUE "0 ps"
set_parameter_property phase_shift$i UNITS "picoseconds"
set_parameter_property phase_shift$i VISIBLE false
set_parameter_property phase_shift$i AFFECTS_GENERATION true
set_parameter_property phase_shift$i DERIVED true
set_parameter_property phase_shift$i HDL_PARAMETER false
#add_display_item "Output Clocks" phase_shift$i parameter

add_parameter duty_cycle$i INTEGER 50
set_parameter_property duty_cycle$i DEFAULT_VALUE 50
set_parameter_property duty_cycle$i ALLOWED_RANGES {1:99}
set_parameter_property duty_cycle$i VISIBLE false
set_parameter_property duty_cycle$i AFFECTS_GENERATION true
set_parameter_property duty_cycle$i DERIVED true
set_parameter_property duty_cycle$i HDL_PARAMETER false
#add_display_item "Output Clocks" duty_cycle$i parameter
}

add_parameter fractional_vco_multiplier boolean 0
set_parameter_property fractional_vco_multiplier DEFAULT_VALUE 0
set_parameter_property fractional_vco_multiplier VISIBLE false
set_parameter_property fractional_vco_multiplier AFFECTS_GENERATION true
set_parameter_property fractional_vco_multiplier DERIVED true
set_parameter_property fractional_vco_multiplier ENABLED true
set_parameter_property fractional_vco_multiplier HDL_PARAMETER false


##########################################
# GENERAL DESIGN OPTIONS
##########################################


##########################################
# DIRECTION
##########################################
add_parameter direction STRING "Source"
set_parameter_property direction DISPLAY_NAME "Direction"
set_parameter_property direction DISPLAY_HINT radio
set_parameter_property direction ALLOWED_RANGES {"Source" "Sink" "Duplex"}
set_parameter_property direction AFFECTS_ELABORATION true
set_parameter_property direction AFFECTS_GENERATION true
set_parameter_property direction IS_HDL_PARAMETER false
add_display_item "General Design Options" direction PARAMETER
set_parameter_property direction VISIBLE true
set_parameter_property direction DESCRIPTION "Transmit/Receive Direction of the core"

##########################################
# LANES 
##########################################

add_parameter lanes INTEGER 4
set_parameter_property lanes DISPLAY_NAME "Lanes"
set_parameter_property lanes DISPLAY_HINT "Number of lanes"
set_parameter_property lanes ALLOWED_RANGES 1:24
set_parameter_property lanes AFFECTS_GENERATION true
set_parameter_property lanes IS_HDL_PARAMETER true
add_display_item "General Design Options" lanes PARAMETER
set_parameter_property lanes DESCRIPTION "Specifies the number of lanes on the link over which the streaming data is striped"
set_display_item_property lanes DISPLAY_HINT "columns:11"

##########################################
# pLL TYPE
##########################################

add_parameter pll_type STRING
set_parameter_property pll_type VISIBLE false
set_parameter_property pll_type HDL_PARAMETER true
set_parameter_property pll_type ENABLED true
set_parameter_property pll_type DERIVED true


# adding pll type parameter - GUI param is symbolic only
add_parameter gui_pll_type STRING "CMU"
set_parameter_property gui_pll_type DEFAULT_VALUE "CMU"
set_parameter_property gui_pll_type ALLOWED_RANGES {"CMU" "ATX"}
set_parameter_property gui_pll_type DISPLAY_NAME "PLL type"
set_parameter_property gui_pll_type UNITS None
set_parameter_property gui_pll_type ENABLED true
set_parameter_property gui_pll_type VISIBLE true
set_parameter_property gui_pll_type DISPLAY_HINT ""
set_parameter_property gui_pll_type HDL_PARAMETER false
set_parameter_property gui_pll_type DESCRIPTION "Specifies the PLL type"
add_display_item "General Design Options" gui_pll_type parameter
set_display_item_property gui_pll_type DISPLAY_HINT "columns:11"


##########################################
# SpeedGrade
##########################################
add_parameter speedgrade STRING "2"
set_parameter_property speedgrade DISPLAY_NAME "Device speed grade"
set_parameter_property speedgrade DISPLAY_HINT "Speed Grade of the device"
set_parameter_property speedgrade ALLOWED_RANGES {"1" "2" "3" "4"}
set_parameter_property speedgrade AFFECTS_ELABORATION true
set_parameter_property speedgrade AFFECTS_GENERATION true
set_parameter_property speedgrade IS_HDL_PARAMETER false
add_display_item "General Design Options" speedgrade PARAMETER
set_parameter_property speedgrade DESCRIPTION "Specifies the speed grade of the device"
set_display_item_property speedgrade DISPLAY_HINT "columns:11"


##########################################
# Mode of Operation 
##########################################




add_parameter mode STRING "continuous"
set_parameter_property mode DISPLAY_NAME "Mode"
set_parameter_property mode DISPLAY_HINT "Operation mode"
#set_parameter_property mode ALLOWED_RANGES {"continuous" "packet"}
set_parameter_property mode ALLOWED_RANGES {"continuous"}
set_parameter_property mode AFFECTS_ELABORATION true
set_parameter_property mode AFFECTS_GENERATION true
set_parameter_property mode IS_HDL_PARAMETER false
add_display_item "General Design Options" mode PARAMETER
set_parameter_property mode DESCRIPTION "Mode of operation"
set_parameter_property mode VISIBLE false

##########################################
# Adaptation & Lane FIFO Depths
##########################################

#add_parameter lane_fifo_depth INTEGER 16
#set_parameter_property lane_fifo_depth DISPLAY_NAME "Lane FIFO Depth"
#set_parameter_property lane_fifo_depth DISPLAY_HINT "lane_fifo_depth"
#set_parameter_property lane_fifo_depth ALLOWED_RANGES 1:16
#set_parameter_property lane_fifo_depth AFFECTS_ELABORATION true
#set_parameter_property lane_fifo_depth AFFECTS_GENERATION true
#set_parameter_property lane_fifo_depth IS_HDL_PARAMETER false
#set_parameter_property lane_fifo_depth VISIBLE false
##set_parameter_property lane_fifo_depth DERIVED true
#set_parameter_property lane_fifo_depth ENABLED false
#add_display_item "General Design Options" lane_fifo_depth PARAMETER
#set_parameter_property lane_fifo_depth DESCRIPTION "Specifies the depth of the lane alignment FIFO"

add_parameter adaptation_fifo_depth INTEGER 32
#set_parameter_property adaptation_fifo_depth DISPLAY_NAME "Adaptation FIFO Depth"
#set_parameter_property adaptation_fifo_depth DISPLAY_HINT "adaptation_fifo_depth"
set_parameter_property adaptation_fifo_depth ALLOWED_RANGES 1:32
#set_parameter_property adaptation_fifo_depth AFFECTS_ELABORATION true
set_parameter_property adaptation_fifo_depth AFFECTS_GENERATION true
set_parameter_property adaptation_fifo_depth IS_HDL_PARAMETER true
set_parameter_property adaptation_fifo_depth VISIBLE false
set_parameter_property adaptation_fifo_depth DERIVED true
set_parameter_property adaptation_fifo_depth ENABLED true

##########################################
# Metaframe Size
##########################################
add_parameter meta_frame_length INTEGER 8191
set_parameter_property meta_frame_length DISPLAY_NAME "Meta frame length"
set_parameter_property meta_frame_length DISPLAY_HINT "meta_frame_length"
set_parameter_property meta_frame_length ALLOWED_RANGES {5:8191}
set_parameter_property meta_frame_length AFFECTS_ELABORATION true
set_parameter_property meta_frame_length AFFECTS_GENERATION true
set_parameter_property meta_frame_length IS_HDL_PARAMETER true
set_parameter_property meta_frame_length DISPLAY_UNITS "words"
add_display_item "General Design Options" meta_frame_length PARAMETER
set_parameter_property meta_frame_length DESCRIPTION "Specifies the Meta Frame interval in words"
set_display_item_property meta_frame_length DISPLAY_HINT "columns:11"


##############################
#
#############################
add_parameter system_family STRING
set_parameter_property system_family SYSTEM_INFO DEVICE_FAMILY
set_parameter_property system_family VISIBLE false

##########################################
# ECC Protection
##########################################

add_parameter gui_ecc_enable BOOLEAN false
set_parameter_property gui_ecc_enable DISPLAY_NAME "ECC Protection"
set_parameter_property gui_ecc_enable DISPLAY_HINT "ECC Protection for Memory Blocks"
set_parameter_property gui_ecc_enable AFFECTS_ELABORATION true
set_parameter_property gui_ecc_enable AFFECTS_GENERATION true
set_parameter_property gui_ecc_enable IS_HDL_PARAMETER false
add_display_item "General Design Options" gui_ecc_enable PARAMETER
set_parameter_property gui_ecc_enable DESCRIPTION "ECC Protection for Memory Blocks"
set_parameter_property gui_ecc_enable VISIBLE true


add_parameter ecc_enable BOOLEAN false
set_parameter_property ecc_enable IS_HDL_PARAMETER true
set_parameter_property ecc_enable VISIBLE false
set_parameter_property ecc_enable DERIVED true
set_parameter_property ecc_enable ENABLED true

