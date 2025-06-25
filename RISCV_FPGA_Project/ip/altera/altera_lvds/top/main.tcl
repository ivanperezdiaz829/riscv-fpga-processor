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


package provide altera_lvds::top::main 0.1

package require altera_lvds::util::hwtcl_utils
package require altera_lvds::top::pll

namespace eval ::altera_lvds::top::main:: {
    
    namespace import ::altera_lvds::util::hwtcl_utils::*
    namespace import ::altera_lvds::top::pll::*

}


proc ::altera_lvds::top::main::create_parameters {} {

    add_user_param      MODE                                    string      "TX"            {"TX" "RX_Non-DPA" "RX_DPA-FIFO" "RX_Soft-CDR"}  ""     "radio"                                true
    add_user_param      USE_EXTERNAL_PLL                        boolean     false           ""                      ""                              ""                                     true
    add_user_param      USE_CLOCK_PIN                           boolean     false           ""                      ""                              ""                                     true
    add_user_param      NUM_CHANNELS                            integer     1               {1:24}                  ""                              ""                                     true
    add_user_param      J_FACTOR                                integer     10              {3 4 5 6 7 8 9 10}      ""                              ""                                     true
    add_user_param      DATA_RATE                               float       1000.0          {5.0:1600.0}            "MegabitsPerSecond"             ""                                     true
    add_user_param      INCLOCK_FREQUENCY                       float       100.0           {5:800}                 "Megahertz"                     ""                                     true
    add_user_param      ACTUAL_INCLOCK_FREQUENCY                float       100.000000      {100.000000}            "Megahertz"                     ""                                     true
    add_user_param      RX_USE_BITSLIP                          boolean     "false"         ""                      ""                           ""                                     true
    add_user_param      RX_INCLOCK_PHASE_SHIFT                  integer     0               ""                      ""                           ""                                     true
    add_user_param      RX_INCLOCK_PHASE_SHIFT_ACTUAL           integer     0               {0}                      
    
    add_user_param      RX_BITSLIP_USE_RESET                    boolean     "false"         ""
    add_user_param      RX_BITSLIP_ASSERT_MAX                   boolean     "false"         ""
    
    add_user_param      RX_DPA_USE_RESET                        boolean     "false"         ""    
    add_user_param      RX_DPA_LOSE_LOCK_ON_ONE_CHANGE          boolean     "false"         ""
    add_user_param      RX_DPA_ALIGN_TO_RISING_EDGE_ONLY        boolean     "false"         ""
    add_user_param      RX_DPA_LOCKED_USED                      boolean     "false"         ""
    add_user_param      RX_DPA_USE_HOLD                         boolean     "false"         ""

         
    add_user_param      RX_FIFO_USE_RESET                       boolean     "false"         ""
    add_user_param      RX_CDR_SIMULATION_PPM_DRIFT             integer    0               {-1000:1000}            "Picoseconds" 
    
    
    
    add_user_param      TX_USE_OUTCLOCK                         boolean     "true"          ""                      ""                           ""                                     true
    add_user_param      TX_OUTCLOCK_DIVISION                    integer     1               {1 2 10}                ""                           ""                                     true
    add_user_param      TX_OUTCLOCK_PHASE_SHIFT                 integer     0               ""                      ""                           ""                                     true
    add_user_param      TX_OUTCLOCK_PHASE_SHIFT_ACTUAL          integer     0               ""                      
    add_user_param      TX_EXPORT_CORECLOCK                     boolean     "false"         ""
    
    add_user_param      PLL_CORECLOCK_RESOURCE                  string      "Auto"          {"Auto" "Regional" "Global"}
    add_user_param      PLL_SPEED_GRADE                         integer     4               {2:4}
    add_user_param      PLL_EXPORT_LOCK                         boolean     "false"         ""
    add_user_param      PLL_USE_RESET                           boolean     "true"          ""

   
    add_derived_param   pll_fclk_frequency                      string      "100.0 MHz"     false
    add_derived_param   pll_fclk_phase_shift                    string      "0 ps"          false

    add_derived_param   pll_sclk_frequency                      string      "10.0 MHz"      false
    add_derived_param   pll_sclk_phase_shift                    string      "0 ps"          false
    
    add_derived_param   pll_loaden_frequency                    string      "10.0 MHz"      false
    add_derived_param   pll_loaden_phase_shift                  string      "0 ps"          false
    add_derived_param   pll_loaden_duty_cycle                   integer     10              false
    
    add_derived_param   pll_tx_outclock_frequency               string      "0 ps"          false 
    add_derived_param   pll_tx_outclock_phase_shift             string      "0 ps"          false 
    
    add_derived_param   pll_vco_frequency                       string      "0 ps"          false 
    add_derived_param   pll_inclock_frequency                   string      "10.0 MHz"      false


    add_derived_param   GUI_CLOCK_PARAM_NAMES                   STRING_LIST ""              true
    add_derived_param   GUI_CLOCK_PARAM_VALUES                  STRING_LIST ""              true
    


    return 1
}


