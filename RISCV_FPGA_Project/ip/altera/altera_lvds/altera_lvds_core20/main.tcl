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


package provide altera_lvds::core_20::main 0.1

package require altera_lvds::top::export
package require altera_lvds::core_20::pll
package require altera_lvds::util::hwtcl_utils  

namespace eval ::altera_lvds::core_20::main:: {
   
   namespace import ::altera_lvds::top::export::*
   namespace import ::altera_lvds::core_20::pll::*
   namespace import ::altera_lvds::util::hwtcl_utils::*

}



proc ::altera_lvds::core_20::main::create_parameters {} {
     
    ::altera_lvds::top::export::inherit_top_level_parameter_defs
    
    

    set_parameter_property J_FACTOR                 HDL_PARAMETER true
    set_parameter_property NUM_CHANNELS             HDL_PARAMETER true
    
    set_parameter_property pll_fclk_frequency           HDL_PARAMETER true
    set_parameter_property pll_sclk_frequency           HDL_PARAMETER true
    set_parameter_property pll_loaden_frequency         HDL_PARAMETER true
    set_parameter_property pll_sclk_phase_shift         HDL_PARAMETER true
    set_parameter_property pll_fclk_phase_shift         HDL_PARAMETER true
    set_parameter_property pll_loaden_phase_shift       HDL_PARAMETER true
    set_parameter_property pll_loaden_duty_cycle        HDL_PARAMETER true
    set_parameter_property pll_inclock_frequency        HDL_PARAMETER true
    set_parameter_property pll_tx_outclock_frequency    HDL_PARAMETER true
    set_parameter_property pll_tx_outclock_phase_shift  HDL_PARAMETER true 
    add_derived_hdl_param   TX_OUTCLOCK_NON_STD_PHASE_SHIFT     string              "false"                     
    set_parameter_property  TX_OUTCLOCK_NON_STD_PHASE_SHIFT     AFFECTS_ELABORATION true
    
    add_derived_hdl_param   SERDES_DPA_MODE                     string              "tx_mode" 
    add_derived_hdl_param   TX_OUTCLOCK_DIV_WORD                integer             0               10 
    add_derived_hdl_param   TX_OUTCLOCK_BYPASS_SERIALIZER       string              "false"
    add_derived_hdl_param   TX_OUTCLOCK_USE_FALLING_CLOCK_EDGE  string              "false"

    ::altera_lvds::core_20::pll::create_pll_hdl_parameters
    
    
    return 1
}

proc ::altera_lvds::core_20::main::elaboration_callback {} {


    set data_width [get_parameter_value J_FACTOR]
    set lvds_interface_width [get_parameter_value NUM_CHANNELS]
    set parallel_interface_width [expr $data_width*$lvds_interface_width]
    set mode [get_parameter_value MODE]


    _set_derived_hdl_parameters
    ::altera_lvds::core_20::pll::set_hardware_pll_parameters


	_create_all_interfaces_disabled
	
	set_interface_property inclock_conduit_end ENABLED true

    if {[param_string_compare PLL_USE_RESET "true"]} {
        set_interface_property pll_areset_conduit_end ENABLED true
    }    
    

    if {[param_string_compare PLL_EXPORT_LOCK "true"] 
        && [param_string_compare USE_EXTERNAL_PLL "false"] 
        && [param_string_compare USE_CLOCK_PIN "false"] } {
        
        set_interface_property pll_locked_conduit_end ENABLED true
    }
    
    if {[string_compare $mode "TX"]} { 
    
        _elaborate_tx_interfaces
    
    } else {    
   
        _elaborate_common_rx_interfaces 
    
       if {[string_compare $mode "RX_DPA-FIFO"] || [string_compare $mode "RX_Soft-CDR"]} {   
        
            if {[param_string_compare RX_DPA_LOCKED_USED "true"] } {
                set_interface_property rx_dpa_locked_conduit_end ENABLED true 
            }
            
            if {[param_string_compare RX_DPA_USE_HOLD "true"] } {
                set_interface_property rx_dpa_hold_conduit_end ENABLED true
            }
			
            if {[param_string_compare RX_DPA_USE_RESET "true"] } {
                set_interface_property rx_dpa_reset_conduit_end ENABLED true
            }    

        } 
        
        if {[string_compare $mode "RX_DPA-FIFO"]} {
            
            if {[param_string_compare RX_FIFO_USE_RESET "true"] } {
                set_interface_property rx_fifo_reset_conduit_end ENABLED true
            }
             
        } elseif {[string_compare $mode "RX_Soft-CDR"]} {
            set_interface_property rx_divfwdclk_conduit_end ENABLED true
        }                                             
    } 

    if {[param_string_compare USE_EXTERNAL_PLL "true"]} {
        _elaborate_external_pll_interfaces
    }

    return 1
}

