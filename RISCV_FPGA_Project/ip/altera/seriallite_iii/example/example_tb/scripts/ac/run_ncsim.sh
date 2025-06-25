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


###########################################################################################################
# Notes: Update path variables 
# QUARTUS_ROOTDIR based on Quartus install location 
# SNK_SIM_LOCATION to where generated simulation files for Sink Interface are located
# SRC_SIM_LOCATION to where generated simulation files for Source Interface are located
###########################################################################################################
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/altera_primitives.v"         
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/220model.v"                       
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/sgate.v"                      
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v"                      
ncvlog -sv "$QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv"                  
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/cadence/stratixv_atoms_ncrypt.v"          
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/stratixv_atoms.v"                        
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/cadence/stratixv_hssi_atoms_ncrypt.v"  
ncvlog     "$QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v"                   
ncvlog   "$QUARTUS_ROOTDIR/eda/sim_lib/cadence/arriavgz_hssi_atoms_ncrypt.v"
ncvlog   "$QUARTUS_ROOTDIR/eda/sim_lib/arriavgz_hssi_atoms.v"
ncvlog   "$QUARTUS_ROOTDIR/eda/sim_lib/arriavgz_atoms.v"
ncvlog   "$QUARTUS_ROOTDIR/eda/sim_lib/cadence/arriavgz_atoms_ncrypt.v"


# Compile the Interlaken and transceiver reconfig IP

irun -compile -F interlaken_phy_ip_lib_src_lst.txt
irun -compile -F reconfig_ctrlr_lib_src_lst.txt

# Compile the generic design files
irun -compile -sv +define+ADVANCED_CLOCKING +define+SIMULATION +incdir+../../src+../ -F seriallite_src_lst_ncsim.txt

# Run the simulation

ncelab -access +w+r+c +define+ADVANCED_CLOCKING -defparam test_env.lanes=4 test_env
ncsim -run +random_seed=123456 +define+SIMULATION +define+ADVANCED_CLOCKING +test_name=data_forwarding test_env
