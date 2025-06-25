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


# +-----------------------------------
# | request TCL package from other libraries
# |
package provide altera_xcvr_fpll_vi::parameters 13.1
package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::common
package require quartus::qcl_pll 
package require quartus::advanced_pll_legality 
package require mcgb_package_vi::mcgb
package require alt_xcvr::utils::reconfiguration_arria10

# +-----------------------------------
# | create CMU_FPLL parameter list
# | 
namespace eval ::altera_xcvr_fpll_vi::parameters:: {
   namespace import ::alt_xcvr::ip_tcl::ip_module::*
   namespace import ::alt_xcvr::ip_tcl::messages::*
   namespace export \
      declare_parameters \
      validate \

   variable display_items_pll
   variable generation_display_items
   variable refclk_switchover_display_items
   variable parameters
   variable parameters_allowed_range
   variable atom_parameters
   variable logical_parameters
   variable debug_message

   # turn on/off debug message
   set debug_message 0
   
   # creating items for display elements such as tab, header...	
   set display_items_pll {\
      {NAME                         GROUP                    ENABLED   VISIBLE   TYPE   ARGS  } \
      {"PLL"                    	""                       NOVAL     NOVAL     GROUP  tab   } \	  
      {"General"              		"PLL"                	 NOVAL     NOVAL     GROUP  noval } \	  
      {"Feedback"                   "PLL"                    NOVAL     NOVAL     GROUP  noval } \
      {"Ports"                      "PLL"                    NOVAL     NOVAL     GROUP  noval } \
	  {"Output Frequency"           "PLL"                    NOVAL     NOVAL     GROUP  noval } \ 
      {"Transceiver Usage"          "Output Frequency"       NOVAL     NOVAL     GROUP  noval } \	  
      {"Core Usage"              	"Output Frequency"       NOVAL     NOVAL     GROUP  noval } \	  
      {"outclk0"              		"Core Usage"             NOVAL     NOVAL     GROUP  noval } \	  
      {"outclk1"              		"Core Usage"             NOVAL     NOVAL     GROUP  noval } \	  
      {"outclk2"              		"Core Usage"             NOVAL     NOVAL     GROUP  noval } \	  
      {"outclk3"              		"Core Usage"             NOVAL     NOVAL     GROUP  noval } \
   }

   set generation_display_items {\
      {NAME                         GROUP                    ENABLED   VISIBLE   TYPE   ARGS  } \
      {"Generation Options"         ""                       NOVAL     NOVAL     GROUP  tab   } \
   }

   set refclk_switchover_display_items {\
      {NAME                           GROUP                  ENABLED   VISIBLE   TYPE   ARGS  } \
      {"Clock Switchover"             ""                     NOVAL     NOVAL     GROUP  tab   } \
	  {"Input Clock Switchover Mode"  "Clock Switchover"     NOVAL     NOVAL     GROUP  noval } \
   }

