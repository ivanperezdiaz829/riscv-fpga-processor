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


# (C) 2002-2010 Altera Corporation. All rights reserved.
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
# | $Header: //acds/rel/13.1/ip/altera_mult_add/source/top/altera_mult_add_ui_rules.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | 
# | User Interface rules and legality check  
# | 
# +-----------------------------------
proc validation_param_visibility {} {
	
	#Retrieve gui_ parameter
	set get_number_of_multiplier [get_parameter_value number_of_multipliers]
	set get_representation_a [get_parameter_value gui_representation_a]
	set get_representation_b [get_parameter_value gui_representation_b]
	set get_multiplier1_direction [get_parameter_value gui_multiplier1_direction]
	set get_multiplier3_direction [get_parameter_value gui_multiplier3_direction]
	set get_multiplier_a_input [get_parameter_value gui_multiplier_a_input]
	set get_preadder_mode [get_parameter_value preadder_mode]
	set get_coef_register [get_parameter_value gui_coef_register]
	set get_datac_input_register [get_parameter_value gui_datac_input_register]
	set get_accumulator [get_parameter_value accumulator]
	set get_ena_preload_const [get_parameter_value gui_ena_preload_const]
	set get_device [get_parameter_value selected_device_family]
	
	set is_use_register_signa [get_parameter_value gui_register_signa]
	set is_use_register_signb [get_parameter_value gui_register_signb]
	set is_use_output_register [get_parameter_value gui_output_register]
	set is_use_addnsub_multiplier_register1 [get_parameter_value gui_addnsub_multiplier_register1]
	set is_use_addnsub_multiplier_register3 [get_parameter_value gui_addnsub_multiplier_register3]
	set is_use_input_register_a [get_parameter_value gui_input_register_a]
	set is_use_input_register_b [get_parameter_value gui_input_register_b]
	set is_use_multiplier_register [get_parameter_value gui_multiplier_register]
	set is_use_scanouta_register [get_parameter_value gui_scanouta_register]
	set is_use_systolic_register [get_parameter_value gui_systolic_delay]
	set get_accumulate_port_select [get_parameter_value gui_accumulate_port_select]
	
	set get_pipelining [get_parameter_value gui_pipelining]

	
	#General "Multiplier Representation"
	if {$get_representation_a eq "VARIABLE"} {
		set_parameter_property gui_register_signa ENABLED true
		set_parameter_property gui_register_signa VISIBLE true
	} else {
		set_parameter_property gui_register_signa ENABLED false
		set_parameter_property gui_register_signa VISIBLE false
		set_parameter_property gui_register_signa_clock VISIBLE false
		set_parameter_property gui_register_signa_aclr VISIBLE false
	}
	if {$get_representation_a eq "VARIABLE" && $is_use_register_signa == "true"} {
		set_parameter_property gui_register_signa_clock VISIBLE true
		set_parameter_property gui_register_signa_aclr VISIBLE true
	} else {
		set_parameter_property gui_register_signa_clock VISIBLE false
		set_parameter_property gui_register_signa_aclr VISIBLE false
	}
	if {$get_representation_b eq "VARIABLE"} {
		set_parameter_property gui_register_signb ENABLED true
		set_parameter_property gui_register_signb VISIBLE true
	} else {
		set_parameter_property gui_register_signb ENABLED false
		set_parameter_property gui_register_signb VISIBLE false
		set_parameter_property gui_register_signb_clock VISIBLE false
		set_parameter_property gui_register_signb_aclr VISIBLE false
	}
	if {$get_representation_b eq "VARIABLE" && $is_use_register_signb == "true"} {
		set_parameter_property gui_register_signb_clock VISIBLE true
		set_parameter_property gui_register_signb_aclr VISIBLE true
	} else {
		set_parameter_property gui_register_signb_clock VISIBLE false
		set_parameter_property gui_register_signb_aclr VISIBLE false
	}
	#Extra Modes "Output Configuration"
	if {$is_use_output_register == "true"} {
		set_parameter_property gui_output_register_clock VISIBLE true
		set_parameter_property gui_output_register_aclr VISIBLE true
	} else {
		set_parameter_property gui_output_register_clock VISIBLE false
		set_parameter_property gui_output_register_aclr VISIBLE false
	}
	#Extra Modes "Multipliers Configuration"
	if {$get_number_of_multiplier > 1} {
		set_parameter_property gui_multiplier1_direction ENABLED true
	} elseif {$get_multiplier1_direction ne "VARIABLE"} {
		set_parameter_property gui_multiplier1_direction ENABLED false
	}
	if {$get_number_of_multiplier > 1 && $get_multiplier1_direction eq "VARIABLE"} {
		set_parameter_property gui_addnsub_multiplier_register1 ENABLED true
		set_parameter_property gui_addnsub_multiplier_register1 VISIBLE true
	} else {
		set_parameter_property gui_addnsub_multiplier_register1 ENABLED false
		set_parameter_property gui_addnsub_multiplier_register1 VISIBLE false
		set_parameter_property gui_addnsub_multiplier_register1_clock VISIBLE false
		set_parameter_property gui_addnsub_multiplier_aclr1 VISIBLE false
	}
	if {$get_number_of_multiplier > 1 && $get_multiplier1_direction eq "VARIABLE" && $is_use_addnsub_multiplier_register1 == "true"} {
		set_parameter_property gui_addnsub_multiplier_register1_clock VISIBLE true
		set_parameter_property gui_addnsub_multiplier_aclr1 VISIBLE true
	} else {
		set_parameter_property gui_addnsub_multiplier_register1_clock VISIBLE false
		set_parameter_property gui_addnsub_multiplier_aclr1 VISIBLE false
	}
	if {$get_number_of_multiplier == 4} {
		set_parameter_property gui_multiplier3_direction ENABLED true
	} elseif {$get_multiplier3_direction ne "VARIABLE"} {
		set_parameter_property gui_multiplier3_direction ENABLED false
	}
	if {$get_number_of_multiplier == 4 && $get_multiplier3_direction eq "VARIABLE"} {
		set_parameter_property gui_addnsub_multiplier_register3 ENABLED true
		set_parameter_property gui_addnsub_multiplier_register3 VISIBLE true
	} else {
		set_parameter_property gui_addnsub_multiplier_register3 ENABLED false
		set_parameter_property gui_addnsub_multiplier_register3 VISIBLE false
		set_parameter_property gui_addnsub_multiplier_register3_clock VISIBLE false
		set_parameter_property gui_addnsub_multiplier_aclr3 VISIBLE false
	}
	if {$get_number_of_multiplier == 4 && $get_multiplier3_direction eq "VARIABLE" && $is_use_addnsub_multiplier_register3 == "true"} {
		set_parameter_property gui_addnsub_multiplier_register3_clock VISIBLE true
		set_parameter_property gui_addnsub_multiplier_aclr3 VISIBLE true
	} else {
		set_parameter_property gui_addnsub_multiplier_register3_clock VISIBLE false
		set_parameter_property gui_addnsub_multiplier_aclr3 VISIBLE false
	}
	#Multipliers "Input Configuration"
	if {$is_use_input_register_a == "true"} {
		set_parameter_property gui_input_register_a_clock VISIBLE true
		set_parameter_property gui_input_register_a_aclr VISIBLE true
	} else {
		set_parameter_property gui_input_register_a_clock VISIBLE false
		set_parameter_property gui_input_register_a_aclr VISIBLE false
	}
	if {$is_use_input_register_b == "true"} {
		set_parameter_property gui_input_register_b_clock VISIBLE true
		set_parameter_property gui_input_register_b_aclr VISIBLE true
	} else {
		set_parameter_property gui_input_register_b_clock VISIBLE false
		set_parameter_property gui_input_register_b_aclr VISIBLE false
	}
	if {$get_number_of_multiplier > 1} {
		set_parameter_property gui_multiplier_a_input ENABLED true
	} else {
		set_parameter_property gui_multiplier_a_input ENABLED false
	}
	if {$get_number_of_multiplier > 1 && $get_multiplier_a_input eq "Scan chain input"} {
		set_parameter_property gui_scanouta_register ENABLED true
		set_parameter_property gui_scanouta_register VISIBLE true
	} else {
		set_parameter_property gui_scanouta_register ENABLED false
		set_parameter_property gui_scanouta_register VISIBLE false
		set_parameter_property gui_scanouta_register_clock VISIBLE false
		set_parameter_property gui_scanouta_register_aclr VISIBLE false
	}
	if {$get_number_of_multiplier > 1 && $get_multiplier_a_input eq "Scan chain input" && $is_use_scanouta_register == "true"} {
		set_parameter_property gui_scanouta_register_clock VISIBLE true
		set_parameter_property gui_scanouta_register_aclr VISIBLE true
	} else {
		set_parameter_property gui_scanouta_register_clock VISIBLE false
		set_parameter_property gui_scanouta_register_aclr VISIBLE false
	}
	#Multiplier "Output Configuration"
	if {$is_use_multiplier_register == "true"} {
		set_parameter_property gui_multiplier_register_clock VISIBLE true
		set_parameter_property gui_multiplier_register_aclr VISIBLE true
	} else {
		set_parameter_property gui_multiplier_register ENABLED false
		set_parameter_property gui_multiplier_register_clock VISIBLE false
		set_parameter_property gui_multiplier_register_aclr VISIBLE false
	}
	#Preadder
	set_parameter_property width_coef ENABLED false
	set_parameter_property gui_coef_register ENABLED false		
	for { set i 0 } {$i < 4} {incr i} {	
		for { set j 0 } {$j < 8} {incr j} {
			set_parameter_property coef${i}_${j} ENABLED false
		}
	}
	if {$get_preadder_mode eq "COEF" || $get_preadder_mode eq "CONSTANT"} {
		set_parameter_property width_coef ENABLED true
		set_parameter_property gui_coef_register ENABLED true		
		for { set i 0 } {$i < 4} {incr i} {	
			for { set j 0 } {$j < 8} {incr j} {
				set_parameter_property coef${i}_${j} ENABLED true

			}
		}
	}
	
	if {$get_preadder_mode eq "SIMPLE"} {
		set_parameter_property gui_preadder_direction ENABLED false
	} else {
		set_parameter_property gui_preadder_direction ENABLED true
	}
	if {($get_preadder_mode eq "COEF" || $get_preadder_mode eq "CONSTANT") && $get_coef_register == true} {
		set_parameter_property gui_coef_register_clock VISIBLE true
		set_parameter_property gui_coef_register_aclr VISIBLE true
	} else {
		set_parameter_property gui_coef_register_clock VISIBLE false
		set_parameter_property gui_coef_register_aclr VISIBLE false
	}
	if {$get_preadder_mode eq "INPUT"} {
		set_parameter_property width_c ENABLED true
		set_parameter_property gui_datac_input_register ENABLED true
	} else {
		set_parameter_property width_c ENABLED false
		set_parameter_property gui_datac_input_register ENABLED false
	}
	if {$get_preadder_mode eq "INPUT" && $get_datac_input_register == "true"} {
		set_parameter_property gui_datac_input_register_clock VISIBLE true
		set_parameter_property gui_datac_input_register_aclr VISIBLE true
	} else {
		set_parameter_property gui_datac_input_register_clock VISIBLE false
		set_parameter_property gui_datac_input_register_aclr VISIBLE false
	}
	#Accumulator/Preload
	if {$get_accumulator eq "YES"} {
		set_parameter_property accum_direction ENABLED true
		set_parameter_property gui_ena_preload_const ENABLED true
	} else {
		set_parameter_property accum_direction ENABLED false
		set_parameter_property gui_ena_preload_const ENABLED false
	}
	if {$get_accumulator eq "YES" && $get_ena_preload_const == "true"} {
		set_parameter_property loadconst_value ENABLED true
		set_parameter_value gui_accum_sload_register "true"
		set_parameter_property gui_accum_sload_register_clock VISIBLE true
		set_parameter_property gui_accum_sload_register_aclr VISIBLE true
		set_parameter_property gui_accumulate_port_select ENABLED true

	} else {
		set_parameter_property loadconst_value ENABLED false
		set_parameter_value gui_accum_sload_register "false"
		set_parameter_property gui_accum_sload_register_clock VISIBLE false
		set_parameter_property gui_accum_sload_register_aclr VISIBLE false
		set_parameter_property gui_accumulate_port_select ENABLED false
	}
	if {$get_accumulator eq "YES" && $get_device eq "Arria V"} {
		set_parameter_property gui_double_accum ENABLED true
	} else {
		set_parameter_property gui_double_accum ENABLED false
	}
		
	#Systolic delay
	if {$get_number_of_multiplier == 4 || $get_number_of_multiplier == 2} {
		set_parameter_property gui_systolic_delay ENABLED true
	} elseif {$is_use_systolic_register == "false"} {
		set_parameter_property gui_systolic_delay ENABLED false
	}
	if {($get_number_of_multiplier == 4 || $get_number_of_multiplier == 2) && $is_use_systolic_register == "true"} {
		set_parameter_property gui_systolic_delay_clock VISIBLE true
		set_parameter_property gui_systolic_delay_aclr VISIBLE true
	} else {
		set_parameter_property gui_systolic_delay_clock VISIBLE false
		set_parameter_property gui_systolic_delay_aclr VISIBLE false
	}
	
	#pipelining
	if {$get_pipelining == 0} {
		set_parameter_property latency ENABLED false
		set_parameter_property gui_input_latency_clock VISIBLE false
		set_parameter_property gui_input_latency_aclr VISIBLE false
	} else {
		set_parameter_property latency ENABLED true
		set_parameter_property gui_input_latency_clock VISIBLE true
		set_parameter_property gui_input_latency_aclr VISIBLE true
	}	
}

