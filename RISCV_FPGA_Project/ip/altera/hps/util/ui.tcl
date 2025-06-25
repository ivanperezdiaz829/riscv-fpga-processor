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


################################################################################
# UI-related Tcl Procedures
################################################################################

################################################################################
# A parameter UI callback that allows EMAC + I2C GUI-related choices.
# When to automatically switch an I2C pinset/mode
#  1. Go from EMAC using I2C to EMAC Unused
#  2. Go from EMAC using I2C to EMAC using MDIO
#  3. Go from anything to EMAC using I2C
#
proc on_emac_mode_switch {model_ns peripheral_name} {
################################################################################
    set pin_muxing_param_name [format [PIN_MUX_PARAM_FORMAT] $peripheral_name]
    set mode_param_name       [format    [MODE_PARAM_FORMAT] $peripheral_name]
    
    set selected_pin_set [get_parameter_value $pin_muxing_param_name]
    set selected_mode    [get_parameter_value $mode_param_name]

    get_linked_peripheral ${model_ns} $peripheral_name $selected_pin_set\
	i2c_name i2c_pin_set i2c_mode
    
    set i2c_pin_muxing_param_name [format [PIN_MUX_PARAM_FORMAT] $i2c_name]
    set i2c_mode_param_name       [format    [MODE_PARAM_FORMAT] $i2c_name]
    set i2c_selected_mode         [get_parameter_value $i2c_mode_param_name]
    
    if {[string match "*${i2c_name}*" $selected_mode]} {
	set_parameter_value $i2c_pin_muxing_param_name $i2c_pin_set
	set_parameter_value $i2c_mode_param_name       $i2c_mode
    } elseif {[string match "*${peripheral_name}*" $i2c_selected_mode]} {
	set_parameter_value $i2c_pin_muxing_param_name [UNUSED_MUX_VALUE]
	set_parameter_value $i2c_mode_param_name       [NA_MODE_VALUE]
    }
}