   # creating items for widgets for each parameters such as check box, drop down list...
   set parameters {\
      {NAME                                 M_CONTEXT  M_USED_FOR_RCFG  M_SAME_FOR_RCFG  VALIDATION_CALLBACK                                                          DERIVED HDL_PARAMETER   TYPE      DEFAULT_VALUE 							ALLOWED_RANGES                               							  						ENABLED                  	   																																																			VISIBLE                   											DISPLAY_HINT  DISPLAY_UNITS 	DISPLAY_ITEM     				DISPLAY_NAME                                         				DESCRIPTION } \
      {gui_refclk_switch              		NOVAL      0                0                NOVAL                         												  false   false           BOOLEAN   false                        			NOVAL                                               					  						true                     																																																				true                     											BOOLEAN       NOVAL         	"Clock Switchover"      		"Create a second input clock 'pll_refclk1'"                			"Turn on this parameter to have a backup clock attached to your FPLL that can switch with your original reference clock"} \
      {gui_refclk1_frequency      			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_reference_clock1_frequency         false   false           FLOAT     100.0          							NOVAL                                        							  						gui_refclk_switch 																																																						true   					 											NOVAL         MHz           	"Clock Switchover"     			"Second Reference Clock Frequency"                   				"Specifies the second reference clock frequency for FPLL"} \
      {gui_switchover_mode                  NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_switchover_mode                    false   false           STRING    "Automatic Switchover"  				{"Automatic Switchover" "Manual Switchover" "Automatic Switchover with Manual Override"}      	gui_refclk_switch                     	   																																																true                      											RADIO         NOVAL         	"Input Clock Switchover Mode"	"Switchover Mode"  									 				"Specifies how Input frequency switchover will be handled. Automatic Switchover will use built in circuitry to detect if one of your input clocks has stopped toggling and switch to the other. Manual Switchover will create an EXTSWITCH signal which can be used to manually switch the clock by asserting high for atleast 3 cycles.  Automatic Switchover with Manual Override will perform act as Automatic Switchover until the EXTSWITCH goes high, in which case it will switch and ignore any automatic switches as long as EXTSWITCH stays high"} \
      {gui_switchover_delay                 NOVAL      0                0                NOVAL                    													  false   false           INTEGER   0                        				{0 1 2 3 4 5 6 7}                                         					  					gui_refclk_switch                     																																																	true                      											NOVAL         NOVAL         	"Input Clock Switchover Mode"   "Switchover Delays"          			 			 				"Adds a specific amount of cycle delay to the Switchover Process."}\
      {gui_enable_active_clk               	NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   false           						NOVAL                                       	 						  						gui_refclk_switch                         																																																true                      											BOOLEAN       NOVAL         	"Input Clock Switchover Mode"  	"Create an 'active_clk' signal to indicate the input clock in use"  "This parameter creates an output which indicates which input clock is currently in use by the PLL. Low indicates refclk, High indicates refclk1."} \
      {gui_enable_clk_bad               	NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   false           						NOVAL                                       	 						  						gui_refclk_switch                         																																																true                      											BOOLEAN       NOVAL         	"Input Clock Switchover Mode"  	"Create a 'clkbad' signal for each of the input clocks"             "This parameter creates two CLKBAD outputs, one for each input clock. Low indicates the CLK is working, High indicates the CLK isn't working."} \
      {gui_enable_extswitch               	NOVAL	   0				0				 NOVAL                                                                        true    false           BOOLEAN   false           						NOVAL                                       	 						  						gui_refclk_switch                         																																																false                      											BOOLEAN       NOVAL         	"Input Clock Switchover Mode"  	NOVAL                  				 								NOVAL       } \
      \																																		
      {enable_advanced_options              NOVAL      0                0                NOVAL                                                               		  true    false           INTEGER   0                        				{ 0 1 }                                               					  						true                     																																																				false                     											NOVAL         NOVAL         	NOVAL                  			NOVAL                                     							NOVAL} \
      {enable_hip_options                   NOVAL      0                0                NOVAL                                                               		  true    false           INTEGER   0                        				{ 0 1 }                                               					  						true                     																																																				false                     											NOVAL         NOVAL         	NOVAL                  			NOVAL                                     							NOVAL} \
      {generate_docs                        NOVAL      0                0                NOVAL                                                               		  false   false           INTEGER   1                        				NOVAL                                                 					  						true                     																																																				true                      											BOOLEAN       NOVAL         	"Generation Options"   			"Generate parameter documentation file"             				"When enabled, generation will produce a .CSV file with descriptions of the IP parameters."} \
      {generate_add_hdl_instance_example    NOVAL	   0                0                NOVAL                                                               		  false   false           INTEGER   0                        				NOVAL                                                 					  						enable_advanced_options  																																																				enable_advanced_options   											BOOLEAN       NOVAL         	"Generation Options"   			"Generate '_hw.tcl' 'add_hdl_instance' example file"				"When enabled, generation will produce a file containing an example of how to use the '_hw.tcl' 'add_hdl_instance' API. The example will be correct for the current configuration of the IP."} \
      {device_family                        NOVAL	   0				0				 NOVAL                                                                        false   false           STRING    "Arria VI"  							NOVAL                                        							  						true                     	   																																																			false                     											NOVAL         NOVAL         	NOVAL            				NOVAL                                               				NOVAL       } \
      \                                     																																																															
      {silicon_rev                          NOVAL      0                0                NOVAL                                                               		  false   false           BOOLEAN   false                    				NOVAL                                                 											true                     																																																				false                        										NOVAL         NOVAL         	"General"                      "Silicon revision ES"                                   				NOVAL} \
      {gui_silicon_rev                      NOVAL	   0                0                ::altera_xcvr_fpll_vi::parameters::update_silicon_rev           			  true    false           STRING    "reva"                   				{ "reva" "revb" "revc" }                              											true                     																																																				false                        										NOVAL         NOVAL         	NOVAL                          NOVAL                                                   				NOVAL} \
      {gui_device_speed_grade               NOVAL	   0				0				 NOVAL                                                                        false   false           STRING    "fastest"     							NOVAL                                        							  						true                     	   																																																			true                      											NOVAL         NOVAL         	"General"        				"Device speed grade"                                				"Specifies the desired device speedgrade. This information is used for data rate validation."} \
      \                                     																																																																
      {gui_reference_clock_frequency 		NOVAL	   0				0				 NOVAL                                                                        false   false           FLOAT     100.0         							NOVAL                                        							  						true                     	   																																																			true      				 											NOVAL         MHz           	"General"  						"Reference clock frequency"                      					NOVAL       } \
      {reference_clock_frequency 		    NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_reference_clock_frequency      	  true    true            STRING    "100.0 MHz"     						NOVAL                                        							  						true                     	   																																																			false      				 											NOVAL         MHz           	"General"  						"Reference clock frequency"                      					NOVAL       } \
      \                                                                                                                  																																																																
      {vco_frequency 		    			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_vco_frequency      				  true    true            STRING    "300.0 MHz"     						NOVAL                                        							  						true                     	   																																																			false      				 											NOVAL         MHz           	"General"  						"VCO Frequency"                      								NOVAL       } \
      \                                                                                                           																																																													
      {gui_operation_mode                   NOVAL	   0				0				 NOVAL                  													  false   false           STRING    "direct"  								{ "direct" "normal" "IQTXRXCLK" }      															"!enable_fb_comp_bonding"                     	   																																														true                      											NOVAL         NOVAL         	"Feedback"  					"Operation mode"                                 					"Specifies the operation mode for FPLL."} \
      {compensation_mode                    NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_compensation_mode                  true    true            STRING    "direct"  								{ "direct" "normal" "fpll_bonding" "iqtxrxclk" }      											true                     	   																																																			false                      											NOVAL         NOVAL         	"Feedback"  					"Operation mode"                                 					"Specifies the operation mode for FPLL."} \
      {gui_enable_iqtxrxclk_mode       		NOVAL	   0				0				 NOVAL         																  true    false           BOOLEAN   false           						NOVAL                                       	 						  						true                         																																																			false                      											BOOLEAN       NOVAL         	"Feedback"  					"Operation mode for IQTXRXCLK"       								NOVAL       } \
      {gui_iqtxrxclk_outclk_index      		NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_iqtxrxclk_outclk_index       	  false   false           STRING    "0"  									{ 0 1 2 3 }      														  						true        							   																																																gui_enable_iqtxrxclk_mode                     						NOVAL         NOVAL         	"Feedback"  					 "Specifies which core outclk to be used as feedback source"        "Specifies the feedback source for IQTXRXCLK operation mode."} \
	  \																																																												
      {gui_bw_sel                           NOVAL	   1				0				 NOVAL                                                                        false   false           STRING    "low"           						NOVAL  							  										  						true                     	   																																																			true                      											NOVAL         NOVAL         	"General"  						"Bandwidth"                                          				NOVAL       } \
      \                                                                                                                  																																																											
      {gui_refclk_cnt                       NOVAL      1                1                NOVAL                                                               		  false   false           INTEGER   1                        				{ 1 2 3 4 5 }                                         					  						true                     																																																				true                      											NOVAL         NOVAL         	"General"              			"Number of PLL reference clocks"          							"Specifies the number of input reference clocks for the FPLL."}\
      {gui_refclk_index                     NOVAL      1                0                ::altera_xcvr_fpll_vi::parameters::update_refclk_index           			  false   false           INTEGER   0                        				NOVAL                                                 					  						true                     																																																				true                      											NOVAL         NOVAL         	"General"              			"Selected reference clock source"         							"Specifies the initially selected reference clock input to the FPLL."}\
	  \																																													
      {gui_enable_fractional                NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   false         							NOVAL                                        							  						true  				   	   																																																				true                      											NOVAL         NOVAL         	"General"  						"Enable fractional mode"                          					 NOVAL       } \
      \                                                                                                                  																																																															
      {gui_enable_pcie_clk                  NOVAL 	   1                1                ::altera_xcvr_fpll_vi::parameters::update_enable_pcie_clk                    false   false           INTEGER   0                        				NOVAL                                                 											true                     																																																				true                      											BOOLEAN       NOVAL         	"Ports"                         "Enable PCIe clock output port"                         			 NOVAL		 } \
      {gui_enable_pld_cal_busy_port         NOVAL      1                1                NOVAL                                                               		  false   false           INTEGER   1               						{ 0 1 }                                               					  						false                    																																																				false                     											BOOLEAN       NOVAL         	NOVAL                  			"enable_pld_fpll_cal_busy_port"                     				 NOVAL		 } \
      {gui_enable_hip_cal_done_port         NOVAL      1                1                NOVAL                                                               		  false   false           INTEGER   0               						NOVAL                                               					  						enable_hip_options	 																																																					enable_hip_options        											BOOLEAN       NOVAL         	"Ports"                       	"Enable calibration status ports for HIP"                     				 "Enables calibration status port from PLL and Master CGB(if enabled) for HIP"		 } \
	  \																																		
      {gui_enable_cascade_out               NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_enable_cascade_out                 false   false           BOOLEAN   false           						NOVAL                                       	 						  						true                         																																																			true                      											BOOLEAN       NOVAL         	"Ports"  						"Enable cascade clock output port (FPLL to FPLL cascading)"          NOVAL       } \
      {gui_cascade_outclk_index             NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_cascade_outclk_index               false   false           STRING    "0"  									{ 0 1 2 3 }      														  						gui_enable_cascade_out        							   																																												true                      											NOVAL         NOVAL         	"Ports"  					    "Specifies which core outclk to be used as cascading source"         "Specifies the cascading source for FPLL to FPLL cascading."} \
      {gui_enable_atx_pll_cascade_out       NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_enable_atx_pll_cascade_out         false   false           BOOLEAN   false           						NOVAL                                       	 						  						true                         																																																			true                      											BOOLEAN       NOVAL         	"Ports"  						"Enable cascade clock output port (FPLL to ATX PLL cascading)"       NOVAL       } \
      {gui_atx_pllcascade_outclk_index      NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_atx_pll_cascade_outclk_index       false   false           STRING    "0"  									{ 0 1 2 3 }      														  						gui_enable_atx_pll_cascade_out        							   																																										true                      											NOVAL         NOVAL         	"Ports"  					    "Specifies which core outclk to be used as cascading source"         "Specifies the cascading source for FPLL to ATX PLL cascading."} \
      \                                                                                                                  																																																																	
      {gui_enable_dps             			NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   false           						NOVAL                                        							  						true                     	   																																																			true                      											BOOLEAN       NOVAL         	"Ports"  						"Enable access to dynamic phase shift ports"           				 NOVAL       } \
      \                                                                                                                  																																																																	
      {gui_enable_manual_config             NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   false           						NOVAL                                        							  						true                     	   																																																			true                      											BOOLEAN       NOVAL         	"General"  						"Enable physical output clock parameters"           				 NOVAL       } \
	  \																																																																
      {gui_enable_transceiver_usage         NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   true         							NOVAL                                        							  						true  				  	   																																																				true                      											BOOLEAN       NOVAL         	"Transceiver Usage"  			"Use as Transceiver PLL"                       						 NOVAL       } \
	  \																																																																
      {gui_hssi_prot_mode                   NOVAL	   1				0				 NOVAL                                                                        false   false           STRING    "Basic"       							{ "Basic" "PCIe Gen 1" "PCIe Gen 2" }			  												gui_enable_transceiver_usage 																																																			true                      											NOVAL         NOVAL         	"Transceiver Usage"     		"Protocol mode"                                     				 NOVAL       } \
      {prot_mode                   			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_prot_mode				    	  true    true            STRING    "basic_tx"      						NOVAL                           							  			  						gui_enable_transceiver_usage 																																																			false                      											NOVAL         NOVAL         	"Transceiver Usage"     		"Protocol mode"                                     				 NOVAL       } \
      \                                                                                                                  																																																																
      {gui_hssi_output_clock_frequency      NOVAL	   0				0				 NOVAL                                                                        false   false           FLOAT     1250.0          						NOVAL                                        							  						gui_enable_transceiver_usage 																																																			"!gui_enable_manual_config"   					 					NOVAL         MHz           	"Transceiver Usage"     		"PLL output frequency"                              				 NOVAL       } \
      {gui_actual_hssi_clock_frequency      NOVAL	   0				0				 NOVAL          															  false   false           STRING    "1250.0 MHz"          					NOVAL                                        							  						gui_enable_transceiver_usage 																																																			gui_enable_manual_config   					 						NOVAL         NOVAL           	"Transceiver Usage"     		"PLL output frequency"                              				 NOVAL       } \
      \                                                                                                                  																																																																
      {hssi_output_clock_frequency  		NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_hssi_output_clock_frequency    	  true    true            STRING    "1250.0 MHz"    						NOVAL                                        							  						gui_enable_transceiver_usage 																																																			false      				 											NOVAL         MHz           	"Transceiver Usage"     		"PLL output frequency"                      	 					 NOVAL       } \
      \                                                                                                                  																																																																
      {gui_pll_l_counter                    NOVAL	   1				0				 NOVAL                                                                        false   false           INTEGER   1             							{ 1 2 4 8 } 															  						gui_enable_transceiver_usage 																																																			gui_enable_manual_config 											NOVAL 		  NOVAL  			"Transceiver Usage"  			"Divide factor (L-counter)"                        					 NOVAL       } \
      \                                                                                                                  																																																																
      {gui_enable_core_usage             	NOVAL	   0				0				 NOVAL                                                                        false   false           BOOLEAN   false         							NOVAL                                        							  						true  				   	   																																																				true                      											BOOLEAN       NOVAL         	"Core Usage"  					"Use as Core PLL"                       		 					 NOVAL       } \
      \                                                                                                                  																																																							
      {gui_number_of_output_clocks          NOVAL	   0				0				 NOVAL                                                                        false   false           STRING    "1"  									{ 1 2 3 4 }      														  						gui_enable_core_usage        							   																																												true                      											NOVAL         NOVAL         	"Core Usage"  					"Number of clocks"                                  				 "Specifies the number of output clocks required in the FPLL design."} \
      \                                                                                                                  																																																													
      {gui_pll_m_counter                    NOVAL	   1				0				 NOVAL                      												  false   false           INTEGER   1             							{1:256} 																  						"gui_enable_core_usage || gui_enable_transceiver_usage"	   																																												gui_enable_manual_config 											NOVAL 		  NOVAL  			"Output Frequency"  			"Multiply factor (M-counter)"                       				 NOVAL       } \
      {gui_pll_dsm_fractional_division      NOVAL	   0				0				 NOVAL                                                                        false   false           LONG  	1             							{0:2147483647} 															  						"gui_enable_core_usage || gui_enable_transceiver_usage"	   																																												"gui_enable_manual_config && gui_enable_fractional"					NOVAL 		  NOVAL  			"Output Frequency"  			"Fractional multiply factor (K)"                    				 NOVAL       } \
      {gui_pll_n_counter                    NOVAL	   1				0				 NOVAL                                                                        false   false           INTEGER   1             							{1:32} 																  	  						"gui_enable_core_usage || gui_enable_transceiver_usage"	   																																												gui_enable_manual_config 											NOVAL 		  NOVAL  			"Output Frequency"  			"Divide factor (N-counter)"                        					 NOVAL       } \
      \                                                                                                                  																																																									
      {gui_desired_outclk0_frequency 		NOVAL	   0				0				 NOVAL                                                                        false   false           FLOAT     100.0         							NOVAL                                        							  						gui_enable_core_usage        																																																			"gui_number_of_output_clocks >= 1 && !gui_enable_manual_config"   	NOVAL         MHz           	"outclk0"  			    		"Desired frequency"                      			 				"Specifies requested value for output clock frequency"} \
      {gui_pll_c_counter_0                  NOVAL	   1				0				 NOVAL                                                                        false   false           INTEGER   1             							{1:256} 																  						gui_enable_core_usage 	   																																																				"gui_number_of_output_clocks >= 1 && gui_enable_manual_config" 	 	NOVAL 		  NOVAL  			"outclk0"  			    		"Divide factor (C-counter 0)"                        				NOVAL       } \
      {gui_actual_outclk0_frequency         NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_outclk0_frequency_values   	  false   false           STRING    "100.0 MHz"  							NOVAL     											  					  						gui_enable_core_usage        																																																			"gui_number_of_output_clocks >= 1"   								NOVAL         NOVAL         	"outclk0"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {output_clock_frequency_0         	NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_0   	 	  true    true			  STRING    "100.0 MHz"  							NOVAL     											  					  						gui_enable_core_usage        																																																			false							    								NOVAL         NOVAL         	"outclk0"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {gui_outclk0_phase_shift_unit         NOVAL	   0				0				 NOVAL           															  false   false           STRING    "ps"  									{ "ps" "degrees" }    													  						gui_enable_core_usage        																																																			"gui_number_of_output_clocks >= 1"   								NOVAL         NOVAL         	"outclk0"  			    		"Phase shift units"                                  				"Specifies phase shift in degrees or picoseconds"} \
      {gui_outclk0_desired_phase_shift      NOVAL	   0				0				 NOVAL        																  false   false           INTEGER   0    									NOVAL     													  			  						gui_enable_core_usage        																																																			"gui_number_of_output_clocks >= 1"   								NOVAL         "ps / degrees"    "outclk0"  			    		"Phase shift"                                  		 				"Specifies requested value for phase shift"} \
      {gui_outclk0_actual_phase_shift       NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_0_values		 	  false   false           STRING    "0 ps"  								NOVAL     													  			  						gui_enable_core_usage        																																																			"gui_number_of_output_clocks >= 1"   								NOVAL         NOVAL         	"outclk0"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      {phase_shift_0       					NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_phase_shift_0                  	  true    true            STRING    "0 ps"  								NOVAL     													  			  						gui_enable_core_usage        																																																			false   															NOVAL         NOVAL         	"outclk0"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      \                                                                                                                  																			
      {gui_desired_outclk1_frequency 		NOVAL	   0				0				 NOVAL                                                                        false   false           FLOAT     100.0         							NOVAL                                        							  						"gui_enable_core_usage && !gui_enable_atx_pll_cascade_out && !gui_enable_iqtxrxclk_mode || gui_enable_atx_pll_cascade_out && gui_atx_pllcascade_outclk_index == 1 || gui_enable_iqtxrxclk_mode && gui_iqtxrxclk_outclk_index == 1"    	"gui_number_of_output_clocks >= 2 && !gui_enable_manual_config"   	NOVAL         MHz           	"outclk1"  			    		"Desired frequency"                      			 				"Specifies requested value for output clock frequency"} \
      {gui_pll_c_counter_1                  NOVAL	   1				0				 NOVAL                                                                        false   false           INTEGER   1             							{1:256} 																  						"gui_enable_core_usage && !gui_enable_atx_pll_cascade_out && !gui_enable_iqtxrxclk_mode || gui_enable_atx_pll_cascade_out && gui_atx_pllcascade_outclk_index == 1 || gui_enable_iqtxrxclk_mode && gui_iqtxrxclk_outclk_index == 1"		"gui_number_of_output_clocks >= 2 && gui_enable_manual_config" 	 	NOVAL 		  NOVAL  			"outclk1"  						"Divide factor (C-counter 1)"                        				NOVAL       } \
      {gui_actual_outclk1_frequency         NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_outclk1_frequency_values   	  false   false           STRING    "100.0 MHz"  							NOVAL     											  					  						"gui_enable_core_usage && !gui_enable_atx_pll_cascade_out && !gui_enable_iqtxrxclk_mode || gui_enable_atx_pll_cascade_out && gui_atx_pllcascade_outclk_index == 1 || gui_enable_iqtxrxclk_mode && gui_iqtxrxclk_outclk_index == 1"    	"gui_number_of_output_clocks >= 2"  								NOVAL         NOVAL         	"outclk1"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {output_clock_frequency_1         	NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_1   	 	  true    true			  STRING    "100.0 MHz"  							NOVAL     											  					  						gui_enable_core_usage      																																																				false							    								NOVAL         NOVAL         	"outclk1"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {gui_outclk1_phase_shift_unit         NOVAL	   0				0				 NOVAL                                                                        false   false           STRING    "ps"  									{ "ps" "degrees" }    													  						"gui_enable_core_usage && !gui_enable_atx_pll_cascade_out && !gui_enable_iqtxrxclk_mode || gui_enable_atx_pll_cascade_out && gui_atx_pllcascade_outclk_index == 1 || gui_enable_iqtxrxclk_mode && gui_iqtxrxclk_outclk_index == 1"    	"gui_number_of_output_clocks >= 2"  								NOVAL         NOVAL         	"outclk1"  			    		"Phase shift units"                                  				"Specifies phase shift in degrees or picoseconds"} \
      {gui_outclk1_desired_phase_shift      NOVAL	   0				0				 NOVAL                                                                        false   false           INTEGER   0    									NOVAL     													  			  						"gui_enable_core_usage && !gui_enable_atx_pll_cascade_out && !gui_enable_iqtxrxclk_mode || gui_enable_atx_pll_cascade_out && gui_atx_pllcascade_outclk_index == 1 || gui_enable_iqtxrxclk_mode && gui_iqtxrxclk_outclk_index == 1"    	"gui_number_of_output_clocks >= 2"  								NOVAL         "ps / degrees"    "outclk1"  			    		"Phase shift"                                  		 				"Specifies requested value for phase shift"} \
      {gui_outclk1_actual_phase_shift       NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_1_values		 	  false   false           STRING    "0 ps"  								NOVAL     													  			  						"gui_enable_core_usage && !gui_enable_atx_pll_cascade_out && !gui_enable_iqtxrxclk_mode || gui_enable_atx_pll_cascade_out && gui_atx_pllcascade_outclk_index == 1 || gui_enable_iqtxrxclk_mode && gui_iqtxrxclk_outclk_index == 1"    	"gui_number_of_output_clocks >= 2"  								NOVAL         NOVAL         	"outclk1"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      {phase_shift_1       					NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_phase_shift_1                  	  true    true            STRING    "0 ps"  								NOVAL     													  			  						gui_enable_core_usage      																																																				false   															NOVAL         NOVAL         	"outclk1"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      \                                                                                                                  																																																														
      {gui_desired_outclk2_frequency 		NOVAL	   0				0				 NOVAL                                                                        false   false           FLOAT     100.0         							NOVAL                                        							  						gui_enable_core_usage      																																																				"gui_number_of_output_clocks >= 3 && !gui_enable_manual_config"     NOVAL         MHz           	"outclk2"  			    		"Desired frequency"                      			 				"Specifies requested value for output clock frequency"} \
      {gui_pll_c_counter_2                  NOVAL	   1				0				 NOVAL                                                                        false   false           INTEGER   1             							{1:256} 																  						gui_enable_core_usage 	 																																																				"gui_number_of_output_clocks >= 3 && gui_enable_manual_config" 	    NOVAL 		  NOVAL  			"outclk2"  						"Divide factor (C-counter 2)"                        				NOVAL       } \
      {gui_actual_outclk2_frequency         NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_outclk2_frequency_values   	  false   false           STRING    "100.0 MHz"  							NOVAL     											  					  						gui_enable_core_usage      																																																				"gui_number_of_output_clocks >= 3"  							 	NOVAL         NOVAL         	"outclk2"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {output_clock_frequency_2         	NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_2   	 	  true    true			  STRING    "100.0 MHz"  							NOVAL     											  					  						gui_enable_core_usage      																																																				false							    								NOVAL         NOVAL         	"outclk2"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {gui_outclk2_phase_shift_unit         NOVAL	   0				0				 NOVAL                                                                        false   false           STRING    "ps"  									{ "ps" "degrees" }    													  						gui_enable_core_usage      																																																				"gui_number_of_output_clocks >= 3"  							 	NOVAL         NOVAL         	"outclk2"  			    		"Phase shift units"                                  				"Specifies phase shift in degrees or picoseconds"} \
      {gui_outclk2_desired_phase_shift      NOVAL	   0				0				 NOVAL                                                                        false   false           INTEGER   0    									NOVAL     													  			  						gui_enable_core_usage      																																																				"gui_number_of_output_clocks >= 3"  							 	NOVAL         "ps / degrees"    "outclk2"  			    		"Phase shift"                                  		 				"Specifies requested value for phase shift"} \
      {gui_outclk2_actual_phase_shift       NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_2_values		 	  false   false           STRING    "0 ps"  								NOVAL     													  			  						gui_enable_core_usage      																																																				"gui_number_of_output_clocks >= 3"  							 	NOVAL         NOVAL         	"outclk2"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      {phase_shift_2       					NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_phase_shift_2                  	  true    true            STRING    "0 ps"  								NOVAL     													  			  						gui_enable_core_usage      																																																				false   															NOVAL         NOVAL         	"outclk2"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      \                                                                                                                  																																																														
      {gui_desired_outclk3_frequency 		NOVAL	   0				0				 NOVAL                                                                        false   false           FLOAT     100.0         							NOVAL                                        							  						"gui_enable_core_usage && !gui_enable_cascade_out || gui_enable_cascade_out && gui_cascade_outclk_index == 3"    																														"gui_number_of_output_clocks == 4 && !gui_enable_manual_config"   	NOVAL         MHz           	"outclk3"  			    		"Desired frequency"                      			 				"Specifies requested value for output clock frequency"} \
      {gui_pll_c_counter_3                  NOVAL	   1				0				 NOVAL                                                                        false   false           INTEGER   1             							{1:256} 																  						"gui_enable_core_usage && !gui_enable_cascade_out || gui_enable_cascade_out && gui_cascade_outclk_index == 3" 	 																														"gui_number_of_output_clocks == 4 && gui_enable_manual_config" 	 	NOVAL 		  NOVAL  			"outclk3"  						"Divide factor (C-counter 3)"                        				NOVAL       } \
      {gui_actual_outclk3_frequency         NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_outclk3_frequency_values   	  false   false           STRING    "100.0 MHz"  							NOVAL     											  					  						"gui_enable_core_usage && !gui_enable_cascade_out || gui_enable_cascade_out && gui_cascade_outclk_index == 3"      																														"gui_number_of_output_clocks == 4"   								NOVAL         NOVAL         	"outclk3"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {output_clock_frequency_3         	NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_3   	 	  true    true			  STRING    "100.0 MHz"  							NOVAL     											  					  						gui_enable_core_usage      																																																				false   															NOVAL         NOVAL         	"outclk3"  			    		"Actual frequency"                                   				"Specifies actual value for output clock frequency"} \
      {gui_outclk3_phase_shift_unit         NOVAL	   0				0				 NOVAL                                                                        false   false           STRING    "ps"  									{ "ps" "degrees" }    													  						"gui_enable_core_usage && !gui_enable_cascade_out || gui_enable_cascade_out && gui_cascade_outclk_index == 3"      																														"gui_number_of_output_clocks == 4"   								NOVAL         NOVAL         	"outclk3"  			    		"Phase shift units"                                  				"Specifies phase shift in degrees or picoseconds"} \
      {gui_outclk3_desired_phase_shift      NOVAL	   0				0				 NOVAL                                                                        false   false           INTEGER   0    									NOVAL     													  			  						"gui_enable_core_usage && !gui_enable_cascade_out || gui_enable_cascade_out && gui_cascade_outclk_index == 3"      																														"gui_number_of_output_clocks == 4"   								NOVAL         "ps / degrees"    "outclk3"  			    		"Phase shift"                                  		 				"Specifies requested value for phase shift"} \
      {gui_outclk3_actual_phase_shift       NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_3_values		 	  false   false           STRING    "0 ps"  								NOVAL     													  			  						"gui_enable_core_usage && !gui_enable_cascade_out || gui_enable_cascade_out && gui_cascade_outclk_index == 3"      																														"gui_number_of_output_clocks == 4"   								NOVAL         NOVAL         	"outclk3"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      {phase_shift_3       					NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_phase_shift_3                  	  true    true            STRING    "0 ps"  								NOVAL     													  			  						gui_enable_core_usage      																																																				false   															NOVAL         NOVAL         	"outclk3"  			    		"Actual phase shift"                                 				"Specifies actual value for phase shift"} \
      \                                                                                                                  																																																																						
 	  {gui_pll_clkin_0_src        			NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "pll_clkin_0_src_lvpecl"  				NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clkin_0_src"                                    				NOVAL} \
 	  {gui_pll_clkin_1_src        			NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "pll_clkin_1_src_core_ref_clk"  		NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clkin_1_src"                                    				NOVAL} \
 	  {gui_pll_auto_clk_sw_en        		NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "false"  								NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_auto_clk_sw_en"                                 				NOVAL} \
 	  {gui_pll_clk_loss_edge        		NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "pll_clk_loss_both_edges"  				NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clk_loss_edge"                                  				NOVAL} \
 	  {gui_pll_clk_loss_sw_en        		NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "false"  								NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clk_loss_sw_en"                                 				NOVAL} \
 	  {gui_pll_clk_sw_dly        			NOVAL	   1				0				 NOVAL                	  													  false   false           INTEGER   0  										NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clk_sw_dly"                                     				NOVAL} \
 	  {gui_pll_manu_clk_sw_en        		NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "false"  								NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_manu_clk_sw_en"                                 				NOVAL} \
 	  {gui_pll_sw_refclk_src        		NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "pll_sw_refclk_src_clk_0"  				NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_sw_refclk_src"                                  				NOVAL} \
 	  {gui_refclk_select0        			NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "lvpecl"  								NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"refclk_select0"                                     				NOVAL} \
 	  {gui_refclk_select1        			NOVAL	   1				0				 NOVAL                	  													  false   false           STRING    "coreclk"  								NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"refclk_select1"                                     				NOVAL} \
      \                                                                                                                  																																																																
 	  {pll_clkin_0_src        				NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_clkin_0_src                	  true    false           STRING    "pll_clkin_0_src_lvpecl"  				NOVAL     													  			  						true        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clkin_0_src"                                    				NOVAL} \
      {pll_clkin_1_src        				NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_clkin_1_src               	  true    false           STRING    "pll_clkin_1_src_core_ref_clk"  		NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clkin_1_src"                                  	 				NOVAL} \
      {pll_auto_clk_sw_en        			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_auto_clk_sw_en            	  true    false           STRING    "false"  								NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_auto_clk_sw_en"                               	 				NOVAL} \
      {pll_clk_loss_edge        			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_clk_loss_edge              	  true    false           STRING    "pll_clk_loss_both_edges"  				NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clk_loss_edge"                                	 				NOVAL} \
      {pll_clk_loss_sw_en        			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_clk_loss_sw_en             	  true    false           STRING    "false"  								NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clk_loss_sw_en"                               	 				NOVAL} \
      {pll_clk_sw_dly        				NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_clk_sw_dly             	 	  true    false           INTEGER   0  										NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_clk_sw_dly"                                   	 				NOVAL} \
      {pll_manu_clk_sw_en        			NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_manu_clk_sw_en            	  true    false           STRING    "false"  								NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_manu_clk_sw_en"                               	 				NOVAL} \
      {pll_sw_refclk_src       				NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_sw_refclk_src             	  true    false           STRING    "pll_sw_refclk_src_clk_0"  				NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"pll_sw_refclk_src"                                	 				NOVAL} \
      {refclk_select0        				NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_refclk_select0                	  true    false           STRING    "lvpecl"  								NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"refclk_select0"                                   	 				NOVAL} \
      {refclk_select1        				NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_refclk_select1                	  true    false           STRING    "coreclk"  								NOVAL     													  			  						false        				 																																																			false   															NOVAL         NOVAL         	"General"  						"refclk_select1"                                   	 				NOVAL} \
      \    																																																				
      {gui_pll_c_counter_0_in_src        	NOVAL	   1				0			 	 NOVAL        	  															  false   false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_in_src"                       	     				NOVAL} \
      {gui_pll_c_counter_0_ph_mux_prst      NOVAL	   1				0			 	 NOVAL   	  																  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_ph_mux_prst"                  	     				NOVAL} \
      {gui_pll_c_counter_0_prst        		NOVAL	   1				0			 	 NOVAL          															  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_prst"                         	     				NOVAL} \
      {gui_pll_c_counter_0_coarse_dly       NOVAL	   1				0			 	 NOVAL    	  																  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_coarse_dly"                   	     				NOVAL} \
      {gui_pll_c_counter_0_fine_dly        	NOVAL	   1				0			 	 NOVAL      	  															  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_fine_dly"                     	     				NOVAL} \
      {gui_pll_c_counter_1_in_src        	NOVAL	   1				0			 	 NOVAL        	 															  false   false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_in_src"                       	     				NOVAL} \
      {gui_pll_c_counter_1_ph_mux_prst      NOVAL	   1				0			 	 NOVAL   	  																  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_ph_mux_prst"                  	     				NOVAL} \
      {gui_pll_c_counter_1_prst        		NOVAL	   1				0			 	 NOVAL          															  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_prst"                         	     				NOVAL} \
      {gui_pll_c_counter_1_coarse_dly       NOVAL	   1				0			 	 NOVAL    	  																  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_coarse_dly"                   	     				NOVAL} \
      {gui_pll_c_counter_1_fine_dly        	NOVAL	   1				0			 	 NOVAL     	  																  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_fine_dly"                     	     				NOVAL} \
      {gui_pll_c_counter_2_in_src        	NOVAL	   1				0			 	 NOVAL        	  															  false   false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_in_src"                       	     				NOVAL} \
      {gui_pll_c_counter_2_ph_mux_prst      NOVAL	   1				0			 	 NOVAL   	  																  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_ph_mux_prst"                  	     				NOVAL} \
      {gui_pll_c_counter_2_prst        		NOVAL	   1				0			 	 NOVAL          															  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_prst"                         	     				NOVAL} \
      {gui_pll_c_counter_2_coarse_dly       NOVAL	   1				0			 	 NOVAL    	  																  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_coarse_dly"                   	     				NOVAL} \
      {gui_pll_c_counter_2_fine_dly        	NOVAL	   1				0			 	 NOVAL      	  															  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_fine_dly"                     	     				NOVAL} \
      {gui_pll_c_counter_3_in_src        	NOVAL	   1				0			 	 NOVAL        	  															  false   false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_in_src"                       	     				NOVAL} \
      {gui_pll_c_counter_3_ph_mux_prst      NOVAL	   1				0			 	 NOVAL   	  																  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_ph_mux_prst"                  	     				NOVAL} \
      {gui_pll_c_counter_3_prst        		NOVAL	   1				0			 	 NOVAL         	  															  false   false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_prst"                         	     				NOVAL} \
      {gui_pll_c_counter_3_coarse_dly       NOVAL	   1				0			 	 NOVAL    	  																  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_coarse_dly"                   	     				NOVAL} \
      {gui_pll_c_counter_3_fine_dly        	NOVAL	   1				0			 	 NOVAL       	  															  false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_fine_dly"                     	     				NOVAL} \
      \    																																																				
      {pll_c_counter_0        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0               	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0"                              	     				NOVAL} \
      {pll_c_counter_0_in_src        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_in_src        	  true    false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_in_src"                       	     				NOVAL} \
      {pll_c_counter_0_ph_mux_prst      	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_ph_mux_prst   	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_ph_mux_prst"                  	     				NOVAL} \
      {pll_c_counter_0_prst        			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_prst          	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_prst"                         	     				NOVAL} \
      {pll_c_counter_0_coarse_dly       	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_coarse_dly    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_coarse_dly"                   	     				NOVAL} \
      {pll_c_counter_0_fine_dly        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_fine_dly      	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_0_fine_dly"                     	     				NOVAL} \
      {pll_c_counter_1        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1               	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1"                              	     				NOVAL} \
      {pll_c_counter_1_in_src        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_in_src        	  true    false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_in_src"                       	     				NOVAL} \
      {pll_c_counter_1_ph_mux_prst      	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_ph_mux_prst   	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_ph_mux_prst"                  	     				NOVAL} \
      {pll_c_counter_1_prst        			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_prst          	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_prst"                         	     				NOVAL} \
      {pll_c_counter_1_coarse_dly       	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_coarse_dly    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_coarse_dly"                   	     				NOVAL} \
      {pll_c_counter_1_fine_dly        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_fine_dly      	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_1_fine_dly"                     	     				NOVAL} \
      {pll_c_counter_2        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2               	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2"                              	     				NOVAL} \
      {pll_c_counter_2_in_src        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_in_src        	  true    false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_in_src"                       	     				NOVAL} \
      {pll_c_counter_2_ph_mux_prst      	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_ph_mux_prst   	  true    false           INTEGER   1 										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_ph_mux_prst"                  	     				NOVAL} \
      {pll_c_counter_2_prst        			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_prst          	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_prst"                         	     				NOVAL} \
      {pll_c_counter_2_coarse_dly       	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_coarse_dly    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_coarse_dly"                   	     				NOVAL} \
      {pll_c_counter_2_fine_dly        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_fine_dly      	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_2_fine_dly"                     	     				NOVAL} \
      {pll_c_counter_3        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3               	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3"                              	     				NOVAL} \
      {pll_c_counter_3_in_src        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_in_src        	  true    false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_in_src"                       	     				NOVAL} \
      {pll_c_counter_3_ph_mux_prst      	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_ph_mux_prst   	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_ph_mux_prst"                  	     				NOVAL} \
      {pll_c_counter_3_prst        			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_prst          	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_prst"                         	     				NOVAL} \
      {pll_c_counter_3_coarse_dly       	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_coarse_dly    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_coarse_dly"                   	     				NOVAL} \
      {pll_c_counter_3_fine_dly        		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_fine_dly      	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_c_counter_3_fine_dly"                     	     				NOVAL} \
	  \																																														
	  {gui_pll_fbclk_mux_1        			NOVAL	   1				0			 	 NOVAL        			  													  false   false           STRING    "pll_fbclk_mux_1_glb"   				NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_fbclk_mux_1"                          			 				NOVAL} \
      {gui_pll_fbclk_mux_2        			NOVAL	   1				0			 	 NOVAL        			  													  false   false           STRING    "pll_fbclk_mux_2_m_cnt"   				NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_fbclk_mux_2"                          			 				NOVAL} \
      {gui_pll_iqclk_mux_sel        		NOVAL	   1				0			 	 NOVAL        			  													  false   false           STRING    "power_down"   							NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_iqclk_mux_sel"                          			 			NOVAL} \
	  \																																														
	  {pll_fbclk_mux_1        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_fbclk_mux_1        			  true    false           STRING    "pll_fbclk_mux_1_glb"   				NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_fbclk_mux_1"                          			 				NOVAL} \
      {pll_fbclk_mux_2        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_fbclk_mux_2        			  true    false           STRING    "pll_fbclk_mux_2_m_cnt"   				NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_fbclk_mux_2"                          			 				NOVAL} \
      {pll_iqclk_mux_sel        			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_iqclk_mux_sel        		  true    false           STRING    "power_down"   							NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_iqclk_mux_sel"                          			 			NOVAL} \
	  \                                                                                                                                                                                       																																														
      {gui_pll_l_counter_bypass       		NOVAL	   1				0			 	 NOVAL				  														  false   false           STRING    "false"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_l_counter_bypass"                    			 				NOVAL} \
      {gui_pll_l_counter_enable       		NOVAL	   1				0			 	 NOVAL				  														  false   false           STRING    "true"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_l_counter_enable"                    			 				NOVAL} \
	  \                                                                                                                                                                                       																																														
      {pll_l_counter_bypass       			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_l_counter_bypass				  true    false           STRING    "false"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_l_counter_bypass"                    			 				NOVAL} \
      {pll_l_counter        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_l_counter                 	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_l_counter"                                      				NOVAL} \
      {pll_l_counter_enable       			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_l_counter_enable				  true    false           STRING    "true"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_l_counter_enable"                    			 				NOVAL} \
	  \                                                                                                                                                                                       																																														
      {gui_pll_m_counter_in_src       		NOVAL	   1				0			 	 NOVAL				  													      false   false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_in_src"                    			 				NOVAL} \
      {gui_pll_m_counter_ph_mux_prst       	NOVAL	   1				0			 	 NOVAL    	  															      false   false           INTEGER   1  									    NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_ph_mux_prst"                          				NOVAL} \
      {gui_pll_m_counter_prst        		NOVAL	   1				0			 	 NOVAL      															      false   false           INTEGER   1  									    NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_prst"                         		 				NOVAL} \
      {gui_pll_m_counter_coarse_dly       	NOVAL	   1				0			 	 NOVAL    	  															      false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_coarse_dly"                    		 				NOVAL} \
      {gui_pll_m_counter_fine_dly       	NOVAL	   1				0			 	 NOVAL	    	  														      false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_fine_dly"                    		 				NOVAL} \
      {gui_pll_n_counter_coarse_dly       	NOVAL	   1				0			 	 NOVAL	    	  														      false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_n_counter_coarse_dly"                    		 				NOVAL} \
      {gui_pll_n_counter_fine_dly       	NOVAL	   1				0			 	 NOVAL	    	  														      false   false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_n_counter_fine_dly"                    		 				NOVAL} \
	  \                                                                                                                                                                                       																																														
      {pll_dsm_fractional_division      	NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_dsm_fractional_division        true    false           LONG  	 0             							{0:2147483647} 															  						false	   																																																								false																NOVAL 		  NOVAL  			"General"  						"pll_dsm_fractional_division"                     	 				NOVAL} \
      {pll_dsm_mode       					NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_dsm_mode					      true    false           STRING    "dsm_mode_integer"   					NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_dsm_mode"                    			 						NOVAL} \
      {pll_dsm_out_sel       				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_dsm_out_sel					  true    false           STRING    "pll_dsm_disable"   					NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_dsm_out_sel"                    			 					NOVAL} \
      {pll_m_counter                    	NOVAL	   0				0				 ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter                      true    false           INTEGER   1             							{1:256} 																  						false	   																																																								false 																NOVAL 		  NOVAL  			"General"  						"pll_m_counter"                        				 				NOVAL} \
      {pll_m_counter_in_src       			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_in_src				  true    false           STRING    "m_cnt_in_src_ph_mux_clk"   			NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_in_src"                    			 				NOVAL} \
      {pll_m_counter_ph_mux_prst        	NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_ph_mux_prst     	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_ph_mux_prst"                          				NOVAL} \
      {pll_m_counter_prst        			NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_prst      			  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_prst"                         		 				NOVAL} \
      {pll_m_counter_coarse_dly       		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_coarse_dly	    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_coarse_dly"                    		 				NOVAL} \
      {pll_m_counter_fine_dly       		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_fine_dly	    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_m_counter_fine_dly"                    		 				NOVAL} \
      {pll_n_counter        				NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_n_counter                 	  true    false           INTEGER   1  										NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_n_counter"                                      				NOVAL} \
      {pll_n_counter_coarse_dly       		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_n_counter_coarse_dly	    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_n_counter_coarse_dly"                    		 				NOVAL} \
      {pll_n_counter_fine_dly       		NOVAL	   0				0			 	 ::altera_xcvr_fpll_vi::parameters::update_pll_n_counter_fine_dly	    	  true    false           STRING    "0 ps"   								NOVAL     													  			  						false        				   																																																			false   															NOVAL         NOVAL         	"General"  						"pll_n_counter_fine_dly"                    		 				NOVAL} \
	}
	
	set parameters_allowed_range {\
      {NAME           ALLOWED_RANGES } \
      {prot_mode  	  { "unused" "basic_tx" "basic_kr_tx" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "cei_tx" "qpi_tx" "cpri_tx" "fc_tx" "srio_tx" "gpon_tx" "sdi_tx" "sata_tx" "xaui_tx" "obsai_tx" "gige_tx" "higig_tx" "sonet_tx" "sfp_tx" "xfp_tx" "sfi_tx" } } \
      {gui_bw_sel     { "auto" "low" "medium" "high" } } \
   }
   
   set atom_parameters {\
      { NAME                                          M_RCFG_REPORT   TYPE       DERIVED   M_MAPS_FROM                     		HDL_PARAMETER   ENABLED     VISIBLE    M_MAP_VALUES }\
      {bw_sel                                		  1               STRING     true      gui_bw_sel                           true            false       false      NOVAL }\
      {cmu_fpll_pll_silicon_rev                		  1	  			  STRING     true      gui_silicon_rev            			true     		false       false 	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_clkin_0_src         0				  STRING	 true 	   pll_clkin_0_src			   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_clkin_1_src         0				  STRING	 true 	   pll_clkin_1_src			   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_auto_clk_sw_en      1				  STRING	 true 	   pll_auto_clk_sw_en		   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_clk_loss_edge       1				  STRING	 true 	   pll_clk_loss_edge		   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_clk_loss_sw_en      1				  STRING	 true 	   pll_clk_loss_sw_en		   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_clk_sw_dly          1				  INTEGER	 true 	   pll_clk_sw_dly			   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_manu_clk_sw_en      1				  STRING	 true 	   pll_manu_clk_sw_en		   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_pll_sw_refclk_src       1				  STRING	 true 	   pll_sw_refclk_src		   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_refclk_select_refclk_select0          1               STRING     true      gui_refclk_index                    	true            false       false     {"0:lvpecl" "1:coreclk" "2:ref_iqclk0" "3:ref_iqclk1" "4:ref_iqclk2"} } \
	  {cmu_fpll_refclk_select_refclk_select1          1				  STRING	 true 	   refclk_select1			   			true 		   	false	 	false	   NOVAL } \
	  \				
      {cmu_fpll_pll_fbclk_mux_1        				  1 			  STRING     true	   pll_fbclk_mux_1	           			true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_fbclk_mux_2        				  1 			  STRING     true	   pll_fbclk_mux_2 	           			true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_iqclk_mux_sel        			  0 			  STRING     true	   pll_iqclk_mux_sel 	           		true 		   	false	 	false	   NOVAL } \
      \				
	  {cmu_fpll_pll_c_counter_0_ph_mux_prst        	  1				  INTEGER    true  	   pll_c_counter_0_ph_mux_prst 			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_0_prst        		  1				  INTEGER    true  	   pll_c_counter_0_prst 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_0_in_src        		  1				  STRING     true  	   pll_c_counter_0_in_src 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_0_coarse_dly        	  1				  STRING     true  	   pll_c_counter_0_coarse_dly  			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_0_fine_dly        	  1				  STRING     true  	   pll_c_counter_0_fine_dly    			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_1_ph_mux_prst        	  1				  INTEGER    true  	   pll_c_counter_1_ph_mux_prst 			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_1_prst        		  1				  INTEGER    true  	   pll_c_counter_1_prst 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_1_in_src        		  1				  STRING     true  	   pll_c_counter_1_in_src 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_1_coarse_dly        	  1				  STRING     true  	   pll_c_counter_1_coarse_dly  			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_1_fine_dly        	  1				  STRING     true  	   pll_c_counter_1_fine_dly    			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_2_ph_mux_prst        	  1				  INTEGER    true  	   pll_c_counter_2_ph_mux_prst 			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_2_prst        		  1				  INTEGER    true  	   pll_c_counter_2_prst 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_2_in_src        		  1				  STRING     true  	   pll_c_counter_2_in_src 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_2_coarse_dly        	  1				  STRING     true  	   pll_c_counter_2_coarse_dly  			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_2_fine_dly        	  1				  STRING     true  	   pll_c_counter_2_fine_dly    			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_3_ph_mux_prst        	  1				  INTEGER    true  	   pll_c_counter_3_ph_mux_prst 			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_3_prst        		  1				  INTEGER    true  	   pll_c_counter_3_prst 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_3_in_src        		  1				  STRING     true  	   pll_c_counter_3_in_src 	   			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_3_coarse_dly        	  1				  STRING     true  	   pll_c_counter_3_coarse_dly  			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_3_fine_dly        	  1				  STRING     true  	   pll_c_counter_3_fine_dly    			true 		   	false	 	false	   NOVAL } \
	  \                                                
	  {cmu_fpll_pll_l_counter_bypass       			  1				  STRING     true  	   pll_l_counter_bypass    				true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_l_counter_enable       		      1				  STRING     true  	   pll_l_counter_enable    				true 		   	false	 	false	   NOVAL } \
	  \	                                               
      {cmu_fpll_pll_m_counter_ph_mux_prst       	  1				  INTEGER    true  	   pll_m_counter_ph_mux_prst    		true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_m_counter_prst        			  1				  INTEGER    true  	   pll_m_counter_prst    				true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_m_counter_in_src       			  1 			  STRING     true  	   pll_m_counter_in_src    				true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_m_counter_coarse_dly       		  1				  STRING     true  	   pll_m_counter_coarse_dly    			true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_m_counter_fine_dly       		  1				  STRING     true  	   pll_m_counter_fine_dly    			true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_n_counter_coarse_dly       		  1				  STRING     true  	   pll_n_counter_coarse_dly    			true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_n_counter_fine_dly       		  1				  STRING     true  	   pll_n_counter_fine_dly    			true 		   	false	 	false	   NOVAL } \
	  \	                                               
	  {cmu_fpll_pll_m_counter        			      1				  INTEGER    true      pll_m_counter    					true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_0        				  1				  INTEGER    true      pll_c_counter_0 	           			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_1        				  1				  INTEGER    true  	   pll_c_counter_1 	           			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_2        				  1				  INTEGER    true  	   pll_c_counter_2 	           			true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_c_counter_3        				  1				  INTEGER    true  	   pll_c_counter_3 	           			true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_l_counter        				  1				  INTEGER    true  	   pll_l_counter    					true 		   	false	 	false	   NOVAL } \
	  {cmu_fpll_pll_dsm_fractional_division        	  1				  LONG    	 true  	   pll_dsm_fractional_division    		true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_dsm_mode       		  			  1				  STRING     true  	   pll_dsm_mode    						true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_dsm_out_sel       		  		  1				  STRING     true  	   pll_dsm_out_sel    					true 		   	false	 	false	   NOVAL } \
      {cmu_fpll_pll_n_counter        				  1				  INTEGER    true  	   pll_n_counter    					true 		   	false	 	false	   NOVAL } \
	}

	set parameters_to_be_removed {\
      { NAME                                          						M_RCFG_REPORT   TYPE       DERIVED   HDL_PARAMETER   ENABLED   VISIBLE   DEFAULT_VALUE } \
      { cmu_fpll_pll_a_csr_bufin_posedge              						0               STRING     true      true            false     false     "zero" } \
      { cmu_fpll_pll_atb                              						0               STRING     true      true            false     false     "atb_selectdisable" } \
      { cmu_fpll_pll_bw_mode                          						0               STRING     true      true            false     false     "low_bw" } \
      { cmu_fpll_pll_c_counter_0_min_tco_enable       						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_c_counter_1_min_tco_enable       						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_c_counter_2_min_tco_enable       						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_c_counter_3_min_tco_enable       						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_cal_status                       						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_calibration                      						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_cmp_buf_dly                      						0               STRING     true      true            false     false     "0 ps" } \
      { cmu_fpll_pll_cp_compensation                  						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_cp_current_setting               						0               STRING     true      true            false     false     "cp_current_setting0" } \
      { cmu_fpll_pll_cp_lf_3rd_pole_freq              						0               STRING     true      true            false     false     "lf_3rd_pole_setting0" } \
      { cmu_fpll_pll_cp_lf_4th_pole_freq              						0               STRING     true      true            false     false     "lf_4th_pole_setting0" } \
      { cmu_fpll_pll_cp_lf_order                      						0               STRING     true      true            false     false     "lf_2nd_order" } \
      { cmu_fpll_pll_cp_testmode                      						0               STRING     true      true            false     false     "cp_normal" } \
      { cmu_fpll_pll_ctrl_override_setting            						0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_ctrl_plniotri_override           						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_device_variant                	  						0               STRING     true      true            false     false     "device1" } \
      { cmu_fpll_pll_dprio_base_addr                  						0               INTEGER    true      true            false     false     256 } \
      { cmu_fpll_pll_dprio_broadcast_en               						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_dprio_clk_vreg_boost             						0               STRING     true      true            false     false     "clk_fpll_vreg_no_voltage_boost" } \
      { cmu_fpll_pll_dprio_cvp_inter_sel              						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_dprio_force_inter_sel            						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_dprio_fpll_vreg_boost            						0               STRING     true      true            false     false     "fpll_vreg_no_voltage_boost" } \
      { cmu_fpll_pll_dprio_fpll_vreg1_boost           						0               STRING     true      true            false     false     "fpll_vreg1_no_voltage_boost" } \
      { cmu_fpll_pll_dprio_power_iso_en               						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_dprio_status_select              						0               STRING     true      true            false     false     "dprio_normal_status" } \
      { cmu_fpll_pll_dsm_ecn_bypass                   						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_dsm_ecn_test_en                  						0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_dsm_fractional_value_ready       						0               STRING     true      true            false     false     "pll_k_ready" } \
      { cmu_fpll_pll_enable                			  		  				0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_extra_csr                	  		  	  				0               INTEGER    true      true            false     false     0 } \
      { cmu_fpll_pll_lf_resistance                        	  				0               STRING     true      true            false     false     "lf_res_setting0" } \
      { cmu_fpll_pll_lf_ripplecap                        	  				0               STRING     true      true            false     false     "lf_ripple_enabled" } \
      { cmu_fpll_pll_lock_fltr_cfg                			  				0               INTEGER    true      true            false     false     25 } \
      { cmu_fpll_pll_lock_fltr_test                			  				0               STRING     true      true            false     false     "pll_lock_fltr_nrm" } \
      { cmu_fpll_pll_lpf_rstn_value                             			0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_m_counter_min_tco_enable                   			0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_nreset_invert                			    			0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_op_mode                			  					0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_optimal                  				    			0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_overrange_underrange_voltage_coarse_sel    			0               STRING     true      true            false     false     "vreg_setting_coarse1" } \
      { cmu_fpll_pll_overrange_voltage   					    			0               STRING     true      true            false     false     "over_setting3" } \
      { cmu_fpll_pll_power_mode   					  		    			0               STRING     true      true            false     false     "low_power" } \
      { cmu_fpll_pll_powerdown_mode   					  	    			0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_ppm_clk0_src   					  	  				0               STRING     true      true            false     false     "ppm_clk0_vss" } \
      { cmu_fpll_pll_ppm_clk1_src   					  	    			0               STRING     true      true            false     false     "ppm_clk1_vss" } \
      { cmu_fpll_pll_ref_buf_dly                			  				0               STRING     true      true            false     false     "0 ps" } \
      { cmu_fpll_pll_rstn_override                              			0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_self_reset                			  	    			0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_speed_grade                			  				0               STRING     true      true            false     false     "dash2" } \
      { cmu_fpll_pll_sup_mode                			  	    			0               STRING     true      true            false     false     "user_mode" } \
      { cmu_fpll_pll_tclk_mux_en                			  				0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_tclk_sel                			  	    			0               STRING     true      true            false     false     "pll_tclk_m_src" } \
      { cmu_fpll_pll_test_enable                			  				0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_underrange_voltage                		    			0               STRING     true      true            false     false     "under_setting3" } \
      { cmu_fpll_pll_unlock_fltr_cfg                		    			0               INTEGER    true      true            false     false     2 } \
      { cmu_fpll_pll_vccr_pd_en                			  	  				0               STRING     true      true            false     false     "false" } \
      { cmu_fpll_pll_vco_freq_band                			  				0               STRING     true      true            false     false     "pll_freq_band0" } \
      { cmu_fpll_pll_vco_ph0_en                			  	  				0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_vco_ph0_value                			  				0               STRING     true      true            false     false     "pll_vco_ph0_vss" } \
      { cmu_fpll_pll_vco_ph1_en                			  	  				0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_vco_ph1_value                			  				0               STRING     true      true            false     false     "pll_vco_ph1_vss" } \
      { cmu_fpll_pll_vco_ph2_en                			  	  				0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_vco_ph2_value                			  				0               STRING     true      true            false     false     "pll_vco_ph2_vss" } \
      { cmu_fpll_pll_vco_ph3_en                			  	  				0               STRING     true      true            false     false     "true" } \
      { cmu_fpll_pll_vco_ph3_value                			  				0               STRING     true      true            false     false     "pll_vco_ph3_vss" } \
      { cmu_fpll_pll_vreg0_output                			  				0               STRING     true      true            false     false     "vccdreg_nominal" } \
      { cmu_fpll_pll_vreg1_output                			  				0               STRING     true      true            false     false     "vccdreg_nominal" } \
      { mux0_inclk0_logical_to_physical_mapping        						0               STRING     true      true            false     false     "lvpecl" }\
      { mux0_inclk1_logical_to_physical_mapping        						0               STRING     true      true            false     false     "coreclk" }\
      { mux0_inclk2_logical_to_physical_mapping        						0               STRING     true      true            false     false     "ref_iqclk0" }\
      { mux0_inclk3_logical_to_physical_mapping        						0               STRING     true      true            false     false     "ref_iqclk1" }\
      { mux0_inclk4_logical_to_physical_mapping        						0               STRING     true      true            false     false     "ref_iqclk2" }\
      { mux1_inclk0_logical_to_physical_mapping        						0               STRING     true      true            false     false     "lvpecl" }\
      { mux1_inclk1_logical_to_physical_mapping        						0               STRING     true      true            false     false     "coreclk" }\
      { mux1_inclk2_logical_to_physical_mapping        						0               STRING     true      true            false     false     "ref_iqclk0" }\
      { mux1_inclk3_logical_to_physical_mapping        						0               STRING     true      true            false     false     "ref_iqclk1" }\
      { mux1_inclk4_logical_to_physical_mapping        						0               STRING     true      true            false     false     "ref_iqclk2" }\
	}

   set logical_parameters {\
      { NAME                    M_RCFG_REPORT   TYPE       DERIVED   M_MAPS_FROM                     HDL_PARAMETER   ENABLED   VISIBLE   M_MAP_VALUES }\
      { fpll_refclk_select        1               INTEGER    true      gui_refclk_index                false           false     false     NOVAL }\
   }

}

# +-----------------------------------
# | 
# |
proc ::altera_xcvr_fpll_vi::parameters::declare_parameters { {device_family "Arria VI"} } {
   variable display_items_pll
   variable generation_display_items
   variable refclk_switchover_display_items
   variable parameters
   variable parameters_allowed_range
   variable atom_parameters
   variable logical_parameters
   variable parameters_to_be_removed

   # Determine which parameters are needed to include in reconfig reports is parameter dependent
   ip_add_user_property_type M_RCFG_REPORT integer

   # Initialize Reconfiguration parameters
   ::alt_xcvr::utils::reconfiguration_arria10::declare_parameters
   ip_set "parameter.rcfg_file_prefix.DEFAULT_VALUE" "altera_xcvr_fpll_a10"
   
   # Initialize General parameters
   ip_declare_parameters $parameters
   ip_declare_parameters $parameters_allowed_range
   ip_declare_parameters $atom_parameters
   ip_declare_parameters $logical_parameters
   ip_declare_parameters $parameters_to_be_removed
   
   
   # Initialize Central Clock Divider parameters
   ::mcgb_package_vi::mcgb::set_hip_cal_done_enable_maps_from gui_enable_hip_cal_done_port
   ::mcgb_package_vi::mcgb::set_output_clock_frequency_maps_from hssi_output_clock_frequency
   ::mcgb_package_vi::mcgb::set_protocol_mode_maps_from prot_mode
   ::mcgb_package_vi::mcgb::set_silicon_rev_maps_from gui_silicon_rev
   ::mcgb_package_vi::mcgb::declare_mcgb_parameters

   # Declare General tab
   ip_declare_display_items $display_items_pll

   # Declare Central Clock Divider tab
   ::mcgb_package_vi::mcgb::set_mcgb_display_item_properties "" tab
   ::mcgb_package_vi::mcgb::declare_mcgb_display_items
   
   # Declare Reconfiguration tab
   ::alt_xcvr::utils::reconfiguration_arria10::declare_display_items "" tab
   
   # Declare Refclk switchover tab
   ip_declare_display_items $refclk_switchover_display_items

   # Declare Generation option tab
   ip_declare_display_items $generation_display_items
	   
   # Initialize device information (to allow sharing of this function across device families)
   ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
   ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
   ip_set "parameter.gui_device_speed_grade.allowed_ranges" [::alt_xcvr::utils::device::get_device_speedgrades $device_family]
   
   # Grab Quartus INI's
   ip_set "parameter.enable_advanced_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_fpll_10_advanced ENABLED]
   ip_set "parameter.enable_hip_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_fpll_atx_pll_10_hip_options ENABLED]
}

# +-----------------------------------
# | 
# |
proc ::altera_xcvr_fpll_vi::parameters::validate {} {      
   ip_validate_parameters
   ip_validate_display_items
}

# +-----------------------------------
# | This function returns a generic device part name for NightFury
# | This is needed for getting the right spec limit for the given part
# |
proc ::altera_xcvr_fpll_vi::parameters::get_device_part_name { } {
	set device_part "nightfury5_f1932bc2"
	return $device_part
}

# +-----------------------------------
# | This function sets the new allowed ranges based on given refclk_cnt
# |
proc ::altera_xcvr_fpll_vi::parameters::update_refclk_index { gui_refclk_cnt } { 
   # update refclk_index allowed range from 0 to gui_refclk_cnt-1
   set new_range 0
   for {set index 1} {$index < $gui_refclk_cnt} {incr index} {
      lappend new_range $index
   }
   ip_set "parameter.gui_refclk_index.ALLOWED_RANGES" $new_range
}

# +-----------------------------------
# | This function retreives the VCO from the given refclk, HSSI and output clock frequency
# | The returned VCO value will need to satisfy all of the necessary requirements/specs
# |
proc ::altera_xcvr_fpll_vi::parameters::get_vco_frequency_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift return_all_legal_value} {
	variable debug_message
	
	set device_part [::altera_xcvr_fpll_vi::parameters::get_device_part_name]
	set reference_clock_frequency "$gui_reference_clock_frequency MHz"
	set hssi_output_clock_frequency "$gui_hssi_output_clock_frequency MHz"
	set pll_dsm_mode ""
	set output_clks [list "$gui_desired_outclk0_frequency MHz" "$gui_desired_outclk1_frequency MHz" "$gui_desired_outclk2_frequency MHz" "$gui_desired_outclk3_frequency MHz"]
	set output_clk_phase_shifts [list "$gui_outclk0_desired_phase_shift ps" "$gui_outclk1_desired_phase_shift ps" "$gui_outclk2_desired_phase_shift ps" "$gui_outclk3_desired_phase_shift ps"]
	set output_clk_duty_cycle [list "50" "50" "50" "50"]
	
	# build list to pass to advanced_pll_legality tcl package to retreive the VCO information.
	set reference_list [list]
	
	# fractional pll usage
	if { $gui_enable_fractional } {
		set pll_dsm_mode "dsm_mode_phase";
	} else {
		set pll_dsm_mode "dsm_mode_integer";
	}

	#general PLL information
	lappend reference_list $device_part
	lappend reference_list $reference_clock_frequency
	lappend reference_list $hssi_output_clock_frequency
	lappend reference_list $pll_dsm_mode

	# setup output clock frequencies, phase shifts and duty cycles
	for {set outclk_index 0} {$outclk_index < $gui_number_of_output_clocks} {incr outclk_index} {
		set outclk_freq [lindex $output_clks $outclk_index]
		set outclk_phase_shift [lindex $output_clk_phase_shifts $outclk_index]
		set outclk_duty_cycle [lindex $output_clk_duty_cycle $outclk_index]
		lappend reference_list $outclk_freq
		lappend reference_list $outclk_phase_shift
		lappend reference_list $outclk_duty_cycle
	}
	
	# set the unused output clocks as 0 MHz
	for {set outclk_index $gui_number_of_output_clocks} {$outclk_index < [llength $output_clks]} {incr outclk_index} {
		lappend reference_list "0 MHz"
		lappend reference_list "0 ps"
		lappend reference_list "50"
	}
	
	# call TCL package to retreive VCO information
	set result [get_pll_legal_values "NIGHTFURY_PLL_CONFIG" "CMU_FPLL_VCO_FREQUENCY" $reference_list]
		
	#strip off {{ and }} from RBC
	regsub {([\{]+)} $result {} result
	regsub {([\}]+)} $result {} result
	
	# TODO -- check VCO limit
	# print out error message if we cannot be an legal VCO
	#if {[string match -nocase "" $result]} {
		# Output an error message if we cannot find the matching output clock frequency
	#	send_message error "The specified configuration causes Voltage-Controlled Oscillator (VCO) to go beyond the limit."
    #} 

	#split each refclk freq returned
	set return_array [split $result |]

	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_vco_frequency_values reference_list: $reference_list"
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_vco_frequency_values return_array: $return_array"
	}
	
	# return the first legal VCO (smallest)
	if { $return_all_legal_value == "true"} {
		return $return_array
	} else {
		return [lindex $return_array 0]
	}
}

# +-----------------------------------
# | This function returns a list of valid output clock frequency for OUTCLK0
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_outclk0_frequency_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_pll_c_counter_0 } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		if { $gui_enable_manual_config } {
			# get the possible output frequency based on the given physical parameters
			set result [get_valid_desired_output_clock_frequency $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional $gui_pll_c_counter_0 1]
			::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk0_frequency $result
		} else {	
			set result [get_actual_outclk_frequency_values "CMU_FPLL_OUTPUT_CLOCK_FREQUENCY_0" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]
			
			if {[string match -nocase "" $result]} {
				# Output an error message if we cannot find the matching output clock frequency
				send_message error "Please specify correct outclk0 desired output frequency."
			} else {		
				# Update the allowed range for listing the possible actual output clock frequency
				::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk0_frequency $result
			}
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_outclk0_frequency_values result: $result"
		}
	} else {
		ip_set "parameter.gui_actual_outclk0_frequency.allowed_ranges" { "0.0 MHz" "100.0 MHz" "200.0 MHz"}
	}
}

# +-----------------------------------
# | This function returns a list of valid output clock frequency for OUTCLK1
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_outclk1_frequency_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_pll_c_counter_1 } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		if { $gui_enable_manual_config } {
			# get the possible output frequency based on the given physical parameters
			set result [get_valid_desired_output_clock_frequency $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional $gui_pll_c_counter_1 1]
			::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk1_frequency $result
		} else {	
			set result [get_actual_outclk_frequency_values "CMU_FPLL_OUTPUT_CLOCK_FREQUENCY_1" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk1_phase_shift_unit $gui_outclk0_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]
			
			if {[string match -nocase "" $result]} {
				# Output an error message if we cannot find the matching output clock frequency
				send_message error "Please specify correct outclk1 desired output frequency."
			} else {		
				# Update the allowed range for listing the possible actual output clock frequency
				::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk1_frequency $result
			}
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_outclk1_frequency_values result: $result"
		}
	} else {
		ip_set "parameter.gui_actual_outclk1_frequency.allowed_ranges" { "0.0 MHz" "100.0 MHz" "200.0 MHz"}
	}
}

# +-----------------------------------
# | This function returns a list of valid output clock frequency for OUTCLK2
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_outclk2_frequency_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_pll_c_counter_2 } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		if { $gui_enable_manual_config } {
			# get the possible output frequency based on the given physical parameters
			set result [get_valid_desired_output_clock_frequency $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional $gui_pll_c_counter_2 1]
			::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk2_frequency $result
		} else {	
			set result [get_actual_outclk_frequency_values "CMU_FPLL_OUTPUT_CLOCK_FREQUENCY_2" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk2_phase_shift_unit $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]
		
			if {[string match -nocase "" $result]} {
				# Output an error message if we cannot find the matching output clock frequency
				send_message error "Please specify correct outclk2 desired output frequency."
			} else {		
				# Update the allowed range for listing the possible actual output clock frequency
				::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk2_frequency $result
			}
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_outclk2_frequency_values result: $result"
		}
	} else {
		ip_set "parameter.gui_actual_outclk2_frequency.allowed_ranges" { "0.0 MHz" "100.0 MHz" "200.0 MHz"}
	}
}

# +-----------------------------------
# | This function returns a list of valid output clock frequency for OUTCLK3
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_outclk3_frequency_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_pll_c_counter_3 } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		if { $gui_enable_manual_config } {
			# get the possible output frequency based on the given physical parameters
			set result [get_valid_desired_output_clock_frequency $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional $gui_pll_c_counter_3 1]
			::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk3_frequency $result
		} else {	
			set result [get_actual_outclk_frequency_values "CMU_FPLL_OUTPUT_CLOCK_FREQUENCY_3" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_outclk3_phase_shift_unit $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_enable_manual_config]
		
			if {[string match -nocase "" $result]} {
				# Output an error message if we cannot find the matching output clock frequency
				send_message error "Please specify correct outclk3 desired output frequency."
			} else {		
				# Update the allowed range for listing the possible actual output clock frequency
				::alt_xcvr::utils::common::map_allowed_range gui_actual_outclk3_frequency $result
			}
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_outclk3_frequency_values result: $result"
		}
	} else {
		ip_set "parameter.gui_actual_outclk3_frequency.allowed_ranges" { "0.0 MHz" "100.0 MHz" "200.0 MHz"}
	}
}

# +-----------------------------------
# | This function returns a list of valid output clock frequency or phase shift to be as close as possible (if not exactly the same) to desired frequency
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_fpll_legal_values { rule_name gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency desired_outclk_frequency desired_outclk_phase_shift other_outclk_frequency_1 other_outclk_phase_shift_1 other_outclk_frequency_2 other_outclk_phase_shift_2 other_outclk_frequency_3 other_outclk_phase_shift_3 desired_phase_shift_unit other_outclk1_phase_shift_unit other_outclk2_phase_shift_unit other_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message
		
	# reset the outclks to 0 MHz if the clocks are not used
	set desired_outclk_frequency_0 $desired_outclk_frequency 
	set desired_phase_shift_0 $desired_outclk_phase_shift
	set desired_outclk_frequency_1 $other_outclk_frequency_1
	set desired_phase_shift_1 $other_outclk_phase_shift_1
	set desired_outclk_frequency_2 $other_outclk_frequency_2 
	set desired_phase_shift_2 $other_outclk_phase_shift_2
	set desired_outclk_frequency_3 $other_outclk_frequency_3 
	set desired_phase_shift_3 $other_outclk_phase_shift_3
	if { $gui_number_of_output_clocks < 2 } {
		set desired_outclk_frequency_1 "0"		
		set desired_phase_shift_1 "0"	
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 3 } {
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 4 } {
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	}
	
	# convert back to ps since user specify phase shift in degree
	if { $desired_phase_shift_unit == "degrees"} {
		set desired_phase_shift_0 [degrees_to_ps $desired_phase_shift_0 $desired_outclk_frequency_0]
	}
	if { $other_outclk1_phase_shift_unit == "degrees" } {
		set desired_phase_shift_1 [degrees_to_ps $desired_phase_shift_1 $desired_outclk_frequency_1]
	}
	if { $other_outclk2_phase_shift_unit == "degrees" } {
		set desired_phase_shift_2 [degrees_to_ps $desired_phase_shift_2 $desired_outclk_frequency_2]
	}
	if { $other_outclk3_phase_shift_unit == "degrees" } {
		set desired_phase_shift_3 [degrees_to_ps $desired_phase_shift_3 $desired_outclk_frequency_3]
	}

	# set up inforamtion to use in reference list
	set device_part [::altera_xcvr_fpll_vi::parameters::get_device_part_name]
	set reference_clock_frequency "$gui_reference_clock_frequency MHz"
	set pll_dsm_mode ""
	set output_clks [list "$desired_outclk_frequency_1 MHz" "$desired_outclk_frequency_2 MHz" "$desired_outclk_frequency_3 MHz"]
	set output_clk_phase_shifts [list "$desired_phase_shift_1 ps" "$desired_phase_shift_2 ps" "$desired_phase_shift_3 ps"]
	set output_clk_duty_cycle [list "50" "50" "50"]
	set desired_outclk_frequency_str "$desired_outclk_frequency_0 MHz"
	set desired_outclk_phase_shift_str "$desired_phase_shift_0 ps"

	# get the HSSI output frequency
	if { $gui_enable_transceiver_usage && !$gui_enable_manual_config } {
		set hssi_output_clock_frequency $gui_hssi_output_clock_frequency
	} else {
		set hssi_output_clock_frequency 0
	}
	
	# fractional pll usage
	if { $gui_enable_fractional } {
		set pll_dsm_mode "dsm_mode_phase";
	} else {
		set pll_dsm_mode "dsm_mode_integer";
	}
	
	# get the vco frequency based on the given reference clocks and output clocks
	set vco_frequency [::altera_xcvr_fpll_vi::parameters::get_vco_frequency_values $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $hssi_output_clock_frequency $desired_outclk_frequency_0 $desired_phase_shift_0 $other_outclk_frequency_1 $desired_phase_shift_1 $other_outclk_frequency_2 $desired_phase_shift_2 $other_outclk_frequency_3 $desired_phase_shift_3 "false"]

	# build list to pass to advanced_pll_legality tcl package to retreive the VCO information.
	set reference_list [list]
	
	#general PLL information
	lappend reference_list $device_part
	lappend reference_list $reference_clock_frequency
	lappend reference_list $vco_frequency
	lappend reference_list "$hssi_output_clock_frequency MHz"
	lappend reference_list $desired_outclk_frequency_str
	lappend reference_list $desired_outclk_phase_shift_str
	lappend reference_list "50"
	lappend reference_list $pll_dsm_mode

	# setup output clock frequencies, phase shifts and duty cycles
	for {set outclk_index 0} {$outclk_index < $gui_number_of_output_clocks && $outclk_index < [llength $output_clks]} {incr outclk_index} {
		set outclk_freq [lindex $output_clks $outclk_index]
		set outclk_phase_shift [lindex $output_clk_phase_shifts $outclk_index]
		set outclk_duty_cycle [lindex $output_clk_duty_cycle $outclk_index]
		lappend reference_list $outclk_freq
		lappend reference_list $outclk_phase_shift
		lappend reference_list $outclk_duty_cycle
	}
	
	# set the unused output clocks as 0 MHz
	for {set outclk_index $gui_number_of_output_clocks} {$outclk_index < [llength $output_clks]} {incr outclk_index} {
		lappend reference_list "0 MHz"
		lappend reference_list "0 ps"
		lappend reference_list "50"
	}
	
	# call TCL package to retreive VCO information
	set result [get_pll_legal_values "NIGHTFURY_PLL_CONFIG" $rule_name $reference_list]
	
	#strip off {{ and }} from RBC
	regsub {([\{]+)} $result {} result
	regsub {([\}]+)} $result {} result
	
	#split each refclk freq returned
	set return_array [split $result |]

	return $return_array
}

# +-----------------------------------
# | This function returns a list of valid output clock frequency to be as close as possible (if not exactly the same) to desired frequency
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_outclk_frequency_values { rule_name gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency desired_outclk_frequency desired_outclk_phase_shift other_outclk_frequency_1 other_outclk_phase_shift_1 other_outclk_frequency_2 other_outclk_phase_shift_2 other_outclk_frequency_3 other_outclk_phase_shift_3 desired_phase_shift_unit other_outclk1_phase_shift_unit other_outclk2_phase_shift_unit other_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message
	
	# get legal values
	set return_array [get_actual_fpll_legal_values $rule_name $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $desired_outclk_frequency $desired_outclk_phase_shift $other_outclk_frequency_1 $other_outclk_phase_shift_1 $other_outclk_frequency_2 $other_outclk_phase_shift_2 $other_outclk_frequency_3 $other_outclk_phase_shift_3 $desired_phase_shift_unit $other_outclk1_phase_shift_unit $other_outclk2_phase_shift_unit $other_outclk3_phase_shift_unit $gui_enable_manual_config]

	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_outclk_frequency_values reference_list: $reference_list"
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_outclk_frequency_values return_array: $return_array"
	}
	
	return $return_array
}

# +-----------------------------------
# | This function returns a list of valid values for a given refclk select parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::get_refclk_select_legal_values { rule_name } {
	variable debug_message
	
	set device_part [::altera_xcvr_fpll_vi::parameters::get_device_part_name]

	# build list to pass to advanced_pll_legality tcl package to retreive the refclk select parameter information.
	set reference_list [list]
	
	# general PLL information
	lappend reference_list $device_part

	# call TCL package to retreive refclk select parameter information
	set result [get_pll_legal_values "NIGHTFURY_PLL_CONFIG" $rule_name $reference_list]

	# strip off {{ and }} from RBC
	regsub {([\{]+)} $result {} result
	regsub {([\}]+)} $result {} result
	
	# split each refclk freq returned
	set return_array [split $result |]

	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_refclk_select_legal_values result: $return_array"
	}
	
	return $return_array
}

# +-----------------------------------
# | This function sets an legal value on the given refclk select parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter { rule_name parameter_name } {
	variable debug_message
	
	# get the list of legal values on the given parameter
	set legal_values [::altera_xcvr_fpll_vi::parameters::get_refclk_select_legal_values $rule_name]

	# select the first value
	set legal_value [lindex $legal_values 0]
	set lower_case_legal_value [string tolower $legal_value]
	ip_set "parameter.$parameter_name.value" $lower_case_legal_value
	
	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter: $parameter_name -> $legal_value"
	}
}

# +-----------------------------------
# | This function returns a list of valid values for a given cmu fpll parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::get_fpll_legal_values { rule_name gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency outclk_frequency_0 outclk_phase_shift_0 outclk_frequency_1 outclk_phase_shift_1 outclk_frequency_2 outclk_phase_shift_2 outclk_frequency_3 outclk_phase_shift_3 gui_enable_manual_config} {
	variable debug_message
	
	set device_part [::altera_xcvr_fpll_vi::parameters::get_device_part_name]
	set reference_clock_frequency "$gui_reference_clock_frequency MHz"
	set output_clks [list "$outclk_frequency_0 MHz" "$outclk_frequency_1 MHz" "$outclk_frequency_2 MHz" "$outclk_frequency_3 MHz"]
	set output_clk_phase_shifts [list "$outclk_phase_shift_0 ps" "$outclk_phase_shift_1 ps" "$outclk_phase_shift_2 ps" "$outclk_phase_shift_3 ps"]
	set output_clk_duty_cycle [list "50" "50" "50" "50"]
	set pll_auto_reset "off"
	set pll_bandwidth_preset "auto"
	set pll_compensation_mode [get_compensation_mode $gui_operation_mode]
	set pll_feedback_mode "Global Clock"  
	set pll_dsm_mode ""

	# get the HSSI output frequency
	if { $gui_enable_transceiver_usage && !$gui_enable_manual_config } {
		set hssi_output_clock_frequency $gui_hssi_output_clock_frequency
	} else {
		set hssi_output_clock_frequency 0
	}
	
	# fractional pll usage
	if { $gui_enable_fractional } {
		set pll_dsm_mode "dsm_mode_phase";
	} else {
		set pll_dsm_mode "dsm_mode_integer";
	}
	
	# get the vco frequency based on the given reference clocks and output clocks
	set vco_frequency [::altera_xcvr_fpll_vi::parameters::get_vco_frequency_values $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $hssi_output_clock_frequency $outclk_frequency_0 $outclk_phase_shift_0 $outclk_frequency_1 $outclk_phase_shift_1 $outclk_frequency_2 $outclk_phase_shift_2 $outclk_frequency_3 $outclk_phase_shift_3 "false"]

	# build list to pass to advanced_pll_legality tcl package to retreive the VCO information.
	set reference_list [list]
	
	#general PLL information
	lappend reference_list $device_part
	lappend reference_list $reference_clock_frequency
	lappend reference_list $vco_frequency
	lappend reference_list "$hssi_output_clock_frequency MHz"
	lappend reference_list $pll_dsm_mode

	# setup output clock frequencies, phase shifts and duty cycles
	for {set outclk_index 0} {$outclk_index < $gui_number_of_output_clocks} {incr outclk_index} {
		set outclk_freq [lindex $output_clks $outclk_index]
		set outclk_phase_shift [lindex $output_clk_phase_shifts $outclk_index]
		set outclk_duty_cycle [lindex $output_clk_duty_cycle $outclk_index]
		lappend reference_list $outclk_freq
		lappend reference_list $outclk_phase_shift
		lappend reference_list $outclk_duty_cycle
	}
	
	# set the unused output clocks as 0 MHz
	for {set outclk_index $gui_number_of_output_clocks} {$outclk_index < [llength $output_clks]} {incr outclk_index} {
		lappend reference_list "0 MHz"
		lappend reference_list "0 ps"
		lappend reference_list "50"
	}
	lappend reference_list $pll_compensation_mode
	lappend reference_list $pll_auto_reset
	lappend reference_list $pll_bandwidth_preset
	lappend reference_list $pll_feedback_mode

	# call TCL package to retreive refclk select parameter information
	set result [get_pll_legal_values "NIGHTFURY_PLL_CONFIG" $rule_name $reference_list]
	
	# strip off {{ and }} from RBC
	regsub {([\{]+)} $result {} result
	regsub {([\}]+)} $result {} result

	# print out error message
	#if {[string match -nocase "" $result]} {
		# Output an error message if we cannot find the matching output clock frequency
	#	send_message error "Requested settings cannot be implemented using the given hssi and/or core clock output frequenceis.  Please specify correct frequencies."
    #} 
	
	# split each refclk freq returned
	set return_array [split $result |]

	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_fpll_legal_values reference_list: $reference_list"
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_fpll_legal_values result: $return_array"
	}
	
