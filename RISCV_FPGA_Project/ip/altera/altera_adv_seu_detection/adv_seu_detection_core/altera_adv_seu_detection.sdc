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



#__ACDS_USER_COMMENT__ ATTENTION: Replace below 'clk' with appropriate clock that was connected to 'clk' port of IP core
create_generated_clock -name ed_clock -source [get_ports {clk}] -divide_by 2 [get_keepers {*emr_unloader:emr_unloader|current_state.STATE_CLOCKHIGH}]