proc ::altera_lvds::top::main::add_display_items {} {

    set general_tab [get_string TAB_GENERAL_NAME]
    set rx_tab  [get_string TAB_RX_SETTINGS_NAME]
    set tx_tab  [get_string TAB_TX_SETTINGS_NAME]
    set clocking_tab [get_string TAB_CLOCKING_NAME]

    set top_tab [get_string TAB_TOP_LEVEL_SETTINGS_NAME]
    set pll_tab [get_string TAB_PLL_SETTINGS_NAME]
    set clock_resources [get_string TAB_CLOCK_RESOURCES_NAME]
    set dpa_tab [get_string TAB_DPA_SETTINGS_NAME]
    set bslip_tab [get_string TAB_BITSLIP_SETTINGS_NAME]
    set non_dpa_tab [get_string TAB_NON_DPA_SETTINGS_NAME]
 
 
    add_display_item "" $general_tab        GROUP tab
    add_display_item "" $pll_tab            GROUP tab
    add_display_item "" $rx_tab             GROUP tab
    add_display_item "" $tx_tab             GROUP tab
    add_display_item "" $clock_resources    GROUP tab
    add_display_item $general_tab   $top_tab                GROUP
   
    add_display_item $rx_tab        $bslip_tab              GROUP 
    add_display_item $rx_tab        $dpa_tab                GROUP 
    add_display_item $rx_tab        $non_dpa_tab            GROUP
    
 
    add_param_to_gui $general_tab       MODE 
    add_param_to_gui $general_tab       NUM_CHANNELS 
    add_param_to_gui $general_tab       DATA_RATE
    add_param_to_gui $general_tab       J_FACTOR  
    add_param_to_gui $general_tab       USE_CLOCK_PIN 
    add_param_to_gui $general_tab       USE_EXTERNAL_PLL


    add_param_to_gui $pll_tab       INCLOCK_FREQUENCY     
    add_param_to_gui $pll_tab       ACTUAL_INCLOCK_FREQUENCY
    add_param_to_gui $pll_tab       PLL_SPEED_GRADE
    add_param_to_gui $pll_tab       PLL_EXPORT_LOCK
    add_param_to_gui $pll_tab       PLL_USE_RESET 
    add_param_to_gui $pll_tab       PLL_CORECLOCK_RESOURCE

    add_param_to_gui $bslip_tab     RX_USE_BITSLIP
    add_param_to_gui $bslip_tab     RX_BITSLIP_USE_RESET
    add_param_to_gui $bslip_tab     RX_BITSLIP_ROLLOVER
    add_param_to_gui $bslip_tab     RX_BITSLIP_ASSERT_MAX
    
    add_param_to_gui $dpa_tab       RX_DPA_USE_RESET
    add_param_to_gui $dpa_tab       RX_DPA_LOCKED_USED
    add_param_to_gui $dpa_tab       RX_FIFO_USE_RESET
    add_param_to_gui $dpa_tab       RX_DPA_USE_HOLD
    
    add_param_to_gui $dpa_tab       RX_DPA_LOSE_LOCK_ON_ONE_CHANGE
    add_param_to_gui $dpa_tab       RX_DPA_ALIGN_TO_RISING_EDGE_ONLY
    add_param_to_gui $dpa_tab       RX_CDR_SIMULATION_PPM_DRIFT

    add_param_to_gui $non_dpa_tab   RX_INCLOCK_PHASE_SHIFT
    add_param_to_gui $non_dpa_tab   RX_INCLOCK_PHASE_SHIFT_ACTUAL

    add_param_to_gui $tx_tab        TX_USE_OUTCLOCK
    add_param_to_gui $tx_tab        TX_OUTCLOCK_PHASE_SHIFT
    add_param_to_gui $tx_tab        TX_OUTCLOCK_PHASE_SHIFT_ACTUAL
    add_param_to_gui $tx_tab        TX_OUTCLOCK_DIVISION
    add_param_to_gui $tx_tab        TX_EXPORT_CORECLOCK

    add_display_item $clock_resources "Clock Resource Summary" GROUP TABLE
    set_display_item_property "Clock Resource Summary"  DISPLAY_HINT { table fixed_size rows:15 }
    add_display_item "Clock Resource Summary" GUI_CLOCK_PARAM_NAMES parameter
    add_display_item "Clock Resource Summary" GUI_CLOCK_PARAM_VALUES parameter

   return 1
}