	return $return_array
}

# +-----------------------------------
# | This function sets an legal value on the given fpll parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter { rule_name parameter_name gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency outclk_frequency_0 outclk_phase_shift_0 outclk_frequency_1 outclk_phase_shift_1 outclk_frequency_2 outclk_phase_shift_2 outclk_frequency_3 outclk_phase_shift_3 desired_phase_shift_unit other_outclk1_phase_shift_unit other_outclk2_phase_shift_unit other_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message

	set desired_outclk_frequency_0 $outclk_frequency_0 
	set desired_phase_shift_0 $outclk_phase_shift_0
	set desired_outclk_frequency_1 $outclk_frequency_1
	set desired_phase_shift_1 $outclk_phase_shift_1
	set desired_outclk_frequency_2 $outclk_frequency_2 
	set desired_phase_shift_2 $outclk_phase_shift_2
	set desired_outclk_frequency_3 $outclk_frequency_3 
	set desired_phase_shift_3 $outclk_phase_shift_3

	# reset the outclks to 0 MHz if the clocks are not used
	if { !$gui_enable_core_usage } {
		set desired_outclk_frequency_0 "0"		
		set desired_phase_shift_0 "0"	
		set desired_outclk_frequency_1 "0"		
		set desired_phase_shift_1 "0"	
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 2 } {
		set desired_outclk_frequency_1 "0"		
		set desired_phase_shift_1 "0"	
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 3 } {
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 4 } {
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	}
	
	# convert back to ps since user specify phase shift in degree
	if { $desired_phase_shift_unit == "degrees" } {
		set desired_phase_shift_0 [degrees_to_ps $desired_phase_shift_0 $desired_outclk_frequency_0]
	}
	if { $other_outclk1_phase_shift_unit == "degrees" } {
		set desired_phase_shift_1 [degrees_to_ps $desired_phase_shift_1 $desired_outclk_frequency_1]
	}
	if { $other_outclk2_phase_shift_unit == "degrees" } {
		set desired_phase_shift_2 [degrees_to_ps $desired_phase_shift_2 $desired_outclk_frequency_2]
	}
	if { $other_outclk3_phase_shift_unit == "degrees" } {
		set desired_phase_shift_3 [degrees_to_ps $desired_phase_shift_3 $desired_outclk_frequency_3]
	}

	# get the list of legal values on the given parameter
	set legal_values [::altera_xcvr_fpll_vi::parameters::get_fpll_legal_values $rule_name $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $desired_outclk_frequency_0 $desired_phase_shift_0 $desired_outclk_frequency_1 $desired_phase_shift_1 $desired_outclk_frequency_2 $desired_phase_shift_2 $desired_outclk_frequency_3 $desired_phase_shift_3 $gui_enable_manual_config]

	# select the first value
	set legal_value [lindex $legal_values 0]
	if {[string match -nocase "" $legal_value]} {
	} else {
		set lower_case_legal_value [string tolower $legal_value]
		ip_set "parameter.$parameter_name.value" $lower_case_legal_value
	}
	
	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter: $parameter_name -> $legal_value"
	}
}

