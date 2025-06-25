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


proc log {base x} {expr {log($x)/log($base)}} 
proc log2ceil { num } {
    set val 0
    set i   1
    while { $i <= $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

     return $val
 }

proc calculate_avalon_s_address_width {i_CB_A2P_ADDR_MAP_NUM_ENTRIES i_Cg_Avalon_S_Addr_Width } {

set my_Cg_Avalon_S_Addr_Width $i_Cg_Avalon_S_Addr_Width
switch $i_CB_A2P_ADDR_MAP_NUM_ENTRIES {
	1 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width]}
	2 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 1]}
	4 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 2]}
	8 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 3]}
	16 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 4]}
	32 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 5]}
	64 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 6]}
	128 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 7]}
	256 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 8]}
	512 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 9]}
	default { }	
    }	
	
	return $my_Cg_Avalon_S_Addr_Width
}

proc set_buffer_settings { p_pcie_target_performance_preset max_payload_size max_link_width } {
 	
 	set high "High"
	set under "_"
	 
	set key $p_pcie_target_performance_preset$under$high$under$max_payload_size$under$max_link_width
	 	  
	set credits [split [get_creditslist $key] " "]
	foreach credit $credits {
		#Index of =
   		set equalIndex [string first "=" $credit ]
   		
   		#name
		set name [string range $credit 0 [expr { $equalIndex-1 }]  ]
   		
   		#value
		set value [string range $credit [expr { $equalIndex+1 }] end ]

		if { [ string compare -nocase $name "rx_buf" ] == 0 } {
				
		} else {		
			set_parameter_value $name $value
		}
	  
	  }  
}

proc set_a2p_address_map { } {	  
        
	set CB_A2P_ADDR_MAP_NUM_ENTRIES [get_parameter_value CB_A2P_ADDR_MAP_NUM_ENTRIES]
	set CB_A2P_ADDR_MAP_PASS_THRU_BITS [get_parameter_value CB_A2P_ADDR_MAP_PASS_THRU_BITS]
	set CB_A2P_ADDR_MAP_IS_FIXED [get_parameter_value CB_A2P_ADDR_MAP_IS_FIXED]
	
if { $CB_A2P_ADDR_MAP_IS_FIXED == 1  } {
	for { set i 0 } { $i < $CB_A2P_ADDR_MAP_NUM_ENTRIES } { incr i } {
		
		set high_list [split [ get_parameter_value "PCIe Address 63:32" ] ","]
		set low_list [split [ get_parameter_value "PCIe Address 31:0" ] ","]
		
		set_parameter_value "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" [lindex $high_list $i] 
		set_parameter_value "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" [lindex $low_list $i] 
		
		}
}	
		
	}

