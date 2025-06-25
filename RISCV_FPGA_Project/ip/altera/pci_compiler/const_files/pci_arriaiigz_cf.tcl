# Arria II GZ Constraint file.

# PCI_CF_Device_Family = Arria II GZ
# PCI_CF_Bus_Speed = 33.33MHz, 66.67 MHz 
# PCI_CF_Core_Support = MT64, T64, MT32, T32
# PCI_CF_Revision_No = 8.0	
# PCI_CF_Date_Of_Creation (MM/DD/YY)= 11/16/07
# PCI_Quartus_Version = Quartus II 8.0 or higher
# PCI_Compiler_Version = 8.0 or higher

# PCI constraint file support
# Under Testing

# To use the the constraint file,
#   #source <constraint filename>.tcl
#   #add_pci_constraints [-speed 33 | 66] [-no_compile] [-no_pinouts] [-pin_prefix <pin_prefix_name>] [-pin_suffix <pin_suffix_name>] [-help]  
# For more information on constraint file usage, please refer to Appendix A of PCI Compiler 4.0.0 User Guide and PCI Compiler 4.0.0 Read Me File.

package require ::quartus::project
package require ::quartus::flow
package require ::quartus::report
package require ::quartus::device 1.0
package require ::quartus::logiclock 1.0

#****************************************************************************************************
# This procedure should be hand edited only when 
#  1. You are upgrading your project to use new version of PCI Compiler or Quartus II software
#  2. You have changed the PCI Pin names from the default Pin names

# This procedure maps Altera defined PCI pin names to user defined PCI pin names

# Change the PCI pin names specific to your project under the "Change" header.
# For example, if you project uses "pci_ad" for "ad" bus where "ad" is the default Altera provided 
# PCI pin name and "pci_ad" is the user defined PCI pin name, the change made should be as following:

#       array set map_user_pin_name_to_internal_pin_name { ad                           pci_ad  }
#                                                          |                              |
#                                                          |                              |
#                                                          |                              |
#                                                          v                              v
#                                                       Altera default                  User defined 
#                                                       pin names                       pin names

# This script will delete all the old PCI assignments based on this new user defined pin names

# Note: It will still add new PCI pin assignments using the Altera Provided default PCI pin names.
# After you have run the script, you have to edit your project Quartus Setting File (.QSF) to match 
# the user defined PCI pin names

#****************************************************************************************************
if ![info exist SHARED_CLK] {
set pin_planner_group pci_compiler
set SHARED_CLK no
set SHARED_CLK_NAME clk

proc get_user_pin_name { internal_pin_name } {
	
	
	#---------------- Do NOT change -------------------------------      ---- Change -----
		array set map_user_pin_name_to_internal_pin_name { ad                   ad                              }
		array set map_user_pin_name_to_internal_pin_name { cben                 cben                            }
		
	#---------------- Do NOT change -------------------------------      ---- Change -----
		array set map_user_pin_name_to_internal_pin_name { clk                  clk                             }
		array set map_user_pin_name_to_internal_pin_name { rstn                 rstn                            }
		array set map_user_pin_name_to_internal_pin_name { idsel                idsel                           }
		array set map_user_pin_name_to_internal_pin_name { framen               framen                          }
		array set map_user_pin_name_to_internal_pin_name { irdyn                irdyn                           }
		array set map_user_pin_name_to_internal_pin_name { trdyn                trdyn                           }
		array set map_user_pin_name_to_internal_pin_name { devseln              devseln                         }
		array set map_user_pin_name_to_internal_pin_name { stopn                stopn                           }
		array set map_user_pin_name_to_internal_pin_name { intan                intan                           }
		array set map_user_pin_name_to_internal_pin_name { par                  par                             }
		array set map_user_pin_name_to_internal_pin_name { perrn                perrn                           }
		array set map_user_pin_name_to_internal_pin_name { serrn                serrn                           }
		
	#---------------- Do NOT change -------------------------------     ---- Change -----
		array set map_user_pin_name_to_internal_pin_name { reqn                 reqn                            }
		array set map_user_pin_name_to_internal_pin_name { gntn                 gntn                            }
		
	#---------------- Do NOT change -------------------------------     ---- Change -----
		array set map_user_pin_name_to_internal_pin_name { ack64n               ack64n                          }
		array set map_user_pin_name_to_internal_pin_name { par64                par64                        	}
		array set map_user_pin_name_to_internal_pin_name { req64n               req64n                          }
		# ********************** Please do not modify anything beyond this line ****************************
		# *********** The script might not work correctly if the following lines are modified **************
	 
	# Shared clock renaming
	global SHARED_CLK SHARED_CLK_NAME
	if {$SHARED_CLK} {
	   array set map_user_pin_name_to_internal_pin_name  " clk $SHARED_CLK_NAME  "
	}
	
	return [lindex [array get map_user_pin_name_to_internal_pin_name  [escape_name $internal_pin_name]] 1]
}
} 