proc ::altera_lvds::top::main::composition_callback {} {

    

    
    _compose
    
}

proc ::altera_lvds::top::main::validation_callback {} {

    
    _validate
}


proc ::altera_lvds::top::main::generate_verilog_sim {name} {

    set tb_param_list [_generate_altera_lvds_tb_parameters]
    add_fileset_file my_altera_lvds_tb_parameters.v VERILOG TEXT $tb_param_list

}





proc ::altera_lvds::top::main::_validate {} {

    _validate_settable_parameters
    _generate_pll_parameters 
    _set_derived_visible_parameters
}

proc ::altera_lvds::top::main::_compose {} {

    set core_component altera_lvds_core20
    set core_name core
    
    add_instance $core_name $core_component
     
    foreach param_name [get_parameters] {
       set param_val [get_parameter_value $param_name]
       set_instance_parameter_value $core_name $param_name $param_val
    }

    altera_lvds::top::main::export_all_interfaces_of_sub_component $core_name

    return 1
}

proc ::altera_lvds::top::main::rename_exported_interface_ports {instance_name interface_name exported_interface_name} {

   
   set port_map [list]
   foreach port_name [get_instance_interface_ports $instance_name $interface_name] {
      lappend port_map $port_name
      lappend port_map $port_name
   }
   set_interface_property $exported_interface_name PORT_NAME_MAP $port_map
   return 1
}




proc ::altera_lvds::top::main::_export_single_port_interface {if_name if_type if_dir inst_name inst_if} {
         
   add_interface $if_name $if_type $if_dir
   set_interface_property $if_name EXPORT_OF "${inst_name}.${inst_if}"
     
   set port_map [list]
   set port_name [get_instance_interface_ports $inst_name $inst_if] 
      lappend port_map $if_name
      lappend port_map [lindex $port_name 0]

   set_interface_property $if_name PORT_NAME_MAP $port_map
   return 1
} 


proc ::altera_lvds::top::main::export_all_interfaces_of_sub_component {inst_name} {   

    set i 0
    foreach if_name [get_instance_interfaces $inst_name] {
        if {[regexp -lineanchor "\^(.*?)_(clock|reset|avalon|avalon_streaming|conduit)_(master|slave|source|sink|end)\$" $if_name matched if_short_name if_type if_dir ] } {
      
            add_interface $if_short_name $if_type $if_dir
            set_interface_property $if_short_name EXPORT_OF "${inst_name}.${if_name}"
         
            rename_exported_interface_ports $inst_name $if_name $if_short_name
            incr i
            }
        }
    return $i
}