# +-----------------------------------
# | This function go through RBC check to retreive the legal values on the given rule_name
# |
proc ::altera_xcvr_fpll_vi::parameters::get_pll_legal_values { config_name rule_name reference_list } {
	set result [::quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values -flow_type MEGAWIZARD -configuration_name $config_name -rule_name $rule_name -param_args $reference_list]
    return $result
    
}

# +-----------------------------------
# | This function sets the reference clock frequency parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::check_reference_clock_frequency_spec { reference_clock_frequency enable_fractional print_info_message } {
	# device part selection
	set device_part [::altera_xcvr_fpll_vi::parameters::get_device_part_name]
	
	# fractional pll usage
	if { $enable_fractional } {
		set fractional_usage "dsm_mode_phase";
	} else {
		set fractional_usage "dsm_mode_integer";
	}
		
	# set up the reference list and get the result through TCL package
	set reference_list [list $device_part $fractional_usage]
	set result [get_pll_legal_values "NIGHTFURY_PLL_CONFIG" "CMU_FPLL_REFERENCE_CLOCK_FREQUENCY" $reference_list]
	
	# strip off {{ and }} from RBC
    regsub {([\{]+)} $result {} result
    regsub {([\}]+)} $result {} result
    
	# split each refclk freq returned
    set compare_range_min [lindex [split $result "MHz.."] 0]
    set compare_range_max [lindex [split $result "MHz.."] 6]
	
	# print message to indicate the frequency range
	if { $print_info_message } {
		send_message info "The legal reference clock frequency is $result"	
	}
	
	# check on whether refclk is within the spec
	set result 1
	if { $reference_clock_frequency < $compare_range_min || $reference_clock_frequency > $compare_range_max} {
		set result 0
    }
	
	return $result
}