proc update_a2p_address_map_table { } {	  

	set CB_A2P_ADDR_MAP_NUM_ENTRIES [get_parameter_value CB_A2P_ADDR_MAP_NUM_ENTRIES]
	set CB_A2P_ADDR_MAP_PASS_THRU_BITS [get_parameter_value CB_A2P_ADDR_MAP_PASS_THRU_BITS]
	set pcie_num_list [split [ get_parameter_value "Address Page" ] ","]
	#send_message "error" "The  pcie_num_list is...... $pcie_num_list"	

	for { set i 0 } { $i < 16 } { incr i } {	
		
		###########send_message "error" "bar_num_list is $bar_num_list" 
		if { ($i> [expr $CB_A2P_ADDR_MAP_NUM_ENTRIES-1] ) } {

			set pcie_num_list [lreplace $pcie_num_list $i $i "N/A"]
			

			#send_message "error" "The new value of BAR is $pcie_num_list"		
		} else {
			set pcie_num_list [lreplace $pcie_num_list $i $i $i]
		}
		
	}
	
	set pcie_num_list [join $pcie_num_list , ]
	if {[string equal [get_parameter_value "Address Page"] ${pcie_num_list} ] == 1} {
	} else {
		set_parameter_value "Address Page" $pcie_num_list
	}
}
proc enable_disable_controls { } {


	# Collect parameter values into local variables
	foreach var [ get_parameters ] {
	  set $var [ get_parameter_value $var ]
	 }
	 
	## 0:Requester/Completer" "1:Completer-Only" "2:Completer-Only single dword"
	if { $CB_PCIE_MODE == 2 || $CB_PCIE_MODE == 1} {

	 	
	 	#MM Lite DISABLE  all othetr GUI controls on Avalaon page
	 	if { $CB_PCIE_MODE == 1} {	
	 		set_parameter_property CG_COMMON_CLOCK_MODE ENABLED "true"
	 	} else {
	 		set_parameter_property CG_COMMON_CLOCK_MODE ENABLED "false"
	 	}
	  # set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED ENABLED "false"
	 	set_parameter_property CG_AVALON_S_ADDR_WIDTH ENABLED "false"
	 	
	 	
	 	set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES ENABLED "false"
	 	set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS ENABLED "false"

		set_parameter_property CG_AVALON_S_ADDR_WIDTH ENABLED "false"

	 	
	 	 for { set i 0 } { $i < 16 } { incr i } {		
			#set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}" ENABLED "false"	
		  }
	
	 } else {
	 	
	 	#ENABLE  all othetr GUI controls on Avalaon page
	 	set_parameter_property CG_COMMON_CLOCK_MODE ENABLED "true"
		set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED ENABLED "true"
		set_parameter_property CG_AVALON_S_ADDR_WIDTH ENABLED "true"

		
		set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES ENABLED "true"
		set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS ENABLED "true"
	 }	
	 
	 
	  
	  
	set MY_CB_A2P_ADDR_MAP_NUM_ENTRIES 16
	if { $CB_A2P_ADDR_MAP_NUM_ENTRIES < 16  } {
	 	set MY_CB_A2P_ADDR_MAP_NUM_ENTRIES $CB_A2P_ADDR_MAP_NUM_ENTRIES 
	 }
	 
	 #2. Disable controls for Dynamic translation table
	 for { set i 0 } { $i <16 } { incr i } {		
	 	#set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}" ENABLED "false"	
	 }
	 if { $CB_A2P_ADDR_MAP_IS_FIXED == 0  } {
	 	
		
	 } else {
		#Only enable "Number of address pages" CB_A2P_ADDR_MAP_FIXED_TABLE entries
		for { set i 0 } { $i < $MY_CB_A2P_ADDR_MAP_NUM_ENTRIES } { incr i } {		
			#set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}" ENABLED "true"	
		}
		
	 }
	    
	  

}
proc is64bitBar { index } {

    set result 0 
    # split the contents on ,
    set bar_type_list [split [ get_parameter_value "BAR Type" ] ","]
    

    ###########send_message "error" "bar_type_list is $bar_type_list"
    
    set value_at_index [lindex $bar_type_list $index]
    #########send_message "error" "value_at_index is $value_at_index"    
    if {[ string compare -nocase $value_at_index "64 bit Prefetchable" ] == 0 } {
    	set result 1
    }
    ########send_message "error" "result is $result" 
    
    return $result
}

proc isBarPrefetchable { index } {

    set result 0     
    if { ([isBarUsed $index] == 1) && ([is64bitBar $index] == 1) } {
    	set result 1
    }
       
    return $result
}


proc isBarUsed { index } {

    set result 1 
    # split the contents on ,
    set bar_type_list [split [ get_parameter_value "BAR Type" ] ","] 
    
    set value_at_index [lindex $bar_type_list $index]   
    if {[ string compare -nocase $value_at_index "Not used" ] == 0 } {
    	set result 0
    }
    #send_message "error" "result is $result for BAR$index" 
    
    return $result
}


