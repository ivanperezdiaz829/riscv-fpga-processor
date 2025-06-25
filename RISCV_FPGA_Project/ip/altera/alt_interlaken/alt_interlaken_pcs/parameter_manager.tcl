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


proc get_pma_parameters { } {
	set infos [get_pma_parameter_info]
	array set params $infos
	set names [array names params]
	return $names
}

proc get_pma_parameter_info { } {
	return [list tx_termination "string" tx_vod_selection "integer" tx_preemp_pretap "integer" tx_preemp_pretap_inv "integer" tx_preemp_tap_1 "integer" tx_preemp_tap_2 "integer" tx_preemp_tap_2_inv "integer" rx_common_mode "string" rx_termination "string" rx_eq_dc_gain "integer" rx_eq_ctrl "integer" ]
}

proc add_pma_parameters { } {
	set params [get_pma_parameter_info]
	add_display_item "" "Analog Options" GROUP tab
	foreach {param type} $params {
		if { [string equal $type "string"] } {
			set defval ""
		} else {
			set defval 0
		}
		add_parameter $param $type $defval
		send_message 1 "adding parameter $param of type $type"
		set_parameter_property $param AFFECTS_GENERATION true
		set_parameter_property $param HDL_PARAMETER true
		#set_parameter_property $param VISIBLE false
		add_display_item "Analog Options" $param PARAMETER
	}
}

proc inherit_parameters { params instance } {
	send_message 1 "want to inherit props"
	set insts [get_instances]
     	set exists [lsearch $insts $instance]
	if { $exists == 1 } {
		send_message 1 "instance exists!"
		set inst_params [get_instance_parameters $instance]
		set props [get_inheritable_properties]
		send_message 1 $params
		foreach param $params {
			if { [lsearch $inst_params $param] != -1} {
				set param_type [get_parameter_property $param TYPE]
				send_message 1 "inheritting $param of type $param_type"
				foreach prop $props {
					if { [string equal $param_type "BOOLEAN"] != 1 || [string equal $prop "ALLOWED_RANGES"] != 1 } {
						set_parameter_property $param $prop [get_instance_parameter_property $instance $param $prop]
						send_message 1 "interitting $param $prop"
					}
				}
			}
		}
	}
}

proc get_inheritable_properties { } {
	return [list DEFAULT_VALUE ALLOWED_RANGES DISPLAY_NAME WIDTH VISIBLE ENABLED UNITS DISPLAY_HINT DESCRIPTION ]
}

proc inherit_parameter_values { params instance } {
	foreach param $params {
		set_instance_parameter_value $instance $param [get_parameter_value $param]
	}
}

