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


package provide altera_lvds::core_20::pll 0.1


package require quartus::qcl_pll
package require altera_lvds::util::hwtcl_utils
namespace eval ::altera_lvds::core_20::pll:: {
   
   namespace import ::quartus::qcl_pll::*
   namespace import ::altera_lvds::util::hwtcl_utils::*

}

proc ::altera_lvds::core_20::pll::create_pll_hdl_parameters {} {

    set max_M_HI_DIV 256
    set max_C_HI_DIV 256
    set max_N_HI_DIV 256
    set max_M_LO_DIV 256
    set max_C_LO_DIV 256
    set max_N_LO_DIV 256
 

    add_parameter m_cnt_hi_div INTEGER 1
    set_parameter_property m_cnt_hi_div DEFAULT_VALUE 1
    set_parameter_property m_cnt_hi_div ALLOWED_RANGES {1:$max_M_HI_DIV}
    set_parameter_property m_cnt_hi_div UNITS None
    set_parameter_property m_cnt_hi_div AFFECTS_GENERATION true
    set_parameter_property m_cnt_hi_div IS_HDL_PARAMETER true
    set_parameter_property m_cnt_hi_div VISIBLE false
    set_parameter_property m_cnt_hi_div DERIVED true
    set_parameter_property m_cnt_hi_div ENABLED false

    add_parameter m_cnt_lo_div INTEGER 1
    set_parameter_property m_cnt_lo_div DEFAULT_VALUE 1
    set_parameter_property m_cnt_lo_div ALLOWED_RANGES {1:$max_M_LO_DIV}
    set_parameter_property m_cnt_lo_div UNITS None
    set_parameter_property m_cnt_lo_div AFFECTS_GENERATION true
    set_parameter_property m_cnt_lo_div IS_HDL_PARAMETER true
    set_parameter_property m_cnt_lo_div VISIBLE false
    set_parameter_property m_cnt_lo_div DERIVED true
    set_parameter_property m_cnt_lo_div ENABLED false

    add_parameter n_cnt_hi_div INTEGER 1
    set_parameter_property n_cnt_hi_div DEFAULT_VALUE 1
    set_parameter_property n_cnt_hi_div ALLOWED_RANGES {1:$max_N_HI_DIV}
    set_parameter_property n_cnt_hi_div UNITS None
    set_parameter_property n_cnt_hi_div AFFECTS_GENERATION true
    set_parameter_property n_cnt_hi_div IS_HDL_PARAMETER true
    set_parameter_property n_cnt_hi_div VISIBLE false
    set_parameter_property n_cnt_hi_div DERIVED true
    set_parameter_property n_cnt_hi_div ENABLED false

    add_parameter n_cnt_lo_div INTEGER 1
    set_parameter_property n_cnt_lo_div DEFAULT_VALUE 1
    set_parameter_property n_cnt_lo_div ALLOWED_RANGES {1:$max_N_LO_DIV}
    set_parameter_property n_cnt_lo_div UNITS None
    set_parameter_property n_cnt_lo_div AFFECTS_GENERATION true
    set_parameter_property n_cnt_lo_div IS_HDL_PARAMETER true
    set_parameter_property n_cnt_lo_div VISIBLE false
    set_parameter_property n_cnt_lo_div DERIVED true
    set_parameter_property n_cnt_lo_div ENABLED false

    add_parameter m_cnt_bypass_en STRING "true"
    set_parameter_property m_cnt_bypass_en DEFAULT_VALUE "true"
    set_parameter_property m_cnt_bypass_en ALLOWED_RANGES {"false" "true"}
    set_parameter_property m_cnt_bypass_en UNITS None
    set_parameter_property m_cnt_bypass_en AFFECTS_GENERATION true
    set_parameter_property m_cnt_bypass_en IS_HDL_PARAMETER true
    set_parameter_property m_cnt_bypass_en VISIBLE false
    set_parameter_property m_cnt_bypass_en DERIVED true
    set_parameter_property m_cnt_bypass_en ENABLED false

    add_parameter n_cnt_bypass_en STRING "true" 
    set_parameter_property n_cnt_bypass_en DEFAULT_VALUE "true"
    set_parameter_property n_cnt_bypass_en ALLOWED_RANGES {"false" "true"}
    set_parameter_property n_cnt_bypass_en UNITS None
    set_parameter_property n_cnt_bypass_en AFFECTS_GENERATION true
    set_parameter_property n_cnt_bypass_en IS_HDL_PARAMETER true
    set_parameter_property n_cnt_bypass_en VISIBLE false
    set_parameter_property n_cnt_bypass_en DERIVED true
    set_parameter_property n_cnt_bypass_en ENABLED false


    add_parameter m_cnt_odd_div_duty_en STRING "false"
    set_parameter_property m_cnt_odd_div_duty_en DEFAULT_VALUE "false"
    set_parameter_property m_cnt_odd_div_duty_en ALLOWED_RANGES {"false" "true"}
    set_parameter_property m_cnt_odd_div_duty_en UNITS None
    set_parameter_property m_cnt_odd_div_duty_en AFFECTS_GENERATION true
    set_parameter_property m_cnt_odd_div_duty_en IS_HDL_PARAMETER true
    set_parameter_property m_cnt_odd_div_duty_en VISIBLE false
    set_parameter_property m_cnt_odd_div_duty_en DERIVED true
    set_parameter_property m_cnt_odd_div_duty_en ENABLED false

    add_parameter n_cnt_odd_div_duty_en STRING "false"
    set_parameter_property n_cnt_odd_div_duty_en DEFAULT_VALUE "false"
    set_parameter_property n_cnt_odd_div_duty_en ALLOWED_RANGES {"false" "true"}
    set_parameter_property n_cnt_odd_div_duty_en UNITS None
    set_parameter_property n_cnt_odd_div_duty_en AFFECTS_GENERATION true
    set_parameter_property n_cnt_odd_div_duty_en IS_HDL_PARAMETER true
    set_parameter_property n_cnt_odd_div_duty_en VISIBLE false
    set_parameter_property n_cnt_odd_div_duty_en DERIVED true
    set_parameter_property n_cnt_odd_div_duty_en ENABLED false

    for { set i 0 } {$i < 9} {incr i} {
    add_parameter c_cnt_hi_div$i INTEGER 1
    set_parameter_property c_cnt_hi_div$i DEFAULT_VALUE 1
    set_parameter_property c_cnt_hi_div$i ALLOWED_RANGES {1:$max_C_HI_DIV}
    set_parameter_property c_cnt_hi_div$i UNITS None
    set_parameter_property c_cnt_hi_div$i AFFECTS_GENERATION true
    set_parameter_property c_cnt_hi_div$i IS_HDL_PARAMETER true
    set_parameter_property c_cnt_hi_div$i VISIBLE false
    set_parameter_property c_cnt_hi_div$i DERIVED true
    set_parameter_property c_cnt_hi_div$i ENABLED false

    add_parameter c_cnt_lo_div$i INTEGER 1
    set_parameter_property c_cnt_lo_div$i DEFAULT_VALUE 1
    set_parameter_property c_cnt_lo_div$i ALLOWED_RANGES {1:$max_C_LO_DIV}
    set_parameter_property c_cnt_lo_div$i UNITS None
    set_parameter_property c_cnt_lo_div$i AFFECTS_GENERATION true
    set_parameter_property c_cnt_lo_div$i IS_HDL_PARAMETER true
    set_parameter_property c_cnt_lo_div$i VISIBLE false
    set_parameter_property c_cnt_lo_div$i DERIVED true
    set_parameter_property c_cnt_lo_div$i ENABLED false

    add_parameter c_cnt_prst$i INTEGER 1
    set_parameter_property c_cnt_prst$i DEFAULT_VALUE 1
    set_parameter_property c_cnt_prst$i ALLOWED_RANGES {1:256}
    set_parameter_property c_cnt_prst$i UNITS None
    set_parameter_property c_cnt_prst$i AFFECTS_GENERATION true
    set_parameter_property c_cnt_prst$i IS_HDL_PARAMETER true
    set_parameter_property c_cnt_prst$i VISIBLE false
    set_parameter_property c_cnt_prst$i DERIVED true
    set_parameter_property c_cnt_prst$i ENABLED false

    add_parameter c_cnt_ph_mux_prst$i INTEGER 0
    set_parameter_property c_cnt_ph_mux_prst$i DEFAULT_VALUE 0
    set_parameter_property c_cnt_ph_mux_prst$i ALLOWED_RANGES {0:7}
    set_parameter_property c_cnt_ph_mux_prst$i UNITS None
    set_parameter_property c_cnt_ph_mux_prst$i AFFECTS_GENERATION true
    set_parameter_property c_cnt_ph_mux_prst$i IS_HDL_PARAMETER true
    set_parameter_property c_cnt_ph_mux_prst$i VISIBLE false
    set_parameter_property c_cnt_ph_mux_prst$i DERIVED true
    set_parameter_property c_cnt_ph_mux_prst$i ENABLED false

    add_parameter c_cnt_bypass_en$i STRING "true"
    set_parameter_property c_cnt_bypass_en$i DEFAULT_VALUE "true"
    set_parameter_property c_cnt_bypass_en$i ALLOWED_RANGES {"false" "true"}
    set_parameter_property c_cnt_bypass_en$i UNITS None
    set_parameter_property c_cnt_bypass_en$i AFFECTS_GENERATION true
    set_parameter_property c_cnt_bypass_en$i IS_HDL_PARAMETER true
    set_parameter_property c_cnt_bypass_en$i VISIBLE false
    set_parameter_property c_cnt_bypass_en$i DERIVED true
    set_parameter_property c_cnt_bypass_en$i ENABLED false

    add_parameter c_cnt_odd_div_duty_en$i STRING "false"
    set_parameter_property c_cnt_odd_div_duty_en$i DEFAULT_VALUE "false"
    set_parameter_property c_cnt_odd_div_duty_en$i ALLOWED_RANGES {"false" "true"}
    set_parameter_property c_cnt_odd_div_duty_en$i UNITS None
    set_parameter_property c_cnt_odd_div_duty_en$i AFFECTS_GENERATION true
    set_parameter_property c_cnt_odd_div_duty_en$i IS_HDL_PARAMETER true
    set_parameter_property c_cnt_odd_div_duty_en$i VISIBLE false
    set_parameter_property c_cnt_odd_div_duty_en$i DERIVED true
    set_parameter_property c_cnt_odd_div_duty_en$i ENABLED false
    }

    add_parameter pll_cp_current INTEGER 5
    set_parameter_property pll_cp_current DEFAULT_VALUE 5
    set_parameter_property pll_cp_current ALLOWED_RANGES {5 10 20 30 40}
    set_parameter_property pll_cp_current UNITS None
    set_parameter_property pll_cp_current AFFECTS_GENERATION true
    set_parameter_property pll_cp_current IS_HDL_PARAMETER true
    set_parameter_property pll_cp_current VISIBLE false
    set_parameter_property pll_cp_current DERIVED true
    set_parameter_property pll_cp_current ENABLED false



    add_parameter pll_bwctrl INTEGER 18000
    set_parameter_property pll_bwctrl DEFAULT_VALUE 18000
    set_parameter_property pll_bwctrl ALLOWED_RANGES {500 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000}
    set_parameter_property pll_bwctrl UNITS None
    set_parameter_property pll_bwctrl AFFECTS_GENERATION true
    set_parameter_property pll_bwctrl IS_HDL_PARAMETER true
    set_parameter_property pll_bwctrl VISIBLE false
    set_parameter_property pll_bwctrl DERIVED true
    set_parameter_property pll_bwctrl ENABLED false



    add_parameter pll_output_clk_frequency STRING "0 MHz"
    set_parameter_property pll_output_clk_frequency DEFAULT_VALUE "0 MHz"
    set_parameter_property pll_output_clk_frequency VISIBLE false
    set_parameter_property pll_output_clk_frequency AFFECTS_GENERATION true
    set_parameter_property pll_output_clk_frequency VISIBLE false
    set_parameter_property pll_output_clk_frequency DERIVED true
    set_parameter_property pll_output_clk_frequency IS_HDL_PARAMETER true
    set_parameter_property pll_output_clk_frequency ENABLED false



    add_parameter pll_fbclk_mux_1 STRING "glb"
    set_parameter_property pll_fbclk_mux_1 DEFAULT_VALUE "glb"
    set_parameter_property pll_fbclk_mux_1 UNITS None
    set_parameter_property pll_fbclk_mux_1 AFFECTS_GENERATION true
    set_parameter_property pll_fbclk_mux_1 IS_HDL_PARAMETER true
    set_parameter_property pll_fbclk_mux_1 VISIBLE false
    set_parameter_property pll_fbclk_mux_1 DERIVED true
    set_parameter_property pll_fbclk_mux_1 ENABLED false

    add_parameter pll_fbclk_mux_2 STRING "fb_1"
    set_parameter_property pll_fbclk_mux_2 DEFAULT_VALUE "fb_1"
    set_parameter_property pll_fbclk_mux_2 UNITS None
    set_parameter_property pll_fbclk_mux_2 AFFECTS_GENERATION true
    set_parameter_property pll_fbclk_mux_2 IS_HDL_PARAMETER true
    set_parameter_property pll_fbclk_mux_2 VISIBLE false
    set_parameter_property pll_fbclk_mux_2 DERIVED true
    set_parameter_property pll_fbclk_mux_2 ENABLED false

    add_parameter pll_m_cnt_in_src STRING "ph_mux_clk"
    set_parameter_property pll_m_cnt_in_src DEFAULT_VALUE "ph_mux_clk"
    set_parameter_property pll_m_cnt_in_src UNITS None
    set_parameter_property pll_m_cnt_in_src AFFECTS_GENERATION true
    set_parameter_property pll_m_cnt_in_src IS_HDL_PARAMETER true
    set_parameter_property pll_m_cnt_in_src VISIBLE false
    set_parameter_property pll_m_cnt_in_src DERIVED true
    set_parameter_property pll_m_cnt_in_src ENABLED false

}



