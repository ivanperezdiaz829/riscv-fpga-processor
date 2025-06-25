# ====================================================
# Pin assignment script for Address and Command pins 
# for the Stratix II High Speed IO board (2S60)
#
# This board uses all the 9 byte groups available.
# However, unless you have a 72 bit DIMM, you should
# use these byte groups: 
# DQS0 = 0T, DQS1 = 1T, DQS2 = 2T, DQS3 = 3T
# DQS4 = 5T, DQS5 = 6T, DQS6 = 7T, DQS7 = 8T 
# 
# NB: 
# * Don't forget to change the example PLL input 
#   clock frequency to 100MHz!
# ====================================================

# use pb0 as reset_n
set_location_assignment PIN_H11 -to reset_n

# 100MHz reference clock, CLKB_PLL5_P on the schematic
set_location_assignment PIN_A17 -to clock_source

set_location_assignment PIN_K20 -to ddr2_a\[0\]
set_location_assignment PIN_L19 -to ddr2_a\[1\]
set_location_assignment PIN_K19 -to ddr2_a\[2\]
set_location_assignment PIN_J19 -to ddr2_a\[3\]
set_location_assignment PIN_L18 -to ddr2_a\[4\]
set_location_assignment PIN_K18 -to ddr2_a\[5\]
set_location_assignment PIN_L15 -to ddr2_a\[6\]
set_location_assignment PIN_J14 -to ddr2_a\[7\]
set_location_assignment PIN_K14 -to ddr2_a\[8\]
set_location_assignment PIN_L14 -to ddr2_a\[9\]
set_location_assignment PIN_K21 -to ddr2_a\[10\]
set_location_assignment PIN_H14 -to ddr2_a\[11\]
set_location_assignment PIN_J13 -to ddr2_a\[12\]
set_location_assignment PIN_L20 -to ddr2_a\[13\]
set_location_assignment PIN_J12 -to ddr2_a\[14\]
set_location_assignment PIN_L13 -to ddr2_a\[15\]
set_location_assignment PIN_B15 -to clk_to_sdram\[0\]
set_location_assignment PIN_C16 -to clk_to_sdram\[1\]
set_location_assignment PIN_D15 -to clk_to_sdram\[2\]
set_location_assignment PIN_C15 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_D16 -to clk_to_sdram_n\[1\]
set_location_assignment PIN_E15 -to clk_to_sdram_n\[2\]
set_location_assignment PIN_E25 -to ddr2_odt\[0\]
set_location_assignment PIN_L21 -to ddr2_odt\[1\]
set_location_assignment PIN_G21 -to ddr2_ras_n
set_location_assignment PIN_G20 -to ddr2_ba\[0\]
set_location_assignment PIN_J20 -to ddr2_ba\[1\]
set_location_assignment PIN_H22 -to ddr2_cas_n
set_location_assignment PIN_K12 -to ddr2_cke\[0\]
set_location_assignment PIN_L12 -to ddr2_cke\[1\]
set_location_assignment PIN_J21 -to ddr2_cs_n\[0\]
set_location_assignment PIN_K22 -to ddr2_cs_n\[1\]
set_location_assignment PIN_G22 -to ddr2_we_n

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "1.8 V" -to reset_n
set_instance_assignment -name IO_STANDARD "1.8 V" -to clock_source