proc ::altera_lvds::core_20::main::sim_vhdl_fileset_callback {top_level} {
	::altera_lvds::util::hwtcl_utils::generate_vhdl_sim [list altera_lvds_core20.sv altera_lvds_core20_pll.v]
}

proc ::altera_lvds::core_20::main::sim_verilog_fileset_callback {top_level} {
  	
    add_fileset_file altera_lvds_core20.sv SYSTEM_VERILOG PATH altera_lvds_core20.sv
	add_fileset_file altera_lvds_core20_pll.v VERILOG PATH altera_lvds_core20_pll.v
    
    if {[get_quartus_ini "altera_lvds_tb_param_dump"]} { 
        set tb_param_list [_generate_altera_lvds_tb_parameters]
        add_fileset_file my_altera_lvds_tb_parameters.v VERILOG TEXT $tb_param_list
    }

}


proc ::altera_lvds::core_20::main::quartus_synth_fileset_callback {top_level} {
	source altera_lvds_sdc.tcl

	add_fileset_file altera_lvds_core20.sv SYSTEM_VERILOG PATH altera_lvds_core20.sv
	add_fileset_file altera_lvds_core20_pll.v VERILOG PATH altera_lvds_core20_pll.v
	add_fileset_file altera_lvds.sdc SDC TEXT [generate_sdc_file]
 
}


proc ::altera_lvds::core_20::main::_create_all_interfaces_disabled {} {
    set data_width [get_parameter_value J_FACTOR]
    set lvds_interface_width [get_parameter_value NUM_CHANNELS]
    set parallel_interface_width [expr $data_width*$lvds_interface_width]
	set mode [get_parameter_value MODE]
    set use_bitslip [param_string_compare RX_USE_BITSLIP "true"]
    
	add_if tx_in conduit end INPUT $parallel_interface_width
	add_if tx_out conduit end OUTPUT $lvds_interface_width	
	add_if tx_outclock conduit end OUTPUT
	add_if tx_coreclock conduit end OUTPUT
	add_if rx_in conduit end Input $lvds_interface_width 
	add_if rx_out conduit end OUTPUT $parallel_interface_width 
	add_if rx_bitslip_reset conduit end INPUT $lvds_interface_width
	add_if rx_bitslip_ctrl conduit end INPUT $lvds_interface_width
	add_if rx_bitslip_max conduit end OUTPUT $lvds_interface_width
	add_if rx_coreclock conduit end OUTPUT 
	add_if ext_fclk clock end INPUT
	add_if ext_loaden clock end INPUT
	add_if ext_coreclock clock end INPUT
	add_if ext_tx_outclock clock end INPUT
	add_if ext_vcoph conduit end INPUT 8 
	add_if inclock conduit end Input
	add_if pll_areset conduit end INPUT
	add_if pll_locked conduit end OUTPUT
	add_if rx_dpa_locked conduit end OUTPUT $lvds_interface_width
	add_if rx_dpa_hold conduit end INPUT $lvds_interface_width
	add_if rx_dpa_reset conduit end INPUT $lvds_interface_width
	add_if rx_fifo_reset conduit end INPUT $lvds_interface_width
	add_if rx_divfwdclk conduit end OUTPUT $lvds_interface_width 
	add_if loopback_in conduit end Input $lvds_interface_width 
	add_if loopback_out conduit end Input $lvds_interface_width 
}

