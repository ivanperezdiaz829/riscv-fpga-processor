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



# CPRI Clock Settings Reference Table
# 
# Frequency(MHz) Period(ns) Half Period(ns)
#   3.84         260.416    130.208
#   7.68         130.208     65.104
#  15.36          65.104     32.552        
#  21.04          47.528     23.764 
#  30.72          32.552     16.276
#  38.4           26.042     13.021
#  49.152         20.345     10.1725
#  61.44          16.276      8.138
#  76.80          13.020      6.510
#  96.0           10.416      5.208
#  98.304         10.172      5.086
# 102.4            9.766      4.883
# 122.88           8.138      4.069
# 153.60           6.510      3.255
# 196.608          5.086      2.543
# 204.8            4.883      2.4415
# 245.76           4.069      2.035
# 256.0            3.906      1.953
# 307.20           3.255      1.628
# 384.0            2.604      1.302
# 393.216          2.543      1.2715
# 409.6            2.4414     1.2207
# 491.52           2.035      1.0175
# 512.0            1.953      0.9765
# 614.4            1.628      0.814
#
# -------------------------------------------------------------------------------------------------------
# Device Family     Linerate  ALTGX Clock  System Clock  Extended Delay Measurement Clock             
#                   (Mbps)    (MHz)        (MHz)         127/128                  63/64 
#                                                        (MHz)   (ns)    0.5(ns)  (MHz)   (ns)    0.5(ns)
# Arria II GX
#                    614.4     61.44        15.36         15.24  65.617  32.809    15.12  66.138  33.069        
#                   1228.8     61.44        30.72         30.48  32.808  16.404    30.24  33.069  16.535
#                   2457.6    122.88        61.44         60.96  16.404   8.202    60.48  16.534   8.267
#                   3072.0    153.60        76.80         76.20  13.123   6.562    75.60  13.228   6.614  
#                   4915.2    245.76       122.88        121.92   8.202   4.101   120.96   8.267   4.134  
#                   6144.0    307.20       153.60        152.40   6.562   3.281   151.20   6.614   3.307  
# -------------------------------------------------------------------------------------------------------
# Cyclone IV GX
#                    614.4     61.44        15.36         15.24  65.617  32.809    15.12  66.138  33.069        
#                   1228.8     61.44        30.72         30.48  32.808  16.404    30.24  33.069  16.535
#                   2457.6    122.88        61.44         60.96  16.404   8.202    60.48  16.534   8.267
#                   3072.0    153.60        76.80         76.20  13.123   6.562    75.60  13.228   6.614
# -------------------------------------------------------------------------------------------------------
# Stratix IV
# Arria II GZ
#                    614.4     61.44        15.36         15.24  65.617  32.809    15.12  66.138  33.069
#                   1228.8     61.44        30.72         30.48  32.808  16.404    30.24  33.069  16.535
#                   2457.6     61.44        61.44         60.96  16.404   8.202    60.48  16.534   8.267
#                   3072.0     76.80        76.80         76.20  13.123   6.562    75.60  13.228   6.614
#                   4915.2    122.88       122.88        121.92   8.202   4.101   120.96   8.267   4.134
#                   6144.0    153.60       153.60        152.40   6.562   3.281   151.20   6.614   3.307
#--------------------------------------------------------------------------------------------------------
# Stratix V
# Arria V GZ
#                    614.4     30.72        15.36         15.24  65.617  32.809    15.12  66.138  33.069
#                   1228.8     30.72        30.72         30.48  32.808  16.404    30.24  33.069  16.535
#                   2457.6     61.44        61.44         60.96  16.404   8.202    60.48  16.534   8.267
#                   3072.0     76.80        76.80         76.20  13.123   6.562    75.60  13.228   6.614
#                   4915.2    122.88       122.88        121.92   8.202   4.101   120.96   8.267   4.134
#                   6144.0    153.60       153.60        152.40   6.562   3.281   151.20   6.614   3.307
#                   9830.4    245.76       245.76        243.84   4.101   2.051   241.92   4.134   2.067  
#--------------------------------------------------------------------------------------------------------
# Arria V
#                    614.4     30.72        15.36         15.24  65.617  32.809    15.12  66.138  33.069
#                   1228.8     30.72        30.72         30.48  32.808  16.404    30.24  33.069  16.535
#                   2457.6     61.44        61.44         60.96  16.404   8.202    60.48  16.534   8.267
#                   3072.0     76.80        76.80         76.20  13.123   6.562    75.60  13.228   6.614
#                   4915.2    122.88       122.88        121.92   8.202   4.101   120.96   8.267   4.134
#                   6144.0    153.60       153.60        152.40   6.562   3.281   151.20   6.614   3.307  
#                   9830.4    245.76       245.76        243.84   4.101   2.051   241.92   4.134   2.067
#--------------------------------------------------------------------------------------------------------
# Cyclone V
#                    614.4     30.72        15.36         15.24  65.617  32.809    15.12  66.138  33.069
#                   1228.8     30.72        30.72         30.48  32.808  16.404    30.24  33.069  16.535
#                   2457.6     61.44        61.44         60.96  16.404   8.202    60.48  16.534   8.267
#                   3072.0     76.80        76.80         76.20  13.123   6.562    75.60  13.228   6.614
# Table End

