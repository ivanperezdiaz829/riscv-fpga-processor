# (C) 2001-2011 Altera Corporation. All rights reserved.
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


set_clock_groups -exclusive -group [get_clocks {sv_reconfig_pma_testbus_clk}] -group [remove_from_collection [get_clocks *] [get_clocks {sv_reconfig_pma_testbus_clk}]]
set_clock_groups -exclusive -group [get_clocks {alt_cal_sv_edge_detect_clk}] -group [remove_from_collection [get_clocks *] [get_clocks {alt_cal_sv_edge_detect_clk}]]