proc ::altera_lvds::core_20::pll::set_hardware_pll_parameters {} {

    set mode [get_parameter_value MODE]
    set nstd_outclock [get_parameter_value TX_OUTCLOCK_NON_STD_PHASE_SHIFT] 
    
	set number_of_counters 9
    set device "Arria 10"
    set speed 4 
    set part "NIGHTFURY5_F1932BC2"
	set pll_type "fPLL"
    set reference_clock_frequency [get_parameter_value actual_inclock_frequency]
    set pll_channel_spacing "0.0 MHz" 
    set pll_fractional_vco_multiplier "false"
    set pll_auto_reset "Off"
    set pll_bandwidth_preset "Auto"
    set pll_compensation_mode "lvds"
    set pll_feedback_mode "Global Clock"
	set pll_desired_vco_frequency "100.0 MHz"
    set advanced_param_used "false"  
    
    set reference_list [list]
    
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
    
    lappend reference_list "${reference_clock_frequency} MHz"
	lappend reference_list $pll_desired_vco_frequency
	lappend reference_list $advanced_param_used

    
    
    lappend reference_list [get_parameter_value pll_fclk_frequency]
    lappend reference_list [get_parameter_value pll_fclk_phase_shift]
    lappend reference_list 50
    lappend reference_list [get_parameter_value pll_sclk_frequency]
    lappend reference_list [get_parameter_value pll_loaden_phase_shift]
    lappend reference_list [get_parameter_value pll_loaden_duty_cycle] 
    lappend reference_list [get_parameter_value pll_sclk_frequency]
    lappend reference_list [get_parameter_value pll_sclk_phase_shift]
    lappend reference_list 50
    if {[string_compare $nstd_outclock "true"] && [string_compare $mode "TX"]} {
        lappend reference_list [get_parameter_value pll_tx_outclock_frequency]
        lappend reference_list [get_parameter_value pll_tx_outclock_phase_shift]
        lappend reference_list 50
    } else {
        lappend reference_list 0
        lappend reference_list 0
        lappend reference_list 50
    }    

    for { set i 0 } {$i < 5} {incr i} {
        lappend reference_list 0
        lappend reference_list 0
        lappend reference_list 50
    }
	set phys_params_list [_produce_phys_params_list]

    set param_list [list]
	foreach param $phys_params_list {
		set param_rbc_name [lindex $param 2] 
		append param_rbc_name [lindex $param 3] 
		lappend param_list "$param_rbc_name"
	}
   
    set x_total 0
    set start_t_total [clock clicks -milliseconds]

    set result [::quartus::qcl_pll::get_physical_parameters -reference_list $reference_list -parameter_list $param_list -family $device]
    
    set end_t_total [clock clicks -milliseconds]
    set x_total [expr {$end_t_total - $start_t_total}]
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
        foreach param $phys_params_list {
            set param_name [lindex $param 0] 
            set param_rbc_name [lindex $param 2]
			append param_rbc_name [lindex $param 3] 
            if {![string compare $param_rbc_name $rbc_name]} {
                if {[_is_legal_value $param_value]} {
                set_parameter_value $param_name [lindex [split $param_value |] 0]
                }
            }   
        }
    }	
	if { [string_compare $illegal_vco "true"]} {
		send_message error "The specified configuration causes Voltage-Controlled Oscillator (VCO) to go beyond the limit."
	}
	
}





