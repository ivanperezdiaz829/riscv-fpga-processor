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


set family "$1"
set type "$2"
set sim "$3"
set SIM_DIR "../"
set TOP_LEVEL_NAME "" 

switch $family {
   "sivgx" { set device 0; echo "INFO: Stratix IV is chosen."}
   "aiigx" { set device 1; echo "INFO: Arria II GX is chosen."}
   "aiigz" { set device 2; echo "INFO: Arria II GZ is chosen."}
   "civgx" { set device 3; echo "INFO: Cyclone IV GX is chosen."} 
   "sv"   { set device 4; set family_phy stratixv;set xcvr phy;  echo "INFO: Stratix V is chosen."}
   "av"   { set device 5; set family_phy arriav; set xcvr phy; echo "INFO: Arria V is chosen."}
   "cv"   { set device 6; set family_phy cyclonev; set xcvr phy; echo "INFO: Cyclone V is chosen."}
   "avgz" { set device 7; set family_phy arriavgz; set xcvr phy;  echo "INFO: Arria V GZ is chosen."}
   "avgt" { set device 8; set family_phy arriav; set xcvr xcvr; echo "INFO: Arria V GT is chosen." }
}

# Sourcing the simulator tcl file
if {[string match $sim aldec]} {
   set sim_path "aldec/rivierapro_setup.tcl"
   set option "-dbg -O2 +access +r"
} elseif {[string match $sim mentor]} {
   set sim_path "mentor/msim_setup.tcl"
   set option "-novopt"
} else {
   echo "INFO : This simulator is not supported."
}

   echo "INFO: $family autorate is turned on."

   if { $device < 3 } {
      #Stratix IV GX
      set QSYS_SIMDIR "../../../../cpri_top_level_sim/"
      source ../../../../cpri_top_level_sim/$sim_path
      dev_com
      com
      if {[string match $type vlg]} {
         vlog -work work $SIM_DIR/altgx_reconfig_cpri.v
         vlog -work work $SIM_DIR/rom.v 
      } else {
         vcom -work work $SIM_DIR/altgx_reconfig_cpri.vhd
         vcom -work work $SIM_DIR/rom.vhd 
      }
   } elseif { $device == 3 } {
      #Cyclone IV GX
      set QSYS_SIMDIR "../../../../cpri_top_level_sim/"
      source ../../../../cpri_top_level_sim/$sim_path
      dev_com
      com
      if {[string match $type vlg]} {
         vlog -work work $SIM_DIR/altgx_c4gx_reconfig_cpri.v
         vlog -work work $SIM_DIR/altpll_c4gx_reconfig_cpri.v 
         vlog -work work $SIM_DIR/rom.v     
         vlog -work work $SIM_DIR/rom_pll.v
      } else {
         vcom -work work $SIM_DIR/altgx_c4gx_reconfig_cpri.vhd
         vcom -work work $SIM_DIR/altpll_c4gx_reconfig_cpri.vhd
         vcom -work work $SIM_DIR/rom.vhd      
         vcom -work work $SIM_DIR/rom_pll.vhd        
      }
      } else {
      #Stratix V, Arria V
      set QSYS_SIMDIR "../xcvr_reconfig_cpri_sim/"
      source ../xcvr_reconfig_cpri_sim/$sim_path
      dev_com
      com
      set QSYS_SIMDIR "../../../../cpri_top_level_sim/"
      source ../../../../cpri_top_level_sim/$sim_path
      com
      
      if {[string match $type vlg]} {
         vlog -work work $SIM_DIR/rom.v
      } else {
         vcom -work work $SIM_DIR/rom.vhd
      }
      
      # For AVGT 9.8G only
      if { $device == 8 } {
         vcom -work work $SIM_DIR/clock_switch.vhd
      }

      vcom -work work $SIM_DIR/cpri_reconfig_controller.vhd
   }

# compiling the testbench                                                                
vcom -work work $SIM_DIR/tb.vhd           

if {$device < 4 } {
# elab the top level design
elab\
-novopt\
-t fs\
work.tb } elseif { $device == 8 } {
   if {[string match $type vlg]} {
      vsim $option -t fs -L work -L work_lib -L xcvr_reconfig_cpri -L mm_interconnect_0 -L inst_xcvr_phy_mgmt_translator -L inst_cpri_$xcvr\_mgmt_interface_translator -L inst_xcvr -L inst_cpri -L cpri_top_level -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L $family_phy\_ver -L $family_phy\_hssi_ver -L $family_phy\_pcie_hip_ver tb
    } else {
      vsim $option -t fs -L work -L work_lib -L xcvr_reconfig_cpri -L mm_interconnect_0 -L inst_xcvr_phy_mgmt_translator -L inst_cpri_$xcvr\_mgmt_interface_translator -L inst_xcvr -L inst_cpri -L cpri_top_level -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L $family_phy\_ver -L $family_phy\_hssi_ver -L $family_phy\_pcie_hip_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L $family_phy tb  
    } 
} else {
      if {[string match $type vlg]} {
         vsim $option -t fs -L work -L work_lib -L xcvr_reconfig_cpri -L mm_interconnect_0 -L inst_xcvr_phy_mgmt_translator -L inst_cpri_$xcvr\_mgmt_interface_translator -L inst_xcvr -L inst_cpri -L cpri_top_level -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L $family_phy\_ver -L $family_phy\_hssi_ver -L $family_phy\_pcie_hip_ver tb 
      } else {
         vsim $option -t fs -L work -L work_lib -L xcvr_reconfig_cpri -L mm_interconnect_0 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L $family_phy\_ver -L $family_phy\_hssi_ver -L $family_phy\_pcie_hip_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L $family_phy -L inst_xcvr_phy_mgmt_translator -L inst_cpri_$xcvr\_mgmt_interface_translator -L inst_xcvr -L inst_cpri -L cpri_top_level tb
      } 
}
          
# Add in the wave file
do wave.do
