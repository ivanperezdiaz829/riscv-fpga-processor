# =====================================================
# Pin & Location Assignments for Cyclone II PCI Board
#
# NB The clock input is 100MHz!! Don't forget to change
# the PLL.
#
# This board uses the following byte groups 
# DQS0 = 2T, DQS1 = 4T, DQS2 = 3T, DQS3 = 5T,
#
# =====================================================

# Called  sys_resetn  on the schematic
set_location_assignment PIN_C5 -to reset_n
set_instance_assignment -name IO_STANDARD "1.8 V" -to reset_n

# Called  osca_clk1   on the schematic
set_location_assignment PIN_N1 -to clock_source

# A more sensible default
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_location_assignment PIN_A19 -to ddr2_a[0]
set_location_assignment PIN_A20 -to ddr2_a[1]
set_location_assignment PIN_A21 -to ddr2_a[2]
set_location_assignment PIN_B19 -to ddr2_a[3]
set_location_assignment PIN_B21 -to ddr2_a[4]
set_location_assignment PIN_B22 -to ddr2_a[5]
set_location_assignment PIN_C19 -to ddr2_a[6]
set_location_assignment PIN_D18 -to ddr2_a[7]
set_location_assignment PIN_D19 -to ddr2_a[8]
set_location_assignment PIN_D20 -to ddr2_a[9]
set_location_assignment PIN_A4  -to ddr2_a[10]
set_location_assignment PIN_A5  -to ddr2_a[11]
set_location_assignment PIN_B4  -to ddr2_a[12]
set_location_assignment PIN_B5  -to ddr2_a[13]
set_location_assignment PIN_B6  -to ddr2_a[14]
set_location_assignment PIN_C4  -to ddr2_a[15]
set_location_assignment PIN_C22 -to ddr2_ba[0]
set_location_assignment PIN_C21 -to ddr2_ba[1]
set_location_assignment PIN_C11 -to ddr2_ba[2]
set_location_assignment PIN_F9  -to ddr2_cas_n
set_location_assignment PIN_D7  -to ddr2_ras_n
set_location_assignment PIN_C7  -to ddr2_we_n
set_location_assignment PIN_D21 -to ddr2_cke[0]
set_location_assignment PIN_C23 -to ddr2_cs_n[0]
set_location_assignment PIN_G9  -to ddr2_odt[0]

set_location_assignment PIN_A23 -to clk_to_sdram_n[0]
set_location_assignment PIN_A8  -to clk_to_sdram_n[1]
set_location_assignment PIN_A22 -to clk_to_sdram[0]
set_location_assignment PIN_A9  -to clk_to_sdram[1]
#set_location_assignment PIN_AF14 -to ddr2_fedback_clk
#set_location_assignment PIN_B7  -to ddr2_fedback_clk_out


#set_location_assignment PIN_AA12 -to user_sw[0]
#set_location_assignment PIN_AB8  -to user_sw[1]
#set_location_assignment PIN_AC6  -to user_sw[2]
#set_location_assignment PIN_AD12 -to user_sw[3]
#set_location_assignment PIN_AD8  -to user_sw[4]
#set_location_assignment PIN_G25  -to rs232_cts
#set_location_assignment PIN_H21  -to rs232_rts
#set_location_assignment PIN_G24  -to rs232_rxd
#set_location_assignment PIN_F24  -to rs232_txd
#set_location_assignment PIN_J22  -to user_led[0]
#set_location_assignment PIN_K19  -to user_led[1]
#set_location_assignment PIN_K21  -to user_led[2]
#set_location_assignment PIN_M21  -to user_led[3]
#set_location_assignment PIN_L23  -to user_led[4]
#set_location_assignment PIN_L19  -to user_led[5]
#set_location_assignment PIN_K24  -to user_led[6]
#set_location_assignment PIN_T21  -to user_led[7]
#set_location_assignment PIN_B12  -to user_pb[0]
#set_location_assignment PIN_D13  -to user_pb[1]
