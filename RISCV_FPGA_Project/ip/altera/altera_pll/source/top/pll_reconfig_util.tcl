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


proc reconfig_param_handler {} {
    global five_series_phys_params_list
    global ten_series_phys_params_list
    global total_rbc_time 
    global num_rbc_calls 
    set total_rbc_time 0
    set num_rbc_calls 0
    #add physical parameters necessary for reconfig

    set num_clocks [get_parameter_value gui_number_of_clocks]
    #default reference list

    #first get all desired actual output clock frequencies
    #of the counter outputs
    set output_clock_frequencies [list]
    for { set i 0 } {$i < $num_clocks} {incr i} {
        set output_freq_noMHz [get_parameter_value output_clock_frequency$i]
        lappend output_clock_frequencies $output_freq_noMHz
        regsub {([ MHz]+)} $output_freq_noMHz {} output_freq_noMHz
        if { $output_freq_noMHz == 0} {
            send_message error "Please specify correct output frequencies."
            return -1
        }
    }

    set_parameter_value pll_fractional_cout [get_parameter_value gui_fractional_cout]
    set_parameter_value pll_dsm_out_sel [get_parameter_value gui_dsm_out_sel]
    set number_of_counters [llength [get_parameter_property gui_number_of_clocks allowed_ranges]]
    set device [get_parameter_value device_family]
    set device_part [get_parameter_value device]
    set speed [get_reference_list_items "speed" [list $device]]
    set part [get_reference_list_items "device_part" [list $device $speed $device_part]]
    set pll_type [get_reference_list_items "pll_type" $device]
    set check_refclk [precision_check [get_parameter_value gui_reference_clock_frequency]]
    set reference_clock_frequency "$check_refclk MHz"
    set pll_channel_spacing [get_reference_list_items "channel_spacing" $device]
    set pll_fractional_vco_multiplier [get_reference_list_items "fractional_vco_multiplier" $device]
    set pll_auto_reset [get_parameter_value gui_pll_auto_reset]
    set pll_bandwidth_preset [get_parameter_value gui_pll_bandwidth_preset]
    set pll_compensation_mode [get_compensation_mode]
    set pll_feedback_mode [get_parameter_value gui_feedback_clock]
    set pll_desired_vco_frequency [compute_vco_frequency]
    set advanced_param_used [get_parameter_value gui_en_adv_params]
    set is_nightfury [is_nightfury_device $device]
    
    #Build list to pass to qcl_pll get_physical_parameters call.
    set reference_list [list]
    
    #general PLL information
    lappend reference_list $device
    lappend reference_list $speed
    lappend reference_list $part
    lappend reference_list $pll_type
    lappend reference_list $number_of_counters
    lappend reference_list $pll_channel_spacing
    lappend reference_list $pll_fractional_vco_multiplier
    lappend reference_list $pll_auto_reset
    lappend reference_list $pll_bandwidth_preset
    lappend reference_list $pll_compensation_mode
    lappend reference_list $pll_feedback_mode
    
    #ref clk frequency
    lappend reference_list $reference_clock_frequency
    lappend reference_list $pll_desired_vco_frequency
    lappend reference_list $advanced_param_used
    #output clock frequencies and their phase shifts and duty cycles
    for { set i 0 } {$i < $num_clocks} {incr i} {
        set output_freq [get_parameter_value output_clock_frequency$i]
        set phase_shift [get_parameter_value phase_shift$i]
        set duty_cycle [get_parameter_value duty_cycle$i]
        lappend reference_list $output_freq
        lappend reference_list $phase_shift
        lappend reference_list $duty_cycle
    }
    #append 0s for counters that are unused
    for { set i 0 } {$i < [expr {$number_of_counters - $num_clocks}]} {incr i} {
        lappend reference_list 0
        lappend reference_list 0
        lappend reference_list 50
    }

    #Send the list of physical parameters needed
    if { $is_nightfury } {
        set phys_params_list $ten_series_phys_params_list
    } else {
        set phys_params_list $five_series_phys_params_list
    }
    set param_list [list]
    foreach param $phys_params_list {
        set param_rbc_name [lindex $param 2] 
        if { $is_nightfury } {
            append param_rbc_name [lindex $param 3] 
        }
        
        #append it to the main reference list
        lappend param_list "$param_rbc_name"
    }
   
    set x_total 0
    set start_t_total [clock clicks -milliseconds]
 
    #call the qcl_pll get_physical_parameters command using list we just built
    set result [::quartus::qcl_pll::get_physical_parameters -reference_list $reference_list -parameter_list $param_list -family $device]

#    _dprint 1 $result
    set end_t_total [clock clicks -milliseconds]
    set x_total [expr {$end_t_total - $start_t_total}]
    #send_message info "qcl_pll param_list: $param_list"
    #send_message info "qcl_pll result: $result"
    #_dprint 1 "result = $result"

#    _dprint 1 "call time = $x_total"
    set matched [regexp {^-[0-9]$} $result err_code]
    set illegal_vco "false"
    
    if {$matched} {
        send_message error "Please specify correct output frequencies."
        return -1
    }
    set legal_parameters [lindex $result 0]
    for { set i 0 } {$i < [llength $legal_parameters]} {incr i 2} {
        set rbc_name [lindex $legal_parameters $i]
        set param_value [lindex $legal_parameters [expr {$i+1}]]
        
        #split each legal param if there are mulitple
        set legal_param_value [split $param_value |]
        set param_value [lindex $legal_param_value 0]
        
        foreach param $phys_params_list {
            set param_name [lindex $param 0] 
            set param_rbc_name [lindex $param 2]
            if { $is_nightfury } {
                append param_rbc_name [lindex $param 3] 
            }
            
            if {![string compare $param_rbc_name $rbc_name]} {
                if {[is_legal_value $param_value]} {
                    if {$param_name == "pll_fractional_division"} {
                        #factoring down the fractional K value acording to the Carryout 
                        #selected by the user.
                        set fractional_cout [get_parameter_value pll_fractional_cout]
                        if {$fractional_cout == 8} {
                            set param_value [expr {round($param_value/16777216.0)}]
                        } elseif {$fractional_cout == 16} {
                            set param_value [expr {round($param_value/65536.0)}]
                        } elseif {$fractional_cout == 24} {
                            set param_value [expr {round($param_value/256.0)}]
                        } 
                        if {$param_value < 1} {
                            set param_value 1
                        }
                        if {$advanced_param_used} {
                            set k_value [get_parameter_value gui_frac_multiply_factor]
                            set param_value $k_value
                        }
                    } elseif {$param_name == "mimic_fbclk_type"} {
                        if {$pll_compensation_mode == "normal" || \
                            $pll_compensation_mode == "source synchronous" ||
                            $pll_compensation_mode == "source_synchronous"} {
                            switch $pll_feedback_mode {
                                "Global Clock" {set param_value "gclk"}
                                "Regional Clock" {set param_value "qclk"}
                            }
                        }
                    } elseif {$param_name == "m_cnt_odd_div_duty_en"} {
                        if {$advanced_param_used} {
							set m_counter [get_parameter_value gui_multiply_factor]
                            set param_value [enable_odd_div_duty $m_counter 50]
                        }
                    } elseif {$param_name == "n_cnt_odd_div_duty_en"} {
                        if {$advanced_param_used} {
							set n_counter [get_parameter_value gui_divide_factor_n]
                            set param_value [enable_odd_div_duty $n_counter 50]
                        }
                    } elseif {[string match "c_cnt_odd_div_duty_en*" $param_name]} {
                        if {$advanced_param_used} {
                            regsub {[^0-9]+} $param_name "" cnt_index
                            set c_counter [get_parameter_value gui_divide_factor_c$cnt_index]
							set desired_duty [get_parameter_value gui_duty_cycle$cnt_index]
                            set param_value [enable_odd_div_duty $c_counter $desired_duty]
                        }
                    } elseif {$param_name == "m_cnt_bypass_en"} {
                        if {$advanced_param_used} {
                            set m_counter [get_parameter_value gui_multiply_factor]
                            set param_value [enable_counter_bypass $m_counter]
                        }
                    } elseif {$param_name == "n_cnt_bypass_en"} {
                        if {$advanced_param_used} {
                            set n_counter [get_parameter_value gui_divide_factor_n]
                            set param_value [enable_counter_bypass $n_counter]
                        }
                    } elseif {[string match "c_cnt_bypass_en*" $param_name]} {
                        if {$advanced_param_used} {
                            regsub {[^0-9]+} $param_name "" cnt_index
                            set c_counter [get_parameter_value gui_divide_factor_c$cnt_index]
                            set param_value [enable_counter_bypass $c_counter]
                        }
                    } elseif {$param_name == "m_cnt_hi_div"} {
                        if {$advanced_param_used} {
                            set m_counter [get_parameter_value gui_multiply_factor]
                            set param_value [get_counter_hi_div $m_counter]
                        }
                    } elseif {$param_name == "m_cnt_lo_div"} {
                        if {$advanced_param_used} {
                            set m_counter [get_parameter_value gui_multiply_factor]
                            set param_value [get_counter_lo_div $m_counter]
                        }
                    } elseif {$param_name == "n_cnt_hi_div"} {
                        if {$advanced_param_used} {
                            set n_counter [get_parameter_value gui_divide_factor_n]
                            set param_value [get_counter_hi_div $n_counter]
                        }
                    } elseif {$param_name == "n_cnt_lo_div"} {
                        if {$advanced_param_used} {
                            set n_counter [get_parameter_value gui_divide_factor_n]
                            set param_value [get_counter_lo_div $n_counter]
                        }
                    } elseif {[string match "c_cnt_hi_div*" $param_name]} {
                        if {$advanced_param_used} {
                            regsub {[^0-9]+} $param_name "" cnt_index
                            set c_counter [get_parameter_value gui_divide_factor_c$cnt_index]
                            set duty_cycle [get_parameter_value duty_cycle$cnt_index]
                            set param_value [get_c_counter_hi_div $c_counter $duty_cycle]
                        }
                    } elseif {[string match "c_cnt_lo_div*" $param_name]} {
                        if {$advanced_param_used} {
                            regsub {[^0-9]+} $param_name "" cnt_index
                            set c_counter [get_parameter_value gui_divide_factor_c$cnt_index]
                            set duty_cycle [get_parameter_value duty_cycle$cnt_index]
                            set param_value [get_c_counter_lo_div $c_counter $duty_cycle]
                        }
                    } elseif {$param_name == "pll_output_clk_frequency"} {
                        if {$advanced_param_used} {
                            set illegal_vco [expr {($param_value == "0 MHz") ? "true" : "false"}]  
                        }
                    } 
                    set_parameter_value $param_name $param_value
                } else {
                    if {[string match "c_cnt_*" $param_name]} {
                        #The C counter parameters
                        #extract the number from the param name
                        regsub {[^0-9]+} $param_name "" cnt_index
                        if {[expr {$cnt_index > ($num_clocks - 1)}]} {
                        #For the case where the C counteres are added then removed, need to reset their values
                        #to default
                            set_parameter_value $param_name [get_parameter_property $param_name DEFAULT_VALUE]
                        }
                    } 
                }
            }
        }
    }
    
    #The given configuration results in an illegal VCO frequency
    if {$illegal_vco == "true"} {
        send_message error "The specified configuration causes Voltage-Controlled Oscillator (VCO) to go beyond the limit."
    }
    
    #Calculating the Actual values for the DIV/Mult factors
    set n_bypass_en [get_parameter_value n_cnt_bypass_en]
    set m_bypass_en [get_parameter_value m_cnt_bypass_en]
    if {$n_bypass_en == "true"} {
        set n_cnt_val 1
    } else {
        set n_cnt_val [expr {[get_parameter_value n_cnt_hi_div] + [get_parameter_value n_cnt_lo_div]}]
    }
    if {$m_bypass_en == "true"} {
        set actual_mult 1
    } else {
        set actual_mult [expr {[get_parameter_value m_cnt_hi_div] + [get_parameter_value m_cnt_lo_div]}]
    }
    set actual_frac_mult [get_parameter_value pll_fractional_division] 
    for { set i 0 } {$i < $num_clocks} {incr i} {
        set c_bypass_en [get_parameter_value c_cnt_bypass_en$i]
        if {$c_bypass_en == "true"} {
            set c_cnt_val 1
        } else {
            set c_cnt_val [expr {[get_parameter_value c_cnt_hi_div$i] + [get_parameter_value c_cnt_lo_div$i]}]
        }
        set actual_div [expr {$n_cnt_val * $c_cnt_val}]
        set_parameter_value gui_actual_multiply_factor$i $actual_mult
        set_parameter_value gui_actual_frac_multiply_factor$i $actual_frac_mult
        set_parameter_value gui_actual_divide_factor$i $actual_div
    }
    
    #update the table that displays all the physical parameters
    update_parameter_table 
}
proc en_reconfig_ports { flag enable} {
        #declare the reconfig conduit from pll_reconfig and to it
    global reconf_width
    if {$enable} {

        add_interface reconfig_to_pll conduit end
        add_interface_port reconfig_to_pll reconfig_to_pll reconfig_to_pll input $reconf_width
        add_interface reconfig_from_pll conduit end
        set_interface_assignment reconfig_from_pll "ui.blockdiagram.direction" OUTPUT
        add_interface_port reconfig_from_pll reconfig_from_pll reconfig_from_pll output $reconf_width
        
        set_interface_property reconfig_from_pll ENABLED $enable
        set_interface_property reconfig_to_pll ENABLED $enable
    }
}