# Please adjust the value accordingly
set_time_format -unit ns -decimal_places 3

# Receiver Reference Clock
create_clock -name gxb_refclk -period 6.510 -waveform {0.000 3.255} [get_ports gxb_refclk]

# Transmitter Reference Clock
create_clock -name gxb_pll_inclk -period 6.510 -waveform {0.000 3.255} [get_ports gxb_pll_inclk]

# ALTGX Calibration Block Clock (10MHz to 125MHz)
create_clock -name gxb_cal_blk_clk -period 8.000 -waveform {0.000 4.000} [get_ports gxb_cal_blk_clk]

# 9.8G PHY-IP Soft-PCS and Core clock (245.76MHz) (Arria V GT only)
create_clock -name usr_clk -period 4.069 -waveform {0.000 2.035} [get_ports usr_clk]

# 9.8G PHY-IP Soft-PCS and Native PHY clock (122.88MHz) (Arria V GT only)
create_clock -name usr_pma_clk -period 8.138 -waveform {0.000 4.069} [get_ports usr_pma_clk]

# ALTGX_RECONFIG Clock (37.5MHz to 50MHz)
create_clock -name reconfig_clk -period 20.000 -waveform {0.000 10.000} [get_ports reconfig_clk]

# ALTPLL_RECONFIG Clocks (100MHz Maximum) (Cyclone IV GX only)
create_clock -name pll_scanclk0 -period 10.000 -waveform {0.000 5.000} [get_ports pll_scanclk[0]]
create_clock -name pll_scanclk1 -period 10.000 -waveform {0.000 5.000} [get_ports pll_scanclk[1]]

# CPRI CPU Clock
create_clock -name cpu_clk -period 32.552 -waveform {0.000 16.276} [get_ports cpu_clk]

# Extended Delay Measurement Clock (127/128 of System Clock)
create_clock -name clk_ex_delay -period 65.617 -waveform {0.000 32.809} [get_ports clk_ex_delay]