#*****************
# Main procedure 
#*****************
proc add_pci_constraints {args} {
		
	set speed "66"
	set no_compile "0"
	set no_pins "0" 
	set got_prefix "0" 
	set got_suffix "0"              
	set prefix "0" 
	set suffix "0" 
	global CRITICAL_WARNING
	set CRITICAL_WARNING "0"
	
	# Check if project is open
	if { ![is_project_open] } {
			error "Error: No project open, prior to running this script you have to open your project in Quartus II sofware"
	}
	
	# Detect parameter passed 
	set state 0     
	foreach arg $args {
			switch -- $state {
			0 { 
				switch -exact -- $arg {
					-speed { set state 1 }
					-no_compile { set no_compile "1" ; set state 0 }
					-no_pinouts { set no_pins "1" ; set state 0 }
					-pin_prefix { set state 2 }
					-pin_suffix { set state 3 } 
					-help { 
						puts "The add_pci_constraints command adds PCI constraints to your project.\n"
						puts "Usage"
						puts "\t add_pci_constraints \[-speed 66 | 33 \] \[-no_compile\] \[-no_pinouts\] \[-pin_prefix <pin_prefix_name>\] \[-pin_suffix <pin_suffix_name>\] \[-help\]\n"
						puts "Optional Arguments"
						puts "\t -speed      \t Specify the PCI bus speed. Use this option to override the default PCI bus speed "
						puts "\t             \t supported by the targeted device family. A default speed of 33 MHz can not be overridden.\n"     
															
						puts "\t -no_compile \t Use this option to omit analysis and synthesis.  "
						puts "\t             \t By default, the add_pci_constraints command performs Analysis and Synthesis "
						puts "\t             \t to determine the hierarchy of the PCI MegaCore function. "
						puts "\t             \t This option should be used only if you have already performed Analysis and Synthesis.\n"  
									   
						puts "\t -no_pinouts \t Use this option to omit making Altera-recommended PCI pin location assignments. \n"                 		
							  
						 puts "\t -pin_prefix \t Use this option to define your custom pin name prefix." 
						 puts "\t 			 \t This command argument can be used in the following two scenarios:"
						puts "\t 			 \t Case 1: Adding prefix to the PCI pin names in your project."
						puts "\t 			 \t         The command below will add \"pci\" prefix to all the PCI pin names."
						puts "\t 			 \t 	    	> add_pci_constraints -pin_prefix pci \n"
						
						puts "\t 			 \t Case 2: Upgrading from previous version of PCI Compiler."
						puts "\t 			 \t         If you have exiting PCI assignments in your project that has custom prefix"
						puts "\t			 \t         for all the PCI pin names, you can use the following command argument to"
						puts "\t			 \t         upgrade the assignments to new version of PCI Compiler."
						puts "\t 			 \t 	    	> add_pci_constraints -pin_prefix pci \n"
						
						puts "\t -pin_suffix \t Use this option to define your custom pin name suffix.  "
						 puts "\t 			 \t This command argument can be used in the following two scenarios:"
						puts "\t 			 \t Case 1: Adding suffix to the PCI pin names in your project."
						puts "\t 			 \t         The command below will add \"pci\" suffix to all the PCI pin names."
						puts "\t 			 \t 	    	> add_pci_constraints -pin_suffix pci \n"
						
						puts "\t 			 \t Case 2: Upgrading from previous version of PCI Compiler."
						puts "\t 			 \t         If you have exiting PCI assignments in your project that has custom suffix"
						puts "\t			 \t         for all the PCI pin names, you can use the following command argument to"
						puts "\t			 \t         upgrade the assignments to new version of PCI Compiler."
						puts "\t 			 \t 	    	> add_pci_constraints -pin_suffix pci \n"
						
						 puts "\t -help       \t Use this option to print this help text. \n"  
						 
						 puts ""
						 puts "Example Usage"
						puts "\t add_pci_constraints  �no_compile "
						puts "\t The above command adds the PCI constraints for the default PCI bus speed "
						puts "\t supported by the targeted device family, and does not perform Analysis and Synthesis."   
						puts ""
						puts "\t Add_pci_constraints �pin_prefix pci_ �speed 33"
						puts "\t The above command adds the PCI constraints for PCI 33 MHz speed and adds prefix pci_ to all the PCI pin names"
																					  
						error ""                                 
						 }
					default { 
							error "Error: You have entered the wrong command syntax." 
					} 
				} 
			}               
			1 {
			   if {!($arg==33 || $arg==66)} {
						puts "Error: PCI bus speed must be either 33 MHz or 66 MHz."
						puts "       Use \"add_pci_constraints -help\" to view long help on constraint file usage."
						error ""
				} else {
						set speed $arg
				}
				set state 0                         
			}   
			2 {
				set got_prefix "1"
				set prefix $arg
				 set state 0   
			}
			3 {
				set got_suffix "1"
				  set suffix $arg
				 set state 0   
			}
			
			default { 
				puts "Error: You have entered the wrong command syntax."
				puts "       Use \"add_pci_constraints -help\" to view long help on constraint file usage."
				error ""
			}       
			}
	} 
	
	# Check Quartus II Version
	#check_quartus_version 

	# Find device, hierarchy and core information
	puts ""
	puts "Info: Extracting PCI Core Type, PCI Bus Speed, Device and PCI MegaCore Hierarchy"
	export_assignments
	
	set device [get_global_assignment -name DEVICE]
	set pci_info [find_pci_info $no_compile]
	set core [lindex $pci_info 0]
	set core_lower [string tolower $core]
	set hierarchy [lindex $pci_info 1]      
	set full_64 [lindex $pci_info 2]
	set master [lindex $pci_info 3]      

	puts "Info: **************************************************"
	puts "Info: PCI Core Type: pci_$core_lower"
	puts "Info: Device: $device"
	puts "Info: PCI MegaCore Hierarchy: $hierarchy"
	puts "Info: **************************************************"
	
	# Sanity checks on core, device and PCI bus speed
	sanity_checks $speed $device $core 
	
	# Set pin_list variable based on the PCI core
	set pin_list [get_pin_list $full_64 $master $got_prefix $got_suffix $prefix $suffix]
	set current_project_dir [get_project_directory]
	
	# Reading previous pins list
	set fl [open $current_project_dir/pci_pin.pci a+]
	set fl [open $current_project_dir/pci_pin.pci]
	set data [read $fl]
	close $fl
	set previous_pins [split $data \n]
	# Removing old PCI constraints
	set pci_check [run_check]
	if {$pci_check} {
		run_pin_names_check $previous_pins
		create_bk
		puts "Info: Removing old PCI constraints"
	set_qsf_mode -start
		remove_old_pci_asgn $previous_pins $no_pins $got_prefix $got_suffix $prefix $suffix
	set_qsf_mode -end
	}
   
	# Rewriting with new pin information on file
	# Writing after removal so that if crash while deleting, old information is still on file
	set pin_current_file [open "$current_project_dir/pci_pin.pci" w+]
	foreach current_pin_list $pin_list {
	puts $pin_current_file "$current_pin_list"  
	}
	close $pin_current_file 
 
	# Set PCI timing requirements variable
	if { $speed == 33} {
		set pci_timing [list "30" "7.0ns" "10.0ns" "0.0ns" "11.0ns" "28.0ns"] 
	} elseif {$speed == 66 } {
		set pci_timing [list "15" "3.0ns" "5.0ns" "0.0ns" "6.0ns" "14.0ns"] 
	} else {
		error "Error: PCI speed must be either 33 MHz or 66 MHz \n"
	}
	
	# Add new PCI assignments
	puts "Info: Adding PCI constraints to your project"     
	set_qsf_mode -start
	constraint_file $device $core $full_64 $hierarchy $master $pin_list $speed $pci_timing $no_pins $got_prefix $got_suffix $prefix $suffix
	set_qsf_mode -end

	puts "Info: PCI constraints successfully added to your project"
	puts "Info: **************************************************"
	
		generate_pci_sdc $pin_list $pci_timing $master $hierarchy $core $core_lower $full_64

	#Check if Critical Warning exists
	check_critical_warnings
	
}

#***********************
# Check Quartus Version           
#***********************
proc check_quartus_version {} {
		
	global quartus
	set quartus_version "$quartus(version)"
	
        set version_no [regexp {Version ([0-9]*[0-9].[0-9]) } $quartus_version match q_ver ]

	if {($q_ver >= 4.0)} {
	} else {
			error "Error: You must use Quartus II v4.0 or higher to run this script"
	}
}

#*****************************************
# Find PCI core and hierarchy information
#*****************************************
proc find_pci_info { no_compile } {
	global pin_planner_group 
	global env
	
	set hierarchy ""
	set core ""
	
	# 0 is sucess
	# 1 is fail
	set report_status 0

	if {$no_compile == "1"} {
		if {[catch {load_report} err_msg]} {
			puts "Error: Not able to load Compilation Report to search for hierarchy string"
			puts "       Script needs to run Analysis and Synthesis to get the PCI core hierarchy."
			puts "       Run this script without -no_compile argument"
			error ""
		}
	} else {
		puts "Info: Performing Analysis and Synthesis. This may take several minutes; please wait."
		execute_module -tool map    
	}

	if {[catch {load_report} err_msg]} {    
			error "Error: Analysis and Synthesis was unsuccessful."
	}   

	#Fetch the status of INCREMENTAL COMPILATION
	set inc_comp_stat [get_global_assignment -name INCREMENTAL_COMPILATION]
	
	# Setting incremental compilation with Design Partiotion 
	# architecture changes the hierarchy reporting
	if { [string match $inc_comp_stat "OFF"]} {
	   set resource_panel_name "Analysis & Synthesis Resource Utilization by Entity"
	} else {
		set design_partition_on "0"
		foreach panel_name [get_report_panel_names] {
		   if { [regexp ".*pci.*Utilization by Entity" $panel_name] } {
			  set resource_panel_name ".*pci.*Utilization by Entity"
			  set design_partition_on "1" 
			  break
		   } elseif { [regexp ".*IP_PARTITION.*Utilization by Entity" $panel_name] } {
			  set resource_panel_name ".*IP_PARTITION.*Utilization by Entity"
			  set design_partition_on "1"
		   }
		}
		if { $design_partition_on == "0" } {
			set resource_panel_name "Utilization by Entity"		
		}
	}
			 
	foreach panel_name [get_report_panel_names] {
	   if { [regexp $resource_panel_name $panel_name] } {
			set match 0
			set pci_entity ""
			
			for {set row 2} { $row < [get_number_of_rows $panel_name]} { incr row } {       
				set whole_row [get_report_panel_row "$panel_name" -row $row]
				set entity_name [lindex $whole_row 0]   
				set match_pci [regexp {.*\|(pci[a-zA-Z0-9]+_t:trg)\|} $entity_name temp]        
										
				if { $match_pci } {
					set pci_entity [string trim $entity_name]       
					set pci_entity [string trim $pci_entity "|"]    
					set prev_spaces [string first "|" $entity_name] 
					break
				}
			}
			
			if { $match_pci } {
				set matched_row $row
				
				for {set row $matched_row} { $row > 0 } { set row [expr $row - 1] } {
					set whole_row [get_report_panel_row "$panel_name" -row $row]
					set entity_name [lindex $whole_row 0]
					set spaces [string first "|" $entity_name]
					set entity_name [string trim $entity_name]
					
					if { $spaces < $prev_spaces } {
						set hierarchy "[string trim $entity_name "|"]|$hierarchy"
						set prev_spaces $spaces
					}       
				}
				
				set hierarchy "$hierarchy$pci_entity"           
				set hierarchy [split $hierarchy |]
				set a [expr [llength $hierarchy] - 2]
				
				# Get core information
				set core [lindex $hierarchy [expr [llength $hierarchy] -1]]
				set core [regexp {pci([mt]+[3264]+).*} $core temp line]
				set core [string toupper $line]
		
				# Get hierarchy information
				set hierarchy [join [lreplace [lrange $hierarchy 0 $a] 0 0] |]
				break
			} else {
				puts "Error: Script was not able to find the PCI core instance."
				puts "       Ensure that you have instantiated the"
				puts "       PCI MegaCore function in your top level design."
				error ""
			}
		}
	}
	
	if { $hierarchy == "" } {
	   puts "Error :   The system hierarchy is not properly populated." 
	   puts "Error :   Please re-source the constraints and run add_pci_constraints without the \"-no_compile\" extension"
	   error ""
	}

	# Determine core characteristic
	if {$core=="MT64"} {
		set full_64 1 ; set master 1
	} elseif {$core=="MT32"} {
		set full_64 0 ; set master 1
	} elseif {$core=="T64"} {
		set full_64 1 ; set master 0
	} elseif {$core=="T32"} {
		set full_64 0 ; set master 0
	} else {
		puts "Error: Unrecognized core type $core "
		puts "       Script is not able to extract the PCI core type you instantiated."
		puts "       Ensure that you have instantiated the PCI MegaCore function in your top level design."
		error ""
	}       
			
	# Return core & hierarchy information
	lappend pci_info $core
	lappend pci_info $hierarchy
	lappend pci_info $full_64
	lappend pci_info $master
	
	unload_report
	return $pci_info        
}
		
