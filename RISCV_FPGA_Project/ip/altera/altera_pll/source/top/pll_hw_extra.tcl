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
# | $Header: //acds/rel/13.1/ip/altera_pll/source/top/pll_hw_extra.tcl#7 $
# | 
# +-----------------------------------
# Required header to put the alt_mem_if and alt_xcvr TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
set alt_xcvr_packages_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages"
if { [lsearch -exact $auto_path $alt_xcvr_packages_dir] == -1 } {
  lappend auto_path $alt_xcvr_packages_dir
}

set WIZARD_NAME "altera_pll"

#send_message info "hw.tcl dir is [get_module_property MODULE_DIRECTORY]"
source pll_reconfig_util.tcl
source ../../../sopc_builder_ip/altera_avalon_mega_common/ipcc_wrap_split.tcl
source ../../../sopc_builder_ip/altera_avalon_mega_common/sopc_mwizc.tcl

package require quartus::qcl_pll 
package require quartus::advanced_pll_legality 
package require alt_mem_if::util::messaging
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils
namespace import ::alt_mem_if::util::messaging::*
package require alt_xcvr::utils::common
namespace import ::alt_xcvr::utils::common::map_allowed_range
namespace import ::alt_xcvr::utils::common::get_mapped_allowed_range_value

set WORK_DIR [get_work_directory]
#declare constants for widths
set reconf_width 64
set refclk_width 1

set total_rbc_time 0
set num_rbc_calls 0


# Single parameter callbacks to enforce fixed-precision floats
proc round_frequency_to_six_decimals {arg} {
	set freq [get_parameter_value $arg]
	set new_freq [format "%.6f" $freq]
	set_parameter_value $arg $new_freq
	
	# Warn the user if truncation has occurred
	set threshold 1e-8
	set diff [expr abs($freq - $new_freq)]
	if {$diff > $threshold} {
		send_message warning "Frequencies cannot exceed six decimals of precision"
	}
}
proc round_phase_shift_to_one_decimal {arg} {
	set phase_shift [get_parameter_value $arg]
	
	# Allow 1 decimal of precision for phase shift in "degrees"
	set new_phase_shift [format "%.1f" $phase_shift]
	set_parameter_value $arg $new_phase_shift			
}


proc elaboration_callback {} {
	#declare ports and mappings for elaboration callback
	interface_ports_and_mapping elaboration
	
	#common code function to declare interface ports from mapping data
	ipcc_elaboration_declarations
    
    set reconf_enabled [get_parameter_value gui_en_reconf] 
    set mif_dps_enabled [get_parameter_value gui_enable_mif_dps]
    # Enable settings for MIF Streaming under Advanced Parameters
    set_display_item_property "MIF Streaming" ENABLED $reconf_enabled
    set_display_item_property "Dynamic Phase Shift (MIF)" ENABLED $mif_dps_enabled

    # DPA Connectivity not enabled for CV
    set device [get_parameter_value device_family]
	set is_nightfury [is_nightfury_device $device]
    set dpa_visible [expr {$device != "Cyclone V"}]
	set dpa_enable [get_parameter_value gui_en_phout_ports]
	set lvds_enable $is_nightfury
    set enable_phout_division [expr {$dpa_visible && $dpa_enable && !$is_nightfury}]
    set_parameter_property gui_en_phout_ports ENABLED $dpa_visible
	set_parameter_property gui_phout_division ENABLED $enable_phout_division
    set_parameter_property gui_en_lvds_ports ENABLED $lvds_enable
	set_parameter_property pll_vcoph_div ENABLED $enable_phout_division
	set_parameter_value pll_vcoph_div [get_parameter_value gui_phout_division]
}

#declare dynamic interfaces and ports
#	flag == elaboration means real interfaces and ports must be declared
#	flag == mapping_only declares no interfaces or ports, and returns the mapping data
#		to map from HDL ports to interfaces

proc interface_ports_and_mapping { flag } {
	ipcc_init_mappings $flag
	
    global reconf_width
    global refclk_width
	set num_count [get_parameter_value gui_number_of_clocks]
	set op_mode [get_mapped_allowed_range_value gui_operation_mode]
	set en_locked [get_parameter_value gui_use_locked]
    set en_reconf [get_parameter_value gui_en_reconf]
    set en_dps [get_parameter_value gui_en_dps_ports]
	set en_phout [get_parameter_value gui_en_phout_ports]
	set en_lvds [get_parameter_value gui_en_lvds_ports]
    set en_adv [get_parameter_value gui_en_adv_params]
	set en_refclk_switch [get_parameter_value gui_refclk_switch]
	set en_pll_cascade_out [get_parameter_value gui_enable_cascade_out]
	set en_pll_cascade_in [get_parameter_value gui_enable_cascade_in]
	set device [get_parameter_value device_family]
	set is_nightfury [is_nightfury_device $device]
	set uses_counter_cascading [expr [get_parameter_value number_of_cascade_counters] > 0]	
	set use_non_generic_pll [expr {$en_dps||$en_reconf||$en_refclk_switch||$en_adv||$en_pll_cascade_out||$en_pll_cascade_in||$en_phout||$uses_counter_cascading||$en_lvds}]
	
	if {$en_locked == "true"} {
		set locked_en "true"
	} else {
		set locked_en "false"
	}	
		
    if { $op_mode == "external feedback"} {
	    set fbin "true"
	    set fbout "true"
	    
	    if {$flag == "elaboration"} {
	    	add_interface fbclk clock end
			set_interface_property fbclk ENABLED true
			set_interface_property fbclk ENABLED $fbin
			add_interface_port fbclk fbclk clk Input 1

			add_interface fboutclk clock start
			set_interface_property fboutclk ENABLED true
			set_interface_property fboutclk ENABLED $fbout
			add_interface_port fboutclk fboutclk clk Output 1
		}
    } else {
	    set fbin "false"
	    set fbout "false"
	    my_terminate_port fbclk "1'b0" input
	    my_terminate_port fboutclk "1'b0" output
    }
    if { $op_mode == "zero delay buffer"} {
	    set zdbfbclk "true"
	    if {$flag == "elaboration"} {
			add_interface zdbfbclk conduit start
			set_interface_property zdbfbclk ENABLED true
			set_interface_property zdbfbclk ENABLED $zdbfbclk
			add_interface_port zdbfbclk zdbfbclk export Bidir 1
		}
    } else {
	    set zdbfbclk "false" 
    }
	for { set i 0 } {$i < $num_count} {incr i} {
    	if { $flag == "elaboration" } {
            # Is this counter enabled?
            set is_cascade_counter [get_parameter_value gui_cascade_counter$i]
            if {($is_cascade_counter && $en_adv)} {
                set counter_en false
            } else {
                set counter_en true
            }
            add_interface outclk$i clock start
            set_interface_property outclk$i ENABLED $counter_en 
            set_interface_property outclk$i EXPORT_OF $counter_en 
            set_interface_property outclk$i clockRateKnown "true"
            set output_param [lindex [split [get_parameter_value output_clock_frequency$i] "MHz"] 0]
            if {$output_param == ""} {
                set output_param 0
            }
            set_interface_property outclk$i clockRate [expr $output_param * 1000000]
		}
		ipcc_add_interface_mapped_port outclk$i outclk@$i clk Output $num_count
	}
    if {$flag == "elaboration"} {
		add_interface locked conduit start
        set_interface_property locked ENABLED true
        set_interface_property locked ENABLED $locked_en
		set_interface_assignment locked "ui.blockdiagram.direction" OUTPUT
		add_interface_port locked locked export Output 1

        if {$use_non_generic_pll} {
            set_parameter_value pll_type $device
        } else {
            set_parameter_value pll_type "General"
        }
        
        ##Elaborate refclk switchover and PLL cascading
		pll_cascading_elaboration_validation $flag $device
        refclk_switchover_elaboration_validation $flag $device 
        ##############################	
        if {$device == "Stratix V" || $device == "Arria V" || $device == "Cyclone V" || $device == "Arria V GZ"} {
            #picking the right type of PLL

            if {$en_reconf && $en_dps} {
                send_message warning "Altera PLL does not recommend simultaneously enabling Dynamic Reconfiguration and access to Dynamic Phase Shift ports. Please refer to AN661 for how to perform dynamic phase shifts using PLL Dynamic Reconfiguration."
            }
            if {$en_reconf} {
                if {$en_dps} {
                    set_parameter_value pll_subtype "ReconfDPS"
                } else {
                    set_parameter_value pll_subtype "Reconfigurable"
                }
            } else {
                if {$en_dps} {
                    set_parameter_value pll_subtype "DPS"
                } else {
                    set_parameter_value pll_subtype "General"
                }
            }

            ##############################
            #External DPS ports elaboration function
            en_dps_ports $flag $en_dps $device
            en_reconfig_ports $flag $en_reconf
			en_phout_ports $flag $en_phout
            enable_physical_parameters $use_non_generic_pll
	   } elseif { $is_nightfury } {
            enable_physical_parameters $use_non_generic_pll

            if {$en_reconf} {
                set_parameter_value pll_subtype "Reconfigurable"
            } else {
                if {$en_dps} {
                    set_parameter_value pll_subtype "DPS"
                } else {
    			    set_parameter_value pll_subtype "General"
                }
            }
            en_dps_ports $flag $en_dps $device
            en_reconfig_ports $flag $en_reconf
			en_phout_ports $flag $en_phout
			en_lvds_ports $flag $en_lvds

       } else {
            #Only allow dynamic reconfig/Advanced modes for Supported Families
            set_parameter_property gui_en_reconf VISIBLE false
            set_parameter_property gui_en_dps_ports VISIBLE false
			set_parameter_property gui_en_phout_ports VISIBLE false
			set_parameter_property gui_en_lvds_ports VISIBLE false
			set_parameter_property gui_phout_division VISIBLE false
            set_parameter_property gui_en_adv_params VISIBLE false
        }
    }
}
 
proc validation_param_visibility { } {
	set num_count [get_parameter_value gui_number_of_clocks]
    set adv_params [get_parameter_value gui_en_adv_params]
    set en_reconf [get_parameter_value gui_en_reconf]
    set en_dps [get_parameter_value gui_en_dps_ports]
	set en_phout [get_parameter_value gui_en_phout_ports]
	set en_lvds [get_parameter_value gui_en_lvds_ports]
	set en_refclk_switch [get_parameter_value gui_refclk_switch]
	set en_pll_cascade_out [get_parameter_value gui_enable_cascade_out]
	set en_pll_cascade_in [get_parameter_value gui_enable_cascade_in]
	set device [get_parameter_value device_family]
	set is_nightfury [is_nightfury_device $device]
	set use_non_generic_pll [expr {$en_dps||$en_reconf||$en_refclk_switch||$adv_params||$en_pll_cascade_out||$en_pll_cascade_in||$en_phout||$en_lvds}]
	set op_mode [get_mapped_allowed_range_value gui_operation_mode]

    ##enable feedback clock box for normal and ss comp modes
    if {$use_non_generic_pll} {
        if { $op_mode == "normal" || $op_mode == "source synchronous"} {
            my_set_param_visibility "gui_feedback_clock" "true"
        } else {
            my_set_param_visibility "gui_feedback_clock" "false"
        }
    } else {
        my_set_param_visibility "gui_feedback_clock" "false"
    }
	## enable channel spacing for fractional-N pll
	set pll_mode [get_parameter_value gui_pll_mode]
	if { $pll_mode == "Fractional-N PLL"} {
		set frac "true"
    } else {
	    set frac "false"
    }
    my_set_param_visibility "gui_channel_spacing" $frac
    my_set_param_visibility "gui_fractional_cout" [expr {($frac == "true") ? $use_non_generic_pll : "false"}]
    my_set_param_visibility "gui_dsm_out_sel" [expr {($frac == "true") ? $use_non_generic_pll : "false"}]
	my_set_param_visibility "gui_multiply_factor" [expr {($adv_params == "true") ? "true" : "false"}]
    my_set_param_visibility "gui_frac_multiply_factor" [expr {($frac == "true") ? [expr {($adv_params == "true") ? "true" : "false"}] : "false"}]
    my_set_param_visibility "gui_divide_factor_n" [expr {($adv_params == "true") ? "true" : "false"}]
    for { set i 0 } {$i < 18} {incr i} {
        set visibility [expr { ($i < $num_count ) ? "true" : "false"}]
        set adv_visibility [expr {($adv_params == "true") ? $visibility : "false"}]
		set is_cascade_counter [get_parameter_value gui_cascade_counter$i]
		set cascade_visibility [expr {($is_cascade_counter == "true") ? $adv_visibility : "false"}]
        set dps_in_deg [get_parameter_value gui_ps_units$i]
        set dps_in_deg [expr {($dps_in_deg == "degrees") ? "true" : "false"}]
		
		my_set_param_visibility "gui_output_clock_frequency${i}" [expr {($adv_params == "true") ? "false" : $visibility}]
		my_set_param_visibility "gui_cascade_counter$i" $adv_visibility
		my_set_param_visibility "gui_divide_factor_c$i" $adv_visibility
		my_set_param_visibility "gui_actual_output_clock_frequency${i}" $visibility
		my_set_param_visibility "gui_actual_phase_shift${i}" $visibility
		my_set_param_visibility "gui_ps_units${i}" $visibility	
		
		# Modify the enable advanced parameters interface for counter cascading
		if {$cascade_visibility} {
			# Disable the duty cycle field
			set_parameter_property gui_duty_cycle$i ENABLED false
			# Force the user to use "ps" for phase shift
			map_allowed_range gui_ps_units$i {"ps"}	
			set dps_in_deg false
			# Disable the phase shift field of the next counter
			if {$i != 17} {
				set_parameter_property gui_phase_shift[expr $i+1] ENABLED false
			}
		} else {
			set_parameter_property gui_duty_cycle${i} ENABLED true
			map_allowed_range gui_ps_units$i {"ps" "degrees"}	
			if {$i != 17} {
				set_parameter_property gui_phase_shift[expr $i+1] ENABLED true
			}
		}
		
		# Hide the "ps" textbox if "degrees" is selected and vice versa
		my_set_param_visibility "gui_phase_shift${i}" [expr {($dps_in_deg == "true") ? "false" : $visibility}]
		my_set_param_visibility "gui_phase_shift_deg${i}" [expr {($dps_in_deg == "true") ? $visibility : "false"}]
		my_set_param_visibility "gui_duty_cycle${i}" $visibility
    }
	
}

