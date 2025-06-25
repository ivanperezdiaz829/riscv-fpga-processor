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





source ../../altera/sopc_builder_ip/altera_avalon_mega_common/ipcc_wrap_split.tcl

proc safe_string_compare { string_1 string_2 } {
	set ret_val [expr {[string compare -nocase $string_1 $string_2] == 0}]
	return $ret_val
}

proc set_clock_interface {} {
	set data_dir [get_parameter_value PIN_TYPE]
	set io_reg_mode [get_parameter_value REGISTER_MODE]
	set clock_enable [get_parameter_value gui_clock_enable]
	set use_advanced_ddr_features [get_parameter_value gui_use_advanced_ddr_features]
	set data_size [get_parameter_value SIZE]

	add_interface inclock conduit end
	add_interface_port inclock inclock export Input 1
	set_interface_property inclock ENABLED false
		
	add_interface inclocken conduit end
	add_interface_port inclocken inclocken export Input 1
	set_interface_property inclocken ENABLED false

	add_interface fr_clock conduit end
	add_interface_port fr_clock fr_clock export Output $data_size
	set_interface_property fr_clock ENABLED false
	set_port_property fr_clock VHDL_TYPE STD_LOGIC_VECTOR

	add_interface hr_clock conduit end
	add_interface_port hr_clock hr_clock export Output 1
	set_interface_property hr_clock ENABLED false

	add_interface invert_hr_clock conduit end
	add_interface_port invert_hr_clock invert_hr_clock export Input 1
	set_interface_property invert_hr_clock ENABLED false

	add_interface clkdiv_sclr conduit end
	add_interface_port clkdiv_sclr clkdiv_sclr export Input 1
	set_interface_property clkdiv_sclr ENABLED false

	add_interface outclock conduit end
	set_interface_property outclock ENABLED false
	add_interface_port outclock outclock export Input 1
		
	add_interface outclocken conduit end
	set_interface_property outclocken ENABLED false
	add_interface_port outclocken outclocken export Input 1

	add_interface phy_mem_clock conduit end
	set_interface_property phy_mem_clock ENABLED false
	add_interface_port phy_mem_clock phy_mem_clock export Input 1

	if {[safe_string_compare $data_dir input] || [safe_string_compare $data_dir bidir]} {
		if {![safe_string_compare $io_reg_mode bypass]} {
			set_interface_property inclock ENABLED true
		}	

		if {[safe_string_compare $io_reg_mode ddr]} {
			if {[safe_string_compare $clock_enable true]} {
				set_interface_property inclocken ENABLED true
			} else {
				set_port_property inclocken TERMINATION true
				set_port_property inclocken TERMINATION_VALUE 1
			}
		}

		if {[ safe_string_compare $use_advanced_ddr_features true] && [safe_string_compare $io_reg_mode ddr]} {
			set_interface_property fr_clock ENABLED true
			set_interface_property hr_clock ENABLED true
			set_interface_property invert_hr_clock ENABLED true
			set_interface_property clkdiv_sclr ENABLED true
		}
	}
	
	if {[safe_string_compare $data_dir output] || [safe_string_compare $data_dir bidir]} {
		if {![safe_string_compare $io_reg_mode bypass]} {
			set_interface_property outclock ENABLED true
		}
				
		if {[safe_string_compare $io_reg_mode ddr]} {
			if {[safe_string_compare $clock_enable true]} {
				set_interface_property outclocken ENABLED true
			} else {
				set_port_property outclocken TERMINATION true
				set_port_property outclocken TERMINATION_VALUE 1
			}
		}

		if {[ safe_string_compare $use_advanced_ddr_features true] && [safe_string_compare $io_reg_mode ddr]} {
			set_interface_property phy_mem_clock ENABLED true
		}
	}	
}