#*************************************************
# Variable "pin_list" lists down all the PCI signal 
# names based on Altera's naming convention
#*************************************************
proc get_pin_list { full_64 master got_prefix got_suffix prefix suffix } {
global SHARED_CLK
if ![info exist SHARED_CLK] {
		puts "\n*************************************"
		puts "Please Re-source the constraints file"
		error "*************************************"
}

	if { $got_prefix == "1" && $got_suffix == "0" } {
		if {$SHARED_CLK} {
		   lappend pin_list  [get_user_pin_name clk]
		} else { 
		   lappend pin_list [join [list $prefix [get_user_pin_name clk]] ""]
		}
		lappend pin_list [join [list $prefix rstn] ""]
		lappend pin_list [join [list $prefix devseln] ""]	        	        
		lappend pin_list [join [list $prefix framen] ""]
		lappend pin_list [join [list $prefix idsel] ""]	        
		lappend pin_list [join [list $prefix intan] ""]	        
		lappend pin_list [join [list $prefix irdyn] ""]	        
		lappend pin_list [join [list $prefix par] ""]	        
		lappend pin_list [join [list $prefix perrn] ""]	        
		lappend pin_list [join [list $prefix serrn] ""]
		lappend pin_list [join [list $prefix stopn] ""]	        
		lappend pin_list [join [list $prefix trdyn] ""]
		
		set i 0
		while {$i<32} {
			lappend pin_list [join [list $prefix "ad\[$i\]"] ""]
			incr i
		}
		
		set i 0
		while {$i<4} {
			lappend pin_list [join [list $prefix "cben\[$i\]"] ""]
			incr i
		}
		
		if {$full_64} {
			set i 32
			while {$i<64} {
				lappend pin_list [join [list $prefix "ad\[$i\]"] ""]
				incr i
			}
			set i 4
			while {$i<8} {
				lappend pin_list [join [list $prefix "cben\[$i\]"] ""]
				incr i
			}
			
			lappend pin_list [join [list $prefix ack64n] ""]
			lappend pin_list [join [list $prefix par64] ""]	        
			lappend pin_list [join [list $prefix req64n] ""]
		}
			   
		if {$master} {
			lappend pin_list [join [list $prefix reqn] ""]
			lappend pin_list [join [list $prefix gntn] ""]
		}	        
			  
	} elseif { $got_suffix == "1" && $got_prefix == "0" } {
		if {$SHARED_CLK} {
		   lappend pin_list  [get_user_pin_name clk]
		} else { 
		   lappend pin_list [join [list [get_user_pin_name clk] $suffix] ""]
		}
		lappend pin_list [join [list rstn $suffix] ""]
		lappend pin_list [join [list devseln $suffix] ""]	        	        
		lappend pin_list [join [list framen $suffix] ""]
		lappend pin_list [join [list idsel $suffix] ""]	        
		lappend pin_list [join [list intan $suffix] ""]	        
		lappend pin_list [join [list irdyn $suffix] ""]	        
		lappend pin_list [join [list par $suffix] ""]	        
		lappend pin_list [join [list perrn $suffix] ""]	        
		lappend pin_list [join [list serrn $suffix] ""]
		lappend pin_list [join [list stopn $suffix] ""]	        
		lappend pin_list [join [list trdyn $suffix] ""]
		
		set i 0
		while {$i<32} {
			lappend pin_list [join [list ad $suffix \[$i\]] ""]
			incr i
		}
		
		set i 0
		while {$i<4} {
			lappend pin_list [join [list cben $suffix \[$i\]] ""]
			incr i
		}
		
		if {$full_64} {
			set i 32
			while {$i<64} {
				lappend pin_list [join [list ad $suffix \[$i\]] ""]
				incr i
			}
			set i 4
			while {$i<8} {
				lappend pin_list [join [list cben $suffix \[$i\]] ""]
				incr i
			}
			lappend pin_list [join [list ack64n $suffix] ""]
			lappend pin_list [join [list par64 $suffix] ""]	        
			lappend pin_list [join [list req64n $suffix] ""]
		}
					
		if {$master} {
			lappend pin_list [join [list reqn $suffix] ""]
			lappend pin_list [join [list gntn $suffix] ""]
		}	        
	} elseif {$got_suffix == "1" && $got_prefix == "1" } {
		if {$SHARED_CLK} {
		   lappend pin_list  [get_user_pin_name clk]
		} else { 
		   lappend pin_list [join [list $prefix [get_user_pin_name clk] $suffix] ""]
		}
		lappend pin_list [join [list $prefix rstn $suffix] ""]
		lappend pin_list [join [list $prefix devseln $suffix] ""]	        	        
		lappend pin_list [join [list $prefix framen $suffix] ""]
		lappend pin_list [join [list $prefix idsel $suffix] ""]	        
		lappend pin_list [join [list $prefix intan $suffix] ""]	        
		lappend pin_list [join [list $prefix irdyn $suffix] ""]	        
		lappend pin_list [join [list $prefix par $suffix] ""]	        
		lappend pin_list [join [list $prefix perrn $suffix] ""]	        
		lappend pin_list [join [list $prefix serrn $suffix] ""]
		lappend pin_list [join [list $prefix stopn $suffix] ""]	        
		lappend pin_list [join [list $prefix trdyn $suffix] ""]
		
		set i 0
		while {$i<32} {
			lappend pin_list [join [list $prefix ad $suffix "\[$i\]" ] ""]
			incr i
		}
		
		set i 0
		while {$i<4} {
			lappend pin_list [join [list $prefix cben $suffix "\[$i\]" ] ""]
			incr i
		}
		
		if {$full_64} {
			set i 32
			while {$i<64} {
				lappend pin_list [join [list $prefix ad $suffix "\[$i\]" ] ""]
				incr i
			}
			set i 4
			while {$i<8} {
				lappend pin_list [join [list $prefix cben $suffix "\[$i\]" ] ""]
				incr i
			}
			lappend pin_list [join [list $prefix ack64n $suffix] ""]
			lappend pin_list [join [list $prefix par64 $suffix] ""]	        
			lappend pin_list [join [list $prefix req64n $suffix] ""]
		}
					
		if {$master} {
			lappend pin_list [join [list $prefix reqn $suffix] ""]
			lappend pin_list [join [list $prefix gntn $suffix] ""]
		}	       
					 
	} else {  
		
		lappend pin_list  [get_user_pin_name clk]
		lappend pin_list  [get_user_pin_name rstn]
		lappend pin_list  [get_user_pin_name devseln]
		lappend pin_list  [get_user_pin_name framen]
		lappend pin_list  [get_user_pin_name idsel]
		lappend pin_list  [get_user_pin_name intan]
		lappend pin_list  [get_user_pin_name irdyn]
		lappend pin_list  [get_user_pin_name par ]
		lappend pin_list  [get_user_pin_name perrn]
		lappend pin_list  [get_user_pin_name serrn]
		lappend pin_list  [get_user_pin_name stopn]
		lappend pin_list  [get_user_pin_name trdyn]		
			
		set i 0
		while {$i<32} {
			lappend pin_list [join [list [get_user_pin_name ad] \[$i\]] ""]
			incr i
		}
		set i 0
		while {$i<4} {
			lappend pin_list [join [list [get_user_pin_name cben] \[$i\]] ""]
			incr i
		}
		 
		if {$full_64} {
			set i 32
			while {$i<64} {
				lappend pin_list [join [list [get_user_pin_name ad] \[$i\]] ""]
				incr i
			}
			set i 4
			while {$i<8} {
				lappend pin_list [join [list [get_user_pin_name cben] \[$i\]] ""]
				incr i
			}
			
			lappend pin_list [get_user_pin_name ack64n]
			lappend pin_list [get_user_pin_name par64]
			lappend pin_list [get_user_pin_name req64n]	
		}
		
		if {$master} {
			lappend pin_list [get_user_pin_name gntn]
			lappend pin_list [get_user_pin_name reqn]
		}
	}
	return $pin_list     
}

