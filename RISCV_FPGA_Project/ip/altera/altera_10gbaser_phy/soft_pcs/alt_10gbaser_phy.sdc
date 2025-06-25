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


# (C) 2001-2010 Altera Corporation. All rights reserved.
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


## Generated SDC file "test.out.sdc"

## Copyright (C) 1991-2009 Altera Corporation
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


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 9.1 Internal Build 208 09/15/2009 SJ Full Version"

## DATE    "Tue Sep 29 14:52:00 2009"

##
## DEVICE  "EP4S40G5H40I1"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {xgmii_tx_clk} -period 6.400 -waveform { 0.000 3.200 } [get_ports {xgmii_tx_clk}]
create_clock -name {phy_mgmt_clk}   -period 20.00 -waveform { 0.000 10.000 } [get_ports {phy_mgmt_clk}]
create_clock -name {pll_ref_clk} -period 1.552 -waveform { 0.000 0.776  } [get_ports {pll_ref_clk}]
#derive_pll_clocks

#derive_pll_clocks -create_base_clocks
#derive_clocks -period "1.0"

#**************************************************************
# Create Generated Clock
#**************************************************************

#**************************************************************
# Set Clock Latency
#**************************************************************




#**************************************************************
# Set Clock Uncertainty
#**************************************************************

#**************************************************************
# Set Input Delay
#**************************************************************

set_false_path -from  [get_registers *pcs_map|reg_rclr_ber_cnt[*]] -to [get_registers *pcs_map|sync_rclr_ber_cnt*]
set_false_path -from  [get_registers *pcs_map|reg_rclr_errblk_cnt[*]] -to [get_registers *pcs_map|sync_rclr_errblk_cnt*]

set_false_path -from  [get_registers *pcs_10g_top_0*blk_lock_*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  [get_registers *pcs_10g_top_0*data_out_valid*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  [get_registers *pcs_10g_top_0*errblk_cnt*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  [get_registers *pcs_10g_top_0*ber_count*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  [get_registers *pcs_10g_top_0*hi_ber*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  [get_registers *siv_10gbaser_ch_inst*rx_data_ready_reg*] -to [get_registers *siv_10gbaser_ch_inst*rx_data_ready_sync[*]]

set_false_path -from  [get_registers *pcs_10g_top_0*altera_10gbaser_phy_async_fifo*dcfifo_componenet*ws_dgrp*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  [get_registers *pcs_10g_top_0*altera_10gbaser_phy_async_fifo*dcfifo_componenet*wraclr*] -to [get_registers *pcs_map*mux_pcs_status*]
set_false_path -from  *siv_10gbaser_ch_inst*pcs_10g_top_0*rx_top*async_fifo|wr_full -to [get_registers *pcs_map*mux_pcs_status*]

set_false_path -to {*pcs_pma_inst*rx_top*sv_rx_fifo*rdemp_eq_comp_*sb_aeb}
set_false_path -to {*pcs_pma_inst*rx_top*sv_rx_fifo*wrfull_eq_comp_*sb_mux_reg}

set_false_path -to {*pcs_pma_inst*sreg*}
set_false_path -to {*pcs_pma_inst*tx_pma_rstn}
set_false_path -to {*pcs_pma_inst*rx_pma_rstn}
set_false_path -to {*pcs_pma_inst*rx_usr_rstn}
set_false_path -to {*pcs_pma_inst*tx_usr_rstn}
set_false_path -to {*pcs_pma_inst*rx_usr_rstn_r}
set_false_path -to {*pcs_pma_inst*tx_usr_rstn_r}

set_false_path -from {pll_ref_clk} -to [get_registers *pcs_10g_top_0*rx_top*]

