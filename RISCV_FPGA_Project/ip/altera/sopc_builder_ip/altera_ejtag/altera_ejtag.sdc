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


## Copyright (C) 1991-2008 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.

#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

set clk_period 4.00
set jtag_tck_period 20.00
set jtag_output_delay 5.0
set jtag_input_setup 5.0


#**************************************************************
# Create Clock
#**************************************************************
#create_clock -name {clk} -period $clk_period -waveform { 0.000 1.500 } [get_ports {clk}]
create_clock -name {clk} -period $clk_period -waveform { 0.000 1.500 } 
create_clock -name {jtag_tck} -period $jtag_tck_period -waveform { 0.000 12.000 } [get_ports {jtag_tck}]
set_clock_uncertainty -from { jtag_tck } -to { jtag_tck } -setup 0
set_clock_uncertainty -from { clk } -to { clk } -setup 0


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -add_delay -max -clock [get_clocks {jtag_tck}]  [expr $jtag_tck_period - $jtag_input_setup] [get_ports {jtag_tdi}]
set_input_delay -add_delay -max -clock [get_clocks {jtag_tck}]  [expr $jtag_tck_period - $jtag_input_setup] [get_ports {jtag_tms}]

#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock  [get_clocks {jtag_tck}] -max $jtag_output_delay [get_ports {jtag_tdo}]

#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_clocks clk] -to [get_clocks jtag_tck]
set_false_path -from [get_clocks jtag_tck] -to [get_clocks clk]

# false path to first stage of synchronizers
set_false_path -to [get_keepers {*:*|din_s1}]

#**************************************************************
# Set Multicycle Path
#**************************************************************


