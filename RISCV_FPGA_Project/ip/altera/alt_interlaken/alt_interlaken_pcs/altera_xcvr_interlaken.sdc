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
# File:
# altera_xcvr_interlaken.sdc 
# 
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************
derive_pll_clocks

if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {      
} else {
set_false_path -from [get_registers {*tx_from_fifo*}] -through {*txbursten*} -to {*10g_tx_pcs*SYNC_DATA_REG*} 
}
