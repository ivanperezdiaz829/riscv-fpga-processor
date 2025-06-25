## ================================================================================
## Legal Notice: Copyright (C) 1991-2009 Altera Corporation
## Any megafunction design, and related net list (encrypted or decrypted),
## support information, device programming or simulation file, and any other
## associated documentation or information provided by Altera or a partner
## under Altera's Megafunction Partnership Program may be used only to
## program PLD devices (but not masked PLD devices) from Altera.  Any other
## use of such megafunction design, net list, support information, device
## programming or simulation file, or any other related documentation or
## information is prohibited for any other purpose, including, but not
## limited to modification, reverse engineering, de-compiling, or use with
## any other silicon devices, unless such use is explicitly licensed under
## a separate agreement with Altera or a megafunction partner.  Title to
## the intellectual property, including patents, copyrights, trademarks,
## trade secrets, or maskworks, embodied in any such megafunction design,
## net list, support information, device programming or simulation file, or
## any other related documentation or information provided by Altera or a
## megafunction partner, remains with Altera, the megafunction partner, or
## their respective licensors.  No other licenses, including any licenses
## needed under any third party's intellectual property, are provided herein.
## ================================================================================
# NCO Compiler Multi-Channel Example Design 
# Description: Modelsim TCL script to run the VHDL NCO Compiler Multi-Channel Example Design 

set current_dir [pwd]
if {[file exist [project env]] > 0} {project close}
if {[file exist multichannel_example.vhd] ==0} {
   error "Please change directory to NCO Multiple channel reference design"  }

if {[file exist "$current_dir/multichannel_example.mpf"] == 0} {
      project new [pwd] multichannel_example
} else	{
	project open multichannel_example
}

# Create default work directory if not present
if {[file exist work] ==0} 	{
  exec vlib work
  exec vmap work work}      

# Map lpm library
if {[file exist lpm] ==0} 	{
  exec vlib lpm
  exec vmap lpm lpm}      
vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220pack.vhd 
vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.vhd 

# Map altera_mf library
if {[file exist altera_mf] ==0} 	{
  exec vlib altera_mf
  exec vmap altera_mf altera_mf}      
vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf_components.vhd 
vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.vhd 

# Map sgate library
if {[file exist sgate] ==0} 	{
  exec vlib sgate
  exec vmap sgate sgate}      
vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate_pack.vhd 
vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.vhd 

# Compile IP Functional Simulation Model
vcom nco.vho						

# Compile Multiple-Channel Example toplevel
vcom multichannel_example.vhd

# Compile Testbench		 
vcom multichannel_example_tb.vhd	

# Simulate Testbench in Modelsim
vsim multichannel_example_tb -t 1ps	

# Run script to add signals to wave window
do multichannel_example_wave.tcl

# Run for 50,000 ns (50 us)
run 50000 ns;