proc set_pad_interface {} {
	set data_size [get_parameter_value SIZE]
	set data_dir [get_parameter_value PIN_TYPE]
	set pseudo_diff_buf [get_parameter_value gui_pseudo_diff_buf]
	set true_diff_buf [get_parameter_value gui_true_diff_buf]
	
	add_interface pad_io conduit end
	set_interface_property pad_io ENABLED false
	add_interface_port pad_io pad_io export Bidir $data_size
	set_port_property pad_io VHDL_TYPE STD_LOGIC_VECTOR
	
	add_interface pad_io_b conduit end
	set_interface_property pad_io_b ENABLED false
	add_interface_port pad_io_b pad_io_b export Bidir $data_size
	set_port_property pad_io_b VHDL_TYPE STD_LOGIC_VECTOR

	add_interface pad_in conduit end
	set_interface_property pad_in ENABLED false
	add_interface_port pad_in pad_in export Input $data_size
	set_port_property pad_in VHDL_TYPE STD_LOGIC_VECTOR
	
	add_interface pad_in_b conduit end
	set_interface_property pad_in_b ENABLED false
	add_interface_port pad_in_b pad_in_b export Input $data_size
	set_port_property pad_in_b VHDL_TYPE STD_LOGIC_VECTOR
	
	add_interface pad_out conduit end
	set_interface_property pad_out ENABLED false
	add_interface_port pad_out pad_out export Output $data_size
	set_port_property pad_out VHDL_TYPE STD_LOGIC_VECTOR
	
	add_interface pad_out_b conduit end
	set_interface_property pad_out_b ENABLED false
	add_interface_port pad_out_b pad_out_b export Output $data_size
	set_port_property pad_out_b VHDL_TYPE STD_LOGIC_VECTOR
	
	if {$data_dir == "input"} {	    
		set_interface_property pad_in ENABLED true
		if {[safe_string_compare $true_diff_buf true] || [safe_string_compare $pseudo_diff_buf true]} {    	
		    set_interface_property pad_in_b ENABLED true
		}		
	} elseif {$data_dir == "output"} {
		set_interface_property pad_out ENABLED true
		if {[safe_string_compare $true_diff_buf true] || [safe_string_compare $pseudo_diff_buf true]} {    	
		    	set_interface_property pad_out_b ENABLED true
		} 
	} else {
	    set_interface_property pad_io ENABLED true
		if {[safe_string_compare $true_diff_buf true] || [safe_string_compare $pseudo_diff_buf true]} {    	
		    	set_interface_property pad_io_b ENABLED true
		} 
	}
}

proc set_data_interface {} {
	set io_reg_mode [get_parameter_value REGISTER_MODE]
	set data_size [get_parameter_value SIZE]
	set data_dir [get_parameter_value PIN_TYPE]

	add_interface dout conduit end
    	set_interface_property dout ENABLED false
	if {[safe_string_compare $io_reg_mode ddr]} {
		add_interface_port dout dout export Output [expr $data_size * 2]
	} else {
    		add_interface_port dout dout export Output $data_size
	}
	set_port_property dout VHDL_TYPE STD_LOGIC_VECTOR
	
	add_interface din conduit end
    	set_interface_property din ENABLED false
	if {[safe_string_compare $io_reg_mode ddr]} {
	   	add_interface_port din din export Input [expr $data_size * 2]
	} else {
	    	add_interface_port din din export Input $data_size
	}
	set_port_property din VHDL_TYPE STD_LOGIC_VECTOR


	if {[safe_string_compare $data_dir input] || [safe_string_compare $data_dir bidir]} {
	    	set_interface_property dout ENABLED true
	}

	if {[safe_string_compare $data_dir output] || [safe_string_compare $data_dir bidir]} {
	    	set_interface_property din ENABLED true
	}
}

