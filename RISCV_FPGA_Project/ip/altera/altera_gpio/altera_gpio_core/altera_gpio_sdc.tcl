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


package require altera_gpio::common

proc generate_sdc_header {half_rate} {
	set sdc_content ""

	append sdc_content "#**************************************************************\n"
	append sdc_content "# Time Information\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "\n"
	append sdc_content "set_time_format -unit ns -decimal_places 3\n"
	append sdc_content "\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "# Timing Variables\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "\n"
	append sdc_content "# Clock period\n"
	set tck_fr 10.0
	set tck_hr [expr 2 * $tck_fr]
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		append sdc_content "set tck_fr $tck_fr \n"
		append sdc_content "set tck_hr $tck_hr \n"
	} else {
		append sdc_content "set tck $tck_fr \n"
	}
	append sdc_content "\n"
	append sdc_content "# Setup/hold requirement at the input\n"
	append sdc_content "set delay_in 1.0\n"
	append sdc_content "\n"
	append sdc_content "# Setup/hold requirement at the output\n"
	append sdc_content "set delay_out 1.0\n"
	append sdc_content "\n"

	return $sdc_content
}

proc generate_sdc_clock {half_rate sep_io_clks} {
	set sdc_content ""

	append sdc_content "# Clock name\n"
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			append sdc_content "set ck_name_fr_in \"ck_fr_in\"\n"
			append sdc_content "set ck_name_hr_in \"ck_hr_in\"\n"
			append sdc_content "set ck_name_fr_out \"ck_fr_out\"\n"
			append sdc_content "set ck_name_hr_out \"ck_hr_out\"\n"
		} else {
			append sdc_content "set ck_name_fr \"ck_fr\"\n"
			append sdc_content "set ck_name_hr \"ck_hr\"\n"
		}
	} else {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			append sdc_content "set ck_name_in \"ck_in\"\n"
			append sdc_content "set ck_name_out \"ck_out\"\n"
		} else {
			append sdc_content "set ck_name \"ck\"\n"
		}
	}
	append sdc_content "\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "# Create Clock\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "\n"
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			append sdc_content "create_clock -name \$ck_name_fr_in -period \$tck_fr \[get_ports {dut_core_ck_fr_in_export}\]\n"
			append sdc_content "create_clock -name \$ck_name_hr_in -period \$tck_hr \[get_ports {dut_core_ck_hr_in_export}\]\n"
			append sdc_content "create_clock -name \$ck_name_fr_out -period \$tck_fr \[get_ports {dut_core_ck_fr_out_export}\]\n"
			append sdc_content "create_clock -name \$ck_name_hr_out -period \$tck_hr \[get_ports {dut_core_ck_hr_out_export}\]\n"
		} else {
			append sdc_content "create_clock -name \$ck_name_fr -period \$tck_fr \[get_ports {dut_core_ck_fr_export}\]\n"
			append sdc_content "create_clock -name \$ck_name_hr -period \$tck_hr \[get_ports {dut_core_ck_hr_export}\]\n"
		}
	} else {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			append sdc_content "create_clock -name \$ck_name_in -period \$tck \[get_ports {dut_core_ck_in_export}\]\n"
			append sdc_content "create_clock -name \$ck_name_out -period \$tck \[get_ports {dut_core_ck_out_export}\]\n"
		} else {
			append sdc_content "create_clock -name \$ck_name -period \$tck \[get_ports {dut_core_ck_export}\]\n"
		}
	}
	append sdc_content "\n"

	return $sdc_content
}

proc generate_sdc_output_constraints {core_data_size core_oe_size half_rate sep_io_clks} {
	set sdc_content ""

	set ck_name ""
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			set ck_name "\$ck_name_hr_out"
		} else {
			set ck_name "\$ck_name_hr"
		}
	} else {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			set ck_name "\$ck_name_out"
		} else {
			set ck_name "\$ck_name"
		}
	}
	append sdc_content "#**************************************************************\n"
	append sdc_content "# Paths from core to I/Os\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "\n"
	if { $core_data_size > 1 } {
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_in \[get_ports {dut_core_din_export\[*\]}\]\n"
	} else {
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_in \[get_ports {dut_core_din_export}\]\n"
	}
	if { $core_oe_size > 1 } {
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_in \[get_ports {dut_core_oe_export\[*\]}\]\n"
	} else {
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_in \[get_ports {dut_core_oe_export}\]\n"
	}
	append sdc_content "\n"

	return $sdc_content
}

