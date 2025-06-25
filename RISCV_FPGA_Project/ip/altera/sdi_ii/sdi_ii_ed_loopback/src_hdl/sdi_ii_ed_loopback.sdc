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
# Set False Path
#**************************************************************

# False path for reset synchronizer in ed loopback - not applicable for A2B and B2A
set fifo_rst_sync_collection [get_pins -nowarn -nocase -compatibility_mode *fifo_reset_sync_*|clrn]
foreach_in_collection pin $fifo_rst_sync_collection {
   set_false_path -to [get_pins -nocase -compatibility_mode *fifo_reset_sync_*|clrn]
}

# False path for wrreq for fifo B as signals connected to wrclk (rx_clkout) and wrreq (data_valid_b) are from different clock domain
set fifo_valid_wrreq_collection [get_pins -nowarn -nocase -compatibility_mode *loopback|*u_fifo_b|*valid_wrreq*]
foreach_in_collection pin $fifo_valid_wrreq_collection {
   set_false_path -through [get_pins -nocase -compatibility_mode *loopback|*u_fifo_b|*valid_wrreq*]
}