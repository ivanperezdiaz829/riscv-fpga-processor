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


package require -exact qsys 13.0


set_module_property DESCRIPTION "Altera GPIO Lite"
set_module_property NAME altera_gpio_lite
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Altera GPIO Lite"
set_module_property GROUP "I/O"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_QSYS true
set_module_property HIDE_FROM_SOPC true

add_display_item "" "General" GROUP
add_display_item "" "Buffer" GROUP
add_display_item "" "Registers" GROUP
add_display_item "" "Advanced DDR features" GROUP

add_parameter PIN_TYPE STRING "output"
set_parameter_property PIN_TYPE DEFAULT_VALUE "output"
set_parameter_property PIN_TYPE DISPLAY_NAME "Data direction"
set_parameter_property PIN_TYPE ALLOWED_RANGES {"input" "output" "bidir"}
set_parameter_property PIN_TYPE AFFECTS_GENERATION true
set_parameter_property PIN_TYPE DESCRIPTION "Specify the data direction for the GPIO"
set_parameter_property PIN_TYPE HDL_PARAMETER true
add_display_item "General" PIN_TYPE parameter

add_parameter SIZE INTEGER 4
set_parameter_property SIZE DEFAULT_VALUE 4
set_parameter_property SIZE DISPLAY_NAME "Data width"
set_parameter_property SIZE AFFECTS_GENERATION true
set_parameter_property SIZE DESCRIPTION "Specify the data width"
set_parameter_property SIZE HDL_PARAMETER true
add_display_item "General" SIZE parameter

add_parameter gui_true_diff_buf BOOLEAN false ""
set_parameter_property gui_true_diff_buf DISPLAY_NAME "Use true differential buffer"
set_parameter_property gui_true_diff_buf AFFECTS_GENERATION true
set_parameter_property gui_true_diff_buf DESCRIPTION "Specify the use of true differential buffer"
set_parameter_property gui_true_diff_buf HDL_PARAMETER false
set_parameter_property gui_true_diff_buf VISIBLE true
set_parameter_property gui_true_diff_buf ENABLED true
add_display_item "Buffer" gui_true_diff_buf parameter

add_parameter gui_pseudo_diff_buf BOOLEAN false ""
set_parameter_property gui_pseudo_diff_buf DISPLAY_NAME "Use pseudo differential buffer"
set_parameter_property gui_pseudo_diff_buf AFFECTS_GENERATION true
set_parameter_property gui_pseudo_diff_buf DESCRIPTION "Specify the use of pseudo differential buffer"
set_parameter_property gui_pseudo_diff_buf HDL_PARAMETER false
set_parameter_property gui_pseudo_diff_buf VISIBLE true
set_parameter_property gui_pseudo_diff_buf ENABLED true
add_display_item "Buffer" gui_pseudo_diff_buf parameter

add_parameter gui_bus_hold BOOLEAN false ""
set_parameter_property gui_bus_hold DISPLAY_NAME "Use bus-hold circuitry"
set_parameter_property gui_bus_hold AFFECTS_GENERATION true
set_parameter_property gui_bus_hold DESCRIPTION "Specify the use of bus-hold circuitry"
set_parameter_property gui_bus_hold HDL_PARAMETER false
set_parameter_property gui_bus_hold VISIBLE true
set_parameter_property gui_bus_hold ENABLED true
add_display_item "Buffer" gui_bus_hold parameter

add_parameter gui_open_drain BOOLEAN false ""
set_parameter_property gui_open_drain DISPLAY_NAME "Use open drain output"
set_parameter_property gui_open_drain AFFECTS_GENERATION true
set_parameter_property gui_open_drain DESCRIPTION "Specify the use of open drain output"
set_parameter_property gui_open_drain HDL_PARAMETER false
set_parameter_property gui_open_drain VISIBLE true
set_parameter_property gui_open_drain ENABLED true
add_display_item "Buffer" gui_open_drain parameter


add_parameter gui_io_reg_mode STRING "bypass"
set_parameter_property gui_io_reg_mode DEFAULT_VALUE "bypass"
set_parameter_property gui_io_reg_mode DISPLAY_NAME "Register mode"
set_parameter_property gui_io_reg_mode ALLOWED_RANGES {"bypass" "single-register" "ddr"}
set_parameter_property gui_io_reg_mode AFFECTS_GENERATION true
set_parameter_property gui_io_reg_mode DESCRIPTION "Specify the register mode for the GPIO (Input, Output, or Both)"
set_parameter_property gui_io_reg_mode HDL_PARAMETER false
set_parameter_property gui_io_reg_mode VISIBLE true
add_display_item "Registers" gui_io_reg_mode parameter