# +-----------------------------------
# | 
# | UI update callback (Documentation: IP Core UI-Time Parameter Update FD)
# | 
# +-----------------------------------

#width result update
#proc update_width_result {arg} {
#
#	set get_number_of_multiplier [get_parameter_value number_of_multipliers]
#	set get_width_a [get_parameter_value width_a]
#	set get_width_b [get_parameter_value width_b]
#	
#	set res_calc [expr $get_width_a + $get_width_b + $get_number_of_multiplier - 1]
#	if {$get_number_of_multiplier == 4} {
#		set updated_width_result [expr $res_calc - 1]
#	} else {
#		set updated_width_result $res_calc
#	}
#	if {$updated_width_result <= 256} {
#		set_parameter_value width_result $updated_width_result
#	} else {
#		set_parameter_value width_result 1
#	}
#}

#update parameter/feature restricted by number_of_multipliers' value
proc update_multipliers_restricted_params {arg} {

	set get_number_of_multiplier [get_parameter_value number_of_multipliers]
	
	if {$get_number_of_multiplier == 1 || $get_number_of_multiplier == 3} {
		set_parameter_value gui_systolic_delay 0
	}
	if { $get_number_of_multiplier == 1 } {
		set_parameter_value gui_multiplier_a_input "Multiplier input"
	}
	if { $get_number_of_multiplier < 2 } {	
		set_parameter_value gui_multiplier1_direction "ADD"
	}
	if { $get_number_of_multiplier < 3 } {	
		set_parameter_value gui_multiplier3_direction "ADD"
	}
}