proc bitstoSizestring { bits } {

set sizeString 0
switch $bits {
	4 {set sizeString "16 Bytes - 4 bits"}
	5 {set sizeString "32 Bytes - 5 bits"}
	6 {set sizeString "64 Bytes - 6 bits"}
	7 {set sizeString "128 Bytes - 7 bits"}
	8 {set sizeString "256 Bytes - 8 bits"}
	9 {set sizeString "512 Bytes - 9 bits"}
	10 {set sizeString "1 KByte - 10 bits"}
	11 {set sizeString "2 KByte - 11 bits"}
	12 {set sizeString "4 KByte - 12 bits"}
	13 {set sizeString "8 KByte - 13 bits"}
	14 {set sizeString "16 KBytes - 14 bits"}
	15 {set sizeString "32 KBytes - 15 bits"}
	16 {set sizeString "64 KBytes - 16 bits"}
	17 {set sizeString "128 KBytes - 17 bits"}
	18 {set sizeString "256 KBytes - 18 bits"}
	19 {set sizeString "512 KBytes - 19 bits"}
	20 {set sizeString "1 MByte - 20 bits"}
	21 {set sizeString "2 MByte - 21 bits"}
	22 {set sizeString "4 MByte - 22 bits"}
	23 {set sizeString "8 MByte - 23 bits"}
	24 {set sizeString "16 MBytes - 24 bits"}
	25 {set sizeString "32 MBytes - 25 bits"}
	26 {set sizeString "64 MBytes - 26 bits"}
	27 {set sizeString "128 MBytes - 27 bits"}
	28 {set sizeString "256 MBytes - 28 bits"}
	29 {set sizeString "512 MBytes - 29 bits"}
	30 {set sizeString "1 GByte - 30 bits"}
	31 {set sizeString "2 GByte - 31 bits"}
	32 {set sizeString "4 GByte - 32 bits"}
	default { }	
    }	
	
	return $sizeString
}

proc validate_bars { } {
	set num_bars 6
	for { set i 0 } { $i < $num_bars } { incr i } {
		###if Bar0, Bar2 or Bar4 is 64 bit, we need to do stuff
		if { ($i==0 || $i==2 || $i ==4) && ([is64bitBar $i ] == 1) } {
		
			
			###### ERROR CHECKING ##############################################
			# BARS 1,3 and 5 have to be not used
			if { [isBarUsed [expr $i+1] ] == 1 } {
			 send_message "error" "BAR [expr $i+1] must be set to \"Not used\" as BAR $i is a \"64 bit Prefetchable\" Bar" 
			}
			
		} elseif {($i==1 || $i==3 || $i ==5) && ([is64bitBar $i ] == 1) } {
			send_message "error" "Illegal \"Bar Type\" selected for BAR $i, only even number BARs are allowed to be \"64 bit Prefetchable\" " 
		} elseif {($i==0) && ([isBarUsed $i ] == 0)} {
			 	send_message "error" "BAR $i must always be used" 	
		} 
		
	}
	
}

proc update_bar_table { } {
	set num_bars 6
	for { set i 0 } { $i < $num_bars } { incr i } {
		###if Bar0, Bar2 or Bar4 is 64 bit, we need to do stuff
		if { ($i==0 || $i==2 || $i ==4) && ([is64bitBar $i ] == 1) } {
		
			
			set bar_num_list [split [ get_parameter_value "BAR" ] ","]
			###########send_message "error" "bar_num_list is $bar_num_list" 

			set new_bar_num_list [lreplace $bar_num_list [expr $i+1] [expr $i+1] "[expr $i+1] - Occupied"]
			set new_bar_num_list [join $new_bar_num_list , ]

			#send_message "error" "The new value of BAR is $new_bar_num_list"

			if {[string equal [get_parameter_value "BAR"] ${new_bar_num_list} ] == 1} {
			} else {
				set_parameter_value "BAR" $new_bar_num_list
			}
			
			#send_message "error" "Retrive new value of BAR ::: [get_parameter_value BAR]" 

		} else {
			
			if {([is64bitBar [expr $i-1] ] != 1)} {
        			set bar_num_list [split [ get_parameter_value "BAR" ] ","]
        			###########send_message "error" "bar_num_list is $bar_num_list" 
        
        			set new_bar_num_list [lreplace $bar_num_list $i $i $i]
        			set new_bar_num_list [join $new_bar_num_list , ]
        
        			#send_message "error" "The new value of BAR is $new_bar_num_list"
        
        			if {[string equal [get_parameter_value "BAR"] ${new_bar_num_list} ] == 1} {
        			} else {
        				set_parameter_value "BAR" $new_bar_num_list
        			}
			}			
		}
		
		#2. ######## Set the  BAR Size in the table ############################
		set bar_size_list [split [ get_parameter_value "BAR Size" ] ","]
		#send_message "error" "bar_size_list is $bar_size_list" 
		
		set actual_bar_size [get_parameter_value "bar${i}_size_mask"]

		set new_bar_size_list [lreplace $bar_size_list $i $i $actual_bar_size]
		set new_bar_size_list [join $new_bar_size_list , ]

		#send_message "error" "The new value of BAR Size is $new_bar_size_list"
		if {[string equal [get_parameter_value "BAR Size"] ${new_bar_size_list} ] == 1} {
		
		} else {
			set_parameter_value "BAR Size" ${new_bar_size_list}
		}
		
		#3. ####### Set the  Avalon Base Address in the table ###########################
		set base_address_list [split [ get_parameter_value "Avalon Base Address" ] ","]

		set base_address [expr [get_parameter_value "CB_P2A_AVALON_ADDR_B${i}"]] 
		#send_message "error" "base_address for $i issssssssssss $base_address" 
		
		set new_base_address_list [lreplace $base_address_list $i $i $base_address]
		set new_base_address_list [join $new_base_address_list , ]

		#send_message "error" "The new value of Avalon Base Address is $new_base_address_list"
		if {[string equal [get_parameter_value "Avalon Base Address"] ${new_base_address_list} ] == 1} {

		} else {
			set_parameter_value "Avalon Base Address" ${new_base_address_list}
		}
		
		
	}
	
}