# helper function to declare ST interface
# arguments are (1) interface name, (2) direction (source or sink), (3) data width
proc my_add_st_interface { if_name if_dir width } {
	add_interface $if_name avalon_streaming $if_dir clock_reset
	
	# declare properties of the streaming sink interface
	set_interface_property $if_name dataBitsPerSymbol $width
	set_interface_property $if_name maxChannel 0
	set_interface_property $if_name readyLatency 0
	set_interface_property $if_name symbolsPerBeat 1
	set_interface_property $if_name ASSOCIATED_CLOCK clock_reset
	set_interface_property $if_name ENABLED true
}

proc my_add_clk_interface { if_name status} {
	add_interface $if_name clock start
	set_interface_property $if_name ENABLED true
	set_interface_property $if_name EXPORT_OF true
    set_interface_property $if_name ENABLED $status
    add_interface_port $if_name $if_name clk Output 1
}

proc my_add_clk_interface_in { if_name status} {
	add_interface $if_name clock end
	set_interface_property $if_name ENABLED true
	set_interface_property $if_name EXPORT_OF true
    set_interface_property $if_name ENABLED $status
    add_interface_port $if_name $if_name clk Input 1
}

proc get_reference_list_items { item values } {

    set device [lindex $values 0]
	set is_nightfury [is_nightfury_device $device]

    if { $item == "speed" } {  
       set speed 0
       if {$device == "Stratix V"} {
            map_allowed_range gui_device_speed_grade {"1" "2" "3" "4"}	
            set speed [get_mapped_allowed_range_value gui_device_speed_grade]
        } elseif {$device == "Arria V"} {
            map_allowed_range gui_device_speed_grade {"3_H3" "3_H4" "4_H4" "5_H3" "5_H4" "6_H6"}	
            set speed [get_mapped_allowed_range_value gui_device_speed_grade]
        } elseif {$device == "Arria V GZ"} {
            map_allowed_range gui_device_speed_grade {"3" "4"}
            set speed [get_mapped_allowed_range_value gui_device_speed_grade]
        } elseif {$device == "Cyclone V"} {
            map_allowed_range gui_device_speed_grade {"6" "7" "8"}	
            set speed [get_mapped_allowed_range_value gui_device_speed_grade]
        } elseif {$is_nightfury} {
            map_allowed_range gui_device_speed_grade {"2" "3" "4"}	
            set speed [get_mapped_allowed_range_value gui_device_speed_grade]
        }
        
        return $speed
    } elseif {$item == "device_part"} {
       set device_part [lindex $values 2]
	   if {$device_part == "Unknown" || $device_part == ""} {
	       set speed [lindex $values 1]
		   if {$is_nightfury} {
				set device_part "6AGX1000RF40I3S"
		   } else {
			   if {!($device == "StratixV" || $device == "Stratix V" || $device == "Arria V" || $device == "ArriaV" || $device == "CycloneV" || $device == "Cyclone V" || $device == "Arria V GZ" || $is_nightfury)} {
					send_message error "Altera PLL only supports the 20nm & 28nm device family. For other device families, use ALTPLL or Avalon ALTPLL."
				} elseif {$speed == "1"} {
					set device_part "5SGXEB6R1F43C1"
				} elseif {$speed == "2"} {
					set device_part "5SGXEA7H2F35C2ES"
				} elseif {$speed == "3"} {
					if { $device == "Stratix V" } {
						set device_part "5SGXEA7H2F35C3ES"
					} elseif { $device == "Arria V GZ"} {
						set device_part "5AGZME5K2F40C3"
					}
				} elseif {$speed == "4"} {
					if { $device == "Stratix V" } {
						set device_part "5SGXEA7H3F35C4ES"
					} elseif { $device == "Arria V GZ"} {
						set device_part "5AGZME5K3F40C4"
					}
				} elseif {$speed == "3_H3"} {
					set device_part "5AGTFD7H3F35I3"
				} elseif {$speed == "3_H4"} {
					set device_part "5AGXFB7H4F35I3"
				} elseif {$speed == "4_H4"} {
					set device_part "5AGXFB3H4F35C4"
				} elseif {$speed == "5_H3"} {
					set device_part "5AGTFD7H3F35I5"
				} elseif {$speed == "5_H4"} {
					set device_part "5AGXFB3H4F35C5"
				} elseif {$speed == "6_H6"} {
					set device_part "5AGXFB3H6F35C6"
				} elseif {$speed == "6"} {
					set device_part "5CGTFD6F27C5ES"
				} elseif {$speed == "7"} {
					set device_part "5CGXBC7C6U19C7"
				} elseif {$speed == "8"} {
					set device_part "5CGXBC7C7F23C8"
				}
			}
		}
        return $device_part
    } elseif {$item == "pll_type"} {
        set pll_type "fPLL"
        return $pll_type
        
    } elseif {$item == "channel_spacing"} {
       if { [get_parameter_value gui_pll_mode] == "Fractional-N PLL"} {
            set channel_spacing [get_parameter_value gui_channel_spacing]
            set channel_spacing "$channel_spacing kHz"
        } else {
            set channel_spacing "0.0 MHz"
        }
        return $channel_spacing
    } elseif {$item == "fractional_vco_multiplier"} {
       if { [get_parameter_value gui_pll_mode] == "Fractional-N PLL"} {
            set fractional_vco_multiplier "true"
        } else {
            set fractional_vco_multiplier "false"
        }
        return $fractional_vco_multiplier 
    }
}




set generic_total 0
set generic_total_time 0

