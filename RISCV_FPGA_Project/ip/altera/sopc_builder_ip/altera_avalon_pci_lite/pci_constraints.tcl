# Copyright (C) 1991-2004 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.


# PCI CONSTRAINTS FILE
# To use the the constraint file,
#   #source <constraint filename>.tcl
#   #add_pci_constraints [-speed 33 | 66] [-no_compile] [-no_pinouts] [-pin_prefix <pin_prefix_name>] [-pin_suffix <pin_suffix_name>] [-help]  
# For more information on constraint file usage, please refer to Appendix A of PCI Compiler 4.0.0 User Guide and PCI Compiler 4.0.0 Read Me File.

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
proc get_user_pin_name { internal_pin_name } {
    
    
    #---------------- Do NOT change -------------------------------      ---- Change -----
        array set map_user_pin_name_to_internal_pin_name { ad                    ad                             }
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

package require ::quartus::project
package require ::quartus::flow
package require ::quartus::report
package require ::quartus::device 1.0
package require ::quartus::logiclock 1.0



variable pin_planner_group pci_compiler
variable pcicomp_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/pci_compiler/lib/ip_toolbench"
variable SHARED_CLK yes
variable SHARED_CLK_NAME clk

# Sourcing simulation setup script
		
                set findSopcFile [glob *.sopc]
		set sopcFileList [split $findSopcFile " "]
		foreach file $sopcFileList {
			set sopcFile $file
		}
		set sopcName [split $sopcFile "."]
		set sopcName [lindex $sopcName 0]
		set vhdl_lang 0 
                set sopcFileVHDL $sopcName\.vhd
                if [file exists $sopcFileVHDL] {
		    incr vhdl_lang 
		}
                if {$vhdl_lang} {
                    puts ""
                    puts "Info : PCI LIte is generated in VHDL"
                    puts "Info : Simulation model generation is not supported"
                    puts ""
		} else {
		    set post_gen_tcl "pci_lite_post_generation.tcl"
		    if [file exists $post_gen_tcl] {
			source $post_gen_tcl
		    } else {
	                source "$env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_pci_lite/pci_lite_post_generation.tcl"
		    }
		}

# Current project device family package information
set device [get_global_assignment -name DEVICE]
set device_family [lindex [get_part_info -family $device] 0] 
global no_device
if { $device == "AUTO" } {
   puts "Error: \"AUTO\" device selected. Please select a specific device and re-source the PCI Constraints file""
   error ""
}

# Sourcing the relevant files based on selected device 
switch $device_family {
   "Stratix III"         { source $pcicomp_dir/../../const_files/pci_stratixiii_cf.tcl }
   "Stratix IV"		 { source $pcicomp_dir/../../const_files/pci_stratixiv_cf.tcl }	
   "HardCopy II"         { source $pcicomp_dir/../../const_files/pci_hardcopyii_cf.tcl }
   "HardCopy III"        { source $pcicomp_dir/../../const_files/pci_hardcopyiii_cf.tcl }
   "HardCopy IV"         { source $pcicomp_dir/../../const_files/pci_hardcopyiv_cf.tcl }
   "Cyclone III"         { source $pcicomp_dir/../../const_files/pci_cycloneiii_cf.tcl }
   "Cyclone III LPS"     { source $pcicomp_dir/../../const_files/pci_cyclonelps_cf.tcl }
   default {
      puts "Error: Device family selected is not supported by PCI Compiler"
      puts "Error: Please select another device that supports PCI Compiler"
      error ""
   }
}
