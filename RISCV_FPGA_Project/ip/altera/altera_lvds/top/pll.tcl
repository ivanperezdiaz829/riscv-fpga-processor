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


package provide altera_lvds::top::pll 0.1

package require altera_lvds::util::hwtcl_utils
package require quartus::advanced_pll_legality

namespace eval ::altera_lvds::top::pll:: {
    
    namespace import ::altera_lvds::util::hwtcl_utils::*

    namespace export get_pll_spec
    namespace export calculate_actual_inclock_frequency
    namespace export get_legal_vco
    namespace export get_achievable_freqs
    namespace export get_achievable_phases
}



proc ::altera_lvds::top::pll::calculate_actual_inclock_frequency {rate refclk} {

    set F_PFD_MAX [get_pll_spec PFD_MAX]  
    set F_PFD_MIN [get_pll_spec PFD_MIN]
    set F_VCO_MAX [get_pll_spec VCO_MAX]
    set F_VCO_MIN [get_pll_spec VCO_MIN]

   
    set target_vco [get_legal_vco $rate]


    set MAX_N [expr {int(floor($refclk/$F_PFD_MIN))}]
    set MIN_N [expr {int(ceil($refclk/$F_PFD_MAX))}]
    set MAX_M 1024
    set index 0 
    
    set best_rational [_get_best_rational_for_pll [expr {double($target_vco)/$refclk}] \
                                                  $MAX_M $MAX_N $MIN_N]  

    for {set index 0} { $index < [llength $best_rational] } {incr index} {
        set m_n_pair [lindex $best_rational [expr {([llength $best_rational]) - $index - 1 }]] 
        set m_counter [lindex $m_n_pair 0]
        set n_counter [lindex $m_n_pair 1]
        lappend actual_refclk [format "%.6f" [expr {double($target_vco)*$n_counter/$m_counter}]]
     } 
     return $actual_refclk
}


proc ::altera_lvds::top::pll::get_legal_vco { data_rate } {

    set F_VCO_MIN [get_pll_spec VCO_MIN]


    if {$F_VCO_MIN > $data_rate} {
        set target_vco [format "%.6f" [expr {ceil($F_VCO_MIN/$data_rate)*$data_rate}]]
    } else {
        set target_vco $data_rate
    } 
    return $target_vco
}




proc ::altera_lvds::top::pll::get_pll_spec { spec } {
   
    set speedgrade [get_parameter_value PLL_SPEED_GRADE]

    if {[string_compare $spec PFD_MAX]} {
        return 325.000000
    } elseif {[string_compare $spec PFD_MIN]} {
        return 10.000000
    } elseif {[string_compare $spec VCO_MAX]} {
        if {$speedgrade == 2} { 
            return 1600.000000
        } elseif {$speedgrade == 3 } {
            return 1400.000000 
        } else { 
            return 1200.000000
        } 
    } elseif {[string_compare $spec VCO_MIN]} {
       return 600.000000
    } elseif {[string_compare $spec REF_MAX]} {
        if {$speedgrade == 2} {
            return 800.000000
        } elseif {$speedgrade == 3 } {
            return 700.000000 
        } else {
            return 600.000000
        } 
   } elseif {[string_compare $spec REF_MIN]} {
        return 10.0000000
   }
   return -1
}    