#********************
# Create QSF back up
#********************
proc create_bk {} {
	set start_time [clock seconds]
	set archive_name [clock format $start_time -format "PCI_Archive_%Y%m%d_%H%M%S" ]
	export_assignments
	project_archive "$archive_name\.qar"    
	puts "Info: Your project has existing PCI assignments that must be deleted before adding"
	puts "      the new assignments.  Your old project will be archived with original assignments"
	puts "      in the following file: $archive_name\.qar"
}

#***************************    
# Remove old PCI assignments 
#***************************
proc remove_old_pci_asgn { pin_list no_pins got_prefix got_suffix prefix suffix} {
	global pin_planner_group
if ![info exist pin_planner_group] {
		if {$got_suffix == "1"} {
		set pin_planner_group [string range $suffix 1 end]
		} else {
		set pin_planner_group pci_top
		}
}

	initialize_logiclock
	set ll_region [get_logiclock]
	foreach region $ll_region {
	   set ll_match [regexp {^.*?pci_region_.*$} $region temp]                
	   if {$ll_match} {        	
			   logiclock_delete -region $region
	   }
	}
	uninitialize_logiclock
	#remove_all_global_assignments -section_id $pin -name FMAX_REQUIREMENT
	#remove previous group assignment to be replace with new one
	#assignment_group -remove $pin_planner_group
	set inst_asgn_2 [get_all_global_assignments -name *]
	foreach_in_collection instance $inst_asgn_2 {
		set sec_id [lindex $instance 0]
		set name [lindex $instance 1]
		foreach pin $pin_list {                 
			# Deletes pins which matched with the pin names specified
			if {($pin == $sec_id)} { 
		   if {$name == "FMAX_REQUIREMENT"} {
				 remove_all_global_assignments -section_id $sec_id -name $name
		   } 
			}         
		}    
	}
	set inst_asgn [get_all_instance_assignments -name *]
	foreach_in_collection instance $inst_asgn {
		set sec_id [lindex $instance 0]
		set src [lindex $instance 1]
		set dest [lindex $instance 2]
		set name [lindex $instance 3]   
		set value [lindex $instance 4]  
		foreach pin $pin_list {                 
			
			# Deletes pins which matched with the pin names specified
			if {($pin == $dest)} { 
				  if {$name == "TCO_REQUIREMENT"} {
					  if { $src == ""} {
							  remove_all_instance_assignments -name $name -to $dest
					  } else {
						  remove_all_instance_assignments -name $name -from $src -to $dest
					  }
				  } else {  
					   if {$name == "LOCATION"} {
						   if {!$no_pins} {
							  remove_all_instance_assignments -name $name -to $dest
						   }   
					   } else {
							  remove_all_instance_assignments -name $name -to $dest
					   } 
				  }
						  # cben previous assignment
						  if {[regexp {.*SYNTH_CRITICAL_PIN.*} $name temp]} {
							  remove_all_instance_assignments -name SYNTH_CRITICAL_PIN -to $dest
							 
						  }
			}         
		}    
	  
		# Deletes entity assignments which matches with 
		# PCI_MT64, PCI_MT32, PCI_T64 and PCI_T32 strings in the hierarchy
		if {[regexp {.*([PCIpci]+_[MTmt2346]+)[:].*} $dest match]} {
			set dest [string map { "|" "\\|" "[" "\\[" "]" "\\]" } $dest]
			set src [string map { "|" "\\|" "[" "\\[" "]" "\\]" } $src]
			if { $src == ""} {
					eval [subst {remove_all_instance_assignments -name $name -to {$dest}}]
			} else {
					eval [subst {remove_all_instance_assignments -name $name -from {$src} -to {$dest}}]
			}  
		}
	}    
	export_assignments   
}

#************************************************************************************
# This procedure will check the PCI IO assignment pin names found in QSF file
# against the pin names stored in the get_user_pin_names array

# If the pins match, the script will not do anything.
# If the pins do not match, then it will error out
# informing the customer that he has 2 options to delete the old PCI assignments
#       1. Delete the old PCI assignments manually
#       2. Update the pin array map and run the script to delete the old PCI assignments.
#************************************************************************************
proc run_pin_names_check { pin_list } {

	set pci_io [get_all_instance_assignments -name CLAMPING_DIODE]
	
	# Defaults pin names to "match"
	set match 1
	
	#{ {} {} {ack64n} {CLAMPING_DIODE} {ON}}
	foreach_in_collection asgn $pci_io {
		set dest [lindex $asgn 2]
		set value [lindex $asgn 4]
		
		if {($value=="ON")} {	            
			foreach pin $pin_list {
					
				if {($dest == $pin)} { 
					# pin match
					set match 1
					break
				} else {
					# pin mismatch
					set match 0         
				}
			}
			
			if {!($match)} {        
				puts "Error: Found Pin $dest in your project. This pin name is not the Altera default PCI pin name"         
				puts "       Failed removing old PCI assignments from your Quartus Setting File(.QSF)"
				puts "       because the PCI pin names in your project did not match the default PCI pin names "
				puts ""
				puts "       To use this script successfully you have two options:"                
				puts "       1. Manually delete the existing PCI assignments "
				puts "          from your Quartus Setting File(.QSF) file or "
				puts ""
				puts "       2. Update the PCI pin list in this script."                                                
				puts "          To update the PCI pin list, open this script in any editor of"                 
				puts "          your choice (ensure that the editor does not perform line wrap)"
				puts "          and edit the \"get_user_pin_name\" procedure. This procedure maps"                
				puts "          the default pin names to user defined pin names. Change the user defined"
				puts "          pin names to match the PCI pin names you have specified in your project."
				error ""
			}
		}
	}
}

#*********************************************
# Run checks to find existing PCI assignments 
#*********************************************
proc run_check {} {
	  
	set check 0
	
	#{ {} {<source>} {<destination>} {<name>} {<value>} }
	set io_standard [get_all_instance_assignments -name IO_STANDARD]
	set pci_io [get_all_instance_assignments -name CLAMPING_DIODE]
	set timing_asgn [get_all_instance_assignments -name TCO_REQUIREMENT]
	set ll_asgn [get_all_instance_assignments -name LL_MEMBER_OF]
	set delay_asgn [get_all_instance_assignments -name *_DECREASE_INPUT_DELAY_TO_INTERNAL_CELLS]
	
	#{ {} {} {ack64n} {IO_STANDARD} {3.0-V PCI} }   
	foreach_in_collection asgn $io_standard {
		set value [lindex $asgn 4]
		if {($value=="3.0-V PCI")} { 
			set check 1
		}
	}
	
	#{ {} {} {ack64n} {CLAMPING_DIODE} {ON}}
	foreach_in_collection asgn $pci_io {
		set value [lindex $asgn 4]
		if {($value=="ON")} { 
			set check 1
		}
	}
	
	# check for PCI timing assignments
	foreach_in_collection asgn $timing_asgn {
		set from [lindex $asgn 1]
		set x [split $from |]
		if {!([lsearch -regexp $x {_t:trg$}]< 0)} {
			set check 1
		}
	}
	
	# check for PCI Logic Lock assignments
	foreach_in_collection asgn $ll_asgn {
		set to [lindex $asgn 1]
		set y [split $to |]
		if {!([lsearch -regexp $y {_t:trg$}]< 0)} {
			set check 1
		}
	}
	
	# check PCI delay to internal cells assignments
	foreach_in_collection asgn $delay_asgn {
		set to [lindex $asgn 1]
		set z [split $to |]
		if {!([lsearch -regexp $z {_t:trg$}]< 0)} {
			set check 1
		}
	}
	
	return $check      
}
		