# Data Mapping Clock
create_clock -name map0_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map0_tx_clk]
create_clock -name map1_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map1_tx_clk]
create_clock -name map2_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map2_tx_clk]
create_clock -name map3_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map3_tx_clk]
create_clock -name map4_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map4_tx_clk]
create_clock -name map5_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map5_tx_clk]
create_clock -name map6_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map6_tx_clk]
create_clock -name map7_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map7_tx_clk]
create_clock -name map8_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map8_tx_clk]
create_clock -name map9_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map9_tx_clk]
create_clock -name map10_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map10_tx_clk]
create_clock -name map11_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map11_tx_clk]
create_clock -name map12_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map12_tx_clk]
create_clock -name map13_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map13_tx_clk]
create_clock -name map14_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map14_tx_clk]
create_clock -name map15_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map15_tx_clk]
create_clock -name map16_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map16_tx_clk]
create_clock -name map17_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map17_tx_clk]
create_clock -name map18_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map18_tx_clk]
create_clock -name map19_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map19_tx_clk]
create_clock -name map20_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map20_tx_clk]
create_clock -name map21_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map21_tx_clk]
create_clock -name map22_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map22_tx_clk]
create_clock -name map23_tx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map23_tx_clk]
create_clock -name map0_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map0_rx_clk]
create_clock -name map1_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map1_rx_clk]
create_clock -name map2_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map2_rx_clk]
create_clock -name map3_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map3_rx_clk]
create_clock -name map4_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map4_rx_clk]
create_clock -name map5_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map5_rx_clk]
create_clock -name map6_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map6_rx_clk]
create_clock -name map7_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map7_rx_clk]
create_clock -name map8_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map8_rx_clk]
create_clock -name map9_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map9_rx_clk]
create_clock -name map10_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map10_rx_clk]
create_clock -name map11_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map11_rx_clk]
create_clock -name map12_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map12_rx_clk]
create_clock -name map13_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map13_rx_clk]
create_clock -name map14_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map14_rx_clk]
create_clock -name map15_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map15_rx_clk]
create_clock -name map16_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map16_rx_clk]
create_clock -name map17_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map17_rx_clk]
create_clock -name map18_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map18_rx_clk]
create_clock -name map19_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map19_rx_clk]
create_clock -name map20_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map20_rx_clk]
create_clock -name map21_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map21_rx_clk]
create_clock -name map22_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map22_rx_clk]
create_clock -name map23_rx_clk -period 260.416 -waveform {0.000 130.208} [get_ports map23_rx_clk]

derive_pll_clocks
derive_clock_uncertainty

set_false_path -from * -to *sync
set_false_path -from * -to *sync[*]
set_false_path -from * -to *sync1
set_false_path -from * -to *sync1[*]
set_false_path -from * -to *s0
set_false_path -from * -to *s0[*]

#**************************************************************
# Arria II GX
# Auto-rate Negotiation On (AUTORATE = 1)
# 614.4, 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 614,0,1,2,3,4)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk_div2 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 2 [get_registers *txclk_div2]
create_generated_clock -name txclk_d2 -source [get_registers *txclk_div2] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -exclusive -group txclk_d2 -group {txclk_d4 txclk_div4 *receive_pcs0|clkout}
set_clock_groups -exclusive -group txclk_d4 -group {txclk_d2 txclk_div2 *receive_pcs0|clkout}
set_clock_groups -asynchronous -group cpu_clk -group {txclk_d2 txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk_d2 txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_d2 txclk_d4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk_d2 txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Arria II GX
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Arria II GX
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0, 4915.2 Mbps (LINERATE = 0,1,2,3)
#**************************************************************
create_generated_clock -name txclk_div2 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 2 [get_registers *txclk_div2]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div2 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_div2
set_clock_groups -asynchronous -group map*_clk -group txclk_div2
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div2 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div2

#**************************************************************
# Arria II GX
# Auto-rate Negotiation Off (AUTORATE = 0)
# 6144.0 Mbps (LINERATE = 4)
#**************************************************************
create_generated_clock -name txclk_div2 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 2 [get_registers *txclk_div2]
create_generated_clock -name txclk_d2 -source [get_registers *txclk_div2] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_d2 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_d2
set_clock_groups -asynchronous -group map*_clk -group txclk_d2
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_d2 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_d2

#**************************************************************
# Cyclone IV GX
# Auto-rate Negotiation On (AUTORATE = 1)
# 614.4, 1228.8, 2457.6, 3072.0 Mbps (LINERATE = 614,0,1,2)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk_div2 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 2 [get_registers *txclk_div2]
create_generated_clock -name txclk_d2 -source [get_registers *txclk_div2] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -exclusive -group txclk_d2 -group {txclk_d4 txclk_div4 *receive_pcs0|clkout}
set_clock_groups -exclusive -group txclk_d4 -group {txclk_d2 txclk_div2 *receive_pcs0|clkout}
set_clock_groups -asynchronous -group cpu_clk -group {txclk_d2 txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk_d2 txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_d2 txclk_d4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk_d2 txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Cyclone IV GX
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Cyclone IV GX
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0 Mbps (LINERATE = 0,1,2)
#**************************************************************
create_generated_clock -name txclk_div2 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 2 [get_registers *txclk_div2]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div2 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_div2
set_clock_groups -asynchronous -group map*_clk -group txclk_div2
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div2 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div2

#**************************************************************
# Stratix IV
# Auto-rate Negotiation On (AUTORATE = 1)
# 614.4, 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 614,0,1,2,3,4)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -exclusive -group txclk -group {txclk_d4 txclk_div4 *receive_pcs0|clkout}
set_clock_groups -exclusive -group txclk_d4 -group {txclk *receive_pcs0|clkout}
set_clock_groups -asynchronous -group cpu_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk txclk_d4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Stratix IV
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Stratix IV
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 0,1,2,3,4)
#**************************************************************
set_clock_groups -asynchronous -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group *transmit_pcs0|clkout
set_clock_groups -asynchronous -group map*_clk -group *transmit_pcs0|clkout
set_clock_groups -asynchronous -group clk_ex_delay -group {*transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group {*transmit_pcs0|clkout *receive_pcs0|clkout}

#**************************************************************
# Arria II GZ
# Auto-rate Negotiation On (AUTORATE = 1)
# 614.4, 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 614,0,1,2,3,4)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -asynchronous -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -exclusive -group txclk -group {txclk_d4 txclk_div4 *receive_pcs0|clkout}
set_clock_groups -exclusive -group txclk_d4 -group {txclk txclk_div2 *receive_pcs0|clkout}
set_clock_groups -asynchronous -group cpu_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk txclk_d4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Arria II GZ
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *transmit_pcs0|clkout] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *receive_pcs0|clkout
set_clock_groups -exclusive -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Arria II GZ
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 0,1,2,3,4)
#**************************************************************
set_clock_groups -asynchronous -group *transmit_pcs0|clkout -group *receive_pcs0|clkout
set_clock_groups -asynchronous -group cpu_clk -group *transmit_pcs0|clkout
set_clock_groups -asynchronous -group map*_clk -group *transmit_pcs0|clkout
set_clock_groups -asynchronous -group clk_ex_delay -group {*transmit_pcs0|clkout *receive_pcs0|clkout}
set_clock_groups -asynchronous -group reconfig_clk -group {*transmit_pcs0|clkout *receive_pcs0|clkout}

