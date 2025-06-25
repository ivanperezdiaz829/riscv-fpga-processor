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


rm -rf work
vlib work

# Compile the simulation Libraries
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/altera_primitives.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/220model.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/sgate.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/aldec/stratixv_hssi_atoms_ncrypt.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_atoms.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/aldec/stratixv_atoms_ncrypt.v
## To Simulate with Arria GZ libraries  
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/aldec/arriavgz_hssi_atoms_ncrypt.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/arriavgz_hssi_atoms.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/arriavgz_atoms.v
vlog +acc -sv $QUARTUS_ROOTDIR/eda/sim_lib/aldec/arriavgz_atoms_ncrypt.v

# Compile the Interlaken and Transceiver Reconfiguration IPs

vlog -sv -f interlaken_phy_ip_lib_src_lst.txt +access +w +define+ALTERA +define+SIMULATION
vlog -sv -f reconfig_ctrlr_lib_src_lst.txt +access +w +define+ALTERA +define+SIMULATION

# Compile the generic design files
vlog -sv +incdir+../../src+../ -f seriallite_src_lst_rivr.txt +access +w +define+ALTERA +define+SIMULATION

vsim -c -novopt +test_name=data_forwarding +define+ALTERA +access +w +define+SIMULATION -G /test_env/lanes=5 test_env -do vrun.do