proc my_set_rbc_check { rule_name reference_list } {
	
    set r_total 0
    global generic_total
    global generic_total_time

	_dprint 1 "rule = $rule_name\n $reference_list"	
	#---print for regtest---
	if {[get_parameter_value debug_print_output] == "true"} {	
		send_message debug "rule = $rule_name\n $reference_list"
	}
	
	#---TEST RBC/TAF (old) METHOD---
	if {[get_parameter_value debug_use_rbc_taf_method] == "true"} {
		set start_v_total [clock clicks -milliseconds]
		set result [::quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values -flow_type MEGAWIZARD -configuration_name GENERIC_PLL -rule_name $rule_name -param_args $reference_list]
		set end_v_total [clock clicks -milliseconds]	
	} else {
	#---NEW IPTCL METHOD---
		set start_v_total [clock clicks -milliseconds]
		if { [catch {parse_tcl_data $rule_name $reference_list} result] } {
			#Upon error, ensure that no error message from the C code is propagated to tcl
			set result {{{}}}
		}
		set end_v_total [clock clicks -milliseconds]		
	}

	_dprint 1 "return = $result"
	#---print message for regtest
	if {[get_parameter_value debug_print_output] == "true"} {	
		send_message debug "return = $result"
	}	 
	
	set generic_total [incr generic_total]
	set r_total [expr {$end_v_total - $start_v_total}]
	set generic_total_time [expr {$generic_total_time + $r_total}]
	
	_dprint 1  "total rbc time = $r_total"
	#---print message for regtest
	if {[get_parameter_value debug_print_output] == "true"} {		
		#print message for regtest - DO NOT CHANGE THIS STRING
		send_message debug "total IPTAF/TAF time: $r_total "	 
	}
		
    return $result   
}
# The validation callback
proc validation_callback {} {
    global generic_total
    global generic_total_time
    set r_total 0
    set start_v_total [clock clicks -milliseconds]
    
	# Enable or disable parameters based on the number of output clocks
	validation_param_visibility
	set en_locked [get_parameter_value gui_use_locked]
    set en_reconf [get_parameter_value gui_en_reconf]
    set en_refclk_switch [get_parameter_value gui_refclk_switch]
    set en_pll_cascade_out [get_parameter_value gui_enable_cascade_out]
	set en_pll_cascade_in [get_parameter_value gui_enable_cascade_in]
    set refclk_switchover_mode [get_parameter_value gui_switchover_mode]
    set en_refclk_clkbad [get_parameter_value gui_clk_bad]
    set en_dps [get_parameter_value gui_en_dps_ports]
    set en_phout [get_parameter_value gui_en_phout_ports]
	set en_lvds [get_parameter_value gui_en_lvds_ports]
    set en_adv [get_parameter_value gui_en_adv_params]
    set device [get_parameter_value device_family]
	set is_nightfury [is_nightfury_device $device]
    set use_non_generic_pll [expr {$en_dps||$en_reconf||$en_refclk_switch||$en_adv||$en_pll_cascade_out||$en_pll_cascade_in||$en_phout||$en_lvds}]

	# Adjust the allowed range of K
	if {$en_adv} {
		adjust_allowed_range_of_K
	}
	
	# Number of C-counters needed for cascading
	set num_cascade_counters 0
 
    # Set the number of clocks based on device family
	set_number_of_clocks $device $num_cascade_counters
	
	#Set the derived number_of_clocks parameter
    set num_clocks [get_parameter_value gui_number_of_clocks]
    set_parameter_value number_of_clocks $num_clocks 
	
	# Set PLL modes
	if {$is_nightfury} {
		map_allowed_range gui_pll_mode {"Integer-N PLL"}	
	} else {
		map_allowed_range gui_pll_mode {"Integer-N PLL" "Fractional-N PLL"}	
	}
	
    if {$use_non_generic_pll} {
        map_allowed_range gui_operation_mode {"direct" "external feedback" "normal" "source synchronous" "zero delay buffer" "lvds"}
    } else {
        if {$device == "Stratix V" || $device == "Arria V GZ"} {
            map_allowed_range gui_operation_mode {"direct" "external feedback" "normal" "source synchronous" "zero delay buffer" "lvds"}
        } elseif {$device == "Arria V"} {
            map_allowed_range gui_operation_mode {"direct" "external feedback" "normal" "source synchronous" "zero delay buffer" "lvds"}
        } elseif {$device == "Cyclone V"} {
            map_allowed_range gui_operation_mode {"direct" "external feedback" "normal" "source synchronous" "zero delay buffer" "lvds"}
        } elseif {$is_nightfury} {
            map_allowed_range gui_operation_mode {"direct" "external feedback" "normal" "source synchronous" "zero delay buffer" "lvds"}
        }
    }
    #set the derived operation_mode parameter
    set op_mode [get_parameter_value gui_operation_mode]
    set_parameter_value operation_mode [get_compensation_mode]
    
    # Get the current value of parameters we care about
    set device [get_parameter_value device_family]
	set device_part [get_parameter_value device]
    set speed [get_reference_list_items "speed" [list $device]]
    set device_part [get_reference_list_items "device_part" [list $device $speed $device_part]]
    set num_count [get_parameter_value gui_number_of_clocks]
    set pll_type [get_reference_list_items "pll_type" $device]
    
	# Ensure that refclk frequencies don't exceed 6 decimals of precision
    set check_refclk [precision_check [get_parameter_value gui_reference_clock_frequency]]
    set check_refclk1 [precision_check [get_parameter_value gui_refclk1_frequency]]
    set ref_clk $check_refclk
    set ref_clk1 $check_refclk1
    set rbc_ref_clk "[get_parameter_value gui_reference_clock_frequency] MHz"
    set_parameter_value reference_clock_frequency "$ref_clk MHz"

    set channel_spacing [get_reference_list_items "channel_spacing" [list $device]]
    set fractional_vco_multiplier [get_reference_list_items "fractional_vco_multiplier" [list $device]]
    if { $fractional_vco_multiplier == "true"} {
        set_parameter_value fractional_vco_multiplier 1
    } else {
        set_parameter_value fractional_vco_multiplier 0
    }
    
	# ALTERA_HACK - custom Tcl legality check to provide meaningful error message for physical parameter entry
	# check to see if the given N counter will result in an invalid PFD
	if {$en_adv} {
		set div_n [get_parameter_value gui_divide_factor_n]
		set pfd [expr {$ref_clk / $div_n}]
		if {$pfd < 5 || $pfd > 325} {
			send_message error "The specified configuration causes Phase Frequency Detector (PFD) to go beyond the limit (5 MHz to 325 MHz)"
		}
	}

	# ALTERA_HACK - custom Tcl legality check for physical parameter entry	
	# case:105299 - check to see if the fractional K lies outside the legal 0.05 - 0.95 boundaries
	# This sometimes isn't correctly handled by the computation code because of rounding issues.
	# Even when it is correctly handled, the resulting "VCO outside range" error message isn't helpful.
	if {$en_adv && $fractional_vco_multiplier} {
		set K [get_parameter_value gui_frac_multiply_factor]
		set pll_fractional_cout [get_parameter_value gui_fractional_cout]
		set frac [expr $K/pow(2, $pll_fractional_cout)]
		if {$frac < 0.05 || $frac > 0.95} {
			send_message error "The specified configuration creates a fractional multiplication factor outside of the legal range (0.05 to 0.95)"
		}
	}
	
	# set the allowable DPS range based on family 
	if {$is_nightfury} {
	set_parameter_property gui_dps_num ALLOWED_RANGES {1:7}
	} else {
	set_parameter_property gui_dps_num ALLOWED_RANGES {1:65535}
	}
	
    set MAX_OUTPUT_CLOCKS 18
    for { set i 0 } {$i < $MAX_OUTPUT_CLOCKS} {incr i} {
        if {$i < $num_count} {
            
            # Check the value in RBC
            set rbc_outclk_freq($i) "[get_parameter_value gui_output_clock_frequency$i] MHz"
            set rbc_outclk_duty($i) [get_parameter_value gui_duty_cycle$i]

            set_parameter_value output_clock_frequency$i "[get_mapped_allowed_range_value gui_actual_output_clock_frequency$i]"			
            set_parameter_value duty_cycle$i [get_parameter_value gui_duty_cycle$i]
            
            # Make sure the values pass into the rbc never exceed 6 precision
            #Here, send either the entered frequency to the RBC code, or calculate
            #the frequency using mult/div factors
            if {$en_adv} {
                set div_c [get_parameter_value gui_divide_factor_c$i]
				set vco_freq [compute_vco_frequency]
				set check_value($i) [expr {$vco_freq / $div_c}]                            
            } else {
                set check_value($i) [get_parameter_value gui_output_clock_frequency$i]
            }
            _dprint 1 "freq$i = $check_value($i)"
            set check_val($i) [precision_check $check_value($i)]
            set rbc_outclk_freq_val($i) "$check_val($i) MHz"
            #Set the phase val always in ps, but first convert from degrees if user enters ps in degs
            #set ps_units [get_parameter_value gui_ps_units$i]
			set ps_units [get_mapped_allowed_range_value gui_ps_units$i]
            if {$ps_units == "degrees"} {
                set phase_in_deg [get_parameter_value gui_phase_shift_deg$i]
                set phase_in_ps [degrees_to_ps $phase_in_deg $check_val($i)]
                set rbc_outclk_phase($i) "$phase_in_ps ps"
                #setting the actual phases
                set phase_in_deg [get_mapped_allowed_range_value gui_actual_phase_shift$i]
                set phase_in_deg [list $phase_in_deg]
		if { $phase_in_deg != {{}} } {
	                set phase_in_ps [degrees_to_ps $phase_in_deg $check_val($i)]
	                set_parameter_value phase_shift$i $phase_in_ps
		}
                #set ps [get_parameter_value phase_shift0]
                
            } else {
                set rbc_outclk_phase($i) "[get_parameter_value gui_phase_shift$i] ps"
                set ps_with_units [get_mapped_allowed_range_value gui_actual_phase_shift$i]
                if {[regexp {([0-9.]+)} $ps_with_units phase_value]} {
                	set_parameter_value phase_shift$i $phase_value
		} 
            }

            _dprint 1 "phase$i = $rbc_outclk_phase($i)"
            
 
        } else {

            # Check the value in RBC
            set rbc_outclk_freq($i) "0 MHz"
            set rbc_outclk_phase($i) "0 ps"
            set rbc_outclk_duty($i) 50
            
            # Set the value in the HDL
            set_parameter_value output_clock_frequency$i "0 MHz"
            set_parameter_value phase_shift$i "0 ps"
            set_parameter_value duty_cycle$i 50
            
            # Make sure the values pass into the rbc never exceed 6 precision
            set rbc_outclk_freq_val($i) "0 MHz"
        }
    }

    
    ##################################################
    # Get the reference clock frequency legal values
    ##################################################
    set reference_list [list $device_part $fractional_vco_multiplier $pll_type $channel_spacing]
    set result [my_set_rbc_check REFERENCE_CLOCK_FREQUENCY $reference_list]
    #strip off {{ and }} from RBC
    regsub {([\{]+)} $result {} result
    regsub {([\}]+)} $result {} result
    #split each refclk freq returned
    set compare_range_min [lindex [split $result "MHz.."] 0]
    set compare_range_max [lindex [split $result "MHz.."] 6]
    send_message info "The legal reference clock frequency is $result"	
    if { $ref_clk < $compare_range_min || $ref_clk > $compare_range_max} {
        send_message error "$ref_clk MHz is illegal reference clock frequency"
    } else {		
        #############################################
        #Validate refclk switchover if enabled #####
        ############################################# 
        refclk_switchover_elaboration_validation "validation" $device
        if {$en_refclk_switch} {
          if { $ref_clk1 < $compare_range_min || $ref_clk1 > $compare_range_max } {
                send_message error "Clock 'refclk1' has an illegal reference clock frequency of: $ref_clk1 MHz"
             }
        }

		##################################################
		# Get the output clock frequency legal values
		##################################################
		## Check the legality for desired output clock frequency
		for { set i 0 } {$i < 18} {incr i} {
			for { set k 0 } {$k < $i} {incr k} {
				lappend outclks($i) [get_parameter_value output_clock_frequency$k]
			}
			# Skip $i itself
			for { set j [expr $i+1] } {$j < $MAX_OUTPUT_CLOCKS} {incr j} {
				lappend outclks($i) "0 MHz"
			}

			if {$i < $num_count} {
				set return_array [get_advanced_pll_legality_solved_legal_pll_values $device_part $ref_clk $rbc_outclk_freq_val($i) $fractional_vco_multiplier $channel_spacing $pll_type $outclks($i)]
		#        _dprint 1 "ret = $return_array"
				set outclk_list { }
				if {[string match -nocase "*error*" $return_array]} {
					#Set the return_array to empty signifying no valid frequencies returned
					set return_array "{}"
					send_message error "Please specify correct output frequencies."
					return -1
				} else {
					#extract frequency
					foreach freq $return_array {
						regexp {([0-9.]+)} $freq value 
						lappend outclk_list $value
					}
				}

				set sorted_outclks [lsort -real $outclk_list]
				set outclk_str($i) ""
				foreach f $sorted_outclks {
					lappend outclk_str($i) "$f MHz"
				}
				
				#Prompt error message when frequency is illegal and return 'N/A' as result
				if ![info exist outclk_str($i)] {
					set outclk_str($i) "N/A"
					send_message error "Please specify correct output frequencies."
					return -1
				}		

				# Update the ALLOWED_RANGES for output clock frequency based on the RBC return value
				update_allowed_ranges_for_output_clock_frequency $i $outclk_str($i)

			} elseif {$i == $num_count} {
				# Recompute frequencies using the actual frequencies
				for { set val 0 } {$val < $num_count} {incr val} {
					for { set cal 0 } {$cal < $MAX_OUTPUT_CLOCKS} {incr cal} {
						if {$cal != $val} {
							lappend recalculate($val) [get_parameter_value output_clock_frequency$cal]
						}
					}
			
					set return_array [get_advanced_pll_legality_solved_legal_pll_values $device_part $ref_clk [get_parameter_value output_clock_frequency$val] $fractional_vco_multiplier $channel_spacing $pll_type $recalculate($val)]
					#extract frequency
					set outclk_list {}
					foreach freq $return_array {
						regexp {([0-9.]+)} $freq value 
						lappend outclk_list $value
					}

					set sorted_outclks [lsort -real $outclk_list]
					set outclk_str($val) ""
					foreach f $sorted_outclks {
						lappend outclk_str($val) "$f MHz"
					}
				
					#Prompt error message when frequency is illegal and return 'N/A' as result
					if ![info exist outclk_str($val)] {
						set outclk_str($val) "N/A"
						send_message error "Please specify correct output frequencies."
						return -1
					}
					
					# Update the ALLOWED_RANGES for output clock frequency based on the RBC return value
					update_allowed_ranges_for_output_clock_frequency $val $outclk_str($val)
				}
				for { set another_val $num_count} {$another_val < 18} {incr another_val} {
					map_allowed_range gui_actual_output_clock_frequency$another_val [get_mapped_allowed_range_value gui_actual_output_clock_frequency$another_val]
				}
			} else {
				# must make sure any string parameter that will receive an allowed range when enabled, also has one at start-up
				map_allowed_range gui_actual_output_clock_frequency$i [get_mapped_allowed_range_value gui_actual_output_clock_frequency$i]
			} 
		}
		##################################################
		# Get the phase shift legal values
		##################################################
		if {!$en_adv} {
			## Check the legality for desired output clock frequency
			set intermediate_legalized_phase ""
			for { set i 0 } {$i < $MAX_OUTPUT_CLOCKS} {incr i} {lappend intermediate_legalized_phase "0 ps"}
			
			for { set i 0 } {$i < $MAX_OUTPUT_CLOCKS} {incr i} {
				# Test against all legalized output clocks, every time (could this go wrong if all 18 counters were in use?)
				for { set m 0 } {$m < [expr $MAX_OUTPUT_CLOCKS - 1]} {incr m} {
					lappend phase_clks($i) [get_parameter_value output_clock_frequency$m]
				}
				for { set k 0 } {$k < $i} {incr k} {
					lappend phase($i) [lindex $intermediate_legalized_phase $i]
				}
				# Skip $i itself
				for { set j [expr $i + 1] } {$j < $MAX_OUTPUT_CLOCKS} {incr j} {
					lappend phase($i) "0 ps"
				}
				if {$i < $num_count} {
					set return_phase_array [get_advanced_pll_legality_solved_legal_phase_values $device_part $ref_clk [get_parameter_value output_clock_frequency$i]  $fractional_vco_multiplier $channel_spacing $pll_type $phase_clks($i) $phase($i) $rbc_outclk_phase($i)]
					#extract frequency
					set outclk_phase_list {}
					foreach freq $return_phase_array {
						regexp {([-0-9.]+)} $freq value
						lappend outclk_phase_list $value
					}

					set sorted_outclk_phases [lsort -real $outclk_phase_list]
					set outclk_phase_str($i) ""
					foreach f $sorted_outclk_phases {
						lappend outclk_phase_str($i) "$f ps"
					}
					#Prompt error message when phase shift is illegal and return 'N/A' as result
					if ![info exist outclk_phase_str($i)] {
						set outclk_phase_str($i) "N/A"
						send_message error "Please specify correct phase shifts."
						return -1
					}
					# Update the ALLOWED_RANGES for actual phase shift based on the RBC return value
					update_allowed_ranges_for_output_phase_shift $i $outclk_phase_str($i) 
					
					# If the phase shift is specified in degrees, we need to store the intermediate legalized phase shift in ps.
					# The next legalization step needs the correct legalized value in ps.  If instead we store the legalized value
					# in (rounded) degrees, and convert back to ps for the next step, the computation code could error out (case:129451)
					set ps_units [get_mapped_allowed_range_value gui_ps_units$i]
					set desired_phase_in_ps [get_parameter_value gui_phase_shift$i]
					if {$ps_units == "degrees"} {
						set desired_phase_in_ps [degrees_to_ps [get_parameter_value gui_phase_shift_deg$i] [get_parameter_value output_clock_frequency$i]]
					}
					lset intermediate_legalized_phase $i [find_closest_value $desired_phase_in_ps $outclk_phase_str($i)] 
					
				} elseif {$i == $num_count} {
					for { set val 0 } {$val < $num_count} {incr val} {
						for { set cal 0 } {$cal < 17} {incr cal} {
							lappend recalculate_clks($val) [get_parameter_value output_clock_frequency$cal]
							lappend recalculate_phase($val) [lindex $intermediate_legalized_phase $cal]
						}
						set return_phase_array [get_advanced_pll_legality_solved_legal_phase_values $device_part $ref_clk [get_parameter_value output_clock_frequency$val] $fractional_vco_multiplier $channel_spacing $pll_type $recalculate_clks($val) $recalculate_phase($val) [get_parameter_value phase_shift$val]]
						set phase_list {}
						if {[string match -nocase "*error*" $return_phase_array]} {
							#Set the return_array to empty signifying no valid frequencies returned
							set return_phase_array "{}"
							send_message error "Please specify correct phase shifts."
							return -1
						} else {
							 
							#extract phase
							foreach freq $return_phase_array {
								regexp {([-0-9.]+)} $freq value 
								lappend phase_list $value
							}
						}
						set sorted_phases [lsort -real $phase_list]
						foreach f $sorted_phases {
							lappend phase_str($val) "$f ps"
						}
						#Prompt error message when phase shift is illegal and return 'N/A' as result
						if ![info exist phase_str($val)] {
							set phase_str($val) "N/A"
							send_message error "Please specify correct phase shifts."
							return -1
						}
						# Update the ALLOWED_RANGES for atual phase shift based on the RBC return value
						update_allowed_ranges_for_output_phase_shift $val $phase_str($val) 
					}
					for { set another_val $num_count} {$another_val < 18} {incr another_val} {
						map_allowed_range gui_actual_phase_shift$another_val [get_mapped_allowed_range_value gui_actual_phase_shift$another_val]
					}
				} else {
					# must make sure any string parameter that will receive an allowed range when enabled, also has one at start-up
					map_allowed_range gui_actual_phase_shift$i [get_mapped_allowed_range_value gui_actual_phase_shift$i]
				}		
			}
		} else {
		## Check the legality given the user-specified VCO frequency
		# ALTERA_HACK - custom Tcl legality check for physical parameter entry	
		
			# Compute the legal phase shift step in ps
			set vco_freq [compute_vco_frequency]
			set phase_step [expr (1e6 / $vco_freq) / 8]		
		
			for { set i 0 } {$i < $num_count} {incr i} {
	
				# Determine C-counter divide factor and user's desired phase shift in ps
				set c_divide_factor [get_parameter_value gui_divide_factor_c$i]
				set desired_phase_shift 0	
				set phase_units [get_mapped_allowed_range_value gui_ps_units$i]
				if {$phase_units == "degrees"} {
					set desired_phase_shift [degrees_to_ps [get_parameter_value gui_phase_shift_deg$i] [expr double($vco_freq)/$c_divide_factor]]
				} else {
					set desired_phase_shift [get_parameter_value gui_phase_shift$i]
				}
				
				# Calculate the legal phase shifts closest to the user's desired phase shift 
				set num_steps [expr double($desired_phase_shift)/$phase_step + 0.000001]
				set start_mult 0
				set end_mult 0
				
				# note - num_drop_down should be even
				set num_drop_down 6
				if {$num_steps < 2} {
					set start_mult 0
					set end_mult   [expr int( $num_drop_down-1 )]
				} elseif {$num_steps > $c_divide_factor*8-$num_drop_down/2} {
					set start_mult [expr int( $c_divide_factor*8-$num_drop_down)]
					set end_mult   [expr int( $c_divide_factor*8-1)]			
				} else {
					set start_mult [expr int( floor($num_steps) - ($num_drop_down/2 - 1) )]
					set end_mult   [expr int( ceil($num_steps) + ($num_drop_down/2 - 1) )]
				}
				
				set legal_phase_list ""
				for {set j $start_mult} {$j <= $end_mult} {incr j} {
					# floor is used to match the output of the legalization call
					set legal_phase [expr int( floor($j * $phase_step) )]
					lappend legal_phase_list "$legal_phase ps"
				}
				
				# Map the computed list of legal phase shifts to the GUI drop-down menu
				update_allowed_ranges_for_output_phase_shift $i $legal_phase_list
				#map_allowed_range gui_actual_phase_shift$i [get_mapped_allowed_range_value gui_actual_phase_shift$i]
			}
								
			
		}
				
		########################################	
		##  Update physical parameters table  ##
		########################################     
		# Updating the physical parameters now occurs by default
		set t_total 0
		set start_t_total [clock clicks -milliseconds]
		reconfig_param_handler
		set end_t_total [clock clicks -milliseconds]
		set t_total [expr {$end_t_total - $start_t_total}]
		_dprint 1  "totaltimeRECONF = $t_total"	
				
		################################	
		##  Output counter cascading  ##
		################################
		
		# NOTE:
		# This code was written to support counter cascading in the frequency-entry mode of the MegaWizard
		# This was eventually abandoned for 28 nm, but the code has been left in place for future support.
		
		set MAX_DIV_FACTOR 512
		
		#Obtain the VCO frequency
		set cascade_message_flag 0
		regexp {([-0-9.]+)} [get_parameter_value pll_output_clk_frequency] vco_freq
		for { set i 0 } {$i < $num_count} {incr i} {	

			regexp {([-0-9.]+)} [get_parameter_value gui_output_clock_frequency$i] outclk_freq
			set div_factor [expr round([expr $vco_freq / $outclk_freq])]
			if {!$cascade_message_flag && $div_factor > $MAX_DIV_FACTOR} {
			
				# Determine how many additional cascade counters are necessary to achieve this output
				#set num_cascade($i) [how_many_cascade_counters $div_factor $MAX_DIV_FACTOR]
				#incr num_cascade_counters $num_cascade($i)
				
				# Inform the user
				send_message info "Lower frequency output clocks can be achieved by cascading PLL output counters. Enable physical output clock parameters to access this feature."
				set cascade_message_flag 1
				
			} else {
				#set num_cascade($i) 0
			}
		} 
		if {$num_cascade_counters > 0} {

			#Re-set the number of clocks dropdown list accordingly
			#(Also handles the problem case where the num_count exceeds the number available)
			set_number_of_clocks $device $num_cascade_counters
			
			#Just for consistency
			set use_non_generic_pll 1
		}
		# Set the number_of_cascade_counters parameter to make it visible in the elaboration callback
		set_parameter_value number_of_cascade_counters $num_cascade_counters
		
		# Support for "Enable advanced parameters"
		set uses_advanced_cascade false
		if {$en_adv} {
			for { set i 0 } {$i < $num_count} {incr i} {
				set used_as_cascade [get_parameter_value gui_cascade_counter$i]
				set uses_advanced_cascade [expr {($used_as_cascade == "true") ? "true" : $uses_advanced_cascade}]
				
				# Set the c_cnt_in_src parameter of the next counter
				if {$used_as_cascade && $i != ($num_count - 1)} { 
					set_parameter_value c_cnt_in_src[expr $i+1] "cscd_clk"
				} else {
					set_parameter_value c_cnt_in_src[expr $i+1] "ph_mux_clk"
				}
				
				# Restore the output clock frequency parameters to their correct cascade values
				# if {$used_as_cascade && $i != ($num_count - 1)} {
					# set upstream_counter_frequency [get_parameter_value output_clock_frequency$i]
					# regexp {([-0-9.]+)} $upstream_counter_frequency upstream_counter_frequency_unitless
					# set downstream_div_factor [get_parameter_value gui_divide_factor_c[expr $i + 1]]
					# set cascade_frequency [expr $upstream_counter_frequency_unitless / $downstream_div_factor]
					# set_parameter_value output_clock_frequency[expr $i + 1] "$cascade_frequency MHz"
				# } 
			}
		}
		
		# Issue a warning if the PLL is used as an upstream cascade AND has cascaded counters
		if {[get_parameter_value gui_enable_cascade_out]} {
			if {$num_cascade_counters > 0 || $uses_advanced_cascade} {
				send_message warning "Only non-cascade output clocks can be used to connect with a downstream PLL."
			}        
		}
		
		# cascading parameters need to update to match the selected cascading source
		update_cascading_parameters $device

		
		###############	
		##  Tidy up  ##
		###############	
		
		#setting color coded warning message indicating desired vs actual PLL settings
		set_warning_label
		
		set end_v_total [clock clicks -milliseconds]
		set r_total [expr {$end_v_total - $start_v_total}]
		_dprint 1  "generic_total = $generic_total"
		_dprint 1  "generic_total_time = $generic_total_time"
		_dprint 1  "total validation time = $r_total"
	}
}