proc generate_sdc_input_constraints {core_data_size half_rate sep_io_clks} {
	set sdc_content ""

	set ck_name ""
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			set ck_name "\$ck_name_hr_in"
		} else {
			set ck_name "\$ck_name_hr"
		}
	} else {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			set ck_name "\$ck_name_in"
		} else {
			set ck_name "\$ck_name"
		}
	}
	append sdc_content "#**************************************************************\n"
	append sdc_content "# Paths from I/Os to the core\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "\n"
	if { $core_data_size > 1 } {
		append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_out \[get_ports {dut_core_dout_export\[*\]}\]\n"
	} else {
		append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_out \[get_ports {dut_core_dout_export}\]\n"
	}
	append sdc_content "\n"

	return $sdc_content
}

proc generate_sdc_pad_constraints_output_type {diff_buff data_size half_rate} {
	set sdc_content ""

	set ck_name ""
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		set ck_name "\$ck_name_fr"
	} else {
		set ck_name "\$ck_name"
	}
	if { $data_size > 1 } {
		append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_out \[get_ports {dut_core_pad_out_export\[*\]}\]\n"
	} else {
		append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_out \[get_ports {dut_core_pad_out_export}\]\n"
	}

	if {[::altera_gpio::common::safe_string_compare $diff_buff "true"]} {
		if { $data_size > 1 } {
			append sdc_content "set_output_delay -add_delay -clock \[get_clocks \$ck_name\] \$delay_out \[get_ports {dut_core_pad_out_b_export\[*\]}\]\n"
		} else {
			append sdc_content "set_output_delay -add_delay -clock \[get_clocks \$ck_name\] \$delay_out \[get_ports {dut_core_pad_out_b_export}\]\n"
		}
	}

	return $sdc_content
}

proc generate_sdc_pad_constraints_input_type {diff_buff data_size half_rate} {
	set sdc_content ""

	set ck_name ""
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		set ck_name "\$ck_name_fr"
	} else {
		set ck_name "\$ck_name"
	}
	if { $data_size > 1 } {
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_in \[get_ports {dut_core_pad_in_export\[*\]}\]\n"
	} else {
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name\] \$delay_in \[get_ports {dut_core_pad_in_export}\]\n"
	}

	if {[::altera_gpio::common::safe_string_compare $diff_buff "true"]} {
		if { $data_size > 1 } {
			append sdc_content "set_input_delay -add_delay -clock \[get_clocks \$ck_name\] \$delay_in \[get_ports {dut_core_pad_in_b_export\[*\]}\]\n"
		} else {
			append sdc_content "set_input_delay -add_delay -clock \[get_clocks \$ck_name\] \$delay_in \[get_ports {dut_core_pad_in_b_export}\]\n"
		}
	}

	return $sdc_content
}