#**************************************************************
# Stratix V
# Auto-rate Negotiation Off (AUTORATE = 1)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0, 9830.4 Mbps (LINERATE = 0,1,2,3,4,5)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|clkout] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|clkout] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *hssi_8g_tx_pcs|wys|clkout -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -exclusive -group txclk -group {txclk_d4 txclk_div4 *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -exclusive -group txclk_d4 -group {txclk *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group cpu_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk txclk_d4 *hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Stratix V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|clkout] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|clkout -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Stratix V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0, 9830.4 Mbps (LINERATE = 0,1,2,3,4,5)
#**************************************************************
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|clkout -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -asynchronous -group cpu_clk -group *hssi_8g_tx_pcs|wys|clkout
set_clock_groups -asynchronous -group map*_clk -group *hssi_8g_tx_pcs|wys|clkout
set_clock_groups -asynchronous -group clk_ex_delay -group {*hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group reconfig_clk -group {*hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}

#**************************************************************
# Arria V
# Auto-rate Negotiation Off (AUTORATE = 1)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 0,1,2,3,4)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|txpmalocalclk] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|txpmalocalclk] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *hssi_8g_tx_pcs|wys|txpmalocalclk -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -exclusive -group txclk -group {txclk_d4 txclk_div4 *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -exclusive -group txclk_d4 -group {txclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group cpu_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk txclk_d4 *hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Arria V
# Auto-rate Negotiation Off (AUTORATE = 1)
# 9830.4 Mbps (LINERATE = 5)
#**************************************************************
set_clock_groups -asynchronous -group *cpu_clk -group *usr_clk
set_clock_groups -asynchronous -group *map*clk -group *usr_clk

#**************************************************************
# Arria V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|txpmalocalclk] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|txpmalocalclk -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Arria V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0 Mbps (LINERATE = 0,1,2,3,4)
#**************************************************************
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|txpmalocalclk -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -asynchronous -group cpu_clk -group *hssi_8g_tx_pcs|wys|txpmalocalclk
set_clock_groups -asynchronous -group map*_clk -group *hssi_8g_tx_pcs|wys|txpmalocalclk
set_clock_groups -asynchronous -group clk_ex_delay -group {*hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group reconfig_clk -group {*hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}

#**************************************************************
# Arria V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 9830.4 Mbps (LINERATE = 5)
#**************************************************************
set_clock_groups -asynchronous -group *cpu_clk -group *usr_clk
set_clock_groups -asynchronous -group *map*clk -group *usr_clk

#**************************************************************
# Cyclone V
# Auto-rate Negotiation On (AUTORATE = 1)
# 1228.8, 2457.6, 3072.0 Mbps (LINERATE = 0,1,2)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|txpmalocalclk] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|txpmalocalclk] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *hssi_8g_tx_pcs|wys|txpmalocalclk -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -exclusive -group txclk -group {txclk_d4 txclk_div4 *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -exclusive -group txclk_d4 -group {txclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group cpu_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk txclk_d4 *hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Cyclone V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|txpmalocalclk] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|txpmalocalclk -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Cyclone V
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0 Mbps (LINERATE = 0,1,2)
#**************************************************************
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|txpmalocalclk -group *hssi_8g_rx_pcs|wys|rcvdclkpma
set_clock_groups -asynchronous -group cpu_clk -group *hssi_8g_tx_pcs|wys|txpmalocalclk
set_clock_groups -asynchronous -group map*_clk -group *hssi_8g_tx_pcs|wys|txpmalocalclk
set_clock_groups -asynchronous -group clk_ex_delay -group {*hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}
set_clock_groups -asynchronous -group reconfig_clk -group {*hssi_8g_tx_pcs|wys|txpmalocalclk *hssi_8g_rx_pcs|wys|rcvdclkpma}

#**************************************************************
# Arria V GZ
# Auto-rate Negotiation Off (AUTORATE = 1)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0, 9830.4 Mbps (LINERATE = 0,1,2,3,4,5)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|clkout] -divide_by 4 [get_registers *txclk_div4]
create_generated_clock -name txclk -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|clkout] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout]
create_generated_clock -name txclk_d4 -source [get_registers *txclk_div4] -divide_by 1 [get_nets *inst_tx_clock_switch|clkout] -add
derive_clock_uncertainty
set_clock_groups -exclusive -group *hssi_8g_tx_pcs|wys|clkout -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -exclusive -group txclk -group {txclk_d4 txclk_div4 *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -exclusive -group txclk_d4 -group {txclk *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group cpu_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group map*_clk -group {txclk txclk_d4}
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk txclk_d4 *hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group reconfig_clk -group {txclk txclk_d4}
set_false_path -from * -to *reg_clk0_a*
set_false_path -from * -to *reg_clk1_a*

#**************************************************************
# Arria V GZ
# Auto-rate Negotiation Off (AUTORATE = 0)
# 614.4 Mbps (LINERATE = 614)
#**************************************************************
create_generated_clock -name txclk_div4 -source [get_pins -compatibility_mode *hssi_8g_tx_pcs|wys|clkout] -divide_by 4 [get_registers *txclk_div4]
derive_clock_uncertainty
set_clock_groups -exclusive -group txclk_div4 -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|clkout -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -asynchronous -group cpu_clk -group txclk_div4
set_clock_groups -asynchronous -group map*_clk -group txclk_div4
set_clock_groups -asynchronous -group clk_ex_delay -group {txclk_div4 *hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group reconfig_clk -group txclk_div4

#**************************************************************
# Arria V GZ
# Auto-rate Negotiation Off (AUTORATE = 0)
# 1228.8, 2457.6, 3072.0, 4915.2, 6144.0, 9830.4 Mbps (LINERATE = 0,1,2,3,4,5)
#**************************************************************
set_clock_groups -asynchronous -group *hssi_8g_tx_pcs|wys|clkout -group *hssi_8g_rx_pcs|wys|clocktopld
set_clock_groups -asynchronous -group cpu_clk -group *hssi_8g_tx_pcs|wys|clkout
set_clock_groups -asynchronous -group map*_clk -group *hssi_8g_tx_pcs|wys|clkout
set_clock_groups -asynchronous -group clk_ex_delay -group {*hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group reconfig_clk -group {*hssi_8g_tx_pcs|wys|clkout *hssi_8g_rx_pcs|wys|clocktopld}

#**************************************************************
# End of Constraints
#**************************************************************