proc set_warning_label {} {

    set num_clocks [get_parameter_value gui_number_of_clocks]
    #accumulate the differencees over all clocks to see if either
    #can't be implemented
    set diff 0 
    for { set i 0 } {$i < $num_clocks} {incr i} {
        
        set en_adv [get_parameter_value gui_en_adv_params]
        set output_freq_actual_noMHz [get_parameter_value output_clock_frequency$i]
        regsub {([ MHz]+)} $output_freq_actual_noMHz {} output_freq_actual_noMHz
        if {$en_adv} {
            set user_mult [get_parameter_value gui_multiply_factor]
			set user_div_n [get_parameter_value gui_divide_factor_n]
            set user_div_c [get_parameter_value gui_divide_factor_c$i]
			set user_div [expr {$user_div_n * $user_div_c}]
            set user_frac [get_parameter_value gui_frac_multiply_factor]
            set actual_mult [get_parameter_value gui_actual_multiply_factor$i]
            set actual_div [get_parameter_value gui_actual_divide_factor$i]
            set actual_frac [get_parameter_value gui_actual_frac_multiply_factor$i]
            set diff [expr {$diff + abs($user_mult-$actual_mult)}]
            set diff [expr {$diff + abs($user_div-$actual_div)}]
            set diff [expr {$diff + abs($user_frac-$actual_frac)}]
        } else {
            set output_freq_user_noMHz [get_parameter_value gui_output_clock_frequency$i]
            regsub {([ MHz]+)} $output_freq_user_noMHz {} output_freq_user_noMHz 
            set diff [expr {$diff + abs($output_freq_user_noMHz-$output_freq_actual_noMHz)}]
        }

        set phase_shift_actual_nops [get_parameter_value phase_shift$i]
        regsub {([ ps]+)} $phase_shift_actual_nops {} phase_shift_actual_nops 
        set ps_units [get_parameter_value gui_ps_units$i]
        if {$ps_units == "ps"} {
            set phase_shift_user_nops [get_parameter_value gui_phase_shift$i]
            regsub {([ ps]+)} $phase_shift_user_nops {} phase_shift_user_nops 
            set diff [expr {$diff + abs($phase_shift_user_nops -$phase_shift_actual_nops )}]
        } else {
            set phase_shift_user_deg [get_parameter_value gui_phase_shift_deg$i]
            regsub {([ ps]+)} $phase_shift_user_deg {} phase_shift_user_deg
            set phase_shift_user_deg_to_ps [degrees_to_ps $phase_shift_user_deg $output_freq_actual_noMHz]
            regsub {([ ps]+)} $phase_shift_user_deg_to_ps {} phase_shift_user_deg_to_ps
            set diff [expr {$diff + abs($phase_shift_user_deg_to_ps-$phase_shift_actual_nops )}]
        }

    }
    if {$diff > 0} {
        send_message warning "Able to implement PLL - Actual settings differ from Requested settings"
    } else {
        send_message info "Able to implement PLL with user settings"
    }
}

proc adjust_allowed_range_of_K {} {
    set pll_fractional_cout [get_parameter_value gui_fractional_cout]
    set max_permissible_K [expr {pow(2, $pll_fractional_cout)} -1]
	set max_permissible_K [lindex [split $max_permissible_K .] 0]
	set range "1:$max_permissible_K"	
	
	set_parameter_property gui_frac_multiply_factor ALLOWED_RANGES $range
}

proc update_allowed_ranges_for_output_clock_frequency { counter_index outclk_str } {
	set en_adv [get_parameter_value gui_en_adv_params]
	set has_cascade_input 0
	set i $counter_index
	
	# Note: If advanced parameters is enabled, we only want to report frequency in the "Actual Frequency" field,
	# not the six RBC-returned values in outclk_str.
	if {$en_adv && $outclk_str != "N/A"} {
		set vco_frequency [compute_vco_frequency] 
		
		# Handle the case of cascaded output counters
		if { $i > 0 && [get_parameter_value gui_cascade_counter[expr $i - 1]] } {
			set has_cascade_input 1
			
			# Get the actual output frequency of the previous counter
			# Note that for cascade chains longer than two, we can't trust the "output_clock_frequency$i" parameter
			set counter_input_frequency [get_mapped_allowed_range_value gui_actual_output_clock_frequency[expr $i - 1]]
			regexp {([0-9.]+)} $counter_input_frequency counter_input_frequency
			
			# Compute the actual frequency
			set c_divide_factor [get_parameter_value gui_divide_factor_c$i]
			set computed_output_frequency [format_output_frequency [expr $counter_input_frequency / $c_divide_factor]]
			set actual_frequency [list "$computed_output_frequency MHz" "$computed_output_frequency MHz"]  
			# duplicating the frequency twice is a workaround for FB 107239
			
			# Pass this value to the ALLOWED_RANGES for output clock frequency
			map_allowed_range gui_actual_output_clock_frequency$i $actual_frequency
			#set user_pll_refclk_freq [get_mapped_allowed_range_value gui_actual_output_clock_frequency$i]
			
			# We will need to "lie" to the computation code about the output frequency of this counter
			# We pretend that there is no cascading, lest the computation code complain of the illegal frequency
			set fake_frequency [format "%.6f" [expr $vco_frequency / $c_divide_factor]]
			set closest_legal_value [find_closest_value $fake_frequency $outclk_str]
			set user_pll_refclk_freq $closest_legal_value
			
		# Handle the regular case	
		} else {

			# Compute the actual frequency
			set c_divide_factor [get_parameter_value gui_divide_factor_c$i]
			set computed_output_frequency [format_output_frequency [expr $vco_frequency / $c_divide_factor]]
			
			# The actual frequency may not be legal - sync up with legal returned value
			set closest_legal_value [find_closest_value $computed_output_frequency $outclk_str]
			
			# duplicating the frequency twice is a workaround for FB 107239
			set actual_frequency [list "$closest_legal_value" "$closest_legal_value"]  
	 
			# Pass this value to the ALLOWED_RANGES for output clock frequency
			map_allowed_range gui_actual_output_clock_frequency$i $actual_frequency
			set user_pll_refclk_freq [get_mapped_allowed_range_value gui_actual_output_clock_frequency$i]
		}
		
		# Set the "true" output clock frequency that will be used in subsequent RBC calls
		set_parameter_value output_clock_frequency$i $user_pll_refclk_freq

				
	} elseif {$outclk_str != "N/A"} {
	# Pass the rbc returned value to the ALLOWED_RANGES for output clock frequency
        set desired_frequency [get_parameter_value gui_output_clock_frequency$i]
        set closest_frequency [find_closest_value $desired_frequency $outclk_str]
        map_allowed_range gui_actual_output_clock_frequency$i $outclk_str $closest_frequency
		set user_pll_refclk_freq [get_mapped_allowed_range_value gui_actual_output_clock_frequency$i]
		set_parameter_value output_clock_frequency$i $user_pll_refclk_freq

	} else {
		map_allowed_range gui_actual_output_clock_frequency$i "N/A"	
		set user_pll_refclk_freq [get_mapped_allowed_range_value gui_actual_output_clock_frequency$i]
		set_parameter_value output_clock_frequency$i "0 MHz"
	}
}

proc convert_if_negative { phase_shift full_period } {
	
    # Strip units, if any
    regexp {([-0-9.]+)} $phase_shift phase_shift
	
    # This procedure assumes that the negative phase shift is between -360 and 360 degrees
    # The MegaWizard enforces this legality rule
    if {$phase_shift < 0} {
        return [expr $phase_shift + $full_period]
    } else {
        return $phase_shift
    }
}

proc find_closest_value { desired available } {
    
    set least_diff "infinity"
    set closest ""
    
    # Strip units, if any
    regexp {([0-9.]+)} $desired desired_val
    
    foreach val $available {
        regexp {([0-9.]+)} $val actual_val
        set diff [expr abs($desired_val - $actual_val)]
        if {$diff < $least_diff} {
            set closest $val
            set least_diff $diff
        }
    }
    return $closest
}

proc update_allowed_ranges_for_output_phase_shift { counter_index outclk_phase_str } { 
    if {$outclk_phase_str != "N/A"} {
        set i $counter_index
        set ps_units [get_parameter_value gui_ps_units$i]
        set en_adv [get_parameter_value gui_en_adv_params]
        
        # Figure out whether this counter's output feeds the next counter
        set is_cascade_counter [get_parameter_value gui_cascade_counter$i]
        # Figure out whether this counter is fed by a cascade input
        set is_downstream_counter false
        if {$i!= 0} {
            set is_downstream_counter [get_parameter_value gui_cascade_counter[expr $i-1]]
        }	
        
        # Phase shift in "degrees" is disabled for cascade counters in "enable advanced params" mode
        if {$ps_units == "degrees" && !($en_adv && $is_cascade_counter)} {
            #convert return_array to degree units
            set converted_array [list]
            set outclk_freq [get_parameter_value output_clock_frequency$i]
            set converted_array [ps_to_degrees $outclk_phase_str $outclk_freq]
            set desired_phase [get_parameter_value gui_phase_shift_deg$i]
            set desired_phase [convert_if_negative $desired_phase 360]
            set closest_phase [find_closest_value $desired_phase $converted_array]
            map_allowed_range gui_actual_phase_shift$i $converted_array $closest_phase
            set user_pll_refclk_phase [get_mapped_allowed_range_value gui_actual_phase_shift$i]   
            
            #degrees to ps expects a list 
            set user_pll_phase_deg [list $user_pll_refclk_phase] 
	    if { $user_pll_phase_deg != {{}} } {
	            set user_pll_refclk_phase [degrees_to_ps $user_pll_phase_deg $outclk_freq]
        	    append user_pll_refclk_phase " ps"
	    } 
            
        # Do not allow the user to specific non-zero phase shifts for counters fed by a cascade input 
        } elseif {$en_adv && $is_downstream_counter} {
            map_allowed_range gui_actual_phase_shift$i [list "0 ps"]	                   
            set user_pll_refclk_phase [get_mapped_allowed_range_value gui_actual_phase_shift$i]
        
        # Display achievable phase shifts in picoseconds        
        } else {
            set desired_phase [get_parameter_value gui_phase_shift$i]
            set closest_phase [find_closest_value $desired_phase $outclk_phase_str]
            map_allowed_range gui_actual_phase_shift$i $outclk_phase_str $closest_phase
            set user_pll_refclk_phase [get_mapped_allowed_range_value gui_actual_phase_shift$i]   
        }
        
        ##pass the rbc returned value to the ALLOWED_RANGES for phase shift
        set_parameter_value phase_shift$i $user_pll_refclk_phase
        
    } else {
        map_allowed_range gui_actual_phase_shift$i "N/A"	
        set user_pll_refclk_phase [get_mapped_allowed_range_value gui_actual_phase_shift$i]
        set_parameter_value phase_shift$i "0 ps"
    }
}