# +-----------------------------------
# | This function sets the reference clock frequency parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_reference_clock_frequency { gui_reference_clock_frequency gui_enable_fractional } {
	# check on whether refclk is within the spec
	set result [::altera_xcvr_fpll_vi::parameters::check_reference_clock_frequency_spec $gui_reference_clock_frequency $gui_enable_fractional true]
	if { $result } {
		set reference_clock_frequency "$gui_reference_clock_frequency MHz"
		ip_set "parameter.reference_clock_frequency.value" $reference_clock_frequency
    } else {
        send_message error "$gui_reference_clock_frequency MHz is illegal reference clock frequency"
	}
}

# +-----------------------------------
# | This function sets the reference clock1 frequency parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_reference_clock1_frequency { gui_refclk1_frequency gui_enable_fractional} {
	# check on whether refclk is within the spec
	set result [::altera_xcvr_fpll_vi::parameters::check_reference_clock_frequency_spec $gui_refclk1_frequency $gui_enable_fractional false]
	if { $result } {
		# no op
    } else {
        send_message error "$gui_refclk1_frequency MHz is illegal reference clock frequency to use as second reference clock frequency for Clock Switchover feature"
	}
}

# +-----------------------------------
# | This function sets the switchover parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_switchover_mode { gui_refclk_switch gui_switchover_mode gui_switchover_delay } {
	if { $gui_refclk_switch } {
		ip_set "parameter.pll_clkin_0_src.value" "pll_clkin_0_src_lvpecl"
		ip_set "parameter.pll_clkin_1_src.value" "pll_clkin_1_src_core_ref_clk"
		ip_set "parameter.refclk_select0.value" "lvpecl"
		ip_set "parameter.refclk_select1.value" "coreclk"
		ip_set "parameter.pll_clk_loss_sw_en.value" "true"
		ip_set "parameter.pll_clk_sw_dly.value" $gui_switchover_delay
		ip_set "parameter.gui_enable_extswitch.value" false
		if {$gui_switchover_mode == "Manual Switchover"} {
			ip_set "parameter.pll_auto_clk_sw_en.value" "false"
			ip_set "parameter.pll_manu_clk_sw_en.value" "true"
			ip_set "parameter.gui_enable_extswitch.value" true
		} elseif {$gui_switchover_mode == "Automatic Switchover"} {
			ip_set "parameter.pll_auto_clk_sw_en.value" "true"
			ip_set "parameter.pll_manu_clk_sw_en.value" "false"
		} elseif { $gui_switchover_mode == "Automatic Switchover with Manual Override"} {
			ip_set "parameter.pll_auto_clk_sw_en.value" "true"
			ip_set "parameter.pll_manu_clk_sw_en.value" "true"
			ip_set "parameter.gui_enable_extswitch.value" true
		}
	}
}