proc ::altera_lvds::core_20::pll::_precision_check {params} {
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
	return $forth_val
}


proc ::altera_lvds::core_20::pll::_compute_vco_frequency {} {
    
    set fclk_frequency [get_parameter_value pll_fclk_frequency]
    regexp {([-0-9.]+)} $fclk_frequency data_rate_num 
	return [_precision_check $data_rate_num] 
}


proc ::altera_lvds::core_20::pll::_chomp_units {param} {
    
    set value_with_units [get_parameter_value $param]
    regexp {([-0-9.]+)} $value_with_units value 
	return $value  
}

proc ::altera_lvds::core_20::pll::_produce_phys_params_list {} {

    list six_series_phys_params_list

    lappend six_series_phys_params_list [list m_cnt_hi_div "M-Counter Hi Divide" "IOPLL_PLL_M_COUNTER_HIGH" ""]
    lappend six_series_phys_params_list [list m_cnt_lo_div "M-Counter Low Divide" "IOPLL_PLL_M_COUNTER_LOW" ""]
    lappend six_series_phys_params_list [list n_cnt_hi_div "N-Counter Hi Divide" "IOPLL_PLL_N_COUNTER_HIGH" ""]
    lappend six_series_phys_params_list [list n_cnt_lo_div "N-Counter Low Divide" "IOPLL_PLL_N_COUNTER_LOW" ""]
    lappend six_series_phys_params_list [list m_cnt_bypass_en "M-Counter Bypass Enable" "IOPLL_PLL_M_COUNTER_BYPASS_EN" ""]
    lappend six_series_phys_params_list [list n_cnt_bypass_en "N-Counter Bypass Enable" "IOPLL_PLL_N_COUNTER_BYPASS_EN" ""]
    lappend six_series_phys_params_list [list m_cnt_odd_div_duty_en "M-Counter Odd Divide Enable" "IOPLL_PLL_M_COUNTER_EVEN_DUTY_EN" ""]
    lappend six_series_phys_params_list [list n_cnt_odd_div_duty_en "N-Counter Odd Divide Enable" "IOPLL_PLL_N_COUNTER_ODD_DIV_DUTY_EN" ""]

    for { set i 0 } {$i < 9} {incr i} {
    lappend six_series_phys_params_list [list c_cnt_hi_div$i "C-Counter-$i Hi Divide" "IOPLL_PLL_C_COUNTER_$i" "_HIGH"]
    lappend six_series_phys_params_list [list c_cnt_lo_div$i "C-Counter-$i Low Divide" "IOPLL_PLL_C_COUNTER_$i" "_LOW"]
    lappend six_series_phys_params_list [list c_cnt_prst$i "C-Counter-$i Coarse Phase Shift" "IOPLL_PLL_C_COUNTER_$i" "_PRST"]
    lappend six_series_phys_params_list [list c_cnt_ph_mux_prst$i "C-Counter-$i VCO Phase Tap" "IOPLL_PLL_C_COUNTER_$i" "_PH_MUX_PRST"]
    lappend six_series_phys_params_list [list c_cnt_bypass_en$i "C-Counter-$i Bypass Enable" "IOPLL_PLL_C_COUNTER_$i" "_BYPASS_EN"]
    lappend six_series_phys_params_list [list c_cnt_odd_div_duty_en$i "C-Counter-$i Odd Divide Enable" "IOPLL_PLL_C_COUNTER_$i" "_EVEN_DUTY_EN"]
    }

    lappend six_series_phys_params_list [list pll_cp_current "Charge Pump current (uA)" "IOPLL_PLL_CP_CURRENT_SETTING" ""]
    lappend six_series_phys_params_list [list pll_bwctrl "Loop Filter Bandwidth Resistor (Ohms) " "IOPLL_PLL_BWCTRL" ""]
    lappend six_series_phys_params_list [list pll_output_clk_frequency "PLL Output VCO Frequency" "PLL_OUTPUT_CLOCK_FREQUENCY" ""]
    lappend six_series_phys_params_list [list pll_fbclk_mux_1 "Feedback Clock MUX 1" "IOPLL_PLL_FBCLK_MUX_1" ""]
    lappend six_series_phys_params_list [list pll_fbclk_mux_2 "Feedback Clock MUX 2" "IOPLL_PLL_FBCLK_MUX_2" ""]
    lappend six_series_phys_params_list [list pll_m_cnt_in_src "M Counter Source MUX" "IOPLL_PLL_M_COUNTER_IN_SRC" ""]

    return $six_series_phys_params_list 
}




proc ::altera_lvds::core_20::pll::_is_legal_value { value } {

    set result 0
    if {$value == ""} {
        set result 0
    } else {
        set result 1
    }
    return $result
}
proc ::altera_lvds::core_20::pll::_init {} {
}

::altera_lvds::core_20::pll::_init
