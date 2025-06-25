#! /bin/sh

# *******************************************************************************
# Set the quartus_home variable to the location where you have installed 
# Quartus II software version 6.0 or higher
# ********************************************************************************

export quartus_home=`echo $QUARTUS_ROOTDIR`

# **********************************************************************************************
# Compile the Altera simulation models, the IP Functional Simulation Model and testbench and run
# the simulation model

# Note: In your simulations you must use the Altera simulation model files (nopli.v, altera_mf.v, 
#       220model.v and sgate.v) supplied with the version of Quartus II software you are using to 
#       create your specific variation IP Functional Simulation Model. The simulation model files 
#       are available in the directory <quartus_install_dir>/eda/sim_lib 

#       The example pci_top.vo file located at <path>/testbench/pci_top was created using 
#       Quartus II software version 6.0
# **********************************************************************************************


vcsi +v2k $quartus_home/eda/sim_lib/nopli.v \
$quartus_home/eda/sim_lib/220model.v \
$quartus_home/eda/sim_lib/sgate.v \
$quartus_home/eda/sim_lib/altera_mf.v \
../pci_top/pci_top.vo \
../tb_src/clk_gen.v \
../tb_src/pull_up.v \
../tb_src/arbiter.v \
../tb_src/monitor.v \
./trgt_tranx.v \
./mstr_tranx.v \
../local_bfm/lpm_ram_32.v \
../local_bfm/dma.v \
../local_bfm/lm_lastn_gen.v \
../local_bfm/prefetch.v \
../local_bfm/local_target.v \
../local_bfm/local_master.v \
../local_bfm/top_local.v \
./altera_tb.v -R <<EOF

quit
EOF


