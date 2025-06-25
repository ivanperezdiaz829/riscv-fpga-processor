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


# Regenerate the IP simulation models
qmegawiz -silent av_xcvr_reconfig.v
qmegawiz -silent av_dp.v

# Merge the msim_setup.tcl files
ip-make-simscript --spd=./av_xcvr_reconfig.spd --spd=./av_dp.spd 

# Call ModelSim to compile the design and run the simulation
vsim -c -do msim_dp.tcl