proc en_dps_ports { flag enable device} {
    set is_nightfury [is_nightfury_device $device]
    if {$device == "Stratix V" || $device == "Arria V" || $device == "Cyclone V" || $device == "Arria V GZ"} {
        set cntsel_width 5
        set en_reconf [get_parameter_value gui_en_reconf]
        if {$enable} {
            add_interface phase_en conduit end
            add_interface_port phase_en phase_en phase_en input 1
            if {$en_reconf == "false"} {
                add_interface scanclk conduit end
                add_interface_port scanclk scanclk scanclk input 1
                set_interface_property scanclk ENABLED $enable
            }
            add_interface updn conduit end
            add_interface_port updn updn updn input 1
            add_interface cntsel conduit end
            add_interface_port cntsel cntsel cntsel input $cntsel_width

            add_interface phase_done conduit end
            set_interface_assignment phase_done "ui.blockdiagram.direction" OUTPUT
            add_interface_port phase_done phase_done phase_done output 1

            set_interface_property phase_en ENABLED $enable
            set_interface_property updn ENABLED $enable
            set_interface_property cntsel ENABLED $enable
            set_interface_property phase_done ENABLED $enable
        }
    } elseif {$is_nightfury} {
        # cntsel on IOPLL is 4 bits, but 5 on 28nm. For backwards compatibility, keep it 5
        # and pass in cntsel[3:0] to the IOPLL
        set cntsel_width 5
        set en_reconf [get_parameter_value gui_en_reconf]
        if {$enable} {
            if {$en_reconf == "false"} {
                add_interface scanclk conduit end
                add_interface_port scanclk scanclk scanclk input 1
                set_interface_property scanclk ENABLED $enable
            }
            
            add_interface phase_en conduit end
            add_interface_port phase_en phase_en phase_en input 1

            add_interface updn conduit end
            add_interface_port updn updn updn input 1

            add_interface cntsel conduit end
            add_interface_port cntsel cntsel cntsel input $cntsel_width

            add_interface num_phase_shifts conduit end
            add_interface_port num_phase_shifts num_phase_shifts num_phase_shifts input 3
            

            add_interface phase_done conduit end
            set_interface_assignment phase_done "ui.blockdiagram.direction" OUTPUT
            add_interface_port phase_done phase_done phase_done output 1

            set_interface_property phase_en ENABLED $enable
            set_interface_property updn ENABLED $enable
            set_interface_property cntsel ENABLED $enable
            set_interface_property num_phase_shifts ENABLED $enable
            set_interface_property phase_done ENABLED $enable

        }
    } else {
    }
}