# +-----------------------------------
# | This function sets the hssi output clock frequency parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_hssi_output_clock_frequency { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_pll_l_counter } {
	variable debug_message
	
	set hssi_output_clock_frequency "$gui_hssi_output_clock_frequency MHz"
	set enable_hssi_usage $gui_enable_transceiver_usage
	if { $enable_hssi_usage } {
		if { $gui_enable_manual_config } {
			# get the possible output frequency based on the given physical parameters
			set result [get_valid_desired_output_clock_frequency $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional $gui_pll_l_counter 1]
			::alt_xcvr::utils::common::map_allowed_range gui_actual_hssi_clock_frequency $result
			
			# debug information
			if { $debug_message } {
				ip_message info "::altera_xcvr_fpll_vi::parameters::update_hssi_output_clock_frequency result: $result"
			}
			
			#strip off {{ and }} 
			regsub {([\{]+)} $result {} result
			regsub {([\}]+)} $result {} result

			# gui_actual_hssi_clock_frequency should already include the unit...
			ip_set "parameter.hssi_output_clock_frequency.value" $result
		} else {			
			set hssi_output_clock_frequency "$gui_hssi_output_clock_frequency MHz"
			ip_set "parameter.hssi_output_clock_frequency.value" $hssi_output_clock_frequency
		}
	} else {
		ip_set "parameter.gui_actual_hssi_clock_frequency.allowed_ranges" { "1250.0 MHz" }
		ip_set "parameter.hssi_output_clock_frequency.value" "0 MHz"
	}
}

# +-----------------------------------
# | This function returns a list of valid HSSI output clock frequency 
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_hssi_frequency_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_pll_l_counter } {
	variable debug_message
	
	if { $gui_enable_transceiver_usage } {
		if { $gui_enable_manual_config } {
			# get the possible output frequency based on the given physical parameters
			set result [get_valid_desired_output_clock_frequency $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional $gui_pll_l_counter 1]
			::alt_xcvr::utils::common::map_allowed_range gui_actual_hssi_clock_frequency $result
			
			# debug information
			if { $debug_message } {
				ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_hssi_frequency_values result: $result"
			}
		} 		
	} else {
		ip_set "parameter.gui_actual_hssi_clock_frequency.allowed_ranges" { "1250.0 MHz" }
	}
}


# +-----------------------------------
# | This function sets the core output clock frequency 0 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_0 { gui_enable_core_usage gui_number_of_output_clocks gui_actual_outclk0_frequency } {
	set output_clock_frequency [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_actual_outclk0_frequency]
	set enable_core_usage $gui_enable_core_usage
	if { $enable_core_usage && $gui_number_of_output_clocks >= 1} {
		ip_set "parameter.output_clock_frequency_0.value" $output_clock_frequency
	} else {
		ip_set "parameter.output_clock_frequency_0.value" "0 MHz"
	}
}

# +-----------------------------------
# | This function sets the core output clock frequency 1 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_1 { gui_enable_core_usage gui_number_of_output_clocks gui_actual_outclk1_frequency gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index } {
	set output_clock_frequency [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_actual_outclk1_frequency]
	set enable_core_usage $gui_enable_core_usage
	
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1 } {
		# no op
	} else {
		if { $enable_core_usage && $gui_number_of_output_clocks >= 2} {
			ip_set "parameter.output_clock_frequency_1.value" $output_clock_frequency
		} else {
			ip_set "parameter.output_clock_frequency_1.value" "0 MHz"
		}
	}
}

# +-----------------------------------
# | This function sets the core output clock frequency 2 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_2 { gui_enable_core_usage gui_number_of_output_clocks gui_actual_outclk2_frequency } {
	set output_clock_frequency [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_actual_outclk2_frequency]
	set enable_core_usage $gui_enable_core_usage
	if { $enable_core_usage && $gui_number_of_output_clocks >= 3} {
		ip_set "parameter.output_clock_frequency_2.value" $output_clock_frequency
	} else {
		ip_set "parameter.output_clock_frequency_2.value" "0 MHz"
	}
}

# +-----------------------------------
# | This function sets the core output clock frequency 3 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_output_clock_frequency_3 { gui_enable_core_usage gui_number_of_output_clocks gui_actual_outclk3_frequency gui_enable_cascade_out gui_cascade_outclk_index} {
	set output_clock_frequency [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_actual_outclk3_frequency]
	set enable_core_usage $gui_enable_core_usage

	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		if { $enable_core_usage && $gui_number_of_output_clocks >= 4} {
			ip_set "parameter.output_clock_frequency_3.value" $output_clock_frequency
		} else {
			ip_set "parameter.output_clock_frequency_3.value" "0 MHz"
		}
	}
}

# +-----------------------------------
# | This function gets the VCO frequency parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::get_legal_vco_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config return_all_legal_value } {

	# get the HSSI output frequency
	if { $gui_enable_transceiver_usage && !$gui_enable_manual_config } {
		set hssi_output_clock_frequency $gui_hssi_output_clock_frequency
	} else {
		set hssi_output_clock_frequency 0
	}

	set desired_outclk_frequency_0 $gui_desired_outclk0_frequency 
	set desired_phase_shift_0 $gui_outclk0_desired_phase_shift
	set desired_outclk_frequency_1 $gui_desired_outclk1_frequency
	set desired_phase_shift_1 $gui_outclk1_desired_phase_shift
	set desired_outclk_frequency_2 $gui_desired_outclk2_frequency 
	set desired_phase_shift_2 $gui_outclk2_desired_phase_shift
	set desired_outclk_frequency_3 $gui_desired_outclk3_frequency 
	set desired_phase_shift_3 $gui_outclk3_desired_phase_shift

	# reset the outclks to 0 MHz if the clocks are not used
	if { !$gui_enable_core_usage } {
		set desired_outclk_frequency_0 "0"		
		set desired_phase_shift_0 "0"	
		set desired_outclk_frequency_1 "0"		
		set desired_phase_shift_1 "0"	
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 2 } {
		set desired_outclk_frequency_1 "0"		
		set desired_phase_shift_1 "0"	
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 3 } {
		set desired_outclk_frequency_2 "0"		
		set desired_phase_shift_2 "0"	
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	} elseif { $gui_number_of_output_clocks < 4 } {
		set desired_outclk_frequency_3 "0"		
		set desired_phase_shift_3 "0"	
	}
	
	# convert into degrees since user specify phase shift in degree
	set outclk0_phase_shift $desired_phase_shift_0
	if { $gui_outclk0_phase_shift_unit == "degrees" } {
		set outclk0_phase_shift [degrees_to_ps $outclk0_phase_shift $desired_outclk_frequency_0]
	}
	set outclk1_phase_shift $desired_phase_shift_1
	if { $gui_outclk1_phase_shift_unit == "degrees" } {
		set outclk1_phase_shift [degrees_to_ps $outclk1_phase_shift $desired_outclk_frequency_1]
	}
	set outclk2_phase_shift $desired_phase_shift_2
	if { $gui_outclk2_phase_shift_unit == "degrees" } {
		set outclk2_phase_shift [degrees_to_ps $outclk2_phase_shift $desired_outclk_frequency_2]
	}
	set outclk3_phase_shift $desired_phase_shift_3
	if { $gui_outclk3_phase_shift_unit == "degrees" } {
		set outclk3_phase_shift [degrees_to_ps $outclk3_phase_shift $desired_outclk_frequency_3]
	}

	# get the vco frequency based on the given reference clocks and output clocks
	set vco_frequency [::altera_xcvr_fpll_vi::parameters::get_vco_frequency_values $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $hssi_output_clock_frequency $desired_outclk_frequency_0 $outclk0_phase_shift $desired_outclk_frequency_1 $outclk1_phase_shift $desired_outclk_frequency_2 $outclk2_phase_shift $desired_outclk_frequency_3 $outclk3_phase_shift $return_all_legal_value]
	return $vco_frequency
}

# +-----------------------------------
# | This function sets the VCO frequency parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_vco_frequency { gui_reference_clock_frequency gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_pll_m_counter gui_pll_n_counter gui_pll_dsm_fractional_division } {
	if { $gui_enable_manual_config } {
		set is_vco_valid [is_desire_vco_valid $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional 0]
		if { $is_vco_valid } {
			set desire_vco_frequency [compute_vco_frequency $gui_reference_clock_frequency $gui_pll_m_counter $gui_pll_n_counter $gui_pll_dsm_fractional_division $gui_enable_fractional]
			set vco_frequency_value "$desire_vco_frequency MHz"
			ip_set "parameter.vco_frequency.value" $vco_frequency_value
		}
	} else {
		# get the vco frequency based on the given reference clocks and output clocks
		set vco_frequency [::altera_xcvr_fpll_vi::parameters::get_legal_vco_values $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config "false"]
		ip_set "parameter.vco_frequency.value" $vco_frequency
	}
}

# +-----------------------------------
# | This function sets the HSSI protocol parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_prot_mode { gui_hssi_prot_mode } {
   if { [string compare -nocase $gui_hssi_prot_mode Basic]==0 } {
      ip_set "parameter.prot_mode.value" "basic_tx"
   } elseif { [string compare -nocase $gui_hssi_prot_mode "PCIe Gen 1"]==0 } {
      ip_set "parameter.prot_mode.value" "pcie_gen1_tx"
   } elseif { [string compare -nocase $gui_hssi_prot_mode "PCIe Gen 2"]==0 } {
      ip_set "parameter.prot_mode.value" "pcie_gen2_tx"
   } else {
      ip_set "parameter.prot_mode.value" "basic_tx"
      ip_message warning "Unexpected prot_mode($gui_hssi_prot_mode), selecting basic_tx"
   }       
}  

# +-----------------------------------
# | This function returns a list of valid output clock frequency to be as close as possible (if not exactly the same) to desired frequency
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_values { rule_name gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency desired_outclk_frequency desired_outclk_phase_shift other_outclk_frequency_1 other_outclk_phase_shift_1 other_outclk_frequency_2 other_outclk_phase_shift_2 other_outclk_frequency_3 other_outclk_phase_shift_3 desired_phase_shift_unit other_outclk1_phase_shift_unit other_outclk2_phase_shift_unit other_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message

	# get legal values
	set return_array [get_actual_fpll_legal_values $rule_name $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $desired_outclk_frequency $desired_outclk_phase_shift $other_outclk_frequency_1 $other_outclk_phase_shift_1 $other_outclk_frequency_2 $other_outclk_phase_shift_2 $other_outclk_frequency_3 $other_outclk_phase_shift_3 $desired_phase_shift_unit $other_outclk1_phase_shift_unit $other_outclk2_phase_shift_unit $other_outclk3_phase_shift_unit $gui_enable_manual_config]

	# return values are always in ps -- convert back to degrees if needed
	if { $desired_phase_shift_unit == "degrees" } {
		set return_array [ps_to_degrees $return_array $desired_outclk_frequency]
	}
	
	# debug information
	if { $debug_message } {
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_values reference_list: $reference_list"
		ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_values return_array: $return_array"
	}
	
	return $return_array
}

# +-----------------------------------
# | This function gets the valid phase shift that can be implemented by the given desired phase shift
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_0_values { gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		set result [get_actual_phase_shift_values "CMU_FPLL_OUTPUT_CLOCK_PHASE_SHIFT_0" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]
		if {[string match -nocase "" $result]} {
			# Output an error message if we cannot find the matching output clock frequency
			send_message error "Please specify correct outclk0 desired phase shift."
        } else {		
			# Update the allowed range for listing the possible actual output clock frequency
			::alt_xcvr::utils::common::map_allowed_range gui_outclk0_actual_phase_shift $result
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_0_values result: $result"
		}
	} else {
		ip_set "parameter.gui_outclk0_actual_phase_shift.allowed_ranges" { "10 ps" "20 ps" "0 ps"}
	}
}

# +-----------------------------------
# | This function gets the valid phase shift that can be implemented by the given desired phase shift
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_1_values {  gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		set result [get_actual_phase_shift_values "CMU_FPLL_OUTPUT_CLOCK_PHASE_SHIFT_1" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]

		if {[string match -nocase "" $result]} {
			# Output an error message if we cannot find the matching output clock frequency
			send_message error "Please specify correct outclk1 desired phase shift."
        } else {		
			# Update the allowed range for listing the possible actual output clock frequency
			::alt_xcvr::utils::common::map_allowed_range gui_outclk1_actual_phase_shift $result
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_1_values result: $result"
		}
	} else {
		ip_set "parameter.gui_outclk1_actual_phase_shift.allowed_ranges" { "10 ps" "20 ps" "0 ps"}
	}	
}