proc set_bar_parameters { } {
	set num_bars 6
	for { set i 0 } { $i < $num_bars } { incr i } {

         	if {( $i==1 ||$i==3 || $i ==5) && ([is64bitBar [expr $i-1] ] == 1)} {
        	 	#These bars are not used
    
                	if {[expr [get_parameter_value "CB_P2A_AVALON_ADDR_B${i}"]] != 0} {
                		set_parameter_value "CB_P2A_AVALON_ADDR_B${i}" 0
                	}
                	if {[get_parameter_value "bar${i}_size_mask"] != 0} {
                		set_parameter_value "bar${i}_size_mask" 0
                	}	
        	} else {   
             		if {[isBarUsed $i ] == 1} {
        
                            	if { ([is64bitBar $i] == 1)} {
                            	    if { ([string equal [get_parameter_value "bar${i}_64bit_mem_space"] "true" ] != 1)} {
            				set_parameter_value "bar${i}_64bit_mem_space"  true
            				}
            
                            	} else {
                            		set_parameter_value "bar${i}_64bit_mem_space"  false
                            	}
                            
                            	if { [isBarPrefetchable $i] == 1 } {
                            		if { ([string equal [get_parameter_value "bar${i}_prefetchable"] "true" ] != 1) } {
            					set_parameter_value "bar${i}_prefetchable"  true
            				}
                            	} else {
                            		set_parameter_value "bar${i}_prefetchable"  false
                            	}
            	
            
                        } else {
                                if { ([string equal [get_parameter_value "bar${i}_64bit_mem_space"] "true" ] == 1)} {
                                	set_parameter_value "bar${i}_64bit_mem_space"  false
                                }
                                
                                if {  ([string equal [get_parameter_value "bar${i}_prefetchable"] "true" ] == 1)} {
                                	set_parameter_value "bar${i}_prefetchable"  false
                                }
                                if {[expr [get_parameter_value "CB_P2A_AVALON_ADDR_B${i}"]] != 0} {
                                 	set_parameter_value "CB_P2A_AVALON_ADDR_B${i}" 0
                                }
                                if {[get_parameter_value "bar${i}_size_mask"] != 0} {
                                 	set_parameter_value "bar${i}_size_mask" 0
                                }
                        }
        	
        
            	} 

    }

}

