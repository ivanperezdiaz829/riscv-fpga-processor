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


## \file pll_calculations.tcl 

package provide altera_xcvr_atx_pll_vi::pll_calculations 13.1

package require alt_xcvr::gui::messages

namespace eval ::altera_xcvr_atx_pll_vi::pll_calculations:: {
   namespace import ::alt_xcvr::ip_tcl::messages::*

   namespace export \
      legality_check_auto \
      legality_check_manual \
      legality_check_feedback_auto \
      
   variable l_counter_list
   variable n_counter_list
   variable m_counter_list
   
   # Set counter enum values  
   ## \open (should be auto populated eventually)
   ## \open should be propogated to parameters eventually 
   set l_counter_list { 1 2 4 8 16 } 
   set n_counter_list { 1 2 4 8 }
   set m_counter_list { 100 80 64 60 50 48 40 36 32 30 25 24 20 18 16 15 12 10  9  8  6  5   4   3   2   1 }   
}

##
# function returns a dictionary where the possible combinations of reference clock frequencies and counter settings are listed for a given output frequency
# @param[in] f_out - desired pll output frequency
# @return dictionary ---> {status good/bad} {"X.Y" {{param_name1 param_value1} {param_name2 param_value2}...}} {status good/bad} {"Z.T" {{param_name1 param_value1} {param_name2 param_value2}...}}... 
proc ::altera_xcvr_atx_pll_vi::pll_calculations::legality_check_auto { f_out } {
   variable l_counter_list
   variable n_counter_list
   variable m_counter_list
   set ref_clk 0
   set find_ref 0
   set ret [find_values $ref_clk $f_out $find_ref $l_counter_list $m_counter_list $n_counter_list]
   return $ret
}

##
# function returns a dictionary where the output frequency and other pll settings are listed for a given reference clock frequency and counter settings
# @param[in] f_ref - pll reference clock frequency
# @param[in] l_value - l counter for the pll
# @param[in] m_value - m counter for the pll
# @param[in] n_value - n counter for the pll
# @return dictionary ---> {status good/bad} {config {{param_name1 param_value1} {param_name2 param_value2}...}}  
proc ::altera_xcvr_atx_pll_vi::pll_calculations::legality_check_manual { f_ref l_value m_value n_value } {
   set ret [verify_counter_settings_with_reference_clock $f_ref $l_value $m_value $n_value]
   return $ret
}

##
# function returns a dictionary where the possible combinations of reference clock frequencies and counter settings are listed for a given output frequency
# @param[in] f_out - desired pll output frequency
# @param[in] f_fb - desired pll feedback frequency
# @param[in] enable_fb_comp - whether unknown external feedback or feedback compensation bonding mode
# @return dictionary ---> {status good/bad} {"X.Y" {{param_name1 param_value1} {param_name2 param_value2}...}} {status good/bad} {"Z.T" {{param_name1 param_value1} {param_name2 param_value2}...}}... 
proc ::altera_xcvr_atx_pll_vi::pll_calculations::legality_check_feedback_auto { f_out f_fb enable_fb_comp } {
   variable n_counter_list

   set modified_n_counter_list $n_counter_list
   if { $enable_fb_comp } {
      set modified_n_counter_list {1}
      ip_message info "Setting N counter to 1 in feedback compensation bonding mode"
   }
   # else use the full N-counter list

   set ret [find_external_feedback_mode_values $f_out $f_fb $modified_n_counter_list]
   return $ret
}

#-----------------------------------------
# INTERNAL FUNCTIONS NOT EXPORTED
#-----------------------------------------

