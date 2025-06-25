# ====================================================
# Pin assignment script for Address and Command pins 
# for the Stratix Memory board 1 (EP1S40F1020C5)
#
# This board has two DDR SDRAM interfaces. This script 
# is for the DIMM and uses the following byte groups:
# DQS0 = 0B, DQS1 = 1B, DQS2 = 2B, DQS3 = 3B
# DQS4 = 6B, DQS5 = 7B, DQS6 = 8B, DQS7 = 9B
# DQS8 = 5B        (Don't use 4B!)
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
# sys_reset pushbutton
set_location_assignment PIN_AM19 -to clock_source
set_location_assignment PIN_AG5 -to reset_n

set_location_assignment PIN_AM13 -to clk_to_sdram\[0\]
set_location_assignment PIN_AK12 -to clk_to_sdram\[1\]
set_location_assignment PIN_AL13 -to clk_to_sdram\[2\]
set_location_assignment PIN_AM14 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_AL12 -to clk_to_sdram_n\[1\]
set_location_assignment PIN_AL14 -to clk_to_sdram_n\[2\]

set_location_assignment PIN_AK19 -to stratix_dqs_ref_clk
set_location_assignment PIN_AJ19 -to stratix_dqs_ref_clk_out
set_location_assignment PIN_AB28 -to feedback_clk
set_location_assignment PIN_AL15 -to feedback_clk_out

set_location_assignment PIN_AG9  -to ddr_dm\[0\]
set_location_assignment PIN_AG10 -to ddr_dm\[1\]
set_location_assignment PIN_AF10 -to ddr_dm\[2\]
set_location_assignment PIN_AM11 -to ddr_dm\[3\]
set_location_assignment PIN_AG21 -to ddr_dm\[4\]
set_location_assignment PIN_AG22 -to ddr_dm\[5\]
set_location_assignment PIN_AG23 -to ddr_dm\[6\]
set_location_assignment PIN_AG24 -to ddr_dm\[7\]
set_location_assignment PIN_AG20 -to ddr_dm\[8\]

set_location_assignment PIN_AE24 -to ddr_cas_n
set_location_assignment PIN_AF23 -to ddr_ras_n
set_location_assignment PIN_AE23 -to ddr_we_n
set_location_assignment PIN_AF24 -to ddr_cs_n\[0\]
set_location_assignment PIN_AF11 -to ddr_cke\[0\]

set_location_assignment PIN_AF22 -to ddr_ba\[0\]
set_location_assignment PIN_AE22 -to ddr_ba\[1\]

set_location_assignment PIN_AK14 -to ddr_a\[0\]
set_location_assignment PIN_AJ15 -to ddr_a\[10\]
set_location_assignment PIN_AD12 -to ddr_a\[11\]
set_location_assignment PIN_AD11 -to ddr_a\[12\]
set_location_assignment PIN_AE14 -to ddr_a\[1\]
set_location_assignment PIN_AD14 -to ddr_a\[2\]
set_location_assignment PIN_AK13 -to ddr_a\[3\]
set_location_assignment PIN_AJ13 -to ddr_a\[4\]
set_location_assignment PIN_AG13 -to ddr_a\[5\]
set_location_assignment PIN_AH13 -to ddr_a\[6\]
set_location_assignment PIN_AE13 -to ddr_a\[7\]
set_location_assignment PIN_AF13 -to ddr_a\[8\]
set_location_assignment PIN_AF12 -to ddr_a\[9\]



set_location_assignment PIN_AB2 -to user_dipsw\[0\]
set_location_assignment PIN_AD20 -to user_dipsw\[1\]
set_location_assignment PIN_AE20 -to user_dipsw\[2\]
set_location_assignment PIN_AD19 -to user_dipsw\[3\]
set_location_assignment PIN_AJ18 -to user_dipsw\[4\]
set_location_assignment PIN_AH18 -to user_dipsw\[5\]
set_location_assignment PIN_AK18 -to user_dipsw\[6\]
set_location_assignment PIN_AA21 -to user_dipsw\[7\]
set_location_assignment PIN_R10 -to user_led\[0\]
set_location_assignment PIN_R9 -to user_led\[1\]
set_location_assignment PIN_R5 -to user_led\[2\]
set_location_assignment PIN_R6 -to user_led\[3\]
set_location_assignment PIN_P7 -to user_led\[4\]
set_location_assignment PIN_P8 -to user_led\[5\]
set_location_assignment PIN_R7 -to user_led\[6\]
set_location_assignment PIN_R8 -to user_led\[7\]
set_location_assignment PIN_AG8 -to user_pb0
set_location_assignment PIN_AH1 -to user_pb1
set_location_assignment PIN_AD24 -to user_pb2



set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name DEVICE EP1S40F1020C5
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "2.5-V" -to stratix_dqs_ref_clk_out
set_instance_assignment -name IO_STANDARD "2.5-V" -to stratix_dqs_ref_clk
set_instance_assignment -name IO_STANDARD "2.5-V" -to feedback_clk_out
set_instance_assignment -name IO_STANDARD "2.5-V" -to feedback_clk
set_instance_assignment -name IO_STANDARD "LVTTL" -to clock_source