proc format_output_frequency { output_frequency } {

	set result [format "%.6f" $output_frequency]
	set result [string trimright $result 0]
	if {[string index $result end] == "."} {
		append result 0
	}
	
	return $result
}

proc copy_actual_values {} {
    
    set num_clocks [get_parameter_value gui_number_of_clocks]
    for { set i 0 } {$i < $num_clocks} {incr i} {
        #getting all the actual values
        set output_freq_actual_noMHz [get_parameter_value output_clock_frequency$i]
        regsub {([ MHz]+)} $output_freq_actual_noMHz {} output_freq_actual_noMHz
        set phase_shift_actual_nops [get_parameter_value phase_shift$i]
        regsub {([ ps]+)} $phase_shift_actual_nops {} phase_shift_actual_nops 

        #get the phase shift in degrees
        set phase_shift_actual_deg [lindex [ps_to_degrees $phase_shift_actual_nops $output_freq_actual_noMHz] 0]
        regsub {([ deg]+)} $phase_shift_actual_deg {} phase_shift_actual_deg

        set_parameter_value gui_output_clock_frequency$i $output_freq_actual_noMHz
        
        set_parameter_value gui_phase_shift$i $phase_shift_actual_nops
        set_parameter_value gui_phase_shift_deg$i $phase_shift_actual_deg
            set phase_shift_user_deg [get_parameter_value gui_phase_shift_deg$i]
        _dprint 1 "user = $phase_shift_user_deg\n"
        
    }
}

# ---------------------------------------------------------------------------------------------- #
# This function sets the number of output clocks available to the user from the drop-down menu.  #
# The number of output clocks may decrease if counters are used for cascading.                   #
# ---------------------------------------------------------------------------------------------- #
proc set_number_of_clocks {device num_cascade_counters} {
	
	# Set default number of clocks based on device family
	set is_nightfury [is_nightfury_device $device]
    if {$device == "Stratix V" || $device == "Arria V GZ"} {
        set legal_number_of_clocks {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}
		set legal_c_counters {"C0" "C1" "C2" "C3" "C4" "C5" "C6" "C7" "C8" "C9" "C10" "C11" "C12" "C13" "C14" "C15" "C16" "C17" "All C" "M"}
	} elseif {$device == "Arria V"} {
        set legal_number_of_clocks {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}
		set legal_c_counters {"C0" "C1" "C2" "C3" "C4" "C5" "C6" "C7" "C8" "C9" "C10" "C11" "C12" "C13" "C14" "C15" "C16" "C17" "All C" "M"}	
    } elseif {$device == "Cyclone V" || $is_nightfury} {
        set legal_number_of_clocks {1 2 3 4 5 6 7 8 9}	
		set legal_c_counters {"C0" "C1" "C2" "C3" "C4" "C5" "C6" "C7" "C8" "All C" "M"}
    } else {
		set legal_number_of_clocks {1}
		set legal_c_counters {"C0" "M"}
    }
	
	# Truncate the default clock list to reflect C-counters used up by cascading
	if {$num_cascade_counters > 0} {
		set legal_number_of_clocks [lrange $legal_number_of_clocks 0 end-$num_cascade_counters]
		set legal_c_counters [lrange $legal_c_counters 0 end-$num_cascade_counters]
	}
	
	set num_clocks [get_parameter_value gui_number_of_clocks]
	set allowed_num_clocks [lindex $legal_number_of_clocks end]
    if {$num_clocks > $allowed_num_clocks} {
		# Handle the case where the user has requested more outclks than are actually available (due to cascading)
		send_message error "Only $allowed_num_clocks output clocks are available due to counter cascading."
	} else {
		# Set allowed range
		map_allowed_range gui_number_of_clocks $legal_number_of_clocks	
		map_allowed_range gui_dps_cntr $legal_c_counters
	}
}

proc my_terminate_port { port_name termination_value direction } {
	ipcc_set_port_termination $port_name $termination_value $direction

}

proc get_advanced_pll_legality_solved_legal_pll_values {device_part ref_clk rbc_outclk_freq fractional_vco_multiplier channel_spacing pll_type outclks} {
	set solved_freqs [list]
	set result_out [list]
	set return_array [list]
	lappend param_args $device_part
	lappend param_args "$ref_clk MHz"
	lappend param_args $rbc_outclk_freq
	lappend param_args "0 ps"
	lappend param_args 50
	lappend param_args $fractional_vco_multiplier
	lappend param_args $pll_type
	lappend param_args $channel_spacing
	for {set solved_clock_index 0} {$solved_clock_index < [llength $outclks]} {incr solved_clock_index} {
		set solved_freq [lindex $outclks $solved_clock_index]
		lappend param_args "$solved_freq"
		lappend param_args "0 ps"
		lappend param_args 50
	}

  	#output clock frequency rules
	set result_out [my_set_rbc_check OUTPUT_CLOCK_FREQUENCY $param_args]
	#strip off {{ and }} from RBC
	regsub {([\{]+)} $result_out {} result_out
	regsub {([\}]+)} $result_out {} result_out
	#split each refclk freq returned
	set return_array [split $result_out |]

	return $return_array
}
proc precision_check {params} {
	set output_0 [lindex [split $params .] 0]
	set output_1 [lindex [split $params .] 1]
	if {[string length $output_1] > 6} {
		set first_val [expr $params - $output_0]
		set second_val [expr {int([expr $first_val * 1000000])}]
		set third_val [expr $second_val/1000000.0]
		set forth_val [expr $output_0 + $third_val]
	} else {
		set forth_val $params
	}
   # _dprint 1 $forth_val 
	return $forth_val
}
proc get_advanced_pll_legality_solved_legal_phase_values {device_part ref_clk rbc_outclk_freq fractional_vco_multiplier channel_spacing pll_type outclks phase rbc_outclk_phase} {
	set solved_freqs [list]
	set result_out [list]
	set return_array [list]
	lappend phase_args $device_part
	lappend phase_args "$ref_clk MHz"
	lappend phase_args $rbc_outclk_freq
	lappend phase_args $rbc_outclk_phase
	lappend phase_args 50
	lappend phase_args $fractional_vco_multiplier
	lappend phase_args $pll_type
	lappend phase_args $channel_spacing
	set width [llength $outclks]

	for {set solved_clock_index 0} {$solved_clock_index < [llength $outclks]} {incr solved_clock_index} {
		set solved_freq [lindex $outclks $solved_clock_index]
		set solved_phase [lindex $phase $solved_clock_index]
		lappend phase_args "$solved_freq"
		lappend phase_args $solved_phase
		lappend phase_args 50
	}

  	#output clock frequency rules
	set result_out [my_set_rbc_check PHASE_SHIFT $phase_args]
	#strip off {{ and }} from RBC
	regsub {([\{]+)} $result_out {} result_out
	regsub {([\}]+)} $result_out {} result_out
	#split each refclk freq returned
	set return_array [split $result_out |]
	return $return_array
}

# --------------------------------------------------------------------------------------------- #
# This function determines how many cascaded c-counters (if any) are needed                     #  
# --------------------------------------------------------------------------------------------- #
proc how_many_cascade_counters {div_factor max_div_factor} {
	
	set num_cascade 0
	while {$div_factor > $max_div_factor} {
		set x [greatest_divisor_less_than_n $div_factor $max_div_factor]		
		if {$x == 1} {
			# Handle the case where div_factor has a prime factor greater than max_div_factor
			# The PLL computation code should ensure that this never happens.
			send_message error "Requested settings cannot be implemented using output counter cascading.  Please enter legal output frequencies."	
			return 1000 
		}		
		# update 
		set div_factor [expr $div_factor / $x]
		incr num_cascade
	}	
	return $num_cascade
}

proc greatest_divisor_less_than_n {val n} {	
	# loop is guaranteed to terminate if n reaches 1
	while {1} {
		# is val divisible by n?
		if {[expr $val % $n] == 0} {
			return $n
		} else {
			# if not, try n-1
			incr n -1
		}
	}
}

proc degrees_to_ps {phase_array freq} {
    
    set return_phase_array [list]
    foreach phase_val $phase_array {
        regexp {([-0-9.]+)} $phase_val phase_value 
        regexp {([-0-9.]+)} $freq freq_value 
        #convert negative phase shift to positive phase shift
        if {$phase_value < 0} {
            set phase_value [expr {360 - abs($phase_value)}]
        }
        set phase_in_ps [expr {$phase_value /(360*$freq_value)}]
        #convert to ps
        set phase_in_ps [expr {$phase_in_ps * 1000000.0}]
        set phase_in_ps [expr {round($phase_in_ps)}]
        lappend return_phase_array $phase_in_ps
    }
    return $return_phase_array

}
proc ps_to_degrees {phase_array freq} {
    set return_phase_array [list]
    foreach phase_val $phase_array {
        regexp {([-0-9.]+)} $phase_val phase_value 
        regexp {([-0-9.]+)} $freq freq_value 
        set phase_in_deg [expr {$phase_value*360.0*$freq_value/1000000.0}]
        set phase_in_deg_int [expr {round($phase_in_deg)}]
        set phase_in_deg_mod [expr {$phase_in_deg_int%360}]
		set phase_in_deg [expr $phase_in_deg + $phase_in_deg_mod - $phase_in_deg_int]
		set phase_in_deg [format "%.1f" $phase_in_deg]
        set phase_in_deg "$phase_in_deg deg"
        lappend return_phase_array $phase_in_deg
    }
    return $return_phase_array


}
proc is_legal_range {value} {
    
}

# +-----------------------------------
# | 
# | Callback function when generating variation file
# | This function should generate a QIP file based on pll compensation mode
# | 
# +-----------------------------------
proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"
	global five_series_phys_params_list
	global ten_series_phys_params_list

	#declare ports and mappings for generation callback
	interface_ports_and_mapping generation
	ipcc_set_module altera_pll
	
	#create a temp directory
	set tmpdir [create_temp_file {}]
	_dprint 1 "Using temporary directory $tmpdir for generate_synth"

	# generate HDL wrapper that instantiate altera_pll
	generate_hdl_wrapper $name $tmpdir
	add_fileset_file ${name}.v VERILOG PATH ${tmpdir}${name}.v
	
	# generate SDC file for altera_pll
	set device [get_parameter_value device_family]
	set is_nightfury [is_nightfury_device $device]
	if {0 && $is_nightfury} {
		generate_sdc_related_files $name $tmpdir
	}

	# generate QIP file with proper assignments created for operation mode	
	set op_mode [get_mapped_allowed_range_value gui_operation_mode]
	set pll_mode [get_parameter_value gui_pll_mode]
	if {$op_mode == "direct" || $op_mode == "normal" || $op_mode == "source synchronous" || $op_mode == "zero delay buffer" || $op_mode == "external feedback" || $op_mode == "lvds" || $pll_mode == "Fractional-N PLL"} {
		set qip_text [generate_qip $name]
	} else {
		set qip_text " "
	}
	add_fileset_file ${name}.qip OTHER TEXT "$qip_text"
	#common_add_fileset_files {S5 ALL_HDL ALTERA_PLL} {QIP}

	# Generate MIF File if enabled
	set mif_enabled [get_parameter_value gui_mif_generate]
	if {$mif_enabled == "true"} {
		# Remove the "_0002" ending so MIF name matches user's desired PLL name
		# Can't reg ex since ip generate doesn't add _0002 and megawiz does
		set mif_extract [string range $name end-4 end]
		set mif_checking [string match $mif_extract "_0002"]
		if {$mif_checking} {
		set mif_name [string range $name 0 end-5]
		} else {
		set mif_name $name
		}
		# regexp {(.*)_0002} $name temp mif_name
		set mif_filename "${mif_name}.mif"
		set mif_filelocation [create_temp_file $mif_filename]
		send_message info "Generating MIF file $mif_filename"
	
		if {$is_nightfury} {
			set mif_success [generate_mif_file $ten_series_phys_params_list $mif_filelocation]
		} else {
			set mif_success [generate_mif_file $five_series_phys_params_list $mif_filelocation]
		}
	
		add_fileset_file ${mif_name}.mif MIF PATH ${mif_filelocation}
	}
}

# +-----------------------------------
# | 
# | This function will generate a QIP file with all the QSF assignments defined
# | for the use of PLL compensation mode.  This will be called during IP generate
# | 
# +-----------------------------------
proc generate_qip {name} {
	set op_mode [get_mapped_allowed_range_value gui_operation_mode]
	set outputname $name
	set bracket_open "\["
	set value "0"
	set bracket_close "\]"
	set extract [string range $outputname end-4 end]
	set checking [string match $extract "_0002"]

	if {$checking} {
		set design [string range $outputname 0 end-5]
	} else {
		set design $outputname
	}	
	set to_path "*$outputname*|altera_pll:altera_pll_i*|*"
	set path "*$outputname*|altera_pll:altera_pll_i*|*"
	set chnl_spacing [get_parameter_value gui_channel_spacing]
	set pll_mode [get_parameter_value gui_pll_mode]
	set auto_reset_mode [get_parameter_value gui_pll_auto_reset]
	set bandwidth_mode [get_parameter_value gui_pll_bandwidth_preset]
	set result ""
	if {$op_mode == "direct"} {
		set operation "DIRECT"
	} elseif {$op_mode == "normal"} {
		set operation "NORMAL"
	} elseif {$op_mode == "source synchronous"} {
		set operation "\"SOURCE SYNCHRONOUS\""
	} elseif {$op_mode == "external feedback"} {
		set operation "\"EXTERNAL FEEDBACK\""
	} elseif {$op_mode == "zero delay buffer"} {
		set operation "\"ZERO DELAY BUFFER\""
	} elseif {$op_mode == "lvds"} {
		set operation "\"LVDS\""
	}
	if {$op_mode == "lvds" || $op_mode == "direct" || $op_mode == "normal" || $op_mode == "source synchronous" || $op_mode == "external feedback" || $op_mode == "zero delay buffer"} {
	    append result "set_instance_assignment -name PLL_COMPENSATION_MODE $operation -to \"$to_path\"\n"
    } else {
	    append result " \n"
    }
	
    if {$pll_mode == "Fractional-N PLL"} {
	    append result "set_instance_assignment -name PLL_CHANNEL_SPACING \"$chnl_spacing KHz\" -to \"$to_path\"\n"
    } else {
	    append result " \n"
    }
    if {$auto_reset_mode == "Off"} {
		set auto_rst_mode "OFF"
	} else {
		set auto_rst_mode "ON"
	}
	if {$bandwidth_mode == "Auto"} {
		set bandwidth_settings "AUTO"
	} elseif {$bandwidth_mode == "Low"} {
		set bandwidth_settings "LOW" 
	} elseif {$bandwidth_mode == "High"} {
		set bandwidth_settings "HIGH"
	} elseif {$bandwidth_mode == "Medium"} {
		set bandwidth_settings "MEDIUM"
	}
	append result "set_instance_assignment -name PLL_AUTO_RESET $auto_rst_mode -to \"$path\"\n"
	append result "set_instance_assignment -name PLL_BANDWIDTH_PRESET $bandwidth_settings -to \"$path\"\n"
	return $result
}