proc ::altera_lvds::top::main::_generate_pll_parameters {} { 

    set mode [get_parameter_value MODE]
    set rate [get_parameter_value DATA_RATE]
    set uses_clock_pin [get_parameter_value USE_CLOCK_PIN]
    set inclock_freq [get_parameter_value ACTUAL_INCLOCK_FREQUENCY]
    set j_factor [get_parameter_value J_FACTOR]
    set inclock_shift_deg 0
    
    if {[string_compare $mode "RX_Non-DPA"]} {
        set inclock_shift_deg [get_parameter_value RX_INCLOCK_PHASE_SHIFT_ACTUAL]
        set inclock_shift_deg [expr {$inclock_shift_deg%(360*$j_factor)}]
    }    
    
    set fclk_period [freq_to_period $rate]
    set fclk_frequency_double  [format "%.6f" $rate]

    set_parameter_value pll_inclock_frequency "$inclock_freq MHz"
    
    set_parameter_value pll_fclk_frequency "$fclk_frequency_double MHz"
    set_parameter_value pll_fclk_phase_shift "[expr {round($fclk_period * (0.5 - double($inclock_shift_deg)/360))%($fclk_period)}] ps"

    
    
    if { ([string_compare $mode "RX_DPA-FIFO"]) || 
         ([string_compare $uses_clock_pin "false"]  && 
         ([string_compare $mode "RX_Non-DPA"]  || [string_compare $mode "TX"])) } { 

        set sclk_frequency_double  [format "%.6f" [expr {double($rate)/$j_factor}]]
        set loaden_shift_ps [expr {round($fclk_period*($j_factor - 2 - double($inclock_shift_deg)/360))%($fclk_period*$j_factor)}]
        set sclk_shift_ps [expr {round($fclk_period * (0.5 - double($inclock_shift_deg)/360))%($fclk_period*$j_factor)}]


        set result_array [get_achievable_phases $sclk_frequency_double $loaden_shift_ps $inclock_freq]
        if {[string match -nocase "*error*" $result_array]} {
            send_message error "Could not find a pll-realizable loaden phase shift given the current specification." 
        } else {
            set_parameter_value pll_loaden_frequency "$sclk_frequency_double MHz"
            set_parameter_value pll_loaden_duty_cycle [expr {100/$j_factor}]
            set_parameter_value pll_loaden_phase_shift "[lindex $result_array 0]"
        }

        set result_array [get_achievable_phases $sclk_frequency_double $sclk_shift_ps $inclock_freq]
        if {[string match -nocase "*error*" $result_array]} {
            send_message error "Could not find a pll-realizable sclk phase shift given the current specification." 
        } else {
            set_parameter_value pll_sclk_frequency "$sclk_frequency_double MHz"
            set_parameter_value pll_sclk_phase_shift "[lindex $result_array 0]"
        }

    } else {
        set_parameter_value pll_sclk_frequency "0 MHz"
        set_parameter_value pll_sclk_phase_shift "0 ps"

        set_parameter_value pll_loaden_frequency "0 MHz"
        set_parameter_value pll_loaden_duty_cycle 50
        set_parameter_value pll_loaden_phase_shift "0 ps"

    }

    if  { [string_compare $mode "TX"] && [string_compare $uses_clock_pin "false"] && [param_string_compare TX_USE_OUTCLOCK "true"]} {

        set tx_outclock_div [get_parameter_value TX_OUTCLOCK_DIVISION]
        set tx_outclock_shift_deg [get_parameter_value TX_OUTCLOCK_PHASE_SHIFT_ACTUAL]
        
        set_parameter_value pll_tx_outclock_frequency "[format "%.6f" [expr {double ($rate)/$tx_outclock_div}]] MHz"
        set_parameter_value pll_tx_outclock_phase_shift "[expr {round($fclk_period * ((double($tx_outclock_shift_deg)/360 + 0.5)))%($fclk_period*$tx_outclock_div)}] ps"
            
    } else {
        set_parameter_value pll_tx_outclock_frequency "0 MHz"
        set_parameter_value pll_tx_outclock_phase_shift "0 ps"
    }

    
    if { [string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_value pll_vco_frequency "[get_legal_vco $rate] MHz" 
    } else {
        set_parameter_value pll_vco_frequency "0 MHz"
    }    
}



proc ::altera_lvds::top::main::_generate_altera_lvds_tb_parameters {} {
    
    set param_list ""
    foreach param [get_parameters] { 
        append param_list ".$param\("
        set param_type [get_parameter_property $param type] 
        if { [string_compare $param_type "STRING"] || [string_compare $param_type "BOOLEAN"] } {
            append param_list "\"" [get_parameter_value $param] "\""
        } else {
            append param_list [get_parameter_value $param]
        }    
        append param_list "\),\n"
    }
    return [string trimright $param_list ",\n"]
}



proc ::altera_lvds::top::main::_set_derived_visible_parameters { } {         
   
    set mode [get_parameter_value MODE]
    set param_list [list]
    set param_values [list] 
    set num_outclocks 0

    if { [string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        lappend param_list "VCO frequency"
        lappend param_values [get_parameter_value pll_vco_frequency]
    } 

    if { [param_string_compare pll_fclk_frequency "0 MHz"] == 0  } {
        lappend param_list     "Fast clock frequency"
        lappend param_values   [get_parameter_value pll_fclk_frequency]
        lappend param_list     "Fast clock phase shift"
        lappend param_values   [get_clock_shift_in_degrees "fclk"] 
        lappend param_list     "Fast clock duty cycle"
        lappend param_values   "50 %"
        incr num_outclocks 
   }   

    if { [param_string_compare pll_loaden_frequency "0 MHz"] == 0 } {
        lappend param_list     "Load enable frequency"
        lappend param_values   [get_parameter_value pll_loaden_frequency]
        lappend param_list     "Load enable phase shift"
        lappend param_values   [get_clock_shift_in_degrees "loaden"] 
        lappend param_list     "Load enable duty cycle"
        lappend param_values   "[get_parameter_value pll_loaden_duty_cycle] %"
        incr num_outclocks 
    }  

    if { [param_string_compare pll_sclk_frequency "0 MHz"] == 0 } {
        lappend param_list "Core clock frequency"
        lappend param_values [get_parameter_value pll_sclk_frequency]
        lappend param_list "Core clock phase shift"
        lappend param_values [get_clock_shift_in_degrees "sclk"] 
        lappend param_list "Core clock duty cycle"
        lappend param_values "50 %"
        incr num_outclocks 
    } 

    if { [param_string_compare pll_tx_outclock_frequency "0 MHz"] == 0 } {
        lappend param_list "Tx outclock frequency"
        lappend param_values [get_parameter_value pll_tx_outclock_frequency]
        lappend param_list "Tx outclock phase shift"
        lappend param_values [get_clock_shift_in_degrees "tx_outclock"] 
        lappend param_list "Tx outclock clock duty cycle"
        lappend param_values "50 %"
        incr num_outclocks 
    }
    
    lappend param_list "\n"
    lappend param_list "# of outclocks"

    lappend param_values "\n"
    lappend param_values "$num_outclocks"
    

    set_parameter_value GUI_CLOCK_PARAM_NAMES $param_list
    set_parameter_value GUI_CLOCK_PARAM_VALUES $param_values

}
          

proc ::altera_lvds::top::main::_validate_settable_parameters { } {         
   
    foreach param [get_parameters] {
        if { [get_parameter_property $param DERIVED] == 0 && $param != ""  } {
            _validate_$param 
        }
    }
}


proc ::altera_lvds::top::main::_validate_MODE { } {
}

proc ::altera_lvds::top::main::_validate_NUM_CHANNELS { } {
   
    set mode [get_parameter_value MODE]

    if {[string_compare $mode "RX_DPA-FIFO"]} {
        set max_if_width 24 
    } elseif {[string_compare $mode "RX_Soft-CDR"]} {
        set max_if_width 12 
    } else {
        set max_if_width 72
    }    
   
   set_parameter_property NUM_CHANNELS allowed_ranges 1:${max_if_width} 
}

proc ::altera_lvds::top::main::_validate_USE_EXTERNAL_PLL { } {
   
    if {[get_parameter_value USE_CLOCK_PIN] == 1 } {
        set_parameter_property USE_EXTERNAL_PLL ENABLED false
    } else {
        set_parameter_property USE_EXTERNAL_PLL ENABLED true
    } 
}

proc ::altera_lvds::top::main::_validate_J_FACTOR { } {
}

proc ::altera_lvds::top::main::_validate_DATA_RATE { } {
    
    
    if {[get_parameter_value USE_CLOCK_PIN]} {
        set max_data_rate 800.0
    } elseif {[get_parameter_value USE_EXTERNAL_PLL]} {
        set max_data_rate 1600.0
    } else {
        set max_data_rate 1600.0
    }

    set_parameter_property DATA_RATE allowed_ranges 1:$max_data_rate 
}

proc ::altera_lvds::top::main::_validate_INCLOCK_FREQUENCY { } {
   
    if {[get_parameter_value USE_CLOCK_PIN] || [get_parameter_value USE_EXTERNAL_PLL]} {
        set_parameter_property INCLOCK_FREQUENCY ENABLED false
    } else {
        set_parameter_property INCLOCK_FREQUENCY ENABLED true
        set refmin [get_pll_spec REF_MIN]
        set refmax [get_pll_spec REF_MAX]
        set allowed_range "{$refmin:$refmax}"
        set_parameter_property INCLOCK_FREQUENCY ALLOWED_RANGES $allowed_range
    } 
}

proc ::altera_lvds::top::main::_validate_ACTUAL_INCLOCK_FREQUENCY { } {
    
    set use_clock_pin [get_parameter_value USE_CLOCK_PIN]
    set use_external_pll [get_parameter_value USE_EXTERNAL_PLL]

    if { $use_external_pll} {
        set_parameter_property PLL_CORECLOCK_RESOURCE ENABLED false
    } 
    
    if {$use_clock_pin} {
        set_parameter_property ACTUAL_INCLOCK_FREQUENCY ALLOWED_RANGES [format "%.6f" [get_parameter_value DATA_RATE]]
    } else {
        set_parameter_property ACTUAL_INCLOCK_FREQUENCY ALLOWED_RANGES [calculate_actual_inclock_frequency \
                                                    [get_parameter_value DATA_RATE] \
                                                    [get_parameter_value INCLOCK_FREQUENCY]]
    }
}

proc ::altera_lvds::top::main::_validate_USE_CLOCK_PIN { } {
    
    set mode [get_parameter_value MODE] 

        set_parameter_property USE_CLOCK_PIN ENABLED false
}




proc ::altera_lvds::top::main::_validate_RX_INCLOCK_PHASE_SHIFT { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_Non-DPA"] && [param_string_compare USE_CLOCK_PIN "false"]} {
        set_parameter_property RX_INCLOCK_PHASE_SHIFT ENABLED true
        set rate [get_parameter_value DATA_RATE]
        set inclock_freq [get_parameter_value ACTUAL_INCLOCK_FREQUENCY]

        set fclk_inclk_div [expr {double($rate)/$inclock_freq}]
        set allowed_ranges "{0:[expr {round(ceil($fclk_inclk_div*360)-1)}]}"
        
        set_parameter_property RX_INCLOCK_PHASE_SHIFT ENABLED true
        set_parameter_property RX_INCLOCK_PHASE_SHIFT ALLOWED_RANGES  $allowed_ranges
    } else {
        set_parameter_property RX_INCLOCK_PHASE_SHIFT ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_INCLOCK_PHASE_SHIFT_ACTUAL { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_Non-DPA"]} {
        set_parameter_property RX_INCLOCK_PHASE_SHIFT_ACTUAL ENABLED true
        
        if {[param_string_compare USE_CLOCK_PIN "true"]} {
            set_parameter_property RX_INCLOCK_PHASE_SHIFT_ACTUAL ALLOWED_RANGES {0 180}
        } else {   

            set inclock_freq [get_parameter_value ACTUAL_INCLOCK_FREQUENCY]
            set rate [get_parameter_value DATA_RATE]
            set fclk_period [freq_to_period $rate]
            set j_factor [get_parameter_value J_FACTOR]
            set inclock_shift_deg [get_parameter_value RX_INCLOCK_PHASE_SHIFT]
            set sclk_frequency_double  [format "%.6f" [expr {double($rate)/$j_factor}]]


            set sclk_shift_ps [expr {round($fclk_period * (0.5 - double($inclock_shift_deg)/360))%($fclk_period*$j_factor)}]

            set sclk_phases [get_achievable_phases $sclk_frequency_double $sclk_shift_ps $inclock_freq]
            if {[string match -nocase "*error*" $sclk_phases] || $sclk_phases == ""} {
                send_message error "Could find a legal pll configuration using the specified inclock phase shift." 
            } else {
                set phases_deg [list]
                foreach phase $sclk_phases {
                    set phase_deg [expr {round((180 - round([strip_units $phase] * 360.0/$fclk_period)))}]
                    lappend phases_deg $phase_deg
                }
                set_parameter_property RX_INCLOCK_PHASE_SHIFT_ACTUAL ALLOWED_RANGES $phases_deg
            }
        }   
    } else {
        set_parameter_property RX_INCLOCK_PHASE_SHIFT_ACTUAL ENABLED false
    }
}


proc ::altera_lvds::top::main::_validate_RX_USE_BITSLIP { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "TX"]} {
        set_parameter_property RX_USE_BITSLIP ENABLED false
    } else {
        set_parameter_property RX_USE_BITSLIP ENABLED true
    }
}

