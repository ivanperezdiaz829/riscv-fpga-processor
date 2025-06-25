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


#######################################################
#
# Top-level Tcl script for running the DisplayPort
# MegaCore Example Design
# 
# #####################################################

# Load required packages
load_package flow
load_package misc

# Regenerate the IP 
qexec "qmegawiz -silent av_xcvr_reconfig.v"
qexec "qmegawiz -silent av_dp.v"

# Create the project overwriting any previous settings files
project_new av_dp_example -overwrite

# add the assignments to the project
source assignments.tcl

# Compile the project
execute_flow -compile

# Clean up by closing the project
project_close
