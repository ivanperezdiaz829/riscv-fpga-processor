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



# # YMCHIN - Open Items:  
			## TBD  - which param to be stored in reconfig profile?
			## TBD  - cdr_pll_loopback_mode - default value = LOOPBACK_RECOVERED_DATA - gp core file = LOOPBACK_DISABLED
			## ToDo - speed grades 
			## TODO - Implement RBC Tcl 


package provide altera_xcvr_cdr_pll_vi::parameters 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::common
package require alt_xcvr::utils::reconfiguration_arria10

namespace eval ::altera_xcvr_cdr_pll_vi::parameters:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_parameters \
    validate \
    compute_pll_settings
	
  #variable package_name
  variable display_items
  variable generation_display_items
  variable parameters
  variable atom_parameters
  variable logical_parameters
  variable auto_configured_parameters

  
 # set package_name "altera_xcvr_cdr_pll_vi::parameters"

  
  set display_items {\
    {NAME                                     GROUP           ENABLED		VISIBLE		TYPE  ARGS  }\
	{"PLL"                                	  ""              NOVAL			NOVAL		GROUP tab }\
    {"General"                                "PLL"           NOVAL			NOVAL		GROUP noval }\
    {"Output Frequency"                       "PLL"           NOVAL			NOVAL		GROUP noval }\
   
  }
  
  set generation_display_items {\
      {NAME                         GROUP                      ENABLED             VISIBLE   TYPE   ARGS  }\
      {"Generation Options"         ""                         NOVAL               NOVAL     GROUP  tab   }\
   }
   
  set parameters {\
    {NAME                                     M_USED_FOR_RCFG  M_SAME_FOR_RCFG			DERIVED HDL_PARAMETER 		TYPE      		DEFAULT_VALUE 				ALLOWED_RANGES          						ENABLED     						VISIBLE 							DISPLAY_HINT  DISPLAY_UNITS 																				DISPLAY_ITEM  					DISPLAY_NAME                        													VALIDATION_CALLBACK                                                     						 DESCRIPTION }\
 	{enable_advanced_options							0				0					true	false			INTEGER			    0						{ 0 1 }											true								false								NOVAL		  NOVAL																							NOVAL						    NOVAL																						NOVAL																								NOVAL}\
	{generate_docs										0				0					false	false			INTEGER			    1						    NOVAL										true								true								boolean		  NOVAL																							"Generation Options"			"Generate parameter documentation file"														NOVAL																								"When enabled, generation will produce a .CSV file with descriptions of the IP parameters."}\
	{generate_add_hdl_instance_example					0				0					false	false			INTEGER			    0						    NOVAL										enable_advanced_options				enable_advanced_options				boolean		  NOVAL																							"Generation Options"			"Generate '_hw.tcl' 'add_hdl_instance' example file"										NOVAL																								"When enabled, generation will produce a file containing an example of how to use the '_hw.tcl' 'add_hdl_instance' API. The example will be correct for the current configuration of the IP."}\
	{device_family										0				0					false	false			STRING			"Arria VI"						NOVAL										true								false								NOVAL		  NOVAL																							NOVAL							NOVAL																						NOVAL																								NOVAL}\
    {speed_grade	                        			0				0					false   false         	STRING    		"fastest"  	  					NOVAL     									true        						true   								NOVAL         NOVAL         																				"General"         				"Device speed grade"                    													NOVAL                                                                   							NOVAL}\
	{prot_mode											1				0					false	false		  	STRING			"Basic"		      			{"Basic"}										true								true								NOVAL		  NOVAL																							"General"						"Protocol mode"																				NOVAL 																    							NOVAL}\
	{bw_sel												1				1					false	false		  	STRING			"Low"	  					{"Low" "Medium" "High"}							true								true								NOVAL		  NOVAL																							"General"						"Bandwidth"																					NOVAL																								NOVAL}\
	{refclk_cnt											1				0					false	false		  	INTEGER				1			  			{ 1 2 3 4 5}									true								true								NOVAL		  NOVAL																							"General"						"Number of PLL reference clocks"															NOVAL 																    							NOVAL}\
	{refclk_index										1				0					false	false		  	INTEGER				0			  			{ 0 1 2 3 4}									true								true								NOVAL		  NOVAL																							"General"						"Selected reference clock source"															NOVAL 																    							NOVAL}\
	{silicon_rev	                        			0				0					false   false         	STRING   		"reva"             			{"reva" "revb" "revc"}                   		true       							false   							boolean       NOVAL         																				"General"         				"Silicon ES revision"			        													NOVAL                                                                   							NOVAL}\
	\
	{bw_sel_atom										0				0					true	false			STRING			"low"							NOVAL										true								false								NOVAL		  NOVAL																							NOVAL							NOVAL																						::altera_xcvr_cdr_pll_vi::parameters::validate_bw_sel												NOVAL}\
	{prot_mode_atom										0				0					false	false			STRING			"basic_rx"					{"basic_rx"}									true								false								NOVAL		  NOVAL																							NOVAL							NOVAL																						NOVAL																								NOVAL}\
	{speed_grade_atom									0				0					true	false			STRING			"dash4"							NOVAL										true								false								NOVAL		  NOVAL																							NOVAL							NOVAL																						::altera_xcvr_cdr_pll_vi::parameters::validate_speed_grade											NOVAL}\
	{message_level										0				0					false	false			STRING			"error"						{error warning}									true								true								NOVAL		  NOVAL																							"General"						"Message level for rule violations"															NOVAL																								"Specifies the messaging level to use for parameter rule violations. Selecting \"error\" will cause all rule violations to prevent IP generation. Selecting \"warning\" will display all rule violations as warnings and will allow IP generation in spite of violations."}\
	{support_mode										1				0					false	false			STRING			"user_mode"					{"user_mode" "engineering_mode"}				enable_advanced_options				enable_advanced_options				NOVAL		  NOVAL																							"General"						"Support mode"																				::altera_xcvr_cdr_pll_vi::parameters::validate_support_mode											"Selects the support mode (user or engineering). Engineering mode options are not officially supported by Altera or Quartus II."}\
	{select_manual_config								0				0					false	false			BOOLEAN				0							NOVAL										true								false								boolean		  NOVAL																							"Output Frequency"				"Configure counters manually"																NOVAL																								NOVAL}\
	{output_clock_frequency         					1				0					false   false         	STRING    		"2000"        					NOVAL                   					true        						true   								NOVAL         MHz           																				"Output Frequency"     			"PLL output frequency"                  													NOVAL                                                                 								NOVAL}\
	{reference_clock_frequency      					1				0					false   false         	STRING    		"100.000000"       				NOVAL	        							true        						true   								NOVAL         MHz           																				"Output Frequency"     			"PLL reference clock frequency"         													::altera_xcvr_cdr_pll_vi::parameters::validate_reference_clock_frequency							NOVAL}\
	{cdr_pll_out_clock_frequency         				1				0					true    false         	STRING    		"2000 MHz"        				NOVAL                   					true        						false   							NOVAL         MHz           																				"Output Frequency"     			"PLL output frequency"                  													::altera_xcvr_cdr_pll_vi::parameters::validate_output_clock_frequency                               NOVAL}\
	{cdr_pll_ref_clock_frequency      					1				0					true    false         	STRING    		"100.000000 MHz"       			NOVAL	        							true        						false   							NOVAL         MHz           																				"Output Frequency"     			"PLL reference clock frequency"         													::altera_xcvr_cdr_pll_vi::parameters::validate_cdr_pll_ref_clock_frequency							NOVAL}\
	{cdr_pll_mcounter									1				0					true	false		  	INTEGER				1			  				NOVAL										true								true								NOVAL		  NOVAL																							"Output Frequency"				"Multiply factor (M-Counter)" 																::altera_xcvr_cdr_pll_vi::parameters::validate_m_counter											NOVAL}\
	{cdr_pll_ncounter									1				0					true	false		  	INTEGER				1			  				NOVAL										true								true								NOVAL		  NOVAL																							"Output Frequency"				"Divide factor (N-Counter)" 																::altera_xcvr_cdr_pll_vi::parameters::validate_n_counter											NOVAL}\
	{cdr_pll_pfd_lcounter								1				0					true	false		  	INTEGER				1			  				NOVAL										true								true								NOVAL		  NOVAL																							"Output Frequency"	 			"Divide factor (L-Counter)" 																::altera_xcvr_cdr_pll_vi::parameters::validate_lpfd_counter											NOVAL}\
	{manual_counters									0				0					false	false			STRING			NOVAL							NOVAL										select_manual_config				false								NOVAL		  "N-Counter (Divide Factor)   Lpfd-Counter (Divide Factor)   M-Counter (Multiply Factor)"		"Output Frequency"				"Counter Values"																			::altera_xcvr_cdr_pll_vi::parameters::validate_manual_counters										NOVAL}\
	{auto_counters										0				0					true	false			STRING			NOVAL							NOVAL										true								false								NOVAL		  NOVAL																							"Output Frequency"				"Auto Counter Values"																		::altera_xcvr_cdr_pll_vi::parameters::validate_auto_counters										NOVAL}\
	{temporary_parameter								0				0					true	false			STRING			"reva"						{ "reva" "revb" "revc"	}						true								false								NOVAL		  NOVAL																							NOVAL							NOVAL																						NOVAL																								NOVAL}\
	}


	set atom_parameters {\
      { NAME                                          M_RCFG_REPORT   TYPE       DERIVED   M_MAPS_FROM                     		HDL_PARAMETER   ENABLED   VISIBLE   M_MAP_VALUES }\
      { cdr_pll_speed_grade							  1				  STRING	 true	   speed_grade_atom						true			false	  false		NOVAL }\
	  { cdr_pll_prot_mode                             1               STRING     true      prot_mode_atom	                   	true            false     false     NOVAL }\
      { cdr_pll_bw_sel                                1               STRING     true      bw_sel_atom	                        true            false     false     NOVAL }\
      { cdr_pll_silicon_rev                           1               STRING     true      silicon_rev	                   		true            false     false     NOVAL }\
      { cdr_pll_output_clock_frequency                1               STRING     true      cdr_pll_out_clock_frequency       	true            false     false     NOVAL }\
      { cdr_pll_reference_clock_frequency             1               STRING     true      cdr_pll_ref_clock_frequency			true            false     false     NOVAL }\
      { cdr_pll_m_counter                             1               INTEGER   true      cdr_pll_mcounter               		true            false     false     NOVAL }\
      { cdr_pll_n_counter                             1               INTEGER   true      cdr_pll_ncounter               		true            false     false     NOVAL }\
      { cdr_pll_pfd_l_counter                         1               INTEGER   true      cdr_pll_pfd_lcounter           		true            false     false     NOVAL }\
      { pma_cdr_refclk_select_mux_silicon_rev         1               STRING     true      temporary_parameter		            true            false     false     NOVAL }\
      { pma_cdr_refclk_select_mux_refclk_select       1               STRING   	 true      refclk_index                    		true            false     false     {"0:ref_iqclk0" "1:ref_iqclk1" "2:ref_iqclk2" "3:ref_iqclk3" "4:ref_iqclk4"} }\
   }

   set logical_parameters {\
      { NAME                    M_RCFG_REPORT   TYPE       DERIVED   M_MAPS_FROM                     HDL_PARAMETER   ENABLED   VISIBLE   M_MAP_VALUES }\
      { cmu_refclk_select       1               INTEGER    true      refclk_index                    false           false     false     NOVAL }\
   }

   set auto_configured_parameters {\
      { NAME                                                               M_RCFG_REPORT   TYPE       DERIVED   HDL_PARAMETER   ENABLED   VISIBLE   DEFAULT_VALUE }\
      { cdr_pll_pma_width												   1			   INTEGER	  true      true			false	  false     8 }\
	  { cdr_pll_cgb_div                                                    1               INTEGER    true      true            false     false     1 }\
      { cdr_pll_txpll_hclk_driver_enable                                   1               STRING     true      true            false     false     "false" }\
      { cdr_pll_fb_select                                     			   1               STRING     true      true            false     false     "direct_fb"}\
      { cdr_pll_atb_select_control                                         1               STRING     true      true            false     false     "atb_off" }\
      { cdr_pll_bbpd_data_pattern_filter_select                            1               STRING     true      true            false     false     "bbpd_data_pat_off" }\
      { cdr_pll_cdr_odi_select                                        	   1               STRING     true      true            false     false     "sel_cdr" }\
      { cdr_pll_chgpmp_current_pd                                          1               STRING     true      true            false     false     "cp_current_pd_setting0" }\
      { cdr_pll_chgpmp_current_pfd                                         1               STRING     true      true            false     false     "cp_current_pfd_setting0" }\
      { cdr_pll_chgpmp_replicate                                           1               STRING     true      true            false     false     "true" }\
      { cdr_pll_chgpmp_testmode                                            1               STRING     true      true            false     false     "cp_test_disable" }\
      { cdr_pll_clklow_mux_select                                          1               STRING     true      true            false     false     "clklow_mux_cdr_fbclk" }\
      { cdr_pll_diag_loopback_enable                                       1               STRING     true      true            false     false     "false" }\
      { cdr_pll_disable_up_dn                                              1               STRING     true      true            false     false     "true" }\
      { cdr_pll_fref_clklow_div                                            1               INTEGER    true      true            false     false     1 }\
      { cdr_pll_fref_mux_select                                 		   1               STRING     true      true            false     false     "fref_mux_cdr_refclk" }\
      { cdr_pll_gpon_lck2ref_control                                       1               STRING     true      true            false     false     "gpon_lck2ref_off" }\
      { cdr_pll_lck2ref_delay_control                                      1               STRING     true      true            false     false     "lck2ref_delay_off" }\
      { cdr_pll_lf_resistor_pd                                             1               STRING     true      true            false     false     "lf_pd_setting0" }\
      { cdr_pll_lf_resistor_pfd                                            1               STRING     true      true            false     false     "lf_pfd_setting0" }\
      { cdr_pll_lf_ripple_cap                                              1               STRING     true      true            false     false     "lf_no_ripple" }\
      { cdr_pll_loop_filter_bias_select                                    1               STRING     true      true            false     false     "lpflt_bias_off" }\
      { cdr_pll_loopback_mode                                              1               STRING     true      true            false     false     "loopback_disabled" }\
      { cdr_pll_ltd_ltr_micro_controller_select                            0               STRING     true      true            false     false     "ltd_ltr_pcs" }\
      { cdr_pll_op_mode                                                    1               STRING     true      true            false     false     "pwr_down" }\
      { cdr_pll_pd_fastlock_mode                                           1               STRING     true      true            false     false     "false" }\
      { cdr_pll_power_mode                                                 1               STRING     true      true            false     false     "low_power" }\
      { cdr_pll_reverse_serial_loopback                                    1               STRING     true      true            false     false     "no_loopback" }\
      { cdr_pll_set_cdr_v2i_enable                                         1               STRING     true      true            false     false     "true" }\
      { cdr_pll_set_cdr_vco_reset                                          1               STRING     true      true            false     false     "false" }\
      { cdr_pll_set_cdr_vco_speed                                          1               STRING     true      true            false     false     "cdr_vco_max_speedbin" }\
      { cdr_pll_set_cdr_vco_speed_pciegen3                                 1               STRING     true      true            false     false     "cdr_vco_max_speedbin_pciegen3" }\
      { cdr_pll_vco_overrange_voltage                                      1               STRING     true      true            false     false     "vco_overrange_off" }\
      { cdr_pll_vco_underrange_voltage                                     1               STRING     true      true            false     false     "vco_underange_off" }\
      { cdr_pll_is_cascaded_pll                           				   1               STRING     true      true            false     false     "false" }\
      { cdr_pll_device_variant                                             1               STRING     true      true            false     false     "device1" }\
      { cdr_pll_optimal                                                    1               STRING     true      true            false     false     "true" }\
      { cdr_pll_position                                                   1               STRING     true      true            false     false     "position_unknown" }\
      { cdr_pll_primary_use                                                1               STRING     true      true            false     false     "cmu" }\
      { cdr_pll_side                                                       1               STRING     true      true            false     false     "side_unknown" }\
      { cdr_pll_sup_mode                                                   1               STRING     true      true            false     false     "user_mode" }\
      { cdr_pll_top_or_bottom                                              1               STRING     true      true            false     false     "tb_unknown" }\
      { pma_cdr_refclk_select_mux_inclk0_logical_to_physical_mapping       0               STRING     true      true            false     false     "ref_iqclk0" }\
      { pma_cdr_refclk_select_mux_inclk1_logical_to_physical_mapping       0               STRING     true      true            false     false     "ref_iqclk1" }\
      { pma_cdr_refclk_select_mux_inclk2_logical_to_physical_mapping       0               STRING     true      true            false     false     "ref_iqclk2" }\
      { pma_cdr_refclk_select_mux_inclk3_logical_to_physical_mapping       0               STRING     true      true            false     false     "ref_iqclk3" }\
      { pma_cdr_refclk_select_mux_inclk4_logical_to_physical_mapping       0               STRING     true      true            false     false     "ref_iqclk4" }\
   }
}

  
proc ::altera_xcvr_cdr_pll_vi::parameters::declare_parameters { {device_family "Arria VI"} } {
  variable display_items
  variable generation_display_items
  variable parameters
  variable atom_parameters
  variable logical_parameters
  variable auto_configured_parameters
  
  # Which parameters are included in reconfig reports is parameter dependent
   ip_add_user_property_type M_RCFG_REPORT integer

   ::alt_xcvr::utils::reconfiguration_arria10::declare_parameters
   ip_set "parameter.rcfg_file_prefix.DEFAULT_VALUE" "altera_xcvr_cdr_pll_a10"
   
  ip_declare_parameters $parameters
  ip_declare_parameters $atom_parameters
  ip_declare_parameters $logical_parameters
  ip_declare_parameters $auto_configured_parameters
  
  ip_declare_display_items $display_items
  
  ::alt_xcvr::utils::reconfiguration_arria10::declare_display_items "" tab
  
  ip_declare_display_items $generation_display_items
  
  ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
  ip_set "parameter.speed_grade.allowed_ranges" [::alt_xcvr::utils::device::get_device_speedgrades $device_family]
   # Grab Quartus INI's
  ip_set "parameter.enable_advanced_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_cdr_pll_10_advanced ENABLED]

}

