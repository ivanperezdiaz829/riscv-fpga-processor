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


package require -exact qsys 13.1

proc string_compare {string_1 string_2} {
    return [expr {[string compare -nocase $string_1 $string_2] == 0}] 
}

proc param_string_compare {param str} {
	upvar ip_params ip_params
	return [string_compare $ip_params($param) $str]
}

proc interface_exists_on_instance {interface_name instance} {
	set interface_list [get_instance_interfaces $instance]
	return [expr [lsearch $interface_list $interface_name] != -1]
}

if {! [info exists ip_params] || ! [info exists ed_params]} {
   source "params.tcl"
}

set lvds_if    [list $ed_params(ALTERA_LVDS_NAME)]

create_system
set_project_property DEVICE_FAMILY $device_family


set core_name $lvds_if
set driver_name driver

add_instance $core_name altera_lvds

foreach param_name [array names ip_params] { 
	set_instance_parameter_value $core_name $param_name $ip_params($param_name)
}

foreach interface_name [get_instance_interfaces $core_name] {
	set exported_interface_name ${core_name}_$interface_name
	add_interface $exported_interface_name conduit end
	set_interface_property $exported_interface_name EXPORT_OF "${core_name}.${interface_name}"
}
save_system $ed_params(TMP_SYNTH_QSYS_PATH)

add_instance $driver_name altera_lvds_driver

foreach param_name [get_instance_parameters $driver_name] { 
	set_instance_parameter_value $driver_name $param_name $ip_params($param_name)
}

foreach interface_name [get_instance_interfaces $core_name] {
	remove_interface ${core_name}_${interface_name}
}


add_connection $driver_name.refclk/$core_name.inclock
if {[param_string_compare PLL_USE_RESET "true"]} {
	add_connection $core_name.pll_areset/$driver_name.pll_areset
}

set mode $ip_params(MODE)
if {[string_compare $mode "TX"]} {
	add_connection $core_name.tx_in/$driver_name.par_in
	add_connection $core_name.tx_out/$driver_name.lvdsout
	if { [param_string_compare TX_USE_OUTCLOCK "true"] } {
        add_connection $driver_name.tx_outclock/$core_name.tx_outclock
    }
} else {
	add_connection $core_name.rx_in/$driver_name.lvdsin
	add_connection $core_name.rx_out/$driver_name.par_out
	
	set use_bitslip [param_string_compare RX_USE_BITSLIP "true"]
	
	if { $use_bitslip } {
		add_connection $core_name.rx_bitslip_ctrl/$driver_name.bslipcntl
    }
	
	if { $use_bitslip && [param_string_compare RX_BITSLIP_ASSERT_MAX "true"] } {
        add_connection $core_name.rx_bitslip_max/$driver_name.bslipmax
    }
	
	if { [param_string_compare RX_BITSLIP_USE_RESET "true"] && $use_bitslip } {
        add_connection $core_name.rx_bitslip_reset/$driver_name.bsliprst
    }
	if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"]} {   
		add_connection $core_name.rx_dpa_reset/$driver_name.dparst
		add_connection $core_name.rx_dpa_locked/$driver_name.lock
	}
	if {[string_compare $mode "RX_Soft-CDR"]} {  
		add_connection $core_name.rx_divfwdclk/$driver_name.pclk
	} else {
		add_connection $core_name.rx_coreclock/$driver_name.coreclock
	}
}

if {[param_string_compare PLL_EXPORT_LOCK "true"] 
	&& [param_string_compare USE_EXTERNAL_PLL "false"] 
	&& [param_string_compare USE_CLOCK_PIN "false"] } {
	
	add_connection $core_name.pll_locked/$driver_name.pll_locked
}


save_system $ed_params(TMP_SIM_QSYS_PATH)