proc ::altera_lvds::top::pll::get_achievable_freqs {outclk_freq refclk_freq} {

    set rate [get_parameter_value DATA_RATE]
    set refclk [get_parameter_value INCLOCK_FREQUENCY]

    lappend reference_list [_get_reference_item "device_part"]
    lappend reference_list "$refclk_freq MHz"
    lappend reference_list [_get_reference_item "fractional_vco_multiplier"]
    lappend reference_list [_get_reference_item "pll_type"]
    lappend reference_list [_get_reference_item "channel_spacing"]
    lappend reference_list ""
    lappend reference_list ""
    lappend reference_list ""
    lappend reference_list ""
    lappend reference_list "$outclk_freq MHz"
    lappend reference_list "0 ps"
    lappend reference_list 50
    for {set index 1} {$index < 18} {incr index} {
        lappend reference_list "0 MHz"
        lappend reference_list "0 ps"
        lappend reference_list 50
    }    

    set achievable_fclk [::quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values \
                                                            -flow_type MEGAWIZARD \
                                                            -configuration_name GENERIC_PLL \
                                                            -rule_name  PLL_OUTPUT_CLOCK_FREQUENCY \
                                                            -param_args $reference_list]
	regsub {([\{]+)} $achievable_fclk {} achievable_fclk 
    regsub {([\}]+)} $achievable_fclk {} achievable_fclk 
	set result_array [split $achievable_fclk |]
}


proc ::altera_lvds::top::pll::get_achievable_phases {outclk_freq outclk_shift refclk_freq} {

    set fclk_freq [get_parameter_value pll_fclk_frequency]
    set refclk [get_parameter_value INCLOCK_FREQUENCY]

    lappend reference_list [_get_reference_item "device_part"]
    lappend reference_list "$refclk_freq MHz"
    lappend reference_list "$outclk_freq MHz"
    lappend reference_list "$outclk_shift ps"
    lappend reference_list 50
    lappend reference_list [_get_reference_item "fractional_vco_multiplier"]
    lappend reference_list [_get_reference_item "pll_type"]
    lappend reference_list [_get_reference_item "channel_spacing"]
    
    lappend reference_list "$outclk_freq MHz"
    lappend reference_list "0 ps"
    lappend reference_list 50

    lappend reference_list $fclk_freq
    lappend reference_list "0 ps"
    lappend reference_list 50 

    for {set index 2} {$index < 17} {incr index} {
        lappend reference_list "0 MHz"
        lappend reference_list "0 ps"
        lappend reference_list 50
    }    

    set achievable_phases [::quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values \
                                                            -flow_type MEGAWIZARD \
                                                            -configuration_name GENERIC_PLL \
                                                            -rule_name  PHASE_SHIFT \
                                                            -param_args $reference_list]
	regsub {([\{]+)} $achievable_phases {} achievable_phases 
    regsub {([\}]+)} $achievable_phases {} achievable_phases 
	set result_array [split $achievable_phases |]
}





proc ::altera_lvds::top::pll::_get_reference_item {item} {


    if {[string_compare $item "speed"]} {
        return get_parameter_value PLL_SPEED_GRADE
    } elseif {[string_compare $item "device_part"]} {
        return "6AGX1000RF40I3S"
    } elseif {[string_compare $item "pll_type"]} {
        return "fPLL"
    } elseif {[string_compare $item "channel_spacing"]} {
        return "0.0 MHz"
    } elseif {[string_compare $item "fractional_vco_multiplier"]} {
        return "false"
    }    

    return ""
} 


proc ::altera_lvds::top::pll::_get_best_rational_for_pll {   dbl        \
                                                    {max_m 1024}    \
                                                    {max_n 1024}    \
                                                    {min_n 1   }
                                                    {precision 0.0000005}} {
    set min_err dbl
    set result "" 
    
    for {set n $min_n} {$n <= $max_n} {incr n} {
        set m [expr {round($dbl*$n)}]
        if {[expr {abs(double($m)/$n - $dbl)}] < $precision && $m <= $max_m } {
        return [list [list $m $n]]
        } elseif {[expr {abs(double($m)/$n - $dbl)}] < $min_err && $m <= $max_m  } {
            set min_err [expr abs(double($m)/$n - $dbl)]
            lappend result [list $m $n]
        } elseif { $m > $max_m } {
            break
        }    
    }     
    return $result
}    
    


proc ::altera_lvds::top::pll::_init {} {
}

::altera_lvds::top::pll::_init