#***************************
# Add new PCI assignments
#***************************
proc constraint_file { device core full_64 hierarchy master pin_list speed pci_timing no_pins got_prefix got_suffix prefix suffix } { 
	global clk rstn devseln framen idsel intan irdyn par perrn serrn stopn trdyn ad cben ack64n par64 req64n gntn reqn
		global SHARED_CLK
		global pin_planner_group

if ![info exist pin_planner_group] {
		if {$got_suffix == "1"} {
		set pin_planner_group [string range $suffix 1 end]
		} else {
		set pin_planner_group pci_top
		}
}

		if {$got_prefix == "1" && $got_suffix == "0" } {
		if {$SHARED_CLK} {
		   set clk [get_user_pin_name clk]
				} else {
				   set clk [join [list $prefix [get_user_pin_name clk]] ""]
		}
		set rstn [join [list $prefix rstn] ""]
		set devseln [join [list $prefix devseln] ""]
		set framen [join [list $prefix framen] ""]
		set idsel [join [list $prefix idsel] ""]
		set intan [join [list $prefix intan] ""]
		set irdyn [join [list $prefix irdyn] ""]
		set par [join [list $prefix par] ""] 
		set perrn [join [list $prefix perrn] ""]
		set serrn [join [list $prefix serrn] ""]
		set stopn [join [list $prefix stopn] ""]
		set trdyn [join [list $prefix trdyn	] ""]	
		set ack64n [join [list $prefix ack64n] ""]
		set par64 [join [list $prefix par64] ""]
		set req64n [join [list $prefix req64n] ""]			
		set ad [join [list $prefix ad] ""]
		set cben [join [list $prefix cben] ""]
		set gntn [join [list $prefix gntn] ""]
		set reqn [join [list $prefix reqn] ""]
	} elseif {$got_suffix == "1" && $got_prefix == "0" } {
		if {$SHARED_CLK} {
		   set clk [get_user_pin_name clk]
				} else {
				   set clk [join [list [get_user_pin_name clk] $suffix] ""]
		}
				set rstn [join [list rstn $suffix] ""]
		set devseln [join [list devseln $suffix] ""]
		set framen [join [list framen $suffix] ""]
		set idsel [join [list idsel $suffix] ""]
		set intan [join [list intan $suffix] ""]
		set irdyn [join [list irdyn $suffix] ""]
		set par [join [list par $suffix] ""] 
		set perrn [join [list perrn $suffix] ""]
		set serrn [join [list serrn $suffix] ""]
		set stopn [join [list stopn $suffix] ""]
		set trdyn [join [list trdyn $suffix] ""]	
		set ack64n [join [list ack64n $suffix] ""]
		set par64 [join [list par64 $suffix] ""]
		set req64n [join [list req64n $suffix] ""]	
		set ad [join [list ad $suffix] ""]
		set cben [join [list cben $suffix] ""]
		set gntn [join [list gntn $suffix] ""]
		set reqn [join [list reqn $suffix] ""]		
	} elseif {$got_suffix == "1" && $got_prefix == "1" } {
		if {$SHARED_CLK} {
		   set clk [get_user_pin_name clk]
				} else {
				   set clk [join [list $prefix [get_user_pin_name clk] $suffix] ""]
		}
		#set clk [join [list $prefix clk $suffix] ""]
		set rstn [join [list $prefix rstn $suffix] ""]
		set devseln [join [list $prefix devseln $suffix] ""]
		set framen [join [list $prefix framen $suffix] ""]
		set idsel [join [list $prefix idsel $suffix] ""]
		set intan [join [list $prefix intan $suffix] ""]
		set irdyn [join [list $prefix irdyn $suffix] ""]
		set par [join [list $prefix par $suffix] ""] 
		set perrn [join [list $prefix perrn $suffix] ""]
		set serrn [join [list $prefix serrn $suffix] ""]
		set stopn [join [list $prefix stopn $suffix] ""]
		set trdyn [join [list $prefix trdyn $suffix] ""]	
		set ack64n [join [list $prefix ack64n $suffix] ""]
		set par64 [join [list $prefix par64 $suffix] ""]
		set req64n [join [list $prefix req64n $suffix] ""]	
		set ad [join [list $prefix ad $suffix] ""]
		set cben [join [list $prefix cben $suffix] ""]
		set gntn [join [list $prefix gntn $suffix] ""]
		set reqn [join [list $prefix reqn $suffix] ""]						
	} else {
		set clk [get_user_pin_name clk]
		set rstn [get_user_pin_name rstn]
		set devseln [get_user_pin_name devseln]
		set framen [get_user_pin_name framen]
		set idsel [get_user_pin_name idsel]
		set intan [get_user_pin_name intan]
		set irdyn [get_user_pin_name irdyn]
		set par [get_user_pin_name par ]
		set perrn [get_user_pin_name perrn]
		set serrn [get_user_pin_name serrn]
		set stopn [get_user_pin_name stopn]
		set trdyn [get_user_pin_name trdyn]	
		set ack64n [get_user_pin_name ack64n]
		set par64 [get_user_pin_name par64]
		set req64n [get_user_pin_name req64n]		
		set ad [get_user_pin_name ad]
		set cben [get_user_pin_name cben]
		set gntn [get_user_pin_name gntn]
		set reqn [get_user_pin_name reqn]
	}
		# adding  pin grouping
		#assignment_group $pin_planner_group -add_member $pin_list
	pci_pin_asgn $device $full_64 $master $core $pin_list $no_pins $got_prefix $got_suffix $prefix $suffix  
	basic_pci_asgn $core $full_64 $hierarchy $master $pin_list $pci_timing $got_prefix $got_suffix $prefix $suffix   
	family_pci_asgn $master $full_64 $hierarchy $pin_list $got_prefix $got_suffix $prefix $suffix
		set_qsf_mode -end
	SetLogicLockAssignment $core $speed $hierarchy
	export_assignments
		unset SHARED_CLK
}