proc ::altera_lvds::core_20::main::_elaborate_tx_interfaces {} {

	set_interface_property tx_in_conduit_end ENABLED true
    
    set_interface_property tx_out_conduit_end ENABLED true
	
    if { [param_string_compare TX_USE_OUTCLOCK "true"] } {
        set_interface_property tx_outclock_conduit_end ENABLED true
    }

    if { [param_string_compare TX_EXPORT_CORECLOCK "true"] } {
        set_interface_property tx_coreclock_conduit_end ENABLED true
    }    
}

proc ::altera_lvds::core_20::main::_elaborate_common_rx_interfaces {} {

    set data_width [get_parameter_value J_FACTOR]
    set lvds_interface_width [get_parameter_value NUM_CHANNELS]
    set parallel_interface_width [expr $data_width*$lvds_interface_width]
    set mode [get_parameter_value MODE]
    set use_bitslip [param_string_compare RX_USE_BITSLIP "true"]

    set_interface_property rx_in_conduit_end ENABLED true
    
    set_interface_property rx_out_conduit_end ENABLED true
	
    if { [param_string_compare RX_BITSLIP_USE_RESET "true"] && $use_bitslip } {
        set_interface_property rx_bitslip_reset_conduit_end ENABLED true
    }

    if { $use_bitslip } {
        set_interface_property rx_bitslip_ctrl_conduit_end ENABLED true
    }

    if { $use_bitslip && [param_string_compare RX_BITSLIP_ASSERT_MAX "true"] } {
        set_interface_property rx_bitslip_max_conduit_end ENABLED true
    }
   
    if {[string_compare $mode "RX_Soft-CDR"] == 0 && [param_string_compare USE_EXTERNAL_PLL "false"]} {
        set_interface_property rx_coreclock_conduit_end ENABLED true
    } 

}

proc ::altera_lvds::core_20::main::_elaborate_external_pll_interfaces {} {

    set mode [get_parameter_value MODE]

    if {[param_strip_units pll_fclk_frequency] != 0 } {
        set_interface_property ext_fclk_clock_end ENABLED true
    }
	
    if {[param_strip_units pll_loaden_frequency] != 0 } {
        set_interface_property ext_loaden_clock_end ENABLED true
    }
	
    if {[param_strip_units pll_sclk_frequency] != 0 } {
        set_interface_property ext_coreclock_clock_end ENABLED true
    }
	
    if {[param_strip_units pll_tx_outclock_frequency] != 0 } {
        set_interface_property ext_tx_outclock_clock_end ENABLED true
    }
	
    if {[param_strip_units pll_vco_frequency] != 0 } {
        set_interface_property ext_vcoph_conduit_end ENABLED true
    }
}


proc ::altera_lvds::core_20::main::_set_derived_hdl_parameters {} {
    
    set mode [get_parameter_value MODE]
    set data_width [get_parameter_value J_FACTOR]

    if {[string_compare $mode "TX"] } {
        set_parameter_value SERDES_DPA_MODE "tx_mode"
        _set_derived_tx_hdl_parameters
    } elseif {[string_compare $mode "RX_DPA-FIFO"] } {
        set_parameter_value SERDES_DPA_MODE "dpa_mode_fifo"
    } elseif {[string_compare $mode "RX_Soft-CDR"] } {
        set_parameter_value SERDES_DPA_MODE "dpa_mode_cdr"
    } else {
        set_parameter_value SERDES_DPA_MODE "non_dpa_mode"
    }    
    
    
}



