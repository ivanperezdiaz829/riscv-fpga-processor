#--------------------------------------------------------------------------------
# Modelsim SE or PE Tcl script to run the design Walkthrough Example
#--------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# IP functional simulation model directory
# This walkthrough uses pci_top.vho (IP functional simulation model) from the
# directory specified in the walkthrough.
# You need Modelsim Altera version 6.1 or higher to simulate this project successfully
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
vsim work.altera_tb

#----------------------------------------------------------------
# Perform Simulation
#----------------------------------------------------------------

do wave.do
when {/altera_tb/u4/end_sim} { 
puts ""
stop
}
run -all