proc ::altera_xcvr_cdr_pll_vi::parameters::validate {} {
  ip_message warning "This IP core is in beta stage. IP ports and parameters are subject to change."
  ::alt_xcvr::ip_tcl::messages::set_auto_message_level [ip_get "parameter.message_level.value"]
  ip_validate_parameters
  ip_validate_display_items
  
  
}


proc ::altera_xcvr_cdr_pll_vi::parameters::validate_support_mode { PROP_NAME PROP_VALUE message_level } {
  if {$PROP_VALUE == "engineering_mode"} {
    ip_message $message_level "Engineering support mode has been selected. Engineering mode is for internal use only. Altera does not officially support or guarantee IP configurations for this mode."
  }
}
	
#########################################################################
###################### Validation Callbacks #############################

######################## Express in MHz #################################
proc ::altera_xcvr_cdr_pll_vi::parameters::get_f_max_pfd {} { return   800 }
proc ::altera_xcvr_cdr_pll_vi::parameters::get_f_min_pfd {} { return    20 }
proc ::altera_xcvr_cdr_pll_vi::parameters::get_f_min_vco {} { return  4750 }
proc ::altera_xcvr_cdr_pll_vi::parameters::get_f_max_vco {} { return 16000 }
proc ::altera_xcvr_cdr_pll_vi::parameters::get_f_min_ref {} { return    61.44 }
proc ::altera_xcvr_cdr_pll_vi::parameters::get_f_max_ref {} { return   800 }