# \open Establish procedures to return relevant virtual attributes (should be auto populated eventually)
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_max_pfd {} { return 350000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_pfd {} { return 100000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_vco {} { return 7000000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_max_vco {} { return 14000000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_ref {} { return 100000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_max_ref {} { return 800000000 }

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_tank_0 {} { return 8000000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_max_tank_0 {} { return 10500000000 }

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_tank_1 {} { return 10500000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_max_tank_1 {} { return 12000000000 }

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_tank_2 {} { return 12000000000 }
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_max_tank_2 {} { return 14000000000 }

# The proc has three use cases:
#
# 1) find_values $f_ref $f_out 0 $l_counter_list $m_counter_list $n_counter_list 
#
# --> The above case is the classic requirement for the HSSI PLL IP

# The following two use cases are likely not required for now but are available for possible future support
#
# In this use case $f_ref is ignored.  Instead all available reference clocks with their associated l, m, and n counters will be provided
#
# 2) find_values $f_ref $f_out 1 $l_counter_list $m_counter_list $n_counter_list 
#
# Given $f_ref and $f_out loop through all values of counters and provide those settings that fulfill this frequency relationship
#
# For the first two use cases it is assumed that the counter lists being passed in are fully populated with all possible values of the counters
# This next use case will instead assume that only a single value of counter is being passed in ... the idea is that if you provide an $f_out
# and a specific set of counter values you want to check whether an f_ref can be found.

proc ::altera_xcvr_atx_pll_vi::pll_calculations::find_values { f_ref f_out find_ref l_counter_list m_counter_list n_counter_list} {
    
	# initialize return status as bad. don't forget to update the status to good once proper settings find
	dict set ret status bad
    
	foreach l $l_counter_list {
		set f_vco [expr $f_out * $l]
                #ip_message info ":::altera_xcvr_atx_pll_vi::pll_calculations::find_values f_vco $f_vco max [get_f_max_vco] min [get_f_min_vco]"
		if {$f_vco >= [get_f_min_vco] && $f_vco <= [get_f_max_vco]} {
			foreach m $m_counter_list {
				set f_pfd_calc [expr $f_vco / ($m * 2)]
                                #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_values f_pfd_calc $f_pfd_calc max [get_f_max_pfd] min [get_f_min_pfd]"
				if {$f_pfd_calc >= [get_f_min_pfd] && $f_pfd_calc <= [get_f_max_pfd]} {
					foreach n $n_counter_list {
						set f_ref_calc [expr $f_pfd_calc * $n]
                                                #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_values f_ref_calc $f_ref_calc max [get_f_max_ref] min [get_f_min_ref]"
						if {$f_ref_calc <= [get_f_max_ref] && $f_ref_calc >= [get_f_min_ref]} {
							if {($find_ref == 1 && $f_ref_calc == $f_ref) || $find_ref == 0} {								
                                                                dict set ret status good
								set refclk [expr $f_ref_calc/1000000]
                                                                set refclk [format "%.6f" $refclk];# 6 fractional digits, \open: is it ok for hdl parameters? 
								set refclk_str "$refclk"
                                                                if { ![dict exists $ret $refclk_str] } {
								   dict set ret $refclk_str m $m
								   dict set ret $refclk_str n $n
								   dict set ret $refclk_str l $l
								   dict set ret $refclk_str k 1
                                                                   set tank_sel [get_tank_sel [get_f_vco $f_out $l]]  
                                                                   dict set ret $refclk_str tank_sel $tank_sel
                                                                   dict set ret $refclk_str tank_band [get_tank_band [get_f_vco $f_out $l] [get_f_min_tank $tank_sel] [get_f_increment_tank $tank_sel]]
                                                                   #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_values single-freq(1/0): $find_ref fref: $f_ref_calc n: $n  l: $l  m: $m"
                                                                } else {
                                                                   # If refclk repeats with different counter settings ignore it, as the first setting found will be optimal
                                                                   #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_values refclk already exists"
                                                                }
							}							
						}
					}
				}
			}
		}
	}
	return $ret
}

# This proc will be used to return the Fout produced when the user specifies Fref and the counter values
proc ::altera_xcvr_atx_pll_vi::pll_calculations::verify_counter_settings_with_reference_clock { f_ref l_value m_value n_value } {
	# initialize return status as bad. don't forget to update the status to good once proper settings find
	dict set ret status bad
        #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::verify_counter_settings_with_reference_clock f_ref $f_ref max [get_f_max_ref] min [get_f_min_ref]"
	if {$f_ref >= [get_f_min_ref] && $f_ref <= [get_f_max_ref]} {
		set f_pfd_calc [expr $f_ref / $n_value]
                #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::verify_counter_settings_with_reference_clock f_pfd_calc $f_pfd_calc max [get_f_max_pfd] min [get_f_min_pfd]"
		if {$f_pfd_calc >= [get_f_min_pfd] && $f_pfd_calc <= [get_f_max_pfd]} {
			set f_vco_calc [expr $f_pfd_calc * 2 * $m_value]
                        #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::verify_counter_settings_with_reference_clock f_vco_calc $f_vco_calc max [get_f_max_vco] min [get_f_min_vco]"
			if {$f_vco_calc >= [get_f_min_vco] && $f_vco_calc <= [get_f_max_vco]} {
				dict set ret status good				
				set out_freq [expr $f_vco_calc/$l_value]
                                set out_freq_MHz [expr $out_freq/1000000]
                                set out_freq_MHz [format "%.6f" $out_freq_MHz];# 6 fractional digits, \open: is it ok for hdl parameters?
				dict set ret config out_freq "$out_freq_MHz MHz"
				set tank_sel [get_tank_sel [get_f_vco $out_freq $l_value]]
                                dict set ret config tank_sel $tank_sel 
                                dict set ret config tank_band [get_tank_band [get_f_vco $out_freq $l_value] [get_f_min_tank $tank_sel] [get_f_increment_tank $tank_sel]]
				#ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::verify_counter_settings_with_reference_clock out: $out_freq MHz"				
			}
		}
	}
	return $ret
}

# This proc returns in the same way as find_values proc, except this one is used for external feedback clock modes hence uses a different algorithm
# n counter list input is determined by the caller based on feedback modes 
proc ::altera_xcvr_atx_pll_vi::pll_calculations::find_external_feedback_mode_values { f_out f_fb n_counter_list } {
   variable l_counter_list

   # initialize return status as bad. don't forget to update the status to good once proper settings find
   dict set ret status bad

   # Going to select the first legal l value found 
   set l_value 0
   set n_value 0
   foreach l $l_counter_list {
      if {$l_value == 0} {
         set f_vco [expr $f_out * $l]
         if {$f_vco >= [get_f_min_vco] && $f_vco <= [get_f_max_vco]} {
            set l_value $l
         }
      }
   }

   if {$l_value != 0} {#when a proper l value found, continue
      foreach n $n_counter_list {
         set f_ref_calc [expr $f_fb * $n]
         if {$f_ref_calc <= [get_f_max_ref] && $f_ref_calc >= [get_f_min_ref]} {
            set m_calc [expr $f_out / $f_fb ]
            set n_value $n
            #puts "$f_ref_calc n: $n_value  l: $l_value  m: $m_calc";
            dict set ret status good
            set refclk [expr $f_ref_calc/1000000]
            set refclk [format "%.6f" $refclk];# 6 fractional digits, \open: is it ok for hdl parameters? 
            set refclk_str "$refclk"
            if { ![dict exists $ret $refclk_str] } {
               #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_external_feedback_mode_values:: In external feedback clock mode(s), value of M counter is irrelevant, setting it to 10"
               dict set ret $refclk_str m 10
               dict set ret $refclk_str effective_m $m_calc
               dict set ret $refclk_str n $n_value
               dict set ret $refclk_str l $l_value
               dict set ret $refclk_str k 1
               set tank_sel [get_tank_sel [get_f_vco $f_out $l_value]]  
               dict set ret $refclk_str tank_sel $tank_sel
               dict set ret $refclk_str tank_band [get_tank_band [get_f_vco $f_out $l_value] [get_f_min_tank $tank_sel] [get_f_increment_tank $tank_sel]]
               #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_values single-freq(1/0): $find_ref fref: $f_ref_calc n: $n  l: $l  m: $m"
            } else {
               # If refclk repeats with different counter settings ignore it, as the first setting found will be optimal
               #ip_message info "::altera_xcvr_atx_pll_vi::pll_calculations::find_values refclk already exists"
            }
         }
      }
   }


   return $ret
}

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_vco { f_out l } {
	set f_vco [expr $f_out * $l]
	return $f_vco
}

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_tank_sel { vco_freq } { 
	set tank_sel "lctank0"
	if {$vco_freq < [get_f_max_tank_0]} {
		set tank_sel "lctank0"
	} elseif {$vco_freq >= [get_f_max_tank_0] && $vco_freq < [get_f_max_tank_1]} {
		set tank_sel "lctank1"
	} elseif {$vco_freq >= [get_f_max_tank_1] && $vco_freq <= [get_f_max_tank_2]} {
		set tank_sel "lctank2"
	}
	return $tank_sel
}

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_min_tank { tank_sel } {
	set f_min_tank 0
	if {$tank_sel == "lctank0"} {
		set f_min_tank [get_f_min_tank_0]
	} elseif {$tank_sel == "lctank1"} {
		set f_min_tank [get_f_min_tank_1]
	} elseif {$tank_sel == "lctank2"} {
		set f_min_tank [get_f_min_tank_2]
	}
	return $f_min_tank
}

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_f_increment_tank { tank_sel } {
	set f_increment_tank 0
	if {$tank_sel == "lctank0"} {
		set f_increment_tank [expr ([get_f_max_tank_0] - [get_f_min_tank_0]) / 7]
	} elseif {$tank_sel == "lctank1"} {
		set f_increment_tank [expr ([get_f_max_tank_1] - [get_f_min_tank_1]) / 7]
	} elseif {$tank_sel == "lctank2"} {
		set f_increment_tank [expr ([get_f_max_tank_2] - [get_f_min_tank_2]) / 7]
	}
	return $f_increment_tank
}

proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_tank_band { vco_freq f_min_tank f_increment_tank } {
	set tank_band "lc_band0"
	if {$vco_freq < ($f_min_tank + $f_increment_tank)} {
		set tank_band "lc_band0"
	} elseif {$vco_freq >= ($f_min_tank + $f_increment_tank) && $vco_freq < ($f_min_tank + ($f_increment_tank * 2))} {
		set tank_band "lc_band1"
	} elseif {$vco_freq >= ($f_min_tank + $f_increment_tank) && $vco_freq < ($f_min_tank + ($f_increment_tank * 3))} {
		set tank_band "lc_band2"
	} elseif {$vco_freq >= ($f_min_tank + $f_increment_tank) && $vco_freq < ($f_min_tank + ($f_increment_tank * 4))} {
		set tank_band "lc_band3"
	} elseif {$vco_freq >= ($f_min_tank + $f_increment_tank) && $vco_freq < ($f_min_tank + ($f_increment_tank * 5))} {
		set tank_band "lc_band4"
	} elseif {$vco_freq >= ($f_min_tank + $f_increment_tank) && $vco_freq < ($f_min_tank + ($f_increment_tank * 6))} {
		set tank_band "lc_band5"
	} elseif {$vco_freq >= ($f_min_tank + $f_increment_tank) && $vco_freq < ($f_min_tank + ($f_increment_tank * 7))} {
		set tank_band "lc_band6"
	}
	return $tank_band
}

## \open l_counter enable currently is used as a parameter in GUI? 
proc ::altera_xcvr_atx_pll_vi::pll_calculations::l_counter_enable_rule { f_out } {
	set return_value "TRUE"
	if {$f_out > [get_f_min_vco]} {
		set return_value "FALSE"
	}
	return $return_value
}

## \open find out the mapped hdl parameter
proc ::altera_xcvr_atx_pll_vi::pll_calculations::get_hclk_divide { m_value } {
	set hclk_divide "0"
	if {$m_value == 1} {
		set hclk_divide "0" 
	} elseif {$m_value == 2} {
		set hclk_divide "0" 
	} elseif {$m_value == 3} {
		set hclk_divide "3" 
	} elseif {$m_value == 4} {
		set hclk_divide "0" 
	} elseif {$m_value == 5} {
		set hclk_divide "5" 
	} elseif {$m_value == 6} {
		set hclk_divide "6" 
	} elseif {$m_value == 8} {
		set hclk_divide "8" 
	} elseif {$m_value == 9} {
		set hclk_divide "3" 
	} elseif {$m_value == 10} {
		set hclk_divide "10" 
	} elseif {$m_value == 12} {
		set hclk_divide "12" 
	} elseif {$m_value == 15} {
		set hclk_divide "5" 
	} elseif {$m_value == 16} {
		set hclk_divide "16" 
	} elseif {$m_value == 18} {
		set hclk_divide "6" 
	} elseif {$m_value == 20} {
		set hclk_divide "20" 
	} elseif {$m_value == 24} {
		set hclk_divide "6" 
	} elseif {$m_value == 25} {
		set hclk_divide "5" 
	} elseif {$m_value == 30} {
		set hclk_divide "10" 
	} elseif {$m_value == 32} {
		set hclk_divide "8" 
	} elseif {$m_value == 36} {
		set hclk_divide "12" 
	} elseif {$m_value == 40} {
		set hclk_divide "10" 
	} elseif {$m_value == 48} {
		set hclk_divide "12" 
	} elseif {$m_value == 50} {
		set hclk_divide "10" 
	} elseif {$m_value == 60} {
		set hclk_divide "20" 
	} elseif {$m_value == 64} {
		set hclk_divide "16" 
	} elseif {$m_value == 80} {
		set hclk_divide "16" 
	} elseif {$m_value == 100} {
		set hclk_divide "20" 
	}
	return $hclk_divide
}

# \open will be updated eventually
# caliberation_mode = "CAL_OFF"
# lc_mode = "LCCMU_NORMAL"
# lc_atb = "ATB_SELECTDISABLE"
# cp_compensation_enable = "TRUE"
# cp_current_setting = "0" --> Should modify this to be an enum in the atom map
# cp_testmode = "CP_NORMAL"
# cp_lf_3rd_pole_freq = "LF_3RD_POLE_SETTING0"
# cp_lf_4rd_pole_freq = "LF_4RD_POLE_SETTING0"
# cp_lf_order = "LF_2ND_ORDER"
# lf_resistance = "0" --> Should modify this to be an enum in the atom map
# lf_ripplecap = "LF_RIPPLE_CAP"
# d2a_voltage = "D2A_DISABLE"
# dsm_mode = "DSM_MODE_INTEGER"
# dsm_out_sel = "PLL_DSM_DISABLE"
# dsm_ecn_bypass = "FALSE"
# dsm_ecn_test_en = "FALSE"
# fb_select = "???" --> Set by UI
# iqclk_mux_sel = "POWER_DOWN"
# vco_bypass_enable = "FALSE"
# l_counter --> Set by rule
# l_counter_enable --> Set by rule
# cascadeclk_test = "CASCADETEST_OFF"
# hclk_divide --> Set by rule
# m_counter --> Set by rule
# ref_clk_div --> Set by rule
# tank_sel --> Set by rule
# tank_band --> Set by rule
# tank_voltage_coarse = "VREG_SETTING_COARSE1"
# tank voltage_fine = "VREG_SETTING3"
# output_regulator_supply = "VREG1V_SETTING1"
# overrange_voltage = "OVER_SETTING3"
# underrange_voltage = "UNDER_SETTING3"
# vreg0_output = "VCCDREG_NOMINAL"
# vreg1_output = "VCCDREG_NOMINAL"
# bw_sel --> Set by UI
# cgb_div --> Set by UI
# is_cascaded_pll --> Perhaps set by UI
# pma_width --> Set by UI
# output_clock_frequency --> Set by UI
# prot_mode --> Set by UI
# reference_clock_frequency --> Set by UI
# silicon_rev --> Set by UI
# speed_grade --> Set by UI
# use_default_base_address = "??"
# user_base_address = "??"

 