proc ::altera_lvds::top::main::_validate_RX_BITSLIP_ASSERT_MAX { } {
    
    set mode [get_parameter_value MODE] 
    set use_cda [get_parameter_value RX_USE_BITSLIP]

    if {[string_compare $mode "TX"] == 0 && $use_cda } {
        set_parameter_property RX_BITSLIP_ASSERT_MAX ENABLED true
    } else {
        set_parameter_property RX_BITSLIP_ASSERT_MAX ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_BITSLIP_USE_RESET { } {
    
    set mode [get_parameter_value MODE] 
    set use_cda [get_parameter_value RX_USE_BITSLIP]

    if {[string_compare $mode "TX"] == 0 && $use_cda } {
        set_parameter_property RX_BITSLIP_USE_RESET ENABLED true
    } else {
        set_parameter_property RX_BITSLIP_USE_RESET ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_DPA_USE_RESET { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_property RX_DPA_USE_RESET ENABLED true
    } else {
        set_parameter_property RX_DPA_USE_RESET ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_DPA_LOSE_LOCK_ON_ONE_CHANGE { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_property RX_DPA_LOSE_LOCK_ON_ONE_CHANGE ENABLED true
    } else {
        set_parameter_property RX_DPA_LOSE_LOCK_ON_ONE_CHANGE ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_DPA_LOCKED_USED { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_property RX_DPA_LOCKED_USED ENABLED true
    } else {
        set_parameter_property RX_DPA_LOCKED_USED ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_DPA_USE_HOLD { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_property RX_DPA_USE_HOLD ENABLED true
    } else {
        set_parameter_property RX_DPA_USE_HOLD ENABLED false
    }
}



proc ::altera_lvds::top::main::_validate_RX_DPA_ALIGN_TO_RISING_EDGE_ONLY { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_property RX_DPA_ALIGN_TO_RISING_EDGE_ONLY ENABLED true
    } else {
        set_parameter_property RX_DPA_ALIGN_TO_RISING_EDGE_ONLY ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_RX_CDR_SIMULATION_PPM_DRIFT { } {
    
    set mode [get_parameter_value MODE] 

        set_parameter_property RX_CDR_SIMULATION_PPM_DRIFT ENABLED false
}

proc ::altera_lvds::top::main::_validate_RX_FIFO_USE_RESET { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "RX_DPA-FIFO"] } {
        set_parameter_property RX_FIFO_USE_RESET ENABLED true
    } else {
        set_parameter_property RX_FIFO_USE_RESET ENABLED false
    }
}


proc ::altera_lvds::top::main::_validate_TX_USE_OUTCLOCK { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "TX"] } {
        set_parameter_property TX_USE_OUTCLOCK ENABLED true
    } else {
        set_parameter_property TX_USE_OUTCLOCK ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_TX_OUTCLOCK_PHASE_SHIFT { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "TX" ] && [param_string_compare TX_USE_OUTCLOCK "true"] } {
        set outclock_div [get_parameter_value TX_OUTCLOCK_DIVISION]
        set allowed_ranges "{0:[expr {$outclock_div*360-1}]}"
        set_parameter_property TX_OUTCLOCK_PHASE_SHIFT ENABLED true
        set_parameter_property TX_OUTCLOCK_PHASE_SHIFT ALLOWED_RANGES  $allowed_ranges

    } else {
        set_parameter_property TX_OUTCLOCK_PHASE_SHIFT ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_TX_OUTCLOCK_PHASE_SHIFT_ACTUAL { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "TX" ] && [param_string_compare TX_USE_OUTCLOCK "true"] } {
        set_parameter_property TX_OUTCLOCK_PHASE_SHIFT_ACTUAL ENABLED true

        set inclock_freq [get_parameter_value ACTUAL_INCLOCK_FREQUENCY]
        set tx_outclock_div [get_parameter_value TX_OUTCLOCK_DIVISION]
        set rate [get_parameter_value DATA_RATE]
        set fclk_period [freq_to_period $rate]
        set tx_outclock_shift_deg [get_parameter_value TX_OUTCLOCK_PHASE_SHIFT]
        
        set tx_outclock_freq_double [format "%.6f" [expr {double ($rate)/$tx_outclock_div}]]
        set tx_outclock_shift_ps [expr {round($fclk_period * ((double($tx_outclock_shift_deg)/360 + 0.5)))%($fclk_period*$tx_outclock_div)}]

        set tx_outclock_phases [get_achievable_phases $tx_outclock_freq_double $tx_outclock_shift_ps $inclock_freq]
        if {[string match -nocase "*error*" $tx_outclock_phases] || $tx_outclock_phases == ""} {
            send_message error "Could not find a pll-realizable tx outclock phase shift given the current specification." 
        } else {
            set phases_deg [list]
            foreach phase $tx_outclock_phases {
                lappend phases_deg [expr { (round([strip_units $phase] * 360.0/$fclk_period) - 180)%(360*$tx_outclock_div)}]
            }
            set_parameter_property TX_OUTCLOCK_PHASE_SHIFT_ACTUAL ALLOWED_RANGES $phases_deg
        }    

    } else {
        set_parameter_property TX_OUTCLOCK_PHASE_SHIFT_ACTUAL ENABLED false
    }
}



proc ::altera_lvds::top::main::_validate_TX_OUTCLOCK_DIVISION { } {
    
    set mode [get_parameter_value MODE] 
	set data_width [get_parameter_value J_FACTOR]

	if { $data_width == 10 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 2 10}    
	} elseif { $data_width == 9 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 9}    
	} elseif { $data_width == 8 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 2 4 8}  
	} elseif { $data_width == 7 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 7}  
	} elseif { $data_width == 6 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 2 6}
	} elseif { $data_width == 5 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 5}  
	} elseif { $data_width == 4 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 2 4} 
	} elseif { $data_width == 3 } {
		set_parameter_property TX_OUTCLOCK_DIVISION ALLOWED_RANGES {1 3}  
	}
	
    if {[string_compare $mode "TX" ] && [param_string_compare TX_USE_OUTCLOCK "true"] } {
        set_parameter_property TX_OUTCLOCK_DIVISION ENABLED true    

    } else {
        set_parameter_property TX_OUTCLOCK_DIVISION ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_TX_EXPORT_CORECLOCK { } {
    
    set mode [get_parameter_value MODE] 

    if {[string_compare $mode "TX"] } {
        set_parameter_property TX_EXPORT_CORECLOCK ENABLED true
    } else {
        set_parameter_property TX_EXPORT_CORECLOCK ENABLED false
    }
}


proc ::altera_lvds::top::main::_validate_PLL_USE_RESET { } {
    
    set use_external_pll [get_parameter_value USE_EXTERNAL_PLL]

    if { $use_external_pll } {
        set_parameter_property PLL_USE_RESET ENABLED true
    } else {
        set_parameter_property PLL_USE_RESET ENABLED false
    }
}

proc ::altera_lvds::top::main::_validate_PLL_EXPORT_LOCK { } {
    
    set use_clock_pin [get_parameter_value USE_CLOCK_PIN]
    set use_external_pll [get_parameter_value USE_EXTERNAL_PLL]

    if { $use_external_pll || $use_clock_pin } {
        set_parameter_property PLL_EXPORT_LOCK ENABLED false
    } else {
        set_parameter_property PLL_EXPORT_LOCK ENABLED true
    }
}

proc ::altera_lvds::top::main::_validate_PLL_SPEED_GRADE { } {
    
    set use_clock_pin [get_parameter_value USE_CLOCK_PIN]

    if { $use_clock_pin } {
        set_parameter_property PLL_SPEED_GRADE ENABLED false
    } else {
        set_parameter_property PLL_SPEED_GRADE ENABLED true
    }
}

proc ::altera_lvds::top::main::_validate_PLL_CORECLOCK_RESOURCE { } {
    
    set use_clock_pin [get_parameter_value USE_CLOCK_PIN]
    set use_external_pll [get_parameter_value USE_EXTERNAL_PLL]

        set_parameter_property PLL_CORECLOCK_RESOURCE ENABLED false
}



proc ::altera_lvds::top::main::_init {} {
}

::altera_lvds::top::main::_init 
