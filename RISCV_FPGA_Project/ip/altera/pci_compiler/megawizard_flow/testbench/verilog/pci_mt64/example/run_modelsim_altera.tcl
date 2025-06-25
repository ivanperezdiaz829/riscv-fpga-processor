#------------------------------------------------------------------------------
# Modelsim-Altera Tcl script to run the design Walkthrough Example
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Modelsim Home Directory
# This walkthrough uses default location of Modelsim Altera directory.
# You need Modelsim Altera version 6.1 or higher to simulate this project successfully
#------------------------------------------------------------------------------
set modelsim_home "C:/Modeltech_ae"

#------------------------------------------------------------------------------
# IP functional simulation model directory
# This walkthrough uses pci_top.vo (IP functional simulation model) from the
# directory specified in the walkthrough.
#------------------------------------------------------------------------------
#set pci_ip_sim_model_home  "c:/pci_example"
set pci_ip_sim_model_home  "../pci_top"


#------------------------------------------------------------------------------------------
# Check Modelsim Version
#------------------------------------------------------------------------------------------
set modelsim_version [exec vlog -version]
if {[string match *6.1* $modelsim_version]} {  
} else {
   error "To simulate this project successfully you require Modelsim Altera version 6.1 or higher"
}

if {[file exists $modelsim_home/docs/rlsnotes/6.1]} {  
} else {
   error "modelsim_home variable in this tcl script must point to the location where Modelsim Altera sofware version 6.1 or higher is installed"
}


#------------------------------------------------------------------------------
# Make work directory
#------------------------------------------------------------------------------
if {[file exists work]} {                   
    file delete -force work
    vlib work
    puts "Successfully Created work directory"
} else {
    vlib work
    puts "Successfully Created work directory"
}   

#------------------------------------------------------------------------------
# Compile IP functional simulation model
#------------------------------------------------------------------------------
 
if {[file exists $pci_ip_sim_model_home/pci_top.vo]} {                   
 vlog -work work  $pci_ip_sim_model_home/pci_top.vo
 puts "Compile pci_top.vo(IP Functional simulation model) from $pci_ip_sim_model_home"
} else  {
    error "Could not find pci_top.vo file in $pci_ip_sim_model_home"
}

 
#------------------------------------------------------------------------------
# Altera Testbench Components, refer to PCI Testbench User guide for more 
# information 
#------------------------------------------------------------------------------
vlog -work work ../tb_src/clk_gen.v
vlog -work work ../tb_src/pull_up.v
vlog -work work ../tb_src/arbiter.v
vlog -work work ../tb_src/monitor.v
vlog -work work ./trgt_tranx.v
vlog -work work ./mstr_tranx.v

#------------------------------------------------------------------------------
# Local Simple Reference Design
#------------------------------------------------------------------------------
vlog -work work  ../local_bfm/lpm_ram_32.v
vlog -work work  ../local_bfm/dma.v
vlog -work work  ../local_bfm/lm_lastn_gen.v
vlog -work work  ../local_bfm/prefetch.v
vlog -work work  ../local_bfm/local_target.v
vlog -work work  ../local_bfm/local_master.v
vlog -work work  ../local_bfm/top_local.v

#------------------------------------------------------------------------------
# Top level file
#------------------------------------------------------------------------------
vlog -work work ./altera_tb.v


#------------------------------------------------------------------------------
# Load and Simulate the testbench 
# The following Libraries are precompiled libraries provided in 
# Modelsim Altera Edition
#------------------------------------------------------------------------------
vsim -t ns -L $modelsim_home/altera/verilog/220model \
           -L $modelsim_home/altera/verilog/sgate \
           -L $modelsim_home/altera/verilog/altera_mf \
           work.altera_tb

#------------------------------------------------------------------------------
# Perform Simulation
#------------------------------------------------------------------------------

do wave.do
run 19300 ns