proc en_phout_ports { flag enable} {
    set phout_width 8
    if {$enable} {
        add_interface phout conduit end
        set_interface_assignment phout "ui.blockdiagram.direction" OUTPUT
        add_interface_port phout phout phout output $phout_width
        set_interface_property phout ENABLED $enable
    }
}
 
proc en_lvds_ports { flag enable} {
    set device [get_parameter_value device_family]
    set is_nightfury [is_nightfury_device $device]
    set lvds_width 2
    if {$enable && $is_nightfury} {
        add_interface lvds_clk conduit end
        set_interface_assignment lvds_clk "ui.blockdiagram.direction" OUTPUT
        add_interface_port lvds_clk lvds_clk lvds_clk output $lvds_width
        set_interface_property lvds_clk ENABLED $enable
        
        add_interface loaden conduit end
        set_interface_assignment loaden "ui.blockdiagram.direction" OUTPUT
        add_interface_port loaden loaden loaden output $lvds_width
        set_interface_property loaden ENABLED $enable
    }
}
 
proc is_legal_value { value } {

    #Checking if string is empty
    set result 0
    if {$value == ""} {
        set result 0
    } else {
        set result 1
    }
    return $result
}
proc  refclk_switchover_elaboration_validation { flag device} {
    global refclk_width
    set is_nightfury [is_nightfury_device $device]
    if {$device == "Stratix V" || $device == "Arria V" || $device == "Cyclone V" || $device == "Arria V GZ" || $is_nightfury} { 
        set en_refclk_switch [get_parameter_value gui_refclk_switch]
        
        if {$flag == "elaboration"} {

            if {$en_refclk_switch} {
                set refclk_switchover_mode [get_parameter_value gui_switchover_mode]
                set refclk_switchover_delay [get_parameter_value gui_switchover_delay]
                set en_refclk_active_clk [get_parameter_value gui_active_clk]
                set en_refclk_clkbad [get_parameter_value gui_clk_bad]
                set refclk1 [get_parameter_value gui_refclk1_frequency]
                
                #Add the extra refclk if user has decided to enter refclk switchover mode
                add_interface refclk1 clock end
                add_interface_port refclk1 refclk1 refclk1 input $refclk_width
                set_interface_assignment refclk1 "ui.blockdiagram.direction" INPUT
                set_interface_property refclk1 ENABLED $en_refclk_switch
    
                #enable gui params
                enable_refswitch_parameters "true"
               ###################SET PARAMS###################
                set_parameter_value refclk1_frequency  "$refclk1 MHz"
                set_parameter_value pll_clkin_1_src "clk_1" 
                set_parameter_value pll_clk_loss_sw_en "true" 
                set_parameter_value pll_clk_sw_dly $refclk_switchover_delay
                if {$refclk_switchover_mode == "Manual Switchover"} {
                    set_parameter_value pll_auto_clk_sw_en "false" 
                    set_parameter_value pll_manu_clk_sw_en "true" 
                } elseif {$refclk_switchover_mode == "Automatic Switchover"} {
                    set_parameter_value pll_auto_clk_sw_en "true" 
                    set_parameter_value pll_manu_clk_sw_en "false" 
                } elseif { $refclk_switchover_mode == "Automatic Switchover with Manual Override"} {
                    set_parameter_value pll_auto_clk_sw_en "true" 
                    set_parameter_value pll_manu_clk_sw_en "true" 
                } 
                ###################SET PORTS#################### 
                #Add EXTSWITCH signal if user chooses a mode that would use it.
                if {$refclk_switchover_mode == "Manual Switchover" || $refclk_switchover_mode == "Automatic Switchover with Manual Override"} {
                    add_interface extswitch conduit end
                    add_interface_port extswitch extswitch extswitch input 1
                    set_interface_assignment extswitch "ui.blockdiagram.direction" INPUT
                    set_interface_property extswitch ENABLED "true"
                } 
                
                #Add activeclk port if checked 
                if {$en_refclk_active_clk} {
                    add_interface activeclk conduit end
                    add_interface_port activeclk activeclk activeclk output 1
                    set_interface_assignment activeclk "ui.blockdiagram.direction" OUTPUT
                    set_interface_property activeclk ENABLED $en_refclk_active_clk
                }
                
                #Add clkbad ports if checked
                if {$en_refclk_clkbad} {
                    add_interface clkbad conduit end
                    add_interface_port clkbad clkbad clkbad output 2
                    set_interface_assignment clkbad "ui.blockdiagram.direction" OUTPUT
                    set_interface_property clkbad ENABLED $en_refclk_clkbad
                }
                
   
            } else {
                enable_refswitch_parameters "false"
            }
                    
        } elseif {$flag == "validation"} {
            
            if {$en_refclk_switch} {
                set ref_clk [precision_check [get_parameter_value gui_reference_clock_frequency]]
                set ref_clk1 [precision_check [get_parameter_value gui_refclk1_frequency]]
                set refclk_switchover_mode [get_parameter_value gui_switchover_mode]
                set en_refclk_clkbad [get_parameter_value gui_clk_bad]
                set en_refclk_clkbad [get_parameter_value gui_clk_bad]
                if {$ref_clk1 != $ref_clk } {
                    send_message warning "'refclk1' is not the same frequency as 'refclk'. You must run Timequest at both frequencies to ensure timing closure"
                }
                if {($ref_clk1 < [expr $ref_clk*0.8] || $ref_clk1 > [expr $ref_clk*1.2]) && ($refclk_switchover_mode == "Automatic Switchover"|| $refclk_switchover_mode == "Automatic Switchover with Manual Override")} {
                    send_message warning "The period difference between refclk and refclk1 is greater than 20%, automatic clock loss detection will not work"
                }   
                if {($ref_clk1 < [expr $ref_clk*0.5] || $ref_clk1 > [expr $ref_clk*2.0]) && $refclk_switchover_mode == "Manual Switchover" && $en_refclk_clkbad == "true" } {
                    send_message warning "The period difference between refclk and refclk1 is greater than double, 'clkbad' signals are now invalid"
                } 
                set fractional_pll [get_parameter_value fractional_vco_multiplier] 
                set vco_div [get_parameter_value pll_vco_div] 
                set lower_vco 600
                set upper_vco 1600
                if {$vco_div == "2" || $is_nightfury} {  # JK: TODO -- remove the nightfury check
                    set lower_vco 300
                    set upper_vco 800
                }
        
                set k_val [get_parameter_value pll_fractional_division] 
                set m_cnt_val [expr {[get_parameter_value m_cnt_hi_div] + [get_parameter_value m_cnt_lo_div]}]
                set n_cnt_val [expr {[get_parameter_value n_cnt_hi_div] + [get_parameter_value n_cnt_lo_div]}]
                set n_bypass_en [get_parameter_value n_cnt_bypass_en]
                set m_bypass_en [get_parameter_value m_cnt_bypass_en]
                if {$m_bypass_en == "true"} {
                    set m_cnt_val 1
                }
                if {$n_bypass_en == "true"} {
                    set n_cnt_val 1
                }
                set integer_vco [expr $ref_clk1*$m_cnt_val/$n_cnt_val]  
                set carry_out [expr pow(2, 32)]  
                set fractional_vco [expr $ref_clk1*($m_cnt_val + $k_val/$carry_out)/$n_cnt_val]   
                
                if {$fractional_pll == "true"} {
                    set current_vco $fractional_vco
                } else {
                    set current_vco $integer_vco
                }

                if {$current_vco > $upper_vco || $current_vco < $lower_vco } {
                    send_message error "'refclk1' will generate an invalid VCO frequency which will cause unpredictable results. Please change the settings of the PLL or the frequency 'refclk1' to rectify this issue."
                }
            }
        }
    } else {
        #set refclk visible only for stratixv for now
        set_parameter_property gui_refclk_switch VISIBLE false
    }
}

