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


#!/bin/sh
    

cd ../altera_eth_2_5GbE_sim/synopsys/vcsmx/

cat vcsmx_setup.sh | sed -e 's/SKIP_ELAB=0/SKIP_ELAB=1/' > vcsmx_setup.sh.tmp; mv -f vcsmx_setup.sh.tmp vcsmx_setup.sh
cat vcsmx_setup.sh | sed -e 's/SKIP_SIM=0/SKIP_SIM=1/' > vcsmx_setup.sh.tmp; mv -f vcsmx_setup.sh.tmp vcsmx_setup.sh
cat vcsmx_setup.sh | sed -e 's/TOP_LEVEL_NAME=".*"/TOP_LEVEL_NAME="tb"/' > vcsmx_setup.sh.tmp; mv -f vcsmx_setup.sh.tmp vcsmx_setup.sh

source vcsmx_setup.sh

#Compile Avalon VIP
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/verification/lib/verbosity_pkg.sv
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/verification/lib/avalon_mm_pkg.sv
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/verification/lib/avalon_utilities_pkg.sv
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_sink_bfm/altera_avalon_st_sink_bfm.sv
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm.sv
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_hssi_atoms.v
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_pcie_hip_atoms.v
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_atoms.v
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_hssi_atoms.v
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_pcie_hip_atoms.v
vlogan +v2k -sverilog -work work $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_atoms.v

vlogan +v2k -sverilog ../../../altera_eth_2_5GbE_testbench/avalon_driver.sv +incdir+../../../altera_eth_2_5GbE_testbench/ +incdir+./ -work work
vlogan +v2k -sverilog ../../../altera_eth_2_5GbE_testbench/avalon_st_eth_packet_monitor.sv +incdir+../../../altera_eth_2_5GbE_testbench/ +incdir+./ -work work
vlogan +v2k -sverilog ../../../altera_eth_2_5GbE_testbench/avalon_gmii_rx_converter.v +incdir+ ../../../altera_eth_2_5GbE_testbench +incdir+ ./ -work work

vlogan +v2k -sverilog ../../../altera_eth_2_5GbE_testbench/tb.sv  +incdir+../../../altera_eth_2_5GbE_testbench/ +incdir+./ -work work

vcs -lca -t ps tb -debug_all

#./simv -gui 
./simv
    
