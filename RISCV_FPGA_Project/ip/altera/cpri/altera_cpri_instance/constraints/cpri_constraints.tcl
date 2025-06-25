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


set p_DEVICE [get_parameter_value DEVICE]
set p_LINERATE [get_parameter_value LINERATE]
set p_AUTORATE [get_parameter_value AUTORATE]
set p_SYNC_MODE [get_parameter_value SYNC_MODE]
set p_N_MAP [get_parameter_value N_MAP]
set p_XVCR_FREQ [get_parameter_value XCVR_FREQ]
set p_SYNC_MAP [get_parameter_value SYNC_MAP]

set file [open "../constraints/altera_cpri.sdc" r]
set file_data [read $file]
close $file

set data [split $file_data "\n"]

set table_list [list]
set freq_prd_list [list]
set start_table 0
set start_freq_prd 0
foreach line $data {
   if { [regexp {.*Device Family.*} $line] } {
      set start_table 1
   }
   if { [regexp {.*Table End.*} $line] } {
      set start_table 0
   }
   if { $start_table == "1" } {
      lappend table_list $line
   }
   if { [regexp {.*Frequency.*Period.*Half.*Period.*} $line] } {
      set start_freq_prd 1
   }
   if { [regexp {.*# ---.*} $line] } {
      set start_freq_prd 0
   }
   if { $start_freq_prd == "1" } {
      lappend freq_prd_list $line
   }
}

proc f2p { f2p_list var } {
   foreach line $f2p_list {
      regexp {([0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)} $line matched sub1 sub2 sub3
      if { [info exist sub1] } {
         if { $sub1 == $var } {
            set sub2 [string trim $sub2]
            return $sub2
         }
      }
   }
}

proc f2hp { f2hp_list var } {
   foreach line $f2hp_list {
      regexp {([0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)} $line matched sub1 sub2 sub3
      if { [info exist sub1] } {
         if { $sub1 == $var } {
            set sub3 [string trim $sub3]
            return $sub3
         }
      }
   }
}

set gxb_refclk ""
set clk_ex_delay [list]

set device_detect 0
set start_assign 0
set assign_done 0
foreach line $table_list {
   if { [regexp {.*Stratix IV.*} $line] && $p_DEVICE == "0" } {
      set device_detect 1
   }
   if { [regexp {.*Arria II GX.*} $line] && $p_DEVICE == "1" } {
      set device_detect 1
   }
   if { [regexp {.*Arria II GZ.*} $line] && $p_DEVICE == "2" } {
      set device_detect 1
   }
   if { [regexp {.*Cyclone IV GX.*} $line] && $p_DEVICE == "3" } {  
      set device_detect 1
   }
   if { [regexp {.*Stratix V.*} $line] && $p_DEVICE == "4" } {  
      set device_detect 1
   }
   if { [regexp {.*Arria V.*} $line] && $p_DEVICE == "5" } {  
      set device_detect 1
   }
   if { [regexp {.*Cyclone V.*} $line] && $p_DEVICE == "6" } {  
      set device_detect 1
   }
   if { [regexp {.*Arria V GZ.*} $line] && $p_DEVICE == "7" } {  
      set device_detect 1
   }
   if { $device_detect == 1 } {
      if { [regexp {.*614.4.*} $line] && $p_LINERATE == "614" } {
         set start_assign 1
      }
      if { [regexp {.*1228.8.*} $line] && $p_LINERATE == "0" } {
         set start_assign 1
      }
      if { [regexp {.*2457.6.*} $line] && $p_LINERATE == "1" } {
         set start_assign 1
      }
      if { [regexp {.*3072.0.*} $line] && $p_LINERATE == "2" } {
         set start_assign 1
      }
      if { [regexp {.*4915.2.*} $line] && $p_LINERATE == "3" } {
         set start_assign 1
      }
      if { [regexp {.*6144.0.*} $line] && $p_LINERATE == "4" } {
         set start_assign 1
      }
      if { [regexp {.*9830.4.*} $line] && $p_LINERATE == "5" } {
         set start_assign 1
      }
   }
   if { $start_assign == 1 && $assign_done == 0 } {
      regexp {([0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)(.*[0-9]+\.[0-9]+)} $line matched sub1 sub2 sub3 sub4 sub5 sub6 sub7 sub8 sub9
      set sub2 [string trim $sub2]
      set sub5 [string trim $sub5]
      set sub6 [string trim $sub6]
      if { $p_DEVICE > "3" } {
         set gxb_refclk $p_XVCR_FREQ
      } else {
         set gxb_refclk $sub2
      }
      lappend clk_ex_delay $sub5 
      lappend clk_ex_delay $sub6
      set assign_done 1
   }
}

set text_list [list]
set header_start 0
set header_done 0
set map_clk_start 0
set map_clk_done 0
set derive_pll_done 0
set false_path_start 0
set false_path_done 0
set ds_detect_start 0
set device_ok 0
set autorate_ok 0
set linerate_ok 0
set ds_start 0
set ds_done 0

foreach line $data {

   if { [regexp {.*Altera.*Corporation.*} $line] } {
      set header_start 1
   }
   if { [regexp {.*Table End.*} $line] } {
      set header_done 1
   }
   if { $header_start == "1" && $header_done == "0" } {
      lappend text_list $line
   }
   if { $header_start == "1" && $header_done == "1" } {
      lappend text_list ""
      lappend text_list "set_time_format -unit ns -decimal_places 3\n"
      set header_start 0
   }

   if { [regexp {.*create_clock.*} $line]} {
      if { [regexp {.*gxb_refclk.*} $line]} {
         lappend text_list "# Transmitter Reference Clock"
         lappend text_list "create_clock -name gxb_refclk -period [f2p $freq_prd_list $gxb_refclk] -waveform \{0.000 [f2hp $freq_prd_list $gxb_refclk]\} \[get_ports gxb_refclk\]"
      }
      if { [regexp {.*gxb_pll_inclk.*} $line]} {
         lappend text_list "\n# Receiver Reference Clock"
         lappend text_list "create_clock -name gxb_pll_inclk -period [f2p $freq_prd_list $gxb_refclk] -waveform \{ 0.000 [f2hp $freq_prd_list $gxb_refclk] \} \[get_ports gxb_pll_inclk\]"
      }
      if { [regexp {.*gxb_cal_blk_clk.*} $line]} {
         if { $p_DEVICE == "0" || $p_DEVICE == "1" || $p_DEVICE == "2" || $p_DEVICE == "3" } {
            lappend text_list "\n# ALTGX Calibration Block Clock \(10MHz to 125MHz\)"
            lappend text_list "create_clock -name gxb_cal_blk_clk -period 8.000 -waveform \{0.000 4.000\} \[get_ports gxb_cal_blk_clk\]"
         } else {
         }
      }
      if { [regexp {.*usr_clk.*} $line]} {
         if { $p_DEVICE == "5" && $p_LINERATE == "5" } {
            lappend text_list "\n# 9.8G PHY-IP Soft-PCS and Core clock \(245.76MHz\) \(Arria V GT only\)"
            lappend text_list "create_clock -name usr_clk -period 4.069 -waveform \{0.000 2.035\} \[get_ports usr_clk\]"
         }
      }
      if { [regexp {.*usr_pma_clk.*} $line]} {
         if { $p_DEVICE == "5" && $p_LINERATE == "5" } {
            lappend text_list "\n# 9.8G PHY-IP Soft-PCS and Native PHY clock \(122.88MHz\) \(Arria V GT only\)"
            lappend text_list "create_clock -name usr_pma_clk -period 8.138 -waveform \{0.000 4.069\} \[get_ports usr_pma_clk\]"
         }
      }
      if { [regexp {.*reconfig_clk.*} $line]} {
         if { $p_DEVICE == "0" || $p_DEVICE == "1" || $p_DEVICE == "2" || $p_DEVICE == "3" } {
            lappend text_list "\n# ALTGX_RECONFIG Clock \(37.5MHz to 50MHz\)"
            lappend text_list "create_clock -name reconfig_clk -period 20.000 -waveform \{0.000 10.000\} \[get_ports reconfig_clk\]"
         } else {
            lappend text_list "\n# Reconfig/Calibration Clock (mgmt_clk_clk) \(100MHz to 125MHz\)"
            lappend text_list "create_clock -name reconfig_clk -period 10.000 -waveform \{0.000 5.000\} \[get_ports reconfig_clk\]"
         }
      }
      if { [regexp {.*pll_scanclk0.*} $line] && $p_DEVICE == "3" } {
         lappend text_list "\n# ALTPLL_RECONFIG Clock \(100MHz Maximum\) \(Cyclone IV GX only\)"
         lappend text_list "create_clock -name pll_scanclk -period 10.000 -waveform \{0.000 5.000\} \[get_ports pll_scanclk\[0\]\]"
      }
      if { [regexp {.*pll_scanclk1.*} $line] && $p_DEVICE == "3" } {
         lappend text_list "create_clock -name pll_scanclk1 -period 10.000 -waveform \{0.000 5.000\} \[get_ports pll_scanclk\[1\]\]"
      }
      if { [regexp {.*cpu_clk.*} $line]} {
         lappend text_list "\n# CPRI CPU Clock"
         lappend text_list "create_clock -name cpu_clk -period 32.552 -waveform \{0.000 16.276\} \[get_ports cpu_clk\]"
      }
      if { [regexp {.*clk_ex_delay.*} $line]} {
         lappend text_list "\n# Extended Delay Measurement Clock"
         lappend text_list "create_clock -name clk_ex_delay -period [lindex $clk_ex_delay 0] -waveform \{0.000 [lindex $clk_ex_delay 1]\} \[get_ports clk_ex_delay\]"
      }
      if { [regexp {.*map.*clk.*} $line] && $map_clk_start == "0" } {
           set map_clk_start 1
      }
      if { $map_clk_start == "1" && $map_clk_done == "0" } {
         if { $p_N_MAP != "0" && $p_SYNC_MAP == "0" } {
            lappend text_list "\n# Data Mapping Clock"
            for {set i 0} {$i < $p_N_MAP} {incr i} {
               lappend text_list "create_clock -name map${i}_tx_clk -period 260.416 -waveform \{0.000 130.208\} \[get_ports map${i}_tx_clk\]"
            }
            for {set i 0} {$i < $p_N_MAP} {incr i} {
               lappend text_list "create_clock -name map${i}_rx_clk -period 260.416 -waveform \{0.000 130.208\} \[get_ports map${i}_rx_clk\]"
            }
         }
         set map_clk_done 1
      }
   }
   if { $derive_pll_done == "0" && $map_clk_done == "1" } {
      lappend text_list "\nderive_pll_clocks"
      lappend text_list "derive_clock_uncertainty\n"
      set derive_pll_done 1
   }
   if { $false_path_done == "0" && $derive_pll_done == "1" } {
      set false_path_start 1
   }
   if { $false_path_start == "1" && [regexp {.*set_false_path.*} $line] } {
      lappend text_list $line     
   }
   if { $false_path_start == "1" && [regexp {.*\#\*\*\*.*} $line] } {
      set false_path_done 1
      set false_path_start 0
      set ds_detect_start 1
   }
   if { $ds_detect_start == "1" && $ds_done == "0" } {
      if { $p_DEVICE == "0" && [regexp {.*Stratix IV.*} $line] } {
         set device_ok 1
      }
      if { $p_DEVICE == "1" && [regexp {.*Arria II GX.*} $line] } {
         set device_ok 1
      }
      if { $p_DEVICE == "2" && [regexp {.*Arria II GZ.*} $line] } {
         set device_ok 1
      }
      if { $p_DEVICE == "3" && [regexp {.*Cyclone IV GX.*} $line] } {
         set device_ok 1
      }
      if { $p_DEVICE == "4" && [regexp {.*Stratix V.*} $line] } {
         set device_ok 1
      }
      if { $p_DEVICE == "5" && [regexp {.*Arria V.*} $line] } {
         set device_ok 1
      }
      if { $p_DEVICE == "6" && [regexp {.*Cyclone V.*} $line] } {
         set device_ok 1
      } 
      if { $p_DEVICE == "7" && [regexp {.*Arria V GZ.*} $line] } {
         set device_ok 1
      }

      if { $device_ok == "1" } {
         if { $p_AUTORATE == "1" && [regexp {.*AUTORATE.*1.*} $line] } {
            set autorate_ok 1
         }
         if { $p_AUTORATE == "0" && [regexp {.*AUTORATE.*0.*} $line] } {
            set autorate_ok 1
         }
      }
       
      if { $autorate_ok == "1" } {
         if { $p_LINERATE == "614" && [regexp {.*614.4.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
         if { $p_LINERATE == "0" && [regexp {.*1228.8.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
         if { $p_LINERATE == "1" && [regexp {.*2457.6.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
         if { $p_LINERATE == "2" && [regexp {.*3072.0.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
         if { $p_LINERATE == "3" && [regexp {.*4915.2.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
         if { $p_LINERATE == "4" && [regexp {.*6144.0.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
         if { $p_LINERATE == "5" && [regexp {.*9830.4.*LINERATE.*} $line] } {
            set linerate_ok 1
         }
      }
      if { $ds_start == "1" } {
         set ds_start 2
         set code_base 1
         if { $p_DEVICE == "4" } {
            if { $p_LINERATE == "5" || $p_LINERATE == "4" } {
               set code_base 2
            } 
         }
         if { $p_DEVICE == "5" } { 
            if { $p_LINERATE == "5" || $p_LINERATE == "4" || $p_LINERATE == "3" } {
               set code_base 2
            }
         }
         if { $p_DEVICE == "7" } {
            if { $p_LINERATE == "4" || $p_LINERATE == "3" } {
               set code_base 2
            }
         }
         if { $code_base == "2" } {
            lappend text_list "set_false_path -from *cpri_cpu2*int_cpri_map_mode* -to *"
            lappend text_list "set_false_path -from *cpri_cpu2*int_cpri_map_15bit_mode* -to *"
            lappend text_list "set_false_path -from *cpri_cpu2*int_cpri_map_ac* -to *"
            lappend text_list "set_false_path -from *cpri_cpu2*int_map_tx_enable* -to *"
         }
      } 
      if { $linerate_ok == "1" } {
         if { [regexp {.*\#\*\*\*.*} $line] && $ds_start == "0" } {
            set ds_start 1
            lappend text_list ""
         }
      }
      if { $ds_start == "2" && $ds_done == "0" } {
         if { [regexp {.*\#\*\*\*.*} $line] } {
            set ds_done 1
         } else {
            if { $p_N_MAP == "0" && [regexp {.*set_clock_groups.*map.*clk.*} $line] } {
	    } else {
               lappend text_list $line
            }
         }
      }
   }
}

set text [join $text_list \n]

add_fileset_file altera_cpri.sdc OTHER TEXT $text