# +-----------------------------------
# | This function gets the valid phase shift that can be implemented by the given desired phase shift
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_2_values {  gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		set result [get_actual_phase_shift_values "CMU_FPLL_OUTPUT_CLOCK_PHASE_SHIFT_2" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]

		if {[string match -nocase "" $result]} {
			# Output an error message if we cannot find the matching output clock frequency
			send_message error "Please specify correct outclk2 desired phase shift."
        } else {		
			# Update the allowed range for listing the possible actual output clock frequency
			::alt_xcvr::utils::common::map_allowed_range gui_outclk2_actual_phase_shift $result
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_2_values result: $result"
		}
	} else {
		ip_set "parameter.gui_outclk2_actual_phase_shift.allowed_ranges" { "10 ps" "20 ps" "0 ps"}
	}	
}

# +-----------------------------------
# | This function gets the valid phase shift that can be implemented by the given desired phase shift
# |
proc ::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_3_values {  gui_reference_clock_frequency gui_number_of_output_clocks gui_enable_fractional gui_enable_transceiver_usage gui_hssi_output_clock_frequency gui_enable_core_usage gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	variable debug_message
	
	if { $gui_enable_core_usage } {
		set result [get_actual_phase_shift_values "CMU_FPLL_OUTPUT_CLOCK_PHASE_SHIFT_3" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_hssi_output_clock_frequency $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config]

		if {[string match -nocase "" $result]} {
			# Output an error message if we cannot find the matching output clock frequency
			send_message error "Please specify correct outclk3 desired phase shift."
        } else {		
			# Update the allowed range for listing the possible actual output clock frequency
			::alt_xcvr::utils::common::map_allowed_range gui_outclk3_actual_phase_shift $result
		}
		
		# debug information
		if { $debug_message } {
			ip_message info "::altera_xcvr_fpll_vi::parameters::get_actual_phase_shift_3_values result: $result"
		}
	} else {
		ip_set "parameter.gui_outclk3_actual_phase_shift.allowed_ranges" { "10 ps" "20 ps" "0 ps"}
	}	
}

# +-----------------------------------
# | This function sets phase_shift_0 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_phase_shift_0 { gui_enable_core_usage gui_number_of_output_clocks gui_outclk0_actual_phase_shift } {
	set phase_shift [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_outclk0_actual_phase_shift]
	set enable_core_usage $gui_enable_core_usage
	if { $enable_core_usage && $gui_number_of_output_clocks >= 1} {
		ip_set "parameter.phase_shift_0.value" $phase_shift
	} else {
		ip_set "parameter.phase_shift_0.value" "0 ps"
	}
}

# +-----------------------------------
# | This function sets phase_shift_1 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_phase_shift_1 { gui_enable_core_usage gui_number_of_output_clocks gui_outclk1_actual_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index } {
	set phase_shift [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_outclk1_actual_phase_shift]
	set enable_core_usage $gui_enable_core_usage
	
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1 } {
		# no op	
	} else {
		if { $enable_core_usage && $gui_number_of_output_clocks >= 2} {
			ip_set "parameter.phase_shift_1.value" $phase_shift
		} else {
			ip_set "parameter.phase_shift_1.value" "0 ps"
		}
	}
}

# +-----------------------------------
# | This function sets phase_shift_2 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_phase_shift_2 { gui_enable_core_usage gui_number_of_output_clocks gui_outclk2_actual_phase_shift } {
	set phase_shift [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_outclk2_actual_phase_shift]
	set enable_core_usage $gui_enable_core_usage
	if { $enable_core_usage && $gui_number_of_output_clocks >= 3} {
		ip_set "parameter.phase_shift_2.value" $phase_shift
	} else {
		ip_set "parameter.phase_shift_2.value" "0 ps"
	}
}

# +-----------------------------------
# | This function sets phase_shift_3 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_phase_shift_3 { gui_enable_core_usage gui_number_of_output_clocks gui_outclk3_actual_phase_shift gui_enable_cascade_out gui_cascade_outclk_index } {
	set phase_shift [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_outclk3_actual_phase_shift]
	set enable_core_usage $gui_enable_core_usage
	
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		if { $enable_core_usage && $gui_number_of_output_clocks >= 4} {
			ip_set "parameter.phase_shift_3.value" $phase_shift
		} else {
			ip_set "parameter.phase_shift_3.value" "0 ps"
		}
	}
}

# +-----------------------------------
# | This function sets pll_clkin_0_src parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_clkin_0_src { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		ip_set "parameter.pll_clkin_0_src.value" "pll_clkin_0_src_lvpecl"
	}
}

# +-----------------------------------
# | This function sets pll_clkin_1_src parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_clkin_1_src { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		ip_set "parameter.pll_clkin_1_src.value" "pll_clkin_1_src_core_ref_clk"
	}
}

# +-----------------------------------
# | This function sets pll_auto_clk_sw_en parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_auto_clk_sw_en { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter "CMU_FPLL_REFCLK_SELECT_PLL_AUTO_CLK_SW_EN" "pll_auto_clk_sw_en"
	}
}

# +-----------------------------------
# | This function sets pll_clk_loss_edge parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_clk_loss_edge { gui_refclk_switch } {
	::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter "CMU_FPLL_REFCLK_SELECT_PLL_CLK_LOSS_EDGE" "pll_clk_loss_edge"
}

# +-----------------------------------
# | This function sets pll_clk_loss_sw_en parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_clk_loss_sw_en { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter "CMU_FPLL_REFCLK_SELECT_PLL_CLK_LOSS_SW_EN" "pll_clk_loss_sw_en"
	}
}

# +-----------------------------------
# | This function sets pll_clk_sw_dly parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_clk_sw_dly { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter "CMU_FPLL_REFCLK_SELECT_PLL_CLK_SW_DLY" "pll_clk_sw_dly"
	}
}

# +-----------------------------------
# | This function sets pll_manu_clk_sw_en parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_manu_clk_sw_en { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter "CMU_FPLL_REFCLK_SELECT_PLL_MANU_CLK_SW_EN" "pll_manu_clk_sw_en"
	}
}

# +-----------------------------------
# | This function sets pll_sw_refclk_src parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_sw_refclk_src { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		::altera_xcvr_fpll_vi::parameters::update_refclk_select_physical_parameter "CMU_FPLL_REFCLK_SELECT_PLL_SW_REFCLK_SRC" "pll_sw_refclk_src"
	}
}

# +-----------------------------------
# | This function sets refclk_select1 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_refclk_select0 { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		ip_set "parameter.refclk_select0.value" "lvpecl"
	}
}