proc ::altera_xcvr_cdr_pll_vi::parameters::compute_pll_settings {output_clock_frequency_Mhz pll_type pcie_mode} {
	#output clock freq is in MHz
	
	if {[string compare $pll_type "CMU" ] == 0 } { 
		set pfd_l_counter { 1 2 4 8 16}
	} else {
	    # Arranging the lpfd in descending order enable the computation algo to produce on top of the returned stack that contain smallest m value. 
		set pfd_l_counter { 16 8 4 2 1}
	}
	set pd_l_counter { 1.0 2.0 4.0 8.0 16.0}
	set m_counter { 1 2 3 4 5 6 8 9 10 12 15 16 18 20 24 25 30 32 36 40 48 50 60 64 72 80 96 100 120 128 160 200 }
	
	if {[string compare $pcie_mode "non_pcie" ] == 0 } { 
	set ref_clk_div { 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 }
	} else {
	set ref_clk_div { 1 }
	}
	
	set index 0
	set ret [dict create]
	 
	if {[string compare $pll_type "CMU" ] == 0 } {   
			foreach lpfd $pfd_l_counter {
				set calc_fvco [expr {$output_clock_frequency_Mhz * $lpfd}] 
				
				if {$calc_fvco >= [get_f_min_vco] && $calc_fvco <= [get_f_max_vco]} {
					foreach mcnt $m_counter {
						set calc_fbclk [expr {double($output_clock_frequency_Mhz) / $mcnt}]	
						if {$calc_fbclk >= [get_f_min_pfd] && $calc_fbclk <= [get_f_max_pfd]} {
							foreach ncnt $ref_clk_div {
								set calc_refclk [expr {$calc_fbclk * $ncnt}]
							
								if { $calc_refclk >= [get_f_min_ref] && $calc_refclk <= [get_f_max_ref] } {	
									set refclk [format "%.6f" $calc_refclk];
									set refclk_str "$refclk"
									dict set ret $index refclk $refclk_str
									dict set ret $index m $mcnt
									dict set ret $index n $ncnt
									dict set ret $index lpfd $lpfd
									incr index
									#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::compute_pll_settings result: $ret " 
								}
							}
						}
					}					 
				}
			}
	} else {
		foreach lpd $pd_l_counter {
			set calc_fvco [expr {$output_clock_frequency_Mhz * $lpd}] 
			if {$calc_fvco >= [get_f_min_vco] && $calc_fvco <= [get_f_max_vco]} {
				foreach lpfd $pfd_l_counter {
					set calc_outclk_pfd [expr {double($calc_fvco)/$lpfd}]
					foreach mcnt $m_counter {
						set calc_fbclk [expr {double($calc_outclk_pfd) / $mcnt}]	
						if {$calc_fbclk >= [get_f_min_pfd] && $calc_fbclk <= [get_f_max_pfd]} {
							foreach ncnt $ref_clk_div {
								set calc_refclk [expr {$calc_fbclk * $ncnt}]
								if { $calc_refclk >= [get_f_min_ref] && $calc_refclk <= [get_f_max_ref] } {	
									set refclk [format "%.6f" $calc_refclk];
									set refclk_str "$refclk"
									dict set ret $index refclk $refclk_str
									dict set ret $index m $mcnt
									dict set ret $index n $ncnt
									dict set ret $index lpfd $lpfd
									dict set ret $index lpd $lpd
									incr index
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
	
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_reference_clock_frequency { output_clock_frequency} {
    set result [compute_pll_settings $output_clock_frequency "CMU" "non_pcie"]
	
	set ret_length [llength [dict keys $result] ]
	for {set x 0} {$x<$ret_length} {incr x} {
		set this_item [dict get $result $x]
		set refclk [dict get $this_item refclk]
		
		########## get the last index of refclk , remove duplicates and sort ######################
		lappend valid_refclk "$refclk"
		set list_of_valid_refclk [lsort -real -unique -index 0 $valid_refclk] 
	
	}
	
		::alt_xcvr::utils::common::map_allowed_range reference_clock_frequency $list_of_valid_refclk
		#ip_set "parameter.reference_clock_frequency.allowed_ranges" $list_of_valid_refclk
		#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_reference_clock_frequency list_of_valid_refclk: $list_of_valid_refclk"
	return $list_of_valid_refclk
	}
	
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_cdr_pll_ref_clock_frequency {reference_clock_frequency } {
			 
			set reference_clock_freq "$reference_clock_frequency MHz"
			ip_set "parameter.cdr_pll_ref_clock_frequency.value" $reference_clock_freq
			
			#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_cdr_pll_ref_clock_frequency cdr_pll_ref_clock_frequency: $reference_clock_freq"
		
	return $reference_clock_freq
	}	
		
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_output_clock_frequency {output_clock_frequency} {
		set output_clock_freq "$output_clock_frequency MHz"
		ip_set "parameter.cdr_pll_out_clock_frequency.value" $output_clock_freq
		#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_output_clock_frequency cdr_pll_out_clock_frequency: $output_clock_freq"
	return $output_clock_freq
	}

proc ::altera_xcvr_cdr_pll_vi::parameters::validate_auto_counters {cdr_pll_ref_clock_frequency output_clock_frequency} {
          # starting with an empty list	
   ip_set "parameter.auto_counters.value" ""
   
   # eventually temp will be copied into parameter.auto_counters
    set temp ""
	set result [compute_pll_settings $output_clock_frequency "CMU" "non_pcie"]
	set ret_length_pre [llength [dict keys $result] ]
	
	set ret_length [expr {$ret_length_pre - 1}] 
	
	set selected_refclk [lindex $cdr_pll_ref_clock_frequency 0]
	set cdr_pll_ref_clock_frequency_formatted [format "%.6f" $selected_refclk]
	
	
	for {set x $ret_length} {$x>0} {incr x -1} {

		set this_item [dict get $result $x]
		dict set temp refclk [dict get $this_item refclk]
		dict set temp m_cnt  [dict get $this_item m]
		dict set temp n_cnt  [dict get $this_item n]
		dict set temp lpfd_cnt  [dict get $this_item lpfd]
		
	#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_auto_counters cdr_pll_ref_clock_frequency_formatted: $cdr_pll_ref_clock_frequency_formatted"	
	
		set all_freq [dict get $temp refclk]
		if {[string compare $cdr_pll_ref_clock_frequency_formatted $all_freq] == 0} {
			
			ip_set "parameter.auto_counters.value" $temp
			
			#ip_message info "temp $temp"
		
		} 
	}
	return $temp
	}


	
	# validate_manual_counters - Get valid counter values based on user input refclk #
	# ## Not applicable for now
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_manual_counters {cdr_pll_ref_clock_frequency output_clock_frequency select_manual_config} {
	set result [compute_pll_settings $output_clock_frequency "CMU" "non_pcie"]
	set ret_length [llength [dict keys $result] ]
	
	set selected_refclk [lindex $cdr_pll_ref_clock_frequency 0]
	set cdr_pll_ref_clock_frequency_formatted [format "%.6f" $selected_refclk]
	#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_manual_counters selected_refclk: $selected_refclk"
	for {set x 0} {$x<$ret_length} {incr x} {
		set this_item [dict get $result $x]
		set refclk [dict get $this_item refclk]
		set m_cnt  [dict get $this_item m]
		set n_cnt  [dict get $this_item n]
		set lpfd_cnt  [dict get $this_item lpfd]
		
	
		
		if {[string compare $cdr_pll_ref_clock_frequency_formatted $refclk] == 0} {
			
			lappend display_counters "n   $n_cnt     lpfd   $lpfd_cnt    m   $m_cnt             "	
			#::alt_xcvr::utils::common::map_allowed_range manual_counters $display_counters
			if {$select_manual_config} {
			ip_set "parameter.manual_counters.allowed_ranges" $display_counters
			} else {
			::alt_xcvr::utils::common::map_allowed_range manual_counters $display_counters
			}
		} 
	}
	return $display_counters
	}

	# Extract and map n_counter value
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_n_counter {auto_counters } {

	ip_set "parameter.cdr_pll_ncounter.value" [dict get $auto_counters n_cnt]
	#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_n_counter n_cnt: $n_cnt"
  
 }	
 
	# Extract and map lpfd_counter value
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_lpfd_counter {auto_counters} {
   
    ip_set "parameter.cdr_pll_pfd_lcounter.value" [dict get $auto_counters lpfd_cnt]
	#ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_lpfd_counter lpfd_cnt: $lpfd_cnt"
}
 
 
	# Extract and map m_counter value
proc ::altera_xcvr_cdr_pll_vi::parameters::validate_m_counter {auto_counters} {
   
   ip_set "parameter.cdr_pll_mcounter.value" [dict get $auto_counters m_cnt]
   #ip_message info "::altera_xcvr_cdr_pll_vi::parameters::validate_m_counter m_cnt: $m_cnt"
}

proc ::altera_xcvr_cdr_pll_vi::parameters::validate_speed_grade {speed_grade} {
   set temp "dash4"
   if { [string compare -nocase $speed_grade 1_H2]==0 } {
      set temp "dash2"   
   } elseif { [string compare -nocase $speed_grade 1_H3]==0 } {
      set temp "dash3"
   } elseif { [string compare -nocase $speed_grade 1_H4]==0 } {
      set temp "dash4"
   } else {
      set temp "dash4"
   }
   ip_set "parameter.speed_grade_atom.value" $temp

}

proc ::altera_xcvr_cdr_pll_vi::parameters::validate_bw_sel {bw_sel } {
	set temp "low"
   if { [string compare -nocase $bw_sel Low]==0 } {
      set temp "low"   
   } elseif { [string compare -nocase $bw_sel Medium]==0 } {
      set temp "medium"
   } elseif { [string compare -nocase $bw_sel High]==0 } {
      set temp "high"
   } else {
      set temp "low"
   }
   ip_set "parameter.bw_sel_atom.value" $temp
	
}	
