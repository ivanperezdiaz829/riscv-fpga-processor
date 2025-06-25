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


#-----------------------------------------------------------------------------
#
# Description: SDC file for alt_xaui 
#
# Authors:     bauyeung 
#
#              Copyright (c) Altera Corporation 1997 - 2010
#              All rights reserved.
#
#
#-----------------------------------------------------------------------------

set_time_format -unit ns -decimal_places 3
derive_pll_clocks  -create_base_clock 
derive_clock_uncertainty

#
# input clocks
#
##create_clock -name {xgmii_tx_clk} -period 3.200 -waveform {0.000 1.6}   \
##    [get_ports {xgmii_tx_clk}]
create_clock -name {pll_ref_clk} -period 6.400 -waveform {0.000 3.2}   \
    [get_ports {pll_ref_clk}]
create_clock -name {phy_mgmt_clk} -period 20.000 -waveform {0.000 10.0} \
    [get_ports {phy_mgmt_clk}]

set_multicycle_path -from {*|alt_soft_dxaui_tx_data_pipeline:tx_pipeline_inst0|pcs_tx_dataout[*]} \
    -to {*alt4gxb:pma_direct*transmit_pma0~OBSERVABLEOUT} \
    -setup -end 2
set_multicycle_path -from {*|alt_soft_dxaui_tx_data_pipeline:tx_pipeline_inst0|pcs_tx_dataout[*]} \
    -to {*alt4gxb:pma_direct*transmit_pma1~OBSERVABLEOUT} \
    -setup -end 2
set_multicycle_path -from {*|alt_soft_dxaui_tx_data_pipeline:tx_pipeline_inst0|pcs_tx_dataout[*]} \
    -to {*alt4gxb:pma_direct*transmit_pma2~OBSERVABLEOUT} \
    -setup -end 2
set_multicycle_path -from {*|alt_soft_dxaui_tx_data_pipeline:tx_pipeline_inst0|pcs_tx_dataout[*]} \
    -to {*alt4gxb:pma_direct*transmit_pma3~OBSERVABLEOUT} \
    -setup -end 2

set_clock_groups -asynchronous \
    -group [get_clocks {*receive_pma0|deserclock[0]}] \
    -group [get_clocks {*receive_pma1|deserclock[0]}] \
    -group [get_clocks {*receive_pma2|deserclock[0]}] \
    -group [get_clocks {*receive_pma3|deserclock[0]}] \
    -group [get_clocks {*atx_clk_div0|refclkout}]

set_clock_groups -asynchronous \
    -group [get_clocks {phy_mgmt_clk}] \
    -group [get_clocks {*receive_pma0|deserclock[0]}]

set_clock_groups -asynchronous \
    -group [get_clocks {phy_mgmt_clk}] \
    -group [get_clocks {pll_ref_clk}]

set_clock_groups -asynchronous \
    -group [get_clocks {phy_mgmt_clk}] \
    -group [get_clocks {*atx_clk_div0|refclkout}]