# +-----------------------------------
# | 
# | Generate an HDL wrapper from static ports and parameter, and from the mapping data
# | 
# +-----------------------------------
proc generate_hdl_wrapper {output_name path_name} {
	global ipcc_l_mapped_ports	;# raw port mapping data
	global ipcc_module	;# top-level module name
	
	set hdl_params [ipcc_get_hdl_params]
	set hdl_file "$path_name${output_name}.v"	;# Verilog only for wrapper
	_dprint 1 "Module name: $ipcc_module for generate_hdl_wrapper"
	
	if [ catch {open $hdl_file w} fid ] {
		send_message error "generate_hdl_wrapper{}: Couldn't open file '$hdl_file' for writing: $fid"
	} else {
		#send_message info "generate_hdl_wrapper{}: writing '$hdl_file'"
		puts $fid "`timescale 1ns/10ps"
		puts $fid "module  ${output_name}("

		set line_cnt 0
		
		# generate the wrapper module declaration, grouped by interface
		foreach interface [get_interfaces] {
			set if_comment "\n\t// interface '$interface'"	;# save interface name for HDL
			foreach port [get_interface_ports $interface] {
				if {$line_cnt > 0} {
					puts -nonewline $fid ",\n"	;# add ',' at end of previous port name declaration
				}
				incr line_cnt
				if {[string length $if_comment] > 0} {
					puts $fid "$if_comment"
					set if_comment ""
				}

				# generate HDL port declaration
				set port_direction [string tolower [get_port_property $port DIRECTION]]
				set port_width [expr [get_port_property $port WIDTH_VALUE] - 1]
				if {$port_direction == "bidir"} {
					set port_direction "inout"
				}
				if {$port_width == 0} {
					puts -nonewline $fid "\t$port_direction wire $port"
				} else {
					puts -nonewline $fid "\t$port_direction wire \[${port_width}:0\] $port"
				}
			}
		}
		puts $fid "\n);\n"
		
		# If the PLL uses counter cascading, create a wire. 
		set uses_advanced_cascade false
		if {[get_parameter_value gui_en_adv_params]} {			
			set num_count [get_parameter_value gui_number_of_clocks]
			for {set i 0} {$i < $num_count} {incr i} {
				if {[get_parameter_value gui_cascade_counter$i]} {
					set uses_advanced_cascade true
					break
				}
			}
		}
		set num_cascade [get_parameter_value number_of_cascade_counters]
		if { $uses_advanced_cascade || $num_cascade > 0 } {
			puts $fid "\twire output_unavailable;"
		}

		# generate sub-module instantiation, parameters first
		set line_cnt 0
		puts $fid "\t$ipcc_module #("
		foreach param [ipcc_get_hdl_params] {
			if {$line_cnt > 0} {
				puts -nonewline $fid ",\n"
			}
			incr line_cnt
			set p_value [get_parameter_value $param]
			set p_type [get_parameter_property $param TYPE]
			if {[regexp -nocase {^(string|boolean)} $p_type ] } {
				puts -nonewline $fid "\t\t.$param\(\"${p_value}\"\)"
			} else {
				puts -nonewline $fid "\t\t.$param\(${p_value}\)"
			}
		}
		puts -nonewline $fid "\n\t)"

		set line_cnt 0
		puts $fid " ${ipcc_module}_i ("
		array set mapped_vlg_ports [ipcc_get_hdl_ports]
		#send_message info "hdl write{indices}: [array names mapped_vlg_ports]"
		foreach port [array names mapped_vlg_ports] {
			#send_message info "hdl write: $port <-> $mapped_vlg_ports($port)"
			if {$line_cnt > 0} {
				puts -nonewline $fid ",\n"
			}
			incr line_cnt
			puts -nonewline $fid "\t\t.$port\t"
			if {[string compare $port outclk] == 0} {
				set outclk_mapped_ports [get_outclk_mapped_ports $mapped_vlg_ports($port)]
				puts -nonewline $fid "($outclk_mapped_ports)"
			} else {
				puts -nonewline $fid "($mapped_vlg_ports($port))"
			}

		}
		puts $fid "\n\t);"
		puts $fid "endmodule\n"
		close $fid
	}
	return $hdl_file
}

# +-----------------------------------
# | 
# | Generate an SDC and related files from static the parameter
# | 
# +-----------------------------------
proc generate_sdc_related_files {output_name path_name} {
	global ipcc_l_mapped_ports	;# raw port mapping data
	global ipcc_module	;# top-level module name
	
	############################################
	# First dynamically create the parameters.tcl
	
	set hdl_params [ipcc_get_hdl_params]
	set parameters_tcl_file "$path_name${output_name}_parameters.tcl"	;# parameters.tcl file
	_dprint 1 "Module name: $ipcc_module for generate_sdc_related_files"
	
	if {[ catch {open $parameters_tcl_file w} fid ]} {
		send_message error "generate_sdc_related_files{}: Couldn't open file '$parameters_tcl_file' for writing: $fid"
	} else {
		#send_message info "generate_sdc_related_files{}: writing '$parameters_tcl_file'"
		
		# Get non-counter specific PLL parameters
		set number_of_clocks [get_parameter_value gui_number_of_clocks]
		if {[get_parameter_value m_cnt_bypass_en] == "true"} {
			set mcnt 1
		} else {
			set mcnt [expr [get_parameter_value m_cnt_hi_div] + [get_parameter_value m_cnt_lo_div]]
		}
		if {[get_parameter_value n_cnt_bypass_en] == "true"} {
			set ncnt 1
		} else {
			set ncnt [expr [get_parameter_value n_cnt_hi_div] + [get_parameter_value n_cnt_lo_div]]
		}
		
		# Determine instance name
		if {[regexp {([0-9a-zA-Z]+)\_[0-9]+$} $output_name instance_name instance_name]} {
			set core_name ${instance_name}_inst
		} else {
			set core_name $output_name
		}

		# Write out PLL parameters
		puts $fid "# PLL Parameters"
		puts $fid ""
		puts $fid "#USER W A R N I N G !"
		puts $fid "#USER The PLL parameters are statically defined in this"
		puts $fid "#USER file at generation time!"
		puts $fid "#USER To ensure timing constraints and timing reports are correct, when you make "
		puts $fid "#USER any changes to the PLL component using the MegaWizard Plug-In,"
		puts $fid "#USER apply those changes to the PLL parameters in this file"
		puts $fid ""
		puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_corename $core_name"
		puts $fid ""
		puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_num_pll_clock $number_of_clocks"
		puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_pll_ref_freq \"[get_parameter_value reference_clock_frequency]\""
		puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_pll_vco_freq \"[get_parameter_value pll_output_clk_frequency]\""
		for { set i 0 } { $i < $number_of_clocks } { incr i } {
			set clk_prst [get_parameter_value c_cnt_prst$i]
			set clk_ph_mux [get_parameter_value c_cnt_ph_mux_prst$i]

			set clk_duty_cycle [get_parameter_value duty_cycle$i]
			if {[get_parameter_value c_cnt_bypass_en$i] == "true"} {
				set ccnt 1
			} else {
				set ccnt [expr [get_parameter_value c_cnt_hi_div$i] + [get_parameter_value c_cnt_lo_div$i]]
			}
			
			set clk_mult $mcnt
			set clk_div [expr $ncnt*$ccnt]
			set clk_phase [expr 360 * ($clk_ph_mux  + 8*($clk_prst-1))/(8*$clk_div)]

			puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_pll_mult(${i}) $clk_mult"
			puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_pll_div(${i}) $clk_div"
			puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_pll_phase(${i}) $clk_phase"
			puts $fid "set ::GLOBAL_${ipcc_module}_${output_name}_pll_dutycycle(${i}) $clk_duty_cycle"
		}		
		
		close $fid
		add_fileset_file ${output_name}_parameters.tcl OTHER PATH ${path_name}${output_name}_parameters.tcl
	}
	
	# Now uniquify the static pin_map and SDC files
	set file_list "alterapll.sdc"
	set sdc_file [parse_tcl_params $output_name "" $path_name [list $file_list]]
	add_fileset_file ${output_name}.sdc SDC PATH $sdc_file
	
	set file_list "alterapll_pin_map.tcl"
	set pin_map_tcl_file [parse_tcl_params $output_name "" $path_name [list $file_list]]
	add_fileset_file ${output_name}_pin_map.tcl OTHER PATH $pin_map_tcl_file 
	
	return [list $parameters_tcl_file $sdc_file $pin_map_tcl_file]
}


# +-----------------------------------
# | 
# | Callback function when generating simulation file (VERILOG)
# | 
# +-----------------------------------
proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"
	
	#create a temp directory
	set tmpdir [create_temp_file {}]
	_dprint 1 "Using temporary directory $tmpdir for generate_verilog_sim"
		
	# generate HDL wrapper that instantiate altera_pll
	set family \"[get_parameter_value device_family]\"
	set generated_files [generate_verilog_fileset $name]
	interface_ports_and_mapping generation
	ipcc_set_module altera_pll
	generate_hdl_wrapper $name $tmpdir
	generate_simgen_model_file $generated_files $tmpdir $family $name VERILOG [list]

	# Advertize back the VO file
	add_fileset_file "${name}.vo" VERILOG PATH ${tmpdir}${name}.vo
	#common_add_fileset_files {S5 ALL_HDL ALL_SIM ALTERA_PLL} [concat PLAIN [common_fileset_tags_all_simulators]]
}

proc generate_verilog_fileset {name} {
	set file_list [list \
		${name}.v \
	]
	
	return $file_list
}

# +-----------------------------------
# | 
# | Callback function when generating simulation file (VHDL)
# | 
# +-----------------------------------
proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate vhdl simulation fileset for $name"

	#create a temp directory
	set tmpdir [create_temp_file {}]
	_dprint 1 "Using temporary directory $tmpdir for generate_vhdl_sim"
		
	# generate HDL wrapper that instantiate altera_pll
	set family \"[get_parameter_value device_family]\"
	set generated_files [generate_verilog_fileset $name]
	interface_ports_and_mapping generation
	ipcc_set_module altera_pll
	generate_hdl_wrapper $name $tmpdir
	generate_simgen_model_file $generated_files $tmpdir $family $name VHDL [list]

	# Advertize back the VHO file
	add_fileset_file "${name}.vho" VHDL PATH ${tmpdir}${name}.vho
	#common_add_fileset_files {S5 ALL_HDL ALL_SIM ALTERA_PLL} [concat PLAIN [common_fileset_tags_all_simulators]]
}

# +-----------------------------------
# | 
# | This function generate the necessary simgen model files (i.e. vho or vo file) in the 
# | specified temp_dir directory which will be added later to the simulation directories
# | 
# +-----------------------------------
proc generate_simgen_model_file {file_list temp_dir family top_level_name file_type blackbox_list} {

	set qdir $::env(QUARTUS_ROOTDIR)

	_iprint "Generating simgen model"

	#load_package project
	#load_package flow

	set curdir [pwd]
	cd $temp_dir

	set script_name [file join $temp_dir "proj.tcl"]
	set FH [open $script_name w]

	# Create Quartus II project                                                
	puts $FH "project_new $top_level_name -overwrite"

	puts $FH "set_global_assignment -name COMPILER_SETTINGS $top_level_name"
                                                                             
	# Set Compiler assignements                                                
	puts $FH "set_global_assignment -name FAMILY $family"
	puts $FH "set_global_assignment -name DEVICE AUTO"
	puts $FH "set_global_assignment -name FITTER_EFFORT \"STANDARD FIT\""
	puts $FH "set_global_assignment -name RESERVE_ALL_UNUSED_PINS \"AS INPUT TRI-STATED\""

	puts $FH "set_global_assignment -name VERILOG_MACRO \"SIMGEN=1\""
	puts $FH "set_global_assignment -name VERILOG_MACRO \"SYNTH_FOR_SIM=1\""

	# write out simgen init file indicate that we need a component declaration for the blackbox entity
	# and create simgen blackbox argument
	if {[llength $blackbox_list] == 0} {
		set bb_arg ""
		set init_arg ""
	} else {
		set bb_arg {--simgen_arbitrary_blackbox=+}
		append bb_arg [join $blackbox_list ";+"]
		set simgen_init [file join $temp_dir simgen_init.txt]
		set init_arg "SIMGEN_INITIALIZATION_FILE=$simgen_init,"
		set fd [open $simgen_init "w"]
		foreach bb $blackbox_list {
      		puts $fd "DECLARE_VHDL_COMPONENT=$bb"
		}
		close $fd
	}

	
	foreach fname $file_list {
		if {[regexp -nocase "\\.vh?\[ \t\]*$" $fname] } {
			puts $FH "set_global_assignment -name VERILOG_FILE ${fname}"
		} elseif {[regexp -nocase "\\.vh\[do\]\[ \t\]*$" $fname] } { 
			puts $FH "set_global_assignment -name VHDL_FILE ${fname}"
		} elseif {[regexp -nocase "\\.sv\[ \t\]*$" $fname] } {          
			puts $FH "set_global_assignment -name SYSTEMVERILOG_FILE ${fname}"
		} else {
			_iprint "Ignoring file $fname for simgen"
		}
	}

	close $FH
	alt_mem_if::util::iptclgen::run_quartus_tcl_script $script_name

	set cmd [list [file join ${qdir} bin quartus_map] "${top_level_name}.qpf" "--simgen" "--ini=disable_check_quartus_compatibility_qsys_only=on" "--simgen_parameter=${init_arg}CBX_HDL_LANGUAGE=$file_type"]
	if {[string compare $bb_arg ""] != 0} {
		lappend cmd "$bb_arg"
	}
	_dprint 1 "Command: $cmd"

	set fh [open "run_simgen_cmd.tcl" w]
	if {[string compare $bb_arg ""] == 0} {
		puts $fh "catch \{ eval \[list exec \"[file join ${qdir} bin quartus_map]\" \"${top_level_name}.qpf\" \"--simgen\" \"--ini=disable_check_quartus_compatibility_qsys_only=on\" \{--simgen_parameter=${init_arg}CBX_HDL_LANGUAGE=$file_type\} \]\} temp"
	} else {
		puts $fh "catch \{ eval \[list exec \"[file join ${qdir} bin quartus_map]\" \"${top_level_name}.qpf\" \"--simgen\" \"--ini=disable_check_quartus_compatibility_qsys_only=on\" \{--simgen_parameter=${init_arg}CBX_HDL_LANGUAGE=$file_type\} \{$bb_arg\} \]\} temp"
	}
	puts $fh "puts \$temp"
	close $fh

	set resultout [alt_mem_if::util::iptclgen::run_quartus_tcl_script "run_simgen_cmd.tcl"]
	
	_iprint $resultout

	# need to account for possible extra "64-Bit" after "Quartus II" in output
	if {[regexp -nocase {Quartus II.*Analysis \& Synthesis was successful} $resultout junk] == 0} {
		_eprint "Simgen failed" 1
	} else {
		_iprint "Simgen was successful"
	}
}