#preadder register
proc update_preadder_reg {arg} {
	
	set get_preadder_mode [get_parameter_value preadder_mode]
	
	if {$get_preadder_mode eq "INPUT"} {
		set_parameter_value gui_datac_input_register 1
	} else {
		set_parameter_value gui_datac_input_register 0
	}
		
	if {$get_preadder_mode eq "COEF" || $get_preadder_mode eq "CONSTANT"} {
		set_parameter_value gui_coef_register 1
	} else {
		set_parameter_value gui_coef_register 0	
	}
}

#accumulator preload_constant
proc update_accum_conf {arg} {
	
	set get_accumulator [get_parameter_value accumulator]
	
	if {$get_accumulator eq "NO"} {
		set_parameter_value gui_ena_preload_const 0
		set_parameter_value gui_double_accum 0
	}
}

proc update_accmulate_port_select {arg} {

	set get_accumulator [get_parameter_value accumulator]
	set get_ena_preload_const [get_parameter_value gui_ena_preload_const]
	
	if {$get_accumulator eq "NO" || $get_ena_preload_const eq "false"} {
		set_parameter_value gui_accumulate_port_select 0
	}
}

#pipelining
proc update_pipelining_update {arg} {

	set get_pipelining [get_parameter_value gui_pipelining]
	
	if {$get_pipelining == 0} {
		set_parameter_value latency 0
	}
}