add_parameter gui_aclr_aset_port_setting STRING "None"
set_parameter_property gui_aclr_aset_port_setting DEFAULT_VALUE "None"
set_parameter_property gui_aclr_aset_port_setting DISPLAY_NAME "Port aclr/aset setting"
set_parameter_property gui_aclr_aset_port_setting ALLOWED_RANGES {"None" "Enable aclr port" "Enable aset port" "Set registers to power up high (when aclr and aset ports are not used)"}
set_parameter_property gui_aclr_aset_port_setting AFFECTS_GENERATION true
set_parameter_property gui_aclr_aset_port_setting DESCRIPTION "Specify the aclr /aset port setting"
set_parameter_property gui_aclr_aset_port_setting HDL_PARAMETER false
set_parameter_property gui_aclr_aset_port_setting VISIBLE true
add_display_item "Registers" gui_aclr_aset_port_setting parameter

add_parameter gui_clock_enable BOOLEAN false ""
set_parameter_property gui_clock_enable DISPLAY_NAME "Enable inclocken/outclocken ports"
set_parameter_property gui_clock_enable AFFECTS_GENERATION true
set_parameter_property gui_clock_enable DESCRIPTION "Add a clock enable port to control when data input and output are clocked in. This signal prevents data from being passed through."
set_parameter_property gui_clock_enable HDL_PARAMETER false
set_parameter_property gui_clock_enable VISIBLE true
set_parameter_property gui_clock_enable ENABLED true
add_display_item "Registers" gui_clock_enable parameter

add_parameter gui_invert_output BOOLEAN false ""
set_parameter_property gui_invert_output DISPLAY_NAME "Invert din"
set_parameter_property gui_invert_output AFFECTS_GENERATION true
set_parameter_property gui_invert_output DESCRIPTION "Use this option to invert the data to be output through the DDIO register."
set_parameter_property gui_invert_output HDL_PARAMETER false
set_parameter_property gui_invert_output VISIBLE true
set_parameter_property gui_invert_output ENABLED true
add_display_item "Registers" gui_invert_output parameter

add_parameter gui_invert_input_clock BOOLEAN false ""
set_parameter_property gui_invert_input_clock DISPLAY_NAME "Invert inclock"
set_parameter_property gui_invert_input_clock AFFECTS_GENERATION true
set_parameter_property gui_invert_input_clock DESCRIPTION "Use this option to invert the input clock."
set_parameter_property gui_invert_input_clock HDL_PARAMETER false
set_parameter_property gui_invert_input_clock VISIBLE true
set_parameter_property gui_invert_input_clock ENABLED true
add_display_item "Registers" gui_invert_input_clock parameter

add_parameter gui_use_register_to_drive_obuf_oe BOOLEAN false ""
set_parameter_property gui_use_register_to_drive_obuf_oe DISPLAY_NAME "Use a single register to drive the output enable (oe) signal at the I/O buffer"
set_parameter_property gui_use_register_to_drive_obuf_oe AFFECTS_GENERATION true
set_parameter_property gui_use_register_to_drive_obuf_oe DESCRIPTION "Use a single register to drive the output enable (oe) signal at the I/O buffer."
set_parameter_property gui_use_register_to_drive_obuf_oe HDL_PARAMETER false
set_parameter_property gui_use_register_to_drive_obuf_oe VISIBLE true
set_parameter_property gui_use_register_to_drive_obuf_oe ENABLED true
add_display_item "Registers" gui_use_register_to_drive_obuf_oe parameter

add_parameter gui_use_ddio_reg_to_drive_oe BOOLEAN false ""
set_parameter_property gui_use_ddio_reg_to_drive_oe DISPLAY_NAME "Use DDIO registers to drive the output enable (oe) signal at the I/O buffer"
set_parameter_property gui_use_ddio_reg_to_drive_oe AFFECTS_GENERATION true
set_parameter_property gui_use_ddio_reg_to_drive_oe DESCRIPTION "When this option is used, the output pin is held at high impedance for an extra half clock cycle after the output_enable port goes high."
set_parameter_property gui_use_ddio_reg_to_drive_oe HDL_PARAMETER false
set_parameter_property gui_use_ddio_reg_to_drive_oe VISIBLE true
set_parameter_property gui_use_ddio_reg_to_drive_oe ENABLED true
add_display_item "Registers" gui_use_ddio_reg_to_drive_oe parameter

