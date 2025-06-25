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


global env ;

cd ../altera_eth_2_5GbE_sim/mentor
source msim_setup.tcl

# Compile Stratix IV device family
vlib stratixiv_hssi_lib
vmap stratixiv_hssi_lib stratixiv_hssi_lib
vlog -work stratixiv_hssi_lib $env(QUARTUS_ROOTDIR)/eda/sim_lib/stratixiv_hssi_atoms.v
vlog -work stratixiv_hssi_lib $env(QUARTUS_ROOTDIR)/eda/sim_lib/stratixiv_atoms.v
vlog -work stratixiv_hssi_lib $env(QUARTUS_ROOTDIR)/eda/sim_lib/stratixiv_pcie_hip_atoms.v 
# Compile Arria II device family
vlib arriaii_hssi_lib
vlog -work arriaii_hssi_lib $env(QUARTUS_ROOTDIR)/eda/sim_lib/arriaii_hssi_atoms.v
vlog -work arriaii_hssi_lib $env(QUARTUS_ROOTDIR)/eda/sim_lib/arriaii_pcie_hip_atoms.v
vlog -work arriaii_hssi_lib $env(QUARTUS_ROOTDIR)/eda/sim_lib/arriaii_atoms.v

# Alias from msim_setup.tcl
# Compile device library files
dev_com 

# Compile the design files in correct order
com


# Compile Avalon VIP
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/verbosity_pkg.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/avalon_mm_pkg.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/avalon_utilities_pkg.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_sink_bfm/altera_avalon_st_sink_bfm.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm.sv

# Compile testbench
vlog -work work +incdir+../../altera_eth_2_5GbE_testbench/ ../../altera_eth_2_5GbE_testbench/tb.sv


# Elaborate top level design
elab \
-L stratixiv_hssi_lib\
-novopt\
-t ps\
work.tb


# Add waveform
#do ../../../testbench/wave.do

# Run the simulation
log -r /*
run -all

cd ../../altera_eth_2_5GbE_testbench
