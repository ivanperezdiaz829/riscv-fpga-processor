# =====================================================
# Pin & Location Assignments for Cyclone II DSP Board
#
# NB The clock input is 100MHz!! Don't forget to change
# the PLL.
#
# This board uses the following byte groups 
# DQS0 = 2B, DQS1 = 4B, DQS2 = 5B, DQS3 = 3B,
# DQS4 = 3T, DQS5 = 5T, DQS6 = 4T, DQS7 = 2T,
# DQS8 = 1T
#
# Top    =   8, 4, 5, 6, 7, --
# Bottom =  --, 3, 2, 1, 0, -- 
#
# =====================================================

# A more sensible default
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_location_assignment PIN_A14 -to reset_n
set_instance_assignment -name IO_STANDARD "1.8 V" -to reset_n

# Called clkin_top on the schematic
set_location_assignment PIN_N2 -to clock_source
#set_location_assignment PIN_N25 -to clkin_bot


set_location_assignment PIN_AE4 -to ddr2_a[0]
set_location_assignment PIN_AC8 -to ddr2_a[1]
set_location_assignment PIN_AD6 -to ddr2_a[2]
set_location_assignment PIN_Y10 -to ddr2_a[3]
set_location_assignment PIN_AF5 -to ddr2_a[4]
set_location_assignment PIN_AD7 -to ddr2_a[5]
set_location_assignment PIN_AC6 -to ddr2_a[6]
set_location_assignment PIN_AB8 -to ddr2_a[7]
set_location_assignment PIN_AD5 -to ddr2_a[8]
set_location_assignment PIN_AE11 -to ddr2_a[9]
set_location_assignment PIN_AE5 -to ddr2_a[10]
set_location_assignment PIN_AD4 -to ddr2_a[11]
set_location_assignment PIN_Y12 -to ddr2_a[12]
set_location_assignment PIN_AF7 -to ddr2_a[13]
set_location_assignment PIN_AC5 -to ddr2_a[14]
set_location_assignment PIN_AF13 -to ddr2_a[15]
set_location_assignment PIN_Y18 -to ddr2_ba[0]
set_location_assignment PIN_AF23 -to ddr2_ba[1]
set_location_assignment PIN_AB15 -to ddr2_ba[2]
set_location_assignment PIN_AE20 -to ddr2_ras_n
set_location_assignment PIN_AA17 -to ddr2_we_n
set_location_assignment PIN_AC22 -to ddr2_cas_n
set_location_assignment PIN_AE21 -to ddr2_cke[0]
set_location_assignment PIN_AC19 -to ddr2_cke[1]
set_location_assignment PIN_AF22 -to ddr2_cs_n[0]
set_location_assignment PIN_AB18 -to ddr2_cs_n[1]
set_location_assignment PIN_AF21 -to ddr2_odt[0]
set_location_assignment PIN_AE23 -to ddr2_odt[1]

set_location_assignment PIN_AD19 -to clk_to_sdram_n[0]
set_location_assignment PIN_AD21 -to clk_to_sdram_n[1]
set_location_assignment PIN_AA20 -to clk_to_sdram_n[2]
set_location_assignment PIN_AC21 -to clk_to_sdram[0]
set_location_assignment PIN_AB20 -to clk_to_sdram[1]
set_location_assignment PIN_AD22 -to clk_to_sdram[2]
#set_location_assignment PIN_AF14 -to ddr2_sync_clk_in
#set_location_assignment PIN_AB21 -to ddr2_sync_clk

#set_location_assignment PIN_AA18 -to ddr2_scl
#set_location_assignment PIN_AF20 -to ddr2_sda
#set_location_assignment PIN_AD23 -to ddr2_resetn

set_location_assignment PIN_AC13 -to user_dipsw[0]
set_location_assignment PIN_A19  -to user_dipsw[1]
set_location_assignment PIN_C21  -to user_dipsw[2]
set_location_assignment PIN_C23  -to user_dipsw[3]
set_location_assignment PIN_AF4  -to user_dipsw[4]
set_location_assignment PIN_AC20 -to user_dipsw[5]
set_location_assignment PIN_AE18 -to user_dipsw[6]
set_location_assignment PIN_AE19 -to user_dipsw[7]
set_location_assignment PIN_E5   -to user_led[0]
set_location_assignment PIN_B3   -to user_led[1]
set_location_assignment PIN_F20  -to user_led[2]
set_location_assignment PIN_E22  -to user_led[3]
set_location_assignment PIN_AC3  -to user_led[4]
set_location_assignment PIN_AB4  -to user_led[5]
set_location_assignment PIN_AA6  -to user_led[6]
set_location_assignment PIN_AA7  -to user_led[7]
set_location_assignment PIN_Y21  -to dig_1_a
set_location_assignment PIN_T7   -to dig_1_b
set_location_assignment PIN_AB23 -to dig_1_c
set_location_assignment PIN_Y5   -to dig_1_d
set_location_assignment PIN_V3   -to dig_1_dp
set_location_assignment PIN_E1   -to dig_1_e
set_location_assignment PIN_U1   -to dig_1_f
set_location_assignment PIN_W21  -to dig_1_g
set_location_assignment PIN_K2   -to dig_2_a
set_location_assignment PIN_U25  -to dig_2_b
set_location_assignment PIN_AA3  -to dig_2_c
set_location_assignment PIN_V1   -to dig_2_d
set_location_assignment PIN_P7   -to dig_2_dp
set_location_assignment PIN_V7   -to dig_2_e
set_location_assignment PIN_U23  -to dig_2_f
set_location_assignment PIN_AC2  -to dig_2_g
