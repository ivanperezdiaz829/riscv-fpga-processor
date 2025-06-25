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
# | 
# | Stratix IV analog parameter declarations
# | $Header: //acds/rel/13.1/ip/altera_xcvr_generic/tgx/alt_xcvr_s4_analog.tcl#1 $
# | 
# +-----------------------------------


set string_boolean_parameters {}

# +--------------------------------------------------------------------------------
# | Declare string parameter so that it shows up as a checkbox (boolean)
# |
# | String values must be limited to "true" and "false"
proc add_string_parameter_as_boolean {param defVal tags {dispName ""} {description ""} {dispItem ""}} {
	# current solution is to declare two parameters - one for GUI display only
	# and derive the real parameter value from the GUI-only parameter
	global string_boolean_parameters

	# Gui-only parameter
	add_parameter "gui_$param" BOOLEAN $defVal
	set_parameter_property "gui_$param" DEFAULT_VALUE $defVal
	set_parameter_property "gui_$param" DISPLAY_NAME $dispName
	set_parameter_property "gui_$param" HDL_PARAMETER false
	set_parameter_property "gui_$param" DESCRIPTION $description
	if {[ string length $dispItem ] > 0} {
		add_display_item $dispItem "gui_$param" parameter
	}
	common_set_parameter_tag "gui_$param" $tags	;# tag visible parameter, to allow visible property change

	# real parameter, derived from GUI-only parameter
	add_parameter $param STRING $defVal
	set_parameter_property $param DEFAULT_VALUE $defVal
	set_parameter_property $param HDL_PARAMETER true
	set_parameter_property $param DERIVED true
	set_parameter_property $param VISIBLE false
	lappend string_boolean_parameters $param	;# append to list or auto-derived string-boolean parameters
}

# +--------------------------------------------------------------------------------
# | Derive values for all string-boolean parameters
# |
proc derive_all_string_boolean_parameters {} {
	global string_boolean_parameters

	foreach p $string_boolean_parameters {
		set_parameter_value $p [get_parameter_value "gui_$p" ]
	}
}

# +-----------------------------------------------------------
# | This procedure adds all the SIV-generation analog options
# +-----------------------------------------------------------