proc set_async_mode_interface {} {
	set aclr_aset_port_setting [get_parameter_value gui_aclr_aset_port_setting]
	set io_reg_mode [get_parameter_value gui_io_reg_mode]

	add_interface aset conduit end
	add_interface_port aset aset export Input 1
	set_interface_property aset ENABLED false

	add_interface aclr conduit end
	add_interface_port aclr aclr export Input 1
	set_interface_property aclr ENABLED false

	
	if {$aclr_aset_port_setting == "Enable aset port" && $io_reg_mode == "ddr"} {
	    set_interface_property aset ENABLED true
	}
	
	if {$aclr_aset_port_setting == "Enable aclr port" && $io_reg_mode == "ddr"} {
	    set_interface_property aclr ENABLED true
	}
}

proc set_enable_buffer_interface {} {
	set data_size [get_parameter_value SIZE]
	set data_dir [get_parameter_value PIN_TYPE]
	set io_reg_mode [get_parameter_value gui_io_reg_mode]
	
	
	add_interface oe conduit end
	add_interface_port oe oe export Input $data_size
	set_interface_property oe ENABLED false
	set_port_property oe VHDL_TYPE STD_LOGIC_VECTOR
	
	if { [safe_string_compare $data_dir bidir] } {
		set_interface_property oe ENABLED true
	}

}

proc ip_elaborate {} {

	set_clock_interface
	set_data_interface
	set_pad_interface
	set_async_mode_interface
	set_enable_buffer_interface
}


