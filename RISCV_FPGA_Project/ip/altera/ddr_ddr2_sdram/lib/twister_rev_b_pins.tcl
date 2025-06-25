# ====================================================
# Pin assignment script for Address and Command pins
# for the Twister Cyclone board (www.fpga.nl).
#
# This board uses the following byte groups:
# DQS0 = 0L, DQS1 = 0T 
#
# Note that there are two possible DQS pins on each
# side of this device and the Megacore default (pin 50)
# for byte group 0L is different to this board (pin 11).
# ====================================================

# Megacore selects pin 50 for group OL for more flexible
# clocking, but the Twister uses the other optional DQS pin
set_location_assignment PIN_11 -to ddr_dqs\[0\]
set_location_assignment PIN_193 -to ddr_dqs\[1\]

set_location_assignment PIN_228 -to reset_n
set_location_assignment PIN_28 -to clock_source

set_location_assignment PIN_238 -to ddr_a\[0\]
set_location_assignment PIN_223 -to ddr_a\[10\]
set_location_assignment PIN_207 -to ddr_a\[11\]
set_location_assignment PIN_2 -to ddr_a\[1\]
set_location_assignment PIN_19 -to ddr_a\[2\]
set_location_assignment PIN_23 -to ddr_a\[3\]
set_location_assignment PIN_181 -to ddr_a\[4\]
set_location_assignment PIN_182 -to ddr_a\[5\]
set_location_assignment PIN_183 -to ddr_a\[6\]
set_location_assignment PIN_197 -to ddr_a\[7\]
set_location_assignment PIN_200 -to ddr_a\[8\]
set_location_assignment PIN_203 -to ddr_a\[9\]
set_location_assignment PIN_218 -to ddr_ba\[0\]
set_location_assignment PIN_222 -to ddr_ba\[1\]
set_location_assignment PIN_59 -to ddr_cas_n
set_location_assignment PIN_1 -to ddr_cke\[0\]
set_location_assignment PIN_39 -to clk_to_sdram_n\[0\]
set_location_assignment PIN_38 -to clk_to_sdram\[0\]
set_location_assignment PIN_41 -to ddr_cs_n\[0\]
set_location_assignment PIN_42 -to ddr_ras_n
set_location_assignment PIN_60 -to ddr_we_n

set_location_assignment PIN_102 -to txd_from_the_uart
set_location_assignment PIN_103 -to rxd_to_the_uart