#*********************************************
# Format pin names for Quartus II readability
#*********************************************
proc escape_name { a } {
	return "[string map { "[" "\\[" "]" "\\]" } $a]"
}
#************************************************************
# This procedure makes basic PCI assignment based on $pin_list
#************************************************************
proc basic_pci_asgn { core full_64 hierarchy master pin_list pci_timing got_prefix got_suffix prefix suffix } {

	global quartus 
	global clk rstn devseln framen idsel intan irdyn par perrn serrn stopn trdyn ack64n par64 req64n ad cben gntn reqn
	
	# Passes the correct PCI timing requirements
	# based on 66MHz or 33MHz PCI bus speed
	set speed [lindex $pci_timing 0]
	set pci_tsu [lindex $pci_timing 1]
	set pci_ptp [lindex $pci_timing 2] 
	set pci_th [lindex $pci_timing 3]
	set pci_tco [lindex $pci_timing 4]
	set pci_toff [lindex $pci_timing 5]
	
	if [string equal $quartus(nameofexecutable) "Quartus II"] {
		project start_batch $quartus(project)
	}
	   
	# Convert core to lower case for hierarchy replacement
	# in Tco timing requirement
	set core_lower [string tolower $core]
	# Timing-Related Assignments
	set_global_assignment -name "OPTIMIZE_HOLD_TIMING" "IO Paths and Minimum TPD Paths"
	#create_base_clock $clk -fmax "$speed ns"  
	#set_instance_assignment -name "CLOCK_SETTINGS" $clk -to $clk 
       	set_instance_assignment -name FAST_OUTPUT_REGISTER -to $ad[*]* ON
       	set_instance_assignment -name FAST_OUTPUT_REGISTER -to $cben[*]* ON
	
	   set number_of_pins [llength $pin_list]
	   foreach pin $pin_list {
		set_instance_assignment -name IO_STANDARD "3.0-V PCI" -to $pin
		set_instance_assignment -name CLAMPING_DIODE ON -to $pin
	} 
	
		# Filtering Pin direction based on cores assignments

		foreach asgn_pin $pin_list {
		if { $master } {
			if { $asgn_pin == "$trdyn" || [ regexp "$ad" $asgn_pin] || $asgn_pin == "$devseln" || $asgn_pin == "$par" || $asgn_pin == "$par64" ||  [regexp "$cben" $asgn_pin] || $asgn_pin == "$framen"  || $asgn_pin == "$req64n"  || $asgn_pin == "$irdyn" || $asgn_pin == "$stopn" || $asgn_pin == "$perrn" || $asgn_pin == "$ack64n" } {
				lappend bidir_pin $asgn_pin
			} elseif { $asgn_pin == "$gntn" || $asgn_pin == "$idsel" } {
				lappend input_pin $asgn_pin	
			} elseif { $asgn_pin == "$intan" || $asgn_pin == "$serrn" || $asgn_pin == "$reqn" } {  
				lappend output_pin $asgn_pin
			}
		} else {
			if { [regexp "$ad" $asgn_pin] || $asgn_pin == "$par" || $asgn_pin == "$par64" } {
				lappend bidir_pin $asgn_pin
			} elseif { $asgn_pin == "$idsel" || [regexp "$cben" $asgn_pin] || $asgn_pin == "$framen" || $asgn_pin == "$req64n" || $asgn_pin == "$irdyn" } { 
				lappend input_pin $asgn_pin	
			} elseif { $asgn_pin == "$trdyn" || $asgn_pin == "$devseln" || $asgn_pin == "$ack64n" || $asgn_pin == "$stopn" || $asgn_pin == "$intan" || $asgn_pin == "$perrn" || $asgn_pin == "$serrn"  } {
				lappend output_pin $asgn_pin
			}
		}
	}
	
	
	 # Specific Fitter Assignments
	set_global_assignment -name "RELEASE_CLEARS_BEFORE_TRI_STATES" "ON"	
	#set_instance_assignment -name "IGNORE_LCELL_BUFFERS" "ON" -to $hierarchy
	#set_instance_assignment -name "REMOVE_DUPLICATE_REGISTERS" "ON" -to $hierarchy
	
	export_assignments
	   if [string equal $quartus(nameofexecutable) "Quartus II"] { 
		project end_batch $quartus(project)
	}	
}
#*************
# Family Name
#*************
proc get_family_name {} {
		set family "Arria II GZ"
		return $family
}

#*********************************
# Set family specific assignments
#*********************************
proc family_pci_asgn { master full_64 hierarchy pin_list got_prefix got_suffix prefix suffix } {
	
	global clk rstn devseln framen idsel intan irdyn par perrn serrn stopn trdyn ad cben ack64n par64 req64n gntn reqn  
	set family [get_family_name]
	set_global_assignment -name "FAMILY" $family
	set_instance_assignment -name "GLOBAL_SIGNAL" ON -to $rstn
	set_instance_assignment -name "GLOBAL_SIGNAL" "DUAL-REGIONAL CLOCK" -to $clk
	set_instance_assignment -name "GLOBAL_SIGNAL" "DUAL-REGIONAL CLOCK" -to $irdyn
	set_instance_assignment -name "GLOBAL_SIGNAL" "DUAL-REGIONAL CLOCK" -to $trdyn
	set_instance_assignment -name "AUTO_PACKED_REGISTERS_STRATIXII" OFF -to "$hierarchy\|low_ad_or_fb"   
	set_instance_assignment -name "AUTO_PACKED_REGISTERS_STRATIXII" OFF -to "$hierarchy\|low_cben_or_fb"        
	set_instance_assignment -name "AUTO_PACKED_REGISTERS_STRATIXII" OFF -to "$hierarchy\|low_cben_or_d"             
	# For QIC flow, SPR 316344 
       	set_instance_assignment -name FAST_OUTPUT_REGISTER -to "*trdy_OR_NOT" ON
	
	if {$full_64} {
		set_instance_assignment -name "AUTO_PACKED_REGISTERS_STRATIXII" OFF -to "$hierarchy\|high_ad_or_fb"
		set_instance_assignment -name "AUTO_PACKED_REGISTERS_STRATIXII" OFF -to "$hierarchy\|high_cben_or_fb"
		set_instance_assignment -name "AUTO_PACKED_REGISTERS_STRATIXII" OFF -to "$hierarchy\|high_cben_or_d"
	}
	 
	foreach pin $pin_list {       
		set_instance_assignment -name BOARD_MODEL_NEAR_C 10p -to $pin   
	} 
	export_assignments
	# Assignment not applicable on input pins    
	remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $clk
	remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $rstn   
	remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $idsel
	
	if {$master} {  
		# For QIC flow, SPR 316344 
       		set_instance_assignment -name FAST_OUTPUT_REGISTER -to "*irdy_or_not" ON
		remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $gntn  		
	} else {
		remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $framen	
		remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $irdyn
		remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $cben\*	    
		if {$full_64} {
			remove_all_instance_assignments -name {BOARD_MODEL_NEAR_C} -to $req64n	    
		}
	} 
	export_assignments
	
	# LCELL Buffer Assignments
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $trdyn
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $irdyn
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $cben
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $devseln
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $framen
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $idsel
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $par
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $perrn
	set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $stopn
	
	if {$master} {
		set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $gntn
	}
	 if {$full_64} {
	  set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $ack64n	
	  set_instance_assignment -name "SYNTH_CRITICAL_PIN" ON -to $par64
	 }
	
	
	set_instance_assignment -name "IGNORE_LCELL_BUFFERS" "ON" -to $hierarchy
	set_instance_assignment -name "REMOVE_DUPLICATE_REGISTERS" "ON" -to $hierarchy
	export_assignments 
	
}

#*******************************************
# Sanity checks on device and PCI bus speed
#*******************************************
proc sanity_checks { speed device core  } {
	if { $device == "AUTO" } {
			error "Error: Cannot set DEVICE to AUTO. Assign a device using the Quartus II software"
	}
	
	# Check if customer is targeting on Arria II GZ device
	set device_family [lindex [get_part_info -family $device] 0]        

	if { $device_family == "Arria II GZ" } {
	} else {
			puts "Error: This constraint file is specific to Arria II GZ device family."
			puts "       You are not targeting a Arria II GZ device."
			puts "       Ensure that you are using the correct constraint file."
			error ""
	}       
	
	set pin_count [get_part_info -pin_count $device]
	set device_type [get_part_info -device $device]
	set grade [get_part_info -speed_grade $device]
	set tmp_grade [get_part_info -temperature_grade $device]
	
   if { $speed == "66" } {
      if { $device_type == "EP2AGZ225"} {
         pci_messages $device 0
      } elseif { $device_type == "EP2AGZ300"} {
         if { $grade == "3" } {
            if { $tmp_grade == "Commercial" } {
               if { $pin_count == "1517" && $core =="T64" } { # to block HF40 package
                  pci_messages $device 0
               } else {
                  pci_messages $device 1
               }
            } elseif { $tmp_grade == "Industrial" } {
               if { $core =="T32" || $core =="T64" } {
                  pci_messages $device 0
               } elseif { $pin_count == "1517" } {
                  pci_messages $device 0
               } else {
                  pci_messages $device 1
               }
            }
         } else {
            pci_messages $device 0
         }
      } elseif { $device_type == "EP2AGZ350"} {
         if { $grade == "3" } {
            if { $tmp_grade == "Commercial" } {
               pci_messages $device 1
            } elseif { $tmp_grade == "Industrial" } {
               if { $core =="MT64" || $core =="T32" || $core =="T64" } {
                  pci_messages $device 0
               } else {
                  pci_messages $device 1
               }            
            }
         } else {
            pci_messages $device 0
         }
      }
   } else {
      pci_messages $device 1
   }
}

proc pci_messages { device support } {
   global CRITICAL_WARNING
   if { $support == "1" } {
	puts "PCI Info: Device $device is supported. "
   } else {
	puts "PCI Critical Warning: PCI timing requirements are not met in device $device.  "
	set CRITICAL_WARNING 1
   }
}

#**********************
# Check if any PCI Critical Warnings 
#**********************
proc check_critical_warnings { } {
   global CRITICAL_WARNING 
   if { $CRITICAL_WARNING != "0" } {
        puts "PCI Critical Warning: Device may fail to compile successfully. "
		error ""
   } 
}


#**********************
# PCI pin assignments
#**********************