add_parameter gui_use_advanced_ddr_features BOOLEAN false ""
set_parameter_property gui_use_advanced_ddr_features DISPLAY_NAME "Enable advanced DDR features"
set_parameter_property gui_use_advanced_ddr_features AFFECTS_GENERATION true
set_parameter_property gui_use_advanced_ddr_features DESCRIPTION "Specify whether to enable advanced DDR features in the IO and enable the IO clock divider for input and bidir pin"
set_parameter_property gui_use_advanced_ddr_features HDL_PARAMETER false
set_parameter_property gui_use_advanced_ddr_features VISIBLE false
set_parameter_property gui_use_advanced_ddr_features ENABLED true
add_display_item "Advanced DDR features" gui_use_advanced_ddr_features parameter

add_parameter gui_invert_clkdiv_input_clock BOOLEAN false ""
set_parameter_property gui_invert_clkdiv_input_clock DISPLAY_NAME "Invert clock divider input clock"
set_parameter_property gui_invert_clkdiv_input_clock AFFECTS_GENERATION true
set_parameter_property gui_invert_clkdiv_input_clock DESCRIPTION "Specify whether to invert the input clock of clock divider"
set_parameter_property gui_invert_clkdiv_input_clock HDL_PARAMETER false
set_parameter_property gui_invert_clkdiv_input_clock VISIBLE false
set_parameter_property gui_invert_clkdiv_input_clock ENABLED true
add_display_item "Advanced DDR features" gui_invert_clkdiv_input_clock parameter





add_parameter REGISTER_MODE STRING "bypass"
set_parameter_property REGISTER_MODE DEFAULT_VALUE "bypass"
set_parameter_property REGISTER_MODE ALLOWED_RANGES {"bypass" "single-register" "ddr"}
set_parameter_property REGISTER_MODE AFFECTS_GENERATION true
set_parameter_property REGISTER_MODE HDL_PARAMETER true
set_parameter_property REGISTER_MODE VISIBLE false
set_parameter_property REGISTER_MODE DERIVED true

add_parameter BUFFER_TYPE STRING "single-ended"
set_parameter_property BUFFER_TYPE DEFAULT_VALUE "single-ended"
set_parameter_property BUFFER_TYPE ALLOWED_RANGES {"single-ended" "true_differential" "pseudo_differential"}
set_parameter_property BUFFER_TYPE AFFECTS_GENERATION true
set_parameter_property BUFFER_TYPE HDL_PARAMETER true
set_parameter_property BUFFER_TYPE VISIBLE false
set_parameter_property BUFFER_TYPE DERIVED true


add_parameter ASYNC_MODE STRING "none"
set_parameter_property ASYNC_MODE DEFAULT_VALUE "none"
set_parameter_property ASYNC_MODE ALLOWED_RANGES {"none" "preset" "clear"}
set_parameter_property ASYNC_MODE AFFECTS_GENERATION true
set_parameter_property ASYNC_MODE HDL_PARAMETER true
set_parameter_property ASYNC_MODE VISIBLE false
set_parameter_property ASYNC_MODE DERIVED true

add_parameter BUS_HOLD STRING "false"
set_parameter_property BUS_HOLD DEFAULT_VALUE "false"
set_parameter_property BUS_HOLD ALLOWED_RANGES {"true" "false"}
set_parameter_property BUS_HOLD AFFECTS_GENERATION true
set_parameter_property BUS_HOLD HDL_PARAMETER true
set_parameter_property BUS_HOLD VISIBLE false
set_parameter_property BUS_HOLD DERIVED true

add_parameter OPEN_DRAIN_OUTPUT STRING "false"
set_parameter_property OPEN_DRAIN_OUTPUT DEFAULT_VALUE "false"
set_parameter_property OPEN_DRAIN_OUTPUT ALLOWED_RANGES {"true" "false"}
set_parameter_property OPEN_DRAIN_OUTPUT AFFECTS_GENERATION true
set_parameter_property OPEN_DRAIN_OUTPUT HDL_PARAMETER true
set_parameter_property OPEN_DRAIN_OUTPUT VISIBLE false
set_parameter_property OPEN_DRAIN_OUTPUT DERIVED true


