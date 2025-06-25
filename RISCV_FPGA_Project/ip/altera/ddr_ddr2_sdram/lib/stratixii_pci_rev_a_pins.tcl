# ====================================================
# Pin assignment script for Address and Command pins 
# for the Stratix II PCI board (2S60 version, rev A)
#
# This board uses all the 9 byte groups available.
# However, unless you have a 72 bit SO-DIMM, you should
# use these byte groups: 
# DQS0 = 0T, DQS1 = 1T, DQS2 = 2T, DQS3 = 3T
# DQS4 = 5T, DQS5 = 6T, DQS6 = 7T, DQS7 = 8T 
# 
# NB: 
# * Don't forget to change the example PLL input 
#   clock frequency to 100MHz!
# ====================================================

# 100MHz refclock (CLK_OSC_B_PLL5 on schematic)
set_location_assignment PIN_C17 -to clock_source

# can use user_pb2 as reset_n or user_pb1 (connects to dev_clrn (AG19))
set_location_assignment PIN_L6 -to reset_n; 

set_location_assignment PIN_G20 -to ddr_ba\[0\]
set_location_assignment PIN_J20 -to ddr_ba\[1\]
set_location_assignment PIN_K20 -to ddr_a\[0\]
set_location_assignment PIN_L19 -to ddr_a\[1\]
set_location_assignment PIN_K19 -to ddr_a\[2\]
set_location_assignment PIN_J19 -to ddr_a\[3\]
set_location_assignment PIN_L18 -to ddr_a\[4\]
set_location_assignment PIN_K18 -to ddr_a\[5\]
set_location_assignment PIN_L15 -to ddr_a\[6\]
set_location_assignment PIN_J14 -to ddr_a\[7\]
set_location_assignment PIN_K14 -to ddr_a\[8\]
set_location_assignment PIN_L14 -to ddr_a\[9\]
set_location_assignment PIN_K21 -to ddr_a\[10\]
set_location_assignment PIN_H14 -to ddr_a\[11\]
set_location_assignment PIN_J13 -to ddr_a\[12\]
set_location_assignment PIN_J21 -to ddr_cs_n\[0\]
set_location_assignment PIN_K22 -to ddr_cs_n\[1\]
set_location_assignment PIN_K12 -to ddr_cke\[0\]
set_location_assignment PIN_L12 -to ddr_cke\[1\]
set_location_assignment PIN_G21 -to ddr_ras_n
set_location_assignment PIN_H22 -to ddr_cas_n
set_location_assignment PIN_G22 -to ddr_we_n
set_location_assignment PIN_B15 -to clk_to_sdram\[0\]
set_location_assignment PIN_C16 -to clk_to_sdram\[1\]
set_location_assignment PIN_D15 -to clk_to_sdram\[2\]
set_location_assignment PIN_C15 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_D16 -to clk_to_sdram_n\[1\]
set_location_assignment PIN_E15 -to clk_to_sdram_n\[2\]

set_location_assignment PIN_J6 -to user_leds\[0\]
set_location_assignment PIN_J7 -to user_leds\[1\]
set_location_assignment PIN_J8 -to user_leds\[2\]
set_location_assignment PIN_J9 -to user_leds\[3\]
set_location_assignment PIN_K6 -to user_leds\[4\]
set_location_assignment PIN_K7 -to user_leds\[5\]
set_location_assignment PIN_K8 -to user_leds\[6\]
set_location_assignment PIN_K9 -to user_leds\[7\]

# override the default in Quartus with the more sensible option
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# some of the pins are quite close together so reduce their drive strength
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_ras_n
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_cas_n
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_we_n
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_cke
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_a
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_ba
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_cs_n
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_dm
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_dq
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to ddr_dqs
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to clk_to_sdram
set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to clk_to_sdram_n