proc enable_refswitch_parameters { enable } {
    global refswitch_params_list
    foreach param_name $refswitch_params_list {
        set_parameter_property $param_name ENABLED $enable
    }
}
proc enable_physical_parameters { enable } {
    global five_series_phys_params_list
    global ten_series_phys_params_list
    set device [get_parameter_value device_family]
    set is_nightfury [is_nightfury_device $device]
    if { $is_nightfury } {
        set phys_params_list $ten_series_phys_params_list
    } else {
        set phys_params_list $five_series_phys_params_list
    }

    foreach param $phys_params_list {
        set param_name [lindex $param 0] 
        set_parameter_property $param_name ENABLED $enable
    }
    
    if { $is_nightfury } {
    } else {
        #set the fractional carry out parameter to enabled/disabled
        set_parameter_property pll_fractional_cout ENABLED $enable
        set_parameter_property pll_dsm_out_sel ENABLED $enable
    }
}
proc my_set_param_visibility { if_name if_visibility } {
    set_parameter_property $if_name VISIBLE $if_visibility
}
proc update_parameter_table {} {
    global five_series_phys_params_list
    global ten_series_phys_params_list
    set current_parameter_list [get_parameters]
    
    set parameter_names_list [list]
    set parameter_values_list [list]
    set num_counters [get_parameter_value gui_number_of_clocks]
    set en_adv [get_parameter_value gui_en_adv_params]
    set device [get_parameter_value device_family]
    set is_nightfury [is_nightfury_device $device]
    if { $is_nightfury } {
        set phys_params_list $ten_series_phys_params_list
    } else {
        set phys_params_list $five_series_phys_params_list
    }
    
    foreach param $phys_params_list {
        set param_full_name [lindex $param 1] 
        set param_name [lindex $param 0] 
                
        #Don't display values of unused counters
        if {[string match "c_cnt_*" $param_name]} {
            #extract the number from the param name
            regsub {[^0-9]+} $param_name "" cnt_index
            if {[expr {$cnt_index > ($num_counters - 1)}]} {
                continue
            }
            # Change the c_cnt_in_src parameter if necessary
            if {[string match "c_cnt_in_src*" $param_name]} {
                if {$en_adv && $cnt_index!=0} {
                    set has_cascade_input [get_parameter_value gui_cascade_counter[expr $cnt_index-1]]
                    # This is redundant in pll_hw_extra, but needed here in order to display the table correctly
                    if {$has_cascade_input} {  
                        set_parameter_value $param_name "cscd_clk"
                    } else {
                        set_parameter_value $param_name "ph_mux_clk"
                    }
                }
            }
        }
        
        lappend parameter_names_list $param_full_name 
        lappend parameter_values_list [get_parameter_value $param_name]
    }
    set_parameter_value gui_parameter_list $parameter_names_list 
    set_parameter_value gui_parameter_values $parameter_values_list 
}

