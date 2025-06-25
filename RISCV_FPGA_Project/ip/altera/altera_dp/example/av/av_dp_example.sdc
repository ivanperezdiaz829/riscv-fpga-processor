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
create_clock -name {xcvr_mgmt_clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {xcvr_mgmt_clk}]
create_clock -name {clk162} -period 6.172 -waveform { 0.000 3.086 } [get_ports {xcvr_refclk[0]}]
create_clock -name {clk270} -period 3.700 -waveform { 0.000 1.850 } [get_ports {xcvr_refclk[1]}]
create_clock -name {tx_vid_clk} -period 8.333 -waveform { 0.000 4.166 } [get_ports {tx_vid_clk}]
create_clock -name {rx_vid_clk} -period 9.091 -waveform { 0.000 4.545 } [get_ports {rx_vid_clk}]
create_clock -name {aux_clk} -period 62.500 -waveform { 0.000 31.250 } [get_ports {aux_clk}]

# Get the clocks from the different PLLs
derive_pll_clocks