proc ip_validate {} {
    
    set data_dir [get_parameter_value PIN_TYPE]
    set io_reg_mode [get_parameter_value gui_io_reg_mode]
	set pseudo_diff_buf [get_parameter_value gui_pseudo_diff_buf]
	set true_diff_buf [get_parameter_value gui_true_diff_buf]
	set aclr_aset_port_setting [get_parameter_value gui_aclr_aset_port_setting]
	set bus_hold [get_parameter_value gui_bus_hold]
	set invert_output [get_parameter_value gui_invert_output]
	set invert_input_clock [get_parameter_value gui_invert_input_clock]
	set use_register_to_drive_obuf_oe [get_parameter_value gui_use_register_to_drive_obuf_oe]
	set use_ddio_reg_to_drive_oe [get_parameter_value gui_use_ddio_reg_to_drive_oe]
	set open_drain_output [get_parameter_value gui_open_drain]
	set use_advanced_ddr_features [get_parameter_value gui_use_advanced_ddr_features]
	set invert_clkdiv_input_clock [ get_parameter_value gui_invert_clkdiv_input_clock]

    if [get_quartus_ini "ip_altgpio_zb_use_advanced_ddr_features"] {
		set_parameter_property gui_use_advanced_ddr_features VISIBLE true
		set_parameter_property gui_invert_clkdiv_input_clock VISIBLE true
		
		if {$io_reg_mode == "ddr"} {
	   		set_parameter_property gui_use_advanced_ddr_features ENABLED true
	   		if {$data_dir == "input" || $data_dir == "bidir"} {
	   			set_parameter_property gui_invert_clkdiv_input_clock ENABLED true
	   		} else {
	   			set_parameter_property gui_invert_clkdiv_input_clock ENABLED false
	   		}
		} else {
		    set_parameter_property gui_use_advanced_ddr_features ENABLED false
			set_parameter_property gui_invert_clkdiv_input_clock ENABLED false
		   	
			set use_advanced_ddr_features false
			set invert_clkdiv_input_clock false
		}
    }

	if {[safe_string_compare $use_advanced_ddr_features true]} {
		set_parameter_value USE_ADVANCED_DDR_FEATURES "true"
	} else {
		set_parameter_value USE_ADVANCED_DDR_FEATURES "false"
	}

	if {[safe_string_compare $invert_clkdiv_input_clock true]} {
		set_parameter_value INVERT_CLKDIV_INPUT_CLOCK "true"
	} else {
		set_parameter_value INVERT_CLKDIV_INPUT_CLOCK "false"
	}

    if {($data_dir == "input")} {
		set_parameter_property gui_true_diff_buf ENABLED true
		set_parameter_property gui_pseudo_diff_buf ENABLED false
		if {[safe_string_compare $true_diff_buf true]} {
			set_parameter_value BUFFER_TYPE "true_differential"
		} else {
			set_parameter_value BUFFER_TYPE "single-ended"
		}
  	} elseif { $data_dir == "output" } {
		set_parameter_property gui_true_diff_buf ENABLED true
		set_parameter_property gui_pseudo_diff_buf ENABLED true
		
		if {[safe_string_compare $true_diff_buf true]} {
			set_parameter_value BUFFER_TYPE "true_differential"
			set_parameter_property gui_pseudo_diff_buf ENABLED false
		} elseif {[safe_string_compare $pseudo_diff_buf true]} {
			set_parameter_value BUFFER_TYPE "pseudo_differential"
			set_parameter_property gui_true_diff_buf ENABLED false
		} else {
			set_parameter_value BUFFER_TYPE "single-ended"
		}
	} else {
		set_parameter_property gui_true_diff_buf ENABLED false
		set_parameter_property gui_pseudo_diff_buf ENABLED false
		set_parameter_value BUFFER_TYPE "single-ended"
	}
	
	if {[safe_string_compare $bus_hold true]} {
		set_parameter_value BUS_HOLD "true"
	} else {
		set_parameter_value BUS_HOLD "false"
	}
		
	
	if {$io_reg_mode == "ddr"} {
		set_parameter_value REGISTER_MODE "ddr"
    } elseif {$io_reg_mode == "single-register"} {
		set_parameter_value REGISTER_MODE "single-register"
    } else {
		set_parameter_value REGISTER_MODE "bypass"
    }
	
	if {$io_reg_mode == "bypass" || $io_reg_mode == "single-register"} {
		set_parameter_property gui_clock_enable ENABLED false		
		set_parameter_property gui_aclr_aset_port_setting ENABLED false	
	} elseif { $io_reg_mode == "ddr" } {
	
		set_parameter_property gui_clock_enable ENABLED true
		set_parameter_property gui_aclr_aset_port_setting ENABLED true
		
		if { $aclr_aset_port_setting == "Enable aset port" } {
			set_parameter_value ASYNC_MODE "preset"
			set_parameter_value SET_REGISTER_OUTPUTS_HIGH "false"
		} elseif { $aclr_aset_port_setting == "Enable aclr port" } {
			set_parameter_value ASYNC_MODE "clear"
			set_parameter_value SET_REGISTER_OUTPUTS_HIGH "false"
		} elseif { $aclr_aset_port_setting == "Set registers to power up high (when aclr and aset ports are not used)" } {
			set_parameter_value ASYNC_MODE "none"
			set_parameter_value SET_REGISTER_OUTPUTS_HIGH "true"
		} elseif { $aclr_aset_port_setting == "None" } {
			set_parameter_value ASYNC_MODE  "none"
			set_parameter_value SET_REGISTER_OUTPUTS_HIGH "false"
		}
	}
		
	
	if {$io_reg_mode == "ddr" && ($data_dir == "output") } {
		set_parameter_property gui_invert_output ENABLED true
		if {[safe_string_compare $invert_output true]} {
			set_parameter_value INVERT_OUTPUT "true"
		} else {
			set_parameter_value INVERT_OUTPUT "false"
		}
	} else {
		set_parameter_property gui_invert_output ENABLED false
		set_parameter_value INVERT_OUTPUT "false"
	}
	
	if {$io_reg_mode == "ddr" && ($data_dir == "input")} {
		set_parameter_property gui_invert_input_clock ENABLED true
		if {[safe_string_compare $invert_input_clock true]} {
			set_parameter_value INVERT_INPUT_CLOCK "true"
		} else {
			set_parameter_value INVERT_INPUT_CLOCK "false"
		}
	} else {
		set_parameter_property gui_invert_input_clock ENABLED false
		set_parameter_value INVERT_INPUT_CLOCK "false"
	}
	
	if {($io_reg_mode != "bypass" ) && (($data_dir == "output") ||($data_dir == "bidir"))} {
	
		if {$io_reg_mode == "single-register" } {
			set_parameter_property gui_use_register_to_drive_obuf_oe ENABLED true
			set_parameter_property gui_use_ddio_reg_to_drive_oe ENABLED false
			set_parameter_value USE_DDIO_REG_TO_DRIVE_OE "false"
			if {[safe_string_compare $use_register_to_drive_obuf_oe true]} {
				set_parameter_value USE_ONE_REG_TO_DRIVE_OE "true"
			} else {
				set_parameter_value USE_ONE_REG_TO_DRIVE_OE "false"
			}
		} else {
			if {[safe_string_compare $use_register_to_drive_obuf_oe true]} {
				set_parameter_value USE_ONE_REG_TO_DRIVE_OE "true"
				set_parameter_value USE_DDIO_REG_TO_DRIVE_OE "false"
				set_parameter_property gui_use_register_to_drive_obuf_oe ENABLED true
				set_parameter_property gui_use_ddio_reg_to_drive_oe ENABLED false
			} elseif {[safe_string_compare $use_ddio_reg_to_drive_oe true]} {
				set_parameter_value USE_DDIO_REG_TO_DRIVE_OE "true"
				set_parameter_value USE_ONE_REG_TO_DRIVE_OE "false"
				set_parameter_property gui_use_ddio_reg_to_drive_oe ENABLED true
				set_parameter_property gui_use_register_to_drive_obuf_oe ENABLED false
			} elseif {[safe_string_compare $use_register_to_drive_obuf_oe false] && [safe_string_compare $use_ddio_reg_to_drive_oe false]} {
				set_parameter_property gui_use_register_to_drive_obuf_oe ENABLED true
				set_parameter_property gui_use_ddio_reg_to_drive_oe ENABLED true
				set_parameter_value USE_ONE_REG_TO_DRIVE_OE "false"
				set_parameter_value USE_DDIO_REG_TO_DRIVE_OE "false"
			}
		}
	} else {
		set_parameter_property gui_use_register_to_drive_obuf_oe ENABLED false
		set_parameter_property gui_use_ddio_reg_to_drive_oe ENABLED false
		set_parameter_value USE_ONE_REG_TO_DRIVE_OE "false"
		set_parameter_value USE_DDIO_REG_TO_DRIVE_OE "false"
	}
	
	if {( $data_dir == "output" || $data_dir == "bidir" )} {
		set_parameter_property gui_open_drain ENABLED true
		if {[safe_string_compare $open_drain_output true]} {
			set_parameter_value OPEN_DRAIN_OUTPUT "true"
		} else {
			set_parameter_value OPEN_DRAIN_OUTPUT "false"
		}
	} else {
		set_parameter_property gui_open_drain ENABLED false
		set_parameter_value OPEN_DRAIN_OUTPUT "false"
	} 	
		
}











set_module_property ELABORATION_CALLBACK ip_elaborate
set_module_property VALIDATION_CALLBACK ip_validate

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_gpio_lite

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_gpio_lite

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL altera_gpio_lite


proc generate_vhdl_sim {name} {

	add_fileset_file altera_gpio_lite.sv SYSTEM_VERILOG PATH altera_gpio_lite.sv 

	add_fileset_file [file join mentor altera_gpio_lite.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor altera_gpio_lite.sv] {MENTOR_SPECIFIC}
}

proc generate_verilog_sim {name} {
	add_fileset_file altera_gpio_lite.sv SYSTEM_VERILOG PATH altera_gpio_lite.sv
}

proc generate_synth {name} {
	add_fileset_file altera_gpio_lite.sv SYSTEM_VERILOG PATH altera_gpio_lite.sv
}

