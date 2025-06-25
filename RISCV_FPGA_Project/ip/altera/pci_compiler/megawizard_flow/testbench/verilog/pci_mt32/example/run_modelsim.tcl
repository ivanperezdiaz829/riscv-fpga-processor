#------------------------------------------------------------------------------
# Modelsim-Altera Tcl script to run the design Walkthrough Example
#------------------------------------------------------------------------------

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
global env ;
if [regexp {ModelSim ALTERA} [vsim -version]] {
        ;# Using OEM Version ModelSIM .ini file (modelsim.ini at ModelSIM Altera installation directory)
} else {
        # Using non-OEM Version, compile all of the libraries
        vlib lpm_ver
        vmap lpm_ver lpm_ver
        vlog -work lpm_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v

        vlib altera_mf_ver
        vmap altera_mf_ver altera_mf_ver
        vlog -work altera_mf_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v

        vlib sgate_ver
        vmap sgate_ver sgate_ver
        vlog -work sgate_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.v

}

vsim -t ps -L altera_mf_ver\
           -L lpm_ver\
           -L sgate_ver\
           work.altera_tb


#------------------------------------------------------------------------------
# Perform Simulation
#------------------------------------------------------------------------------

do wave.do
run 19300 ns