proc  pll_cascading_elaboration_validation { flag device} {
    set is_nightfury_device [is_nightfury_device $device]
    if {$device == "Stratix V" || $device == "Arria V" || $device == "Cyclone V" || $device == "Arria V GZ" || $is_nightfury_device} { 
        set en_pll_cascade_out [get_parameter_value gui_enable_cascade_out]
        set en_pll_cascade_in [get_parameter_value gui_enable_cascade_in]
        set pll_cascading_mode [get_parameter_value gui_pll_cascading_mode]
        set num_count [get_parameter_value gui_number_of_clocks]
        
        if {$flag == "elaboration"} {
            if {$en_pll_cascade_out} {
                # enable all parameters that are used for PLL cascade out
                enable_pll_cascade_out_parameters "true"
                
                # adding port for pll cascade out
                add_interface cascade_out conduit start
                set_interface_property cascade_out ENABLED $en_pll_cascade_out
                set_interface_assignment cascade_out "ui.blockdiagram.direction" OUTPUT
                add_interface_port cascade_out cascade_out export output $num_count
    
                # update output clock index list based on number of clocks selected from General tab
                # This allows user to choose which output clock they want to use for cascading
                set output_clock_index_list [list]
                for { set i 0 } {$i < $num_count} {incr i} {
                    lappend output_clock_index_list $i
                }
                if { !$is_nightfury_device } {
                    set_parameter_property gui_cascade_outclk_index ENABLED "false"
                } else {
                    set_parameter_property gui_cascade_outclk_index ENABLED "true"
                    map_allowed_range gui_cascade_outclk_index $output_clock_index_list
                }
            } else {
                # disable all parameters that are used for PLL cascade out
                enable_pll_cascade_out_parameters "false"
                set_parameter_property gui_cascade_outclk_index ENABLED "false"
            }

            if {$en_pll_cascade_in} {
                # PLL will be used as a downstream PLL
                # enable all parameters that are used for PLL cascade in
                enable_pll_cascade_mode_parameters "true"

                if { $device == "Cyclone V" || $is_nightfury_device } {
                    set_parameter_property gui_pll_cascading_mode ENABLED "false"
                }
                
                if {$pll_cascading_mode == "Create an adjpllin signal to connect with an upstream PLL"} {
                    # Create adjpllin port
                    add_interface adjpllin conduit end
                    set_interface_property adjpllin ENABLED "true"
                    add_interface_port adjpllin adjpllin export input 1
                    set_parameter_value pll_clkin_0_src "adj_pll_clk" 
                } elseif {$pll_cascading_mode == "Create a cclk signal to connect with an upstream PLL"} {
                    # Create cclk port
                    add_interface cclk conduit end
                    set_interface_property cclk ENABLED "true"
                    add_interface_port cclk cclk export input 1
                    set_parameter_value pll_clkin_0_src "fpll" 
                } else {
                    # PLL is not used as a downstream pll
                    # don't need to do anything
                }                            
            } else {
                enable_pll_cascade_mode_parameters "false"
            }
        } 
    } else {
        # disable all the parameters related to cascading feature
        set_parameter_property gui_enable_cascade_out VISIBLE false
        set_parameter_property gui_cascade_outclk_index VISIBLE false
        set_parameter_property gui_enable_cascade_in VISIBLE false
        enable_pll_cascade_out_parameters "false"
        enable_pll_cascade_mode_parameters "false"
    }
}