proc generate_sdc_pad_constraints_bidir_type {diff_buff data_size half_rate sep_io_clks} {
	set sdc_content ""

	set ck_name_in ""
	set ck_name_out ""
	if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			set ck_name_in "\$ck_name_fr_in"
			set ck_name_out "\$ck_name_fr_out"
		} else {
			set ck_name_in "\$ck_name_fr"
			set ck_name_out "\$ck_name_fr"
		}
	} else {
		if {[::altera_gpio::common::safe_string_compare $sep_io_clks "true"]} {
			set ck_name_in "\$ck_name_in"
			set ck_name_out "\$ck_name_out"
		} else {
			set ck_name_in "\$ck_name"
			set ck_name_out "\$ck_name"
		}
	}
	if { $data_size > 1 } {
		append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name_out\] \$delay_out \[get_ports {dut_core_pad_io_export\[*\]}\]\n"
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name_in\] \$delay_in \[get_ports {dut_core_pad_io_export\[*\]}\]\n"
	} else {
		append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name_out\] \$delay_out \[get_ports {dut_core_pad_io_export}\]\n"
		append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name_in\] \$delay_in \[get_ports {dut_core_pad_io_export}\]\n"
	}

	if {[::altera_gpio::common::safe_string_compare $diff_buff "true"]} {
		if { $data_size > 1 } {
			append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name_out\] \$delay_out \[get_ports {dut_core_pad_io_b_export\[*\]}\]\n"
			append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name_in\] \$delay_in \[get_ports {dut_core_pad_io_b_export\[*\]}\]\n"
		} else {
			append sdc_content "set_output_delay -add_delay -clock \[get_clocks $ck_name_out\] \$delay_out \[get_ports {dut_core_pad_io_b_export}\]\n"
			append sdc_content "set_input_delay -add_delay -clock \[get_clocks $ck_name_in\] \$delay_in \[get_ports {dut_core_pad_io_b_export}\]\n"
		}
	}

	return $sdc_content
}

proc generate_sdc_pad_constraints {pin_type diff_buff data_size half_rate sep_io_clks} {
	set sdc_content ""

	append sdc_content "#**************************************************************\n"
	append sdc_content "# Pads Constraints\n"
	append sdc_content "#**************************************************************\n"
	append sdc_content "\n"
	if { [::altera_gpio::common::safe_string_compare $pin_type "output"] } {
		append sdc_content [generate_sdc_pad_constraints_output_type $diff_buff $data_size $half_rate]

	} elseif { [::altera_gpio::common::safe_string_compare $pin_type "input"] } {
		append sdc_content [generate_sdc_pad_constraints_input_type $diff_buff $data_size $half_rate]

	} else {
		append sdc_content [generate_sdc_pad_constraints_bidir_type $diff_buff $data_size $half_rate $sep_io_clks]
	}

	return $sdc_content
}

proc generate_sdc_file {} {
	set pin_type [get_parameter_value PIN_TYPE]
    set data_size [get_parameter_value SIZE]
    set io_reg_mode [get_parameter_value REGISTER_MODE]
    set half_rate [get_parameter_value HALF_RATE]
	set diff_buff [get_parameter_value gui_diff_buff]
	set sep_io_clks [get_parameter_value gui_separate_io_clks]
	
	set core_data_size 0
	set core_oe_size 0
	if {[::altera_gpio::common::safe_string_compare $io_reg_mode "ddr"]} {
		if {[::altera_gpio::common::safe_string_compare $half_rate "true"]} {
			set core_data_size [expr $data_size * 4]
			set core_oe_size [expr $data_size * 2]
		} else {
			set core_data_size [expr $data_size * 2]
			set core_oe_size $data_size
		}
	} else {
		set core_data_size $data_size
		set core_oe_size $data_size
	}

	
	set sdc_content ""

	append sdc_content "# This is an automatically generated SDC file\n"
	append sdc_content "\n"
	if {[::altera_gpio::common::safe_string_compare $io_reg_mode "none"]} {
		append sdc_content "# This configuration of altera_gpio is purely combinational\n"
		append sdc_content "# No timing constraints is provided\n"
	} else {
		append sdc_content [generate_sdc_header $half_rate]

		append sdc_content [generate_sdc_clock $half_rate $sep_io_clks]

		if { [::altera_gpio::common::safe_string_compare $pin_type "output"] || [::altera_gpio::common::safe_string_compare $pin_type "bidir"]} {
			append sdc_content [generate_sdc_output_constraints $core_data_size $core_oe_size $half_rate $sep_io_clks]
		}
	
		if { [::altera_gpio::common::safe_string_compare $pin_type "input"] || [::altera_gpio::common::safe_string_compare $pin_type "bidir"]} {
			append sdc_content [generate_sdc_input_constraints $core_data_size $half_rate $sep_io_clks]
		}

		append sdc_content [generate_sdc_pad_constraints $pin_type $diff_buff $data_size $half_rate $sep_io_clks]
	}

	return $sdc_content
}
