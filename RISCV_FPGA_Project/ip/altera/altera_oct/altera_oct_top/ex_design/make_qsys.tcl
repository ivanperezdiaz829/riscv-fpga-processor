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



create_system
set_project_property DEVICE_FAMILY $device_family


set core_name dut
set driver_name driver

add_instance $core_name altera_oct

foreach param_name [array names ip_params] {
	set param_val $ip_params($param_name)

	set_instance_parameter_value $core_name $param_name $param_val
}

foreach interface_name [get_instance_interfaces $core_name] {
	add_interface ${core_name}_${interface_name} conduit end
	set_interface_property ${core_name}_${interface_name} EXPORT_OF ${core_name}.${interface_name}
}

add_instance mybuffer altera_gpio

set_instance_parameter_value mybuffer PIN_TYPE "output"
set_instance_parameter_value mybuffer gui_io_reg_mode "none"
set_instance_parameter_value mybuffer gui_hr_logic "false"
set_instance_parameter_value mybuffer gui_diff_buff "false"
set_instance_parameter_value mybuffer gui_separate_io_clks "false"
set_instance_parameter_value mybuffer SIZE 1
set_instance_parameter_value mybuffer gui_enable_termination_ports "true"

add_interface ex_din conduit end
set_interface_property ex_din EXPORT_OF mybuffer.core_din
add_interface ex_pad conduit end
set_interface_property ex_pad EXPORT_OF mybuffer.core_pad_out

remove_interface ${core_name}_core_series_termination_control
add_connection ${core_name}.core_series_termination_control/mybuffer.core_seriesterminationcontrol
remove_interface ${core_name}_core_parallel_termination_control
add_connection ${core_name}.core_parallel_termination_control/mybuffer.core_parallelterminationcontrol

save_system $ed_params(TMP_SYNTH_QSYS_PATH)


add_instance $driver_name altera_oct_driver

save_system $ed_params(TMP_SIM_QSYS_PATH)