proc add_pma_parameters_raw { } {
add_parameter tx_termination STRING OCT_100_OHMS
set_parameter_property tx_termination DEFAULT_VALUE OCT_100_OHMS
set_parameter_property tx_termination ALLOWED_RANGES {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS}
set_parameter_property tx_termination DESCRIPTION \
    "Indicates the value of the termination resistor for the transmitter"
set_parameter_property tx_termination DISPLAY_NAME \
    "Transmitter termination resistance"
set_parameter_property tx_termination UNITS None
set_parameter_property tx_termination DISPLAY_HINT ""
set_parameter_property tx_termination AFFECTS_GENERATION true
set_parameter_property tx_termination IS_HDL_PARAMETER true
add_display_item "Analog Options" tx_termination parameter 

add_parameter tx_vod_selection INTEGER 1
set_parameter_property tx_vod_selection DEFAULT_VALUE 1
set_parameter_property tx_vod_selection DESCRIPTION \
    "Sets VOD for the various TX buffers"
set_parameter_property tx_vod_selection DISPLAY_NAME \
    "Transmitter VOD control setting"
set_parameter_property tx_vod_selection UNITS None
set_parameter_property tx_vod_selection ALLOWED_RANGES 0:7
set_parameter_property tx_vod_selection AFFECTS_GENERATION true
set_parameter_property tx_vod_selection IS_HDL_PARAMETER true
add_display_item "Analog Options" tx_vod_selection parameter 

add_parameter tx_preemp_pretap INTEGER 0
set_parameter_property tx_preemp_pretap DEFAULT_VALUE 0
set_parameter_property tx_preemp_pretap DESCRIPTION \
    "Sets the amount of pre-emphasis on the TX buffer"
set_parameter_property tx_preemp_pretap DISPLAY_NAME \
    "Pre-emphasis pre-tap setting"
set_parameter_property tx_preemp_pretap UNITS None
set_parameter_property tx_preemp_pretap ALLOWED_RANGES 0:7
set_parameter_property tx_preemp_pretap AFFECTS_GENERATION true
set_parameter_property tx_preemp_pretap IS_HDL_PARAMETER true
add_display_item "Analog Options" tx_preemp_pretap parameter 

add_parameter tx_preemp_pretap_inv integer 0
set_parameter_property tx_preemp_pretap_inv DEFAULT_VALUE 0
set_parameter_property tx_preemp_pretap_inv ALLOWED_RANGES 0:1
set_parameter_property tx_preemp_pretap_inv DESCRIPTION \
    "Determines whether or not the pre-emphasis control signal for the pre-tap is inverted. If you turn this option on, the pre-emphasis control signal is inverted"
set_parameter_property tx_preemp_pretap_inv DISPLAY_NAME \
"Invert the pre-emphasis pre-tap polarity setting"
set_parameter_property tx_preemp_pretap_inv UNITS None
set_parameter_property tx_preemp_pretap_inv DISPLAY_HINT "Boolean"
set_parameter_property tx_preemp_pretap_inv AFFECTS_GENERATION true
set_parameter_property tx_preemp_pretap_inv IS_HDL_PARAMETER true
add_display_item "Analog Options" tx_preemp_pretap_inv parameter 

add_parameter tx_preemp_tap_1 INTEGER 5
set_parameter_property tx_preemp_tap_1 DEFAULT_VALUE 5
set_parameter_property tx_preemp_tap_1 DESCRIPTION \
     "Sets the amount of pre-emphasis for the 1st post-tap"
set_parameter_property tx_preemp_tap_1 DISPLAY_NAME \
     "Pre-emphasis first post-tap setting"
set_parameter_property tx_preemp_tap_1 UNITS None
set_parameter_property tx_preemp_tap_1 ALLOWED_RANGES 0:30
set_parameter_property tx_preemp_tap_1 AFFECTS_GENERATION true
set_parameter_property tx_preemp_tap_1 IS_HDL_PARAMETER true
add_display_item "Analog Options" tx_preemp_tap_1 parameter 

add_parameter tx_preemp_tap_2 INTEGER 0
set_parameter_property tx_preemp_tap_2 DEFAULT_VALUE 0
set_parameter_property tx_preemp_tap_2 DESCRIPTION \
    "Sets the amount of pre-emphasis for the 2nd post-tap"
set_parameter_property tx_preemp_tap_2 DISPLAY_NAME \
    "Pre-emphasis second post-tap setting"
set_parameter_property tx_preemp_tap_2 UNITS None
set_parameter_property tx_preemp_tap_2 ALLOWED_RANGES 0:7
set_parameter_property tx_preemp_tap_2 AFFECTS_GENERATION true
set_parameter_property tx_preemp_tap_2 IS_HDL_PARAMETER true
add_display_item "Analog Options" tx_preemp_tap_2 parameter 

add_parameter tx_preemp_tap_2_inv integer 0
set_parameter_property tx_preemp_tap_2_inv DEFAULT_VALUE 0
set_parameter_property tx_preemp_tap_2_inv ALLOWED_RANGES 0:1
  set_parameter_property tx_preemp_tap_2_inv DESCRIPTION \
    "Determines whether or not the pre-emphasis control signal for the second post-tap is inverted. If you turn this option on, the pre-emphasis control signa is inverted"
  set_parameter_property tx_preemp_tap_2_inv DISPLAY_NAME \
"Invert the second post-tap polarity setting"
set_parameter_property tx_preemp_tap_2_inv UNITS None
set_parameter_property tx_preemp_tap_2_inv AFFECTS_GENERATION true
set_parameter_property tx_preemp_tap_2_inv IS_HDL_PARAMETER true
set_parameter_property tx_preemp_tap_2_inv DISPLAY_HINT "Boolean"
add_display_item "Analog Options" tx_preemp_tap_2_inv parameter 

add_parameter rx_common_mode STRING 0.82v
set_parameter_property rx_common_mode DEFAULT_VALUE 0.82v
  set_parameter_property rx_common_mode DESCRIPTION \
    "Specifes the RX common mode voltage"
  set_parameter_property rx_common_mode DISPLAY_NAME \
    "Receiver common mode voltage"
set_parameter_property rx_common_mode ALLOWED_RANGES {Tri-state 0.82v 1.1v}
set_parameter_property rx_common_mode UNITS None
set_parameter_property rx_common_mode AFFECTS_GENERATION true
set_parameter_property rx_common_mode IS_HDL_PARAMETER true
add_display_item "Analog Options" rx_common_mode parameter 


add_parameter rx_termination STRING OCT_100_OHMS
set_parameter_property rx_termination DEFAULT_VALUE OCT_100_OHMS
  set_parameter_property rx_termination DESCRIPTION \
    "Indicates the value of the termination resistor for the receiver"
  set_parameter_property rx_termination DISPLAY_NAME \
    "Receiver termination resistance"
set_parameter_property rx_termination ALLOWED_RANGES {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS}
set_parameter_property rx_termination UNITS None
set_parameter_property rx_termination AFFECTS_GENERATION true
set_parameter_property rx_termination IS_HDL_PARAMETER true
add_display_item "Analog Options" rx_termination parameter 

add_parameter rx_eq_dc_gain INTEGER 0
set_parameter_property rx_eq_dc_gain DEFAULT_VALUE 0
  set_parameter_property rx_eq_dc_gain DESCRIPTION \
    "Sets the equalization DC gain using one of the following settings"
  set_parameter_property rx_eq_dc_gain DISPLAY_NAME \
    "Receiver DC gain"
set_parameter_property rx_eq_dc_gain UNITS None
set_parameter_property rx_eq_dc_gain ALLOWED_RANGES 0:4
set_parameter_property rx_eq_dc_gain AFFECTS_GENERATION true
set_parameter_property rx_eq_dc_gain IS_HDL_PARAMETER true
add_display_item "Analog Options" rx_eq_dc_gain parameter 

add_parameter rx_eq_ctrl INTEGER 14
set_parameter_property rx_eq_ctrl DEFAULT_VALUE 14
  set_parameter_property rx_eq_ctrl DESCRIPTION \
    "This option sets the equalizer control settings. The equalizer uses a pass band filter. Specifying a low value passes low frequencies. Specifying a high value passes high frequencies"
  set_parameter_property rx_eq_ctrl DISPLAY_NAME \
    "Receiver static equalizer setting"
set_parameter_property rx_eq_ctrl UNITS None
set_parameter_property rx_eq_ctrl ALLOWED_RANGES 0:16
set_parameter_property rx_eq_ctrl AFFECTS_GENERATION true
set_parameter_property rx_eq_ctrl IS_HDL_PARAMETER true
add_display_item "Analog Options" rx_eq_ctrl parameter 
}
