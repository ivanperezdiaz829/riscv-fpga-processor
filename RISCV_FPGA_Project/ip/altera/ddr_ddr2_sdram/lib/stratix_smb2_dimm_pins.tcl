# ====================================================
# Pin assignment script for Address and Command pins 
# for the Stratix Memory board 2 (1S40 version, rev A)
#
# This board has two DDR2 SDRAM interfaces. This script 
# is for the DIMM and uses the following byte groups:
# DQS0 = 6B, DQS1 = 7B, DQS2 = 8B, DQS3 = 9B
# 
# NB: 
# * Don't forget to change the example PLL input 
#   clock frequency to 100MHz!
# * This script sets the DM pin locations but the add
#   constraints scripts only sets them to an io_bank
#   so make sure you run this *after* add_constraints.
# ====================================================


# Pin & Location Assignments
# ==========================
set_location_assignment PIN_A19 -to clock_source
set_location_assignment PIN_AE29 -to reset_n

set_location_assignment PIN_B16 -to clk_to_sdram\[0\]
set_location_assignment PIN_B17 -to clk_to_sdram\[1\]
set_location_assignment PIN_B18 -to clk_to_sdram\[2\]
set_location_assignment PIN_A16 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_A17 -to clk_to_sdram_n\[1\]
set_location_assignment PIN_A18 -to clk_to_sdram_n\[2\]

set_location_assignment PIN_B15 -to stratix_dqs_ref_clk
set_location_assignment PIN_D18 -to stratix_dqs_ref_clk_out
set_location_assignment PIN_T27 -to feedback_clk
set_location_assignment PIN_K24 -to feedback_clk_out

set_location_assignment PIN_C14 -to ddr2_dm\[8\]
set_location_assignment PIN_C29 -to ddr2_dm\[7\]
set_location_assignment PIN_F26 -to ddr2_dm\[6\]
set_location_assignment PIN_F25 -to ddr2_dm\[5\]
set_location_assignment PIN_F24 -to ddr2_dm\[4\]
set_location_assignment PIN_F10 -to ddr2_dm\[3\]
set_location_assignment PIN_F9 -to ddr2_dm\[2\]
set_location_assignment PIN_F8 -to ddr2_dm\[1\]
set_location_assignment PIN_F7 -to ddr2_dm\[0\]

set_location_assignment PIN_G23 -to ddr2_odt\[0\]
set_location_assignment PIN_G24 -to ddr2_odt\[1\]
set_location_assignment PIN_H20 -to ddr2_cke\[1\]
set_location_assignment PIN_H19 -to ddr2_cke\[0\]
set_location_assignment PIN_F23 -to ddr2_cs_n\[1\]
set_location_assignment PIN_G22 -to ddr2_cs_n\[0\]
set_location_assignment PIN_F21 -to ddr2_ras_n
set_location_assignment PIN_F22 -to ddr2_cas_n
set_location_assignment PIN_G21 -to ddr2_we_n

set_location_assignment PIN_F19 -to ddr2_ba\[2\]
set_location_assignment PIN_F20 -to ddr2_ba\[1\]
set_location_assignment PIN_G20 -to ddr2_ba\[0\]
set_location_assignment PIN_H9 -to ddr2_a\[15\]
set_location_assignment PIN_J9 -to ddr2_a\[14\]
set_location_assignment PIN_G13 -to ddr2_a\[13\]
set_location_assignment PIN_H11 -to ddr2_a\[12\]
set_location_assignment PIN_J11 -to ddr2_a\[11\]
set_location_assignment PIN_F13 -to ddr2_a\[10\]
set_location_assignment PIN_G10 -to ddr2_a\[9\]
set_location_assignment PIN_H12 -to ddr2_a\[8\]
set_location_assignment PIN_K13 -to ddr2_a\[7\]
set_location_assignment PIN_F12 -to ddr2_a\[6\]
set_location_assignment PIN_G12 -to ddr2_a\[5\]
set_location_assignment PIN_H13 -to ddr2_a\[4\]
set_location_assignment PIN_J13 -to ddr2_a\[3\]
set_location_assignment PIN_H14 -to ddr2_a\[2\]
set_location_assignment PIN_J14 -to ddr2_a\[1\]
set_location_assignment PIN_J15 -to ddr2_a\[0\]

set_location_assignment PIN_AB30 -to user_led\[0\]
set_location_assignment PIN_AB31 -to user_led\[1\]
set_location_assignment PIN_AA30 -to user_led\[2\]
set_location_assignment PIN_AA31 -to user_led\[3\]
set_location_assignment PIN_Y29 -to user_led\[4\]
set_location_assignment PIN_Y30 -to user_led\[5\]
set_location_assignment PIN_Y31 -to user_led\[6\]
set_location_assignment PIN_Y32 -to user_led\[7\]
set_location_assignment PIN_AC30 -to user_dipsw\[0\]
set_location_assignment PIN_AC29 -to user_dipsw\[1\]
set_location_assignment PIN_AD31 -to user_dipsw\[2\]
set_location_assignment PIN_AD32 -to user_dipsw\[3\]
set_location_assignment PIN_AC31 -to user_dipsw\[4\]
set_location_assignment PIN_AB32 -to user_dipsw\[5\]
set_location_assignment PIN_AA29 -to user_dipsw\[6\]
set_location_assignment PIN_AA28 -to user_dipsw\[7\]

set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name DEVICE EP1S40F1020C5

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V HSTL" -to clock_source
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to stratix_dqs_ref_clk_out
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to stratix_dqs_ref_clk
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to clk_to_sdram\[0\]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to clk_to_sdram\[1\]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to clk_to_sdram\[2\]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to clk_to_sdram_n\[0\]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to clk_to_sdram_n\[1\]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to clk_to_sdram_n\[2\]

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to feedback_clk
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to stratix_dqs_ref_clk_out_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to feedback_clk_out