proc ::altera_lvds::core_20::main::_set_derived_tx_hdl_parameters {} {
    
    set mode [get_parameter_value MODE]
    set data_width [get_parameter_value J_FACTOR]
    set outclock_div [get_parameter_value TX_OUTCLOCK_DIVISION]
    set outclock_div_word 0
    set outclock_shift_deg [get_parameter_value TX_OUTCLOCK_PHASE_SHIFT]
    set is_non_std_shift "false" 

    
    
    if { $outclock_shift_deg % 180 == 0 } {
        set is_non_std_shift false
    } else { 
        set is_non_std_shift true 
    }
    set_parameter_value TX_OUTCLOCK_NON_STD_PHASE_SHIFT $is_non_std_shift 

    
    if { [string_compare $is_non_std_shift "false"] } {
        if { $data_width == 10 } {
            if {$outclock_div == 10} {
                 set outclock_div_word 31  
             } elseif { $outclock_div == 2 } {
                 set outclock_div_word 341
             }
         } elseif { $data_width == 9 } {
             if {$outclock_div == 9} {
                 set outclock_div_word 31
             }    
         } elseif { $data_width == 8 } {
             if {$outclock_div == 8} {
                 set outclock_div_word 15
             } elseif {$outclock_div == 4} {
                 set outclock_div_word 51
             } elseif {$outclock_div == 2} {
                 set outclock_div_word 85
             }    
         } elseif { $data_width == 7 } {
             if {$outclock_div == 7} {
                 set outclock_div_word 15
             }    
         } elseif { $data_width ==  6 } {
             if {$outclock_div == 6} {
                 set outclock_div_word 7
             } elseif {$outclock_div == 2} {
                 set outclock_div_word 21
             }
         } elseif { $data_width ==  5 } {
             if {$outclock_div == 5} {
                 set outclock_div_word 7
             }
        } elseif { $data_width ==  4 } {
             if {$outclock_div == 4} {
                 set outclock_div_word 3 
             } elseif {$outclock_div == 2} {
                 set outclock_div_word 5
             }
        } elseif { $data_width ==  3 } {
             if {$outclock_div == 3} {
                 set outclock_div_word 3
            }
        }
        set outclock_div_word [bit_rotate $outclock_div_word $data_width [expr {$outclock_shift_deg/360}]]
                                            
        set_parameter_value TX_OUTCLOCK_DIV_WORD $outclock_div_word 

        if {$outclock_div == 1} {    
            set_parameter_value TX_OUTCLOCK_BYPASS_SERIALIZER "true"
        } else {
            set_parameter_value TX_OUTCLOCK_BYPASS_SERIALIZER "false"
            }
     
         if {[expr {$outclock_shift_deg/180 % 2}] == 1} {
             set_parameter_value TX_OUTCLOCK_USE_FALLING_CLOCK_EDGE "true" 
         } else {
             set_parameter_value TX_OUTCLOCK_USE_FALLING_CLOCK_EDGE "false"
         }    

     } else { 
        set_parameter_value TX_OUTCLOCK_BYPASS_SERIALIZER "false"
        set_parameter_value TX_OUTCLOCK_DIV_WORD 0 
        set_parameter_value TX_OUTCLOCK_USE_FALLING_CLOCK_EDGE "false" 
    }

}




proc ::altera_lvds::core_20::main::_generate_altera_lvds_tb_parameters {} {
    
    set param_list ""
    foreach param [get_parameters] {
    set param_type [get_parameter_property $param type] 
        if {[get_parameter_property $param DERIVED] == 0 && [regexp -lineanchor {^GUI} $param] == 0 } {
            append param_list ".$param\("
            set param_type [get_parameter_property $param type] 
            if { [string_compare $param_type "STRING"] || [string_compare $param_type "BOOLEAN"] } {
                append param_list "\"" [get_parameter_value $param] "\""
            } else {
                append param_list [get_parameter_value $param]
            }    
            append param_list "\),\n"
        }
    }
    return [string trimright $param_list ",\n"]

}
proc ::altera_lvds::core_20::main::_init {} {
}

::altera_lvds::core_20::main::_init