proc enable_pll_cascade_out_parameters { enable } {
    global pll_cascade_out_params_list
    foreach param_name $pll_cascade_out_params_list {
        set_parameter_property $param_name ENABLED $enable
    }
}

proc enable_pll_cascade_mode_parameters { enable } {
    global pll_cascade_mode_params_list
    foreach param_name $pll_cascade_mode_params_list {
        set_parameter_property $param_name ENABLED $enable
    }
}

# ALTERA_HACK -- Tcl being used to infer the value of a parameter computed in C!
proc enable_odd_div_duty {counter_value desired_duty} {
    set is_counter_bypass [enable_counter_bypass $counter_value]

    if { $is_counter_bypass == "false" } {
		set duty [expr double($desired_duty)/100]
		set cnt  $counter_value
		# Duty cycle calculation : (hi_cnt - 0.5*en)/cnt = duty
		# So it follows that     : 2*hi - en = 2*duty*cnt
		if { [expr round(2*$duty*$cnt) % 2] == 1} {
			# Then 2*duty*cnt is near-odd, which means that the "odd counter-even duty" parameter should be true
			set enable "true"
		} else {
			# Then 2*duty*cnt is near-even, which means that the "odd counter-even duty" parameter should be false
			set enable "false"
		}
	} else {
			set enable "false"
	}
		
    return $enable
}