add_parameter SET_REGISTER_OUTPUTS_HIGH STRING "false"
set_parameter_property SET_REGISTER_OUTPUTS_HIGH DEFAULT_VALUE "false"
set_parameter_property SET_REGISTER_OUTPUTS_HIGH ALLOWED_RANGES {"true" "false"}
set_parameter_property SET_REGISTER_OUTPUTS_HIGH AFFECTS_GENERATION true
set_parameter_property SET_REGISTER_OUTPUTS_HIGH HDL_PARAMETER true
set_parameter_property SET_REGISTER_OUTPUTS_HIGH VISIBLE false
set_parameter_property SET_REGISTER_OUTPUTS_HIGH DERIVED true

add_parameter INVERT_OUTPUT STRING "false"
set_parameter_property INVERT_OUTPUT DEFAULT_VALUE "false"
set_parameter_property INVERT_OUTPUT ALLOWED_RANGES {"true" "false"}
set_parameter_property INVERT_OUTPUT AFFECTS_GENERATION true
set_parameter_property INVERT_OUTPUT HDL_PARAMETER true
set_parameter_property INVERT_OUTPUT VISIBLE false
set_parameter_property INVERT_OUTPUT DERIVED true

add_parameter INVERT_INPUT_CLOCK STRING "false"
set_parameter_property INVERT_INPUT_CLOCK DEFAULT_VALUE "false"
set_parameter_property INVERT_INPUT_CLOCK ALLOWED_RANGES {"true" "false"}
set_parameter_property INVERT_INPUT_CLOCK AFFECTS_GENERATION true
set_parameter_property INVERT_INPUT_CLOCK HDL_PARAMETER true
set_parameter_property INVERT_INPUT_CLOCK VISIBLE false
set_parameter_property INVERT_INPUT_CLOCK DERIVED true

add_parameter USE_ONE_REG_TO_DRIVE_OE STRING "false"
set_parameter_property USE_ONE_REG_TO_DRIVE_OE DEFAULT_VALUE "false"
set_parameter_property USE_ONE_REG_TO_DRIVE_OE ALLOWED_RANGES {"true" "false"}
set_parameter_property USE_ONE_REG_TO_DRIVE_OE AFFECTS_GENERATION true
set_parameter_property USE_ONE_REG_TO_DRIVE_OE HDL_PARAMETER true
set_parameter_property USE_ONE_REG_TO_DRIVE_OE VISIBLE false
set_parameter_property USE_ONE_REG_TO_DRIVE_OE DERIVED true

add_parameter USE_DDIO_REG_TO_DRIVE_OE STRING "false"
set_parameter_property USE_DDIO_REG_TO_DRIVE_OE DEFAULT_VALUE "false"
set_parameter_property USE_DDIO_REG_TO_DRIVE_OE ALLOWED_RANGES {"true" "false"}
set_parameter_property USE_DDIO_REG_TO_DRIVE_OE AFFECTS_GENERATION true
set_parameter_property USE_DDIO_REG_TO_DRIVE_OE HDL_PARAMETER true
set_parameter_property USE_DDIO_REG_TO_DRIVE_OE VISIBLE false
set_parameter_property USE_DDIO_REG_TO_DRIVE_OE DERIVED true

add_parameter USE_ADVANCED_DDR_FEATURES STRING "false"
set_parameter_property USE_ADVANCED_DDR_FEATURES DEFAULT_VALUE "false"
set_parameter_property USE_ADVANCED_DDR_FEATURES ALLOWED_RANGES {"true" "false"}
set_parameter_property USE_ADVANCED_DDR_FEATURES AFFECTS_GENERATION true
set_parameter_property USE_ADVANCED_DDR_FEATURES HDL_PARAMETER true
set_parameter_property USE_ADVANCED_DDR_FEATURES VISIBLE false
set_parameter_property USE_ADVANCED_DDR_FEATURES DERIVED true

add_parameter INVERT_CLKDIV_INPUT_CLOCK STRING "false"
set_parameter_property INVERT_CLKDIV_INPUT_CLOCK DEFAULT_VALUE "false"
set_parameter_property INVERT_CLKDIV_INPUT_CLOCK ALLOWED_RANGES {"true" "false"}
set_parameter_property INVERT_CLKDIV_INPUT_CLOCK AFFECTS_GENERATION true
set_parameter_property INVERT_CLKDIV_INPUT_CLOCK HDL_PARAMETER true
set_parameter_property INVERT_CLKDIV_INPUT_CLOCK VISIBLE false
set_parameter_property INVERT_CLKDIV_INPUT_CLOCK DERIVED true


    
source altera_gpio_lite_hw_extra.tcl