# +-----------------------------------
# | This function sets refclk_select1 parameter
# |
proc ::altera_xcvr_fpll_vi::parameters::update_refclk_select1 { gui_refclk_switch } {
	if { !$gui_refclk_switch } {
		ip_set "parameter.refclk_select1.value" "coreclk"
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_0 parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0 { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_pll_c_counter_0 } {
	if { !$gui_enable_manual_config } {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_0" "pll_c_counter_0" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	} else {
		ip_set "parameter.pll_c_counter_0.value" $gui_pll_c_counter_0
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_0_in_src parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_in_src { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_0_IN_SRC" "pll_c_counter_0_in_src" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_0_ph_mux_prst parameter  
# |pll_c_counter_0_ph_mux_prst
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_ph_mux_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_0_PH_MUX_PRST" "pll_c_counter_0_ph_mux_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_0_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_0_PRST" "pll_c_counter_0_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_0_coarse_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_coarse_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_0_COARSE_DLY" "pll_c_counter_0_coarse_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_0_fine_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_0_fine_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_0_FINE_DLY" "pll_c_counter_0_fine_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_1 parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1 { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_pll_c_counter_1 } {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1} {
		# no op
	} else {
		if { !$gui_enable_manual_config } {
			::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_1" "pll_c_counter_1" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
		} else {
			ip_set "parameter.pll_c_counter_1.value" $gui_pll_c_counter_1
		}
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_1_in_src parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_in_src { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1} {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_1_IN_SRC" "pll_c_counter_1_in_src" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_1_ph_mux_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_ph_mux_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1} {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_1_PH_MUX_PRST" "pll_c_counter_1_ph_mux_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_1_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config
gui_enable_manual_config} {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1} {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_1_PRST" "pll_c_counter_1_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_1_coarse_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_coarse_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1} {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_1_COARSE_DLY" "pll_c_counter_1_coarse_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_1_fine_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_1_fine_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		# no op
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1} {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_1_FINE_DLY" "pll_c_counter_1_fine_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_2 parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2 { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_pll_c_counter_2 gui_enable_manual_config} {
	if { !$gui_enable_manual_config } {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_2" "pll_c_counter_2" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	} else {
		ip_set "parameter.pll_c_counter_2.value" $gui_pll_c_counter_2
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_2_in_src parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_in_src { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_2_IN_SRC" "pll_c_counter_2_in_src" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_2_ph_mux_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_ph_mux_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_2_PH_MUX_PRST" "pll_c_counter_2_ph_mux_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_2_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_2_PRST" "pll_c_counter_2_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_2_coarse_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_coarse_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_2_COARSE_DLY" "pll_c_counter_2_coarse_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_2_fine_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_2_fine_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_2_FINE_DLY" "pll_c_counter_2_fine_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_c_counter_3 parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3 { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_cascade_out gui_cascade_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_pll_c_counter_3 gui_enable_manual_config } {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		if { !$gui_enable_manual_config } {
			::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_3" "pll_c_counter_3" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
		} else {
			ip_set "parameter.pll_c_counter_3.value" $gui_pll_c_counter_3
		}
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_3_in_src parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_in_src { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_cascade_out gui_cascade_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_3_IN_SRC" "pll_c_counter_3_in_src" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_3_ph_mux_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_ph_mux_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_cascade_out gui_cascade_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_3_PH_MUX_PRST" "pll_c_counter_3_ph_mux_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_3_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_cascade_out gui_cascade_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_3_PRST" "pll_c_counter_3_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_3_coarse_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_coarse_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_cascade_out gui_cascade_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_3_COARSE_DLY" "pll_c_counter_3_coarse_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_c_counter_3_fine_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_c_counter_3_fine_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_enable_cascade_out gui_cascade_outclk_index gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		# no op
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_C_COUNTER_3_FINE_DLY" "pll_c_counter_3_fine_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_fbclk_mux_1 parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_fbclk_mux_1 { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	# TODO: remove the check from the IP once PLL computation code is properly supported with FPLL bonding mode
	set is_fpll_bonding_mode [get_parameter_value "enable_fb_comp_bonding"]
	if { $is_fpll_bonding_mode } {
		ip_set "parameter.pll_fbclk_mux_1.value" "pll_fbclk_mux_1_fbclk_pll"
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_FBCLK_MUX_1" "pll_fbclk_mux_1" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_fbclk_mux_2 parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_fbclk_mux_2 { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	# TODO: remove the check from the IP once PLL computation code is properly supported with FPLL bonding mode
	set is_fpll_bonding_mode [get_parameter_value "enable_fb_comp_bonding"]
	if { $is_fpll_bonding_mode } {
		ip_set "parameter.pll_fbclk_mux_2.value" "pll_fbclk_mux_2_fb_1"
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_FBCLK_MUX_2" "pll_fbclk_mux_2" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_iqclk_mux_sel parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_iqclk_mux_sel { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_enable_iqtxrxclk_mode } {
	# TODO: remove the check from the IP once PLL computation code is properly supported with FPLL bonding mode
	set is_fpll_bonding_mode [get_parameter_value "enable_fb_comp_bonding"]
	if { $is_fpll_bonding_mode || $gui_enable_iqtxrxclk_mode } {
		ip_set "parameter.pll_iqclk_mux_sel.value" "iqtxrxclk0"
	} else {
		ip_set "parameter.pll_iqclk_mux_sel.value" "power_down"
	}
}

# +-----------------------------------
# | This function sets pll_l_counter_bypass parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_l_counter_bypass { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_L_COUNTER_BYPASS" "pll_l_counter_bypass" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_l_counter parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_l_counter { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config gui_pll_l_counter gui_enable_manual_config} {
	if { !$gui_enable_manual_config } {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_L_COUNTER" "pll_l_counter" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	} else {
		ip_set "parameter.pll_l_counter.value" $gui_pll_l_counter
	}
}

# +-----------------------------------
# | This function sets pll_l_counter_enable parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_l_counter_enable { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_L_COUNTER_ENABLE" "pll_l_counter_enable" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets update_pll_dsm_fractional_division parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_dsm_fractional_division { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_enable_fractional } {
	if { $gui_enable_manual_config } {
		# get the possible vco frequency based on the given reference clocks and output clocks
		# no need to print the error message since it should be print by m_counter parameter if the VCO is invalid
		set is_vco_valid [is_desire_vco_valid $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional 0]
		if { $is_vco_valid } {
			ip_set "parameter.pll_dsm_fractional_division.value" $gui_pll_dsm_fractional_division
		}
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_DSM_FRACTIONAL_DIVISION" "pll_dsm_fractional_division" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_dsm_mode parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_dsm_mode { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_DSM_MODE" "pll_dsm_mode" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_dsm_out_sel parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_dsm_out_sel { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config } {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_DSM_OUT_SEL" "pll_dsm_out_sel" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_m_counter parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_enable_fractional} {
	if { $gui_enable_manual_config } {
		# get the possible vco frequency based on the given reference clocks and output clocks
		set is_vco_valid [is_desire_vco_valid $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional 1]
		if { $is_vco_valid } {
			ip_set "parameter.pll_m_counter.value" $gui_pll_m_counter
		} else {
			send_message error "The specified configuration causes VCO to go beyond the limit.  Please try another configuration of M-counter/N-counter."
		}
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_M_COUNTER" "pll_m_counter" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_m_counter_in_src parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_in_src { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_M_COUNTER_IN_SRC" "pll_m_counter_in_src" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_m_counter_ph_mux_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_ph_mux_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_M_COUNTER_PH_MUX_PRST" "pll_m_counter_ph_mux_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_m_counter_prst parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_prst { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_M_COUNTER_PRST" "pll_m_counter_prst" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_m_counter_coarse_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_coarse_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_M_COUNTER_COARSE_DLY" "pll_m_counter_coarse_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_m_counter_fine_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_m_counter_fine_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_M_COUNTER_FINE_DLY" "pll_m_counter_fine_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_n_counter parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_n_counter { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_enable_fractional } {
	if { $gui_enable_manual_config } {
		# get the possible vco frequency based on the given reference clocks and output clocks
		# no need to print the error message since it should be print by m_counter parameter if the VCO is invalid
		set is_vco_valid [is_desire_vco_valid $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional 0]
		if { $is_vco_valid } {
			ip_set "parameter.pll_n_counter.value" $gui_pll_n_counter
		}
	} else {
		::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_N_COUNTER" "pll_n_counter" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
	}
}

# +-----------------------------------
# | This function sets pll_n_counter_coarse_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_n_counter_coarse_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_N_COUNTER_COARSE_DLY" "pll_n_counter_coarse_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets pll_n_counter_fine_dly parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_pll_n_counter_fine_dly { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_enable_manual_config} {
	::altera_xcvr_fpll_vi::parameters::update_fpll_physical_parameter "CMU_FPLL_PLL_N_COUNTER_FINE_DLY" "pll_n_counter_fine_dly" $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config
}

# +-----------------------------------
# | This function sets speed_grade parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_speed_grade { gui_device_speed_grade } {
	set speed_grade [ ::alt_xcvr::utils::device::convert_speed_grade $gui_device_speed_grade ]
	ip_set "parameter.speed_grade.value" $speed_grade
}

# +-----------------------------------
# | This function gets compensation_mode string based on the given parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::get_compensation_mode { gui_operation_mode } {
	set is_fpll_bonding_mode [get_parameter_value "enable_fb_comp_bonding"]

	if { $is_fpll_bonding_mode } {
		set compensation_mode "fpll_bonding"
	} else {	
		set compensation_mode "direct"
		if { $gui_operation_mode == "direct" } {
			set compensation_mode "direct"
		} elseif { $gui_operation_mode == "normal" } {
			set compensation_mode "normal"
		} else {
			set compensation_mode "iqtxrxclk"
		}
	}
	return $compensation_mode
}

# +-----------------------------------
# | This function sets compensation_mode parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_compensation_mode { gui_number_of_output_clocks gui_enable_core_usage gui_enable_transceiver_usage gui_operation_mode } {
	set compensation_mode [get_compensation_mode $gui_operation_mode]
	set is_fpll_bonding_mode [get_parameter_value "enable_fb_comp_bonding"]
	ip_set "parameter.compensation_mode.value" $compensation_mode
	
	# enable the source index drop down for IQTXRXCLK compensation mode
	if { $compensation_mode == "iqtxrxclk" } {
		if { $gui_enable_core_usage } {
			ip_set "parameter.gui_enable_iqtxrxclk_mode.value" true
			
			# setup the new range for gui_iqtxrxclk_outclk_index
			set new_range 0
			if { $gui_number_of_output_clocks > 1} {
			  lappend new_range 1
			}
			ip_set "parameter.gui_iqtxrxclk_outclk_index.ALLOWED_RANGES" $new_range		
		} else {
			send_message error "Please enable Core PLL usage -- an outclk is required to use for IQTXRXCLK operation mode."
		}	
	} else {
		ip_set "parameter.gui_enable_iqtxrxclk_mode.value" false
		
		# make sure user doesn't use normal mode on Transciever PLL
		if { $compensation_mode == "normal" && $gui_enable_transceiver_usage} {
			send_message error "Please use direct, IQTXRXCLK or feedback compensation bonding operation mode when use as Transceiver PLL."
		}
	}
}

# +-----------------------------------
# | This function sets compensation_mode parameter  
# |
proc ::altera_xcvr_fpll_vi::parameters::update_silicon_rev { silicon_rev } {
   #ip_message warning "::altera_xcvr_fpll_vi::parameters::convert_silicon_rev NOTE TO IP DEVELOPER: THIS FUNCTION MUST CHANGE"

   if {[string compare -nocase $silicon_rev true]==0 } {
      ip_set "parameter.gui_silicon_rev.value" "reva"
   } elseif { [string compare -nocase $silicon_rev false]==0 } {
      ip_set "parameter.gui_silicon_rev.value" "reva"
   } else {
      ip_set "parameter.gui_silicon_rev.value" "reva"
      ip_message warning "Unexpected silicon_rev($silicon_rev), selecting reva"
   }   
}       

# +-----------------------------------
# | This function updates/prints necessary error message when enable pcie_clk is turned on 
# |
proc ::altera_xcvr_fpll_vi::parameters::update_enable_pcie_clk { gui_enable_pcie_clk gui_enable_core_usage gui_enable_transceiver_usage output_clock_frequency_0 gui_hssi_output_clock_frequency } {
  if { $gui_enable_pcie_clk } {
	  if { $gui_enable_transceiver_usage } {
		# the HSSI usage is on -- make sure HSSI outclock is running at 2500MHz
		if { $gui_hssi_output_clock_frequency != "2500" } {
			send_message error "Please specify correct output frequency on Tranceiver PLL usage -- output frequency is required to toggle at 2500 MHz for PCIe."
		}
		
		# the core usage (outclk0) needs to be on for PCIE usage
		if { $gui_enable_core_usage } {
			if { $output_clock_frequency_0 != "500.0 MHz" } {
				send_message error "Please specify correct output frequency on Core PLL usage -- outclk0 is required to toggle at 500 MHz for PCIe."
			}
		} else {
			send_message error "Please enable Core PLL usage -- outclk0 is required to toggle at 500 MHz for PCIe."
		}
	  } else {
		send_message error "Please enable Tranceiver PLL usage -- output frequency is required to toggle at 2500 MHz for PCIe."
	  }
  }
} 

# +-----------------------------------
# | This function updates/prints necessary error message when enable cascade out is turned on 
# |
proc ::altera_xcvr_fpll_vi::parameters::update_enable_cascade_out { gui_enable_cascade_out gui_enable_core_usage gui_number_of_output_clocks } {
   if { $gui_enable_cascade_out } {
	   # setup the new range for gui_cascade_outclk_index
	   set new_range 0
	   for {set index 1} {$index < $gui_number_of_output_clocks} {incr index} {
		  lappend new_range $index
	   }
	   ip_set "parameter.gui_cascade_outclk_index.ALLOWED_RANGES" $new_range
	   
	   # a Core outclk is required for cascading purposes
	   if { $gui_enable_core_usage } {
			# no op
	   } else {
			send_message error "Please enable Core PLL usage -- an outclk is required to use for cascading."
	   }
   }
}

# +-----------------------------------
# | This function updates/prints necessary error message when enable atx pll cascade out is turned on
# |
proc ::altera_xcvr_fpll_vi::parameters::update_enable_atx_pll_cascade_out { gui_enable_atx_pll_cascade_out gui_enable_core_usage gui_number_of_output_clocks } {
   if { $gui_enable_atx_pll_cascade_out } {
	   # setup the new range for gui_atx_pllcascade_outclk_index
	   set new_range 0
	   if { $gui_number_of_output_clocks > 1} {
		  lappend new_range 1
	   }
	   ip_set "parameter.gui_atx_pllcascade_outclk_index.ALLOWED_RANGES" $new_range
	   
	   # a Core outclk is required for cascading purposes
	   if { $gui_enable_core_usage } {
			# no op
	   } else {
			send_message error "Please enable Core PLL usage -- an outclk is required to use for cascading."
	   }
   }
}

# +-----------------------------------
# | This function copies the pll_counter_3 parameters with the cascading source 
# |
proc ::altera_xcvr_fpll_vi::parameters::update_cascade_outclk_index { gui_enable_cascade_out gui_cascade_outclk_index } {
	if { $gui_enable_cascade_out && $gui_cascade_outclk_index != 3 } {
		set param "pll_c_counter_$gui_cascade_outclk_index"
		set in_src "_in_src"
		set ph_mux_prst "_ph_mux_prst"
		set prst "_prst"
		set coarse_dly "_coarse_dly"
		set fine_dly "_fine_dly"
		
		# overwrite pll_c_counter_3 paramters since cascade_out is connected with counter 3
		ip_set "parameter.pll_c_counter_3.value" [get_parameter_value $param]
		set param_name $param$in_src
		ip_set "parameter.pll_c_counter_3_in_src.value" [get_parameter_value $param_name]
		set param_name $param$ph_mux_prst
		ip_set "parameter.pll_c_counter_3_ph_mux_prst.value" [get_parameter_value $param_name]
		set param_name $param$prst
		ip_set "parameter.pll_c_counter_3_prst.value" [get_parameter_value $param_name]
		set param_name $param$coarse_dly
		ip_set "parameter.pll_c_counter_3_coarse_dly.value" [get_parameter_value $param_name]
		set param_name $param$fine_dly
		ip_set "parameter.pll_c_counter_3_fine_dly.value" [get_parameter_value $param_name]
		ip_set "parameter.output_clock_frequency_3.value" [get_parameter_value output_clock_frequency_$gui_cascade_outclk_index]
		ip_set "parameter.phase_shift_3.value" [get_parameter_value phase_shift_$gui_cascade_outclk_index]
		
		# output an info message to indicate that we are overwriting pll_c_counter_3 parameters
		ip_message info "Replacing outclk3 with outclk$gui_cascade_outclk_index parameters as outclk3 will be used as FPLL to FPLL cascading source"
	}	
}

# +-----------------------------------
# | This function copies the pll_counter_1 parameters with the cascading source 
# |
proc ::altera_xcvr_fpll_vi::parameters::update_atx_pll_cascade_outclk_index { gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index } {
	if { $gui_enable_atx_pll_cascade_out && $gui_atx_pllcascade_outclk_index != 1 } {
		set param "pll_c_counter_$gui_atx_pllcascade_outclk_index"
		set in_src "_in_src"
		set ph_mux_prst "_ph_mux_prst"
		set prst "_prst"
		set coarse_dly "_coarse_dly"
		set fine_dly "_fine_dly"
		
		# overwrite pll_c_counter_1 paramters since iqtxrxclk is connected with counter 1
		ip_set "parameter.pll_c_counter_1.value" [get_parameter_value $param]
		set param_name $param$in_src
		ip_set "parameter.pll_c_counter_1_in_src.value" [get_parameter_value $param_name]
		set param_name $param$ph_mux_prst
		ip_set "parameter.pll_c_counter_1_ph_mux_prst.value" [get_parameter_value $param_name]
		set param_name $param$prst
		ip_set "parameter.pll_c_counter_1_prst.value" [get_parameter_value $param_name]
		set param_name $param$coarse_dly
		ip_set "parameter.pll_c_counter_1_coarse_dly.value" [get_parameter_value $param_name]
		set param_name $param$fine_dly
		ip_set "parameter.pll_c_counter_1_fine_dly.value" [get_parameter_value $param_name]
		ip_set "parameter.output_clock_frequency_1.value" [get_parameter_value output_clock_frequency_$gui_atx_pllcascade_outclk_index]
		ip_set "parameter.phase_shift_1.value" [get_parameter_value phase_shift_$gui_atx_pllcascade_outclk_index]

		# output an info message to indicate that we are overwriting pll_c_counter_1 parameters
		ip_message info "Replacing outclk1 with outclk$gui_atx_pllcascade_outclk_index parameters as outclk1 will be used as FPLL to ATX PLL cascading source"
	}
}

# +-----------------------------------
# | This function copies the pll_counter_1 parameters with the IQTXRXCLK feedback source 
# |
proc ::altera_xcvr_fpll_vi::parameters::update_iqtxrxclk_outclk_index { gui_enable_iqtxrxclk_mode gui_iqtxrxclk_outclk_index gui_enable_atx_pll_cascade_out gui_atx_pllcascade_outclk_index } {
	if { $gui_enable_atx_pll_cascade_out && $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != $gui_atx_pllcascade_outclk_index } {
		# conflict with cascading feature
		ip_message error "Cannot use outclk1 as IQTXRXCLK feedback source as outclk1 is already used as FPLL to ATX PLL cascading source"		
	} elseif { $gui_enable_iqtxrxclk_mode && $gui_iqtxrxclk_outclk_index != 1 } {
		set param "pll_c_counter_$gui_iqtxrxclk_outclk_index"
		set in_src "_in_src"
		set ph_mux_prst "_ph_mux_prst"
		set prst "_prst"
		set coarse_dly "_coarse_dly"
		set fine_dly "_fine_dly"
		
		# overwrite pll_c_counter_1 paramters since iqtxrxclk is connected with counter 1
		ip_set "parameter.pll_c_counter_1.value" [get_parameter_value $param]
		set param_name $param$in_src
		ip_set "parameter.pll_c_counter_1_in_src.value" [get_parameter_value $param_name]
		set param_name $param$ph_mux_prst
		ip_set "parameter.pll_c_counter_1_ph_mux_prst.value" [get_parameter_value $param_name]
		set param_name $param$prst
		ip_set "parameter.pll_c_counter_1_prst.value" [get_parameter_value $param_name]
		set param_name $param$coarse_dly
		ip_set "parameter.pll_c_counter_1_coarse_dly.value" [get_parameter_value $param_name]
		set param_name $param$fine_dly
		ip_set "parameter.pll_c_counter_1_fine_dly.value" [get_parameter_value $param_name]
		ip_set "parameter.output_clock_frequency_1.value" [get_parameter_value output_clock_frequency_$gui_iqtxrxclk_outclk_index]
		ip_set "parameter.phase_shift_1.value" [get_parameter_value phase_shift_$gui_iqtxrxclk_outclk_index]

		# output an info message to indicate that we are overwriting pll_c_counter_1 parameters
		ip_message info "Replacing outclk1 with outclk$gui_iqtxrxclk_outclk_index parameters as outclk1 will be used as IQTXRXCLK feedback source"
	}
}


# +-----------------------------------
# | This function converts degrees to ps on the given phase_array 
# |
proc degrees_to_ps {phase_array freq} {
    
    set return_phase_array [list]
    foreach phase_val $phase_array {
		regexp {([-0-9.]+)} $phase_val phase_value 
		regexp {([-0-9.]+)} $freq freq_value 
		if {$freq_value != 0} {
			#convert negative phase shift to positive phase shift
			if {$phase_value < 0} {
				set phase_value [expr {360 - abs($phase_value)}]
			}
			set phase_in_ps [expr {$phase_value /(360*$freq_value)}]
			#convert to ps
			set phase_in_ps [expr {$phase_in_ps * 1000000.0}]
			set phase_in_ps [expr {round($phase_in_ps)}]
			lappend return_phase_array $phase_in_ps
		} else {
			lappend return_phase_array $phase_val
		}
    }
    return $return_phase_array

}

# +-----------------------------------
# | This function converts ps to degrees on the given phase_array 
# |
proc ps_to_degrees {phase_array freq} {
    set return_phase_array [list]
    foreach phase_val $phase_array {
        regexp {([-0-9.]+)} $phase_val phase_value 
        regexp {([-0-9.]+)} $freq freq_value 
        set phase_in_deg [expr {$phase_value*360.0*$freq_value/1000000.0}]
		set phase_in_deg [format "%.1f" $phase_in_deg]
        set phase_in_deg_int [expr {round($phase_in_deg)}]
        set phase_in_deg_mod [expr {$phase_in_deg_int%360}]
		set phase_in_deg [expr $phase_in_deg + $phase_in_deg_mod - $phase_in_deg_int]
        set phase_in_deg "$phase_in_deg deg"
        lappend return_phase_array $phase_in_deg
    }
    return $return_phase_array
}

# +-----------------------------------
# | This function converts ps to degrees on the given phase_array 
# |
proc compute_vco_frequency { gui_reference_clock_frequency gui_pll_m_counter gui_pll_n_counter gui_pll_dsm_fractional_division gui_enable_fractional} {
	set mult $gui_pll_m_counter
	set div $gui_pll_n_counter
	set ref_clk [precision_check $gui_reference_clock_frequency]
    set third_order_divide [expr {pow(2, 32)}]
	
	#use a different equation to calculate frequency
	#if frac pll
	if { $gui_enable_fractional } {
		set frac $gui_pll_dsm_fractional_division
		set frac_double [expr {double($frac*1.0)}]
		set vco_freq [format "%.6f" [expr {$ref_clk*(($mult+double($frac_double)/$third_order_divide)/$div)}]]
	} else {
		set vco_freq [expr {$ref_clk*(double($mult)/$div)}]
	}

	return $vco_freq;
}

# +-----------------------------------
# | 
# |
proc precision_check { params } {
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

# +-----------------------------------
# | This function returns whether the VCO can be implemented by the given physical parameter of M/N/K value
# |
proc is_desire_vco_valid { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_enable_fractional enable_info_message } {
	# get the possible vco frequency based on the given reference clocks and output clocks
	set valid_vco_frequency [::altera_xcvr_fpll_vi::parameters::get_legal_vco_values $gui_reference_clock_frequency $gui_number_of_output_clocks $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_enable_manual_config "true"]
	set desire_vco_frequency [compute_vco_frequency $gui_reference_clock_frequency $gui_pll_m_counter $gui_pll_n_counter $gui_pll_dsm_fractional_division $gui_enable_fractional]

	set is_valid 0
	set is_fractional_error 0
	set tolerance 1
	set num_legal_vco_freqs [llength $valid_vco_frequency]
	for { set i 0 } {$i < $num_legal_vco_freqs} {incr i} {
		set vco_freq_str [lindex $valid_vco_frequency $i]
		regsub {([ MHz]+)} $vco_freq_str {} vco_freq 

		if {[expr {$desire_vco_frequency - $vco_freq}] >= 0 && [expr {$desire_vco_frequency - $vco_freq}] <= $tolerance ||
			[expr {$vco_freq - $desire_vco_frequency}] >= 0 && [expr {$vco_freq - $desire_vco_frequency}] <= $tolerance} {
			# the desired vco frequency is within the legal list; therefore, allow user to pick the given m/n/c values
			set is_valid 1
			break
		}
	}	

	if { $gui_enable_fractional && $gui_enable_manual_config} {
		# allow the configuration when user is manually changing the K value
		set third_order_divide [expr {pow(2, 32)}]
		set frac $gui_pll_dsm_fractional_division
		set frac_double [expr {double($frac*1.0)}]
		set fractional [format "%.6f" [expr {double($frac_double)/$third_order_divide}]]
		if {[expr {$fractional - 0.05}] < 0 || [expr {$fractional - 0.95}] > 0 } { 
			set is_valid 0
			set is_fractional_error 1
		} else {
			set is_valid 1
		}
	}

	if { $enable_info_message && $is_valid != 1} {
		if { $is_fractional_error } {
			send_message error "The specified fractional configuration $fractional ($gui_pll_dsm_fractional_division / 2^32) is illegal.  Please make sure the fractional value is between 0.05 ~ 0.95."	
		} else {
			send_message error "The specified configuration will generate a Voltage-Controlled Oscillator (VCO) of $desire_vco_frequency MHz.\n However, $desire_vco_frequency MHz is not one of the valid VCO frequency that can be configured: $valid_vco_frequency"	
		}
	}
	
	return $is_valid
}


# +-----------------------------------
# | This function returns whether the VCO can be implemented by the given physical parameter of M/N/K value
# |
proc get_valid_desired_output_clock_frequency { gui_reference_clock_frequency gui_enable_core_usage gui_number_of_output_clocks gui_operation_mode gui_enable_fractional gui_enable_transceiver_usage gui_enable_core_usage gui_hssi_output_clock_frequency gui_desired_outclk0_frequency gui_outclk0_desired_phase_shift gui_desired_outclk1_frequency gui_outclk1_desired_phase_shift gui_desired_outclk2_frequency gui_outclk2_desired_phase_shift gui_desired_outclk3_frequency gui_outclk3_desired_phase_shift gui_outclk0_phase_shift_unit gui_outclk1_phase_shift_unit gui_outclk2_phase_shift_unit gui_outclk3_phase_shift_unit gui_pll_m_counter gui_pll_n_counter gui_enable_manual_config gui_pll_dsm_fractional_division gui_enable_fractional counter_division include_unit } {
	set is_vco_valid [is_desire_vco_valid $gui_reference_clock_frequency $gui_enable_core_usage $gui_number_of_output_clocks $gui_operation_mode $gui_enable_fractional $gui_enable_transceiver_usage $gui_enable_core_usage $gui_hssi_output_clock_frequency $gui_desired_outclk0_frequency $gui_outclk0_desired_phase_shift $gui_desired_outclk1_frequency $gui_outclk1_desired_phase_shift $gui_desired_outclk2_frequency $gui_outclk2_desired_phase_shift $gui_desired_outclk3_frequency $gui_outclk3_desired_phase_shift $gui_outclk0_phase_shift_unit $gui_outclk1_phase_shift_unit $gui_outclk2_phase_shift_unit $gui_outclk3_phase_shift_unit $gui_pll_m_counter $gui_pll_n_counter $gui_enable_manual_config $gui_pll_dsm_fractional_division $gui_enable_fractional 0]
	set return_array [list]
	if { $is_vco_valid } {
		set desire_vco_frequency [compute_vco_frequency $gui_reference_clock_frequency $gui_pll_m_counter $gui_pll_n_counter $gui_pll_dsm_fractional_division $gui_enable_fractional]
		set outclk_frequency_value [format "%.6f" [expr $desire_vco_frequency / $counter_division]]
		if { $include_unit } {
			set outclk_frequency_value "$outclk_frequency_value MHz"
		}
		lappend return_array $outclk_frequency_value
	} else {
		# we should already generate an error message by now...
		lappend return_array "N/A"
	}
	
	return $return_array
}