proc enable_counter_bypass {counter_value} {
    set enable [expr {($counter_value == 1) ? "true" : "false"}] 
    
    return $enable
}

# ALTERA_HACK -- Using Tcl to infer a value that should be returned by the computation code
proc get_counter_hi_div {counter_value} {
    set is_counter_bypass [enable_counter_bypass $counter_value]
    
    if { $is_counter_bypass == "false" } {
        if { $counter_value % 2 == 0 } {
            set counter_hi_div [expr {$counter_value / 2}]
        } else {
            set counter_hi_div [expr {$counter_value / 2 + 1}]
        }
    } else {
		set counter_hi_div 256
	}
    
    return $counter_hi_div
}

# ALTERA_HACK -- Using Tcl to infer a value that should be returned by the computation code
proc get_c_counter_hi_div {counter_value duty_cycle_value} {
	set is_counter_bypass [enable_counter_bypass $counter_value]
	set is_odd_div_duty [enable_odd_div_duty $counter_value $duty_cycle_value]
	set counter_hi_div 256
	if { $is_counter_bypass == "false" } {
		if { $is_odd_div_duty == "false" } {
			set counter_hi_div [expr round($counter_value * $duty_cycle_value / 100.0) ]
		} else {
			set counter_hi_div [expr round($counter_value * $duty_cycle_value / 100.0 + 0.5)]
		}
	}

    return $counter_hi_div
}