# +-----------------------------------
# | Fileset Callbacks
# | 
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


# Modify default outclk connection to support counter cascading
proc get_outclk_mapped_ports {default_port_mapping} {
	
	# If there are cascaded counters, we must alter the default instantiation of altera_pll 
	# (produced by ipcc_get_hdl_ports), replacing the outclk mapping.
	
	set en_adv [get_parameter_value gui_en_adv_params]
	set num_outclks [get_parameter_value gui_number_of_clocks]
	set num_cascade_counters [get_parameter_value number_of_cascade_counters]	
	set num_counters [expr $num_cascade_counters + $num_outclks]
	
	if {$en_adv} {
		
		# If advanced parameters are used, we just need to check for user-indicated cascade counters
		set counter_map ""
		for { set i [expr $num_counters-1] } {$i >= 0} {incr i -1} {
			set is_cascade_counter [get_parameter_value gui_cascade_counter$i]
			if {$is_cascade_counter} {
				lappend counter_map "output_unavailable"
			} else {
				lappend counter_map "outclk_$i"
			}
		}
		set ports [join $counter_map ", "]
		set outclk_mapped_ports ""
		append outclk_mapped_ports "{" $ports "}"
		
	} elseif { $num_cascade_counters > 0 } {

		# Loop over each counter, and decide whether its output corresponds to a user outclk
		set counter_map ""
		set outclk 0
		for { set counter 0 } {$counter < ($num_counters-1)} {incr counter} {
			# Look at the c_cnt_in_src of the NEXT counter
			set next [expr $counter + 1]
			set next_src [get_parameter_value c_cnt_in_src$next]
			
			# If counter cascades into next, we shouldn't connect counter's output
			if {[string compare $next_src cscd_clk] == 0} {
				lappend counter_map "output_unavailable"
			} else {
				lappend counter_map "outclk_$outclk"
				incr outclk
			}
		}
		# Special case for the final counter, which must always be an outclk
		lappend counter_map "outclk_$outclk"
		
		# Sanity check
		if {$num_outclks != $outclk+1} {
			send_message error "generate_hdl_wrapper{}: PLL output counter cascading is configured incorrectly."
		}

		# Now, construct the output string
		# set reversed [lreverse counter_map]
		set reversed ""
		set i [expr [llength $counter_map] - 1]
		while {$i >= 0} {
			lappend reversed [lindex $counter_map $i]
			incr i -1
		}
		set ports [join $reversed ", "]
		set outclk_mapped_ports ""
		append outclk_mapped_ports "{" $ports "}"
		
	} else {
		# No output counter cascading -- just use the default mapping
		set outclk_mapped_ports $default_port_mapping
	}

	return $outclk_mapped_ports
}


# MIF file functions
proc generate_mif_file {param_list mif_filename} {
    set success 1
#    set phys_params_file [open "phys_params_file.txt" w]

    set device [get_parameter_value device_family]
	set is_nightfury [is_nightfury_device $device]

    foreach item $param_list {
        set name [lindex $item 2]
		if {$is_nightfury} {
			append name [lindex $item 3]
		} 
        set value [get_parameter_value [lindex $item 0]]
        set old_value $value
        
        ## Parse M and N counts
		# five_series - FRACTIONAL_PLL_PLL_M_CNT_HI_DIV
		# ten_series - IOPLL_PLL_M_COUNTER_HIGH
        if {$name=="FRACTIONAL_PLL_PLL_M_CNT_HI_DIV" || $name=="IOPLL_PLL_M_COUNTER_HIGH"} {
            # hi_div/lo_div = 256 only when bypass, set it to 0
            # since we only have a byte
            if {$value == 256} {
                set value 0
            }
            set m_hi_div [int_to_8bits $value]
        } 
		# five_series - FRACTIONAL_PLL_PLL_M_CNT_LO_DIV
		# ten_series - IOPLL_PLL_M_COUNTER_LOW
        if {$name=="FRACTIONAL_PLL_PLL_M_CNT_LO_DIV" || $name=="IOPLL_PLL_M_COUNTER_LOW"} {
            # hi_div/lo_div = 256 only when bypass, set it to 0
            # since we only have a byte
            if {$value == 256} {
                set value 0
            }
            set m_lo_div [int_to_8bits $value]
        } 
		# five_series - FRACTIONAL_PLL_PLL_N_CNT_HI_DIV
		# ten_series - IOPLL_PLL_N_COUNTER_HIGH
        if {$name=="FRACTIONAL_PLL_PLL_N_CNT_HI_DIV" || $name=="IOPLL_PLL_N_COUNTER_HIGH"} {
            # hi_div/lo_div = 256 only when bypass, set it to 0
            # since we only have a byte
            if {$value == 256} {
                set value 0
            }
            set n_hi_div [int_to_8bits $value]
        } 
		# five_series - FRACTIONAL_PLL_PLL_N_CNT_LO_DIV
		# ten_series - IOPLL_PLL_N_COUNTER_LOW
        if {$name=="FRACTIONAL_PLL_PLL_N_CNT_LO_DIV" || $name=="IOPLL_PLL_N_COUNTER_LOW"} {
            # hi_div/lo_div = 256 only when bypass, set it to 0
            # since we only have a byte
            if {$value == 256} {
                set value 0
            }
            set n_lo_div [int_to_8bits $value]
        } 
		# five_series - FRACTIONAL_PLL_PLL_M_CNT_BYPASS_EN
		# ten_series - IOPLL_PLL_M_COUNTER_BYPASS_EN
        if {$name=="FRACTIONAL_PLL_PLL_M_CNT_BYPASS_EN" || $name=="IOPLL_PLL_M_COUNTER_BYPASS_EN"} {
            if {$value=="true"} {
                set m_bypass_en 1
            } else {
                set m_bypass_en 0
            }
        }
		# five_series - FRACTIONAL_PLL_PLL_N_CNT_BYPASS_EN
		# ten_series - IOPLL_PLL_N_COUNTER_BYPASS_EN
        if {$name=="FRACTIONAL_PLL_PLL_N_CNT_BYPASS_EN" || $name=="IOPLL_PLL_N_COUNTER_BYPASS_EN"} {
            if {$value=="true"} {
                set n_bypass_en 1
            } else {
                set n_bypass_en 0
            }
        }
		# five_series - FRACTIONAL_PLL_PLL_M_CNT_ODD_DIV_DUTY_EN
		# ten_series - IOPLL_PLL_M_COUNTER_EVEN_DUTY_EN
        if {$name=="FRACTIONAL_PLL_PLL_M_CNT_ODD_DIV_DUTY_EN" || $name=="IOPLL_PLL_M_COUNTER_EVEN_DUTY_EN"} {
            if {$value=="true"} {
                set m_odd_div_en 1
            } else {
                set m_odd_div_en 0
            }
        }
		# five_series - FRACTIONAL_PLL_PLL_N_CNT_ODD_DIV_DUTY_EN
		# ten_series - IOPLL_PLL_N_COUNTER_ODD_DIV_DUTY_EN
        if {$name=="FRACTIONAL_PLL_PLL_N_CNT_ODD_DIV_DUTY_EN" || $name=="IOPLL_PLL_N_COUNTER_BYPASS_EN"} {
            if {$value=="true"} {
                set n_odd_div_en 1
            } else {
                set n_odd_div_en 0
            }
        }
        
        ## Parse C counts
        set match ""
        set c_name ""
        set c_num ""

		if {$is_nightfury} {
			regexp {IOPLL_PLL_C_COUNTER_([0-9])_([^0-9]*)} $name match c_num c_name
		} else {
			regexp {PLL_OUTPUT_COUNTER_DPRIO0_CNT_([^0-9]*)([0-9]?[0-9])} $name match c_name c_num			
		}

        #puts $phys_params_file "match = $match, c_name = $c_name, c_num = $c_num"
        if {$match != ""} {
            set c_valid($c_num) 1
            if {$c_name == "HI_DIV" || $c_name == "HIGH"} {
                # If 256, bypass so set to 0
                if {$value == 256} {
                    set value 0
                }
                set c_hi_div($c_num) [int_to_8bits $value]
            }
            if {$c_name == "LO_DIV" || $c_name == "LOW"} {
                if {$value == 256} {
                    set value 0
                }
                set c_lo_div($c_num) [int_to_8bits $value]
            }
            if {$c_name == "BYPASS_EN" || $c_name == "BYPASS_EN"} {
                if {$value == "true"} {
                    set c_bypass_en($c_num) 1
                } else {
                    set c_bypass_en($c_num) 0
                }
            }
            if {$c_name == "ODD_DIV_EVEN_DUTY_EN"|| $c_name == "EVEN_DUTY_EN"} {
                if {$value == "true"} {
                    set c_odd_div_en($c_num) 1
                } else {
                    set c_odd_div_en($c_num) 0
                }
            }
        } else {
			
            set c_valid($c_num) 0
        }

        ## Parse Charge Pump
		# five_series - FRACTIONAL_PLL_PLL_CP_CURRENT
		# ten_series - IOPLL_PLL_CP_CURRENT_SETTING
        if {$name == "FRACTIONAL_PLL_PLL_CP_CURRENT" || $name == "IOPLL_PLL_CP_CURRENT_SETTING" } {
            if {$value == 5} {
                set cp_bits "000"
            }
            if {$value == 10} {
                set cp_bits "001"
            }
            if {$value == 20} {
                set cp_bits "010"
            }
            if {$value == 30} {
                set cp_bits "011"
            }
            if {$value == 40} {
                set cp_bits "100"
            }
            set value $cp_bits
        }

        ## Parse BW Resistor (Ohms)
		# five_series - FRACTIONAL_PLL_PLL_BWCTRL
		# ten_series - IOPLL_PLL_BWCTRL
        if {$name == "FRACTIONAL_PLL_PLL_BWCTRL" || $name == "IOPLL_PLL_BWCTRL" } {
            if {$value == 18000} {
                set bw_bits "0000"
            }
            if {$value == 16000} {
                set bw_bits "0001"
            }
            if {$value == 14000} {
                set bw_bits "0010"
            }
            if {$value == 12000} {
                set bw_bits "0011"
            }
            if {$value == 10000} {
                set bw_bits "0100"
            }
            if {$value == 8000} {
                set bw_bits "0101"
            }
            if {$value == 6000} {
                set bw_bits "0110"
            }
            if {$value == 4000} {
                set bw_bits "0111"
            }
            if {$value == 2000} {
                set bw_bits "1000"
            }
            if {$value == 1000} {
                set bw_bits "1001"
            }
            if {$value == 500} {
                set bw_bits "1010"
            }
            set value $bw_bits
        }

        ## Parse fractional division
        set pll_mode [get_parameter_value gui_pll_mode]
        if {$name == "FRACTIONAL_PLL_PLL_FRACTIONAL_DIVISION"} {
            set frac_div_value [int_to_32bits $value]
            set value $frac_div_value
        }

#        puts $phys_params_file "Item [lindex $item 2], name = [lindex $item 2], old_value=$old_value, value = $value"
    }
    
    ## Parse DPS settings if enabled
    set mif_dps_enabled [get_parameter_value gui_enable_mif_dps]

    if {$mif_dps_enabled == "true"} {
        # Parse counter setting
        set temp_dps_cntr [get_parameter_value gui_dps_cntr]
        if {[regexp {C([0-9]?[0-9])} $temp_dps_cntr dps_match dps_cntr_num]} {
			if {$is_nightfury} {
				set dps_cnt_select [int_to_4bits $dps_cntr_num]
			} else {
				set dps_cnt_select [int_to_5bits $dps_cntr_num]
			}
            send_message info "count match $dps_match dps_cntr_num $dps_cntr_num bits $dps_cnt_select"
        }
        if {$temp_dps_cntr == "All C"} {
			if {$is_nightfury} {
				set dps_cnt_select "1111"
			} else {
				set dps_cnt_select "11111"
			}		
            send_message info "dps_cntr $temp_dps_cntr bits $dps_cnt_select"
        }
        if {$temp_dps_cntr == "M"} {
			if {$is_nightfury} {
				set dps_cnt_select "1011"
			} else {
				set dps_cnt_select "10010"
			}			
            send_message info "dps_cntr $temp_dps_cntr bits $dps_cnt_select"
        }

        # Parse num shifts
        set temp_dps_shifts [get_parameter_value gui_dps_num]
		if {$is_nightfury} {
			set dps_num_shifts [int_to_3bits $temp_dps_shifts]
		} else {
			set dps_num_shifts [int_to_16bits $temp_dps_shifts]
		}
        send_message info "dps_shifts $temp_dps_shifts bits $dps_num_shifts"

        # Parse direction
        set temp_dps_dir [get_parameter_value gui_dps_dir]
        if {$temp_dps_dir == "Positive"} {
            set dps_up_dn 1
        }
        if {$temp_dps_dir == "Negative"} {
            set dps_up_dn 0
        }
        send_message info "dps_dir $temp_dps_dir bits $dps_up_dn"
    }

	## OPCODES
	if {$is_nightfury} {
		set OP_START		"000000000"  
		set OP_N			"010100000"
		set OP_M			"010010000"
		set OP_C_COUNTERS	"011000000" 
		set OP_DPS			"100000000"
		set OP_BWCTRL 		"001000000"
		set OP_CP_CURRENT	"000100000"
		set OP_SOM			"000011110"  
		set OP_EOM			"000011111"   
	} else {
		set OP_SOM          "111110"
		set OP_MODE         "000000"
		set OP_STATUS       "000001"
		set OP_START        "000010"
		set OP_N            "000011"
		set OP_M            "000100"
		set OP_C_COUNTERS   "000101"
		set OP_DPS          "000110"
		set OP_DSM          "000111"
		set OP_BWCTRL       "001000"
		set OP_CP_CURRENT   "001001"
		set OP_EOM          "111111"
	}

    ## Output MIF file
    set mif_file [open $mif_filename w]
    puts $mif_file "DEPTH = 512;"
    puts $mif_file "WIDTH = 32;"
    puts $mif_file "ADDRESS_RADIX = UNS;"
    puts $mif_file "DATA_RADIX = BIN;"
    puts $mif_file "CONTENT"
    puts $mif_file "BEGIN"

    set addr_num 0
    
    # Print SOM - 32 bits, opcodes are 6 bits or 9 bits, pad with 26 zeros or 23 zeros
	if {$is_nightfury} {
		set n_zeros 23
	} else {
		set n_zeros 26
	}
    puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_SOM;        -- START OF MIF"
    incr addr_num

    # Print M counter OP code, then settings - for paddings refer to PLL Reconfig FD
    puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_M;        -- M COUNTER"
    incr addr_num
    puts $mif_file "$addr_num : [string repeat "0" 14]$m_odd_div_en$m_bypass_en$m_hi_div$m_lo_div;"
    incr addr_num

    # Print N counter
    puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_N;        -- N COUNTER"
    incr addr_num
    puts $mif_file "$addr_num : [string repeat "0" 14]$n_odd_div_en$n_bypass_en$n_hi_div$n_lo_div;"
    incr addr_num

    # Print C counters
	if {$is_nightfury} {
		set n_c_counters 9
	} else {
		set n_c_counters 18
	}
	
    for {set k 0} {$k < $n_c_counters} {incr k} {
        if {$c_valid($k) == 1} {
			if {$is_nightfury} {
				set c_cnt_bits [int_to_4bits $k]
				puts $mif_file "$addr_num : [string repeat "0" $n_zeros][string replace $OP_C_COUNTERS 5 8 $c_cnt_bits];        -- C$k COUNTER"
				incr addr_num
				puts $mif_file "$addr_num : [string repeat "0" 14]$c_odd_div_en($k)$c_bypass_en($k)$c_hi_div($k)$c_lo_div($k);"
				incr addr_num
			} else {
				set c_cnt_bits [int_to_5bits $k]
				puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_C_COUNTERS;        -- C$k COUNTER"
				incr addr_num
				puts $mif_file "$addr_num : [string repeat "0" 9]$c_cnt_bits$c_odd_div_en($k)$c_bypass_en($k)$c_hi_div($k)$c_lo_div($k);"
				incr addr_num
			}
        }
    }
    
    # Print Charge Pump
    puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_CP_CURRENT;        -- CHARGE PUMP"
    incr addr_num
    puts $mif_file "$addr_num : [string repeat "0" 29]$cp_bits;"
    incr addr_num

    # Print BW Resistor
    puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_BWCTRL;        -- BANDWIDTH SETTING"
    incr addr_num
    puts $mif_file "$addr_num : [string repeat "0" 25]$bw_bits[string repeat "0" 3];"
    incr addr_num

    # Print Fractional Division
    if {$pll_mode == "Fractional-N PLL"} {
       puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_DSM;        -- M COUNTER FRACTIONAL VALUE"
       incr addr_num
       puts $mif_file "$addr_num : $frac_div_value;"
       incr addr_num
    }
	
    # Print DPS (if enabled)
    if {$mif_dps_enabled == "true"} {
        puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_DPS;        -- DYNAMIC PHASE SHIFT"
        incr addr_num
		if {$is_nightfury} {
			puts $mif_file "$addr_num : [string repeat "0" 28]$dps_up_dn$dps_num_shifts;" 
		} else {
			puts $mif_file "$addr_num : [string repeat "0" 10]$dps_up_dn$dps_cnt_select$dps_num_shifts;"
		}
        incr addr_num
    }

    # Print EOF
    puts $mif_file "$addr_num : [string repeat "0" $n_zeros]$OP_EOM;        -- END OF MIF"
    incr addr_num
    
    # Set the rest of MIF file to zero (to avoid Quartus warning)
    # We have 512 lines of 32 bits for 1 M20K
    while {$addr_num < 512} {
        puts $mif_file "$addr_num : [string repeat "0" 32];"
        incr addr_num
    }

    puts $mif_file "END;"
    incr addr_num

    close $mif_file
    return $success
}

