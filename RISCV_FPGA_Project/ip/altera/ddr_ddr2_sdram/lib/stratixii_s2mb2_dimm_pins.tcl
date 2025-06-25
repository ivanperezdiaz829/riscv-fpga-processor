# ====================================================
# Pin assignment script for Address and Command pins 
# for the Stratix II Memory Board 2 (2S60 version)
#
# This board has two DDR2 SDRAM interfaces. This script 
# is for the DIMM and uses the following byte groups:
# DQS0-3 = 0T-3T, DQS4-7 = 5T-8T, DQS8 = 4T 
# 
# NB: 
# * Don't forget to change the generated PLL input 
#   clock frequency to 100MHz!
# * To get the fed-back clock to work on S2BM2, you must
#   remove R122 from the board.
# ====================================================


set_global_assignment -name STRATIXII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"

# Pin & Location Assignments
# ==========================
#set_location_assignment PIN_A16 -to oscb_clk12_p
#set_location_assignment PIN_B16 -to oscb_clk12_n
set_location_assignment PIN_A16 -to clock_source

# set_location_assignment PIN_AG19 -to user_pb\[3\]
set_location_assignment PIN_AG19 -to reset_n

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
set_location_assignment PIN_H11 -to ddr2_a\[11\]
set_location_assignment PIN_H14 -to ddr2_a\[12\]
set_location_assignment PIN_L20 -to ddr2_a\[13\]
set_location_assignment PIN_H13 -to ddr2_a\[14\]
set_location_assignment PIN_J11 -to ddr2_a\[15\]
set_location_assignment PIN_G20 -to ddr2_ba\[0\]
set_location_assignment PIN_J20 -to ddr2_ba\[1\]
set_location_assignment PIN_K13 -to ddr2_ba\[2\]
set_location_assignment PIN_H22 -to ddr2_cas_n
set_location_assignment PIN_L13 -to ddr2_cke\[0\]
set_location_assignment PIN_K12 -to ddr2_cke\[1\]
set_location_assignment PIN_J21 -to ddr2_cs_n\[0\]
set_location_assignment PIN_K22 -to ddr2_cs_n\[1\]
set_location_assignment PIN_E25 -to ddr2_odt\[0\]
set_location_assignment PIN_L21 -to ddr2_odt\[1\]
set_location_assignment PIN_G21 -to ddr2_ras_n
set_location_assignment PIN_G22 -to ddr2_we_n

set_location_assignment PIN_C15 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_D16 -to clk_to_sdram_n\[1\]
set_location_assignment PIN_E15 -to clk_to_sdram_n\[2\]
set_location_assignment PIN_B15 -to clk_to_sdram\[0\]
set_location_assignment PIN_C16 -to clk_to_sdram\[1\]
set_location_assignment PIN_D15 -to clk_to_sdram\[2\]

# To get the fed-back clock to work on S2BM2, you must
# remove R122 from the board.
set_instance_assignment -name IO_STANDARD "1.8 V" -to fedback_clk_out
set_instance_assignment -name IO_STANDARD LVTTL -to fedback_clk_in
set_location_assignment PIN_B13 -to fedback_clk_out
set_location_assignment PIN_T30 -to fedback_clk_in

#set_location_assignment PIN_AC32 -to user_led\[0\]
# set_location_assignment PIN_AC31 -to user_led\[1\]
# set_location_assignment PIN_AB28 -to user_led\[2\]
# set_location_assignment PIN_AB27 -to user_led\[3\]
# set_location_assignment PIN_AD32 -to user_led\[4\]
# set_location_assignment PIN_AD31 -to user_led\[5\]
# set_location_assignment PIN_AE32 -to user_led\[6\]
# set_location_assignment PIN_AE31 -to user_led\[7\]
# set_location_assignment PIN_AG32 -to user_pb\[0\]
# set_location_assignment PIN_AG31 -to user_pb\[1\]
# set_location_assignment PIN_AE30 -to user_pb\[2\]
# set_location_assignment PIN_AG19 -to user_pb\[3\]

set_instance_assignment -name IO_STANDARD "1.8 V" -to reset_n
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V HSTL CLASS II" -to clock_source
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V HSTL CLASS II" -to oscb_clk12_p
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V HSTL CLASS II" -to oscb_clk12_n