proc add_s4_analog_parameters { {group "Analog Options"} } {

	# add all analog options

	#parameter gxb_analog_power
	#parameter pll_lock_speed
	#parameter rx_common_mode
	#parameter rx_eq_ctrl
	#parameter rx_eq_dc_gain
	#parameter rx_pll_lock_speed
	#parameter rx_ppmselect
	#parameter rx_signal_detect_threshold	;# 2 is only option, don't declare
	#parameter rx_termination
	#parameter tx_analog_power
	#parameter tx_common_mode
	#parameter tx_preemp_pretap
	#parameter tx_preemp_pretap_inv
	#parameter tx_preemp_tap_1
	#parameter tx_preemp_tap_2
	#parameter tx_preemp_tap_2_inv
	#parameter tx_slew_rate
	#parameter tx_termination
	#parameter tx_vod_selection

	# adding parameter for gxb_analog_power
	common_add_parameter gxb_analog_power STRING "AUTO" {S4}
	set_parameter_property gxb_analog_power DISPLAY_NAME "GXB analog power"
	set_parameter_property gxb_analog_power ALLOWED_RANGES {AUTO 2.5V 3.0V 3.3V 3.9V}
	set_parameter_property gxb_analog_power HDL_PARAMETER true
	add_display_item $group gxb_analog_power parameter

	# adding pll_lock_speed parameter
	common_add_parameter pll_lock_speed STRING "AUTO" {S4}
	set_parameter_property pll_lock_speed DISPLAY_NAME "PLL lock speed"
	set_parameter_property pll_lock_speed ALLOWED_RANGES {AUTO LOW MEDIUM HIGH}
	set_parameter_property pll_lock_speed HDL_PARAMETER true
	add_display_item $group pll_lock_speed parameter

	# adding tx_analog_power parameter
	common_add_parameter tx_analog_power STRING "AUTO" {S4}
	set_parameter_property tx_analog_power DISPLAY_NAME "TX analog power"
	set_parameter_property tx_analog_power ALLOWED_RANGES {"AUTO" "1.4V" "1.5V"}
	set_parameter_property tx_analog_power HDL_PARAMETER true
	add_display_item $group tx_analog_power parameter

	# adding tx_slew_rate parameter
	common_add_parameter tx_slew_rate STRING "OFF" {S4}
	set_parameter_property tx_slew_rate DISPLAY_NAME "TX slew rate"
	set_parameter_property tx_slew_rate ALLOWED_RANGES {"AUTO" "OFF" "LOW" "MEDIUM" "HIGH"}
	set_parameter_property tx_slew_rate HDL_PARAMETER true
	add_display_item $group tx_slew_rate parameter

	# adding tx_termination parameter
	common_add_parameter tx_termination STRING "OCT_100_OHMS" {S4}
	set_parameter_property tx_termination DISPLAY_NAME "Select the transmitter termination resistance"
	set_parameter_property tx_termination ALLOWED_RANGES {"OCT_85_OHMS" "OCT_100_OHMS" "OCT_120_OHMS" "OCT_150_OHMS"}
	set_parameter_property tx_termination HDL_PARAMETER true
	add_display_item $group tx_termination parameter
	
	common_add_parameter tx_use_external_termination STRING "false" {S4}
	set_parameter_property tx_use_external_termination DISPLAY_NAME "Enable receiver external termination"
	set_parameter_property tx_use_external_termination ALLOWED_RANGES {"true" "false"}
	set_parameter_property tx_use_external_termination HDL_PARAMETER true
	add_display_item $group tx_use_external_termination parameter

	# adding tx_preemp_pretap parameter
	common_add_parameter tx_preemp_pretap INTEGER 0 {S4}
	set_parameter_property tx_preemp_pretap DISPLAY_NAME "Select the pre-emphasis pre-tap setting"
	set_parameter_property tx_preemp_pretap ALLOWED_RANGES 0:7
	set_parameter_property tx_preemp_pretap HDL_PARAMETER true
	add_display_item $group tx_preemp_pretap parameter

	# adding tx_preemp_pretap_inv parameter
	add_string_parameter_as_boolean tx_preemp_pretap_inv false {S4} "Enable the pre-emphasis pre-tap polarity inversion" "" $group

	# adding tx_preemp_tap_1 parameter
	common_add_parameter tx_preemp_tap_1 INTEGER 0 {S4}
	set_parameter_property tx_preemp_tap_1 DISPLAY_NAME "Select the pre-emphasis first post-tap setting"
	set_parameter_property tx_preemp_tap_1 ALLOWED_RANGES 0:15
	set_parameter_property tx_preemp_tap_1 HDL_PARAMETER true
	add_display_item $group tx_preemp_tap_1 parameter

	# adding tx_preemp_tap_2 parameter
	common_add_parameter tx_preemp_tap_2 INTEGER 0 {S4}
	set_parameter_property tx_preemp_tap_2 DISPLAY_NAME "Specifies the pre-emphasis second post-tap setting"
	set_parameter_property tx_preemp_tap_2 ALLOWED_RANGES 0:7
	set_parameter_property tx_preemp_tap_2 HDL_PARAMETER true
	add_display_item $group tx_preemp_tap_2 parameter

	# adding tx_preemp_tap_2_inv parameter
	add_string_parameter_as_boolean tx_preemp_tap_2_inv false {S4} "Enable the pre-emphasis second post-tap polarity inversion" "" $group

	# adding tx_vod_selection parameter
	common_add_parameter tx_vod_selection INTEGER 2 {S4}
	set_parameter_property tx_vod_selection DISPLAY_NAME "Select the transmitter VOD control setting"
	set_parameter_property tx_vod_selection ALLOWED_RANGES 0:7
	set_parameter_property tx_vod_selection HDL_PARAMETER true
	add_display_item $group tx_vod_selection parameter

	# adding tx_common_mode parameter
	common_add_parameter tx_common_mode STRING "0.65V" {S4}
	set_parameter_property tx_common_mode DISPLAY_NAME "TX common mode"
	#set_parameter_property tx_common_mode ALLOWED_RANGES {"0.65V"}
	set_parameter_property tx_common_mode HDL_PARAMETER true
	add_display_item $group tx_common_mode parameter

	# adding rx_pll_lock_speed parameter
	common_add_parameter rx_pll_lock_speed STRING "AUTO" {S4}
	set_parameter_property rx_pll_lock_speed DISPLAY_NAME "RX PLL lock speed"
	set_parameter_property rx_pll_lock_speed ALLOWED_RANGES {"AUTO" "LOW" "MEDIUM" "HIGH"}
	set_parameter_property rx_pll_lock_speed HDL_PARAMETER true
	add_display_item $group rx_pll_lock_speed parameter

	# adding rx_common_mode parameter
	common_add_parameter rx_common_mode STRING "0.82V" {S4}
	set_parameter_property rx_common_mode DISPLAY_NAME "Select the receiver common mode voltage"
	set_parameter_property rx_common_mode ALLOWED_RANGES {"TRISTATE" "0.82V" "1.1V"}
	set_parameter_property rx_common_mode HDL_PARAMETER true
	add_display_item $group rx_common_mode parameter

# adding rx_signal_detect_threshold parameter
#common_add_parameter rx_signal_detect_threshold INTEGER 2 {S4}
#set_parameter_property rx_signal_detect_threshold DISPLAY_NAME "RX signal detect threshold"
#set_parameter_property rx_signal_detect_threshold ALLOWED_RANGES {2}
#set_parameter_property rx_signal_detect_threshold HDL_PARAMETER true
#add_display_item $group rx_signal_detect_threshold parameter

	# adding rx_ppmselect parameter
	#common_add_parameter rx_ppmselect INTEGER 32 {S4}
	#set_parameter_property rx_ppmselect DISPLAY_NAME "RX PPMSELECT"
	#set_parameter_property rx_ppmselect ALLOWED_RANGES {32}
	#set_parameter_property rx_ppmselect HDL_PARAMETER true
	#add_display_item $group rx_ppmselect parameter

	# adding rx_termination parameter
	common_add_parameter rx_termination STRING "OCT_100_OHMS" {S4}
	set_parameter_property rx_termination DISPLAY_NAME "Select the receiver termination resistance"
	set_parameter_property rx_termination ALLOWED_RANGES {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS}
	set_parameter_property rx_termination HDL_PARAMETER true
	add_display_item $group rx_termination parameter
	
	common_add_parameter rx_use_external_termination STRING "false" {S4}
	set_parameter_property rx_use_external_termination DISPLAY_NAME "Enable receiver external termination"
	set_parameter_property rx_use_external_termination ALLOWED_RANGES {"true" "false"}
	set_parameter_property rx_use_external_termination HDL_PARAMETER true
	add_display_item $group rx_use_external_termination parameter
	
	# adding rx_eq_dc_gain parameter
	common_add_parameter rx_eq_dc_gain INTEGER 1 {S4}
	set_parameter_property rx_eq_dc_gain DISPLAY_NAME "Select the receiver DC gain"
	set_parameter_property rx_eq_dc_gain ALLOWED_RANGES 0:4
	set_parameter_property rx_eq_dc_gain HDL_PARAMETER true
	add_display_item $group rx_eq_dc_gain parameter

	# adding rx_eq_ctrl parameter
	common_add_parameter rx_eq_ctrl INTEGER 16 {S4}
	set_parameter_property rx_eq_ctrl DISPLAY_NAME "Select the receiver static equalizer setting"
	set_parameter_property rx_eq_ctrl ALLOWED_RANGES 0:16
	set_parameter_property rx_eq_ctrl HDL_PARAMETER true
	add_display_item $group rx_eq_ctrl parameter
	
	# Initially set VISIBLE property to false
	common_set_parameter_group {S4} VISIBLE false
}