proc pci_pin_asgn { device full_64 master core pin_list no_pins got_prefix got_suffix prefix suffix } {
   set device_type [get_part_info -device $device]
   set device_type [string trimright $device_type ES]
   
   set pin_count [get_part_info -pin_count $device]
   
   #No pinouts. hard coded to not obtain any pin assignments
   # get pin out group name
   #set pinout_group [get_pinout_group_name $device_type\_$pin_count]
   set no_pins yes
   set pinout_group "nil" 
	
   # added for 33MHz pin out support 
   # no need to check for speed because if it was 66MHz it was errored out earlier already    
   
   #if { (($core == "MT64" || $core == "T64") && ($pin_count == "484" || $pin_count == "672")) } {
   #		   set pinout_group "nil"
   #}     

   # Warning Message if No pinout - Do not place AD pins close to VCCA
   set no_pinout_warning "PCI Warning: To avoid Simultaneous Switching Noise from affecting your system, please assign PCI AD pins away from VCCA pins."
			
   if { $no_pins } {
		# User is using own pins
		puts "Info: Not applying PCI pin location assignments in your project"             
		puts $no_pinout_warning
						  
   } elseif {$pinout_group == "nil"} { 
		# Pin outs are not available
		puts "Info: PCI pin location assignments are not available"
		puts "      Not applying PCI pin location assignments in your project" 
		puts $no_pinout_warning

   } else {
			
		# Lower 32 bit core
		$pinout_group\_lower_32bit_core
		
		# Master core
		if {$master} {
				$pinout_group\_mstr_tgt
		}
		
		# Upper 32 bit core
		if {$full_64} {
				$pinout_group\_upper_32bit_core
		}       
   } 
}

#**********************
# PCI pin assignments
#**********************
proc get_pinout_group_name { device_no_speed } {

	set pinout_group "nil"
			
	# array name == pin
	array set pin {  Titanb1_F780C3    2S90_2S130_2S180_F1508}

	set pinout_group $pin($device_no_speed)
	return $pinout_group
}       



#*****************************************
# PCI logic placement assignments (if any)
#*****************************************
proc SetLogicLockAssignment {core speed hierarchy} {
}




#************************************************************************
# Recommended Pin Outs for Altera PCI MegaCore Functions

# Revision History
# Date                  Change Description
# 02/27/2004    Added Arria II GZ pinouts

# Guidelines
# Please read before using the PCI pin outs information

#************************************************************************
# Using this pin out information
#************************************************************************
# These pin outs can be copied and pasted in Quartus Setting File (.QSF),
# under the "Pin & Location Assignments" section.
#
# If you are sourcing your constraint file in a Tcl console, you do not 
# need to manually add the pin outs information into your project.
# The script will do that automatically for you. The copy and paste 
# methodology is only applicable when the full blown constraint file
# has not been released.
#
#************************************************************************
# Preliminary Software Timing
#************************************************************************
# Pin outs based on preliminary software timing models are only 
# "best guess" based on knowledge of device architecture and estimated 
# device capabilities. In some cases, final software timing may show 
# that there are unavoidable set up time or hold time violations due to 
# the chosen pin-out. Although pin outs changes are not anticipated, 
# please advice your customer of possible pin outs changes when 
# software reports that timing is preliminary.
#
#************************************************************************
# PCI Core Support
#************************************************************************
# Device densities or specific packages may not be recommended for use  
# with all cores. Please refer to the latest PCI Support Product Matrix 
# for more information.
#
#************************************************************************
# PCI Bus Speed Support
#************************************************************************
#   Supports 66-MHz PCI (64 and 32 bit) in -4 and faster speed-gr$ade devices. 
#	Also supports -5 speed-gr$ade devices for device families EP2S15, 
#	EP2S30, EP2S60 and EP2S90.
#
#   Supports 33-MHz PCI (64 and 32 bit) in -5 and faster speed-grade devices.
#
#************************************************************************

# 32-bit master/target
# 33/66 MHz 
# 3.0-V Applications
# History:
#       03/24/2004: Created 
#       03/30/2004: Changed $irdyn and $trdyn from Y8, AA8 to AA12, AB13 respectively.
#                   $irdyn and $trdyn must be placed in bank 8 to make use of 
#                   dual regional clock settings.

# Quartus II Format
#       set_global_assignment -name "DEVICE" "EP2S60F484C3"
#       set_global_assignment -name "DEVICE" "EP2S60F484C4" 
#       set_global_assignment -name "DEVICE" "EP2S60F484C5" 

# Lower PCI 32-bit Core

#####################################################
# Generating SDC files in specific to top-level file
#####################################################

