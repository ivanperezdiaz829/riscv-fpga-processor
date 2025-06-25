#--------------------------------------------------------------------------------
# Modelsim SE or PE Tcl script to run the design Walkthrough Example
#--------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# IP functional simulation model directory
# This walkthrough uses pci_top.vho (IP functional simulation model) from the
# directory specified in the walkthrough.
# You need Modelsim Altera version 6.1d or higher to simulate this project successfully
#------------------------------------------------------------------------------
#set pci_ip_sim_model_home  "c:/pci_example"
set pci_ip_sim_model_home  "../pci_top"


#------------------------------------------------------------------------------------------
# Check Modelsim Version
#------------------------------------------------------------------------------------------
set modelsim_version [exec vcom -version]
if {[string match *6.1* $modelsim_version]} {  
} else {
   error "To simulate this project successfully you require Modelsim Altera version 6.1 or higher"
}


#--------------------------------------------------------------------------------
# Make Lib directories
#--------------------------------------------------------------------------------
if {[file exists work]} {                   
    file delete -force work
    vlib work
    puts "Successfully created work directory"
} else {
    vlib work
    puts "Successfully created work directory"
}   


#--------------------------------------------------------------------------------
# Quartus Library files
# Note: In your simulations you must use the Altera simulation model files (altera_mf.vhd, 
#       220model.vhd and sgate.vhd) supplied with the version of Quartus II software you are using to 
#       create your specific variation IP Functional Simulation Model. The simulation model files 
#       are available in the directory <quartus_install_dir>/eda/sim_lib 

#       The example pci_top.vho file located at <path>/testbench/pci_top. 
#--------------------------------------------------------------------------------
global env ;
if [regexp {ModelSim ALTERA} [vsim -version]] {
        ;# Using OEM Version?s ModelSIM .ini file (modelsim.ini at ModelSIM Altera installation directory)
} else {
        # Using non-OEM Version, compile all of the libraries
        vlib lpm
        vmap lpm lpm 
        vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220pack.vhd
        vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.vhd 
 
        vlib altera_mf
        vmap altera_mf altera_mf
        vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf_components.vhd
        vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.vhd
 
        vlib sgate
        vmap sgate sgate
        vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate_pack.vhd
        vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.vhd
 
}


#------------------------------------------------------------------------------
# Compile IP functional simulation model
#------------------------------------------------------------------------------
if {[file exists $pci_ip_sim_model_home/pci_top.vho]} {                   
 vcom -93 -reportprogress 300 -work work  $pci_ip_sim_model_home/pci_top.vho
 puts "Compile pci_top.vho(IP Functional simulation model) from $pci_ip_sim_model_home"
} else  {
    error "Could not find pci_top.vho file in $pci_ip_sim_model_home"
}


#--------------------------------------------------------------------------------
# Altera Testbench Components, refer to PCI Testbench User guide for more information 
#--------------------------------------------------------------------------------
vcom -93 -reportprogress 300 -work work ../tb_src/clk_gen.vhd
vcom -93 -reportprogress 300 -work work ../tb_src/pull_up.vhd
vcom -93 -reportprogress 300 -work work ../tb_src/arbiter.vhd
vcom -93 -reportprogress 300 -work work ../tb_src/log.vhd
vcom -93 -reportprogress 300 -work work ../tb_src/monitor.vhd
vcom -93 -reportprogress 300 -work work ../tb_src/mstr_pkg.vhd

vcom -93 -reportprogress 300 -work work ./trgt_tranx.vhd
vcom -93 -reportprogress 300 -work work ./mstr_tranx.vhd


#--------------------------------------------------------------------------------
# Local Simple Reference Design
#--------------------------------------------------------------------------------
vcom -93 -reportprogress 300 -work work  ../local_bfm/lpm_ram_32.vhd
vcom -93 -reportprogress 300 -work work  ../local_bfm/dma.vhd
vcom -93 -reportprogress 300 -work work  ../local_bfm/lm_lastn_gen.vhd
vcom -93 -reportprogress 300 -work work  ../local_bfm/prefetch.vhd
vcom -93 -reportprogress 300 -work work  ../local_bfm/local_target.vhd
vcom -93 -reportprogress 300 -work work  ../local_bfm/local_master.vhd
vcom -93 -reportprogress 300 -work work  ../local_bfm/top_local.vhd


#--------------------------------------------------------------------------------
# Top level file
#--------------------------------------------------------------------------------
vcom -93 -reportprogress 300 -work work ./altera_tb.vhd


#----------------------------------------------------------------
# Load and Simulate the testbench 
# The following Libraries are precompiled libraries provided in Modelsim Altera Edition
# Comment out these lines if using Modelsim SE or PE
#----------------------------------------------------------------
vsim -t ps work.altera_tb


#----------------------------------------------------------------
# Perform Simulation
#----------------------------------------------------------------
do wave.do
when {/altera_tb/u4/end_sim} { 
puts ""
stop
}
run -all
