# ====================================================
# Pin assignment script for Address and Command pins 
# for the Stratix PCI board (1S25 & 1S60 version, rev B)
#
# This board uses the following byte groups:
# DQS0 = 0T, DQS1 = 1T, DQS2 = 2T, DQS3 = 3T
# DQS4 = 5T, DQS5 = 6T, DQS6 = 7T, DQS7 = 8T
# 
# NB: 
# * Don't forget to change the example PLL input 
#   clock frequency to 100MHz!
# * This script sets the DM pin locations but the add
#   constraints scripts only sets them to an io_bank
#   so make sure you run this *after* add_constraints.
# ====================================================

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_location_assignment PIN_C19 -to clock_source
set_location_assignment PIN_AG22 -to reset_n

set_location_assignment PIN_H20 -to ddr_a\[0\]
set_location_assignment PIN_H13 -to ddr_a\[10\]
set_location_assignment PIN_H14 -to ddr_a\[11\]
set_location_assignment PIN_F13 -to ddr_a\[12\]
set_location_assignment PIN_F12 -to ddr_a\[13\]
set_location_assignment PIN_H19 -to ddr_a\[1\]
set_location_assignment PIN_G23 -to ddr_a\[2\]
set_location_assignment PIN_G21 -to ddr_a\[3\]
set_location_assignment PIN_G20 -to ddr_a\[4\]
set_location_assignment PIN_F23 -to ddr_a\[5\]
set_location_assignment PIN_F20 -to ddr_a\[6\]
set_location_assignment PIN_F19 -to ddr_a\[7\]
set_location_assignment PIN_H11 -to ddr_a\[8\]
set_location_assignment PIN_H12 -to ddr_a\[9\]
set_location_assignment PIN_L21 -to ddr_ba\[0\]
set_location_assignment PIN_J22 -to ddr_ba\[1\]
set_location_assignment PIN_J23 -to ddr_ba\[2\]
set_location_assignment PIN_H23 -to ddr_cas_n
set_location_assignment PIN_C14 -to ddr_cke\[0\]
set_location_assignment PIN_B14 -to ddr_cke\[1\]
set_location_assignment PIN_F24 -to ddr_cs_n\[0\]
set_location_assignment PIN_G24 -to ddr_cs_n\[1\]
set_location_assignment PIN_H22 -to ddr_ras_n
set_location_assignment PIN_J24 -to ddr_we_n

set_location_assignment PIN_B16 -to clk_to_sdram\[0\]
set_location_assignment PIN_B17 -to clk_to_sdram\[1\]
set_location_assignment PIN_B18 -to clk_to_sdram\[2\]

set_location_assignment PIN_A16 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_A17 -to clk_to_sdram_n\[1\]
set_location_assignment PIN_A18 -to clk_to_sdram_n\[2\]

set_location_assignment PIN_B15 -to stratix_dqs_ref_clk
set_location_assignment PIN_D18 -to stratix_dqs_ref_clk_out

set_location_assignment PIN_F7 -to ddr_dm\[0\]
set_location_assignment PIN_F8 -to ddr_dm\[1\]
set_location_assignment PIN_F9 -to ddr_dm\[2\]
set_location_assignment PIN_F10 -to ddr_dm\[3\]
set_location_assignment PIN_D29 -to ddr_dm\[4\]
set_location_assignment PIN_D28 -to ddr_dm\[5\]
set_location_assignment PIN_C30 -to ddr_dm\[6\]
set_location_assignment PIN_E28 -to ddr_dm\[7\]

#set_location_assignment PIN_C5 -to ddr_dqs\[0\]
#set_location_assignment PIN_E7 -to ddr_dqs\[1\]
#set_location_assignment PIN_A7 -to ddr_dqs\[2\]
#set_location_assignment PIN_D11 -to ddr_dqs\[3\]
#set_location_assignment PIN_D20 -to ddr_dqs\[4\]
#set_location_assignment PIN_D22 -to ddr_dqs\[5\]
#set_location_assignment PIN_B26 -to ddr_dqs\[6\]
#set_location_assignment PIN_B27 -to ddr_dqs\[7\]


set_location_assignment PIN_AF12 -to uart_rxd
set_location_assignment PIN_AC14 -to uart_txd

set_location_assignment PIN_AD23 -to user_dipsw\[0\]
set_location_assignment PIN_AE24 -to user_dipsw\[1\]
set_location_assignment PIN_AE23 -to user_dipsw\[2\]
set_location_assignment PIN_AF24 -to user_dipsw\[3\]
set_location_assignment PIN_AC22 -to user_dipsw\[4\]
set_location_assignment PIN_AG24 -to user_dipsw\[5\]
set_location_assignment PIN_AB22 -to user_dipsw\[6\]
set_location_assignment PIN_AF23 -to user_dipsw\[7\]
set_location_assignment PIN_AK28 -to user_led\[0\]
set_location_assignment PIN_AH28 -to user_led\[1\]
set_location_assignment PIN_AK30 -to user_led\[2\]
set_location_assignment PIN_AJ28 -to user_led\[3\]
set_location_assignment PIN_AJ29 -to user_led\[4\]
set_location_assignment PIN_AK29 -to user_led\[5\]
set_location_assignment PIN_AL30 -to user_led\[6\]
set_location_assignment PIN_AL29 -to user_led\[7\]
set_location_assignment PIN_AG9 -to user_pb1
set_location_assignment PIN_AM5 -to user_pb2

set_instance_assignment -name IO_STANDARD LVTTL -to uart_rxd
set_instance_assignment -name IO_STANDARD LVTTL -to uart_txd
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[0\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[1\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[2\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[3\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[4\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[5\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[6\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_dipsw\[7\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[0\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[1\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[2\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[3\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[4\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[5\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[6\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_led\[7\]
set_instance_assignment -name IO_STANDARD LVTTL -to user_pb1
set_instance_assignment -name IO_STANDARD LVTTL -to user_pb2
set_instance_assignment -name IO_STANDARD LVTTL -to reset_n


