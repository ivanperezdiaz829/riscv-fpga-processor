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


# Compile TSE Qsys source files
set QSYS_SIMDIR "../tse_1588/simulation"
source ../tse_1588/simulation/mentor/msim_setup.tcl

# Compile Device Simulation Model
dev_com

# Compile DUT
com

# Compile Avalon VIP
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/verbosity_pkg.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/avalon_mm_pkg.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/avalon_utilities_pkg.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_sink_bfm/altera_avalon_st_sink_bfm.sv
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm.sv

# Compile 1pps and top wrapper
vlog -work work $env(QUARTUS_ROOTDIR)/../ip/altera/ethernet/altera_eth_10g_design_example/design_example_components/altera_eth_1588_pps/altera_eth_1588_pps.v
vlog -work work ../tse_1588_top.v

 #compile the top level design
 vlog -work work tb_top.sv
 
 
 # Elaborate top level design
 elab \
 -novopt\
 -t ps\
 work.tb_top
 
 # Add waveform
 do wave.do
 
 #log all waveform
 log -r /*
 radix -hexadecimal
 
 # Run the simulation
 run -all