proc set_system_setting_parameters { } {

	 set my_gen2_lane_rate_mode [ get_parameter_value my_gen2_lane_rate_mode ]
	 set gen2_lane_rate_mode [ get_parameter_value gen2_lane_rate_mode ]
	 set max_link_width [ get_parameter_value max_link_width ]
	 set p_pcie_hip_type [ get_parameter_value p_pcie_hip_type ]
	 set p_pcie_app_clk [ get_parameter_value p_pcie_app_clk ]
	 
	  if { [ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0 && $max_link_width == 1} {    # Gen2X1
	  	set_parameter_value core_clk_divider 4
	 	set_parameter_value gen2_lane_rate_mode true
	 	set_parameter_value lane_mask 254
	 	set_parameter_value single_rx_detect 1
	 	set_parameter_value enable_ch0_pclk_out true
	 	set_parameter_value millisecond_cycle_count "125000"
	 	set_parameter_value core_clk_freq 1250
	 	
	     }
	     
	  if { [ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0 && $max_link_width == 4} {  # Gen2X4
	  	set_parameter_value core_clk_divider 2       
                set_parameter_value gen2_lane_rate_mode true 
                set_parameter_value lane_mask 240
                set_parameter_value single_rx_detect 4
                set_parameter_value enable_ch0_pclk_out false
                set_parameter_value millisecond_cycle_count "250000"
                set_parameter_value core_clk_freq 2500
	     }
	 
	 
	  if { [ string compare -nocase $my_gen2_lane_rate_mode "false" ] == 0 && $max_link_width == 1} {  # Gen1X1
	      if {$p_pcie_app_clk == 0} {
	  	set_parameter_value core_clk_divider 2  
	  	set_parameter_value core_clk_freq 1250
	} else {
		set_parameter_value core_clk_divider 4 
		set_parameter_value core_clk_freq 625
	}     
                set_parameter_value gen2_lane_rate_mode false
                set_parameter_value lane_mask 254
                set_parameter_value single_rx_detect 1
                set_parameter_value enable_ch0_pclk_out true
                set_parameter_value millisecond_cycle_count "125000"
	     }
	     
	    if { [ string compare -nocase $my_gen2_lane_rate_mode "false" ] == 0 && $max_link_width == 4} {  # Gen1X4
	    	set_parameter_value core_clk_divider 2       
                set_parameter_value gen2_lane_rate_mode false
                set_parameter_value lane_mask 240
                set_parameter_value single_rx_detect 4
                set_parameter_value enable_ch0_pclk_out false
                set_parameter_value millisecond_cycle_count "125000"
                set_parameter_value core_clk_freq 1250
	     }
	     
	   if { [ string compare -nocase $my_gen2_lane_rate_mode "false" ] == 0 && $max_link_width == 8} {  # Gen1X8
	   	set_parameter_value core_clk_divider 1   
                set_parameter_value gen2_lane_rate_mode false
                set_parameter_value lane_mask 0
                set_parameter_value single_rx_detect 0
                set_parameter_value millisecond_cycle_count "250000"
                set_parameter_value core_clk_freq 2500
	     }
	 
	 if { $max_link_width == 2 } {                                                                  # Gen1X2
	 	set_parameter_value core_clk_divider 2 
	 	set_parameter_value lane_mask 252
	 	set_parameter_value single_rx_detect 2
	 	set_parameter_value enable_ch0_pclk_out false
	 	set_parameter_value millisecond_cycle_count "125000"
	 	set_parameter_value core_clk_freq 1250
	 }
	 
	  if {$p_pcie_hip_type == 0 || $p_pcie_hip_type == 4} {	      #"S4GX PHY" 	  	
	  	set_parameter_value core_clk_source "PLL_FIXED_CLK"
	   } else {
	         set_parameter_value core_clk_source "pclk"
	}
	 
	 
	 
	 set_parameter_value enable_gen2_core $gen2_lane_rate_mode
	 
	 		 
	    
	  if {$p_pcie_hip_type == 0} {	      #"S4GX PHY" 	  	
	  	set_parameter_value retry_buffer_last_active_address 2047	    	
	  } elseif {$p_pcie_hip_type == 4} {  #"A2GX PHY" 	  	  	
	  	set_parameter_value retry_buffer_last_active_address 255
	  } elseif {$p_pcie_hip_type == 1} {  #"A2GX PHY" 	  	  	
	  	set_parameter_value retry_buffer_last_active_address 255	   
	  } elseif {$p_pcie_hip_type == 2} {  #"C4GX PHY" 	  	  	
	  	set_parameter_value retry_buffer_last_active_address 255	   
	  } elseif {$p_pcie_hip_type == 3} {  #"H4GX PHY" 	  	  	
	  	set_parameter_value retry_buffer_last_active_address 2047
	  }
}

proc validate_pcie_hip {} {
    
  	# Collect parameter values into local variables
	foreach var [ get_parameters ] {
	  set $var [ get_parameter_value $var ]
	 }

	 set_parameter_value CG_AVALON_S_ADDR_WIDTH [calculate_avalon_s_address_width $CB_A2P_ADDR_MAP_NUM_ENTRIES $CB_A2P_ADDR_MAP_PASS_THRU_BITS]
	 set my_avalon_s_addr_width $CG_AVALON_S_ADDR_WIDTH
	 
	 if { $my_avalon_s_addr_width > 32 } {
	 	send_message "error" "Invalid combination of Txs Address size and pages resulting Txs Slave Address of greater than 32 bits."
	 }
	 
	 send_message "info" " Txs Address width is $my_avalon_s_addr_width"
	 
	 ########################### System Settings #############################################\\
	 
	 		 
	 #set_parameter_property "p_pcie_hip_type" ALLOWED_RANGES {"1:Arria II GX" "2:Cyclone IV GX" "0:Stratix IV GX" "3:HardCopy IV GX"}
    
	
	 if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Stratix IV"] == 0 } {
		set_parameter_value p_pcie_hip_type 0
		} elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Arria II GZ"] == 0} {
		set_parameter_value p_pcie_hip_type 4
		} elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "HardCopy IV"] == 0} {
		set_parameter_value p_pcie_hip_type 3
		} elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Arria II GX"] == 0} {
		set_parameter_value p_pcie_hip_type 1
		} elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] == 0} {
		set_parameter_value p_pcie_hip_type 2
     	} 
	 		 
	set_system_setting_parameters
	 
	 
	if {([ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0)} {
		if {$p_pcie_version ==1.1} {
			send_message "error" "Gen2 only supports PCI Express version 2.0"
		}
		if {[string equal -nocase $p_pcie_txrx_clock "100 MHz"] == 0} {
			send_message "error" "Gen2 only supports a 100 MHz reference clock."
		}
	 }
	 
	 #### 2. Validate    
	  if {$p_pcie_hip_type == 0 || $p_pcie_hip_type == 4} {	      #"S4GX PHY" 
	  	if {$max_link_width == 2} {
	  	 	send_message "error" "Stratix IV GX and Arria II GZ Phy do not support x2" 
	  	}
	  	 
	  	if { ($max_link_width == 8) && ( [ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0 ) } {
			send_message "error" "Stratix IV GX and Arria II GZ Phy do not support Gen2 x8"
	  	}
		if { [ string equal -nocase $p_pcie_target_performance_preset "Maximum" ] == 0 } {
			send_message "error" "Stratix IV GX and Arria II GZ do not support a non-maximum RX buffer credit allocation"
		}
	    	
	  } elseif {$p_pcie_hip_type == 1} {  #"A2GX PHY" 
	  
	  	if {$max_link_width == 2} {
	  	  	 send_message "error" "Arria II GX Phy does not support x2" 
	  	}
	  	
	  	if { [ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0 } {
			send_message "error" "Arria II GX Phy does not support Gen2"
	  	}
		if { [ string equal -nocase $p_pcie_target_performance_preset "Maximum" ] == 0 } {
			send_message "error" "Arria II GX does not support a non-maximum RX buffer credit allocation"
		}	
	   
	  } elseif {$p_pcie_hip_type == 2} {  #"C4GX PHY" 
	  
	  	if { [ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0 } {
	  		send_message "error" "Cyclove IV GX Phy does not support Gen2"
	  	}
		
	   
	  } elseif {$p_pcie_hip_type == 3} {  #"H4GX PHY" 
	  
	  	if {$max_link_width == 2} {
	  	  	  send_message "error" "HardCopy IV GX Phy does not support x2" 
	  	}
	  } 
	  
	  if {$p_pcie_app_clk == 1} {
	    if { $max_link_width != 1 || $p_pcie_hip_type != 2 } {
	       	  send_message "error" "Application clock can only be set to 62.5Mhz for Gen1 x1 in Cyclone IV GX device family"
	       }
	   }
	   
	 if {$p_pcie_hip_type != 0 && $p_pcie_hip_type != 4} {  # Not Stratix IV
	 	if { $max_link_width == 8 } {
	           send_message "error" " Selected device family does not support X8 " 
	        }
	    }
	    
	 if { ($max_link_width == 4) && ( [ string compare -nocase $my_gen2_lane_rate_mode "true" ] == 0 ) } {
			send_message "info" "Application clock frequency is 250 Mhz "
	  	} elseif { ($max_link_width == 8) && ( [ string compare -nocase $my_gen2_lane_rate_mode "false" ] == 0 ) } {
	                send_message "info" "Application clock frequency is 250 Mhz "
	        } elseif {$p_pcie_app_clk == 1} {
	                send_message "info" "Application clock frequency is 62.5 Mhz "  
	        } else {
	        	 send_message "info" "Application clock frequency is 125 Mhz " 
	        }     	
	 

	 ########################### PCI Registers ################################################	 	 
	 validate_bars
	 set_bar_parameters
	 update_bar_table
	 
	 ########################### Capabilities ##################################################
	 if {([ string compare -nocase $my_advanced_errors "true" ] == 0)} {
	 	set_parameter_value advanced_errors "true"
	 } else {
	 	set_parameter_value advanced_errors "false"
	 }
	 
	 if {([ string compare -nocase $my_enable_ecrc_check "true" ] == 0)} {
		set_parameter_value enable_ecrc_check "true"
	 } else {
		set_parameter_value enable_ecrc_check "false"
	 }
	 
	 if {([ string compare -nocase $my_enable_ecrc_gen "true" ] == 0)} {
		set_parameter_value enable_ecrc_gen "true"
	 } else {
		set_parameter_value enable_ecrc_gen "false"
	 }
	 
	 
	 ########################### Buffer Settings #################################################
	 set_buffer_settings $p_pcie_target_performance_preset $max_payload_size  $max_link_width
	
	 ####  Set derived parameters 
	 set rx_buf [ expr [get_parameter_value vc0_rx_flow_ctrl_nonposted_header]+[get_parameter_value vc0_rx_flow_ctrl_posted_header]+[get_parameter_value vc0_rx_flow_ctrl_posted_data]+[get_parameter_value vc0_rx_flow_ctrl_compl_header]+[get_parameter_value vc0_rx_flow_ctrl_compl_data] ]
	 set RX_BUF  [ log 2 [expr {$rx_buf*16} ] ] 
	 set_parameter_value RX_BUF  [expr $RX_BUF-3 ]
	 #send_message "error" "RX_BUF is [get_parameter_value RX_BUF]"
	 
	 set rh_num [ expr [get_parameter_value vc0_rx_flow_ctrl_nonposted_header]+[get_parameter_value vc0_rx_flow_ctrl_posted_header]+[get_parameter_value vc0_rx_flow_ctrl_compl_header]]
	 set RH_NUM [ log2ceil $rh_num ]
	 set_parameter_value RH_NUM  [expr $RH_NUM ]
	 
	 
	 
	 ########################### Avalon ######################################################
	 
	 if { $CB_A2P_ADDR_MAP_IS_FIXED == 0  } {
		 if { $CB_A2P_ADDR_MAP_NUM_ENTRIES ==1 } { 
			send_message "error" "Number of address pages has to be more than 1 for Dynamic translation table configuration"
}

		 if { $CG_IMPL_CRA_AV_SLAVE_PORT == 0 } {

			send_message "error" "\"Control Register Access (CRA) Avalon slave port\" is required for \"Dynamic translation table\""
		}

	 } else { #Fixed address translation
	 	if { $CB_A2P_ADDR_MAP_NUM_ENTRIES > 16 } { 
	 		send_message "error" "Number of address pages cannot be more than 16 for Fixed translation table configuration"
	 	}
	 }
	 	 
	 set ADDRESS_PAGE_SIZE_LIST " "
	 for { set i 12 } { $i <= [expr {32 - [log2ceil $CB_A2P_ADDR_MAP_NUM_ENTRIES]}]  } { incr i } { 
		lappend ADDRESS_PAGE_SIZE_LIST ${i}
	 }

	 #send_message "error" "CB_A2P_ADDR_MAP_PASS_THRU_BITS is $CB_A2P_ADDR_MAP_PASS_THRU_BITS" 
	# if { [lsearch $ADDRESS_PAGE_SIZE_LIST $CB_A2P_ADDR_MAP_PASS_THRU_BITS] == -1 } {
	# 	
	#	send_message "error" "The legal values for \"Size of address pages\" are $ADDRESS_PAGE_SIZE_LIST"
	# }
	
	
	 #RXM_DATA_WIDTH  --- set to 32 in Lite mode, else 64
	 #RXM_BEN_WIDTH    --- set to 4 in Lite mode , else 8
	 
	
	 
	 #Avalon mm lite mode support
	 set    NEW_RXM_ENABLE 1
	 if  {$NEW_RXM_ENABLE == 1} {
	 
	 if { $CB_PCIE_RX_LITE == 1} {
	 	set_parameter_value bypass_tl false
	 	  #send_message "error" "CG_IMPL_CRA_AV_SLAVE_PORT is $CG_IMPL_CRA_AV_SLAVE_PORT"
	 	if { $CG_IMPL_CRA_AV_SLAVE_PORT == 1 && $CB_PCIE_MODE == 1} {

			send_message "error" "\"Control Register Access (CRA) Avalon slave port\" is not available in \"Completer-Only single dword mode\""
		}
		set_parameter_value credit_buffer_allocation_aux "BALANCED"		
		set_parameter_value RXM_DATA_WIDTH 32
		set_parameter_value RXM_BEN_WIDTH 4
	
	 } else {
	 	set_parameter_value credit_buffer_allocation_aux "BALANCED"
	 	set_parameter_value RXM_DATA_WIDTH 64
	 	set_parameter_value RXM_BEN_WIDTH 8
	 	set_parameter_value bypass_tl false
	 }
	   } else {
	   	
	   	
	   	if { $CB_PCIE_MODE == 2} {
	 	set_parameter_value AST_LITE  1
	 	set_parameter_value bypass_tl false
	 	  #send_message "error" "CG_IMPL_CRA_AV_SLAVE_PORT is $CG_IMPL_CRA_AV_SLAVE_PORT"
	 	if { $CG_IMPL_CRA_AV_SLAVE_PORT == 1 } {

			send_message "error" "\"Control Register Access (CRA) Avalon slave port\" is not available in \"Completer-Only single dword mode\""
		}
		set_parameter_value credit_buffer_allocation_aux "BALANCED"		
		set_parameter_value RXM_DATA_WIDTH 32
		set_parameter_value RXM_BEN_WIDTH 4
	
	 } else {
	 	set_parameter_value AST_LITE  2
	 	set_parameter_value credit_buffer_allocation_aux "BALANCED"
	 	set_parameter_value RXM_DATA_WIDTH 64
	 	set_parameter_value RXM_BEN_WIDTH 8
	 	set_parameter_value bypass_tl false
	 }
	   	
	   	
	  }
	 
	 
	 #Polulate the translation table
if { $CB_A2P_ADDR_MAP_IS_FIXED == 1  } {
 	 set_a2p_address_map
 	 update_a2p_address_map_table
    }

 	 ## Validate the A2P table entries


if { $CB_A2P_ADDR_MAP_IS_FIXED == 1  } { 	 
 	 
 	 for { set i 0 } { $i < $CB_A2P_ADDR_MAP_NUM_ENTRIES } { incr i } {
	 	
		set high_list [split [ get_parameter_value "PCIe Address 63:32" ] ","]
		set low_list [split [ get_parameter_value "PCIe Address 31:0" ] ","]

		#validate the LOW bits
		set low [lindex $low_list $i] 		
		if { [string match {0[xX]*} $low] != 0} {
			set low [string range $low 2 end ]
		}
		#send_message "error" "low is $low"

		if { ![string is xdigit $low] } {		
		   send_message "error" "PCIe Base Address $i : Please enter valid hexadecimal number ( \"Low\": $low is invalid )"
		} elseif { [string length $low] != 8 } {		
		   send_message "error" "PCIe Base Address $i : Please enter 32 bit hexadecimal number ( \"Low\": $low is invalid )"		
		} else {

			##Code taken out
		}
		
		#validate the HIGH bits
		set high [lindex $high_list $i] 		
		if { [string match {0[xX]*} $high] != 0} {
			set high [string range $high 2 end ]
		}
		#send_message "error" "high is $high"

		if { ![string is xdigit $high] } {		
		   send_message "error" "PCIe Base Address $i : Please enter valid hexadecimal number ( \"High\": $high is invalid )"
		} elseif { [string length $high] != 8 } {		
		   send_message "error" "PCIe Base Address $i : Please enter 32 bit hexadecimal number ( \"High\": $high is invalid )"		
		} else {

			##Code taken out
		}
	}
	
 }
	 enable_disable_controls
}