# ALTERA_HACK -- Using Tcl to infer a value that should be returned by the computation code
proc get_counter_lo_div {counter_value} {
    set is_counter_bypass [enable_counter_bypass $counter_value]
    set counter_lo_div 256
    if { $is_counter_bypass == "false" } {
        set counter_lo_div [expr {$counter_value / 2}]
    }
    
    return $counter_lo_div
}

# ALTERA_HACK -- Using Tcl to infer a value that should be returned by the computation code
proc get_c_counter_lo_div {counter_value duty_cycle_value} {
    set is_counter_bypass [enable_counter_bypass $counter_value]
    set counter_lo_div 256
    if { $is_counter_bypass == "false" } {
		set counter_hi_div [get_c_counter_hi_div $counter_value $duty_cycle_value]
        set counter_lo_div [expr $counter_value - $counter_hi_div]
    }
    
    return $counter_lo_div
}

proc is_nightfury_device {device} {
    set is_nightfury [expr {$device == "Arria 10"}]
    return $is_nightfury
}

proc get_compensation_mode { } {
    set pll_compensation_mode [get_parameter_value gui_operation_mode]
    set device [get_parameter_value device_family]
    set is_nightfury_device [is_nightfury_device $device]
    if { $is_nightfury_device } {
        if { $pll_compensation_mode == "source synchronous" } {
            set pll_compensation_mode "source_synchronous"
        } elseif { $pll_compensation_mode == "zero delay buffer" } {
            set pll_compensation_mode "zdb"
        } elseif { $pll_compensation_mode == "external feedback" } {
            set pll_compensation_mode "external"
        } else {
            # no op
        }
    }

    return $pll_compensation_mode
}