proc int_to_bits {integer} {
    set bits ""
    set temp $integer

    while {$temp > 0} {
        set new_bit [expr $temp % 2]
        set bits $new_bit$bits
        set temp [expr $temp/2]
    }

    return $bits
}

proc int_to_3bits {integer} {
    set old_bits [int_to_bits $integer]
    set new_bits $old_bits
    set len [string length $new_bits]
    set zero "0"

    while {$len < 3} {
        # Pad MSBs with 0
        set new_bits $zero$new_bits
        set len [string length $new_bits]
    }

    return $new_bits
}

proc int_to_4bits {integer} {
    set old_bits [int_to_bits $integer]
    set new_bits $old_bits
    set len [string length $new_bits]
    set zero "0"

    while {$len < 4} {
        # Pad MSBs with 0
        set new_bits $zero$new_bits
        set len [string length $new_bits]
    }

    return $new_bits
}

proc int_to_5bits {integer} {
    set old_bits [int_to_bits $integer]
    set new_bits $old_bits
    set len [string length $new_bits]
    set zero "0"

    while {$len < 5} {
        # Pad MSBs with 0
        set new_bits $zero$new_bits
        set len [string length $new_bits]
    }

    return $new_bits
}

proc int_to_8bits {integer} {
    set old_bits [int_to_bits $integer]
    set new_bits $old_bits
    set len [string length $new_bits]
    set zero "0"

    while {$len < 8} {
        # Pad MSBs with 0
        set new_bits $zero$new_bits
        set len [string length $new_bits]
    }

    return $new_bits
}

proc int_to_16bits {integer} {
    set old_bits [int_to_bits $integer]
    set new_bits $old_bits
    set len [string length $new_bits]
    set zero "0"

    while {$len < 16} {
        # Pad MSBs with 0
        set new_bits $zero$new_bits
        set len [string length $new_bits]
    }

    return $new_bits
}

proc int_to_32bits {integer} {
    set old_bits [int_to_bits $integer]
    set new_bits $old_bits
    set len [string length $new_bits]
    set zero "0"

    while {$len < 32} {
        # Pad MSBs with 0
        set new_bits $zero$new_bits
        set len [string length $new_bits]
    }

    return $new_bits
}

proc compute_vco_frequency {} {
	set device [get_parameter_value device_family]
    set fractional_vco_multiplier [get_parameter_value fractional_vco_multiplier]	
	set mult [get_parameter_value gui_multiply_factor]
	set div [get_parameter_value gui_divide_factor_n]
	set ref_clk [precision_check [get_parameter_value gui_reference_clock_frequency]]
	set pll_fractional_cout [get_parameter_value gui_fractional_cout]
    set third_order_divide [expr {pow(2, $pll_fractional_cout)}]
	
	#use a different equation to calculate frequency
	#if frac pll
	if {$fractional_vco_multiplier == "true"} {
		set frac [get_parameter_value gui_frac_multiply_factor]
		set frac_double [expr {double($frac*1.0)}]
		set vco_freq [format "%.6f" [expr {$ref_clk*(($mult+double($frac_double)/$third_order_divide)/$div)}]]
	} else {
		set vco_freq [expr {$ref_clk*(double($mult)/$div)}]
	}

	return $vco_freq;
}

proc update_cascading_parameters { device } {
	set is_cascade_out_enable [get_parameter_value gui_enable_cascade_out]
	set index [get_parameter_value gui_cascade_outclk_index]
	set is_nightfury [is_nightfury_device $device]
	if { $is_nightfury && $is_cascade_out_enable && $index != 8} {
		set_parameter_value output_clock_frequency8 [get_parameter_value output_clock_frequency$index]
		set_parameter_value phase_shift8 [get_parameter_value phase_shift$index]
		set_parameter_value duty_cycle8 [get_parameter_value duty_cycle$index]
		set_parameter_value c_cnt_hi_div8 [get_parameter_value c_cnt_hi_div$index]
		set_parameter_value c_cnt_lo_div8 [get_parameter_value c_cnt_lo_div$index]
		set_parameter_value c_cnt_prst8 [get_parameter_value c_cnt_prst$index]
		set_parameter_value c_cnt_ph_mux_prst8 [get_parameter_value c_cnt_ph_mux_prst$index]
		set_parameter_value c_cnt_in_src8 [get_parameter_value c_cnt_in_src$index]
		set_parameter_value c_cnt_bypass_en8 [get_parameter_value c_cnt_bypass_en$index]
		set_parameter_value c_cnt_odd_div_duty_en8 [get_parameter_value c_cnt_odd_div_duty_en$index]
		
		# output an info message to indicate that we are overwriting pll_c_counter_1 parameters
		send_message info "Replacing outclk8 with outclk$index parameters as outclk8 will be used as cascading source"
	}
	
	if { $is_nightfury } {
		# enable/disable GUI elements based on selected cascade source index
		set enable [expr {$is_cascade_out_enable == "false" || $is_cascade_out_enable && $index == 8}]
		set_parameter_property gui_cascade_counter8 ENABLED $enable
		set_parameter_property gui_output_clock_frequency8 ENABLED $enable
		set_parameter_property gui_divide_factor_c8 ENABLED $enable
		set_parameter_property gui_actual_divide_factor8 ENABLED $enable
		set_parameter_property gui_actual_output_clock_frequency8 ENABLED $enable
		set_parameter_property gui_ps_units8 ENABLED $enable
		set_parameter_property gui_phase_shift8 ENABLED $enable
		set_parameter_property gui_phase_shift_deg8 ENABLED $enable
		set_parameter_property gui_actual_phase_shift8 ENABLED $enable
		set_parameter_property gui_duty_cycle8 ENABLED $enable
	}
}

# proc: parse_tcl_params
#
# Perform string replacement on a TCL script
#
# parameters:
#
#  module          : name of IP variant
#  indir           : input directory
#  outdir          : output directory
#  infile_list     : input file list
#
# returns:
#
#  List of files generated
#
proc parse_tcl_params {module indir outdir infile_list } {

	# Initialize the list of known parameters
	set known_params [get_parameters]
	
	# Initialize list of generated files
	set generated_files [list]
	
	foreach infile_name $infile_list {

		set infull_name [file join $indir $infile_name]

		_dprint 1 "Preparing to run parse_tcl_params on $infile_name"
		_dprint 1 "Source Dir = $indir"
		_dprint 1 "Dest Dir = $outdir"

		set outfile_name [ string map "alterapll $module" $infile_name ]

		set outfile_name [file join $outdir $outfile_name]
		set outfile_name_tmp "${outfile_name}.tmp"
		
		lappend generated_files $outfile_name

		set outtcl [open "$outfile_name_tmp" w]

		_dprint 1 "Preparing to create $outfile_name"

		set intcl [open "$infull_name" r]

		set skip_to_end 0
		set ifdef_level 0

		set spaces "\[ \t\n\]"
		set notspaces "\[^ \t\n\]"

		# Start parsing line by line
		while {[gets $intcl line] != -1} {
			set out_line 1	

			_dprint 2 "LINE: $line"

			# Here go all lines modifications
			if {$out_line == 1 && $skip_to_end == 0} {
				set modified_line $line
				if {[regexp "alterapll_${notspaces}*\.tcl" $line] } {
					# Modify all lines that refer to a TCL file starting with 'alterapll' so that
					# the sourced file actually starts with the core (module) name
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp "alterapll${notspaces}*\.sdc" $line] } {
					# Modify all lines that refer to an SDC file starting with 'alterapll' so that
					# the sourced file actually starts with the core (module) name
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp "^proc${spaces}+alterapll_" $line matchvar ] } {
					# Uniquify function names that start with "alterapll_"
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp {alterapll_get_pll_pins} $line matchvar ] } {
					# Uniquify specific call to this function 
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp {alterapll_initialize_pll_db} $line matchvar ] } {
					# Uniquify specific call to this function 
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp {alterapll_sdc_cache} $line matchvar ] } {
					# Uniquify variable alterapll_sdc_cache
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp {alterapll_pll_db} $line matchvar ] } {
					# Uniquify variable alterapll_pll_db
					set modified_line [ string map "alterapll $module" $line ]
				} elseif {[regexp {(\salterapll_\w+\s])|([alterapll_\w+])} $line] } {
                    set modified_line [ string map "alterapll_ ${module}_" $line ] 
                    set line $modified_line
                }

				if {[regexp {::GLOBAL_} $line matchvar ] } {
					# Uniquify GLOBAL variable names
					set modified_line [ string map "::GLOBAL_ ::GLOBAL_altera_pll_${module}_" $line ]
					set line $modified_line
				} 
			}

			if {$out_line == 1 && $skip_to_end == 0} {
				puts $outtcl $modified_line
			}
		}

		close $intcl
		close $outtcl
		
		# Rename the output file
		file rename -force $outfile_name_tmp $outfile_name

	}

	return $generated_files
}
