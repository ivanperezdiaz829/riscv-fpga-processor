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


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

derive_clock_uncertainty

# Create the top-level clock pins
create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]

# xcvr_pll_refclk is actually 100 MHz on the AV devkit
create_clock -name {xcvr_pll_refclk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {xcvr_pll_refclk}]

# Get the clocks from the different PLLs
derive_pll_clocks

#Setting LED outputs as false path, since no timing requirement
set_false_path -from * -to [get_ports user_led[*]]

# Add the SDC constraints from the Video Frame Buffer
set_false_path -to [get_keepers {*alt_cusp*_gray_clock_crosser*shift_register[2]*}]

# Make the top-level clocks asynchronous to each other
set_clock_groups -asynchronous \
-group {clk} \
-group [get_clocks {ddr_clk}] \
-group {xcvr_pll_refclk} \
-group [get_clocks {video_pll_inst|*|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
-group [get_clocks {video_pll_inst|*|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] \
-group [get_clocks {xcvr_pll_inst|*|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
