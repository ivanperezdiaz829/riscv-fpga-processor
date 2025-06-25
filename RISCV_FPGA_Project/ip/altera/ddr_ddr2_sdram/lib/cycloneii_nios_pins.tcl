# =====================================================
# Pin & Location Assignments for Cyclone II Nios Board
#
# NB The clock input is 50MHz!! Don't forget to change
# the PLL.
#
# This board uses the following byte groups 
# DQS0 = 1L, DQS1 = 3L
#
# NB The ras_n and cas_n pins were swapped on the Rev 0
# board - this file is correct for all production boards.
# =====================================================

set_location_assignment PIN_B13 -to clock_source
set_location_assignment PIN_C5 -to reset_n

#set_location_assignment PIN_AC10 -to pnf
#set_location_assignment PIN_W11 -to test_complete


set_location_assignment PIN_T6 -to ddr_a[0]
set_location_assignment PIN_V2 -to ddr_a[1]
set_location_assignment PIN_R8 -to ddr_a[2]
set_location_assignment PIN_W3 -to ddr_a[3]
set_location_assignment PIN_R5 -to ddr_a[4]
set_location_assignment PIN_U10 -to ddr_a[5]
set_location_assignment PIN_P4 -to ddr_a[6]
set_location_assignment PIN_V1 -to ddr_a[7]
set_location_assignment PIN_T9 -to ddr_a[8]
set_location_assignment PIN_T8 -to ddr_a[9]
set_location_assignment PIN_AA2 -to ddr_a[10]
set_location_assignment PIN_T10 -to ddr_a[11]
set_location_assignment PIN_U3 -to ddr_a[12]
set_location_assignment PIN_U9 -to ddr_ba[0]
set_location_assignment PIN_Y4 -to ddr_ba[1]
set_location_assignment PIN_Y3 -to ddr_cs_n[0]
set_location_assignment PIN_R7 -to ddr_cke[0]

set_location_assignment PIN_U1 -to ddr_cas_n
set_location_assignment PIN_V4 -to ddr_ras_n
#set_location_assignment PIN_V4 -to ddr_cas_n
#set_location_assignment PIN_U1 -to ddr_ras_n

set_location_assignment PIN_U4 -to ddr_we_n
set_location_assignment PIN_AA7 -to clk_to_sdram[0]
set_location_assignment PIN_AA6 -to clk_to_sdram_n[0]

# A more sensible default
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_location_assignment PIN_AC10 -to user_led\[0\]
set_location_assignment PIN_W11 -to user_led\[1\]
set_location_assignment PIN_W12 -to user_led\[2\]
set_location_assignment PIN_AE8 -to user_led\[3\]
set_location_assignment PIN_AF8 -to user_led\[4\]
set_location_assignment PIN_AE7 -to user_led\[5\]
set_location_assignment PIN_AF7 -to user_led\[6\]
set_location_assignment PIN_AA11 -to user_led\[7\]

set_location_assignment PIN_Y11 -to user_pb\[0\]
set_location_assignment PIN_AA10 -to user_pb\[1\]
set_location_assignment PIN_AB10 -to user_pb\[2\]
set_location_assignment PIN_AE6 -to user_pb\[3\]
set_location_assignment PIN_AE13 -to hex_0a
set_location_assignment PIN_AF13 -to hex_0b
set_location_assignment PIN_AD12 -to hex_0c
set_location_assignment PIN_AE12 -to hex_0d
set_location_assignment PIN_AA12 -to hex_0e
set_location_assignment PIN_Y12 -to hex_0f
set_location_assignment PIN_V11 -to hex_0g
set_location_assignment PIN_U12 -to hex_0dp
set_location_assignment PIN_V14 -to hex_1a
set_location_assignment PIN_V13 -to hex_1b
set_location_assignment PIN_AD11 -to hex_1c
set_location_assignment PIN_AE11 -to hex_1d
set_location_assignment PIN_AE10 -to hex_1e
set_location_assignment PIN_AF10 -to hex_1f
set_location_assignment PIN_AD10 -to hex_1g
set_location_assignment PIN_AC11 -to hex_1dp
