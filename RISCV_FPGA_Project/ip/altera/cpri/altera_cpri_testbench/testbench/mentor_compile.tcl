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


global env;

# VARIABLE_DECLARATION
set TOP_LEVEL_NAME tb

# Sourcing the simulator tcl file
source $QSYS_SIMDIR/mentor/msim_setup.tcl

# Alias from msim_setup.tcl
# Compile device library files
dev_com 

# Compile the design files in correct order
com

# TESTBENCH_COMPILE

# Add in the wave file
do wave.do