proc generate_pci_sdc { pin_list pci_timing master hierarchy core core_lower full_64 } {
	global clk rstn devseln framen idsel intan irdyn par perrn serrn stopn trdyn ack64n par64 req64n ad cben gntn reqn        
		global quartus
		global pin_planner_group	
	
	# Printing information to this Line
	
	# Necessary Actions required by tcl to do file manipulations
	
	# Getting Assignments for every settings for PCI external Timings
	set speed [lindex $pci_timing 0]
	set pci_tsu [lindex $pci_timing 1]
	set pci_ptp [lindex $pci_timing 2] 
	set pci_th [lindex $pci_timing 3]
	set pci_tco [lindex $pci_timing 4]
	set pci_toff [lindex $pci_timing 5]
	
	# Removing "ns" Assignments from original value
	regexp {([0-9]*.[0-9]*)} $pci_tsu pci_tsu_value
	regexp {([0-9]*.[0-9]*)} $pci_ptp pci_ptp_value
	regexp {([0-9]*.[0-9]*)} $pci_th pci_th_value
	regexp {([0-9]*.[0-9]*)} $pci_tco pci_tco_value	
	regexp {([0-9]*.[0-9]*)} $pci_toff pci_toff_value
	
	# Converint Values to be assigned to new set_input/output_delay settings
	set input_delay_value_max_ptp [expr $speed - $pci_ptp_value]
	set input_delay_value_max [expr $speed - $pci_tsu_value]
	set input_delay_value_min [expr {$pci_th_value}]

	set output_delay_value_tco [expr $speed - $pci_tco_value]
	set output_delay_value [expr {$pci_toff_value + $output_delay_value_tco}]
	set number_of_pins [llength $pin_list]
		
	# Filtering Pin direction based on cores assignments
	foreach asgn_pin $pin_list {
		if { $master } {
			if { $asgn_pin == "$trdyn" || [ regexp "$ad" $asgn_pin] || $asgn_pin == "$devseln" || $asgn_pin == "$par" || $asgn_pin == "$par64" ||  [regexp "cben" $asgn_pin] || $asgn_pin == "$framen"  || $asgn_pin == "$req64n"  || $asgn_pin == "$irdyn" || $asgn_pin == "$stopn" || $asgn_pin == "$perrn" || $asgn_pin == "$ack64n" } {
				lappend bidir_pin $asgn_pin
			} elseif { $asgn_pin == "$gntn" || $asgn_pin == "$idsel" } {
				lappend input_pin $asgn_pin	
			} elseif { $asgn_pin == "$intan" || $asgn_pin == "$serrn" || $asgn_pin == "$reqn" } {  
				lappend output_pin $asgn_pin
			}
		} else {
			if { [regexp "$ad" $asgn_pin] || $asgn_pin == "$par" || $asgn_pin == "$par64" } {
				lappend bidir_pin $asgn_pin
			} elseif { $asgn_pin == "$idsel" || [regexp "$cben" $asgn_pin] || $asgn_pin == "$framen" || $asgn_pin == "$req64n" || $asgn_pin == "$irdyn" } { 
				lappend input_pin $asgn_pin	
			} elseif { $asgn_pin == "$trdyn" || $asgn_pin == "$devseln" || $asgn_pin == "$ack64n" || $asgn_pin == "$stopn" || $asgn_pin == "$intan" || $asgn_pin == "$perrn" || $asgn_pin == "$serrn"  } {
				lappend output_pin $asgn_pin
			}
		}
	}
	
	
		#    and assinging to new sdc file
	set sdc_file [open $pin_planner_group\.sdc w+]
		set ad_constrained_flag 0
		set cben_constrained_flag 0
		set time [clock seconds]
		
	puts $sdc_file "##########################################################################"
	puts $sdc_file "#"
	puts $sdc_file "# Generated by : PCI Compiler Tcl Timing Constraints  "
	puts $sdc_file "# Quartus      : $quartus(version) "
	puts $sdc_file "# Project      : $quartus(project)"
	puts $sdc_file "#"
	puts $sdc_file "# Date         : [clock format $time]"
	puts $sdc_file "#"
	puts $sdc_file "# To use this SDC Generated File"
	puts $sdc_file "# - Add this file in the SDC file list "
	puts $sdc_file "#   under Timing Analysis Settings -> Timequest Timing Analyzer"
	puts $sdc_file "##########################################################################"
	puts $sdc_file ""
		
		# Make clock assignment
	puts $sdc_file "# PCI Clock Settings"
	puts $sdc_file "##############################"
	#puts $sdc_file "derive_clock_uncertainty"
	puts $sdc_file "create_clock -period $speed -name PCI_CLOCK $clk"
	puts $sdc_file "set_false_path -from \[\get_ports $rstn\] -to *"
	foreach bidir $bidir_pin {
	       if { [regexp "$ad" $bidir] } {
                  if { !$ad_constrained_flag } {
                     puts $sdc_file ""
		     puts $sdc_file "# Assigments for node $ad "
		     puts $sdc_file "###############################"
		     puts $sdc_file "set_output_delay -clock PCI_CLOCK -max $output_delay_value_tco \[\get_ports $ad\[*\]]"
		     puts $sdc_file "set_output_delay -clock PCI_CLOCK -min -2.0 \[\get_ports $ad\[*\]]"
		     puts $sdc_file "set_input_delay -clock PCI_CLOCK -max $input_delay_value_max \[\get_ports $ad\[*\]]"
		     puts $sdc_file "set_input_delay -clock PCI_CLOCK -min $input_delay_value_min \[\get_ports $ad\[*\]]"
                     set ad_constrained_flag 1
                  } else {
                     continue
                  }
	       } elseif { [regexp "$cben" $bidir] } {
                  if { !$cben_constrained_flag } {
                     puts $sdc_file ""
		     puts $sdc_file "# Assigments for node $cben "
		     puts $sdc_file "###############################"
		     puts $sdc_file "set_output_delay -clock PCI_CLOCK -max $output_delay_value_tco \[\get_ports $cben\[*\]]"
		     puts $sdc_file "set_output_delay -clock PCI_CLOCK -min -2.0 \[\get_ports $cben\[*\]]"
		     puts $sdc_file "set_input_delay -clock PCI_CLOCK -max $input_delay_value_max \[\get_ports $cben\[*\]]"
		     puts $sdc_file "set_input_delay -clock PCI_CLOCK -min $input_delay_value_min \[\get_ports $cben\[*\]]"
                     set cben_constrained_flag 1
                  } else {
                     continue
                  }
                } else {
                
                   puts $sdc_file ""
		   puts $sdc_file "# Assigments for node $bidir "
		   puts $sdc_file "###############################"
		   puts $sdc_file "set_output_delay -clock PCI_CLOCK -max $output_delay_value_tco \[\get_ports $bidir]"
		   puts $sdc_file "set_output_delay -clock PCI_CLOCK -min -2.0 \[\get_ports $bidir]"
		   puts $sdc_file "set_input_delay -clock PCI_CLOCK -max $input_delay_value_max \[\get_ports $bidir]"
		   puts $sdc_file "set_input_delay -clock PCI_CLOCK -min $input_delay_value_min \[\get_ports $bidir]"
		}
	}
        
	foreach input $input_pin {
		if { [regexp ".*gntn.*" $input]} {
	           puts $sdc_file ""
		   puts $sdc_file "# Assigments for node $input "
		   puts $sdc_file "###############################"
		   puts $sdc_file "set_input_delay -clock PCI_CLOCK -max $input_delay_value_max_ptp \[\get_ports $input]"
		   puts $sdc_file "set_input_delay -clock PCI_CLOCK -min $input_delay_value_min \[\get_ports $input]"
	
	       } elseif { [regexp "$cben" $input] } {
                  if { !$cben_constrained_flag } {
                   puts $sdc_file ""
		   puts $sdc_file "# Assigments for node $cben "
		   puts $sdc_file "###############################"
		   puts $sdc_file "set_input_delay -clock PCI_CLOCK -max $input_delay_value_max \[\get_ports $cben\[*\]]"
		   puts $sdc_file "set_input_delay -clock PCI_CLOCK -min $input_delay_value_min \[\get_ports $cben\[*\]]"
                   set cben_constrained_flag 1
                  } else {
                      continue
                  }
	       } else {
	          puts $sdc_file ""
		  puts $sdc_file "# Assigments for node $input "
		  puts $sdc_file "###############################"
		  puts $sdc_file "set_input_delay -clock PCI_CLOCK -max $input_delay_value_max \[\get_ports $input]"
		  puts $sdc_file "set_input_delay -clock PCI_CLOCK -min $input_delay_value_min \[\get_ports $input]"
	       }	
	 }
	
	foreach output $output_pin {
	        puts $sdc_file ""
		puts $sdc_file "# Assigments for node $output "
		puts $sdc_file "###############################"
		if { [regexp ".*reqn.*" $output] } {
			puts $sdc_file "set_output_delay -clock PCI_CLOCK -max $output_delay_value_tco \[\get_ports $output]"
			puts $sdc_file "set_output_delay -clock PCI_CLOCK -min -2.0 \[\get_ports $output]"
		} else {
			puts $sdc_file "set_output_delay -clock PCI_CLOCK -max $output_delay_value_tco \[\get_ports $output]"
			puts $sdc_file "set_output_delay -clock PCI_CLOCK -min -2.0 \[\get_ports $output]"
		}        
	}
        puts $sdc_file ""
	puts $sdc_file "####################################################"
	puts $sdc_file "# Assignments to meet PCI \"Float to Active\" Delay"
	puts $sdc_file "####################################################"
		puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_t:trg\|adoe\] -to \[\get_ports $ad\[*\]]"  
	puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|par_oeR\] -to \[\get_ports $par]"  
	puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_t:trg\|targ_oeR_reg\] -to \[\get_ports $devseln]"  
	puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_t:trg\|targ_oeR_reg\] -to \[\get_ports $stopn]"  
	puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_t:trg\|targ_oeR_reg\] -to \[\get_ports $trdyn]"  
	puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|perr_oe_r\] -to \[\get_ports $perrn]"  
			
	# 64-bit cores
	if {$full_64} {
	   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|par_oeR\] -to \[\get_ports $par64]"  		
	   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_t:trg\|targ_oeR_reg\] -to \[\get_ports $ack64n]"	
	   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_t:trg\|adoe\] -to \[\get_ports $ad\[*\]]" 
	}
	# Master/Target cores
	if {$master} {	
		puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|ad_oer\] -to \[\get_ports $ad\[*\]]"	
	   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|cbe_oer_not\] -to \[\get_ports $cben\[*\]]" 	
	   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|cbe_oer_not\] -to \[\get_ports $framen]"  
	   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|irdy_oer\] -to \[\get_ports $irdyn]"  
		
	   # Master/Target 64-bit cores
	   if {$full_64} {
		  puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|ad_oer\] -to \[\get_ports $ad\[*\]]" 
		   puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|cbe_oer_not\] -to \[\get_ports $cben\[*\]]"
		  puts $sdc_file "set_max_delay $output_delay_value -from \[get_registers $hierarchy\|pci$core_lower\_m:mstr\|cbe_oer_not\] -to \[\get_ports $req64n]"  
	   }		
		
	}
	close $sdc_file
}

puts "Info: You have sourced the Arria II GZ PCI constraint file."
puts "Info: Type the following command"
puts "Info: to add PCI assignments to your project. \n"
puts "Info: add_pci_constraints \[-speed 66 | 33\] \[-no_compile\] \[-no_pinouts\] \[-pin_prefix <pin_prefix_name>\] \[-pin_suffix <pin_suffix_name>\] \[-help\]"
puts "Info:      -speed: PCI bus speed "
puts "Info:      -no_compile: Do not perform Analysis and Synthesis on this project"
puts "Info:      -no_pinouts: Do not make Altera-recommended PCI pin location"
puts "Info:      -pin_prefix: Use this option to define your custom pin name which begins with a standard prefix"				
puts "Info:      -pin_suffix: Use this option to define your custom pin name which ends with a standard suffix"
puts "Info:      -help: Provides long help on PCI constraint file usage"
