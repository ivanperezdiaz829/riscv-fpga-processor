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



onerror quit
onbreak resume
vlib work
if { [file exists $env(QUARTUS_ROOTDIR)/eda/sim_lib] } {
  if [regexp {ModelSim ALTERA} [vsim -version]] {
  #Do nothing, using precompiled libraries for Modelsim_AE  
  } else {
  	vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.v
  	vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/stratixiv_hssi_atoms.v
  	vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v
  	vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v
  }
  vlog -timescale "1 ps / 1 ps" +acc ../alt_interlaken_20lane_6g/simulation/*.v
  vlog -timescale "1 ps / 1 ps" +acc -sv *.sv
  vlog -timescale "1 ps / 1 ps" +incdir+../alt_interlaken_20lane_6g/simulation/submodules/ +acc -sv ../alt_interlaken_20lane_6g/simulation/submodules/*.v
  vlog -timescale "1 ps / 1 ps" +acc -sv ../alt_interlaken_20lane_6g/simulation/submodules/mentor/*.v

} else {
  puts "Unable to find Quartus simulation models"
  puts "Please check QUARTUS_ROOTDIR env variable"
  puts "Should be d:/altera/(ver)/quartus"
}

if [regexp {ModelSim ALTERA} [vsim -version]] {
	vsim -L lpm_ver -L altera_mf_ver -L sgate_ver -L stratixiv_hssi_ver  -t 1ps alt_interlaken_20lane_6g_tb 
} else {
	vsim -t 1ps alt_interlaken_20lane_6g_tb
}
add wave *
add wave alt_interlaken_20lane_6g_tb/dut/interlaken_0/*
run -all
quit
