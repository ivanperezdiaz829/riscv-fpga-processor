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


# Compile the Interlaken and Transceiver Reconfig IP

vcs -lca -sverilog +verilog2001ext+.v -timescale=1ps/1ps +define+ALTERA +define+SIMULATION \
  +define+ADVANCED_CLOCKING +define+DUPLEX_MODE +incdir+../../src+../ -debug_pp \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/altera_primitives.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/220model.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/sgate.v \
     $QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_atoms.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/synopsys/stratixv_atoms_ncrypt.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/synopsys/stratixv_hssi_atoms_ncrypt.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/arriavgz_atoms.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/synopsys/arriavgz_atoms_ncrypt.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/arriavgz_hssi_atoms.v \
  -v $QUARTUS_ROOTDIR/eda/sim_lib/synopsys/arriavgz_hssi_atoms_ncrypt.v \
  -F interlaken_phy_ip_lib_src_lst.txt \
  -F reconfig_ctrlr_lib_src_lst.txt \
  -F seriallite_src_lst_vcs.txt \
  -top test_env \
  -pvalue test_env.lanes=4

# use +random_seed='value' for a specific random_seed

./simv -l transcript_vcs -vcd dump.vcd +test_name=data_forwarding +random_seed=222

